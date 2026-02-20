/**
 * Barcode Lookup Service
 *
 * Orchestrates product data retrieval from external APIs with:
 * - MySQL-backed cache (30-day TTL, stale-while-revalidate)
 * - Waterfall: Open Food Facts → UPCitemdb → null
 * - Normalized output regardless of source
 */

const axios = require('axios');
const db = require('../models');

const CACHE_TTL_DAYS = 30;
const HTTP_TIMEOUT_MS = 5000;

const USER_AGENT = 'Makhzani/1.0 (inventory management; contact@makhzani.ma)';

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/**
 * Main entry point. Returns normalized product data or null if not found.
 * @param {string} barcode
 * @returns {Promise<object|null>}
 */
async function lookupBarcode(barcode) {
  // 1. Check cache
  const cached = await _getCached(barcode);
  if (cached) {
    const isExpired = new Date() > new Date(cached.expires_at);
    if (!isExpired) {
      return _formatCached(cached);
    }
    // Stale: return immediately but refresh in background
    _refreshInBackground(barcode);
    return _formatCached(cached);
  }

  // 2. Waterfall: try each source in order
  const result = await _fetchFromOpenFoodFacts(barcode)
    || await _fetchFromUPCitemdb(barcode);

  if (!result) return null;

  // 3. Save to cache
  await _saveToCache(barcode, result);

  return result;
}

// ---------------------------------------------------------------------------
// Cache
// ---------------------------------------------------------------------------

async function _getCached(barcode) {
  try {
    return await db.BarcodeCache.findOne({ where: { barcode } });
  } catch (err) {
    console.error('[BarcodeCache] Read error:', err.message);
    return null;
  }
}

async function _saveToCache(barcode, data) {
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + CACHE_TTL_DAYS);

  try {
    await db.BarcodeCache.upsert({
      barcode,
      name: data.name,
      brand: data.brand || null,
      quantity_string: data.quantity || null,
      unit: data.unit || null,
      unit_value: data.unit_value || null,
      category: data.category || null,
      image_url: data.image_url || null,
      images_json: data.images || [],
      source: data.source,
      confidence: data.confidence,
      looked_up_at: new Date(),
      expires_at: expiresAt,
    });
  } catch (err) {
    // Non-fatal — cache write failure should not break the response
    console.error('[BarcodeCache] Write error:', err.message);
  }
}

function _formatCached(cached) {
  return {
    barcode: cached.barcode,
    name: cached.name,
    brand: cached.brand,
    quantity: cached.quantity_string,
    unit: cached.unit,
    unit_value: cached.unit_value,
    category: cached.category,
    image_url: cached.image_url,
    images: cached.images_json, // uses getter
    source: cached.source,
    confidence: cached.confidence,
  };
}

async function _refreshInBackground(barcode) {
  try {
    const result = await _fetchFromOpenFoodFacts(barcode)
      || await _fetchFromUPCitemdb(barcode);
    if (result) await _saveToCache(barcode, result);
  } catch (err) {
    console.error('[BarcodeCache] Background refresh error:', err.message);
  }
}

// ---------------------------------------------------------------------------
// Open Food Facts (primary — unlimited, no key required)
// ---------------------------------------------------------------------------

async function _fetchFromOpenFoodFacts(barcode) {
  const fields = [
    'product_name', 'generic_name', 'brands',
    'quantity', 'categories_tags',
    'image_front_url', 'image_front_small_url',
    'image_ingredients_url', 'image_nutrition_url',
  ].join(',');

  try {
    const response = await axios.get(
      `https://world.openfoodfacts.org/api/v2/product/${barcode}.json`,
      {
        params: { fields },
        timeout: HTTP_TIMEOUT_MS,
        headers: { 'User-Agent': USER_AGENT },
      }
    );

    if (response.data?.status !== 1 || !response.data?.product) return null;

    return _normalizeOpenFoodFacts(barcode, response.data.product);
  } catch (err) {
    if (err.code !== 'ECONNABORTED') {
      console.error('[OFF] Fetch error:', err.message);
    }
    return null;
  }
}

function _normalizeOpenFoodFacts(barcode, p) {
  const name = p.product_name || p.generic_name;
  if (!name) return null; // unusable without a name

  const quantityStr = p.quantity || null;
  const { unit, unit_value } = _parseQuantityString(quantityStr);

  const images = [
    p.image_front_url,
    p.image_ingredients_url,
    p.image_nutrition_url,
  ].filter(Boolean);

  const category = p.categories_tags?.[0]
    ?.replace(/^[a-z]{2}:/, '') // strip language prefix "en:"
    ?.replace(/-/g, ' ') || null;

  const brand = p.brands?.split(',')[0]?.trim() || null;

  return {
    barcode,
    name: name.trim(),
    brand,
    quantity: quantityStr,
    unit,
    unit_value,
    category,
    image_url: images[0] || null,
    images,
    source: 'openfoodfacts',
    confidence: _scoreConfidence(name, images[0], unit),
  };
}

// ---------------------------------------------------------------------------
// UPCitemdb (fallback — 100 req/day free)
// ---------------------------------------------------------------------------

async function _fetchFromUPCitemdb(barcode) {
  try {
    const response = await axios.get(
      'https://api.upcitemdb.com/prod/trial/lookup',
      {
        params: { upc: barcode },
        timeout: HTTP_TIMEOUT_MS,
        headers: {
          'User-Agent': USER_AGENT,
          'Accept-Language': 'en',
        },
      }
    );

    if (response.data?.code !== 'OK' || !response.data?.items?.length) return null;

    return _normalizeUPCitemdb(barcode, response.data.items[0]);
  } catch (err) {
    if (err.code !== 'ECONNABORTED') {
      console.error('[UPCitemdb] Fetch error:', err.message);
    }
    return null;
  }
}

function _normalizeUPCitemdb(barcode, item) {
  const name = item.title;
  if (!name) return null;

  const quantityStr = item.size || item.weight || null;
  const { unit, unit_value } = _parseQuantityString(quantityStr);

  const images = item.images || [];

  return {
    barcode,
    name: name.trim(),
    brand: item.brand || null,
    quantity: quantityStr,
    unit,
    unit_value,
    category: item.category || null,
    image_url: images[0] || null,
    images,
    source: 'upcitemdb',
    confidence: _scoreConfidence(name, images[0], unit),
  };
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/**
 * Parses a free-text quantity string into structured unit + value.
 * Examples: "400g" → { unit: "g", unit_value: 400 }
 *           "1L"   → { unit: "l", unit_value: 1 }
 *           "6x33cl" → { unit: "cl", unit_value: 33 }
 */
function _parseQuantityString(str) {
  if (!str) return { unit: null, unit_value: null };

  const s = str.trim().toLowerCase();

  // Handle multiplier format: "6x33cl", "12 x 330ml"
  const multiMatch = s.match(/\d+\s*[x×]\s*(\d+(?:\.\d+)?)\s*(g|kg|ml|l|cl|oz|lb)/i);
  if (multiMatch) {
    return { unit: multiMatch[2].toLowerCase(), unit_value: parseFloat(multiMatch[1]) };
  }

  // Standard format: "400g", "1.5 L", "500 ml"
  const match = s.match(/^(\d+(?:\.\d+)?)\s*(g|kg|ml|l|cl|oz|lb|pcs?|pieces?|units?)?/i);
  if (match) {
    const rawUnit = match[2]?.toLowerCase() || null;
    const unit = _normalizeUnit(rawUnit);
    return { unit, unit_value: parseFloat(match[1]) };
  }

  return { unit: null, unit_value: null };
}

function _normalizeUnit(raw) {
  if (!raw) return null;
  const map = {
    'g': 'g', 'kg': 'kg',
    'ml': 'ml', 'l': 'l', 'cl': 'cl',
    'oz': 'oz', 'lb': 'lb',
    'pc': 'piece', 'pcs': 'piece', 'piece': 'piece', 'pieces': 'piece',
    'unit': 'piece', 'units': 'piece',
  };
  return map[raw] || raw;
}

function _scoreConfidence(name, imageUrl, unit) {
  if (name && imageUrl && unit) return 'high';
  if (name && imageUrl) return 'medium';
  return 'low';
}

module.exports = { lookupBarcode };

# Makhzani — Next 20 Features Roadmap

> Features prioritized by **real impact on Moroccan small sellers** — not tech vanity.
> Each feature builds on what exists and moves the app from "useful tool" to "can't live without it."

---

## Phase 2: Complete the Core Loop (Features 1–5)

_Right now the app tracks inventory and creates purchase orders. But the loop is broken — orders go out, but nothing comes back in. These 5 features close that gap._

### 1. Order Receiving & Stock Auto-Update
**Why:** Currently, when a seller receives goods from a supplier, they must manually adjust stock for every product. That's tedious and error-prone. This is the #1 missing piece.

**What it does:**
- Open an existing purchase order → tap "Receive"
- Confirm received quantities per item (may differ from ordered)
- Partial receiving support (supplier sent 80 out of 100 units)
- Stock automatically updates on confirmation
- Order status: `draft` → `sent` → `partially_received` → `received`

**Backend:** `POST /api/orders/:id/receive` with items array + quantities received
**Mobile:** New "Receive Order" screen with quantity inputs per item

---

### 2. Product Categories & Organization
**Why:** A seller with 200+ products scrolling a flat list wastes time daily. Categories make the app usable at scale.

**What it does:**
- Create custom categories (e.g., "Beverages", "Cleaning", "Snacks")
- Assign products to one category
- Filter product list by category
- Dashboard shows stats per category
- Default "Uncategorized" for existing products

**Backend:** New `Category` model, `category_id` on Product
**Mobile:** Category filter chips on products screen, category picker in product form

---

### 3. Stock Transaction History (Audit Trail)
**Why:** "Who changed the stock? When? Why?" — every seller asks this when numbers don't add up. Trust in the system depends on this.

**What it does:**
- Every stock change logged: manual adjustment, order received, wastage
- Transaction record: product, old_qty, new_qty, change_amount, reason, timestamp, source
- View history per product (detail screen → "History" tab)
- Filterable by date range and type

**Backend:** New `StockTransaction` model, auto-logged on every stock mutation
**Mobile:** Transaction history list on product detail screen

---

### 4. Push Notifications & Low-Stock Alerts
**Why:** The dashboard shows low-stock items, but sellers don't open the app every hour. Critical stock-outs need to find the seller, not the other way around.

**What it does:**
- Daily low-stock summary notification (morning)
- Instant alert when a product hits zero
- Order status notifications (PDF ready, marked as sent)
- Notification preferences in settings (toggle per type)
- FCM (Firebase Cloud Messaging) integration

**Backend:** Firebase Admin SDK, notification scheduler (cron job), `POST /api/notifications/register-device`
**Mobile:** FCM setup, notification permission flow, settings toggles

---

### 5. CSV Import/Export for Products
**Why:** A seller with 500 products isn't typing them one by one. Bulk import from a spreadsheet is the difference between adoption and abandonment.

**What it does:**
- Export all products to CSV (name, stock, price, barcode, category, unit, threshold)
- Import products from CSV with validation
- Preview import before confirming (show errors per row)
- Update existing products by barcode match
- Download template CSV

**Backend:** `GET /api/products/export` (CSV), `POST /api/products/import` (multipart CSV)
**Mobile:** Export button in products screen, import flow with file picker + preview

---

## Phase 3: Business Intelligence (Features 6–10)

_Data without insight is just noise. These features turn raw inventory data into decisions._

### 6. Inventory Reports & Analytics Dashboard
**Why:** "How much is my inventory worth? What's my best seller? What's dead stock?" — questions every seller needs answered.

**What it does:**
- Total inventory value (sum of stock × price)
- Stock turnover rate per product
- Dead stock identification (no movement in 30/60/90 days)
- Low stock frequency report (which products constantly run out)
- Filterable by date range, category
- Visual charts (bar, pie)

**Backend:** `GET /api/reports/inventory-summary`, `GET /api/reports/stock-movement`
**Mobile:** New "Reports" tab or section in dashboard with charts (fl_chart package)

---

### 7. Supplier Price Tracking & Comparison
**Why:** Suppliers change prices. A seller buying from 3 suppliers needs to know who offers the best deal — without checking old WhatsApp messages.

**What it does:**
- Track unit price per product per supplier (from purchase orders)
- Price history graph per product
- Compare prices across suppliers for the same product
- Highlight price increases/decreases
- Suggest cheapest supplier when creating orders

**Backend:** `GET /api/products/:id/price-history`, aggregate from PurchaseOrderItems
**Mobile:** Price history section on product detail, supplier comparison view

---

### 8. Smart Reorder Suggestions
**Why:** Instead of the seller manually checking what's low and creating orders, the app should suggest: "You need to reorder these 12 products from Supplier X."

**What it does:**
- Auto-detect products below reorder threshold
- Group by preferred/last supplier
- One-tap to create a pre-filled purchase order
- Suggested quantity based on past order patterns
- "Reorder" button on dashboard low-stock section

**Backend:** `GET /api/orders/suggestions` (grouped by supplier, based on reorder thresholds)
**Mobile:** Reorder suggestions card on dashboard, one-tap order creation

---

### 9. Expense & Cost Tracking
**Why:** Inventory value means nothing without knowing what you paid. Profit = selling price - cost. Without cost tracking, the seller is flying blind.

**What it does:**
- Track cost_price per product (separate from selling price)
- Calculate profit margin per product
- Total cost of goods per order
- Monthly expense summary
- Profit/loss overview

**Backend:** Add `cost_price` to Product model, `GET /api/reports/profit-summary`
**Mobile:** Cost price field in product form, profit column in reports

---

### 10. Multi-Currency & MAD-First Pricing
**Why:** Some Moroccan suppliers quote in EUR (imported goods). The app should handle this without the seller doing mental math.

**What it does:**
- Default currency: MAD (Moroccan Dirham)
- Support EUR, USD for supplier pricing
- Auto-convert to MAD using configurable exchange rate
- Display prices in MAD everywhere
- Exchange rate settings in profile

**Backend:** Currency field on PurchaseOrderItem, exchange rate config per merchant
**Mobile:** Currency picker on order form, exchange rate in settings

---

## Phase 4: Operational Power (Features 11–15)

_Features that save hours per week and prevent real losses._

### 11. Wastage & Loss Tracking
**Why:** Stock disappears — expired goods, damaged items, theft. If you don't track it, you can't control it.

**What it does:**
- Record wastage: product, quantity, reason (expired, damaged, lost, other)
- Auto-deducts from stock
- Monthly wastage report (by category, by reason)
- Wastage value calculation
- Logged in stock transaction history

**Backend:** `POST /api/products/:id/record-wastage`, wastage report endpoint
**Mobile:** "Record Loss" action on product detail, wastage summary in reports

---

### 12. Offline Mode with Sync
**Why:** Internet in Moroccan souks and rural areas is unreliable. The app must work without connection — stock adjustments, viewing products, creating orders locally.

**What it does:**
- Cache products, suppliers, orders locally (SQLite/Hive)
- Queue mutations offline (stock adjustments, new products)
- Auto-sync when connection restored
- Conflict resolution (server wins, with user notification)
- Visual indicator: online/offline status

**Mobile:** Local database (Hive/drift), sync queue, connectivity monitoring
**Backend:** Sync endpoint with last_synced_at timestamps

---

### 13. Employee Accounts & Permissions
**Why:** The shop owner can't do everything. An employee should scan barcodes and adjust stock, but not delete products or see financial reports.

**What it does:**
- Owner invites employees by phone number
- Roles: Owner (full access), Manager (no billing), Staff (view + adjust stock only)
- Activity log: who did what
- Owner can revoke access instantly

**Backend:** New `Employee` model with role, linked to merchant. Permission middleware.
**Mobile:** Team management in settings, role-based UI visibility

---

### 14. Barcode Label Printing
**Why:** Many small sellers don't have barcodes on products. Let them generate and print labels directly — makes scanning actually usable.

**What it does:**
- Generate barcode labels (EAN-13, Code-128) for any product
- Batch print multiple labels
- Customizable label: product name, price, barcode
- Export as PDF for standard label printers
- Thermal printer support (Bluetooth)

**Backend:** `POST /api/products/generate-labels` (PDF with barcode images)
**Mobile:** Label generation screen, Bluetooth printer pairing (optional)

---

### 15. WhatsApp Integration for Orders
**Why:** Moroccan business runs on WhatsApp. Generating a PDF then manually opening WhatsApp and attaching it is friction. One tap should do it.

**What it does:**
- "Send via WhatsApp" button on order detail
- Auto-opens WhatsApp with supplier's number pre-filled
- Attaches order PDF automatically
- Message template: "Order #{number} — {item_count} items"
- Track sent_via: whatsapp with timestamp

**Mobile:** WhatsApp deep link with PDF share intent (url_launcher + share_plus)
**Backend:** No changes needed (already tracks sent_via)

---

## Phase 5: Growth & Monetization (Features 16–20)

_Features that justify a paid subscription and create long-term retention._

### 16. Subscription & Payment System
**Why:** The app has trial logic but no way to actually pay. Without this, there's no business.

**What it does:**
- Subscription plans: Free (50 products), Pro (unlimited, 99 MAD/month), Business (multi-user, 199 MAD/month)
- Payment via CMI (Moroccan card gateway) or cash transfer
- Plan comparison screen
- Grace period (7 days after expiry)
- Receipt generation

**Backend:** Payment webhook, subscription management endpoints
**Mobile:** Subscription screen, plan picker, payment flow

---

### 17. Inventory Valuation & Financial Reports
**Why:** At tax time or when seeking financing, sellers need to know: "What is my inventory worth?" This is a premium feature worth paying for.

**What it does:**
- Real-time inventory valuation (FIFO, weighted average cost)
- Monthly/quarterly inventory reports
- PDF export for accountant
- Cost vs selling price analysis
- Stock value trend over time

**Backend:** `GET /api/reports/valuation`, calculation engine
**Mobile:** Financial reports section, PDF export

---

### 18. Customer Management (Basic CRM)
**Why:** An inventory app that also tracks who buys what becomes indispensable. This is the natural next step from "managing stock" to "managing a business."

**What it does:**
- Add customers (name, phone, notes)
- Record sales (which products, quantities, prices)
- Customer purchase history
- Top customers ranking
- Outstanding balance tracking (credit sales — common in Morocco)

**Backend:** New `Customer`, `Sale`, `SaleItem` models
**Mobile:** New "Customers" feature module, sales recording flow

---

### 19. Sales Recording & POS-Lite
**Why:** Knowing what comes IN (purchase orders) without knowing what goes OUT (sales) means you're tracking half the business. This completes the picture.

**What it does:**
- Quick sale recording: scan barcode → add quantity → confirm
- Auto-deduct stock on sale
- Daily/weekly/monthly sales summary
- Cash register mode (simple POS screen)
- Receipt generation (PDF or thermal print)

**Backend:** `POST /api/sales`, `GET /api/sales`, `GET /api/reports/sales-summary`
**Mobile:** Quick sale screen with barcode scanner, sales list, sales reports

---

### 20. Data Backup & Account Security
**Why:** "What if I lose my phone?" — every seller's fear. Data backup and security features build trust in the platform.

**What it does:**
- Automatic cloud backup (data is already server-side, but make it visible)
- Export all data as ZIP (products, suppliers, orders, history)
- Two-factor authentication option
- Login history (device, time, location)
- Account deletion with data export
- Session management (logout from other devices)

**Backend:** `GET /api/merchants/export-data`, login history tracking, session management
**Mobile:** Backup status in settings, export button, security settings

---

## Summary: Impact Matrix

| # | Feature | Effort | Impact | Priority |
|---|---------|--------|--------|----------|
| 1 | Order Receiving & Stock Auto-Update | Medium | Very High | Must Have |
| 2 | Product Categories | Low | High | Must Have |
| 3 | Stock Transaction History | Medium | Very High | Must Have |
| 4 | Push Notifications | Medium | High | Must Have |
| 5 | CSV Import/Export | Medium | Very High | Must Have |
| 6 | Inventory Reports & Analytics | High | Very High | Should Have |
| 7 | Supplier Price Tracking | Medium | High | Should Have |
| 8 | Smart Reorder Suggestions | Medium | Very High | Should Have |
| 9 | Expense & Cost Tracking | Low | High | Should Have |
| 10 | Multi-Currency (MAD/EUR) | Low | Medium | Nice to Have |
| 11 | Wastage & Loss Tracking | Low | High | Should Have |
| 12 | Offline Mode with Sync | Very High | Very High | Should Have |
| 13 | Employee Accounts | High | High | Should Have |
| 14 | Barcode Label Printing | Medium | Medium | Nice to Have |
| 15 | WhatsApp Integration | Low | Very High | Must Have |
| 16 | Subscription & Payments | High | Critical | Must Have |
| 17 | Inventory Valuation Reports | Medium | High | Should Have |
| 18 | Customer Management (CRM) | High | Very High | Should Have |
| 19 | Sales Recording & POS-Lite | Very High | Very High | Should Have |
| 20 | Data Backup & Security | Medium | High | Must Have |

---

## Recommended Build Order

**Sprint 1-2:** Features 1, 2, 5, 15 (close the core loop + WhatsApp)
**Sprint 3-4:** Features 3, 4, 11 (trust & visibility)
**Sprint 5-6:** Features 6, 8, 9 (intelligence)
**Sprint 7-8:** Features 16, 20 (monetization & trust)
**Sprint 9-10:** Features 7, 10, 14 (operational power)
**Sprint 11-14:** Features 13, 12, 18, 19 (scale & growth)
**Sprint 15:** Feature 17 (premium financial reports)

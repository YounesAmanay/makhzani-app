# Feature: Reports & Analytics — The Seller's Eye
Status: done

## Overview
A Reports section accessible from the dashboard. Three focused screens giving the seller
a complete window into their business: sales performance, product intelligence, and inventory health.

## Access Point
Dashboard screen → "Reports" button/card → ReportsScreen (tab container with 3 sections)

## Screens
1. Sales Report — revenue, profit, chart, top products, by period
2. Products Report — best sellers, dead stock, by category
3. Inventory Report — stock value, health score, by category

## Tasks

### Backend
- [x] Create `backend/routes/reports.js` with 3 endpoints ✓
- [x] `GET /api/reports/sales?period=today|week|month|last_month&from=&to=` ✓
- [x] `GET /api/reports/products` ✓
- [x] `GET /api/reports/inventory` ✓
- [x] Register reports router in `backend/server.js` ✓

### Mobile — Data Layer
- [x] Create entities: `sales_report.dart`, `products_report.dart`, `inventory_report.dart` ✓
- [x] Create models: `sales_report_model.dart`, `products_report_model.dart`, `inventory_report_model.dart` ✓
- [x] Create `reports_remote_datasource.dart` ✓
- [x] Create `reports_repository_impl.dart` ✓
- [x] Add API endpoints to `api_endpoints.dart` ✓

### Mobile — State Layer
- [x] Create `reports_provider.dart` (3 providers: sales, products, inventory) ✓

### Mobile — UI Layer
- [x] Create `reports_screen.dart` (tab container: Sales / Products / Inventory) ✓
- [x] Create `sales_report_screen.dart` ✓
- [x] Create `products_report_screen.dart` ✓
- [x] Create `inventory_report_screen.dart` ✓
- [x] Create `period_picker_widget.dart` ✓
- [x] Create `report_summary_card.dart` ✓
- [x] Add Reports entry point on dashboard screen (green banner card) ✓
- [x] Route: Navigator.push from dashboard (no router change needed) ✓

### Localization
- [x] Add all report keys to `app_en.arb`, `app_ar.arb`, `app_fr.arb` ✓
- [x] Run `flutter gen-l10n` ✓

## API Contracts

### GET /api/reports/sales
```json
Query: ?period=today|week|month|last_month&from=DATE&to=DATE
Response: {
  "data": {
    "period": { "from": "2026-02-01", "to": "2026-02-25" },
    "summary": {
      "total_revenue": 12450.00,
      "total_sales": 87,
      "total_profit": 3240.00,
      "avg_sale_value": 143.10,
      "cancelled_count": 3,
      "cancelled_value": 320.00
    },
    "chart": [{ "date": "2026-02-01", "revenue": 480.00, "count": 4 }],
    "top_products": [
      { "product_id": "...", "name": "Coca Cola", "revenue": 1200.00, "quantity": 240, "profit": 360.00 }
    ],
    "best_day": { "date": "2026-02-15", "revenue": 890.00 },
    "worst_day": { "date": "2026-02-03", "revenue": 120.00 }
  }
}
```

### GET /api/reports/products
```json
Response: {
  "data": {
    "best_sellers": [
      { "product_id": "...", "name": "...", "revenue": 1200.00, "quantity_sold": 240, "profit": 360.00, "margin_pct": 30 }
    ],
    "dead_stock": [
      { "product_id": "...", "name": "...", "current_stock": 45, "stock_value": 900.00, "days_since_last_sale": 67 }
    ],
    "by_category": [
      { "category_id": "...", "name": "Boissons", "revenue": 4200.00, "product_count": 12 }
    ]
  }
}
```

### GET /api/reports/inventory
```json
Response: {
  "data": {
    "total_stock_value": 34200.00,
    "total_products": 45,
    "healthy_stock": 28,
    "low_stock": 12,
    "zero_stock": 5,
    "health_score": 62,
    "by_category": [
      { "category_id": "...", "name": "Boissons", "stock_value": 8400.00, "product_count": 12, "low_stock_count": 3 }
    ],
    "reorder_impact": 2400.00
  }
}
```

## Log

- backend/routes/reports.js created — 3 endpoints
- registered in server.js
- mobile entities, models, datasource, repository, providers created
- UI: reports_screen (tabs), sales/products/inventory report screens, widgets
- dashboard: green Reports banner card pushing ReportsScreen
- ARB keys en/ar/fr, flutter gen-l10n run
- flutter analyze: 0 new issues

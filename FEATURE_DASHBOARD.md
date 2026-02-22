# Feature: Dashboard Analytics
Status: done

## What Exists (do not rebuild)
- Backend: GET /api/merchants/dashboard-stats — returns overview, low_stock_items, recent_orders ✓
- Mobile: full data layer (entities, models, datasource, provider) ✓
- Mobile: stats grid, revenue row, low stock list, recent orders list ✓

## What's Missing (build this)

### Backend
- [ ] Add 7-day chart data to dashboard-stats response (daily sales totals, last 7 days)
- [ ] Add top_selling_products to dashboard-stats response (top 5 by quantity sold this month)
- [ ] Fix recent_orders timestamps — use instance.get('created_at') not instance.created_at (RULE-007)

### Mobile
- [ ] Add fl_chart to pubspec.yaml
- [ ] Add SalesChartPoint entity (date, amount)
- [ ] Add TopSellingProduct entity (id, name, unit, totalSold, totalRevenue)
- [ ] Add SalesChartPointModel + TopSellingProductModel (fromJson + toEntity)
- [ ] Extend DashboardRemoteDataSource to parse chart_data + top_selling_products
- [ ] Extend DashboardState + DashboardNotifier to hold chart + top sellers
- [ ] Build SalesChartWidget (fl_chart BarChart, 7 bars, last 7 days)
- [ ] Build TopSellingList widget (ranked list, top 5)
- [ ] Wire both into dashboard_screen.dart between revenue row and low stock

## API Contract

### GET /api/merchants/dashboard-stats (extended response)
```json
{
  "success": true,
  "data": {
    "overview": {
      "total_products": 25,
      "low_stock_products": 3,
      "total_suppliers": 8,
      "total_orders": 12
    },
    "chart_data": [
      { "date": "2026-02-16", "amount": 1200.00, "count": 5 },
      { "date": "2026-02-17", "amount": 850.50, "count": 3 },
      { "date": "2026-02-18", "amount": 0, "count": 0 },
      { "date": "2026-02-19", "amount": 2100.00, "count": 8 },
      { "date": "2026-02-20", "amount": 950.00, "count": 4 },
      { "date": "2026-02-21", "amount": 1750.00, "count": 6 },
      { "date": "2026-02-22", "amount": 3200.00, "count": 11 }
    ],
    "top_selling_products": [
      { "product_id": "uuid", "name": "Product A", "unit": "kg", "total_sold": 45.5, "total_revenue": 2275.00 },
      { "product_id": "uuid", "name": "Product B", "unit": "pcs", "total_sold": 30, "total_revenue": 1500.00 }
    ],
    "low_stock_items": [...],
    "recent_orders": [...]
  }
}
```

## Log
- extended GET /dashboard-stats — added chart_data (7-day raw SQL) ✓ (backend/routes/merchants.js)
- extended GET /dashboard-stats — added top_selling_products (monthly SQL) ✓ (backend/routes/merchants.js)
- fixed recent_orders timestamp — instance.get('created_at') ✓ (backend/routes/merchants.js)
- added fl_chart ^0.70.0 ✓ (mobile/pubspec.yaml)
- added SalesChartPoint entity ✓ (mobile/lib/features/dashboard/domain/entities/sales_chart_point.dart)
- added TopSellingProduct entity ✓ (mobile/lib/features/dashboard/domain/entities/top_selling_product.dart)
- added SalesChartPointModel ✓ (mobile/lib/features/dashboard/data/models/sales_chart_point_model.dart)
- added TopSellingProductModel ✓ (mobile/lib/features/dashboard/data/models/top_selling_product_model.dart)
- extended DashboardRemoteDataSource to parse chart_data + top_selling_products ✓
- extended DashboardState + DashboardNotifier with chartData + topSelling ✓
- built SalesChartWidget (fl_chart BarChart, 7 bars) ✓ (mobile/lib/features/dashboard/presentation/widgets/sales_chart_widget.dart)
- built TopSellingList widget (ranked, card pattern) ✓ (mobile/lib/features/dashboard/presentation/widgets/top_selling_list.dart)
- added 4 l10n keys (en/ar/fr) ✓
- wired chart + top sellers into dashboard_screen.dart ✓
- flutter analyze — 0 errors ✓

## Polish Tasks
- [x] Make top selling product rows tappable — navigate to that product's detail screen ✓
- [x] Move language selector out of dashboard app bar profile sheet → into a dedicated Settings screen as a 3-option dropdown (EN / AR / FR) ✓

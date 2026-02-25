# ENGINEER RULES — Makhzani

Rules born from real violations. Each has a point penalty.
Start at 100. Below 70 = feature rejected, rewrite required.

---

## Scoring

| Score | Verdict |
|-------|---------|
| 90–100 | Accepted |
| 70–89 | Accepted with fixes |
| < 70 | **Rejected — rewrite** |

---

## Rules

### RULE-001 — No `min: 0` on monetary values (-20pts)
```javascript
// WRONG
body('items.*.unit_price').isFloat({ min: 0 })
// CORRECT
body('items.*.unit_price').isFloat({ min: 0.01 })
```
Zero price = bad data. Always `min: 0.01` for money.

---

### RULE-002 — No null-masking on NOT NULL fields (-15pts)
```dart
// WRONG — hides backend bugs
id: json['id']?.toString() ?? '',
// CORRECT — crash loudly, surface the bug
id: json['id'] as String,
```
Only use safe parsing (`double.parse(x.toString())`) for numeric DB fields that MySQL serializes as strings.

---

### RULE-003 — Every backend field must be parsed, mapped, and used (-20pts)
Before closing a feature:
1. Open the backend route
2. List every field in the response JSON
3. Confirm each is in `fromJson`, in the entity, and drives UI where relevant

Shipping a feature where `is_cancelled` exists in the response but not in the model = -20pts, no exceptions.

---

### RULE-004 — Business invariants enforced at the operation boundary (-15pts)
```dart
// WRONG — guard only at entry, bypassed by other paths
void addProduct(...) { if (price == null) showSheet(); }

// CORRECT — guard at the operation itself
Future<Sale?> confirmSale() async {
  if (state.items.any((i) => i.unitPrice <= 0)) { ... return null; }
}
```
Entry guards = UX. Boundary guards = correctness. Both required.

---

### RULE-005 — Never dual-access the same field via two casings (-10pts)
```javascript
// WRONG — you don't know your own stack
created_at: s.createdAt || s.created_at,
// CORRECT — verify once, use consistently
created_at: new Date(s.get('created_at')).toISOString(),
```

---

### RULE-006 — No temporary fixes (-20pts)
Fix the source. Never patch a symptom on one side to work around a bug on the other.
- Frontend reading both `created_at` and `createdAt` → fix the backend
- Catching a crash silently → fix what throws
- `?? fallback` on fields that must never be null → fix the contract

---

### RULE-007 — Never manually serialize Sequelize timestamps in routes (-15pts)
```javascript
// WRONG — patch each route manually, will be missed somewhere
created_at: order.createdAt,
created_at: new Date(s.get('created_at')).toISOString(),

// CORRECT — fix at the model layer globally (models/index.js toJSON override)
// All models serialize created_at/updated_at as snake_case automatically
```
With `underscored: true`, `toJSON()` still outputs camelCase. Fix this once in `models/index.js` — not in every route.

---

### RULE-010 — When the same bug appears in 2+ places, fix the root cause — not each instance (-20pts)
```javascript
// WRONG — patch symptoms one by one
// Fix orders.js... fix sales.js... fix merchants.js...

// CORRECT — find the shared root cause and fix it once
// e.g. toJSON() outputs camelCase → fix in models/index.js → all routes fixed
```
If you see the same error pattern in more than one file: **stop patching and fix the source**. The fix must be architectural, not repetitive.

---

### RULE-008 — All list tiles use the same card pattern (-15pts)
```dart
Material(
  color: theme.colorScheme.surface,
  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
  child: InkWell(
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: ...
    ),
  ),
)
```
No border = rejected. Wrong radius = rejected. Every card looks the same.

---

### RULE-009 — Refresh related providers after every mutation (-15pts)
```dart
// WRONG — stock changes on backend, UI still shows old value
await _repo.createSale(items: items);
// nothing else

// CORRECT — invalidate every provider whose data changed
await _repo.createSale(items: items);
_ref.read(productsProvider.notifier).refresh();       // stock changed
_ref.read(dashboardProvider.notifier).loadDashboard(); // stats changed
```
After ANY mutation (sale, stock adjust, order receive): refresh ALL providers whose state was affected. User must never need to pull-to-refresh to see their own action reflected.

---

## Sales Feature Post-Mortem: 20/100 — REJECTED

| Violation | Rule | Penalty |
|-----------|------|---------|
| `min: 0` on unit_price | RULE-001 | -20 |
| `?? ''` on NOT NULL fields | RULE-002 | -15 |
| `is_cancelled` not parsed | RULE-003 | -20 |
| Zero-price not checked in confirmSale | RULE-004 | -15 |
| `s.createdAt \|\| s.created_at` | RULE-005 | -10 |
| **Total** | | **20/100** |

---

## How Rules Are Added

Supervisor catches a violation → adds a rule.
Must include: penalty, wrong pattern (code), correct pattern (code), one-line rule.
Rules are never removed.

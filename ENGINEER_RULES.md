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

### RULE-007 — Use `instance.get('column_name')` for Sequelize timestamps (-15pts)
```javascript
// WRONG — breaks in findAndCountAll subqueries
new Date(s.createdAt).toISOString()
// CORRECT — reads dataValues directly, always works
new Date(s.get('created_at')).toISOString()
```
With `underscored: true`, `s.createdAt` getter can be undefined in subquery results.

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

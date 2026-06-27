# Summary — ShopEase SQL Analysis

## Overview

This task involved writing 27 SQL queries across 5 sections (basics, filtering, aggregation, joins, and advanced concepts) against a 4-table e-commerce schema, then validating the underlying sample data for quality issues before drawing conclusions.

## Key Business Insights

1. **Revenue by order status.** Delivered orders account for ₹17,191 across 6 orders — the largest share of recorded order value. Shipped orders (still in transit, not yet finalized) represent another ₹13,596 across 2 orders. Only 1 order has been Cancelled (₹2,999) and 1 remains Pending (₹1,299).

2. **Category pricing.** Electronics is both the most common category and the most evenly priced (₹899–₹3,499 across 4 products). Home products are consistently the cheapest tier (avg. ~₹949). Clothing's average (₹2,699) is misleading on its own — it's based on only 2 products (a ₹799 T-shirt and ₹4,599 running shoes), so it isn't a representative "typical price" the way the Electronics and Home averages are.

3. **Customer base.** 4 of 8 customers (50%) are flagged `is_premium = TRUE`, spread across different states rather than concentrated in one region. Customers joined steadily across 2024, roughly one per month from January through August.

4. **Cancellation rate.** 1 of 10 orders (10%) was cancelled in this sample — a useful baseline to track as order volume scales.

5. **Sample size caveat.** With only 8 customers, 8 products, and 10 orders, these patterns illustrate the query logic rather than carry strong statistical weight. The same SQL would scale directly to a full production dataset without modification.

## Data Quality Finding

While validating the data (Section 2.4 of the notebook), I checked whether each order's stated `total_amount` reconciles with the sum of its `order_items` (both before and after the line-item discount).

**Result: 5 of 10 orders do not match either calculation.**

| order_id | stated total_amount | sum before discount | sum after discount |
|---|---|---|---|
| 1001 | 4498 | 3897.00 | 3807.10 |
| 1003 | 7498 | 7598.00 | 7368.05 |
| 1006 | 5898 | 6098.00 | 5718.15 |
| 1009 | 6098 | 4697.00 | 4517.30 |
| 1010 | 1598 | 1898.00 | 1898.00 |

This is a genuine inconsistency in the sample data provided with the assignment, not an error introduced by the queries. It means `orders.total_amount` cannot be fully trusted as a ground-truth revenue figure for these 5 orders — any real reporting built on this column should reconcile it against `order_items` first, or flag the discrepancy to whoever owns the source data.

For this task, `total_amount` was used as-is for the questions that explicitly call for it (Q14, Q16), since that's the column the assignment schema and questions point to — but this caveat is worth raising if asked about data quality.

## Constraint & Integrity Checks (Sections A & D)

Three database rules were tested directly by attempting to violate them:

- **Duplicate email** → rejected by the `UNIQUE` constraint on `customers.email`
- **Negative price** (`unit_price = -50`) → rejected by `CHECK (unit_price > 0)` on `products`
- **Invalid customer reference** (`customer_id = 999`, which doesn't exist) → rejected by the Foreign Key constraint on `orders.customer_id`

All three behaved as the schema intends, confirming the constraints are actively protecting data integrity rather than just being declared and ignored.

## Section E — Transactions

Q27 demonstrates a multi-step atomic transaction: inserting a new order, inserting its line items, and decrementing stock for the purchased products, all wrapped in a single `BEGIN ... COMMIT` block. This directly illustrates the **Atomicity** property from ACID (Q26) — if any step failed partway through, a `ROLLBACK` would undo everything already done in that transaction, so the order, its items, and the stock levels never end up out of sync with each other.

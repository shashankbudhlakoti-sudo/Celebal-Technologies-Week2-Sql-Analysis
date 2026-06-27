# ShopEase E-Commerce Sales Database — SQL Analysis

**Celebal Summer Internship 2026 — Week 2 Task**

## Scenario

As a Junior Data Analyst at **ShopEase**, a mid-sized e-commerce company selling electronics, clothing, and home products across India, this task involves writing SQL queries against the company's relational database to extract meaningful business insights — covering filtering, aggregation, joins, and transaction management.

## Database Schema

The database consists of 4 tables:

| Table | Primary Key | Foreign Keys |
|---|---|---|
| `customers` | `customer_id` | — |
| `products` | `product_id` | — |
| `orders` | `order_id` | `customer_id` → `customers` |
| `order_items` | `item_id` | `order_id` → `orders`, `product_id` → `products` |

**Relationships:**
```
customers (1:N) → orders
orders    (1:N) → order_items
products  (1:N) → order_items
```

## Repository Structure

```
.
├── data/
│   └── shopease.db            # SQLite database (schema + sample data loaded)
├── notebooks/
│   └── ShopEase_SQL_Analysis.ipynb   # Full walkthrough: all 27 queries, explanations, results
├── sql/
│   ├── 01_schema_and_data.sql # CREATE TABLE statements, indexes, and INSERTs
│   └── 02_queries.sql         # Standalone script with all 27 query answers
├── requirements.txt
├── SUMMARY.md                 # Key findings and insights
└── README.md
```

## How to Run

**Option 1 — Notebook (recommended, includes explanations and live output):**
```bash
pip install -r requirements.txt
jupyter notebook notebooks/ShopEase_SQL_Analysis.ipynb
```
The notebook rebuilds `data/shopease.db` from a clean state on every run, so it can be re-executed safely.

**Option 2 — Raw SQL:**
```bash
sqlite3 data/shopease.db < sql/01_schema_and_data.sql
sqlite3 data/shopease.db < sql/02_queries.sql
```
All queries use standard SQL and run unchanged on MySQL or PostgreSQL (two minor engine-specific notes are called out inline in `02_queries.sql`: SQLite's `strftime()` vs MySQL's `YEAR()`, and SQLite's lack of native `FULL OUTER JOIN`).

## Task Coverage

| Section | Topic | Questions |
|---|---|---|
| A | SQL Basics — SELECT, Constraints, Primary Keys | Q1–Q6 |
| B | Filtering & Optimization — WHERE, Indexes | Q7–Q12 |
| C | Aggregation — GROUP BY, SUM, COUNT, AVG, MIN, MAX | Q13–Q18 |
| D | Joins & Relationships | Q19–Q23 |
| E | Advanced Concepts — CASE, ACID, Transactions | Q24–Q27 |

See `SUMMARY.md` for key findings, including a data quality issue discovered during validation.

## Tools Used

- SQLite 3 (via Python's built-in `sqlite3` module) — chosen for portability; all SQL is standard and portable to MySQL/PostgreSQL
- Python 3 + pandas — for running queries and displaying results in the notebook
- Jupyter Notebook

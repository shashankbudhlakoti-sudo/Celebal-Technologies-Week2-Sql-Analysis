-- ============================================================
-- ShopEase E-Commerce Sales Database — Query Answers
-- Celebal Summer Internship 2026 — Week 2 Task
-- ============================================================
-- Run 01_schema_and_data.sql first to create and populate the tables.
-- All queries below use standard SQL and run unchanged on MySQL/PostgreSQL,
-- except where noted (SQLite's strftime() vs MySQL's YEAR()).


-- ============================================================
-- SECTION A — SQL Basics (SELECT, Constraints, Primary Keys)
-- ============================================================

-- Q1. Display all columns and rows from the customers table.
SELECT * FROM customers;

-- Q2. Retrieve only first_name, last_name, and city of all customers.
SELECT first_name, last_name, city
FROM customers;

-- Q3. List all unique categories available in the products table.
SELECT DISTINCT category
FROM products;

-- Q4. (Conceptual) Primary Keys: customers.customer_id, products.product_id,
--     orders.order_id, order_items.item_id.
--     A Primary Key must be unique and NOT NULL so that every row has exactly
--     one identity that can be reliably referenced by Foreign Keys elsewhere.

-- Q5. (Conceptual) customers.email is UNIQUE NOT NULL. A duplicate insert is
--     rejected by the database with a unique-constraint violation error.

-- Q6. Inserting a product with unit_price = -50 violates CHECK (unit_price > 0)
--     and is rejected. Example statement (will fail):
INSERT INTO products VALUES
(209, 'Broken Pricing Test', 'Electronics', 'TestBrand', -50.00, 100);


-- ============================================================
-- SECTION B — Filtering & Optimization (WHERE, Indexes)
-- ============================================================

-- Q7. Retrieve all orders with status = 'Delivered'.
SELECT * FROM orders
WHERE status = 'Delivered';

-- Q8. Find all Electronics products with unit_price > 2000.
SELECT * FROM products
WHERE category = 'Electronics' AND unit_price > 2000;

-- Q9. Customers who joined in 2024 and belong to Maharashtra.
-- SQLite version (strftime); MySQL equivalent: WHERE YEAR(join_date) = 2024
SELECT * FROM customers
WHERE strftime('%Y', join_date) = '2024'
  AND state = 'Maharashtra';

-- Q10. Orders placed between '2024-08-10' and '2024-08-25' (inclusive), not cancelled.
SELECT * FROM orders
WHERE order_date BETWEEN '2024-08-10' AND '2024-08-25'
  AND status != 'Cancelled';

-- Q11. (Conceptual) idx_orders_date speeds up lookups/filters on order_date by
--     letting the engine seek directly to matching rows instead of scanning
--     the whole table. Sample query that benefits:
SELECT * FROM orders
WHERE order_date >= '2024-08-15';

-- Q12. YEAR(join_date) = 2024 is NOT SARGable — wrapping the column in a
--     function prevents index use. SARGable rewrite:
SELECT * FROM customers
WHERE join_date >= '2024-01-01' AND join_date < '2025-01-01';


-- ============================================================
-- SECTION C — Aggregation (GROUP BY, SUM, COUNT, AVG, MIN, MAX)
-- ============================================================

-- Q13. Total number of orders.
SELECT COUNT(*) AS total_orders FROM orders;

-- Q14. Total revenue from all Delivered orders.
SELECT SUM(total_amount) AS total_revenue
FROM orders
WHERE status = 'Delivered';

-- Q15. Average unit_price of products in each category.
SELECT category, ROUND(AVG(unit_price), 2) AS avg_price
FROM products
GROUP BY category;

-- Q16. Count of orders and total revenue per status, sorted by revenue descending.
SELECT status,
       COUNT(*) AS order_count,
       SUM(total_amount) AS total_revenue
FROM orders
GROUP BY status
ORDER BY total_revenue DESC;

-- Q17. Most expensive and cheapest product in each category.
SELECT category,
       MAX(unit_price) AS most_expensive,
       MIN(unit_price) AS cheapest
FROM products
GROUP BY category;

-- Q18. Categories where average unit_price > 2000 (HAVING, since the filter
--      applies to an aggregated value).
SELECT category, ROUND(AVG(unit_price), 2) AS avg_price
FROM products
GROUP BY category
HAVING AVG(unit_price) > 2000;


-- ============================================================
-- SECTION D — Joins & Relationships
-- ============================================================

-- Q19. INNER JOIN: each order with the customer's first_name and last_name.
SELECT o.order_id, o.order_date, c.first_name, c.last_name, o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- Q20. LEFT JOIN: ALL customers and their orders (if any).
SELECT c.customer_id, c.first_name, c.last_name,
       o.order_id, o.order_date, o.status
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Q21. Three-table JOIN (orders -> order_items -> products).
SELECT o.order_id, p.product_name, oi.quantity, oi.unit_price, oi.discount_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id;

-- Q22. (Conceptual) LEFT JOIN keeps all rows from the left table; RIGHT JOIN
--     keeps all rows from the right table. FULL OUTER JOIN keeps all rows from
--     both sides. SQLite has no native FULL OUTER JOIN; emulate with:
SELECT c.customer_id, o.order_id
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
UNION
SELECT c.customer_id, o.order_id
FROM orders o LEFT JOIN customers c ON c.customer_id = o.customer_id;

-- Q23. Foreign Keys: orders.customer_id -> customers.customer_id,
--     order_items.order_id -> orders.order_id,
--     order_items.product_id -> products.product_id.
--     Inserting an order with customer_id = 999 violates the FK constraint
--     and is rejected (with PRAGMA foreign_keys = ON in SQLite; enforced by
--     default in MySQL/PostgreSQL). Example statement (will fail):
INSERT INTO orders VALUES
(1099, 999, '2024-09-01', 'Pending', 500.00);


-- ============================================================
-- SECTION E — Advanced Concepts (CASE, ACID, Transactions)
-- ============================================================

-- Q24. Classify products into price tiers using CASE.
SELECT product_name, unit_price,
       CASE
           WHEN unit_price < 1000 THEN 'Budget'
           WHEN unit_price BETWEEN 1000 AND 3000 THEN 'Mid-Range'
           ELSE 'Premium'
       END AS price_tier
FROM products;

-- Q25. Count of 'Delivered' vs 'Not Delivered' orders, single row.
SELECT
    SUM(CASE WHEN status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_count,
    SUM(CASE WHEN status != 'Delivered' THEN 1 ELSE 0 END) AS not_delivered_count
FROM orders;

-- Q26. (Conceptual) ACID = Atomicity, Consistency, Isolation, Durability.
--     See notebook / README for the full bank-transfer explanation.

-- Q27. Atomic transaction: insert order 1011, insert two order_items,
--     update stock_qty for both products, COMMIT or ROLLBACK as a unit.
BEGIN;

INSERT INTO orders VALUES
(1011, 102, CURRENT_DATE, 'Pending', 1598.00);

INSERT INTO order_items VALUES
(5016, 1011, 206, 1, 1299.00, 0);

INSERT INTO order_items VALUES
(5017, 1011, 208, 1, 599.00, 0);

UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 206;
UPDATE products SET stock_qty = stock_qty - 1 WHERE product_id = 208;

COMMIT;
-- If any statement above fails, run ROLLBACK; instead of COMMIT;


-- ============================================================
-- VALIDATION QUERIES
-- ============================================================

-- Row counts per table
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;

-- Orphaned orders (no matching customer)
SELECT o.* FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Duplicate customer emails
SELECT email, COUNT(*) AS occurrences
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Consistency check: does orders.total_amount match its line items?
-- (Finding: 5 of 10 orders do NOT reconcile — see SUMMARY.md for details.)
SELECT
    o.order_id,
    o.total_amount AS stated_total,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS sum_before_discount,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct / 100.0)), 2) AS sum_after_discount
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
ORDER BY o.order_id;

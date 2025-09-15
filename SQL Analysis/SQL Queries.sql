-- Create and use new database
CREATE DATABASE retail_store;
USE retail_store;

-- 1. Create Customers Table
CREATE TABLE customers (
  customer_id VARCHAR(20) PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  gender VARCHAR(10),
  age INT,
  signup_date DATE,
  region VARCHAR(50),
  age_group VARCHAR(20)
);

-- 2. Create Products Table
CREATE TABLE products (
  product_id VARCHAR(20) PRIMARY KEY,
  product_name VARCHAR(100),
  category VARCHAR(50),
  brand VARCHAR(50),
  cost_price DECIMAL(10,2),
  unit_price DECIMAL(10,2),
  margin_pct DECIMAL(5,2),
  profit_per_unit DECIMAL(10,2),
  price_range VARCHAR(20),
  margin_category VARCHAR(20)
);

-- 3. Create Stores Table
CREATE TABLE stores (
  store_id VARCHAR(20) PRIMARY KEY,
  store_name VARCHAR(100),
  store_type VARCHAR(50),
  region VARCHAR(50),
  city VARCHAR(50),
  operating_cost DECIMAL(10,2)
);

-- 4. Create Sales Table (no foreign keys yet)
CREATE TABLE sales (
  order_id VARCHAR(20),
  order_date DATE,
  customer_id VARCHAR(20),
  product_id VARCHAR(20),
  store_id VARCHAR(20),
  sales_channel VARCHAR(50),
  quantity INT,
  unit_price DECIMAL(10,2),
  discount_pct DECIMAL(5,2),
  total_amount DECIMAL(10,2),
  PRIMARY KEY (order_id, product_id)
);

-- 5. Create Returns Table
CREATE TABLE returns (
  return_id VARCHAR(20) PRIMARY KEY,
  order_id VARCHAR(20),
  return_date DATE,
  return_reason VARCHAR(100),
  reason_category VARCHAR(50)
);


SELECT 'Customers' AS table_name, COUNT(*) FROM customers;
SELECT 'Products' AS table_name, COUNT(*) FROM products;
SELECT 'Stores' AS table_name, COUNT(*) FROM stores;
SELECT 'Sales' AS table_name, COUNT(*) FROM sales;
SELECT 'Returns' AS table_name, COUNT(*) FROM returns;

-- 7. Clean invalid customer_ids from sales
DELETE FROM sales
WHERE customer_id IN (
  SELECT s.customer_id
  FROM (
    SELECT s.customer_id
    FROM sales s
    LEFT JOIN customers c ON s.customer_id = c.customer_id
    WHERE c.customer_id IS NULL
  ) AS s
);

-- 8. Clean invalid product_ids from sales
DELETE FROM sales
WHERE product_id IN (
  SELECT s.product_id
  FROM (
    SELECT s.product_id
    FROM sales s
    LEFT JOIN products p ON s.product_id = p.product_id
    WHERE p.product_id IS NULL
  ) AS s
);

-- 9. Clean invalid store_ids from sales
DELETE FROM sales
WHERE store_id IN (
  SELECT s.store_id
  FROM (
    SELECT s.store_id
    FROM sales s
    LEFT JOIN stores st ON s.store_id = st.store_id
    WHERE st.store_id IS NULL
  ) AS s
);

-- 10. Clean invalid order_ids from returns
DELETE FROM returns
WHERE order_id IN (
  SELECT r.order_id
  FROM (
    SELECT r.order_id
    FROM returns r
    LEFT JOIN sales s ON r.order_id = s.order_id
    WHERE s.order_id IS NULL
  ) AS r
);

-- 11. add Foreign Keys
ALTER TABLE sales
ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE sales
ADD FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE sales
ADD FOREIGN KEY (store_id) REFERENCES stores(store_id);

ALTER TABLE returns
ADD FOREIGN KEY (order_id) REFERENCES sales(order_id);


-- 1. What is the total revenue generated in the last 12 months?
SELECT 
    ROUND(SUM(total_amount), 2) AS total_revenue_last_12_months
FROM sales
WHERE order_date >= CURDATE() - INTERVAL 12 MONTH;

-- 2. Which are the top 5 best-selling products by quantity?
SELECT 
    p.product_id,
    p.product_name,
    SUM(s.quantity) AS total_quantity_sold
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- 3. How many customers are from each region?
SELECT 
    region,
    COUNT(*) AS customer_count
FROM customers
GROUP BY region;

-- 4. Which store has the highest profit in the past year?
SELECT 
    st.store_id,
    st.store_name,
    ROUND(SUM(p.profit_per_unit * s.quantity), 2) AS total_profit
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN stores st ON s.store_id = st.store_id
WHERE s.order_date >= CURDATE() - INTERVAL 12 MONTH
GROUP BY st.store_id, st.store_name
ORDER BY total_profit DESC
LIMIT 1;

-- 5. What is the return rate by product category?
SELECT 
    p.category,
    COUNT(DISTINCT r.order_id) AS returns_count,
    COUNT(DISTINCT s.order_id) AS sales_count,
    ROUND((COUNT(DISTINCT r.order_id) / COUNT(DISTINCT s.order_id)) * 100, 2) AS return_rate_pct
FROM sales s
JOIN products p ON s.product_id = p.product_id
LEFT JOIN returns r ON s.order_id = r.order_id
GROUP BY p.category;

-- 6. What is the average revenue per customer by age group?
SELECT 
    c.age_group,
    ROUND(SUM(s.total_amount) / COUNT(DISTINCT c.customer_id), 2) AS avg_revenue_per_customer
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.age_group;

-- 7. Which sales channel (Online vs In-Store) is more profitable on average?
SELECT 
    sales_channel,
    ROUND(SUM(p.profit_per_unit * s.quantity), 2) AS total_profit,
    ROUND(SUM(p.profit_per_unit * s.quantity) / COUNT(DISTINCT s.order_id), 2) AS avg_profit_per_order
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY sales_channel
ORDER BY total_profit DESC;

-- 8. How has monthly profit changed over the last 2 years by region?
SELECT 
    DATE_FORMAT(s.order_date, '%Y-%m') AS month,
    st.region,
    ROUND(SUM(p.profit_per_unit * s.quantity), 2) AS monthly_profit
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN stores st ON s.store_id = st.store_id
WHERE s.order_date >= CURDATE() - INTERVAL 24 MONTH
GROUP BY month, st.region
ORDER BY month, st.region;

-- 9. Identify the top 3 products with the highest return rate in each category
WITH total_sales AS (
    SELECT product_id, COUNT(*) AS total_orders
    FROM sales
    GROUP BY product_id
),
total_returns AS (
    SELECT s.product_id, COUNT(*) AS total_returns
    FROM returns r
    JOIN sales s ON r.order_id = s.order_id
    GROUP BY s.product_id
),
return_rates AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        COALESCE(r.total_returns, 0) AS returns_count,
        ts.total_orders,
        ROUND(COALESCE(r.total_returns, 0) / ts.total_orders * 100, 2) AS return_rate_pct
    FROM total_sales ts
    JOIN products p ON ts.product_id = p.product_id
    LEFT JOIN total_returns r ON ts.product_id = r.product_id
)
SELECT category, product_id, product_name, return_rate_pct
FROM (
    SELECT 
        category, product_id, product_name, return_rate_pct,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY return_rate_pct DESC) AS rank_in_category
    FROM return_rates
) AS ranked
WHERE rank_in_category <= 3
ORDER BY category, return_rate_pct DESC;

-- 10. Which 5 customers have contributed the most to total profit, and what is their tenure with the company?
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(p.profit_per_unit * s.quantity), 2) AS total_profit,
    TIMESTAMPDIFF(MONTH, c.signup_date, CURDATE()) AS tenure_in_months
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id
GROUP BY c.customer_id, customer_name, c.signup_date
ORDER BY total_profit DESC
LIMIT 5;

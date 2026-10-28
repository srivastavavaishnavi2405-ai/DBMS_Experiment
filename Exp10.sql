-- CREATE TABLE
DROP TABLE IF EXISTS Sales;
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    CustomerID INT,
    CustomerName VARCHAR(100),
    ProductID INT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    City VARCHAR(50),
    Quantity INT,
    Price DECIMAL(10,2),
    SaleDate DATE,
    Status VARCHAR(30)
) ENGINE = InnoDB;
-- GENERATE 10,000 RECORDS
SET SESSION cte_max_recursion_depth = 10000;
INSERT INTO Sales (
    SaleID,
    CustomerID,
    CustomerName,
    ProductID,
    ProductName,
    Category,
    City,
    Quantity,
    Price,
    SaleDate,
    Status
)
WITH RECURSIVE Numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM Numbers
    WHERE n < 10000
)
SELECT
    n,
    MOD(n, 1000) + 1,
    CONCAT('Customer_', MOD(n, 1000) + 1),
    MOD(n, 100) + 1,
    CONCAT('Product_', MOD(n, 100) + 1),
    CASE MOD(n, 4)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Clothing'
        WHEN 2 THEN 'Furniture'
        ELSE 'Books'
    END,
    CASE MOD(n, 5)
        WHEN 0 THEN 'Delhi'
        WHEN 1 THEN 'Mumbai'
        WHEN 2 THEN 'Kanpur'
        WHEN 3 THEN 'Lucknow'
        ELSE 'Bhopal'
    END,
    MOD(n, 10) + 1,
    100 + MOD(n, 5000),
    DATE_ADD('2024-01-01', INTERVAL MOD(n, 730) DAY),
    CASE MOD(n, 3)
        WHEN 0 THEN 'Completed'
        WHEN 1 THEN 'Pending'
        ELSE 'Cancelled'
    END
FROM Numbers;
-- VERIFY DATASET
SELECT COUNT(*) AS TotalRecords
FROM Sales;
SELECT *
FROM Sales
LIMIT 10;

-- FIVE SLOW QUERIES BEFORE OPTIMIZATION
-- SLOW QUERY 1: SEARCH BY CUSTOMER NAME
EXPLAIN
SELECT *
FROM Sales
WHERE CustomerName = 'Customer_101';
SELECT *
FROM Sales
WHERE CustomerName = 'Customer_101';

-- SLOW QUERY 2: SEARCH BY CITY AND STATUS
EXPLAIN
SELECT *
FROM Sales
WHERE City = 'Delhi'
  AND Status = 'Completed';
SELECT *
FROM Sales
WHERE City = 'Delhi'
  AND Status = 'Completed';

-- SLOW QUERY 3: SEARCH USING DATE FUNCTION
EXPLAIN
SELECT *
FROM Sales
WHERE YEAR(SaleDate) = 2025;
SELECT *
FROM Sales
WHERE YEAR(SaleDate) = 2025;

-- SLOW QUERY 4: SEARCH USING PRICE CALCULATION
EXPLAIN
SELECT *
FROM Sales
WHERE Quantity * Price > 10000;
SELECT *
FROM Sales
WHERE Quantity * Price > 10000;

-- SLOW QUERY 5: SEARCH BY CATEGORY AND DATE
EXPLAIN
SELECT *
FROM Sales
WHERE Category = 'Electronics'
  AND SaleDate BETWEEN '2025-01-01' AND '2025-12-31';
SELECT *
FROM Sales
WHERE Category = 'Electronics'
  AND SaleDate BETWEEN '2025-01-01' AND '2025-12-31';

-- OPTIMIZE QUERY 1 USING A SINGLE-COLUMN INDEX
CREATE INDEX idx_customer_name
ON Sales(CustomerName);
EXPLAIN
SELECT *
FROM Sales
WHERE CustomerName = 'Customer_101';
SELECT *
FROM Sales
WHERE CustomerName = 'Customer_101';

-- OPTIMIZE QUERY 2 USING A COMPOSITE INDEX
CREATE INDEX idx_city_status
ON Sales(City, Status);
EXPLAIN
SELECT *
FROM Sales
WHERE City = 'Delhi'
  AND Status = 'Completed';
SELECT *
FROM Sales
WHERE City = 'Delhi'
  AND Status = 'Completed';

-- OPTIMIZE QUERY 3 BY REWRITING THE DATE CONDITION
-- Original query uses YEAR(SaleDate), which applies a
-- function to the column.
-- Optimized query uses a date range.
EXPLAIN
SELECT *
FROM Sales
WHERE SaleDate >= '2025-01-01'
  AND SaleDate < '2026-01-01';
SELECT *
FROM Sales
WHERE SaleDate >= '2025-01-01'
  AND SaleDate < '2026-01-01';

-- Create an index on SaleDate
CREATE INDEX idx_sale_date
ON Sales(SaleDate);
EXPLAIN
SELECT *
FROM Sales
WHERE SaleDate >= '2025-01-01'
  AND SaleDate < '2026-01-01';

-- OPTIMIZE QUERY 4 USING A GENERATED COLUMN
-- Create a generated column for total sale value.
ALTER TABLE Sales
ADD COLUMN TotalAmount DECIMAL(15,2)
GENERATED ALWAYS AS (Quantity * Price) STORED;
-- Create an index on the generated column.
CREATE INDEX idx_total_amount
ON Sales(TotalAmount);
EXPLAIN
SELECT *
FROM Sales
WHERE TotalAmount > 10000;
SELECT *
FROM Sales
WHERE TotalAmount > 10000;

-- OPTIMIZE QUERY 5 USING A COMPOSITE INDEX

CREATE INDEX idx_category_date
ON Sales(Category, SaleDate);
EXPLAIN
SELECT *
FROM Sales
WHERE Category = 'Electronics'
  AND SaleDate >= '2025-01-01'
  AND SaleDate < '2026-01-01';
SELECT *
FROM Sales
WHERE Category = 'Electronics'
  AND SaleDate >= '2025-01-01'
  AND SaleDate < '2026-01-01';

-- UPDATE TABLE STATISTICS

ANALYZE TABLE Sales;

-- CHECK ALL INDEXES
SHOW INDEX FROM Sales;

-- COMPARE EXECUTION PLANS AFTER OPTIMIZATION
-- Query 1
EXPLAIN
SELECT *
FROM Sales
WHERE CustomerName = 'Customer_101';

-- Query 2
EXPLAIN
SELECT *
FROM Sales
WHERE City = 'Delhi'
  AND Status = 'Completed';

-- Query 3
EXPLAIN
SELECT *
FROM Sales
WHERE SaleDate >= '2025-01-01'
  AND SaleDate < '2026-01-01';

-- Query 4
EXPLAIN
SELECT *
FROM Sales
WHERE TotalAmount > 10000;

-- Query 5
EXPLAIN
SELECT *
FROM Sales
WHERE Category = 'Electronics'
  AND SaleDate >= '2025-01-01'
  AND SaleDate < '2026-01-01';


-- MEASURE ACTUAL EXECUTION TIME

-- Query 1
EXPLAIN ANALYZE
SELECT *
FROM Sales
WHERE CustomerName = 'Customer_101';

-- Query 2
EXPLAIN ANALYZE
SELECT *
FROM Sales
WHERE City = 'Delhi'
  AND Status = 'Completed';

-- Query 3
EXPLAIN ANALYZE
SELECT *
FROM Sales
WHERE SaleDate >= '2025-01-01'
  AND SaleDate < '2026-01-01';

-- Query 4
EXPLAIN ANALYZE
SELECT *
FROM Sales
WHERE TotalAmount > 10000;

-- Query 5
EXPLAIN ANALYZE
SELECT *
FROM Sales
WHERE Category = 'Electronics'
  AND SaleDate >= '2025-01-01'
  AND SaleDate < '2026-01-01';

-- FINAL SUMMARY
SELECT COUNT(*) AS TotalRecords
FROM Sales;
SELECT
    Category,
    COUNT(*) AS TotalSales,
    SUM(TotalAmount) AS Revenue
FROM Sales
GROUP BY Category;
SELECT
    City,
    COUNT(*) AS TotalRecords
FROM Sales
GROUP BY City;

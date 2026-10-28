CREATE TABLE Sales_UNF (
    OrderID INT,
    OrderDate DATE,
    CustomerID INT,
    CustomerName VARCHAR(100),
    CustomerCity VARCHAR(100),
    ProductID INT,
    ProductName VARCHAR(100),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    SalespersonID INT,
    SalespersonName VARCHAR(100)
);

INSERT INTO Sales_UNF VALUES
(101, '2026-01-10', 1, 'Rahul Sharma', 'Delhi', 201, 'Laptop', 1, 55000.00, 11, 'Amit'),
(101, '2026-01-10', 1, 'Rahul Sharma', 'Delhi', 202, 'Mouse', 2, 500.00, 11, 'Amit'),
(102, '2026-01-11', 2, 'Priya Verma', 'Mumbai', 203, 'Keyboard', 1, 1200.00, 12, 'Neha'),
(102, '2026-01-11', 2, 'Priya Verma', 'Mumbai', 201, 'Laptop', 1, 55000.00, 12, 'Neha'),
(103, '2026-01-12', 3, 'Aman Singh', 'Kanpur', 202, 'Mouse', 3, 500.00, 11, 'Amit');

SELECT * FROM Sales_UNF;

-- FUNCTIONAL DEPENDENCIES
-- OrderID -> OrderDate, CustomerID, SalespersonID
-- CustomerID -> CustomerName, CustomerCity
-- ProductID -> ProductName, UnitPrice
-- SalespersonID -> SalespersonName
-- (OrderID, ProductID) -> Quantity
-- Candidate Key: (OrderID, ProductID)


-- CREATE 1NF TABLE

CREATE TABLE Sales_1NF (
    OrderID INT,
    OrderDate DATE,
    CustomerID INT,
    CustomerName VARCHAR(100),
    CustomerCity VARCHAR(100),
    ProductID INT,
    ProductName VARCHAR(100),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    SalespersonID INT,
    SalespersonName VARCHAR(100),
    PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO Sales_1NF
SELECT * FROM Sales_UNF;

SELECT * FROM Sales_1NF;


-- CONVERT 1NF TO 2NF

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID INT,
    CustomerName VARCHAR(100),
    CustomerCity VARCHAR(100),
    SalespersonID INT,
    SalespersonName VARCHAR(100)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    UnitPrice DECIMAL(10,2)
);

CREATE TABLE OrderDetails (
    OrderID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

INSERT INTO Orders
SELECT DISTINCT OrderID, OrderDate, CustomerID,
       CustomerName, CustomerCity,
       SalespersonID, SalespersonName
FROM Sales_1NF;

INSERT INTO Products
SELECT DISTINCT ProductID, ProductName, UnitPrice
FROM Sales_1NF;

INSERT INTO OrderDetails
SELECT OrderID, ProductID, Quantity
FROM Sales_1NF;

SELECT * FROM Orders;
SELECT * FROM Products;
SELECT * FROM OrderDetails;

--  CONVERT 2NF TO 3NF
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    CustomerCity VARCHAR(100)
);

CREATE TABLE Salespersons (
    SalespersonID INT PRIMARY KEY,
    SalespersonName VARCHAR(100)
);

CREATE TABLE Orders_3NF (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID INT,
    SalespersonID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (SalespersonID) REFERENCES Salespersons(SalespersonID)
);

INSERT INTO Customers
SELECT DISTINCT CustomerID, CustomerName, CustomerCity
FROM Sales_1NF;

INSERT INTO Salespersons
SELECT DISTINCT SalespersonID, SalespersonName
FROM Sales_1NF;

INSERT INTO Orders_3NF
SELECT DISTINCT OrderID, OrderDate, CustomerID, SalespersonID
FROM Sales_1NF;

SELECT * FROM Customers;
SELECT * FROM Salespersons;
SELECT * FROM Orders_3NF;
SELECT * FROM Products;
SELECT * FROM OrderDetails;

-- BCNF VERIFICATION
-- Each determinant in the decomposed tables is a candidate key.
-- Therefore, the resulting tables satisfy BCNF under the
-- assumed functional dependencies.

DESCRIBE Customers;
DESCRIBE Salespersons;
DESCRIBE Orders_3NF;
DESCRIBE Products;
DESCRIBE OrderDetails;

-- VERIFY LOSSLESS JOIN
SELECT
    O.OrderID,
    O.OrderDate,
    C.CustomerID,
    C.CustomerName,
    C.CustomerCity,
    P.ProductID,
    P.ProductName,
    OD.Quantity,
    P.UnitPrice,
    S.SalespersonID,
    S.SalespersonName
FROM Orders_3NF O
JOIN Customers C
    ON O.CustomerID = C.CustomerID
JOIN Salespersons S
    ON O.SalespersonID = S.SalespersonID
JOIN OrderDetails OD
    ON O.OrderID = OD.OrderID
JOIN Products P
    ON OD.ProductID = P.ProductID
ORDER BY O.OrderID, P.ProductID;


-- COMPARE ORIGINAL AND RECONSTRUCTED ROW COUNTS

SELECT
    (SELECT COUNT(*) FROM Sales_1NF) AS OriginalRows,
    (
        SELECT COUNT(*)
        FROM Orders_3NF O
        JOIN Customers C
            ON O.CustomerID = C.CustomerID
        JOIN Salespersons S
            ON O.SalespersonID = S.SalespersonID
        JOIN OrderDetails OD
            ON O.OrderID = OD.OrderID
        JOIN Products P
            ON OD.ProductID = P.ProductID
    ) AS ReconstructedRows;

-- Check Customer Functional Dependency

SELECT CustomerID
FROM Sales_1NF
GROUP BY CustomerID
HAVING COUNT(DISTINCT CustomerName) > 1
    OR COUNT(DISTINCT CustomerCity) > 1;

-- Check Product Functional Dependency

SELECT ProductID
FROM Sales_1NF
GROUP BY ProductID
HAVING COUNT(DISTINCT ProductName) > 1
    OR COUNT(DISTINCT UnitPrice) > 1;

-- Check Salesperson Functional Dependency

SELECT SalespersonID
FROM Sales_1NF
GROUP BY SalespersonID
HAVING COUNT(DISTINCT SalespersonName) > 1;

-- Check Order Functional Dependency

SELECT OrderID
FROM Sales_1NF
GROUP BY OrderID
HAVING COUNT(DISTINCT OrderDate) > 1
    OR COUNT(DISTINCT CustomerID) > 1
    OR COUNT(DISTINCT SalespersonID) > 1;


-- FINAL NORMALIZED SALES REPORT

SELECT
    O.OrderID,
    O.OrderDate,
    C.CustomerID,
    C.CustomerName,
    C.CustomerCity,
    P.ProductID,
    P.ProductName,
    OD.Quantity,
    P.UnitPrice,
    (OD.Quantity * P.UnitPrice) AS TotalAmount,
    S.SalespersonID,
    S.SalespersonName
FROM Orders_3NF O
JOIN Customers C
    ON O.CustomerID = C.CustomerID
JOIN Salespersons S
    ON O.SalespersonID = S.SalespersonID
JOIN OrderDetails OD
    ON O.OrderID = OD.OrderID
JOIN Products P
    ON OD.ProductID = P.ProductID
ORDER BY O.OrderID, P.ProductID;


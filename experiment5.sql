-- Experiment 5: Views, view updatability, and recursive CTE reporting chains
-- MySQL 8. This file is self-contained and creates dbms_exp5.

CREATE DATABASE IF NOT EXISTS dbms_exp5;
USE dbms_exp5;

CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(80) NOT NULL,
    DeptID INT NOT NULL,
    ManagerID INT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID),
    FOREIGN KEY (ManagerID) REFERENCES Employee(EmpID)
);

INSERT INTO Department VALUES (1,'IT'),(2,'HR'),(3,'Finance');
INSERT INTO Employee (EmpID,EmpName,DeptID,ManagerID,Salary) VALUES
(1,'Aarav Sharma',1,NULL,105000),
(2,'Diya Patel',1,1,72000),(3,'Kabir Singh',1,1,68000),
(4,'Anaya Gupta',1,2,61000),
(5,'Meera Joshi',2,NULL,90000),(6,'Vivaan Rao',2,5,62000),
(7,'Saanvi Mehta',2,5,58000),
(8,'Arjun Nair',3,NULL,99000),(9,'Myra Shah',3,8,76000);

CREATE OR REPLACE VIEW DepartmentSalarySummary AS
SELECT D.DeptID, D.DeptName,
       COUNT(E.EmpID) AS TotalEmployees,
       SUM(E.Salary) AS TotalSalary,
       AVG(E.Salary) AS AverageSalary
FROM Department D
LEFT JOIN Employee E ON E.DeptID = D.DeptID
GROUP BY D.DeptID, D.DeptName;

SELECT * FROM DepartmentSalarySummary;

CREATE OR REPLACE VIEW EmployeeHierarchy AS
SELECT E.EmpID, E.EmpName AS Employee, E.DeptID,
       E.ManagerID, M.EmpName AS Manager
FROM Employee E
LEFT JOIN Employee M ON E.ManagerID = M.EmpID;

SELECT * FROM EmployeeHierarchy ORDER BY DeptID, ManagerID, EmpID;

-- These are intentionally commented: aggregate/grouped and self-join views
-- are not directly updatable in MySQL, so running them would raise an error.
-- UPDATE DepartmentSalarySummary SET TotalSalary = 500000 WHERE DeptName = 'IT';
-- UPDATE EmployeeHierarchy SET Employee = 'Aarav Sharma' WHERE EmpID = 2;

-- Recursive CTE: start at top-level employees (ManagerID IS NULL), then descend.
WITH RECURSIVE ReportingChain AS (
    SELECT EmpID, EmpName, DeptID, ManagerID,
           0 AS LevelNo,
           CAST(EmpName AS CHAR(1000)) AS ReportingPath
    FROM Employee
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT E.EmpID, E.EmpName, E.DeptID, E.ManagerID,
           R.LevelNo + 1,
           CONCAT(R.ReportingPath, ' -> ', E.EmpName)
    FROM Employee E
    JOIN ReportingChain R ON E.ManagerID = R.EmpID
)
SELECT DeptID, EmpID, LevelNo, ReportingPath
FROM ReportingChain
ORDER BY DeptID, LevelNo, EmpID;

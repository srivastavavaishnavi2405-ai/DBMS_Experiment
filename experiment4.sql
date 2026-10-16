-- Experiment 4: Joins, subqueries, set-operation patterns, and EXPLAIN
-- MySQL 8. This file is self-contained and creates dbms_exp4.

CREATE DATABASE IF NOT EXISTS dbms_exp4;
USE dbms_exp4;

CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE Project (
    ProjectID INT PRIMARY KEY,
    ProjectName VARCHAR(80) NOT NULL UNIQUE,
    Budget DECIMAL(12,2) NOT NULL
);
CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(80) NOT NULL,
    DeptID INT NOT NULL,
    ProjectID INT,
    Salary DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID),
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);

INSERT INTO Department VALUES (1,'IT'),(2,'HR'),(3,'Finance'),(4,'Sales');
INSERT INTO Project VALUES
(101,'Cloud Migration',900000),(102,'Payroll Upgrade',450000),
(103,'Customer Portal',750000),(104,'Data Warehouse',1200000);
INSERT INTO Employee VALUES
(1,'Aarav Sharma',1,101,72000),(2,'Diya Patel',1,104,68000),
(3,'Kabir Singh',1,103,85000),(4,'Anaya Gupta',1,101,59000),
(5,'Ishaan Verma',2,102,91000),(6,'Meera Joshi',2,103,64000),
(7,'Vivaan Rao',2,102,58000),(8,'Saanvi Mehta',3,104,62000),
(9,'Arjun Nair',3,103,74000),(10,'Myra Shah',3,101,55000),
(11,'Reyansh Das',4,104,81000),(12,'Aditi Kumar',4,102,66000);

-- 1. INNER JOIN
SELECT E.EmpName, D.DeptName
FROM Employee E INNER JOIN Department D ON E.DeptID = D.DeptID;

-- 2. LEFT JOIN (also displays departments with no employees)
SELECT D.DeptName, E.EmpName
FROM Department D LEFT JOIN Employee E ON E.DeptID = D.DeptID;

-- 3. SELF JOIN: employee pairs in the same department
SELECT E1.EmpName AS Employee1, E2.EmpName AS Employee2, E1.DeptID
FROM Employee E1 JOIN Employee E2
  ON E1.DeptID = E2.DeptID AND E1.EmpID < E2.EmpID;

-- 4. Three-way join
SELECT E.EmpName, D.DeptName, P.ProjectName
FROM Employee E
JOIN Department D ON E.DeptID = D.DeptID
JOIN Project P ON E.ProjectID = P.ProjectID;

-- 5. Correlated subquery: salary above the employee's department average
SELECT E.EmpName, E.Salary, E.DeptID
FROM Employee E
WHERE E.Salary > (
    SELECT AVG(E2.Salary) FROM Employee E2 WHERE E2.DeptID = E.DeptID
);

-- 6. EXISTS
SELECT D.DeptName
FROM Department D
WHERE EXISTS (SELECT 1 FROM Employee E WHERE E.DeptID = D.DeptID);

-- 7. Simulated INTERSECT: employees over 60,000 on projects over 700,000
SELECT E.EmpName
FROM Employee E
WHERE E.Salary > 60000
  AND EXISTS (SELECT 1 FROM Project P
              WHERE P.ProjectID = E.ProjectID AND P.Budget > 700000);

-- 8. Simulated EXCEPT: employees not assigned to Cloud Migration
SELECT E.EmpName
FROM Employee E
WHERE NOT EXISTS (
    SELECT 1 FROM Project P
    WHERE P.ProjectID = E.ProjectID AND P.ProjectName = 'Cloud Migration'
);

-- 9. Compare plans for a join and correlated subquery
EXPLAIN SELECT E.EmpName, D.DeptName
FROM Employee E JOIN Department D ON E.DeptID = D.DeptID;

EXPLAIN SELECT E.EmpName, E.Salary
FROM Employee E
WHERE E.Salary > (
    SELECT AVG(E2.Salary) FROM Employee E2 WHERE E2.DeptID = E.DeptID
);

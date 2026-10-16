-- Experiment 3: Employee-Department-Project schema and basic SQL queries
-- MySQL 8. Run this file independently; it creates dbms_exp3.

CREATE DATABASE IF NOT EXISTS dbms_exp3;
USE dbms_exp3;

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
    CONSTRAINT fk_exp3_employee_department FOREIGN KEY (DeptID) REFERENCES Department(DeptID),
    CONSTRAINT fk_exp3_employee_project FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);

INSERT INTO Department (DeptID, DeptName) VALUES
(1,'IT'),(2,'HR'),(3,'Finance'),(4,'Sales'),(5,'Research');

INSERT INTO Project (ProjectID, ProjectName, Budget) VALUES
(101,'Cloud Migration',900000),(102,'Payroll Upgrade',450000),
(103,'Customer Portal',700000),(104,'Data Warehouse',1200000);

INSERT INTO Employee (EmpID, EmpName, DeptID, ProjectID, Salary) VALUES
(1,'Aarav Sharma',1,101,72000),(2,'Diya Patel',1,104,68000),
(3,'Kabir Singh',1,103,85000),(4,'Anaya Gupta',1,101,59000),
(5,'Ishaan Verma',1,104,91000),(6,'Meera Joshi',1,102,64000),
(7,'Vivaan Rao',2,102,58000),(8,'Saanvi Mehta',2,103,62000),
(9,'Arjun Nair',2,102,74000),(10,'Myra Shah',2,103,55000),
(11,'Reyansh Das',2,101,81000),(12,'Aditi Kumar',2,102,66000),
(13,'Krishna Iyer',3,102,57000),(14,'Pari Reddy',3,103,61000),
(15,'Advik Bose',3,104,88000),(16,'Kiara Jain',3,102,63000),
(17,'Rudra Sen',3,103,59000),(18,'Tara Kapoor',3,104,55000),
(19,'Yash Malhotra',4,103,60000),(20,'Ira Chawla',4,101,76000),
(21,'Atharv Pillai',4,103,99000),(22,'Navya Sinha',4,101,71000),
(23,'Dhruv Bhat',4,103,64000),(24,'Zara Khan',4,101,79000),
(25,'Om Prakash',5,104,67000),(26,'Siya Thomas',5,104,92000),
(27,'Veer Kulkarni',5,101,74000),(28,'Riya Banerjee',5,104,108000),
(29,'Neil Fernandes',5,103,69000),(30,'Avni Mishra',5,104,95000);

-- 1. Selection
SELECT * FROM Employee WHERE Salary > 60000;

-- 2. Projection
SELECT EmpName, Salary FROM Employee;

-- 3. Aggregate functions
SELECT COUNT(*) AS TotalEmployees,
       AVG(Salary) AS AvgSalary,
       MAX(Salary) AS MaxSalary
FROM Employee;

-- 4. GROUP BY
SELECT DeptID, COUNT(*) AS TotalEmployees
FROM Employee
GROUP BY DeptID;

-- 5. HAVING
SELECT DeptID, AVG(Salary) AS AvgSalary
FROM Employee
GROUP BY DeptID
HAVING AVG(Salary) > 55000;

-- 6. CASE salary band
SELECT EmpName, Salary,
       CASE WHEN Salary >= 70000 THEN 'High'
            WHEN Salary >= 60000 THEN 'Medium'
            ELSE 'Low' END AS SalaryLevel
FROM Employee;

-- 7. ORDER BY
SELECT EmpName, Salary
FROM Employee
ORDER BY Salary DESC;

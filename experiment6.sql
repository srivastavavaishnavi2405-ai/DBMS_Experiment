-- Experiment 6: Stored procedure validation, salary triggers, and audit log
-- MySQL 8. This file is self-contained and creates dbms_exp6.

CREATE DATABASE IF NOT EXISTS dbms_exp6;
USE dbms_exp6;

CREATE TABLE Department (
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL UNIQUE
);
CREATE TABLE Employee (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(80) NOT NULL,
    DeptID INT NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);
CREATE TABLE SalaryAudit (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    EmpID INT NOT NULL,
    OldSalary DECIMAL(10,2) NOT NULL,
    NewSalary DECIMAL(10,2) NOT NULL,
    ChangedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ChangedBy VARCHAR(100) NOT NULL DEFAULT 'experiment6',
    FOREIGN KEY (EmpID) REFERENCES Employee(EmpID)
);

INSERT INTO Department VALUES (1,'IT'),(2,'HR'),(3,'Finance');
INSERT INTO Employee VALUES
(1,'Aarav Sharma',1,55000),(2,'Diya Patel',1,72000),
(3,'Kabir Singh',2,61000),(4,'Anaya Gupta',3,68000);

DROP PROCEDURE IF EXISTS transfer_employee;
DROP TRIGGER IF EXISTS validate_employee_salary;
DROP TRIGGER IF EXISTS audit_employee_salary;

DELIMITER //
CREATE PROCEDURE transfer_employee(IN p_emp_id INT, IN p_new_dept_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Employee WHERE EmpID = p_emp_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee does not exist';
    ELSEIF NOT EXISTS (SELECT 1 FROM Department WHERE DeptID = p_new_dept_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Department does not exist';
    ELSE
        UPDATE Employee SET DeptID = p_new_dept_id WHERE EmpID = p_emp_id;
        SELECT 'Transfer completed' AS Status,
               p_emp_id AS EmpID, p_new_dept_id AS NewDeptID;
    END IF;
END//

CREATE TRIGGER validate_employee_salary
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.Salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Salary must be greater than zero';
    END IF;
END//

CREATE TRIGGER audit_employee_salary
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF OLD.Salary <> NEW.Salary THEN
        INSERT INTO SalaryAudit (EmpID, OldSalary, NewSalary, ChangedBy)
        VALUES (OLD.EmpID, OLD.Salary, NEW.Salary, CURRENT_USER());
    END IF;
END//
DELIMITER ;

-- Valid transfer
CALL transfer_employee(1, 2);
SELECT EmpID, EmpName, DeptID FROM Employee WHERE EmpID = 1;

-- Valid salary update; the AFTER trigger records it in SalaryAudit.
UPDATE Employee SET Salary = 60000 WHERE EmpID = 1;
SELECT * FROM SalaryAudit ORDER BY AuditID;

-- Edge-case calls below are commented because SIGNAL intentionally stops the
-- current statement with an error. Uncomment one at a time to observe it.
-- CALL transfer_employee(999, 2); -- invalid employee
-- CALL transfer_employee(1, 999); -- invalid department
-- CALL transfer_employee(1, 2);   -- same department (valid no-op update)
-- UPDATE Employee SET Salary = 0 WHERE EmpID = 1;     -- rejected
-- UPDATE Employee SET Salary = -5000 WHERE EmpID = 1; -- rejected

SELECT EmpID, EmpName, Salary FROM Employee ORDER BY EmpID;
SELECT AuditID, EmpID, OldSalary, NewSalary, ChangedAt, ChangedBy
FROM SalaryAudit ORDER BY AuditID;

CREATE TABLE IF NOT EXISTS BankAccounts (
    AccountID INT PRIMARY KEY,
    AccountHolder VARCHAR(50),
    Balance DECIMAL(10,2) NOT NULL
) ENGINE = InnoDB;

INSERT INTO BankAccounts VALUES
(101, 'Rahul', 10000.00),
(102, 'Priya', 8000.00),
(103, 'Aman', 5000.00)
ON DUPLICATE KEY UPDATE
    AccountHolder = VALUES(AccountHolder);

SELECT * FROM BankAccounts;

-- TRANSFER MONEY FROM ACCOUNT 101 TO ACCOUNT 102

START TRANSACTION;

UPDATE BankAccounts
SET Balance = Balance - 2000
WHERE AccountID = 101;

UPDATE BankAccounts
SET Balance = Balance + 2000
WHERE AccountID = 102;

SELECT * FROM BankAccounts;

COMMIT;

SELECT * FROM BankAccounts;

-- SIMULATE A FAILED TRANSACTION

START TRANSACTION;

UPDATE BankAccounts
SET Balance = Balance - 1000
WHERE AccountID = 101;

UPDATE BankAccounts
SET Balance = Balance + 1000
WHERE AccountID = 102;

-- Cancel the transaction
ROLLBACK;

-- Balances return to their values before this transaction
SELECT * FROM BankAccounts;

-- SAVEPOINT AND PARTIAL ROLLBACK

START TRANSACTION;

UPDATE BankAccounts
SET Balance = Balance - 500
WHERE AccountID = 101;

SAVEPOINT TransferStep1;

UPDATE BankAccounts
SET Balance = Balance + 500
WHERE AccountID = 102;

-- Undo only the changes made after the savepoint
ROLLBACK TO SAVEPOINT TransferStep1;

-- Release the savepoint
RELEASE SAVEPOINT TransferStep1;

-- Commit the remaining transaction changes
COMMIT;

SELECT * FROM BankAccounts;



-- SIMULATE PARTIAL FAILURE

START TRANSACTION;

UPDATE BankAccounts
SET Balance = Balance - 1000
WHERE AccountID = 101;

SAVEPOINT BeforeSecondUpdate;

-- Simulate a failed operation by undoing changes
-- made after the savepoint
UPDATE BankAccounts
SET Balance = Balance + 1000
WHERE AccountID = 999;

ROLLBACK TO SAVEPOINT BeforeSecondUpdate;

-- Undo the entire transaction because the transfer failed
ROLLBACK;

SELECT * FROM BankAccounts;

-- SET ISOLATION LEVEL

SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

START TRANSACTION;
SELECT * FROM BankAccounts;
COMMIT;


SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;
SELECT * FROM BankAccounts;
COMMIT;


SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

START TRANSACTION;
SELECT * FROM BankAccounts;
COMMIT;


SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;
SELECT * FROM BankAccounts;
COMMIT;

-- CHECK CURRENT ISOLATION LEVEL

SELECT @@transaction_isolation;

-- CREATE TABLE FOR CONCURRENCY DEMONSTRATION


CREATE TABLE IF NOT EXISTS ConcurrencyDemo (
    ID INT PRIMARY KEY,
    AccountHolder VARCHAR(50),
    Balance DECIMAL(10,2)
) ENGINE = InnoDB;

INSERT INTO ConcurrencyDemo VALUES
(1, 'Riya', 10000.00),
(2, 'Aarav', 7000.00)
ON DUPLICATE KEY UPDATE
    AccountHolder = VALUES(AccountHolder);

SELECT * FROM ConcurrencyDemo;

-- DIRTY READ DEMONSTRATION
-- SESSION 1:
START TRANSACTION;
UPDATE ConcurrencyDemo
SET Balance = 15000
WHERE ID = 1;

-- Do not commit yet.
-- Switch to SESSION 2.

-- SESSION 2:
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

START TRANSACTION;

SELECT * FROM ConcurrencyDemo
WHERE ID = 1;

-- Session 2 may see the uncommitted balance of 15000.
COMMIT;

-- SESSION 1:
ROLLBACK;

-- The balance returns to 10000.
SELECT * FROM ConcurrencyDemo;

-- NON-REPEATABLE READ DEMONSTRATION
-- USE TWO MYSQL WORKBENCH SESSIONS

-- SESSION 1:
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT Balance
FROM ConcurrencyDemo
WHERE ID = 1;

-- Switch to SESSION 2.
-- SESSION 2:
START TRANSACTION;

UPDATE ConcurrencyDemo
SET Balance = 12000
WHERE ID = 1;

COMMIT;

-- SESSION 1:
-- The second read may return 12000 instead of 10000.
SELECT Balance
FROM ConcurrencyDemo
WHERE ID = 1;

COMMIT;

-- REPEATABLE READ DEMONSTRATION
-- USE TWO MYSQL WORKBENCH SESSIONS

-- SESSION 1:
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT Balance
FROM ConcurrencyDemo
WHERE ID = 1;

-- Switch to SESSION 2.

-- SESSION 2:
START TRANSACTION;

UPDATE ConcurrencyDemo
SET Balance = 14000
WHERE ID = 1;
COMMIT;

-- SESSION 1:
-- A consistent read normally continues to show the
-- original value of 12000 within this transaction.
SELECT Balance
FROM ConcurrencyDemo
WHERE ID = 1;

COMMIT;

-- LOST UPDATE DEMONSTRATION
-- USE TWO MYSQL WORKBENCH SESSIONS
-- SESSION 1:
START TRANSACTION;
SELECT Balance
FROM ConcurrencyDemo
WHERE ID = 2;

-- Suppose Session 1 calculates a new balance of 8000.
-- Switch to Session 2.
-- SESSION 2:
START TRANSACTION;
SELECT Balance
FROM ConcurrencyDemo
WHERE ID = 2;

-- Suppose Session 2 calculates a new balance of 9000.
UPDATE ConcurrencyDemo
SET Balance = 9000
WHERE ID = 2;
COMMIT;

-- SESSION 1:
-- This stale update overwrites Session 2's result.
UPDATE ConcurrencyDemo
SET Balance = 8000
WHERE ID = 2;
COMMIT;
-- Final balance is 8000, so Session 2's update is lost.
SELECT * FROM ConcurrencyDemo;

/* FINAL BANK ACCOUNT REPORT */

SELECT
    AccountID,
    AccountHolder,
    Balance
FROM BankAccounts
ORDER BY AccountID;

SELECT
    ID,
    AccountHolder,
    Balance
FROM ConcurrencyDemo
ORDER BY ID;


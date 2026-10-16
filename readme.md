# DBMS Experiments

This repository contains six database management lab experiments. The PDFs preserve the lab records, and `sql/` contains standalone MySQL 8 scripts for Experiments 3–6. Experiments 1 and 2 are scanned handwritten pages; Experiments 3–6 are digitally prepared PDFs with matching runnable scripts.

## Files

| File | Experiment | Main topic |
|---|---:|---|
| [`Experiment 1.pdf`](Experiment%201.pdf) | 1 | E-commerce ER diagram |
| [`Experiment 2.pdf`](Experiment%202.pdf) | 2 | Relational schema and MySQL implementation |
| [`Experiment 3.pdf`](Experiment%203.pdf) | 3 | Employee/department/project schema and basic SQL queries |
| [`Experiment 4.pdf`](Experiment%204.pdf) | 4 | Joins, subqueries, set-operation patterns, and `EXPLAIN` |
| [`Experiment 5.pdf`](Experiment%205.pdf) | 5 | Views, view updatability, and recursive CTEs |
| [`Experiment 6.pdf`](Experiment%206.pdf) | 6 | Stored procedure validation, triggers, and audit logging |
| [`sql/experiment3.sql`](sql/experiment3.sql) | 3 | Runnable SQL source for Experiment 3 |
| [`sql/experiment4.sql`](sql/experiment4.sql) | 4 | Runnable SQL source for Experiment 4 |
| [`sql/experiment5.sql`](sql/experiment5.sql) | 5 | Runnable SQL source for Experiment 5 |
| [`sql/experiment6.sql`](sql/experiment6.sql) | 6 | Runnable SQL source for Experiment 6 |

## Experiment details

### Experiment 1 — E-commerce ER diagram

Designs an ER diagram for an Indian e-commerce platform. The diagram includes Customer, Address, Seller, Product, Category, Order, Order Item, Payment, and product subtypes such as Electronic, Fashion, and Home Appliance. It records entity attributes and relationships/cardinalities, including customer orders and addresses, sellers listing products, products belonging to categories, orders containing order items, and payments for orders.

**Related file:** [`Experiment 1.pdf`](Experiment%201.pdf)

### Experiment 2 — Relational schema and MySQL implementation

Converts the e-commerce ER design to relational tables and implements them in MySQL. The shown tables include Customer, Seller, Category, Product, Orders, Order_Item, and Payment. The exercise demonstrates primary keys, foreign keys, `NOT NULL` and `UNIQUE` constraints, `ON DELETE CASCADE` and `ON DELETE SET NULL`, sample data, and a referential-integrity violation.

**Related file:** [`Experiment 2.pdf`](Experiment%202.pdf)

### Experiment 3 — Employee, department, and project queries

Creates and populates `Department`, `Project`, and `Employee` tables with five departments, four projects, and 30 employees. The script uses database `dbms_exp3` and demonstrates selection, projection, aggregate functions (`COUNT`, `AVG`, `MAX`), `GROUP BY`, `HAVING`, `CASE` salary bands, and `ORDER BY`.

**Related files:** [`Experiment 3.pdf`](Experiment%203.pdf) · [`sql/experiment3.sql`](sql/experiment3.sql)

### Experiment 4 — Joins, subqueries, set patterns, and execution plans

Builds `Department`, `Project`, and `Employee` tables in `dbms_exp4`. The script demonstrates inner, left, self, and three-way joins; a correlated subquery; `EXISTS`; simulated `INTERSECT` and `EXCEPT` patterns; and query-plan inspection with `EXPLAIN`. The simulated `EXCEPT` uses `NOT EXISTS` for MySQL compatibility.

**Related files:** [`Experiment 4.pdf`](Experiment%204.pdf) · [`sql/experiment4.sql`](sql/experiment4.sql)

### Experiment 5 — Views and recursive reporting chains

Creates `Department` and `Employee` tables in `dbms_exp5`, including `ManagerID` links. It defines a department salary summary view and an employee hierarchy view, shows the aggregate/grouped and self-join updates as commented examples (they are expected to fail), and runs a recursive CTE to return employee reporting paths and hierarchy levels.

**Related files:** [`Experiment 5.pdf`](Experiment%205.pdf) · [`sql/experiment5.sql`](sql/experiment5.sql)

### Experiment 6 — Stored procedure, validation triggers, and audit log

Creates `Department`, `Employee`, and `SalaryAudit` tables in `dbms_exp6`. The `transfer_employee(emp_id, new_dept_id)` procedure validates employee and department IDs. Triggers reject salary updates at or below zero and log valid salary changes. Invalid-input examples are commented so they do not stop the script; uncomment and run them individually to observe the errors.

**Related files:** [`Experiment 6.pdf`](Experiment%206.pdf) · [`sql/experiment6.sql`](sql/experiment6.sql)

## Suggested study order

The experiments progress from conceptual design (1), to relational implementation and constraints (2), to SQL queries and joins (3–4), then views and hierarchical queries (5), and stored procedures and triggers (6). The Experiment 1 and 2 records remain PDF-only; their SQL must be transcribed from the scans if you want to run it.

The SQL scripts target MySQL 8. Each script creates and selects its own database (`dbms_exp3`, `dbms_exp4`, `dbms_exp5`, or `dbms_exp6`) and includes the tables and sample data needed for that experiment. Run one script at a time from the repository root, for example:

```sh
mysql < sql/experiment3.sql
```

Use `experiment4.sql`, `experiment5.sql`, or `experiment6.sql` to run another practical. The scripts are intended for a clean first run: they create tables and insert fixed sample rows, so to rerun one, drop its corresponding `dbms_expN` database first. The scripts contain executable sample implementations based on the PDF exercises; review the PDFs for the original lab record and expected results. The Experiment 5 salary-summary views and Experiment 6 procedure/triggers modify data, so use the included practice databases.

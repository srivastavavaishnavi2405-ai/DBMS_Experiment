# DBMS Experiments

This repository contains six database management lab experiments as PDF records. The PDFs include handwritten SQL, query examples, and expected or observed outputs. Experiments 1 and 2 are scanned handwritten pages; Experiments 3–6 are digitally prepared lab records.

## Files

| File | Experiment | Main topic |
|---|---:|---|
| [`Experiment 1.pdf`](Experiment%201.pdf) | 1 | E-commerce ER diagram |
| [`Experiment 2.pdf`](Experiment%202.pdf) | 2 | Relational schema and MySQL implementation |
| [`Experiment 3.pdf`](Experiment%203.pdf) | 3 | Employee/department/project schema and basic SQL queries |
| [`Experiment 4.pdf`](Experiment%204.pdf) | 4 | Joins, subqueries, set-operation patterns, and `EXPLAIN` |
| [`Experiment 5.pdf`](Experiment%205.pdf) | 5 | Views, view updatability, and recursive CTEs |
| [`Experiment 6.pdf`](Experiment%206.pdf) | 6 | Stored procedure validation, triggers, and audit logging |

## Experiment details

### Experiment 1 — E-commerce ER diagram

Designs an ER diagram for an Indian e-commerce platform. The diagram includes Customer, Address, Seller, Product, Category, Order, Order Item, Payment, and product subtypes such as Electronic, Fashion, and Home Appliance. It records entity attributes and relationships/cardinalities, including customer orders and addresses, sellers listing products, products belonging to categories, orders containing order items, and payments for orders.

**Related file:** [`Experiment 1.pdf`](Experiment%201.pdf)

### Experiment 2 — Relational schema and MySQL implementation

Converts the e-commerce ER design to relational tables and implements them in MySQL. The shown tables include Customer, Seller, Category, Product, Orders, Order_Item, and Payment. The exercise demonstrates primary keys, foreign keys, `NOT NULL` and `UNIQUE` constraints, `ON DELETE CASCADE` and `ON DELETE SET NULL`, sample data, and a referential-integrity violation.

**Related file:** [`Experiment 2.pdf`](Experiment%202.pdf)

### Experiment 3 — Employee, department, and project queries

Creates and populates an Employee–Department–Project schema, including 30 employee records. The SQL practice covers selection, projection, aggregate functions (`COUNT`, `AVG`, `MAX`), `GROUP BY`, `HAVING`, `CASE` salary bands, and `ORDER BY`.

**Related file:** [`Experiment 3.pdf`](Experiment%203.pdf)

### Experiment 4 — Joins, subqueries, set patterns, and execution plans

Builds Department, Project, and Employee tables and demonstrates inner, left, self, and three-way joins; a correlated subquery; `EXISTS`; simulated `INTERSECT` and `EXCEPT` queries; and query-plan inspection with `EXPLAIN`. The record also compares the inner-join and correlated-subquery approaches.

**Related file:** [`Experiment 4.pdf`](Experiment%204.pdf)

### Experiment 5 — Views and recursive reporting chains

Creates a department salary summary view and an employee hierarchy view. It tests why aggregate/grouped and self-join views are not directly updatable, then uses a recursive CTE to traverse employee-manager reporting chains and show hierarchy levels.

**Related file:** [`Experiment 5.pdf`](Experiment%205.pdf)

### Experiment 6 — Stored procedure, validation triggers, and audit log

Creates and tests a `transfer_employee(emp_id, new_dept_id)` procedure with validation and error handling. Triggers validate salary updates and log salary changes to an audit table. The PDF includes valid and invalid transfer cases, salary updates, zero/negative salary cases, invalid IDs, and same-department transfer testing.

**Related file:** [`Experiment 6.pdf`](Experiment%206.pdf)

## Suggested study order

The experiments progress from conceptual design (1), to relational implementation and constraints (2), to SQL queries and joins (3–4), then views and hierarchical queries (5), and stored procedures and triggers (6). Each experiment is a PDF record; there are no separate `.sql` files in this repository, so code must be copied or transcribed from the corresponding PDF to execute it.

The SQL examples target MySQL-style syntax. Review each PDF for its full statements, table definitions, and results before running them, and use a separate practice database when experimenting with updates or triggers.

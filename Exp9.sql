-- Use the database selected by the editor/environment.
-- CREATE RAILWAY BOOKING TABLE
DROP TABLE IF EXISTS RailwayBooking;

CREATE TABLE RailwayBooking (
    BookingID INT PRIMARY KEY,
    PassengerName VARCHAR(100),
    TrainNo INT,
    TrainName VARCHAR(100),
    SourceStation VARCHAR(100),
    DestinationStation VARCHAR(100),
    JourneyDate DATE,
    SeatNo INT,
    ClassType VARCHAR(30),
    Fare DECIMAL(10,2),
    BookingStatus VARCHAR(30)
) ENGINE = InnoDB;

-- INSERT 5000+ RECORDS
SET SESSION cte_max_recursion_depth = 6000;

INSERT INTO RailwayBooking
(
    BookingID,
    PassengerName,
    TrainNo,
    TrainName,
    SourceStation,
    DestinationStation,
    JourneyDate,
    SeatNo,
    ClassType,
    Fare,
    BookingStatus
)
WITH RECURSIVE Numbers AS
(
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM Numbers
    WHERE n < 5000
)
SELECT
    n,
    CONCAT('Passenger_', n),
    12000 + MOD(n, 20),
    CONCAT('Train_', MOD(n, 20)),
    CASE MOD(n, 5)
        WHEN 0 THEN 'Delhi'
        WHEN 1 THEN 'Mumbai'
        WHEN 2 THEN 'Kanpur'
        WHEN 3 THEN 'Lucknow'
        ELSE 'Bhopal'
    END,
    CASE MOD(n, 5)
        WHEN 0 THEN 'Mumbai'
        WHEN 1 THEN 'Kanpur'
        WHEN 2 THEN 'Lucknow'
        WHEN 3 THEN 'Bhopal'
        ELSE 'Delhi'
    END,
    DATE_ADD('2026-01-01', INTERVAL MOD(n, 365) DAY),
    MOD(n, 100) + 1,
    CASE MOD(n, 3)
        WHEN 0 THEN 'Sleeper'
        WHEN 1 THEN 'AC_3_Tier'
        ELSE 'AC_2_Tier'
    END,
    500 + MOD(n, 20) * 100,
    CASE MOD(n, 3)
        WHEN 0 THEN 'Confirmed'
        WHEN 1 THEN 'Waiting'
        ELSE 'Cancelled'
    END
FROM Numbers;

-- VERIFY RECORD COUNT

SELECT COUNT(*) AS TotalBookings
FROM RailwayBooking;
SELECT *
FROM RailwayBooking
LIMIT 10;

-- BENCHMARK BEFORE INDEXING
-- Query 1: Search using TrainNo

EXPLAIN
SELECT *
FROM RailwayBooking
WHERE TrainNo = 12005;
-- Execute the query
SELECT *
FROM RailwayBooking
WHERE TrainNo = 12005;
-- Query 2: Search by SourceStation and JourneyDate
EXPLAIN
SELECT *
FROM RailwayBooking
WHERE SourceStation = 'Delhi'
  AND JourneyDate = '2026-01-10';
SELECT *
FROM RailwayBooking
WHERE SourceStation = 'Delhi'
  AND JourneyDate = '2026-01-10';

-- Query 3: Search by TrainNo and JourneyDate
EXPLAIN
SELECT *
FROM RailwayBooking
WHERE TrainNo = 12005
  AND JourneyDate = '2026-01-10';
SELECT *
FROM RailwayBooking
WHERE TrainNo = 12005
  AND JourneyDate = '2026-01-10';

-- CREATE SINGLE-COLUMN INDEX
CREATE INDEX idx_trainno
ON RailwayBooking(TrainNo);

-- TEST AFTER SINGLE-COLUMN INDEX
EXPLAIN
SELECT *
FROM RailwayBooking
WHERE TrainNo = 12005;
SELECT *
FROM RailwayBooking
WHERE TrainNo = 12005;

-- CREATE COMPOSITE INDEX
CREATE INDEX idx_source_date
ON RailwayBooking(SourceStation, JourneyDate);

-- TEST AFTER COMPOSITE INDEX
EXPLAIN
SELECT *
FROM RailwayBooking
WHERE SourceStation = 'Delhi'
  AND JourneyDate = '2026-01-10';
SELECT *
FROM RailwayBooking
WHERE SourceStation = 'Delhi'
  AND JourneyDate = '2026-01-10';

-- CREATE ANOTHER COMPOSITE INDEX
CREATE INDEX idx_train_date
ON RailwayBooking(TrainNo, JourneyDate);

-- COMPARE EXECUTION PLANS
EXPLAIN
SELECT *
FROM RailwayBooking
WHERE TrainNo = 12005
  AND JourneyDate = '2026-01-10';

-- Detailed execution plan in MySQL 8.0.18+
EXPLAIN ANALYZE
SELECT *
FROM RailwayBooking
WHERE TrainNo = 12005
  AND JourneyDate = '2026-01-10';

-- CHECK CREATED INDEXES
SHOW INDEX FROM RailwayBooking;
-- UPDATE TABLE STATISTICS
ANALYZE TABLE RailwayBooking;
-- FINAL PERFORMANCE TESTS

-- Single-column index query
EXPLAIN
SELECT BookingID, PassengerName, TrainNo
FROM RailwayBooking
WHERE TrainNo = 12005;

-- Composite index query: both columns
EXPLAIN
SELECT BookingID, TrainNo, JourneyDate
FROM RailwayBooking
WHERE TrainNo = 12005
  AND JourneyDate = '2026-01-10';

  -- Composite index query: first column only
EXPLAIN
SELECT BookingID, TrainNo
FROM RailwayBooking
WHERE TrainNo = 12005;

-- Composite index query: second column only
EXPLAIN
SELECT BookingID, JourneyDate
FROM RailwayBooking
WHERE JourneyDate = '2026-01-10';

-- FINAL BOOKING SUMMARY
SELECT COUNT(*) AS TotalBookings
FROM RailwayBooking;

SELECT BookingStatus, COUNT(*) AS Total
FROM RailwayBooking
GROUP BY BookingStatus;

SELECT TrainNo, COUNT(*) AS TotalBookings
FROM RailwayBooking
GROUP BY TrainNo
ORDER BY TrainNo;


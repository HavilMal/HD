SET DATEFIRST 1;

DECLARE @StartDate DATE = '2020-05-01';
DECLARE @EndDate DATE = '2024-08-31';

WITH DateCTE AS (
    SELECT @StartDate AS DateValue
    UNION ALL
    SELECT DATEADD(day, 1, DateValue)
    FROM DateCTE
    WHERE DateValue < @EndDate
)
INSERT INTO Dim_Date (
    date_id, 
    full_date, 
    [year], 
    [month], 
    month_name,
    day_of_week, 
    day_of_week_name, 
    day_type, 
    season,      
    season_name
)
SELECT 
    YEAR(DateValue) * 10000 + MONTH(DateValue) * 100 + DAY(DateValue) AS date_id,
    DateValue AS full_date,
    YEAR(DateValue) AS [year],
    MONTH(DateValue) AS [month],
    DATENAME(MONTH, DateValue) AS month_name,
    DATEPART(WEEKDAY, DateValue) AS day_of_week_number, 
    DATENAME(WEEKDAY, DateValue) AS day_of_week_name,
    CASE 
        WHEN DATEPART(WEEKDAY, DateValue) IN (6, 7) THEN 'Weekend' 
        ELSE 'Weekday' 
    END AS day_type,
    CASE 
        WHEN MONTH(DateValue) IN (3, 4, 5)  THEN 1
        WHEN MONTH(DateValue) IN (6, 7, 8)  THEN 2
        WHEN MONTH(DateValue) IN (9, 10, 11) THEN 3
        WHEN MONTH(DateValue) IN (12, 1, 2) THEN 4
    END AS season_number,
    CASE 
        WHEN MONTH(DateValue) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(DateValue) IN (3, 4, 5)  THEN 'Spring'
        WHEN MONTH(DateValue) IN (6, 7, 8)  THEN 'Summer'
        WHEN MONTH(DateValue) IN (9, 10, 11) THEN 'Autumn'
    END AS season_name
FROM DateCTE
WHERE NOT EXISTS (
    SELECT 1 
    FROM Dim_Date d 
    WHERE d.date_id = (YEAR(DateValue) * 10000 + MONTH(DateValue) * 100 + DAY(DateValue))
)
OPTION (MAXRECURSION 0);


ALTER TABLE Dim_Date 
ADD month_name VARCHAR(20);


UPDATE Dim_Date
SET month_name = DATENAME(MONTH, full_date);
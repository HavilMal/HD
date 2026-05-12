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
INSERT INTO Dim_Date (date_id, full_date, [year], [month], day_of_week, day_type, season)
SELECT 
    YEAR(DateValue) * 10000 + Month(DateValue) * 100 + DAY(DateValue) AS date_id,
    DateValue AS full_date,
    YEAR(DateValue) AS [year],
    MONTH(DateValue) AS [month],
    DATENAME(WEEKDAY, DateValue) AS day_of_week,
    CASE 
        WHEN DATEPART(WEEKDAY, DateValue) IN (6, 7) THEN 'Weekend' 
        ELSE 'Weekday' 
    END AS day_type,
    CASE 
        WHEN MONTH(DateValue) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(DateValue) IN (3, 4, 5)  THEN 'Spring'
        WHEN MONTH(DateValue) IN (6, 7, 8)  THEN 'Summer'
        WHEN MONTH(DateValue) IN (9, 10, 11) THEN 'Autumn'
    END AS season
FROM DateCTE
OPTION (MAXRECURSION 0);
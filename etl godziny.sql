WITH MinuteSequence AS (
    SELECT 0 AS MinuteOffset
    UNION ALL
    SELECT MinuteOffset + 1
    FROM MinuteSequence
    WHERE MinuteOffset < 1439
),
CalculatedTime AS (
    SELECT DATEADD(MINUTE, MinuteOffset, CAST('00:00' AS TIME)) AS ActualTime
    FROM MinuteSequence
)
INSERT INTO Dim_Time (
    time_id, 
    [hour], 
    [minute], 
    part_of_day, 
    part_of_day_name
)
SELECT 
    (DATEPART(HOUR, ActualTime) * 100) + DATEPART(MINUTE, ActualTime),
    DATEPART(HOUR, ActualTime),
    DATEPART(MINUTE, ActualTime),
    
    CASE 
        WHEN DATEPART(HOUR, ActualTime) < 5  THEN 1 
        WHEN DATEPART(HOUR, ActualTime) < 9  THEN 2 
        WHEN DATEPART(HOUR, ActualTime) < 15 THEN 3 
        WHEN DATEPART(HOUR, ActualTime) < 18 THEN 4 
        WHEN DATEPART(HOUR, ActualTime) < 21 THEN 5
        ELSE 1 
    END,
    
    CASE 
        WHEN DATEPART(HOUR, ActualTime) < 5  THEN 'Night'
        WHEN DATEPART(HOUR, ActualTime) < 9  THEN 'Morning Rush'
        WHEN DATEPART(HOUR, ActualTime) < 15 THEN 'Midday'
        WHEN DATEPART(HOUR, ActualTime) < 18 THEN 'Afternoon Rush'
        WHEN DATEPART(HOUR, ActualTime) < 21 THEN 'Evening'
        ELSE 'Night'
    END
FROM CalculatedTime
WHERE NOT EXISTS (
    SELECT 1 
    FROM Dim_Time t 
    WHERE t.time_id = (DATEPART(HOUR, ActualTime) * 100) + DATEPART(MINUTE, ActualTime)
)
OPTION (MAXRECURSION 1440);
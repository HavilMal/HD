WITH all_station_names AS (
    SELECT 
        start_station_id AS station_id, 
        start_station_name AS station_name, 
        started_at AS timestamp
    FROM [dbo].[Wypożyczenia Poczekalnia]
    WHERE start_station_id IS NOT NULL
    
    UNION ALL
    
    SELECT 
        end_station_id AS station_id, 
        end_station_name AS station_name, 
        ended_at AS timestamp
    FROM [dbo].[Wypożyczenia Poczekalnia]
    WHERE end_station_id IS NOT NULL
),
ranked_names AS (
    SELECT 
        station_id, 
        station_name,
        ROW_NUMBER() OVER(PARTITION BY station_id ORDER BY timestamp ASC) AS rn
    FROM all_station_names
)
SELECT 
    station_id, 
    station_name
FROM ranked_names
WHERE rn = 1;



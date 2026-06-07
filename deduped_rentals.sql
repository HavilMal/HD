WITH DedupedData AS (
    SELECT 
        *,
        ROW_NUMBER() OVER(
            PARTITION BY ride_id 
            ORDER BY started_at DESC
        ) as rn
    FROM [dbo].[Wypożyczenia Poczekalnia]
)
SELECT * 
FROM DedupedData 
WHERE rn = 1;



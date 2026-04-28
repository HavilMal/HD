BULK INSERT rides
FROM 'C:\PWR\HD\Bikeshare\daily_rent_detail.csv'
WITH (
    FIRSTROW = 2,
    FORMAT = 'CSV',
    TABLOCK,
    BATCHSIZE = 100000
);

BULK INSERT rides
FROM 'C:\PWR\HD\Bikeshare\daily_rent_detail.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2
    -- FIELDQUOTE = '"',
    -- CODEPAGE = '65001'
);



CREATE TABLE rides_raw (
    ride_id CHAR(16),
    rideable_type VARCHAR(13),
    started_at DATETIME,
    ended_at DATETIME,
    start_station_name NVARCHAR(100),
    start_station_id NVARCHAR(20),
    end_station_name NVARCHAR(100),
    end_station_id NVARCHAR(20),
    start_lat FLOAT,
    start_lng FLOAT,
    end_lat FLOAT,
    end_lng FLOAT,
    member_casual NVARCHAR(10)
);


BULK INSERT rides_raw
FROM 'C:\PWR\HD\Bikeshare\daily_rent_detail.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

ALTER TABLE weather_hourly ALTER COLUMN time DATETIME NOT NULL;

UPDATE weather_hourly 
SET time = REPLACE(time, 'T', ' ');

UPDATE weather_hourly 
SET time = time + ':00' 
WHERE LEN(time) = 16;


ALTER TABLE weather_hourly ALTER COLUMN temperature FLOAT NULL;
ALTER TABLE weather_hourly ALTER COLUMN wind_speed FLOAT NULL;
ALTER TABLE weather_hourly ALTER COLUMN rain FLOAT NULL;
ALTER TABLE weather_hourly ALTER COLUMN snowfall FLOAT NULL;
ALTER TABLE weather_hourly ALTER COLUMN snow_depth FLOAT NULL;
ALTER TABLE weather_hourly ALTER COLUMN precipitation FLOAT NULL;
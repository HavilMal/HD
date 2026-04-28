-- Drop tables if they already exist to prevent creation errors
DROP TABLE IF EXISTS usage_frequency;
DROP TABLE IF EXISTS weather;
DROP TABLE IF EXISTS rides;
DROP TABLE IF EXISTS stations;

-- 1. Station List Table
CREATE TABLE stations (
    station_id VARCHAR(20) PRIMARY KEY,
    station_name VARCHAR(150) NOT NULL
);

-- 2. Daily Rent Data (Rides) Table
CREATE TABLE rides (
    ride_id VARCHAR(32) PRIMARY KEY,
    rideable_type VARCHAR(20),
    started_at DATETIME, -- (0) limits to exact seconds, saving 2 bytes per row
    ended_at DATETIME,
    start_station_name VARCHAR(150),
    start_station_id VARCHAR(20),
    end_station_name VARCHAR(150),
    end_station_id VARCHAR(20),
    start_lat DECIMAL(9, 6),
    start_lng DECIMAL(9, 6),
    end_lat DECIMAL(9, 6),
    end_lng DECIMAL(9, 6),
    member_casual VARCHAR(10) 
);

-- 3. Usage Frequency Table
CREATE TABLE usage_frequency (
    date DATE,
    station_name VARCHAR(150),
    pickup_counts INT DEFAULT 0,
    dropoff_counts INT DEFAULT 0,
    PRIMARY KEY (date, station_name)
);

-- 4. Weather Table
CREATE TABLE weather (
    name VARCHAR(100), 
    datetime DATE,     
    tempmax DECIMAL(5, 2),
    tempmin DECIMAL(5, 2),
    temp DECIMAL(5, 2),
    feelslikemax DECIMAL(5, 2),
    feelslikemin DECIMAL(5, 2),
    feelslike DECIMAL(5, 2),
    dew DECIMAL(5, 2),
    humidity DECIMAL(5, 2),
    precip DECIMAL(6, 3),
    precipprob DECIMAL(5, 2),
    precipcover DECIMAL(5, 2),
    preciptype VARCHAR(100), 
    snow DECIMAL(6, 2),
    snowdepth DECIMAL(6, 2),
    windgust DECIMAL(5, 2),
    windspeed DECIMAL(5, 2),
    winddir DECIMAL(6, 2),
    sealevelpressure DECIMAL(6, 2),
    cloudcover DECIMAL(5, 2),
    visibility DECIMAL(5, 2),
    solarradiation DECIMAL(6, 2),
    solarenergy DECIMAL(6, 2),
    uvindex DECIMAL(4, 1),
    severerisk DECIMAL(5, 2),
    sunrise TIME(0), -- (0) limits to exact minutes/seconds
    sunset TIME(0),
    moonphase DECIMAL(3, 2),
    conditions VARCHAR(100),
    description VARCHAR(500), -- Swapped TEXT for VARCHAR(500) to avoid legacy LOB issues
    icon VARCHAR(50),
    stations VARCHAR(255), 
    PRIMARY KEY (name, datetime)
);
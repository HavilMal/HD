DROP TABLE IF EXISTS Fact_Rental;
DROP TABLE IF EXISTS Dim_Rental_Profile;
DROP TABLE IF EXISTS Dim_Date;
DROP TABLE IF EXISTS Dim_Location;
DROP TABLE IF EXISTS Dim_Time;
DROP TABLE IF EXISTS Dim_Weather;

CREATE TABLE Dim_Date (
    date_id INT NOT NULL,     
    full_date DATE NOT NULL,
    [year] INT NOT NULL,
    [month] INT NOT NULL,
    day_of_week NVARCHAR(20) NOT NULL,
    day_type NVARCHAR(20) NOT NULL,
    season NVARCHAR(20) NOT NULL,
    
    CONSTRAINT PK_Dim_Date PRIMARY KEY (date_id)
);

CREATE TABLE Dim_Time (
    time_id INT NOT NULL,
    [hour] INT NOT NULL,
    [minute] INT NOT NULL,
    part_of_day NVARCHAR(20) NOT NULL,
    
    CONSTRAINT PK_Dim_Time PRIMARY KEY (time_id)
);

CREATE TABLE Dim_Location (
    location_id INT IDENTITY(1,1) NOT NULL,
    latitude FLOAT NULL,
    longitude FLOAT NULL,
    station_name NVARCHAR(100) NULL,
    location_type NVARCHAR(20) NOT NULL,
    
    CONSTRAINT PK_Dim_Location PRIMARY KEY (location_id)
);

CREATE TABLE Dim_Weather (
    weather_id INT IDENTITY(1,1) NOT NULL,
    temperature_range NVARCHAR(10) NOT NULL,
    wind_speed_range NVARCHAR(10) NOT NULL,
    rain_range NVARCHAR(10) NOT NULL,
    snowfall_range NVARCHAR(10) NOT NULL,
    snow_depth_range NVARCHAR(10) NOT NULL,
    
    CONSTRAINT PK_Dim_Weather PRIMARY KEY (weather_id)
);

CREATE TABLE Dim_Rental_Profile (
    profile_id INT IDENTITY(1,1) NOT NULL,
    member_casual VARCHAR(20) NOT NULL,
    ridable_type VARCHAR(20) NOT NULL,

    CONSTRAINT PK_Dim_Rental_Profile PRIMARY KEY (profile_id)
);


CREATE TABLE Fact_Rental (
    rental_id INT IDENTITY(1,1) NOT NULL,

    start_date_id INT NOT NULL,
    end_date_id INT NOT NULL,

    start_time_id INT NOT NULL,
    end_time_id INT NOT NULL,

    start_location_id INT NOT NULL,
    end_location_id INT NOT NULL,

    weather_id INT NOT NULL,
    profile_id INT NOT NULL,

    duration INT NOT NULL,           
    distance FLOAT NOT NULL,

    CONSTRAINT PK_Fact_Rental PRIMARY KEY (rental_id),

    CONSTRAINT FK_Fact_StartDate FOREIGN KEY (start_date_id) REFERENCES Dim_Date(date_id),
    CONSTRAINT FK_Fact_EndDate FOREIGN KEY (end_date_id) REFERENCES Dim_Date(date_id),
    
    CONSTRAINT FK_Fact_StartTime FOREIGN KEY (start_time_id) REFERENCES Dim_Time(time_id),
    CONSTRAINT FK_Fact_EndTime FOREIGN KEY (end_time_id) REFERENCES Dim_Time(time_id),
    
    CONSTRAINT FK_Fact_StartLoc FOREIGN KEY (start_location_id) REFERENCES Dim_Location(location_id),
    CONSTRAINT FK_Fact_EndLoc FOREIGN KEY (end_location_id) REFERENCES Dim_Location(location_id),
    
    CONSTRAINT FK_Fact_Weather FOREIGN KEY (weather_id) REFERENCES Dim_Weather(weather_id),
    CONSTRAINT FK_Fact_Rental_Profile FOREIGN KEY (profile_id) REFERENCES Dim_Rental_Profile(profile_id),
);
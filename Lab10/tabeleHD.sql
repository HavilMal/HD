DROP TABLE IF EXISTS [dbo].[FactSales];
DROP TABLE IF EXISTS [dbo].[DimDate];
DROP TABLE IF EXISTS [dbo].[DimProduct];
DROP TABLE IF EXISTS [dbo].[DimCustomer];
DROP TABLE IF EXISTS [dbo].[DimAgeGroup];
DROP TABLE IF EXISTS [dbo].[DimCustomer];

CREATE TABLE [dbo].[DimDate](
[DateKey] [int] NOT NULL CONSTRAINT [pk_DimDate] PRIMARY KEY,
[FullDateAlternateKey] [date] NOT NULL,
[DayNumberOfWeek] [tinyint] NOT NULL,
[EnglishDayNameOfWeek] [nvarchar](10) NOT NULL,
[DayNumberOfMonth] [tinyint] NOT NULL,
[DayNumberOfYear] [smallint] NOT NULL,
[WeekNumberOfYear] [tinyint] NOT NULL,
[EnglishMonthName] [nvarchar](10) NOT NULL,
[MonthNumberOfYear] [tinyint] NOT NULL,
[CalendarQuarter] [tinyint] NOT NULL,
[CalendarYear] [smallint] NOT NULL,
[CalendarSemester] [tinyint] NOT NULL,
);

CREATE TABLE [dbo].[DimCustomer](
    [CustomerKey] [int] IDENTITY(1,1) NOT NULL CONSTRAINT [pk_DimCustomer] PRIMARY KEY,
    
    [CustomerID] [int] NOT NULL, 
    
    [FirstName] [nvarchar](50) NOT NULL,
    [LastName] [nvarchar](50) NOT NULL,
    [BirthDate] [date] NULL,
    [EnglishOccupation] [nvarchar](100) NULL,
    [EnglishEducation] [nvarchar](40) NULL,
    [Gender] [nvarchar](1) NULL,
    [MaritalStatus] [nchar](1) NULL,
    [NumberChildrenAtHome] [tinyint] NULL,
    [TotalChildren] [tinyint] NULL,
    [YearlyIncome] [money] NULL
);

CREATE TABLE [dbo].[DimProduct](
[ProductKey] [int] IDENTITY(1,1) NOT NULL,
[ProductID] [int] NULL,
[Name] [nvarchar](50) NULL,
[Color] [nvarchar](15) NULL,
[ListPrice] [money] NULL,
[Size] [nvarchar](5) NULL,
[Weight] [numeric](8, 2) NULL,
[ProductLine] [nvarchar](2) NULL,
[Class] [nvarchar](2) NULL,
[Style] [nvarchar](2) NULL,
[ProductSubcategoryID] [int] NULL,
[ProductModelID] [int] NULL,
[SizeUnitMeasureCode] [nvarchar](3) NULL,
[Grupa rozmiaru] [nvarchar](15) NULL,
[ModelName] [nvarchar](50) NULL,
[Grupa cenowa] [nvarchar](12) NULL,
CONSTRAINT [pk_DimProduct] PRIMARY KEY (ProductKey)
);


CREATE TABLE DimAgeGroup (
AgeGroupID INT CONSTRAINT pk_AgeGroup PRIMARY KEY,
AgeGroup VARCHAR(10) NOT NULL,
MinYear INT NOT NULL,
MaxYear INT NOT NULL
);


CREATE TABLE [dbo].[FactSales](
    [SalesOrderID] [int] NOT NULL,
    [SalesOrderNumber] [nvarchar](25) NOT NULL,
    [SalesOrderLineNumber] INT NOT NULL,
    [OrderDate] [date] NOT NULL,
    [OrderDateKey] [int] NULL,
    [DueDate] [date] NOT NULL,
    [DueDateKey] [int] NULL,
    [ProductKey] [int] NOT NULL,
    [CustomerKey] [int] NOT NULL, 
    [AgeGroupID] [int] NOT NULL,
    [OrderQty] [smallint] NOT NULL,
    [UnitPrice] [money] NOT NULL,
    [SalesAmount] [numeric](38, 6) NOT NULL,
    CONSTRAINT pk_FactSales PRIMARY KEY(SalesOrderNumber, SalesOrderLineNumber)
);
GO

ALTER TABLE [dbo].[FactSales] WITH CHECK ADD CONSTRAINT [fk_DueDimDate] 
FOREIGN KEY([DueDateKey]) REFERENCES [dbo].[DimDate] ([DateKey]);

ALTER TABLE [dbo].[FactSales] WITH CHECK ADD CONSTRAINT [fk_OrderDimDate] 
FOREIGN KEY([OrderDateKey]) REFERENCES [dbo].[DimDate] ([DateKey]);

ALTER TABLE [dbo].[FactSales] WITH CHECK ADD CONSTRAINT [fk_Product] 
FOREIGN KEY([ProductKey]) REFERENCES [dbo].[DimProduct] ([ProductKey]);

ALTER TABLE [dbo].[FactSales] WITH CHECK ADD CONSTRAINT [fk_Customer] 
FOREIGN KEY([CustomerKey]) REFERENCES [dbo].[DimCustomer] ([CustomerKey]);

ALTER TABLE [dbo].[FactSales] WITH CHECK ADD CONSTRAINT [fk_AgeGroup] 
FOREIGN KEY([AgeGroupID]) REFERENCES [dbo].[DimAgeGroup] ([AgeGroupID]);
GO
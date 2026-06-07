DROP TABLE IF EXISTS [dbo].[StgCustomer];
DROP TABLE IF EXISTS [dbo].[StgProduct];
DROP TABLE IF EXISTS [dbo].[StgFactSales];

CREATE TABLE [dbo].[StgProduct](
[ProductID] INT NULL,
[Name] NVARCHAR(50) NULL,
[Color] NVARCHAR(15) NULL,
[ListPrice] MONEY NULL,
[Size] NVARCHAR(5) NULL,
[Weight] NUMERIC(8, 2) NULL,
[ProductLine] NVARCHAR(2) NULL,
[Class] NVARCHAR(2) NULL,
[Style] NVARCHAR(2) NULL,
[ProductSubcategoryID] INT NULL,
[ProductSubcategoryName] NVARCHAR(50) NOT NULL,
[ProductCategoryID] INT NULL,
[ProductCategoryName] NVARCHAR(50) NOT NULL,
[ProductModelID] INT NULL,
[SizeUnitMeasureCode] NVARCHAR(3) NULL,
[Grupa rozmiaru] NVARCHAR(15) NULL,
[ModelName] NVARCHAR(50) NULL,
[Grupa cenowa] NVARCHAR(12) NULL,
);


CREATE TABLE [dbo].[StgCustomer](
[BusinessEntityID] INT NOT NULL CONSTRAINT pk_StgCustomer PRIMARY KEY,
[LastName] NVARCHAR(50) NOT NULL,
[FirstName] NVARCHAR(50) NOT NULL,
[BirthDate] DATE NULL,
[EnglishOccupation] NVARCHAR(100) NULL,
[EnglishEducation] NVARCHAR(40) NULL,
[Gender] NVARCHAR(1) NULL,
[MaritalStatus] NCHAR(1) NULL,
[NumberChildrenAtHome] TINYINT NULL,
[YearlyIncome] MONEY NULL, -- DEC(12, 2)
[TotalChildren] TINYINT NULL
) ;


CREATE TABLE [dbo].[StgFactSales](
[SalesOrderID] INT NOT NULL,
[SalesOrderNumber] NVARCHAR(25) NOT NULL,
[SalesOrderLineNumber] INT NOT NULL,
[OrderDate] DATE NOT NULL,
[OrderDateKey] INT NULL,
[DueDate] DATE NOT NULL,
[DueDateKey] INT NULL,
[ProductID] INT NOT NULL,
[CustomerID] INT NOT NULL, -- BusinessEntityID
[OrderQty] SMALLINT NOT NULL,
[SalesAmount] NUMERIC(12, 2) NOT NULL,
[AgeGroup] VARCHAR(10),
[AgeAtSale] INT
);


TRUNCATE TABLE [dbo].[StgCustomer];
TRUNCATE TABLE [dbo].[StgFactSales];
TRUNCATE TABLE [dbo].[StgProduct];
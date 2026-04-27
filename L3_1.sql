CREATE TABLE Dim_Customer
(
    CustomerID        int PRIMARY KEY,
    FirstName         nvarchar(50),
    LastName          nvarchar(50),
    TerritoryName     nvarchar(50),
    CountryRegionCode nvarchar(3),
    "Group"           nvarchar(50)
)

CREATE TABLE Dim_Product
(
    ProductID       int PRIMARY KEY,
    Name            nvarchar(50),
    ListPrice       money,
    Color           nvarchar(15),
    SubCategoryName nvarchar(50),
    CategoryName    nvarchar(50)
)

CREATE TABLE Fact_Orders
(
    FactOrderID       int IDENTITY (1, 1) PRIMARY KEY,
    ProductID         int,
    CustomerID        int,
    OrderDate         DATETIME,
    ShipDate          DATETIME,
    OrderQty          smallint,
    UnitPrice         money,
    UnitPriceDiscount money,
    LineTotal         numeric(38, 6),

    CONSTRAINT FK_Dim_Product FOREIGN KEY (ProductID) REFERENCES Dim_Product (ProductID),
    CONSTRAINT FK_Dim_Customer FOREIGN KEY (CustomerID) REFERENCES Dim_Customer (CustomerID)
)


INSERT INTO Dim_Customer
SELECT c.CustomerID, p.FirstName, p.LastName, st.Name, st.CountryRegionCode, st."Group"
FROM OLTP.Sales.Customer c
         LEFT JOIN OLTP.Person.Person p ON c.PersonID = p.BusinessEntityID
         LEFT JOIN OLTP.Sales.SalesTerritory st ON c.TerritoryID = st.TerritoryID;

INSERT INTO Dim_Product
SELECT p.ProductID, p.Name, p.ListPrice, p.Color, ps.Name, pc.Name
FROM OLTP.Production.Product p
         LEFT JOIN OLTP.Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
         LEFT JOIN OLTP.Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID;

INSERT INTO Fact_Orders (productid, customerid, orderdate, shipdate, orderqty, unitprice, unitpricediscount, linetotal)
SELECT sod.ProductID,
       soh.CustomerID,
       soh.OrderDate,
       soh.ShipDate,
       sod.OrderQty,
       sod.UnitPrice,
       sod.UnitPriceDiscount,
       sod.LineTotal
FROM OLTP.Sales.SalesOrderHeader soh
         LEFT JOIN OLTP.Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID;




SELECT LastName + ', ' + FirstName, CategoryName, Name, UnitPrice
From Fact_Orders fo
Left join dim_product dp ON fo.productid = dp.productid
left join dim_customer dc ON fo.customerid = dc.customerid


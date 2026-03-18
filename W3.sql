SELECT TOP 20 COUNT(*) ctn,
              p.Name,
              pc.Name
FROM Sales.SalesOrderDetail sod
         LEFT JOIN Production.Product p
                   ON sod.ProductID = p.ProductID
         LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
         LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY p.Name, pc.Name
ORDER BY ctn DESC;


WITH topsales AS (SELECT TOP 20 COUNT(*) ctn, ProductID
                  FROM Sales.SalesOrderDetail sod
                  GROUP BY sod.ProductID
                  ORDER BY ctn DESC)
SELECT ts.ctn,
              p.Name,
              pc.Name
FROM topsales ts
         LEFT JOIN Production.Product p
                   ON ts.ProductID = p.ProductID
         LEFT JOIN OLTP.Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
         LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID;



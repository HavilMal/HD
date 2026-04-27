



SELECT CustomerID                      Klient,
       YEAR(soh.OrderDate)             Rok,
       p.LastName + ', ' + p.FirstName "Nazwisko, Imię",
       COUNT(*)                        "Liczba zamówień",
       SUM(TotalDue)                   Kwota
FROM Sales.SalesOrderHeader soh
         LEFT JOIN Person.Person p ON soh.CustomerID = p.BusinessEntityID
GROUP BY CustomerID, YEAR(soh.OrderDate), p.LastName + ', ' + p.FirstName
HAVING SUM(TotalDue) > 130000
ORDER BY "Liczba zamówień" DESC;


SELECT MIN(OrderDate)                                Pierwsze,
       MAX(OrderDate)                                Ostatnie,
       DATEDIFF(DAY, MIN(OrderDate), MAX(OrderDate)) "Liczba dni"
FROM Sales.SalesOrderHeader;


SELECT CustomerID                                    Klient,
       Cast(MIN(OrderDate) as date)                                Od,
       MAX(OrderDate)                                Do,
       DATEDIFF(DAY, MIN(OrderDate), MAX(OrderDate)) "Liczba dni",
       COUNT(*)                                      "Liczba zam."
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY CustomerID;

WITH processedOrders AS (SELECT SalesPersonID pracID, YEAR(OrderDate) Rok, COUNT(*) Liczba
                         FROM Sales.SalesOrderHeader
                         GROUP BY SalesPersonID, YEAR(OrderDate))
SELECT *, SUM(Liczba) OVER (PARTITION BY pracID ORDER BY Rok ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) Razem
FROM processedOrders
WHERE pracID IS NOT NULL
ORDER BY pracID;

SELECT YEAR(OrderDate) rok, pc.Name Kategoria, SUM(SubTotal) kwota, COUNT(*) "Liczba zam."
FROM Sales.SalesOrderHeader soh
         LEFT JOIN Sales.SalesOrderDetail sod
                   ON sod.SalesOrderID = soh.SalesOrderID
         LEFT JOIN Production.Product p
                   ON sod.ProductID = p.ProductID
         LEFT JOIN Production.ProductSubcategory ps
                   ON p.ProductSubcategoryID = ps.ProductSubcategoryID
         LEFT JOIN Production.ProductCategory pc
                   ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY YEAR(OrderDate), pc.Name
ORDER BY rok, kwota DESC;

WITH processedOrders AS (SELECT SalesPersonID pracID, YEAR(OrderDate) rok, COUNT(*) liczba
                         FROM Sales.SalesOrderHeader
                         GROUP BY SalesPersonID, YEAR(OrderDate))
SELECT *
FROM processedOrders PIVOT (
         SUM(liczba) FOR rok IN (
        "2022", "2023", "2024", "2025"
        )) AS p
WHERE pracID IS NOT NULL;

WITH clientSum AS (SELECT CustomerID klientID, YEAR(OrderDate) rok, SUM(TotalDue) total
                   FROM Sales.SalesOrderHeader
                   GROUP BY CustomerID, YEAR(OrderDate))
SELECT klientID, ISNULL(p."2024", 0) "2024", ISNULL(p."2025", 0) "2025"
FROM clientSum PIVOT (
         SUM(total) FOR rok IN (
        "2024", "2025"
        )) AS p
ORDER BY klientID;

WITH clientClerkSum AS (SELECT SalesPersonID pracID, CustomerID klientID, YEAR(OrderDate) rok, SUM(TotalDue) total
                        FROM Sales.SalesOrderHeader
                        GROUP BY CustomerID, SalesPersonID, YEAR(OrderDate))
SELECT *
FROM clientClerkSum PIVOT (
         SUM(total) FOR rok IN (
        "2022", "2023", "2024", "2025"
        )
         ) AS p;

WITH clientSum AS (SELECT CustomerID, YEAR(OrderDate) rok, SUM(TotalDue) total
                   FROM Sales.SalesOrderHeader
                   GROUP BY CustomerID, YEAR(OrderDate))
SELECT CustomerID                                                                                 Klient,
       (SELECT total FROM clientSum cs2 WHERE cs1.CustomerID = cs2.CustomerID AND cs2.rok = 2022) "2022",
       (SELECT total FROM clientSum cs2 WHERE cs1.CustomerID = cs2.CustomerID AND cs2.rok = 2023) "2023",
       (SELECT total FROM clientSum cs2 WHERE cs1.CustomerID = cs2.CustomerID AND cs2.rok = 2024) "2024",
       (SELECT total FROM clientSum cs2 WHERE cs1.CustomerID = cs2.CustomerID AND cs2.rok = 2025) "2025"
FROM clientSum cs1;

SELECT CustomerID                                              Klient,
       SUM(CASE WHEN YEAR(OrderDate) = 2022 THEN 1 ELSE 0 END) "2022",
       SUM(CASE WHEN YEAR(OrderDate) = 2023 THEN 1 ELSE 0 END) "2023",
       SUM(CASE WHEN YEAR(OrderDate) = 2024 THEN 1 ELSE 0 END) "2024",
       SUM(CASE WHEN YEAR(OrderDate) = 2024 THEN 1 ELSE 0 END) "2025"
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY CustomerID;


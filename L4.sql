SELECT DISTINCT soh.SalesPersonID pracID,
                p.LastName + ', ' + p.FirstName                                               nazwisko,
                YEAR(soh.OrderDate)                                                           rokZam,
                SUM(soh.SubTotal) OVER (PARTITION BY soh.SalesPersonID, YEAR(soh.OrderDate))  Kwota,
                COUNT(*) OVER (PARTITION BY soh.SalesPersonID, YEAR(soh.OrderDate))           "Liczba zamóweń"
FROM Sales.SalesOrderHeader soh
         INNER JOIN Person.Person p ON soh.SalesPersonID = p.BusinessEntityID
WHERE soh.SalesPersonID IS NOT NULL
ORDER BY soh.SalesPersonID, rokZam;


WITH processed AS (SELECT SalesPersonID pracID,
                          FORMAT(OrderDate, 'yyyy-MM') "Miesiąc",
                          COUNT(*)                     "Liczba zamówień"

                   FROM Sales.SalesOrderHeader
                   WHERE SalesPersonID IS NOT NULL
                   GROUP BY SalesPersonID, FORMAT(OrderDate, 'yyyy-MM'))
SELECT *, ISNULL(SUM("Liczba zamówień") 
    OVER ( PARTITION BY pracID 
    ORDER BY "Miesiąc" ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING ) , 0) Dotychczas
FROM processed;


WITH clerks AS (SELECT s.Name                                                                           "Nazwa sklepu",
                       st.Name                                                                          "Terytorium",
                       st."Group"                                                                       "Grupa",
                       soh.TotalDue,
                       CAST(sp.BusinessEntityID AS varchar) + ' - ' + sp.LastName + ', ' + sp.FirstName "Sprzedawca"
                FROM Sales.SalesOrderHeader soh
                         INNER JOIN Sales.Customer c ON c.CustomerID = soh.CustomerID
                         INNER JOIN Sales.Store s ON s.BusinessEntityID = c.StoreID
                         INNER JOIN Sales.SalesTerritory st ON c.TerritoryID = st.TerritoryID
                         INNER JOIN Person.Person sp ON soh.SalesPersonID = sp.BusinessEntityID
                WHERE st.Name IN ('France', 'Germany'))
SELECT "Nazwa sklepu", Terytorium, Grupa, Sprzedawca, SUM(clerks.TotalDue) Kwota
FROM clerks
GROUP BY GROUPING SETS ( ("Nazwa sklepu"), ("Terytorium"), ("Grupa"), ("Sprzedawca") );


SELECT YEAR(OrderDate)                                        Rok,
       SUM(CASE WHEN MONTH(OrderDate) = 1 THEN 1 ELSE 0 END)  "1",
       SUM(CASE WHEN MONTH(OrderDate) = 2 THEN 1 ELSE 0 END)  "2",
       SUM(CASE WHEN MONTH(OrderDate) = 3 THEN 1 ELSE 0 END)  "3",
       SUM(CASE WHEN MONTH(OrderDate) = 4 THEN 1 ELSE 0 END)  "4",
       SUM(CASE WHEN MONTH(OrderDate) = 5 THEN 1 ELSE 0 END)  "5",
       SUM(CASE WHEN MONTH(OrderDate) = 6 THEN 1 ELSE 0 END)  "6",
       SUM(CASE WHEN MONTH(OrderDate) = 7 THEN 1 ELSE 0 END)  "7",
       SUM(CASE WHEN MONTH(OrderDate) = 8 THEN 1 ELSE 0 END)  "8",
       SUM(CASE WHEN MONTH(OrderDate) = 9 THEN 1 ELSE 0 END)  "9",
       SUM(CASE WHEN MONTH(OrderDate) = 10 THEN 1 ELSE 0 END) "10",
       SUM(CASE WHEN MONTH(OrderDate) = 11 THEN 1 ELSE 0 END) "11",
       SUM(CASE WHEN MONTH(OrderDate) = 12 THEN 1 ELSE 0 END) "12"
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY Rok;

WITH ranking AS (SELECT CustomerID                                                     klient,
                        SubTotal,
                        RANK() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC ) ord
                 FROM Sales.SalesOrderHeader)
SELECT *
FROM ranking PIVOT (
         MAX(SubTotal) FOR ord IN
        ("1", "2", "3")
         ) AS p;

WITH ranking AS (SELECT CustomerID,
                        RANK() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC ) ord,
                        'SO' + CAST(SalesOrderID AS varchar)                           num
                 FROM Sales.SalesOrderHeader)
SELECT r.CustomerID                    KlientID,
       p.LastName + ', ' + p.FirstName Osoba,
       "1",
       "2",
       "3",
       "4"
FROM ranking PIVOT (
         MAX(num) FOR ord IN
        ("1", "2", "3", "4")
         ) AS r
         LEFT JOIN Sales.Customer c ON r.CustomerID = c.CustomerID
         LEFT JOIN Person.Person p ON p.BusinessEntityID = c.PersonID;


WITH ranking AS (SELECT CustomerID,
                        RANK() OVER (PARTITION BY CustomerID ORDER BY OrderDate DESC ) ord,
                        'SO' + CAST(SalesOrderID AS varchar)                           num
                 FROM Sales.SalesOrderHeader)
SELECT r.CustomerID                            KlientId,
       p.LastName + ', ' + p.FirstName         Osoba,
       ISNULL("1", '') + ' ' + ISNULL("2", '') + ' ' + ISNULL("3", '') + ' ' + ISNULL("4", '') "Zamówienia"
FROM ranking PIVOT (
         MAX(num) FOR ord IN
        ("1", "2", "3", "4")
         ) AS r
         LEFT JOIN Sales.Customer c ON r.CustomerID = c.CustomerID
         LEFT JOIN Person.Person p ON p.BusinessEntityID = c.PersonID;

WITH orders AS (SELECT SalesPersonID, COUNT(*) liczba, FORMAT(OrderDate, 'yyyy-MM') data
                FROM Sales.SalesOrderHeader
                WHERE SalesPersonID IS NOT NULL
                GROUP BY SalesPersonID, FORMAT(OrderDate, 'yyyy-MM')),
     avgs AS (SELECT SalesPersonID, AVG(liczba) avrg
              FROM orders
              WHERE data <= '2025-02'
              GROUP BY SalesPersonID),
     marzec AS (SELECT SalesPersonID, liczba FROM orders WHERE data = '2025-03')
SELECT avgs.SalesPersonID             pracID,
       CAST(avrg AS DECIMAL(10, 1))   "Średnia do 2025-02",
       CAST(liczba AS DECIMAL(10, 1)) "2025-03"
FROM avgs
         INNER JOIN marzec ON avgs.SalesPersonID = marzec.SalesPersonID
WHERE avrg < liczba;


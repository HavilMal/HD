WITH firstYear AS (SELECT MIN(YEAR(OrderDate)) firstYear
                   FROM sales.salesorderheader)
SELECT salesorderid Identyfikator, YEAR(orderdate) Rok, totaldue Kwota
FROM sales.salesorderheader,
     firstYear
WHERE YEAR(orderdate) = firstYear.firstYear;

WITH nOrders AS (SELECT c.CustomerID,
                        (SELECT COUNT(*) FROM sales.salesorderheader oh WHERE c.CustomerID = oh.CustomerID) n
                 FROM sales.customer c),
     groups AS (SELECT *,
                       CASE
                           WHEN nOrders.n < 10 THEN '0-9'
                           WHEN nOrders.n < 20 THEN '10-19'
                           ELSE '20...' END Grupa
                FROM nOrders)
SELECT Grupa, COUNT(*) "Liczba klientów"
FROM groups
GROUP BY Grupa
ORDER BY "Liczba klientów" DESC;

SELECT sr.Name                                                                                               Czynnik,
       (SELECT COUNT(*) FROM sales.salesorderheadersalesreason oh WHERE sr.SalesReasonID = oh.SalesReasonID) Dotyczy
FROM sales.salesreason sr
ORDER BY Dotyczy DESC;

-- zadanie 1
SELECT SUM(SubTotal) suma, YEAR(OrderDate) rok, DATENAME(DW, OrderDate) dzien
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), DATENAME(DW, OrderDate);

-- zadanie 2
-- todo
select

-- zadanie 3
SELECT
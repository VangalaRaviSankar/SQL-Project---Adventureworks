show databases;
use adventureworks;
show tables;
/*
(1) What are the top 10 highest selling products in the database? 
(Hint - Use salesorderdetail as base table, LineTotal as Sales)
*/
select p.ProductID,p.Name,sum(sod.LineTotal) as TotalSales
from salesorderdetail sod
join product p ON sod.ProductID=p.ProductID
group by p.ProductID
order by TotalSales desc
limit 10;
/*
(2)	Who are the top 10 highest spending customers in the data along with their address and address type information? 
(Hint - Use salesorderheader as base table, TotalDue as sales)
*/
SELECT
    c.CustomerID,
    c.AccountNumber,
    CONCAT(co.FirstName, ' ', co.LastName) as CompanyName,
    a.AddressLine1,
    a.AddressLine2,
    a.City,
    sp.Name as StateProvince,
    a.PostalCode,
    at.Name as AddressType,
    SUM(soh.TotalDue) as TotalSpent
FROM
    salesorderheader soh
JOIN
    customer c ON soh.CustomerID = c.CustomerID
JOIN
    customeraddress ca ON c.CustomerID = ca.CustomerID
JOIN
    address a ON ca.AddressID = a.AddressID
JOIN
    stateprovince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN
    addresstype at ON at.AddressTypeID = 1
JOIN
    contact co ON c.CustomerID = co.ContactID
GROUP BY
    c.CustomerID, c.AccountNumber, CompanyName, a.AddressLine1, a.AddressLine2, a.City, StateProvince, a.PostalCode, AddressType
ORDER BY
    TotalSpent DESC
LIMIT 10;
/*
(3)	Calculate the Sales by Sales Reason Name and Reason Type. Also find the best and worst performing Sales Reason in terms of Sales 
(Hint - Use salesorderheader as base table, TotalDue as sales)
*/
SELECT
    sr.Name as SalesReasonName,
    sr.ReasonType,
    SUM(soh.TotalDue) as TotalSales
FROM
    salesorderheader soh
JOIN
    salesorderheadersalesreason sohsr ON soh.SalesOrderID = sohsr.SalesOrderID 
JOIN 
    salesreason sr ON sohsr.SalesReasonID = sr.SalesReasonID GROUP BY sr.Name, sr.ReasonType ORDER BY TotalSales DESC;
/*
(4)	Calculate the average number of orders shipped by different Ship methods for  each month and year 
(Hint - Use salesorderheader as base table, TotalDue as sales)
*/
SELECT
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    ShipMethodID,
    AVG(TotalDue) AS AverageTotalDue
FROM
    salesorderheader
GROUP BY
    OrderYear,
    OrderMonth,
    ShipMethodID
ORDER BY
    OrderYear,
    OrderMonth,
    ShipMethodID;
/*
(5)	Calculate the count of orders, maximum and minimum shipped by different Credit Card Type for each month and year 
(Hint - Use salesorderheader as base table, TotalDue as sales)
*/
SELECT
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    CreditCard.CardType AS CreditCardType,
    COUNT(*) AS OrderCount,
    MAX(TotalDue) AS MaximumTotalDue,
    MIN(TotalDue) AS MinimumTotalDue
FROM
    salesorderheader
INNER JOIN creditcard ON salesorderheader.CreditCardID = creditcard.CreditCardID
GROUP BY
    OrderYear,
    OrderMonth,
    CreditCardType
ORDER BY
    OrderYear,
    OrderMonth,
    CreditCardType;
/*
(6)	Which are the top 3 highest selling Sales Person by Territory for each month and year 
(Hint - Use salesorderheader as base table, TotalDue as sales)
*/
WITH RankedSales AS (
    SELECT
        YEAR(OrderDate) AS OrderYear,
        MONTH(OrderDate) AS OrderMonth,
        SalesPerson.SalesPersonID AS SalesPersonID,
        SalesTerritory.Name AS Territory,
        SUM(TotalDue) AS TotalSales,
        RANK() OVER (PARTITION BY YEAR(OrderDate), MONTH(OrderDate), SalesTerritory.Name ORDER BY SUM(TotalDue) DESC) AS SalesRank
    FROM
        salesorderheader
    INNER JOIN salesperson ON salesorderheader.SalesPersonID = salesperson.SalesPersonID
    INNER JOIN salesterritory ON salesperson.TerritoryID = salesterritory.TerritoryID
    GROUP BY
        OrderYear,
        OrderMonth,
        SalesPersonID,
        Territory
)
SELECT
    OrderYear,
    OrderMonth,
    Territory,
    SalesPersonID,
    TotalSales
FROM
    RankedSales
WHERE
    SalesRank <= 3
ORDER BY
    OrderYear,
    OrderMonth,
    Territory,
    SalesRank;
/*
(7)	Calculate the count of employees and average tenure per department name and department group name. 
(Hint - Use employee as base table, Tenure is calculated in days – from Hire date to today)
*/
SELECT
    D.Name AS DepartmentName,
    COUNT(E.EmployeeID) AS EmployeeCount,
    AVG(YEAR(NOW()) - YEAR(EDH.StartDate)) AS AverageTenure
FROM
    department AS D
INNER JOIN employeedepartmenthistory AS EDH ON D.DepartmentID = EDH.DepartmentID
INNER JOIN employee AS E ON EDH.EmployeeID = E.EmployeeID
GROUP BY
    D.Name
ORDER BY
    D.Name;
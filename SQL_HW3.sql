USE Northwind
GO
--1.List all cities that have both Employees and Customers.
SELECT DISTINCT c.City
FROM Customers c
WHERE c.City IN(
SELECT e.City
FROM Employees e)

--2.List all cities that have Customers but no Employee.
--a.Use sub-query
SELECT DISTINCT c.City
FROM Customers c
WHERE c.City NOT IN(
SELECT e.City
FROM Employees e)

--b.Do not use sub-query
SELECT DISTINCT c.City
FROM Customers c
LEFT JOIN Employees e ON c.City = e.City
WHERE e.city IS NULL

--3.List all products and their total order quantities throughout all orders.
SELECT p.ProductName, SUM(d.Quantity) AS 'Total Quantity'
FROM Products p LEFT JOIN [Order Details] d ON p.ProductID = d.ProductID
GROUP BY p.ProductName

--4.List all Customer Cities and total products ordered by that city.
SELECT c.City, SUM(d.Quantity) AS 'Total Quantity'
FROM Customers C LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN [Order Details] d ON o.OrderID = d.OrderID
GROUP BY c.City

--5.List all Customer Cities that have at least two customers.
--a.Use union
SELECT DISTINCT c.City
FROM Customers c
WHERE c.City IN(
SELECT c.City 
FROM Customers c 
GROUP BY c.City 
HAVING COUNT(c.CustomerID) = 2)
UNION
SELECT DISTINCT c.City
FROM Customers c
WHERE c.City IN(
SELECT c.City 
FROM Customers c 
GROUP BY c.City 
HAVING COUNT(c.CustomerID) > 2)

--b.Use sub-query and no union
SELECT DISTINCT c.City
FROM Customers c
WHERE c.City IN(
SELECT c.City 
FROM Customers c 
GROUP BY c.City 
HAVING COUNT(c.CustomerID) >= 2)

--6.List all Customer Cities that have ordered at least two different kinds 
--of products.
SELECT DISTINCT c.City
FROM Customers C LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN [Order Details] d ON o.OrderID = d.OrderID
GROUP BY c.City
HAVING COUNT(DISTINCT d.ProductID) >= 2

--7.List all Customers who have ordered products, but have the ‘ship city’ 
--on the order different from their own customer cities.
SELECT	DISTINCT c.CompanyName
FROM Customers C LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN [Order Details] d ON o.OrderID = d.OrderID
WHERE c.City <> o.ShipCity

--8.List 5 most popular products, their average price, and the customer city
--that ordered most quantity of it.
WITH ProductQuantities AS (
    SELECT d.ProductID, SUM(d.Quantity) AS TotalQuantity
    FROM [Order Details] d
    GROUP BY d.ProductID
),
RankedCities AS (
    SELECT d.ProductID, c.City, SUM(d.Quantity) AS CityQuantity,
        RANK() OVER (PARTITION BY d.ProductID ORDER BY SUM(d.Quantity) DESC) AS CityRank
    FROM ProductQuantities q
    LEFT JOIN [Order Details] d ON q.ProductID = d.ProductID
    LEFT JOIN Orders o ON d.OrderID = o.OrderID
    LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
    GROUP BY d.ProductID, c.City
),
ProductPrices AS (
    SELECT d.ProductID, AVG(d.UnitPrice) AS AveragePrice
    FROM [Order Details] d
    GROUP BY d.ProductID
)
SELECT TOP 5 q.ProductID, p.AveragePrice, r.City AS MostOrderedCity
FROM ProductQuantities q LEFT JOIN ProductPrices p ON q.ProductID = p.ProductID
LEFT JOIN RankedCities r ON q.ProductID = r.ProductID
WHERE r.CityRank = 1
ORDER BY q.TotalQuantity DESC

--9.List all cities that have never ordered something but we have employees 
--there.
--a.Use sub-query
SELECT e.City
FROM Employees e
WHERE e.City NOT IN(
SELECT o.ShipCity
FROM Orders o)

--b.Do not use sub-query
SELECT e.City
FROM Employees e LEFT JOIN Orders O ON e.City = o.ShipCity
WHERE o.ShipCity IS NULL

--10.List one city, if exists, that is the city from where the employee sold
--most orders (not the product quantity) is, and also the city of most total
--quantity of products ordered from. (tip: join  sub-query)
WITH EmployeeSales AS (
    SELECT 
        e.City AS EmployeeCity, 
        COUNT(o.OrderID) AS NumberOfOrders
    FROM Employees e
    JOIN Orders o ON e.EmployeeID = o.EmployeeID
    GROUP BY e.City
),
MaxEmployeeSales AS (
    SELECT TOP 1 
        EmployeeCity
    FROM EmployeeSales
    ORDER BY NumberOfOrders DESC
),
ProductQuantities AS (
    SELECT 
        o.ShipCity AS OrderCity, 
        SUM(od.Quantity) AS TotalQuantity
    FROM Orders o
    JOIN [Order Details] od ON o.OrderID = od.OrderID
    GROUP BY o.ShipCity
),
MaxProductQuantities AS (
    SELECT TOP 1 
        OrderCity
    FROM ProductQuantities
    ORDER BY TotalQuantity DESC
)
SELECT s.EmployeeCity
FROM MaxEmployeeSales s JOIN MaxProductQuantities p ON s.EmployeeCity = p.OrderCity
WHERE s.EmployeeCity = p.OrderCity

--11.How do you remove the duplicates record of a table?

-- Create a temporary table with distinct records
SELECT DISTINCT *
INTO TempTable
FROM OriginalTable;

-- Delete duplicate records from the original table
TRUNCATE TABLE OriginalTable

-- Insert distinct records back into the original table
INSERT INTO OriginalTable
SELECT * FROM TempTable

-- Drop the temporary table
DROP TABLE TempTable
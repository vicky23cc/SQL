USE AdventureWorks2022
GO
--1.How many products can you find in the Production.Product table?
SELECT DISTINCT COUNT(pp.Name) AS NumOfProduct
FROM Production.Product pp

--2.Write a query that retrieves the number of products in the 
--Production.Product table that are included in a subcategory. 
--The rows that have NULL in column ProductSubcategoryID are considered 
--to not be a part of any subcategory.
SELECT COUNT(ps.ProductCategoryID)
FROM Production.ProductSubcategory ps LEFT JOIN Production.Product pp 
ON ps.ProductSubcategoryID = pp.ProductSubcategoryID
WHERE ps.ProductSubcategoryID IS NOT NULL

--3.How many Products reside in each SubCategory? Write a query to display 
--the results with the following titles.
SELECT pp.ProductSubcategoryID, COUNT(pp.ProductID) AS CountedProducts
FROM Production.Product pp
WHERE pp.ProductSubcategoryID IS NOT NULL
GROUP BY pp.ProductSubcategoryID

--4.How many products that do not have a product subcategory.
SELECT COUNT(pp.ProductID) AS NumOfProduct
FROM Production.Product pp
WHERE pp.ProductSubcategoryID IS NULL

--5.Write a query to list the sum of products quantity in the 
--Production.ProductInventory table.
SELECT i.ProductID, SUM(i.Quantity)
FROM Production.ProductInventory i
GROUP BY i.ProductID

--6. Write a query to list the sum of products in the 
--Production.ProductInventory table and LocationID set to 40 and limit the 
--result to include just summarized quantities less than 100.
SELECT i.ProductID, SUM(i.Quantity) AS TheSum
FROM Production.ProductInventory i
WHERE i.LocationID = 40 
GROUP BY i.ProductID
HAVING SUM(i.Quantity) < 100

--7. Write a query to list the sum of products with the shelf information in
--the Production.ProductInventory table and LocationID set to 40 and limit 
--the result to include just summarized quantities less than 100
SELECT i.Shelf, i.ProductID, SUM(i.Quantity) AS TheSum
FROM Production.ProductInventory i
WHERE i.LocationID = 40 
GROUP BY i.ProductID, i.Shelf
HAVING SUM(i.Quantity) < 100

--8.Write the query to list the average quantity for products where column 
--LocationID has the value of 10 from the table Production.ProductInventory 
--table.
SELECT i.ProductID, AVG(i.Quantity) AS TheAvg
FROM Production.ProductInventory i
WHERE i.LocationID = 10
GROUP BY i.ProductID

--9.Write query to see the average quantity of products by shelf from the 
--table Production.ProductInventory
SELECT i.ProductID, i.Shelf, AVG(i.Quantity) AS TheAvg
FROM Production.ProductInventory i
GROUP BY i.ProductID, i.Shelf

--10.Write query to see the average quantity of products by shelf excluding 
--rows that has the value of N/A in the column Shelf from the table 
--Production.ProductInventory
SELECT i.ProductID, i.Shelf, AVG(i.Quantity) OVER (PARTITION BY i.Shelf) AS TheAvg
FROM Production.ProductInventory i
WHERE i.Shelf NOT IN ('N/A')

--11.List the members (rows) and average list price in the 
--Production.Product table. This should be grouped independently over the 
--Color and the Class column. Exclude the rows where Color or Class are null.
SELECT pp.Color, pp.Class, COUNT(pp.ProductID) AS TheCount, AVG(PP.ListPrice) AS AvgPrice
FROM Production.Product pp
WHERE pp.Color IS NOT NULL AND pp.Class IS NOT NULL
GROUP BY pp.Color, pp.Class

--12. Write a query that lists the country and province names from 
--person.CountryRegion and person. StateProvince tables. 
SELECT pc.Name AS Country, ps.Name AS Province
FROM Person.CountryRegion pc LEFT JOIN Person.StateProvince ps ON pc.CountryRegionCode = ps.CountryRegionCode

--13.Write a query that lists the country and province names from 
--person. CountryRegion and person. StateProvince tables and list the 
--countries filter them by Germany and Canada. 
SELECT pc.Name AS Country, ps.Name AS Province
FROM Person.CountryRegion pc LEFT JOIN Person.StateProvince ps ON pc.CountryRegionCode = ps.CountryRegionCode
WHERE pc.Name IN ('Germany', 'Canada')

USE Northwind
GO
--14.List all Products that has been sold at least once in last 26 years.
SELECT p.ProductID, p.ProductName
FROM Products p LEFT JOIN [Order Details] d ON p.ProductID = d.ProductID
LEFT JOIN Orders o ON d.OrderID = o.OrderID
WHERE (SELECT YEAR(GETDATE())) -  YEAR(o.OrderDate) <= 26

--15.List top 5 locations (Zip Code) where the products sold most.
SELECT Top 5 o.ShipPostalCode 
FROM Orders o
WHERE o.ShipPostalCode IS NOT NULL
GROUP BY o.ShipPostalCode 
ORDER BY COUNT(o.OrderID) DESC

--16.List top 5 locations (Zip Code) where the products sold most 
--in last 26 years.
SELECT Top 5 o.ShipPostalCode 
FROM Orders o
WHERE (SELECT YEAR(GETDATE())) -  YEAR(o.OrderDate) <= 26 AND o.ShipPostalCode IS NOT NULL
GROUP BY o.ShipPostalCode 
ORDER BY COUNT(o.OrderID) DESC

--17.List all city names and number of customers in that city.
SELECT c.City, COUNT(c.CustomerID) AS NumOfCustomer
FROM Customers c
GROUP BY c.City

--18.List city names which have more than 2 customers, and number of 
--customers in that city
SELECT c.City, COUNT(c.CustomerID) AS NumOfCustomer
FROM Customers c
GROUP BY c.City
HAVING COUNT(c.CustomerID) > 2

--19.List the names of customers who placed orders after 1/1/98 with order 
--date.
SELECT DISTINCT c.CompanyName
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate > '1998-01-01'

--20.List the names of all customers with most recent order dates
SELECT c.CompanyName, MAX(O.OrderDate)
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID 
GROUP BY c.CompanyName

--21.Display the names of all customers along with the count of products 
--they bought
SELECT c.CompanyName, SUM(d.Quantity) AS CountOfProducts
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN [Order Details] d ON o.OrderID = d.OrderID
GROUP BY c.CompanyName

--22.Display the customer ids who bought more than 100 Products with count 
--of products.
SELECT c.CustomerID, SUM(d.Quantity) AS CountOfProducts
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN [Order Details] d ON o.OrderID = d.OrderID
GROUP BY c.CustomerID
HAVING SUM(d.Quantity) > 100

--23.List all of the possible ways that suppliers can ship their products.
SELECT s.CompanyName AS 'Supplier Company Name', p.CompanyName AS 'Shipping Company Name'
FROM Suppliers s CROSS JOIN Shippers p

--24.Display the products order each day. Show Order date and Product Name.
SELECT o.OrderDate, p.ProductName
FROM Products p LEFT JOIN [Order Details] d ON p.ProductID = d.ProductID
LEFT JOIN Orders o ON d.OrderID = o.OrderID

--25.Displays pairs of employees who have the same job title.
SELECT e1.FirstName + e1.LastName AS 'Employee1 Name', e2.FirstName + e2.LastName AS 'Employee2 Name'
FROM Employees e1 INNER JOIN Employees e2 ON e1.Title = e2.Title
WHERE e1.FirstName + e1.LastName <> e2.FirstName + e2.LastName AND e1.EmployeeID < e2.EmployeeID

--26. Display all the Managers who have more than 2 employees reporting to 
--them.
SELECT m.FirstName + ' '+m.LastName AS Manager
FROM Employees e LEFT JOIN Employees m ON e.ReportsTo=m.EmployeeID
GROUP BY m.FirstName + ' '+m.LastName
HAVING COUNT(e.EmployeeID) > 2

--27.Display the customers and suppliers by city
SELECT c.City AS City, c.CompanyName AS Name, c.ContactName AS 'Contact Name', 'Customer' AS Type
FROM Customers c
UNION
SELECT s.City AS City, s.CompanyName AS Name, s.ContactName AS 'Contact Name', 'Supplier' AS Type
FROM Suppliers s
ORDER BY City, Name, 'Contact Name', Type
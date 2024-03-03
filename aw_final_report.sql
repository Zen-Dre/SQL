	-- Analysis of Adventure Works Database Using Basic to Advanced SQL Logic --  

-- Use Database.  
USE AdventureWorks2019; 

-- Show all tables and columns.  
SELECT 
	table_name, table_schema
FROM information_schema.tables 
WHERE table_type = 'BASE TABLE' 
ORDER BY TABLE_SCHEMA; 

SELECT * 
FROM INFORMATION_SCHEMA.TABLES; 

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME ASC; 

-- Count of tables.  
SELECT 
	COUNT(DISTINCT(table_name)) AS 'Number of Tables' 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'; 

-- Count of Columns.
SELECT 
	COUNT(DISTINCT(column_name)) AS 'Number of Columns' 
FROM INFORMATION_SCHEMA.COLUMNS; 

-- Find Distinct Schemas within database. 
SELECT 
	COUNT(DISTINCT(table_schema)) AS 'Number of Schemas', table_schema
FROM INFORMATION_SCHEMA.TABLES 
GROUP BY TABLE_SCHEMA
ORDER BY TABLE_SCHEMA DESC;

-- Search for null values. 
SELECT * 
FROM Sales.Customer
WHERE AccountNumber IS NULL;

SELECT *
FROM Production.Product
WHERE Color IS NULL; 

SELECT 
	COUNT(ProductID) AS 'Products with null color value'
FROM Production.Product
WHERE Color IS NULL; 

-- Search for duplicate values. 
SELECT 
	CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate, COUNT(*) AS '# of Duplicate Values'
FROM Sales.Customer
GROUP BY CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate
HAVING COUNT(*) > 1;

-- Search for duplicates using cte. 
WITH duplicate_values AS ( 
	SELECT 
		CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate, 
		ROW_NUMBER() OVER (PARTITION BY CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate	
		ORDER BY CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate) row_num
	FROM Sales.Customer 
)
SELECT * 
FROM duplicate_values 
WHERE row_num > 1; 

-- If duplicates are present delete duplicate values. 
WITH duplicate_values AS (
	SELECT 
		CustomerID, PersonID, StoreID, TerritoryID, AccountNumber, rowguid, ModifiedDate, 
		ROW_NUMBER() OVER(PARTITION BY CustomerID, PersonID, StoreID, TerritoryID ORDER BY CustomerID, PersonID, StoreID, TerritoryID) row_num
	FROM Sales.Customer
)
DELETE FROM duplicate_values 
WHERE row_num > 1; 

			-- Exploratory Data Analysis

-- Find number of columns within a table. 
SELECT 
	COUNT(*) AS 'Number of Columns' 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customer'; 

-- Find number of rows within a table. 
SELECT 
	COUNT(*) AS 'Number of Rows'
FROM Sales.Customer;  

-- How many stores are there and how many associates are accounted for ? 
SELECT 
	COUNT(Sales.Store.BusinessEntityID) AS 'Number of Stores', 
	COUNT(Sales.Store.SalesPersonID) AS 'Number of Store Associates'
FROM Sales.Store; 

-- Count of people.
SELECT 
	COUNT(DISTINCT(CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName))) AS 'Number of People' 
FROM Person.Person AS pp;

SELECT 
	DISTINCT(CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName)) AS 'Number of People' 
FROM Person.Person AS pp;

-- Count of Business entities 
SELECT 
	COUNT(BusinessEntityID) AS 'Count of Business EntityID' 
FROM Person.Person; 

-- Count of Sales persons 
SELECT 
	COUNT(SalesPersonID) AS 'Count of PersonID'
FROM Sales.Store; 

-- Number of people by person type. 
SELECT 
	COUNT(DISTINCT(CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName))) AS 'Number of People', 
	pp.PersonType AS 'Person Type'
FROM Person.Person AS pp
GROUP BY pp.PersonType
ORDER BY 'Number of People' DESC; 

-- How many territories across various continents and countries are accounted for ? 
SELECT 
	COUNT(Sales.SalesTerritory.TerritoryID) AS 'Number of Territories', 
	Sales.SalesTerritory.[Group], Sales.SalesTerritory.CountryRegionCode
FROM Sales.SalesTerritory
GROUP BY Sales.SalesTerritory.[Group], Sales.SalesTerritory.CountryRegionCode 
ORDER BY 'Number of Territories' DESC;

		-- Business Questions 

	-- HR & Sales Analysis

-- Query listing all business names.
SELECT 
	DISTINCT(ss.Name) AS 'Business Name'
FROM Sales.Store AS ss; 

-- Count of all businesses 
SELECT	
	COUNT(DISTINCT(ss.Name)) AS 'Number of Businesses'
FROM Sales.Store AS ss; 

-- List of people by person type.
SELECT 
	pp.BusinessEntityID AS 'Business_ID', pp.PersonType AS 'Person Type', 
	pp.FirstName AS First_Name, pp.LastName AS Last_Name 
FROM Person.Person AS pp
ORDER BY 'Last_Name', 'First_Name'; 

-- Where is each person located ? 
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName) AS 'Full Name',
	pa.AddressLine1, pa.City, psp.Name AS 'Locale'
FROM Person.Address AS pa
INNER JOIN Person.StateProvince AS psp ON pa.StateProvinceID = psp.StateProvinceID
INNER JOIN Person.BusinessEntityAddress AS pbea ON pa.AddressID = pbea.AddressID 
INNER JOIN Person.Person AS pp ON pbea.BusinessEntityID = pp.BusinessEntityID 
ORDER BY 'Locale'; 

-- What is the count of people by city and state ? 
SELECT 
	COUNT(CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName)) AS 'Number of People', 
	pa.City AS 'City', psp.Name AS 'State'
FROM Person.Address AS pa 
INNER JOIN Person.StateProvince AS psp ON pa.StateProvinceID = psp.StateProvinceID 
INNER JOIN Person.BusinessEntityAddress AS pbea ON pa.AddressID = pbea.AddressID 
INNER JOIN Person.Person AS pp ON pbea.BusinessEntityID = pp.BusinessEntityID
GROUP BY pa.City, psp.Name 
ORDER BY 'Number of People' DESC;

-- Which businesses has each employee worked with ? 
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName,', ',pp.MiddleName) AS 'Employee Name', 
	hre.JobTitle AS 'Position', 
	ss.Name AS 'Business Name'
FROM Person.Person AS pp 
INNER JOIN Sales.SalesPerson AS ssp ON pp.BusinessEntityID = ssp.BusinessEntityID
INNER JOIN Sales.Store AS ss ON ssp.BusinessEntityID = ss.SalesPersonID
INNER JOIN HumanResources.Employee AS hre ON pp.BusinessEntityID = hre.BusinessEntityID
ORDER BY 'Employee Name'; 

-- List employees and their job title.
SELECT 
	DISTINCT(CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName)) AS 'Employee Full Name', 
	hre.JobTitle 
FROM HumanResources.Employee AS hre
INNER JOIN Person.Person AS pp ON hre.BusinessEntityID = pp.BusinessEntityID
ORDER BY hre.JobTitle; 

-- How many employees are paid at each specified pay rate ?  
SELECT 
	COUNT(CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName)) AS 'Number of Employees', 
	TRY_CAST(ROUND(hrep.rate, 2, 1) AS Decimal (10, 2)) AS 'Hourly Wage'
FROM Person.Person AS pp 
INNER JOIN HumanResources.EmployeePayHistory AS hrep ON pp.BusinessEntityID = hrep.BusinessEntityID
GROUP BY hrep.Rate
HAVING COUNT(CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName)) > 0
ORDER BY 'Number of Employees' DESC; 

-- How many employee are paid ate each specified pay rate by position ? 
SELECT	
	COUNT(CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName)) AS 'Number of Employees', 
	hre.JobTitle AS 'Position', 
	TRY_CAST(ROUND(hrep.rate, 2, 1) AS decimal (10, 2)) AS 'Hourly Wage'
FROM Person.Person AS pp 
INNER JOIN HumanResources.EmployeePayHistory AS hrep ON pp.BusinessEntityID = hrep.BusinessEntityID
INNER JOIN HumanResources.Employee AS hre ON hre.BusinessEntityID = pp.BusinessEntityID
GROUP BY hrep.Rate, hre.JobTitle
HAVING COUNT(CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName)) > 0
ORDER BY 'Number of Employees' DESC;  

-- Where is each employee located ? 
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName) AS 'Employee Full Name', 
	pa.City AS 'City', psp.Name AS 'State/Province'
FROM Person.Person AS pp 
INNER JOIN HumanResources.Employee AS hre ON pp.BusinessEntityID = hre.BusinessEntityID
INNER JOIN Person.BusinessEntityAddress AS pbea ON hre.BusinessEntityID = pbea.BusinessEntityID
INNER JOIN Person.Address AS pa ON pbea.AddressID = pa.AddressID
INNER JOIN Person.StateProvince AS psp ON pa.StateProvinceID = psp.StateProvinceID; 

-- How many employees are based in each specified locality ? 
SELECT		
	COUNT(CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName)) AS 'Number of Employees', 
	pa.City AS 'City', psp.Name AS 'State/Province'
FROM Person.Person AS pp 
INNER JOIN HumanResources.Employee AS hre ON pp.BusinessEntityID = hre.BusinessEntityID 
INNER JOIN Person.BusinessEntityAddress AS pbea ON hre.BusinessEntityID = pbea.BusinessEntityID 
INNER JOIN Person.Address AS pa ON pbea.AddressID = pa.AddressID 
INNER JOIN Person.StateProvince AS psp ON pa.StateProvinceID = psp.StateProvinceID
GROUP BY pa.City, psp.Name
ORDER BY 'Number of Employees' DESC; 

-- What is the annual employee salary by department, positon sex and hire date ? 
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName) AS 'Full Name', 
	hrd.Name AS 'Department', hre.JobTitle AS 'Position', YEAR(hre.HireDate) AS 'Date Hired', 
	hre.Gender AS 'Sex', ROUND((2080*hreph.Rate), 0) AS 'Annual Salary' 
FROM Person.Person AS pp 
INNER JOIN HumanResources.Employee AS hre ON pp.BusinessEntityID = hre.BusinessEntityID
INNER JOIN HumanResources.EmployeePayHistory AS hreph ON pp.BusinessEntityID = hreph.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory AS hredh ON hreph.BusinessEntityID = hredh.BusinessEntityID
INNER JOIN HumanResources.Department AS hrd ON hredh.DepartmentID = hrd.DepartmentID
ORDER BY 'Department', 'Position', 'Annual Salary', 'Date Hired' DESC; 

-- Yearly PayRoll.  
WITH cte AS (
SELECT 
	DISTINCT(DATEPART(yyyy, hrep.ModifiedDate)) AS 'Year', hrep.ModifiedDate
FROM HumanResources.EmployeePayHistory AS hrep
) 
SELECT 
	ISNULL(TRY_CAST(cte.[Year] AS VARCHAR(15)), 'Total Employee Payroll') AS 'Year', 
	TRY_CAST(SUM(ROUND(2080*hrep.Rate, 2, 1)) AS decimal (10, 0)) AS 'Annual Payroll'
FROM HumanResources.EmployeePayHistory AS hrep
INNER JOIN cte ON hrep.ModifiedDate = cte.ModifiedDate
GROUP BY ROLLUP (cte.[Year]); 

-- Avg Yearly Salary.  
SELECT 
	TRY_CAST(AVG(ROUND(2080*hrep.Rate, 2, 1)) AS decimal (10, 0)) AS 'Avg Annual Salary'
FROM HumanResources.EmployeePayHistory AS hrep; 

-- Query statement finding which employee profiles are active or inactive. 
WITH emp_status AS (
SELECT
	hredh.BusinessEntityID, CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName) AS 'Employee Name',
	hredh.StartDate, hredh.EndDate, 
		CASE
			WHEN hredh.EndDate > hredh.StartDate THEN 'Inactive'
		ELSE 'Active'
END 'Employment Status' 
FROM HumanResources.EmployeeDepartmentHistory AS hredh
INNER JOIN Person.Person AS pp ON hredh.BusinessEntityID = pp.BusinessEntityID
) 
SELECT * 
FROM emp_status; 

-- Inactive employees.  
WITH emp_status AS (
	SELECT 
		hredh.BusinessEntityID, CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName) AS 'Employee Name', 
		hredh.StartDate, hredh.EndDate, IIF(hredh.EndDate > hredh.StartDate, 'Inactive', 'Active') AS 'Employment Status'
	FROM HumanResources.EmployeeDepartmentHistory AS Hredh 
	INNER JOIN Person.Person AS pp ON hredh.BusinessEntityID = pp.BusinessEntityID
) 
SELECT * 
FROM emp_status
WHERE [Employment Status] = 'Inactive'; 

-- Number of employees per working shift. 
SELECT 
	COUNT(hredh.BusinessEntityID) AS 'Number of Employees', hredh.ShiftID AS 'Shift'
FROM HumanResources.EmployeeDepartmentHistory AS hredh
GROUP BY hredh.ShiftID
ORDER BY 'Number of Employees' DESC; 

-- Distribution of employees working per department and shift. 
SELECT 
	hrd.Name AS 'Department', COUNT(hredh.BusinessEntityID) AS 'Number of Employees', 
	hredh.ShiftID AS 'Shift'
FROM HumanResources.EmployeeDepartmentHistory AS hredh
INNER JOIN HumanResources.Department AS hrd ON hredh.DepartmentID = hrd.DepartmentID
GROUP BY hredh.ShiftID, hrd.Name
ORDER BY 'Shift'; 

-- How many days did an employee work prior to the termination of their employment ?  
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName) AS 'Full Name', hrd.Name AS 'Department', hre.JobTitle AS 'Position', 
	hredh.StartDate, hredh.EndDate, DATEDIFF(DAY, hredh.StartDate, hredh.EndDate) AS 'Days of Employment', 
	IIF(hredh.EndDate > hredh.StartDate, 'Inactive', 'Active') AS 'Employment Status'
FROM HumanResources.EmployeeDepartmentHistory AS hredh
INNER JOIN Person.Person AS pp ON hredh.BusinessEntityID = pp.BusinessEntityID
INNER JOIN HumanResources.Employee AS hre ON pp.BusinessEntityID = hre.BusinessEntityID
INNER JOIN HumanResources.Department AS hrd ON hredh.DepartmentID = hrd.DepartmentID
WHERE EndDate IS NOT NULL
ORDER BY 'Days of Employment' DESC; 

-- Years of employment before termination. 
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName) AS 'Full Name', hrd.Name AS 'Department', 
	hre.JobTitle AS 'Position', hredh.StartDate, hredh.EndDate, 
	DATEDIFF(YEAR, hredh.StartDate, hredh.EndDate) AS 'Years of Employment'
FROM HumanResources.EmployeeDepartmentHistory AS hredh
INNER JOIN Person.Person AS pp ON hredh.BusinessEntityID = pp.BusinessEntityID
INNER JOIN HumanResources.Employee AS hre ON pp.BusinessEntityID = hre.BusinessEntityID
INNER JOIN HumanResources.Department AS hrd ON hredh.DepartmentID = hrd.DepartmentID
WHERE EndDate IS NOT NULL
ORDER BY 'Years of Employment' DESC; 

-- Which employee has the longest tenure ? 
WITH cte AS ( 
SELECT 
	TRY_CAST(GETDATE() AS DATE) AS 'Current Date', pp.BusinessEntityID
FROM Person.Person AS pp 
)
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName) AS 'Employee Name', 
	hredh.StartDate, DATEDIFF(YEAR, hredh.StartDate, cte.[Current Date]) AS 'Years of Employment' 
FROM Person.Person AS pp 
INNER JOIN HumanResources.EmployeeDepartmentHistory AS hredh ON pp.BusinessEntityID = hredh.BusinessEntityID 
INNER JOIN cte ON pp.BusinessEntityID = cte.[BusinessEntityID]
ORDER BY 'Years of Employment' DESC; 

-- Aggregate the number of employees per department. 
SELECT 
	hrd.Name AS 'Department', hre.JobTitle AS 'Position', 
	COUNT(hre.BusinessEntityID) AS 'Number of Employees'
FROM HumanResources.Department AS hrd
INNER JOIN HumanResources.EmployeeDepartmentHistory AS hredh ON hrd.DepartmentID = hredh.DepartmentID
INNER JOIN HumanResources.EmployeePayHistory AS hreph ON hredh.BusinessEntityID = hreph.BusinessEntityID
INNER JOIN HumanResources.Employee AS hre ON hreph.BusinessEntityID = hre.BusinessEntityID
GROUP BY hrd.Name, hre.JobTitle
ORDER BY 'Number of Employees' DESC; 

-- What is the total Number of Production Employees ? 
SELECT
	COUNT(hre.BusinessEntityID) AS 'Number of Production Employees' 
FROM HumanResources.Department AS hrd 
INNER JOIN HumanResources.EmployeeDepartmentHistory AS hredh ON hrd.DepartmentID = hredh.DepartmentID
INNER JOIN HumanResources.EmployeePayHistory AS hreph ON hredh.BusinessEntityID = hreph.BusinessEntityID
INNER JOIN HumanResources.Employee AS hre ON hreph.BusinessEntityID = hre.BusinessEntityID
WHERE hre.JobTitle LIKE '%Production%'; 

-- Which employees have the highest annual salary. 
SELECT 
	TOP 5 CONCAT(pp.FirstName, ', ', pp.LastName, ' ', pp.MiddleName) AS 'Full Name', 
	hrd.Name AS 'Department', hre.JobTitle AS 'Position', hre.HireDate AS 'Date Hired', hre.Gender AS 'Sex', 
	ROUND(((48*52)*hreph.Rate), 0) AS 'Annual Salary'
FROM Person.Person AS pp 
INNER JOIN HumanResources.Employee AS hre ON pp.BusinessEntityID = hre.BusinessEntityID
INNER JOIN HumanResources.EmployeePayHistory AS hreph ON pp.BusinessEntityID = hreph.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory AS hredh ON hreph.BusinessEntityID = hredh.BusinessEntityID 
INNER JOIN HumanResources.Department AS hrd ON hredh.DepartmentID = hrd.DepartmentID 
ORDER BY 'Annual Salary' DESC; 

-- Aggregate vacation and sick leave hours for employees per position.
SELECT 
	hre.JobTitle AS 'Position', SUM(hre.VacationHours) AS 'Total Vacation Hours', 
	SUM(hre.SickLeaveHours) AS 'Total Sick Leave Hours', AVG(hre.VacationHours) AS 'Average Vacation Hours', AVG(hre.SickLeaveHours) AS 'Average Sick Leave Hours' 
FROM HumanResources.Employee AS hre
GROUP BY hre.JobTitle; 

-- Employee Sales and Sales Commission.
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName) AS 'Employee Name', 
 	TRY_CAST(ROUND(ssp.SalesYTD, 2, 1) AS Decimal (10, 0)) AS 'SalesYTD',
	TRY_CAST(ROUND(ssp.SalesLastYear, 2, 1) AS Decimal (10, 0)) AS 'Previous Yr Sales', 
	TRY_CAST(SUM(ROUND(ssp.SalesYTD*ssp.CommissionPct, 2, 1)) AS Decimal (10, 0)) AS 'SalesYTD Commission'
FROM Person.Person AS pp
INNER JOIN Sales.SalesPerson AS ssp ON pp.BusinessEntityID = ssp.BusinessEntityID
GROUP BY pp.FirstName, pp.LastName, pp.MiddleName, ssp.SalesYTD, ssp.SalesLastYear
ORDER BY 'SalesYTD Commission' DESC; 

-- Annual Employee Sales and Sales Commission.
WITH cte AS (
	SELECT 
		DISTINCT(DATEPART(YYYY, sod.ModifiedDate)) AS 'Year', sod.ModifiedDate
	FROM Sales.SalesOrderDetail AS sod
)
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName) AS 'Employee Name', hre.JobTitle, cte.[Year], 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.Unitprice, 2, 1)) AS decimal (10, 0)) AS 'Sales Amount', 
	TRY_CAST(ROUND(ssp.SalesYTD, 2, 1) AS Decimal (10, 0)) AS 'SalesYTD',
	TRY_CAST(ROUND(ssp.SalesLastYear, 2, 1) AS Decimal (10, 0)) AS 'Previous Yr Sales', 
	TRY_CAST(SUM(ROUND(ssp.SalesYTD*ssp.CommissionPct, 2, 1)) AS decimal (10, 0)) AS 'SalesYTD Commission'
FROM Person.Person AS pp 
INNER JOIN Sales.SalesPerson AS ssp ON pp.BusinessEntityID = ssp.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader AS soh ON ssp.TerritoryID = soh.TerritoryID
INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN HumanResources.Employee AS hre ON pp.BusinessEntityID = hre.BusinessEntityID
INNER JOIN cte ON sod.ModifiedDate = cte.[ModifiedDate]
GROUP BY pp.FirstName, pp.LastName, pp.MiddleName, hre.JobTitle, cte.[Year], ssp.SalesYTD, ssp.SalesLastYear
ORDER BY cte.[Year], 'Sales Amount' DESC; 

-- Which employees earned the highest bonuses ? 
WITH cte AS (
	SELECT 
		DISTINCT(DATEPART(yyyy, ssp.ModifiedDate)) AS 'Year', ssp.ModifiedDate
	FROM Sales.SalesPerson AS ssp
)
SELECT 
	TOP 10 CONCAT(pp.FirstName,' ', pp.LastName,', ', pp.MiddleName) AS 'Employee Name', cte.[Year], 
	ssp.Bonus AS 'Employee Bonus'
FROM Person.Person AS pp 
INNER JOIN Sales.SalesPerson AS ssp ON pp.BusinessEntityID = ssp.BusinessEntityID
INNER JOIN cte ON ssp.ModifiedDate = cte.[ModifiedDate]
ORDER BY 'Employee Bonus' DESC; 

-- Which employee earned the highest sales commission ? 
SELECT 
	TOP 5 CONCAT(pp.FirstName,' ', pp.LastName) AS 'Employee Name', 
	TRY_CAST(SUM(ROUND(ssp.SalesYTD*ssp.CommissionPct, 2, 1)) AS decimal (10, 0)) AS 'SalesYTD Commission'
FROM Sales.SalesPerson AS ssp
INNER JOIN Person.Person AS pp ON ssp.BusinessEntityID = pp.BusinessEntityID
GROUP BY pp.FirstName, pp.LastName
ORDER BY 'SalesYTD Commission' DESC; 

SELECT 
	TOP 5 CONCAT(pp.FirstName,' ', pp.LastName) AS 'Employee Name', 
	TRY_CAST(SUM(ROUND(((sod.OrderQty*sod.UnitPrice)* ssp.CommissionPct), 2, 1)) AS decimal (10, 0)) AS 'Sales Commission'
FROM Sales.SalesPerson AS ssp
INNER JOIN Person.Person AS pp ON ssp.BusinessEntityID = pp.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader AS soh ON ssp.TerritoryID = soh.TerritoryID
INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY pp.FirstName, pp.LastName
ORDER BY 'Sales Commission' DESC; 

-- Find avg employee salary by sex
SELECT 
	DISTINCT(hre.Gender) AS 'Sex', 
	TRY_CAST(AVG(ROUND((40*52)*hreph.Rate, 2)) AS Decimal (10, 0)) AS 'Avg Salary By Sex'
FROM Person.Person AS pp 
INNER JOIN HumanResources.Employee AS hre ON pp.BusinessEntityID = hre.BusinessEntityID 
INNER JOIN HumanResources.EmployeePayHistory AS hreph ON pp.BusinessEntityID = hreph.BusinessEntityID
GROUP BY 
GROUPING SETS (hre.Gender)
ORDER BY 'Avg Salary By Sex' DESC; 

-- Query sales schema for employees along with their sales history. 
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName) AS 'Full Name', hrd.Name AS 'Department', 
	hre.JobTitle AS 'Position', ROUND((ssp.SalesYTD), 0) AS 'SalesYTD', 
	ROUND((ssp.SalesLastYear), 0) AS 'Previous Yr Sales'
FROM Person.Person AS pp 
INNER JOIN Sales.SalesPerson AS ssp ON pp.BusinessEntityID = ssp.BusinessEntityID
INNER JOIN HumanResources.Employee AS hre ON ssp.BusinessEntityID = hre.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory AS hredh ON hre.BusinessEntityID = hredh.BusinessEntityID
INNER JOIN HumanResources.Department AS hrd ON hredh.DepartmentID = hrd.DepartmentID
ORDER BY 'SalesYTD' DESC; 

SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName) AS 'Full Name', hrd.Name AS 'Department', hre.JobTitle AS 'Position', 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.Unitprice, 2, 1)) AS decimal (10, 0)) AS 'Sales Amount'
FROM Person.Person AS pp
INNER JOIN Sales.SalesPerson AS ssp ON pp.BusinessEntityID = ssp.BusinessEntityID
INNER JOIN HumanResources.Employee AS hre ON ssp.BusinessEntityID = hre.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory aS hredh ON hre.BusinessEntityID = hredh.BusinessEntityID
INNER JOIN HumanResources.Department AS hrd ON hredh.DepartmentID = hrd.DepartmentID 
INNER JOIN Sales.SalesOrderHeader AS soh ON ssp.TerritoryID = soh.TerritoryID
INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY pp.FirstName, pp.LastName, hrd.Name, hre.JobTitle
ORDER BY 'Sales Amount' DESC; 

-- Which Sales Representatives generated the highest sales amount ? 
SELECT 
	TOP 5 CONCAT(pp.FirstName,' ', pp.LastName) AS 'Full Name', hrd.Name AS 'Department', hre.JobTitle AS 'Position', 
	TRY_CAST(ROUND(ssp.SalesLastYear, 2, 1) AS Decimal (10, 0)) 'Previous Yr Sales',
	TRY_CAST(ROUND(ssp.SalesYTD, 2, 1) AS Decimal (10, 0)) 'SalesYTD', 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.Unitprice, 2, 1)) AS Decimal (10, 0)) AS 'Sales Amount'
FROM Person.Person AS pp 
INNER JOIN Sales.SalesPerson AS ssp ON pp.BusinessEntityID = ssp.BusinessEntityID
INNER JOIN HumanResources.Employee AS hre ON ssp.BusinessEntityID = hre.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory AS hredh ON hre.BusinessEntityID = hredh.BusinessEntityID
INNER JOIN HumanResources.Department AS hrd ON hredh.DepartmentID = hrd.DepartmentID
INNER JOIN Sales.SalesOrderHeader AS soh ON ssp.TerritoryID = soh.TerritoryID
INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY pp.FirstName, pp.LastName, hrd.Name, hre.JobTitle, ssp.SalesYTD, ssp.SalesLastYear
HAVING hre.JobTitle = 'Sales Representative' 
ORDER BY 'Sales Amount' DESC; 

-- What is the sales commission for the specified sales employee ? 
SELECT 
	TRY_CAST(SUM(ROUND(ssp.SalesYTD*ssp.CommissionPct, 2, 1)) AS decimal (10, 0)) AS 'SalesYTD Commission'
FROM Sales.SalesPerson AS ssp
INNER JOIN Person.Person AS pp ON ssp.BusinessEntityID = pp.BusinessEntityID
WhERE pp.LastName = 'Mitchell' AND pp.FirstName = 'Linda'; 

-- Which Sales Manager generated the highest previous yr sales and salesytd ? 
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName) AS 'Full Name', hrd.Name AS 'Department', hre.JobTitle AS 'Position', 
	TRY_CAST(ROUND(ssp.SalesLastYear, 2, 1) AS Decimal (10, 0)) AS 'Previous Yr Sales',
	TRY_CAST(ROUND(ssp.SalesYTD, 2, 1) AS decimal (10, 0)) AS 'SalesYTD'
FROM Person.Person AS pp 
INNER JOIN Sales.SalesPerson AS ssp ON pp.BusinessEntityID = ssp.BusinessEntityID
INNER JOIN HumanResources.Employee AS hre ON ssp.BusinessEntityID = hre.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory AS hredh ON hre.BusinessEntityID = hredh.BusinessEntityID
INNER JOIN HumanResources.Department AS hrd ON hredh.DepartmentID = hrd.DepartmentID
WHERE hre.JobTitle LIKE '%Sales Manager'
ORDER BY 'SalesYTD' DESC; 

-- Business Sales Quota By Quarter 
SELECT 
	CONCAT(pp.FirstName,' ', pp.LastName) AS 'Sales Person', 
	DATEPART(YEAR, spq.QuotaDate) AS 'Year', 
	DATEPART(QUARTER,spq.QuotaDate) AS 'Business Quarter', 
	TRY_CAST(ROUND(spq.SalesQuota, 2, 1) AS Decimal (10, 0)) AS 'Sales Quota', 
	spq.SalesQuota - FIRST_VALUE(spq.SalesQuota)
		OVER (PARTITION BY CONCAT(pp.FirstName,' ', pp.LastName), DATEPART(YEAR, spq.QuotaDate) ORDER BY DATEPART(QUARTER, spq.QuotaDate)) AS 'Difference From 1st Quarter', 
	spq.SalesQuota - LAST_VALUE(spq.SalesQuota)
		OVER (PARTITION BY CONCAT(pp.FirstName,' ',pp.LastName), DATEPART(YEAR, spq.QuotaDate) ORDER BY DATEPART(QUARTER, spq.QuotaDate)
		RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS 'Difference From Previous Quarter'
FROM Sales.SalesPersonQuotaHistory as spq
INNER JOIN Sales.SalesPerson AS ssp ON spq.BusinessEntityID = ssp.BusinessEntityID
INNER JOIN Person.Person AS pp ON spq.BusinessEntityID = pp.BusinessEntityID
ORDER BY 'Year', 'Business Quarter'; 

-- What is the tax rate for each location ? 
SELECT 
	psp.Name AS 'Locale', sst.TaxType, sst.TaxRate
FROM Sales.SalesTaxRate AS sst 
INNER JOIN Person.StateProvince AS psp ON sst.StateProvinceID = psp.StateProvinceID; 

-- What is the tax rate for each state in the U.S ? 
SELECT 
	psp.Name AS 'State', sst.TaxType, sst.TaxRate
FROM Sales.SalesTaxRate AS sst 
INNER JOIN Person.StateProvince AS psp ON sst.StateProvinceID = psp.StateProvinceID
WHERE psp.CountryRegionCode = 'US';

-- What is the avg taxes per sales and total taxes paid overall ? 
SELECT 
	TRY_CAST(AVG(ROUND(soh.TaxAmt, 2, 1)) AS decimal (10, 0)) AS 'Avg Tax Amount Per Sale', 
	TRY_CAST(SUM(ROUND(soh.TaxAmt, 2, 1)) AS decimal (10, 0)) AS 'Total Taxes Paid'
FROM Sales.SalesOrderHeader AS soh; 

-- What is the avg taxes paid per product ? 
SELECT 
	DISTINCT(pp.Name) AS Product, 
	TRY_CAST(AVG(ROUND(soh.TaxAmt, 2, 1)) AS Decimal (10, 0)) AS 'Tax Per Product'
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS pp ON sod.ProductID = pp.ProductID
GROUP BY pp.Name
ORDER BY 'Tax Per Product' DESC; 

-- What is the avg freight amount per sale and total amount paid for freight ? 
SELECT 
	TRY_CAST(AVG(ROUND(soh.Freight, 2, 1)) AS decimal (10, 0)) AS 'Avg Freight Per Sale', 
	TRY_CAST(SUM(ROUND(soh.Freight, 2, 1)) AS decimal (10, 0)) AS 'Total Freight Amount'
FROM Sales.SalesOrderHeader AS soh; 

-- Avg freight amount per product. 
SELECT	
	DISTINCT(pp.Name) AS 'Product', 
	TRY_CAST(AVG(ROUND(soh.Freight, 2, 1)) AS decimal (10, 0)) AS 'Avg Freight Per Product'
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS pp ON sod.ProductID = pp.ProductID
GROUP BY pp.Name 
ORDER BY 'Avg Freight per Product' DESC; 

-- What is the average order processing and shipping time per order ? 
SELECT 
	AVG(DATEDIFF(DAY, soh.OrderDate, soh.ShipDate)) AS 'Avg Order Processing Time', 
	AVG(DATEDIFF(DAY, soh.shipDate, soh.DueDate)) AS 'Avg Shipping Time'
FROM Sales.SalesOrderHeader AS soh; 

-- What is the average order processing and shipping time by continent ? 
SELECT 
	sst.[Group] AS 'Continent', 
	AVG(DATEDIFF(DAY, soh.OrderDate, soh.ShipDate)) AS 'Avg Order Processing Time', 
	AVG(DATEDIFF(DAY, soh.shipDate, soh.DueDate)) AS 'Avg Shipping Time'
FROM Sales.SalesTerritory AS sst
INNER JOIN Sales.SalesOrderHeader AS soh ON sst.TerritoryID = soh.TerritoryID
GROUP BY sst.[Group]; 

	-- full-text search/ Sentiment Analysis 

-- How many reviews were left by customers ? 
SELECT 
	COUNT(ppr.ProductReviewID) AS 'Number of Customer Reviews'
FROM Production.ProductReview AS ppr; 

-- Which reviewers left a negative comment about a product ? 
SELECT
	pp.Name AS 'Product', ppr.ReviewerName, ppr.EmailAddress, ppr.Comments 
FROM Production.ProductReview AS ppr
INNER JOIN Production.Product AS pp ON ppr.ProductID = pp.ProductID
WHERE CONTAINS (ppr.Comments, 'terrible'); 

-- Which reviewers left a positive comment about a product ? 
SELECT
	pp.Name AS 'Product', ppr.ReviewerName, ppr.EmailAddress, ppr.Comments 
FROM Production.ProductReview AS ppr 
INNER JOIN Production.Product AS pp ON ppr.ProductID = pp.ProductID
WHERE FREETEXT (ppr.Comments, 'quality OR praises OR never had a problem'); 

	-- Product/Vendor Sales Analysis 

-- What products are being sold ? 
SELECT 
	pp.Name AS 'Product'
FROM Production.Product AS pp;

-- What is the total number of products ? 
SELECT 
	COUNT(Production.Product.ProductID) AS 'Number of Products'
FROM Production.Product;

-- Who are the product vendors ? 
SELECT 
	pv.Name AS 'Product Vendor'
FROM Purchasing.Vendor AS pv; 

-- How many vendors are there ? 
SELECT 
	COUNT(DISTINCT(pv.Name)) AS 'Number of Vendors' 
FROM Purchasing.Vendor AS pv; 

-- Which products does each vendor sell ? 
SELECT 
	pv.Name AS 'Vendor', pp.Name AS 'Product', ppc.Name AS 'Category'
FROM Production.Product AS pp 
INNER JOIN Purchasing.ProductVendor AS ppv ON pp.ProductID = ppv.ProductID
INNER JOIN Production.ProductSubcategory AS pps ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS ppc ON pps.ProductCategoryID = ppc.ProductCategoryID
INNER JOIN Purchasing.Vendor AS pv ON ppv.BusinessEntityID = pv.BusinessEntityID
GROUP BY pv.Name, ppc.Name, pp.Name
ORDER BY 'Category'; 

-- Count of Products sold by category. 
SELECT 
	ppc.Name AS 'Category', COUNT(ppp.ProductID) AS 'Number of Products' 
FROM Production.Product AS ppp 
INNER JOIN Production.ProductSubcategory AS pps ON ppp.ProductSubcategoryID = pps.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS ppc ON pps.ProductCategoryID = ppc.ProductCategoryID
GROUP BY ppc.Name
ORDER BY 'Number of Products' DESC; 

-- Number of Products in inventory ? 
SELECT 
	pp.Name AS 'Product Name',  
	SUM(ppi.Quantity) AS 'Quantity'
FROM Production.Product AS pp 
INNER JOIN Production.ProductInventory AS ppi ON pp.ProductID = ppi.ProductID
GROUP BY pp.Name
ORDER BY 'Quantity' DESC;  

--  What is the Quantity of Products in inventory across category and color ? 
SELECT
	pp.Name AS 'Product', ppc.Name AS 'Category', 
	ISNULL(pp.Color, 'N/A') AS 'Color', ppi.Quantity
FROM Production.Product AS pp 
INNER JOIN Production.ProductInventory AS ppi ON pp.ProductID = ppi.ProductID
INNER JOIN Production.ProductSubcategory AS pps ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS ppc ON pps.ProductCategoryID = ppc.ProductCategoryID
ORDER BY 'Category', ppi.Quantity DESC; 

-- Total Sales Amount. 
SELECT
	TRY_CAST(SUM(ROUND(ssp.SalesYTD, 2, 1)) AS decimal (10, 0)) AS 'Total SalesYTD', 
	TRY_CAST(SUM(ROUND(ssp.SalesLastYear, 2, 1)) AS decimal (10, 0)) AS 'Total Previous Yr Sales'
FROM Sales.SalesPerson AS ssp
ORDER BY 'Total SalesYTD', 'Total Previous Yr Sales'; 

-- Total Sales Amount By Continent and Country. 
SELECT 
	stt.[Group] AS 'Continent', stt.CountryRegionCode AS 'Country', 
	ROUND(SUM(stt.SalesYTD), 0) AS 'SalesYTD', 
	ROUND(SUM(stt.SalesLastYear), 0) AS 'Previous Yr Sales'
FROM Sales.SalesTerritory AS stt
GROUP BY stt.[Group], stt.CountryRegionCode
ORDER BY 'SalesYTD' DESC; 

SELECT 
	stt.[Group] AS 'Contitent', stt.CountryRegionCode AS 'Country', 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.UnitPrice, 2, 1)) AS decimal (10, 0)) AS 'Sales Amount' 
FROM Sales.SalesTerritory AS stt 
INNER JOIN Sales.SalesOrderHeader AS soh ON stt.TerritoryID = soh.TerritoryID
INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderDetailID
GROUP BY stt.[Group], stt.CountryRegionCode 
ORDER BY 'Sales Amount' DESC; 

-- Total Sales Amount By City and State. 
SELECT 
	ISNULL(psp.Name, 'Total Sales') AS 'State', ISNULL(pa.City, 'State Total') AS 'City', 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.UnitPrice, 2, 1)) AS Decimal (15, 0)) AS 'Sales Amount'
FROM Sales.SalesOrderDetail AS sod 
INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID 
INNER JOIN Person.StateProvince AS psp ON soh.TerritoryID = psp.TerritoryID
INNER JOIN Person.Address AS pa ON psp.StateProvinceID = pa.StateProvinceID
INNER JOIN Sales.SalesTaxRate AS sstr ON pa.StateProvinceID = sstr.StateProvinceID
GROUP BY ROLLUP (psp.Name, pa.City); 

-- Total Sales Amount By City and State filtered by taxrate. 
SELECT	
	ISNULL(psp.Name, 'All States') AS 'State', 
	ISNULL(pa.City, 'Sales Total') AS 'City', sstr.TaxRate, 
	ROUND(SUM(sod.OrderQty*sod.UnitPrice), 0) AS 'Sales Amount'
FROM Sales.SalesOrderDetail AS sod 
INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID 
INNER JOIN Person.StateProvince AS psp ON soh.TerritoryID = psp.TerritoryID
INNER JOIN Person.Address AS pa ON psp.StateProvinceID = pa.StateProvinceID
INNER JOIN Sales.SalesTaxRate AS sstr ON pa.StateProvinceID = sstr.StateProvinceID
GROUP BY ROLLUP (psp.Name, pa.City, sstr.TaxRate) 
HAVING sstr.TaxRate < 7
ORDER BY 'Sales Amount' DESC; 

-- Avg Sales Amount. 
SELECT
	TRY_CAST(ROUND(AVG(sod.OrderQty*sod.UnitPrice), 2, 1) AS decimal (10, 0)) AS 'Sales Amount'
FROM Sales.SalesOrderDetail AS sod 
INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID 
INNER JOIN Person.StateProvince AS psp ON soh.TerritoryID = psp.TerritoryID
INNER JOIN Person.Address AS pa ON psp.StateProvinceID = pa.StateProvinceID
INNER JOIN Sales.SalesTaxRate AS sstr ON pa.StateProvinceID = sstr.StateProvinceID; 

-- Total Sales Amount By Store. 
SELECT 
	ss.Name AS 'Business Name', 
	SUM(sod.OrderQty) AS 'Sales Volume', 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.UnitPrice, 2, 1)) AS Decimal (10, 0)) AS 'Sales Amount' 
FROM Sales.Store AS ss 
INNER JOIN Sales.SalesOrderHeader AS soh ON ss.SalesPersonID = soh.SalesPersonID
INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY
GROUPING SETS (ss.name)
ORDER BY 'Sales Amount' DESC; 

-- Total Sales Amount By Category. 
SELECT 
	ppc.Name AS 'Category', 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.UnitPrice, 2, 1)) AS Decimal (10, 0)) AS 'Sales Amount' 
FROM Sales.SalesOrderDetail AS sod 
INNER JOIN Production.Product AS pp ON sod.ProductID = pp.ProductID 
INNER JOIN Production.ProductSubCategory AS pps ON pp.ProductSubCategoryID = pps.ProductSubCategoryID 
INNER JOIN Production.ProductCategory AS ppc ON pps.ProductCategoryID = ppc.ProductCategoryID
GROUP BY ppc.Name 
ORDER BY 'Sales Amount' DESC; 

-- Total Sales Amount Per Year By Category and SubCategory. 
WITH cte AS ( 
	SELECT 
		DISTINCT(DATEPART(YYYY, sod.ModifiedDate)) AS 'Year', sod.ModifiedDate
	FROM Sales.SalesOrderDetail AS sod
)
SELECT 
	ISNULL(ppc.Name, 'All Categories') AS 'Category', ISNULL(pps.Name, 'Category Total') AS 'Sub Category', 
	ISNULL(TRY_CAST(cte.[Year] AS varchar(25)), 'Sub-Category Total') AS 'Year', 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.UnitPrice, 2, 1)) AS Decimal (10, 0)) AS 'Sales Amount'
FROM Sales.SalesOrderDetail AS sod 
INNER JOIN Production.Product AS pp ON sod.ProductID = pp.ProductID 
INNER JOIN Production.ProductSubCategory AS pps ON pp.ProductSubCategoryID = pps.ProductSubCategoryID 
INNER JOIN Production.ProductCategory AS ppc ON pps.ProductCategoryID = ppc.ProductCategoryID
INNER JOIN cte ON sod.ModifiedDate = cte.[ModifiedDate]
GROUP BY ROLLUP (ppc.Name, pps.Name, cte.[Year]); 
 
-- Total Sales Amount By customer. 
SELECT 
	soh.CustomerID AS 'Customer ID', 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.Unitprice, 2, 1)) AS Decimal (10, 0)) AS 'Sales Amount' 
FROM Sales.Store AS ss 
INNER JOIN Sales.SalesOrderHeader AS soh ON ss.SalesPersonID = soh.SalesPersonID
INNER JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.CustomerID 
ORDER BY 'Sales Amount' DESC;   

-- Total Sales Volume and Sales Amount By Product.  
SELECT 
	pp.Name AS 'Product', ROUND(SUM(sod.OrderQty), 0) AS 'Sales Volume',  
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.UnitPrice, 2, 1)) AS numeric (10, 0)) AS 'Total Sales Amount'
FROM Production.Product AS pp 
INNER JOIN Sales.SalesOrderDetail AS sod ON pp.ProductID = sod.ProductID
GROUP BY pp.Name
ORDER BY 'Total Sales Amount' DESC; 

-- Find top 10 selling products. 
SELECT 
	TOP 10 pp.Name AS 'Product', ppc.Name AS 'Category', pps.Name AS 'Sub Category', 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.UnitPrice, 2, 1)) AS Numeric (10, 0)) AS 'Total Sales Amount'
FROM Production.Product AS pp 
INNER JOIN Sales.SalesOrderDetail AS sod ON pp.ProductID = sod.ProductID
INNER JOIN Production.ProductSubcategory AS pps ON pp.ProductSubcategoryID = pps.ProductCategoryID
INNER JOIN Production.ProductCategory AS ppc ON pps.ProductCategoryID = ppc.ProductCategoryID
GROUP BY pp.Name, pps.Name, ppc.Name
ORDER BY 'Total Sales Amount' DESC; 

-- Find sales amount per product category. 
SELECT 
	ppc.Name AS 'Category', 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.UnitPrice, 2, 1)) AS Decimal (10, 0)) AS 'Total Sales Amount' 
FROM Production.Product AS pp 
INNER JOIN Production.ProductSubcategory AS pps ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS ppc ON pps.ProductCategoryID = ppc.ProductCategoryID
INNER JOIN Sales.SalesOrderDetail AS sod ON pp.ProductID = sod.ProductID
GROUP BY 
GROUPING SETS (ppc.Name)
ORDER BY 'Total Sales Amount' DESC; 

-- Find sales amount per product sub category. 
SELECT 
	pps.Name AS 'Sub Category', 
	TRY_CAST(SUM(ROUND(sod.OrderQty*sod.UnitPrice, 2, 1)) AS decimal (10, 0)) AS 'Total Sales Amount'
FROM Production.Product AS pp 
INNER JOIN Production.ProductSubcategory AS pps ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS ppc ON pps.ProductCategoryID = ppc.ProductCategoryID
INNER JOIN Sales.SalesOrderDetail AS sod ON pp.ProductID = sod.ProductID
GROUP BY
GROUPING SETS (pps.Name)
ORDER BY 'Total Sales Amount' DESC; 

-- Sales Volume Per Product and Product Category. 
SELECT 
	pp.Name AS 'Product Name', ppc.Name AS 'Category', pps.Name AS 'Sub Category', 
	COUNT(sod.OrderQty) AS 'Quantity'
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS pp ON sod.ProductID = pp.ProductID
INNER JOIN Production.ProductSubcategory AS pps ON pp.ProductSubcategoryID = pps.ProductSubcategoryID 
INNER JOIN Production.ProductCategory AS ppc ON pp.ProductSubcategoryID = ppc.ProductCategoryID
GROUP BY ppc.Name, pps.Name, pp.Name, sod.ProductID 
ORDER BY 'Category', 'Sub Category', 'Quantity' DESC;  

-- Top Selling Products By Sales Volume.  
SELECT 
	ISNULL(ppc.Name, 'All Categories') AS 'Category', 
	ISNULL(pp.Name, 'Category Total') AS 'Product', 
	COUNT(sod.OrderQty) AS 'Sales Volume'
FROM Sales.SalesOrderDetail AS sod 
INNER JOIN Production.Product AS pp ON sod.ProductID = pp.ProductID 
INNER JOIN Production.ProductSubcategory AS pps ON pp.ProductSubcategoryID = pps.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS ppc ON pp.ProductSubcategoryID = ppc.ProductCategoryID
GROUP BY ROLLUP (ppc.Name, pp.Name); 

-- Sales Volume By Year. 
WITH cte AS (
SELECT 
	DATEPART(yyyy, ModifiedDate) AS 'Year', ModifiedDate
FROM Sales.SalesOrderDetail 
GROUP By DATEPART(yyyy, ModifiedDate), ModifiedDate
) 
SELECT 
	cte.[Year], 
	CAST(SUM(ROUND(sod.OrderQTY, 2, 1)) AS decimal (10, 0)) AS 'Sales Volume'
FROM cte
INNER JOIN Sales.SalesOrderDetail AS sod ON cte.ModifiedDate = sod.ModifiedDate
GROUP BY cte.[Year]
ORDER BY 'Sales Volume' DESC; 

-- Avg Sales Volume per Year. 
WITH cte AS (
SELECT 
	DATEPART(yyyy, ModifiedDate) AS 'Year', ModifiedDate
FROM Sales.SalesOrderDetail
GROUP BY DATEPART(yyyy, ModifiedDate), ModifiedDAte
) 
SELECT 
	ISNULL(cte.[Year], 'Yearly Avg') AS 'Year', 
	AVG(sod.OrderQty) AS 'Avg Yearly Sales Volume' 
FROM cte
INNER JOIN Sales.SalesOrderDetail AS sod ON cte.ModifiedDate = sod.ModifiedDate 
GROUP BY ROLLUP (cte.[Year]); 

-- Sales Amount per year. 
WITH cte AS ( 
	SELECT 
		DATEPART(yyyy, ModifiedDate) AS 'Year', ModifiedDate
	FROM Sales.SalesOrderDetail 
	GROUP BY DATEPART(YYYY, ModifiedDate), ModifiedDate
) 
SELECT 
	cte.[Year], 
	CAST(SUM(ROUND(sod.OrderQty*sod.UnitPrice, 2, 1)) AS decimal (10, 0)) AS 'Sales Amount' 
FROM cte
INNER JOIN Sales.SalesOrderDetail AS sod ON cte.ModifiedDate = sod.ModifiedDate
GROUP BY cte.[Year]
ORDER BY 'Sales Amount' DESC; 

-- Sales Avg Sales Amount By Year. 
WITH cte AS (
SELECT 
	DATEPART(yyyy, ModifiedDate) AS 'Year', ModifiedDate
FROM Sales.SalesOrderDetail 
GROUP BY DATEPART(yyyy, ModifiedDate), ModifiedDate
)
SELECT 
	cte.[Year], 
	TRY_CAST(AVG(ROUND(sod.OrderQty*sod.UnitPrice, 2, 1)) AS Decimal (10, 0)) AS 'Avg Sales Amount By Year'
FROM cte
INNER JOIN Sales.SalesOrderDetail AS sod ON cte.ModifiedDate = sod.ModifiedDate 
GROUP BY cte.[Year]
ORDER BY 'Avg Sales Amount By Year' DESC; 

-- What is the sales amount generated by each vendor ? 
SELECT 
	pv.Name AS 'Vendor Name', 
	TRY_CAST(SUM(ROUND(ppoh.TotalDue, 2, 1)) AS Decimal (10, 0)) AS 'Vendor Sales'
FROM Purchasing.Vendor AS pv
INNER JOIN Purchasing.ProductVendor AS ppv ON pv.BusinessEntityID = ppv.BusinessEntityID
INNER JOIN Purchasing.PurchaseOrderDetail AS ppod ON ppv.ProductID = ppod.ProductID
INNER JOIN Purchasing.PurchaseOrderHeader AS ppoh ON ppod.PurchaseOrderID = ppoh.PurchaseOrderID
GROUP BY pv.Name
ORDER BY 'Vendor Sales' DESC; 

-- Who are the top n vendors by sales amount ? 
SELECT 
	TOP 5 pv.Name AS 'Vendor Name', 
	TRY_CAST(SUM(ROUND(ppoh.TotalDue, 2, 1)) AS decimal (10, 0)) AS 'Vendor Sales' 
FROM Purchasing.Vendor AS pv 
INNER JOIN Purchasing.ProductVendor AS ppv ON pv.BusinessEntityID = ppv.BusinessEntityID
INNER JOIN Purchasing.PurchaseOrderDetail AS ppod ON ppv.ProductID = ppod.ProductID
INNER JOIN Purchasing.PurchaseOrderHeader AS ppoh ON ppod.PurchaseOrderID = ppoh.PurchaseOrderID
GROUP BY pv.Name 
ORDER BY 'Vendor Sales' DESC; 


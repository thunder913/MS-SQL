--2

USE SoftUni

SELECT * FROM Departments

--3

SELECT Name FROM Departments

--4

SELECT FirstName, LastName, Salary FROM Employees

--5

SELECT FirstName, MiddleName, LastName FROM Employees

--6

SELECT FirstName + '.' + LastName + '@softuni.bg' AS 'Full Email Address' FROM Employees

--7

SELECT DISTINCT Salary FROM Employees

--8

SELECT * FROM Employees e
	WHERE e.JobTitle = 'Sales Representative'

--9

SELECT FirstName, LastName, JobTitle FROM Employees e
	WHERE e.Salary >= 20000 AND e.Salary <= 30000

--10

SELECT FirstName+' '+MiddleName+' '+LastName AS 'Full Name' FROM Employees e
	WHERE e.Salary IN (25000, 14000, 12500, 23600)

--11

SELECT FirstName, LastName FROM Employees e
	WHERE E.ManagerID IS NULL

--12

SELECT FirstName, LastName, Salary FROM Employees e
	WHERE e.Salary > 50000
	ORDER BY e.Salary DESC

--13

SELECT TOP(5) FirstName, LastName FROM Employees e
	ORDER BY e.Salary DESC

--14

SELECT FirstName, LastName FROM Employees e
	WHERE e.DepartmentID != 4

--15

SELECT * FROM Employees e
	ORDER BY e.Salary DESC, e.FirstName, e.LastName DESC, e.MiddleName
	
--16

CREATE VIEW V_EmployeesSalaries AS
SELECT FirstName, LastName, Salary FROM Employees

SELECT * FROM V_EmployeesSalaries

--17

CREATE VIEW V_EmployeeNameJobTitle AS
SELECT FirstName +' '+ ISNULL(MiddleName, '')+ ' ' + LastName AS 'Full Name', JobTitle FROM Employees

--18

SELECT DISTINCT JobTitle FROM Employees

--19

SELECT TOP(10) * FROM Projects p
	ORDER BY p.StartDate ASC, p.Name

--20

SELECT TOP(7) FirstName, LastName, HireDate FROM Employees e
	ORDER BY e.HireDate DESC

--21
UPDATE Employees 
	SET Salary*=1.12
	FROM Employees e
		JOIN Departments d ON e.DepartmentID = d.DepartmentID
	WHERE D.Name IN ('Engineering', 'Tool Design', 'Marketing', 'Information Services')
SELECT Salary FROM Employees

--22

USE Geography

SELECT PeakName FROM Peaks p
	ORDER BY p.PeakName

--23

SELECT TOP(30) CountryName, Population FROM Countries c
	WHERE c.ContinentCode = 'EU'
	ORDER BY c.Population DESC
	
--24

SELECT CountryName, CountryCode, 
	CASE 
		WHEN CurrencyCode='EUR' THEN 'Euro'
		ELSE 'Not Euro'
		END AS Currency
	FROM Countries co
	ORDER BY co.CountryName

--25

USE Diablo

SELECT Name FROM Characters c
	ORDER BY c.Name
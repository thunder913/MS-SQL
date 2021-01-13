USE SOFTUNI

--1

SELECT FirstName, LastName FROM Employees E
	WHERE E.FirstName LIKE 'SA%'

--2

SELECT FirstName, LastName FROM Employees E
	WHERE E.LastName LIKE '%EI%'

--3

SELECT FirstName FROM Employees E
	WHERE E.DepartmentID IN(3,10) AND E.HireDate BETWEEN '1995' AND '2005' 

--4

SELECT FirstName, LastName FROM Employees E
	WHERE E.JobTitle NOT LIKE '%ENGINEER%'

--5

SELECT Name FROM Towns T
	WHERE LEN(T.Name) IN (5,6)
	ORDER BY T.Name

--6

SELECT TownID, Name FROM Towns T
	WHERE LEFT(T.Name, 1) IN ('M','K','B','E')
	ORDER BY T.Name

--7

SELECT TownID, Name FROM Towns T
	WHERE LEFT(T.Name,1) NOT IN ('R','B','D')
	ORDER BY Name

--8

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName FROM Employees E
	WHERE YEAR(E.HireDate) > 2000

--9

SELECT FirstName,LastName FROM Employees E
	WHERE LEN(E.LastName) = 5

--10

SELECT EmployeeID, FirstName, LastName, Salary, DENSE_RANK() OVER (PARTITION BY E.Salary ORDER BY E.EmployeeID) AS 'Rank' FROM Employees E
	WHERE E.Salary BETWEEN 10000 AND 50000 
	ORDER BY Salary DESC
	
--11


SELECT * FROM(
	SELECT EmployeeID, FirstName, LastName, Salary, DENSE_RANK() OVER (PARTITION BY E.Salary ORDER BY E.EmployeeID) 'Rank' FROM Employees E
	WHERE E.Salary BETWEEN 10000 AND 50000) T1
	WHERE T1.Rank = 2
	ORDER BY T1.Salary DESC

--12

USE Geography

SELECT CountryName, IsoCode FROM Countries C
	WHERE C.CountryName LIKE '%A%A%A%'
	ORDER BY C.IsoCode

--13

SELECT P.PeakName, R.RiverName, LOWER(CONCAT(P.PeakName,R.RiverName)) 'Mix' FROM Peaks P
	JOIN Rivers R ON RIGHT(P.PeakName,1) = LEFT(R.RiverName,1)
	ORDER BY Mix

--14

USE Diablo

SELECT G.Name, FORMAT(G.Start, 'yyyy-MM-dd') 'Start' FROM Games G
	WHERE YEAR(G.Start) IN (2011,2012)
	ORDER BY G.Start, G.Name

--15

SELECT Username, RIGHT(Email , LEN(Email) - CHARINDEX('@', Email)) 'Email Provider' FROM Users
	ORDER BY [Email Provider]

--16

SELECT Username, IpAddress FROM Users
	WHERE IpAddress LIKE '___.1%.%.___'
	ORDER BY Username

--17

SELECT Name, 
	CASE
		WHEN DATEPART(HOUR, Start)<12 THEN 'Morning'
		WHEN DATEPART(HOUR, Start) < 18 THEN 'Afternoon'
		WHEN DATEPART(HOUR, Start) < 24 THEN 'Evening'
		END 'Part of the Day',
	CASE
		WHEN Duration <= 3 THEN 'Extra Short'
		WHEN Duration <= 6 THEN 'Short'
		WHEN Duration > 6 THEN 'Long'
		WHEN Duration IS NULL THEN 'Extra Long'
		END 'Duration'
	FROM Games G
		ORDER BY G.Name, Duration, [Part of the Day]


--18
USE ORDERs

SELECT ProductName, OrderDate, DATEADD(DAY, 3, OrderDate) 'Pay Due', DATEADD(MONTH,1,OrderDate) 'Deliver Due' FROM Orders

--19

CREATE TABLE People(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(50),
	BirthDate DATETIME2
)

INSERT INTO People(Name, BirthDate)
VALUES
('Victor',	'2000-12-07 00:00:00.000'),
('Steven',	'1992-09-10 00:00:00.000'),
('Stephen',	'1910-09-19 00:00:00.000'),
('John',	'2010-01-06 00:00:00.000')


SELECT Name, DATEDIFF(YEAR, BirthDate, GETDATE()) 'Age in Years', DATEDIFF(MONTH, BirthDate, GETDATE()) 'Age in Months', 
			DATEDIFF(DAY, BirthDate, GETDATE()) 'Age in Days', DATEDIFF(MINUTE, BirthDate, GETDATE()) 'Age in Minutes'
			FROM People
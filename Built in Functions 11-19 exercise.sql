
SELECT * FROM
	(SELECT  EmployeeID,
		FirstName,
		LastName,
		Salary,
		DENSE_RANK() OVER (PARTITION BY SALARY ORDER BY EMPLOYEEID) AS Rank FROM Employees
		WHERE SALARY BETWEEN 10000 AND 50000) AS TEMP
		WHERE [RANK] = 2
		ORDER BY SALARY DESC


USE Geography

SELECT CountryName, IsoCode FROM Countries
	WHERE CountryName LIKE '%A%A%A%'
	ORDER BY IsoCode

SELECT PeakName, RiverName, LOWER(LEFT(PEAKNAME,LEN(PEAKNAME)-1)+RIVERNAME) AS Mix FROM Peaks
	INNER JOIN Rivers ON LEFT(RiverName,1) = RIGHT(PeakName,1)
	ORDER BY Mix


USE Diablo

SELECT TOP(50) Name, FORMAT( Start, 'yyyy-MM-dd') AS [Start] FROM Games 
	WHERE YEAR(START) BETWEEN 2011 AND 2012
	ORDER BY Start, Name

SELECT Username, RIGHT(EMAIL, LEN(EMAIL) - CHARINDEX('@', Email)) AS [Email Provider] FROM Users
	ORDER BY [Email Provider],Username

SELECT Username, IpAddress FROM USERS
	WHERE IpAddress LIKE '___.1%.%.___' 
	ORDER BY Username

SELECT Name, 
		CASE 
			WHEN DATEPART(HOUR,Start) < 12 THEN 'Morning' 
			WHEN DATEPART(HOUR, Start) < 18 THEN 'Afternoon' 
			WHEN DATEPART(HOUR, Start) < 24 THEN 'Evening' 
				END AS 'Part of the Day',
		CASE
			WHEN DURATION <= 3 THEN 'Extra Short'
			WHEN DURATION <=6 THEN 'Short'
			WHEN DURATION > 6 THEN 'Long'
			WHEN DURATION IS NULL THEN 'Extra Long'
				END AS 'Duration'
	FROM Games
	ORDER BY [NAME], [Duration], [Part of the Day]


CREATE TABLE Orders
(
	Id INT IDENTITY,
	ProductName NVARCHAR(30),
	OrderDate DATETIME2
);

SELECT ProductName, OrderDate, DATEADD(DAY, 3, OrderDate) AS 'Pay Due', DATEADD(MONTH,1,OrderDate) AS 'Deliver Due' FROM Orders


CREATE TABLE People
(
	Id INT IDENTITY,
	Name NVARCHAR(30),
	BirthDate DATETIME2
)

INSERT INTO People(NAME,BirthDate)
VALUES 
	('Victor', '2000-12-07 00:00:00.000'),
	('Steven',	'1992-09-10 00:00:00.000'), 
	('Stephen', '1910-09-19 00:00:00.000'),
	('John','2010-01-06 00:00:00.000');
	 

SELECT Name,
	DATEDIFF(YEAR, BirthDate, GETDATE()) AS 'Age In Years',
	DATEDIFF(MONTH, BirthDate, GETDATE()) AS 'Age In Months',
	DATEDIFF(DAY, BirthDate, GETDATE()) AS 'Age In Days',
	DATEDIFF(MINUTE, BirthDate, GETDATE()) AS 'Age In Minutes'
	FROM People

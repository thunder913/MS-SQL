USE SoftUni
--1
SELECT TOP(5) E.EmployeeID,E.JobTitle, E.AddressID, A.AddressText FROM Employees AS e
	INNER JOIN Addresses a ON E.AddressID = a.AddressID
	ORDER BY E.AddressID 
--2
SELECT TOP(50) E.FirstName,E.LastName, T.Name AS Town,  A.AddressText FROM Employees AS e
	INNER JOIN Addresses a ON E.AddressID = a.AddressID
	INNER JOIN Towns t ON T.TownID = a.TownID
	ORDER BY e.FirstName, e.LastName
--3
SELECT e.EmployeeID, e.FirstName,e.LastName, d.[Name] FROM Employees E
	INNER JOIN Departments D ON D.DepartmentID = E.DepartmentID
	WHERE D.Name = 'Sales'
	ORDER BY EmployeeID
--4
SELECT TOP(5) E.EmployeeID, E.FirstName,E.Salary,D.Name AS 'DepartmentName' FROM Employees E
	JOIN Departments D ON D.DepartmentID = E.DepartmentID
	WHERE Salary >15000
	ORDER BY E.DepartmentID

--5
SELECT TOP(3) E.EmployeeID, E.FirstName FROM EmployeesProjects EP
	RIGHT JOIN Employees E ON E.EmployeeID = EP.EmployeeID
	WHERE EP.EmployeeID IS NULL
	ORDER BY E.EmployeeID

--6
SELECT e.FirstName, e.LastName, e.HireDate, d.Name as 'DeptName' FROM Employees E
	INNER JOIN Departments D ON D.DepartmentID = E.DepartmentID
	WHERE E.HireDate > '1999-1-1'
	AND (D.Name = 'Sales' OR D.Name = 'Finance')
	ORDER BY E.HireDate

--7
SELECT TOP(5) E.EmployeeID, E.FirstName, P.Name FROM EmployeesProjects DP
	INNER JOIN Projects P ON P.ProjectID = DP.ProjectID
	INNER JOIN Employees E ON E.EmployeeID = DP.EmployeeID
	WHERE P.StartDate > '2002-8-12' AND EndDate IS NULL
	ORDER BY E.EmployeeID
--8
SELECT E.EmployeeID,E.FirstName,
CASE 
	WHEN P.StartDate >= '2005' THEN NULL
    ELSE P.[Name]
	END AS 'ProjectName' FROM EmployeesProjects EP
	INNER JOIN Employees E ON E.EmployeeID = EP.EmployeeID
	INNER JOIN Projects P ON P.ProjectID = EP.ProjectID
	WHERE E.EmployeeID = 24

--9
SELECT E.EmployeeID, E.FirstName, E.ManagerID, M.FirstName AS 'ManagerName' FROM Employees E
	INNER JOIN Employees M ON M.EmployeeID = E.ManagerID
	WHERE E.ManagerID = 3 OR E.ManagerID = 7
	ORDER BY E.EmployeeID

--10

SELECT TOP(50) E.EmployeeID, (E.FirstName + ' ' +E.LastName) AS 'EmployeeName', (M.FirstName + ' ' + M.LastName) AS 'ManagerName', D.Name AS 'DepartmentName' FROM Employees E
	JOIN Employees M ON M.EmployeeID = E.ManagerID
	JOIN Departments D ON D.DepartmentID = E.DepartmentID
	ORDER BY E.EmployeeID

--11
SELECT MIN(X) FROM
(SELECT AVG(E.SALARY) as x FROM Employees E
	GROUP BY E.DepartmentID) AS temp

--12
USE Geography

SELECT MC.CountryCode, M.MountainRange, P.PeakName, P.Elevation FROM Peaks P
	JOIN Mountains M ON M.Id = P.MountainId
	JOIN MountainsCountries MC ON MC.MountainId = M.Id
	WHERE P.Elevation > 2835 AND MC.CountryCode = 'BG'
	ORDER BY P.Elevation DESC

--13

SELECT MC.CountryCode, COUNT(*) FROM MountainsCountries MC
	JOIN Countries C ON C.CountryCode = MC.CountryCode
	WHERE C.CountryName IN ('United States', 'Russia', 'Bulgaria')
	GROUP BY MC.CountryCode

--14
SELECT TOP(5) C.CountryName, R.RiverName FROM CountriesRivers CR
	RIGHT JOIN Countries C ON C.CountryCode = CR.CountryCode
	LEFT JOIN Rivers R ON R.Id = CR.RiverId
	LEFT JOIN Continents CNT ON CNT.ContinentCode = C.ContinentCode
	WHERE CNT.ContinentName = 'Africa'
	ORDER BY C.CountryName

--15

SELECT ContinentCode, MAX(CNT) AS MAXVALUE INTO NewTable FROM(
SELECT C1.ContinentCode, C1.CurrencyCode, COUNT(*) AS CNT FROM Countries C1
	JOIN Countries C2 ON C2.CurrencyCode = C1.CurrencyCode AND C2.ContinentCode = C1.ContinentCode AND C2.CountryName = C1.CountryName
	GROUP BY C1.ContinentCode, C1.CurrencyCode
	HAVING COUNT(*) > 1
	) AS TMP
	 GROUP BY ContinentCode


SELECT TMP.ContinentCode, CurrencyCode, CNT FROM(
SELECT C1.ContinentCode, C1.CurrencyCode, COUNT(*) AS CNT FROM Countries C1
	JOIN Countries C2 ON C2.CurrencyCode = C1.CurrencyCode AND C2.ContinentCode = C1.ContinentCode AND C2.CountryName = C1.CountryName
	GROUP BY C1.ContinentCode, C1.CurrencyCode
	HAVING COUNT(*) > 1) AS TMP
	JOIN NewTable NT ON NT.ContinentCode = TMP.ContinentCode
	WHERE TMP.CNT = NT.MAXVALUE
	ORDER BY TMP.ContinentCode

--16

SELECT COUNT(*) FROM Countries C
	LEFT JOIN MountainsCountries MC ON MC.CountryCode = C.CountryCode
	WHERE MC.MountainId IS NULL

--17
SELECT TOP(5) * FROM(
SELECT CountryName, MAX(PK.Elevation) AS HighestPeakElevation, MAX(R.Length) AS LongestRiverLength FROM Countries C
	JOIN MountainsCountries MC ON MC.CountryCode = C.CountryCode
	JOIN CountriesRivers CR ON CR.CountryCode = C.CountryCode
	JOIN Rivers R ON R.Id = CR.RiverId
	JOIN Mountains M ON M.Id = MC.MountainId
	JOIN Peaks PK ON PK.MountainId = M.Id
	GROUP BY CountryName) AS TMP
	ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName

--18

SELECT CountryName, MAX(P.ELEVATION) AS [Highest Peak Elevationx] FROM Countries C
	LEFT JOIN MountainsCountries MC ON MC.CountryCode = C.CountryCode
	LEFT JOIN Mountains M ON M.Id = MC.MountainId
	LEFT JOIN PEAKS P ON P.MountainId = M.Id
	GROUP BY CountryName
	

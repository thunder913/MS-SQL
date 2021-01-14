USE SOFTUNI


--1

SELECT TOP(5) E.EmployeeID, E.JobTitle, E.AddressID, A.AddressText FROM Employees E
	JOIN Addresses A ON E.AddressID = A.AddressID
	ORDER BY E.AddressID

--2

SELECT TOP(50) E.FirstName, E.LastName, T.Name 'Town', A.AddressText FROM Employees E
	JOIN Addresses A ON E.AddressID = A.AddressID
	JOIN Towns T ON A.TownID = T.TownID
	ORDER BY E.FirstName

--3

SELECT E.EmployeeID, E.FirstName, E.LastName, D.Name FROM Employees E
	JOIN Departments D ON D.DepartmentID = E.DepartmentID
	WHERE D.Name='Sales'
	ORDER BY E.EmployeeID

--4

SELECT TOP(5) E.EmployeeID, E.FirstName, E.Salary, D.Name 'DepartmentName' FROM Employees E
	JOIN Departments D ON D.DepartmentID = E.DepartmentID
	WHERE E.Salary>15000
	ORDER BY E.DepartmentID


--5

SELECT TOP(3) E.EmployeeID,E.FirstName FROM Employees E
	LEFT JOIN EmployeesProjects EP ON EP.EmployeeID = E.EmployeeID
	WHERE ProjectID IS NULL
	ORDER BY E.EmployeeID	

--6

SELECT E.FirstName, E.LastName, E.HireDate, D.Name 'DeptName' FROM Employees E
	JOIN Departments D ON D.DepartmentID = E.DepartmentID
	WHERE E.HireDate > '1.1.1999' AND D.Name IN ('Sales', 'Finance')
	ORDER BY E.HireDate

--7

SELECT TOP(5) E.EmployeeID, E.FirstName, P.Name 'ProjectName' FROM Employees E
	JOIN EmployeesProjects EP ON EP.EmployeeID = E.EmployeeID
	JOIN Projects P ON P.ProjectID = EP.ProjectID
	WHERE P.StartDate > '08.13.2002' AND P.EndDate IS NULL
	ORDER BY E.EmployeeID

--8

SELECT E.EmployeeID, E.FirstName, 

	CASE
		WHEN YEAR(P.StartDate)>=2005 THEN NULL
		ELSE P.Name 
		END
		'ProjectName' FROM Projects P
	JOIN EmployeesProjects EP ON EP.ProjectID = P.ProjectID
	JOIN Employees E ON E.EmployeeID = EP.EmployeeID
	WHERE EP.EmployeeID = 24

--9

SELECT E.EmployeeID, E.FirstName, E.ManagerID, M.FirstName 'ManagerName' FROM Employees E
	JOIN Employees M ON M.EmployeeID = E.ManagerID
	WHERE E.ManagerID IN (3,7)
	ORDER BY E.EmployeeID

--10

SELECT TOP(50) E.EmployeeID, E.FirstName+' '+E.LastName 'EmployeeName', M.FirstName+' '+M.LastName 'ManagerName', D.Name 'DepartmentName' FROM Employees E
	JOIN Employees M ON M.EmployeeID = E.ManagerID
	JOIN Departments D ON D.DepartmentID = E.DepartmentID
	ORDER BY E.EmployeeID


--11

SELECT MIN(T.Average) 'MinAverageSalary' FROM(
	SELECT AVG(E.Salary) 'Average' FROM Employees E
	GROUP BY E.DepartmentID) T


--12
USE Geography

SELECT MC.CountryCode, M.MountainRange, P.PeakName, P.Elevation FROM Peaks P
	JOIN MountainsCountries MC ON MC.MountainId = P.MountainId
	JOIN Mountains M ON M.Id = P.MountainId
	WHERE P.Elevation>2835 AND MC.CountryCode ='BG'
	ORDER BY P.Elevation DESC

--13

SELECT MC.CountryCode, COUNT(MC.MountainId) FROM MountainsCountries MC
	JOIN Mountains M ON M.Id = MC.MountainId
	JOIN Countries C ON C.CountryCode = MC.CountryCode
	WHERE C.CountryName IN ('United States', 'Russia', 'Bulgaria')
	GROUP BY MC.CountryCode

--14

SELECT TOP(5) C.CountryName, R.RiverName FROM Countries C
	FULL JOIN CountriesRivers CR ON CR.CountryCode = C.CountryCode
	FULL JOIN Rivers R ON R.Id = CR.RiverId
	WHERE C.ContinentCode='AF'
	ORDER BY C.CountryName

--15

SELECT TEMP.ContinentCode, TEMP.CurrencyCode, TEMP.Count 'CurrencyUsage' FROM(
SELECT CON.ContinentCode, COU.CurrencyCode, COUNT(*) 'Count', DENSE_RANK() OVER(PARTITION BY CON.ContinentCode ORDER BY COUNT(*) DESC) 'Rank' FROM Continents CON
	JOIN Countries COU ON COU.ContinentCode = CON.ContinentCode
	GROUP BY CON.ContinentCode, COU.CurrencyCode
	) TEMP
	WHERE TEMP.Count>1 AND [Rank] = 1


	SELECT COUNT(*) 'Count' FROM Countries C
		LEFT JOIN MountainsCountries MC ON MC.CountryCode = C.CountryCode
		WHERE MC.MountainId IS NULL
--16

SELECT TOP(5) C.CountryName, MAX(PE.Elevation) 'HighestPeakElevation', MAX(R.Length) 'LongestRiverLenght' FROM Countries C
	JOIN MountainsCountries MC ON MC.CountryCode = C.CountryCode
	JOIN CountriesRivers CR ON CR.CountryCode = C.CountryCode
	JOIN Rivers R ON R.Id = CR.RiverId
	JOIN Mountains M ON M.Id=MC.MountainId
	JOIN Peaks PE ON PE.MountainId = M.Id
	GROUP BY C.CountryCode, C.CountryName
	ORDER BY MAX(PE.Elevation) DESC, MAX(R.Length) DESC, C.CountryName


--17

SELECT TEMP.CountryName, 
	CASE
		WHEN TEMP.PeakName IS NULL THEN '(no highest peak)'
		ELSE TEMP.PeakName
		END 'Highest Peak Name',
	CASE	
		WHEN TEMP.Elevation IS NULL THEN 0
		ELSE TEMP.Elevation END 'Highest Peak Elevation', 
	CASE
		WHEN TEMP.MountainRange IS NULL THEN '(no mountain)'
		ELSE TEMP.MountainRange END 'Mountain' FROM(
	SELECT C.CountryName, P.PeakName, P.Elevation, M.MountainRange, DENSE_RANK() OVER(PARTITION BY C.CountryName ORDER BY P.Elevation DESC) 'Rank' FROM Countries C
	LEFT JOIN MountainsCountries MC ON MC.CountryCode = C.CountryCode
	LEFT JOIN Mountains M ON M.Id = MC.MountainId
	LEFT JOIN Peaks P ON P.MountainId = M.Id
	) TEMP
	WHERE TEMP.[Rank] = 1
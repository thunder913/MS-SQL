USE SoftUni


SELECT TOP(50) E.FirstName, E.LastName, T.Name, A.AddressText FROM Employees E
	JOIN Addresses A ON E.AddressID = A.AddressID
	JOIN Towns T ON T.TownID = A.TownID
	ORDER BY E.FirstName, E.LastName

USE Geography

	SELECT TEMP.ContinentCode, TEMP.CurrencyCode, TEMP.Count 'CurrencyUsage' FROM(
SELECT CON.ContinentCode, COU.CurrencyCode, COUNT(*) 'Count', DENSE_RANK() OVER(PARTITION BY CON.ContinentCode ORDER BY COUNT(*) DESC) 'Rank' FROM Continents CON
	JOIN Countries COU ON COU.ContinentCode = CON.ContinentCode
	GROUP BY CON.ContinentCode, COU.CurrencyCode
	HAVING COUNT(*)>1
	) TEMP
	WHERE [Rank] = 1
	ORDER BY TEMP.ContinentCode



SELECT TMP.ContinentCode, CurrencyCode, CNT FROM(
SELECT C1.ContinentCode, C1.CurrencyCode, COUNT(*) AS CNT FROM Countries C1
	JOIN Countries C2 ON C2.CurrencyCode = C1.CurrencyCode AND C2.ContinentCode = C1.ContinentCode AND C2.CountryName = C1.CountryName
	GROUP BY C1.ContinentCode, C1.CurrencyCode
	HAVING COUNT(*) > 1) AS TMP
	JOIN NewTable NT ON NT.ContinentCode = TMP.ContinentCode
	WHERE TMP.CNT = NT.MAXVALUE
	ORDER BY TMP.ContinentCode



SELECT TOP(5) C.CountryName, MAX(PE.Elevation) 'HighestPeakElevation', MAX(R.Length) 'LongestRiverLenght' FROM Countries C
	FULL JOIN MountainsCountries MC ON MC.CountryCode = C.CountryCode
	FULL JOIN CountriesRivers CR ON CR.CountryCode = C.CountryCode
	FULL JOIN Rivers R ON R.Id = CR.RiverId
	FULL JOIN Mountains M ON M.Id=MC.MountainId
	FULL JOIN Peaks PE ON PE.MountainId = M.Id
	GROUP BY C.CountryCode, C.CountryName
	ORDER BY MAX(PE.Elevation) DESC, MAX(R.Length) DESC, C.CountryName


SELECT TOP(5) TEMP.CountryName, 
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

	use SoftUni


	SELECT E.DepartmentID, AVG(E.Salary) 'AverageSalary' INTO tempTable FROM Employees E
	GROUP BY E.DepartmentID
	
	SELECT * FROM tempTable

SELECT TOP(10) E.FirstName, E.LastName, E.DepartmentID FROM Employees E
	JOIN tempTable TT ON TT.DepartmentID = E.DepartmentID
	WHERE E.Salary>TT.AverageSalary
	ORDER BY E.DepartmentID



		SELECT TOP(10) FirstName,LastName,E.DepartmentID FROM Employees E
		JOIN (SELECT DepartmentID, AVG(Salary) AS DepartmentAvgSalary FROM Employees
		GROUP BY DepartmentID) DA ON (DA.DepartmentID = E.DepartmentID)
		WHERE E.Salary > DA.DepartmentAvgSalary
		ORDER BY E.DepartmentID
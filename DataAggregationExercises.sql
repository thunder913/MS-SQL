--1
SELECT COUNT(*) AS Count FROM WizzardDeposits

--2

SELECT MAX(MAGICWANDSIZE) AS LongestMagicWand FROM WizzardDeposits

--3

SELECT DepositGroup, MAX(MAGICWANDSIZE) AS LongestMagicWand FROM WizzardDeposits
	GROUP BY DepositGroup

--4

SELECT TOP(2) DepositGroup FROM WizzardDeposits
	GROUP BY DepositGroup
	ORDER BY AVG(MAGICWANDSIZE)

--5

SELECT DepositGroup, SUM(DEPOSITAMOUNT) AS TotalSum FROM WizzardDeposits
	GROUP BY DepositGroup

--6
	SELECT DepositGroup, SUM(DEPOSITAMOUNT) AS TotalSum FROM WizzardDeposits
	WHERE MagicWandCreator = 'Ollivander family' 
	GROUP BY DepositGroup

--7

	SELECT DepositGroup, SUM(DEPOSITAMOUNT) AS TotalSum FROM WizzardDeposits
		WHERE MagicWandCreator = 'Ollivander family'
		GROUP BY DepositGroup
		HAVING SUM(DEPOSITAMOUNT) < 150000
		ORDER BY TotalSum DESC
		
--8
	SELECT DepositGroup, MagicWandCreator, MIN(DEPOSITCHARGE) FROM WizzardDeposits
		GROUP BY DepositGroup, MagicWandCreator
		ORDER BY MagicWandCreator, DepositGroup

--9
	
SELECT AgeGroup, COUNT(*) FROM(
	SELECT CASE
				WHEN Age<=10 THEN '[0-10]'
				WHEN Age<=20 THEN '[11-20]'
				WHEN Age<=30 THEN '[21-30]'
				WHEN Age<=40 THEN '[31-40]'
				WHEN Age<=50 THEN '[41-50]'
				WHEN Age<=60 THEN '[51-60]'
				ELSE '[61+]'
				END AS AgeGroup
			FROM WizzardDeposits) AS TEMP
			GROUP BY AgeGroup

--10
	SELECT DISTINCT LEFT(FirstName,1) AS FirstLetter FROM WizzardDeposits
		WHERE DepositGroup = 'Troll Chest'

--11
	SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS AverageInterest FROM WizzardDeposits
	WHERE DepositStartDate > '01/01/1985'
		GROUP BY DepositGroup, IsDepositExpired
		ORDER BY DepositGroup DESC, IsDepositExpired

	SELECT * FROM WizzardDeposits

--12
SELECT SUM([Difference]) FROM(
	SELECT FirstName, 
	DepositAmount, 
	(SELECT FirstName FROM WizzardDeposits D WHERE D.Id = WD.Id+1) AS [Guest Wizard],
	(SELECT DepositAmount FROM WizzardDeposits D WHERE D.Id = WD.Id+1) AS GUESTD,
	DepositAmount - (SELECT DepositAmount FROM WizzardDeposits D WHERE D.Id = WD.Id+1)  AS [Difference]
	FROM WizzardDeposits WD
	WHERE WD.Id < 162) AS TEMP

--13
	USE SoftUni

	SELECT DepartmentID, SUM(SALARY) FROM Employees E
		GROUP BY DepartmentID

--14
	SELECT DepartmentID, MIN(SALARY) FROM Employees
		WHERE HireDate > '01/01/2000' AND DepartmentID IN (2,5,7)
		GROUP BY DepartmentID

--15
	SELECT * INTO Emp_AVGSalary FROM Employees
		WHERE SALARY > 30000 

	DELETE FROM Emp_AVGSalary WHERE ManagerID = 42

	UPDATE Emp_AVGSalary SET Salary = Salary + 5000 WHERE DepartmentID = 1
	SELECT DepartmentID, AVG(SALARY) FROM Emp_AVGSalary
		GROUP BY DepartmentID

--16
	SELECT DepartmentID, MAX(SALARY) FROM Employees
		GROUP BY DepartmentID
		HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--17
	SELECT COUNT(*) AS [Count] FROM Employees
		WHERE ManagerID IS NULL

--18
	
	SELECT  DepartmentID, MAX(Salary) AS MaxSalary INTO Departments_MaxSalary FROM Employees 
			GROUP BY DepartmentID
			HAVING COUNT(*) >= 3

SELECT E2.DepartmentID, MAX(Salary) AS MaxSalary FROM Employees E2
	JOIN
	(SELECT E1.DepartmentID, MAX(Salary)AS MaxSalary FROM Employees E1
		JOIN
			Departments_MaxSalary T1 ON T1.DepartmentID = E1.DepartmentID
			WHERE E1.Salary != MaxSalary
			GROUP BY E1.DepartmentID) T2 ON T2.DepartmentID = E2.DepartmentID
	JOIN Departments_MaxSalary DM ON DM.DepartmentID = E2.DepartmentID
			WHERE E2.Salary NOT IN (T2.MaxSalary, DM.MaxSalary)
			GROUP BY E2.DepartmentID

--19
	SELECT TOP(10) FirstName,LastName,E.DepartmentID FROM Employees E
		JOIN (SELECT DepartmentID, AVG(Salary) AS DepartmentAvgSalary FROM Employees
		GROUP BY DepartmentID) DA ON (DA.DepartmentID = E.DepartmentID)
		WHERE E.Salary > DA.DepartmentAvgSalary
		ORDER BY E.DepartmentID
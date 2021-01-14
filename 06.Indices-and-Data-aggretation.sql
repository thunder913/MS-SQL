--1

USE Gringotts

SELECT COUNT(*) 'Count' FROM WizzardDeposits

--2

SELECT MAX(MagicWandSize) 'LongestMagicWand' FROM WizzardDeposits

--3

SELECT WD.DepositGroup, MAX(WD.MagicWandSize) 'LongestMagicWand' FROM WizzardDeposits WD
	GROUP BY WD.DepositGroup

--4

SELECT TOP(2) WD.DepositGroup FROM WizzardDeposits WD
	GROUP BY WD.DepositGroup
	ORDER BY AVG(WD.MagicWandSize)

--5

SELECT WD.DepositGroup, SUM(WD.DepositAmount) 'TotalSum' FROM WizzardDeposits WD
	GROUP BY WD.DepositGroup

--6

SELECT WD.DepositGroup, SUM(WD.DepositAmount) 'TotalSum' FROM WizzardDeposits WD
	WHERE WD.MagicWandCreator = 'Ollivander family'
	GROUP BY WD.DepositGroup

--7

SELECT WD.DepositGroup, SUM(WD.DepositAmount) 'TotalSum' FROM WizzardDeposits WD
	WHERE WD.MagicWandCreator = 'Ollivander family'
	GROUP BY WD.DepositGroup
	HAVING SUM(WD.DepositAmount) < 150000
	ORDER BY SUM(WD.DepositAmount) DESC

--8

SELECT WD.DepositGroup, WD.MagicWandCreator, MIN(WD.DepositCharge) 'MinDepositCharge' FROM WizzardDeposits WD
	GROUP BY WD.DepositGroup, WD.MagicWandCreator
	ORDER BY WD.MagicWandCreator, WD.DepositGroup

--9


SELECT TEMP.AgeGroup, COUNT(*) 'WizardCount' FROM(
SELECT CASE
	WHEN WD.Age <= 10 THEN '[0-10]'
	WHEN WD.Age <= 20 THEN '[11-20]'
	WHEN WD.Age <= 30 THEN '[21-30]'
	WHEN WD.Age <= 40 THEN '[31-40]'
	WHEN WD.Age <= 50 THEN '[41-50]'
	WHEN WD.Age <= 60 THEN '[51-60]'
	ELSE '[61+]'
	END
	'AgeGroup'
FROM WizzardDeposits WD) TEMP
	GROUP BY TEMP.AgeGroup

--10

SELECT LEFT(WD.FirstName,1) 'FirstLetter' FROM WizzardDeposits WD
	WHERE WD.DepositGroup = 'Troll Chest'
	GROUP BY LEFT(WD.FirstName, 1)
	ORDER BY LEFT(WD.FirstName, 1)

--11

SELECT WD.DepositGroup, WD.IsDepositExpired, AVG(WD.DepositInterest) 'AverageInterest' FROM WizzardDeposits WD
	WHERE WD.DepositStartDate>'01/01/1985'
	GROUP BY WD.DepositGroup, WD.IsDepositExpired
	ORDER BY WD.DepositGroup DESC, WD.IsDepositExpired

--12
SELECT SUM(TEMP.Difference) 'SumDifference' FROM(
SELECT WD1.FirstName 'Host Wizard', WD1.DepositAmount 'Host Wizard Deposit', 
	WD2.FirstName 'Guest Wizard', WD2.DepositAmount 'Guest Wizard Deposit', WD1.DepositAmount - WD2.DepositAmount 'Difference' FROM WizzardDeposits WD1
	JOIN WizzardDeposits WD2 ON WD2.Id = WD1.Id+1) TEMP


--13

USE SoftUni

SELECT E.DepartmentID, SUM(E.Salary) 'TotalSalary' FROM Employees E
	GROUP BY E.DepartmentID
	ORDER BY E.DepartmentID

--14

SELECT E.DepartmentID, MIN(E.Salary) 'MinimumSalary' FROM Employees E
	WHERE E.DepartmentID IN (2,5,7) AND YEAR(E.HireDate)>=2000
	GROUP BY E.DepartmentID
	
--15

SELECT * INTO newTable FROM Employees E
	WHERE E.Salary>30000

DELETE FROM newTable
	WHERE ManagerID=42

UPDATE newTable
	SET Salary+=5000
	WHERE DepartmentID=1

SELECT DepartmentID, AVG(Salary) 'AverageSalary' FROM newTable
	GROUP BY DepartmentID

--16

SELECT * FROM(
SELECT E.DepartmentID, MAX(E.Salary) 'MaxSalary' FROM Employees E
	GROUP BY E.DepartmentID) TEMP
	WHERE TEMP.MaxSalary NOT BETWEEN 30000 AND 70000

--17

SELECT COUNT(*) 'Count' FROM Employees E
	WHERE E.ManagerID IS NULL

--18

SELECT TEMP.DepartmentID, TEMP.Salary 'ThirdHighestSalary' FROM(
SELECT E.DepartmentID, E.Salary, DENSE_RANK() OVER(PARTITION BY E.DepartmentID ORDER BY E.Salary DESC) 'Rank' FROM Employees E
	GROUP BY E.DepartmentID, E.Salary) TEMP
	WHERE TEMP.Rank = 3

--19

SELECT E.DepartmentID, AVG(E.Salary) 'AverageSalary' INTO tempTable FROM Employees E
	GROUP BY E.DepartmentID
	
SELECT E.FirstName, E.LastName, E.DepartmentID FROM Employees E
	JOIN tempTable TT ON TT.DepartmentID = E.DepartmentID
	WHERE E.Salary>TT.AverageSalary
	ORDER BY E.DepartmentID



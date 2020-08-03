SELECT [Name] FROM Departments

SELECT FirstName, LastName, Salary FROM Employees

SELECT FirstName, MiddleName, LastName FROM Employees

SELECT FirstName + '.' + LastName + '@softuni.bg' FROM Employees

SELECT DISTINCT Salary FROM Employees

SELECT * FROM Employees
	WHERE JobTitle = 'Sales Representative'

SELECT FirstName,LastName,JobTitle FROM Employees
	WHERE Salary >= 20000 AND SALARY <= 30000

SELECT FirstName + ' ' + MiddleName + ' ' + LastName AS [FullName] FROM Employees
	 WHERE SALARY IN (25000,14000,12500,23600)

SELECT FIRSTNAME, LASTNAME FROM Employees
	WHERE ManagerID IS NULL

SELECT FIRSTNAME, LASTNAME, SALARY FROM Employees
	WHERE SALARY > 50000 
	ORDER BY SALARY DESC

SELECT TOP(5) FIRSTNAME, LASTNAME FROM Employees
	ORDER BY SALARY DESC

SELECT FIRSTNAME, LASTNAME FROM Employees
	WHERE DepartmentID != 4

SELECT * FROM Employees 
	ORDER BY SALARY DESC, FirstName, LastName DESC, MiddleName

CREATE VIEW V_EmployeesSalaries AS 
	SELECT FIRSTNAME, LASTNAME, SALARY FROM Employees

SELECT * FROM V_EmployeesSalaries

CREATE VIEW V_EmployeeNameJobTitle AS
SELECT FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + LastName AS 'Full Name', JobTitle FROM Employees
	

SELECT * FROM V_EmployeeNameJobTitle

SELECT DISTINCT JobTitle FROM Employees

SELECT TOP(10) * FROM Projects
	ORDER BY StartDate, EndDate, NAME

SELECT TOP(7) FirstName, LastName, HireDate FROM Employees
	ORDER BY HireDate DESC

	SELECT * FROM Employees


	SELECT * FROM Departments

--UPDATE Employees
--SET Salary*=1.12
--WHERE DepartmentID IN (1,2,4,11)

--SELECT Salary FROM Employees	

CREATE VIEW V_IncreaseSalaries AS
SELECT Salary FROM Employees
	JOIN  [dbo].[Departments] D ON [dbo].[Employees].[DepartmentID] = D.[DepartmentID]
	WHERE D.Name IN ('Engineering', 'Tool Design', 'Marketing', 'Information Services')
	
	UPDATE SELECT Salary FROM Employees
	JOIN  [dbo].[Departments] D ON [dbo].[Employees].[DepartmentID] = D.[DepartmentID]
	WHERE D.Name IN ('Engineering', 'Tool Design', 'Marketing', 'Information Services')
	SET Salary *= 1.12

	SELECT SALARY FROM Employees


SELECT * FROM 
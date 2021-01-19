USE SoftUni

--1

CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
SELECT E.FirstName, E.LastName FROM Employees E
	WHERE E.Salary>35000
	
EXEC usp_GetEmployeesSalaryAbove35000


--2

CREATE PROC usp_GetEmployeesSalaryAboveNumber(@Salary DECIMAL(18,4))
AS
	SELECT E.FirstName, E.LastName FROM Employees E
		WHERE E.Salary>=@Salary

EXEC usp_GetEmployeesSalaryAboveNumber 48100

--3

CREATE PROC usp_GetTownsStartingWith (@StartWith NVARCHAR(100))
AS
	SELECT T.Name FROM Towns T
		WHERE T.Name LIKE @StartWith+'%'

EXEC usp_GetTownsStartingWith 'C'

--4

CREATE PROC usp_GetEmployeesFromTown(@TownName NVARCHAR(100))
AS
	SELECT E.FirstName, E.LastName FROM Employees E
		JOIN Addresses A ON A.AddressID = E.AddressID
		JOIN Towns T ON T.TownID = A.TownID
		WHERE T.Name = @TownName

EXEC usp_GetEmployeesFromTown 'Sofia'

--5

CREATE FUNCTION ufn_GetSalaryLevel(@Salary DECIMAL(18,4))
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @SalaryLevel VARCHAR(10)

	IF(@Salary <30000)
		SET @SalaryLevel = 'Low'
	ELSE IF(@Salary <= 50000)
		SET @SalaryLevel = 'Average'
	ELSE
		SET @SalaryLevel = 'High'

	RETURN @SalaryLevel
END

SELECT E.Salary, dbo.ufn_GetSalaryLevel(E.Salary) 'Salary Level' FROM Employees E

--6

CREATE PROC usp_EmployeesBySalaryLevel(@Level VARCHAR(10))
AS
SELECT E.FirstName, E.LastName FROM Employees E
	WHERE dbo.ufn_GetSalaryLevel(E.Salary) = @Level

--7

CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(20), @word VARCHAR(20))
RETURNS BIT
AS
BEGIN
	DECLARE @WordLen INT = LEN(@word)
	DECLARE @i INT = 1;
	WHILE(@i <= @WordLen)
		BEGIN
		DECLARE @CurrentChar VARCHAR(1) = SUBSTRING(@word, @i,1)
		IF(CHARINDEX(@CurrentChar, @setOfLetters) = 0)
		RETURN 0
		SET @i +=1
		END

		RETURN 1
ENd

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia')

--8

ALTER PROC usp_DeleteEmployeesFromDepartment(@departmentID INT)
AS
BEGIN
	DELETE EP FROM EmployeesProjects EP
		JOIN Employees E ON E.EmployeeID = EP.EmployeeID
		WHERE E.DepartmentID = @departmentID

		DELETE P FROM Projects P
		JOIN EmployeesProjects EP ON EP.ProjectID = P.ProjectID
		JOIN Employees E ON E.EmployeeID = EP.EmployeeID
		WHERE E.DepartmentID = @departmentID

	ALTER TABLE Employees
		ALTER COLUMN ManagerID
			INT NULL

	ALTER TABLE Departments
		ALTER COLUMN ManagerID
			INT NULL

	UPDATE E
		SET ManagerID = NULL
		FROM Employees E
		JOIN Employees M ON M.EmployeeID = E.ManagerID
		WHERE M.DepartmentID = @departmentID

	UPDATE Departments
		SET ManagerID = NULL
		WHERE DepartmentID = @departmentID

	UPDATE D
		SET D.ManagerID = NULL
		FROM Departments D 
		JOIN Employees E ON E.EmployeeID = D.ManagerID
		WHERE E.DepartmentID = @departmentID

	DELETE FROM Employees
		WHERE DepartmentID = @departmentID

	DELETE FROM Departments
		WHERE DepartmentID = @departmentID

	SELECT COUNT(*) FROM Employees E
		WHERE E.DepartmentID = @departmentID
END

EXEC usp_DeleteEmployeesFromDepartment 1

--9

USE BANK

CREATE PROC usp_GetHoldersFullName 
AS
SELECT FirstName + ' ' + LastName FROM AccountHolders

EXEC usp_GetHoldersFullName

--10

CREATE OR ALTER PROC usp_GetHoldersWithBalanceHigherThan(@balance MONEY)
AS
SELECT AH.FirstName, AH.LastName FROM Accounts A
	JOIN AccountHolders AH ON AH.Id = A.AccountHolderId
	GROUP BY AH.Id, AH.FirstName, AH.LastName
	HAVING SUM(Balance)>@balance
	ORDER BY AH.FirstName, AH.LastName


EXEC usp_GetHoldersWithBalanceHigherThan 100000

--11

CREATE FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(18,2), @yearlyRate float, @years INT)
RETURNS DECIMAL(18,4) AS
BEGIN
	DECLARE @futureValue DECIMAL(18,4)
	SET @futureVALUE = @sum* (POWER(1+@yearlyRate, @years))
	RETURN @futureVALUE
END


SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)

--12

CREATE OR ALTER PROC usp_CalculateFutureValueForAccount(@AccountId INT, @InterestRate DECIMAL(18,2))
AS
BEGIN
SELECT A.Id 'Account Id', AH.FirstName, AH.LastName, A.Balance 'Current Balance', dbo.ufn_CalculateFutureValue(A.Balance,@InterestRate, 5) 'Balance in 5 years' FROM Accounts A
	JOIN AccountHolders AH ON AH.Id = A.AccountHolderId
	WHERE A.Id=@AccountId
END
EXEC usp_CalculateFutureValueForAccount 1,0.1

--13

USE Diablo

CREATE FUNCTION ufn_CashInUsersGames(@param NVARCHAR(50))
RETURNS @result TABLE(
	SumCash money
)
AS
BEGIN
	INSERT INTO @result
	SELECT SUM(TEMP.Cash) 'SumCash' FROM(
	SELECT UG.Cash, ROW_NUMBER() OVER (ORDER BY UG.Cash DESC) 'RowNumber'  FROM UsersGames UG
		JOIN Games G ON G.Id = UG.GameId
		WHERE G.Name = @param
		) TEMP
		WHERE TEMP.RowNumber%2=1	
	RETURN
END

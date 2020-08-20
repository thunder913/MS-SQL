USE SOFTUNI

--1
CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
	SELECT FirstName, LastName FROM Employees
	WHERE SALARY > 35000

EXEC usp_GetEmployeesSalaryAbove35000

--2

CREATE PROC usp_GetEmployeesSalaryAboveNumber(@number DECIMAL(18,4))
AS
	SELECT FirstName, LastName FROM Employees
		WHERE Salary >= @number

--3

CREATE PROC usp_GetTownsStartingWith(@startsWith nvarchar(30))
AS 
	SELECT [Name] FROM Towns
		WHERE LEFT([NAME], LEN(@startsWith)) = @STARTSWITH

EXEC usp_GetTownsStartingWith 'b'

--4
CREATE PROC usp_GetEmployeesFromTown (@town nvarchar(30))
AS
	SELECT * FROM Employees E
		JOIN Addresses A ON A.AddressID = E.AddressID
		JOIN Towns T ON T.TownID = A.TownID
		WHERE T.Name = @town

EXEC usp_GetEmployeesFromTown 'Sofia'

--5

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
	RETURNS NVARCHAR(30) AS
	BEGIN
		IF(@salary < 30000)
		RETURN 'Low'
		ELSE IF(@salary <= 50000)
		RETURN 'Average'
		RETURN 'High'
	END

--6
CREATE PROC usp_EmployeesBySalaryLevel (@level NVARCHAR(30))
	AS
		SELECT FirstName,LastName FROM Employees
			WHERE dbo.ufn_GetSalaryLevel(Salary) = @level

EXEC dbo.usp_EmployeesBySalaryLevel 'Low'

--7
GO
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(30), @word NVARCHAR(30)) 
	RETURNS BIT AS
	BEGIN
	DECLARE @wordLen INT = LEN(@WORD)
	DECLARE @i INT = 1
	WHILE(@i <= @wordLen)
		BEGIN
		DECLARE @currentChar NVARCHAR(1) = SUBSTRING(@WORD, @i, 1)
		IF(CHARINDEX(@currentChar, @setOfLetters) = 0)
		RETURN 0
		SET @i += 1
		END

		RETURN 1
	END

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia')

--8

    GO
	CREATE PROC usp_DeleteEmployeesFromDepartment(@departmentId INT)
	AS
	BEGIN
	ALTER TABLE EMPLOYEES
	DROP FK_Employees_Departments
	ALTER TABLE EmployeesProjects
	DROP FK_EmployeesProjects_Employees
	ALTER TABLE DEPARTMENTS
	DROP FK_Departments_Employees
	ALTER TABLE EMPLOYEES
	DROP FK_Employees_Employees
	DELETE FROM Employees WHERE DepartmentID = @departmentId
	DELETE FROM Departments WHERE DepartmentID = @departmentId
	SELECT COUNT(*) FROM Employees
		WHERE DepartmentID = @departmentId
	END

EXEC usp_DeleteEmployeesFromDepartment 4

--THIS IS WRONG ^^

--9


SELECT * FROM accountholders

GO
CREATE PROC usp_GetHoldersFullName 
	AS
	SELECT (FIRSTNAME + ' ' + LASTNAME) AS [Full Name] FROM AccountHolders

EXEC usp_GetHoldersFullName

--10
CREATE PROC usp_GetHoldersWithBalanceHigherThan(@money money)
AS
SELECT AC.FirstName, AC.LastName FROM (
SELECT A.AccountHolderId FROM accounts A
	JOIN AccountHolders AH ON AH.ID = A.ACCOUNTHOLDERID
	GROUP BY A.ACCOUNTHOLDERID
	HAVING SUM(A.BALANCE) > @MONEY
	) AS TEMP
	JOIN AccountHolders AC ON AC.Id = TEMP.AccountHolderId
	ORDER BY FIRSTNAME, LASTNAME

	EXEC usp_GetHoldersWithBalanceHigherThan 2000

--11
GO
CREATE FUNCTION ufn_CalculateFutureValue (@Sum MONEY, @Rate FLOAT , @Years INT)
RETURNS MONEY AS
BEGIN
 RETURN @Sum * POWER(1+@Rate,@Years)
END
GO

SELECT dbo.ufn_CalculateFutureValue(100,2,1)

--12
go
CREATE FUNCTION ufn_CalculateFutureValue (@Sum MONEY, @Rate FLOAT , @Years INT)
RETURNS MONEY AS
BEGIN
 RETURN @Sum * POWER(1+@Rate,@Years)
END

CREATE PROC usp_CalculateFutureValueForAccount (@AccountID int, @Rate1 float)
AS
SELECT A.AccountHolderId AS [Account Id],
		FirstName as [First Name], 
		LastName as [Last Name],
		A.Balance AS [Current Balance], 
		dbo.ufn_CalculateFutureValue(Balance,@Rate1, 5) AS [Balance in 5 years] 
		FROM Accounts A
	JOIN AccountHolders AH ON AH.Id = A.AccountHolderId
	WHERE @AccountID = A.Id


EXEC usp_CalculateFutureValueForAccount 2,0.1


--13
USE Diablo

SELECT G.Id,G.Name FROM Games G
	JOIN UserGameItems UGI ON UGI.UserGameId = G.Id
	JOIN Items I ON I.Id = UGI.ItemId
	JOIN GameTypes GT ON G.GameTypeId = GT.Id
	JOIN GameTypeForbiddenItems GTFI ON GTFI.GameTypeId = GT.Id
	JOIN Items IT ON IT.Id = GTFI.ItemId
	WHERE ROW_NUMBER() %2 = 0
	ORDER BY I.Price DESC

	SELECT * FROM GameTypes
USE Bank

--1

CREATE TABLE Logs(
	LogId INT PRIMARY KEY IDENTITY,
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
	OldSum DECIMAL(18,2),
	NewSum DECIMAL(18,2)
)

CREATE OR ALTER TRIGGER tr_log ON Accounts FOR UPDATE
AS
BEGIN
	DECLARE @OldSum DECIMAL(18,4)
	DECLARE @NewSum DECIMAL(18,4)
	DECLARE @AccountId INT
	SELECT @OldSum=Balance FROM deleted
	SELECT @NewSum=Balance, @AccountId=Id FROM inserted
	
	INSERT INTO Logs(AccountId, OldSum, NewSum)
	VALUES
	(@AccountId, @OldSum,@NewSum)
END


SELECT * FROM Logs


--2

CREATE TABLE NotificationEmails(
	Id INT PRIMARY KEY IDENTITY,
	Recipient INT FOREIGN KEY REFERENCES Accounts(Id),
	Subject NVARCHAR(100),
	Body NVARCHAR(200)
	)

CREATE OR ALTER TRIGGER tr_notification ON Accounts FOR UPDATE
AS
BEGIN
	DECLARE @OldSum DECIMAL(18,4)
	DECLARE @NewSum DECIMAL(18,4)
	DECLARE @AccountId INT
	SELECT @OldSum=Balance FROM deleted
	SELECT @NewSum=Balance, @AccountId=Id FROM inserted
	INSERT INTO NotificationEmails(Recipient, Subject, Body)
	VALUES
	(@AccountId, 'Balance change for account: '+ CONVERT(NVARCHAR,@AccountId), 'On ' + CONVERT(NVARCHAR, GETDATE()) +' your balance was changed from +'+ CONVERT(NVARCHAR,@OldSum) +' to ' + CONVERT(NVARCHAR,@NewSum))
END

SELECT * FROM NotificationEmails

--3

CREATE PROC usp_DepositMoney (@AccountId INT, @MoneyAmount DECIMAL(18,4))
AS
BEGIN TRANSACTION
	IF(@MoneyAmount<0)
		BEGIN
			ROLLBACK
			RETURN
		END
	UPDATE Accounts
		SET Balance += @MoneyAmount
		WHERE Id = @AccountId
COMMIT

--4

CREATE PROC usp_WithdrawMoney(@AccountId INT, @MoneyAmount DECIMAL(18,4))
AS
BEGIN TRANSACTION
	IF(@MoneyAmount<0)
		BEGIN
			ROLLBACK
			RETURN
		END
	UPDATE Accounts
		SET Balance-=@MoneyAmount
		WHERE Id=@AccountId
COMMIT

--5

CREATE OR ALTER PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(18,4))
AS
BEGIN TRANSACTION
	EXEC usp_DepositMoney @ReceiverId, @Amount
	EXEC usp_WithdrawMoney @SenderId, @Amount
COMMIT


--7
  
DECLARE @UserName VARCHAR(50) = 'Stamat'
DECLARE @GameName VARCHAR(50) = 'Safflower'
DECLARE @UserID int = (SELECT Id FROM Users WHERE Username = @UserName)
DECLARE @GameID int = (SELECT Id FROM Games WHERE Name = @GameName)
DECLARE @UserMoney money = (SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)
DECLARE @ItemsTotalPrice money
DECLARE @UserGameID int = (SELECT Id FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)

BEGIN TRANSACTION
	SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
	BEGIN
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameID FROM Items AS i
		WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 11 AND 12)

		UPDATE UsersGames
		SET Cash -= @ItemsTotalPrice
		WHERE GameId = @GameID AND UserId = @UserID
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK
	END

SET @UserMoney = (SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)
BEGIN TRANSACTION
	SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
	BEGIN
		INSERT INTO UserGameItems
		SELECT i.Id, @UserGameID FROM Items AS i
		WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 19 AND 21)

		UPDATE UsersGames
		SET Cash -= @ItemsTotalPrice
		WHERE GameId = @GameID AND UserId = @UserID
		COMMIT
	END
	ELSE
	BEGIN
		ROLLBACK
	END

SELECT Name AS [Item Name]
FROM Items
WHERE Id IN (SELECT ItemId FROM UserGameItems WHERE UserGameId = @userGameID)
ORDER BY [Item Name]


--8
USE SoftUni

ALTER PROC usp_AssignProject(@emloyeeId INT, @projectID INT)
AS
BEGIN 
	DECLARE @ProjectCount INT
	SELECT @ProjectCount = COUNT(*) FROM Employees E
		JOIN EmployeesProjects EP ON EP.EmployeeID = E.EmployeeID
		JOIN Projects P ON P.ProjectID = EP.ProjectID
		WHERE E.EmployeeID = @emloyeeId
	IF(@ProjectCount>=3)
		BEGIN
			RAISERROR('The employee has too many projects!', 16,1)
			RETURN
		END
	INSERT INTO EmployeesProjects(EmployeeID, ProjectID)
	VALUES(@emloyeeId, @projectID)
END

--22

CREATE TABLE Deleted_Employees(
	EmployeeId INT PRIMARY KEY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	MiddleName NVARCHAR(50),
	JobTitle NVARCHAR(50),
	DepartmentId INT FOREIGN KEY REFERENCES Departments(DepartmentId),
	Salary DECIMAL(18,2)
)

CREATE TRIGGER tr_deletedEmployee ON Employees FOR DELETE
AS
BEGIN
	INSERT INTO Deleted_Employees(EmployeeId, FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
	SELECT EmployeeID,FirstName,LastName,MiddleName, JobTitle,DepartmentID, Salary FROM deleted
END


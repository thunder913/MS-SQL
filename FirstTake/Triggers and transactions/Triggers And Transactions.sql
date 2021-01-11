--14

CREATE TABLE Logs 
(
	LogID int PRIMARY KEY IDENTITY,
	AccountID int,
	OldSum money,
	NewSum money
)

GO
CREATE TRIGGER tr_AddToLogOnAccountSumChange ON Accounts FOR UPDATE
AS
	INSERT INTO Logs(AccountID, OldSum, NewSum)
	SELECT a.Id, d.Balance as OldSum, a.Balance as NewSum FROM Accounts a
		JOIN deleted D on d.Id = a.Id
		WHERE a.Balance != d.Balance
GO

select * from Logs

--15
CREATE TABLE NotificationEmails
(
	Id INT PRIMARY KEY IDENTITY,
	Recipient INT,
	[Subject] NVARCHAR(100),
	Body NVARCHAR(100)
)

GO
CREATE TRIGGER tr_AddEmailWhenAddLogIsTriggered ON LOGS FOR INSERT
AS
	BEGIN
	INSERT INTO NotificationEmails(Recipient,[Subject],Body)
	SELECT
	L.AccountID, 
	'Balance change for account: ' +  CONVERT(VARCHAR(10), L. AccountID), 
	'On ' + CONVERT(VARCHAR(20),GETDATE()) + ' your balance was changed from ' + CONVERT(VARCHAR(10),L.OldSum) + ' to ' 
	+ CONVERT(VARCHAR(10),L.NewSum) + '.'
	FROM Logs L
	END
GO

SELECT * FROM Logs

--16
GO
CREATE PROCEDURE usp_DepositMoney(@accountId   INT, @moneyAmount MONEY)
AS
     BEGIN
         IF(@moneyAmount < 0)
             BEGIN
                 RAISERROR('Cannot deposit negative value', 16, 1);
         END;
         BEGIN TRANSACTION;
         UPDATE Accounts
           SET
               Balance+=@moneyAmount
         WHERE Id = @accountId;
         COMMIT;
     END;

--17

CREATE PROC usp_WithdrawMoney (@AccountId INT,  @MoneyAmount MONEY)
AS
	BEGIN
	IF(@MONEYAMOUNT < 0)
		 BEGIN
                 RAISERROR('Cannot deposit negative value', 16, 1);
         END;
		 BEGIN TRANSACTION;
         UPDATE Accounts
           SET
               Balance-=@moneyAmount
         WHERE Id = @accountId;
         COMMIT;
     END;

EXEC USP_WITHDRAWMONEY 1,10

--18

CREATE PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount MONEY)
AS 
BEGIN
		IF(@Amount < 0)
		 BEGIN
                 RAISERROR('Cannot deposit negative value', 16, 1);
         END;
	BEGIN TRANSACTION
		EXEC usp_WithdrawMoney @SenderId, @Amount
		EXEC usp_DepositMoney @ReceiverId, @Amount
		COMMIT;
END

--20
--TODO
USE DIABLO
SELECT * FROM Users
	WHERE FirstName = 'Stamat'


SELECT * FROM UsersGames
	WHERE UserId = 9 AND GameId = 87

	SELECT * FROM ITEMS

	SELECT * FROM Games G
		JOIN USERGAMEITEMS UGI ON UGI.UserGameId = G.Id
		JOIN ITEMS I ON I.Id = UGI.ItemId 
		WHERE G.Name = 'Safflower'

		SELECT * FROM Games G
			JOIN GameTypes GT ON GT.Id = G.GameTypeId
			JOIN GameTypeForbiddenItems GTFI ON GTFI.GameTypeId = GT.Id
			JOIN ITEMS I ON I.Id = GTFI.ItemId
			WHERE G.Name = 'Safflower'

		SELECT * FROM UserGameItems UGI
			JOIN ITEMS I ON I.Id = UGI.ItemId
			WHERE UGI.UserGameId = 87

BEGIN TRANSACTION

END

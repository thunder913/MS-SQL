CREATE DATABASE WMS
GO
USE WMS
GO

--1

CREATE TABLE Clients(
	ClientId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Phone VARCHAR(12) NOT NULL
)

CREATE TABLE Mechanics(
	MechanicId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Address VARCHAR(255) NOT NULL
)

CREATE TABLE Models(
	ModelId INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs(
	JobId INT PRIMARY KEY IDENTITY,
	ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
	Status VARCHAR(11) CHECK(Status in ('Pending', 'In Progress','Finished')) DEFAULT 'Pending' NOT NULL,
	ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
	MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
	IssueDate DATE NOT NULL,
	FinishDate DATE
)

CREATE TABLE Orders(
	OrderId INT PRIMARY KEY IDENTITY,
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
	IssueDate DATE,
	Delivered BIT DEFAULT 0 NOT NULL
)

CREATE TABLE Vendors(
	VendorId INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts(
	PartId INT PRIMARY KEY IDENTITY,
	SerialNumber VARCHAR(50) UNIQUE NOT NULL,
	Description VARCHAR(255),
	Price DECIMAL(6,2) CHECK(Price>0),
	VendorId INT FOREIGN KEY  REFERENCES Vendors(VendorId),
	StockQty INT CHECK(StockQty>=0) DEFAULT 0
)

CREATE TABLE OrderParts(
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
	Quantity INT CHECK(Quantity>0) Default 1 NOT NULL
	PRIMARY KEY(OrderId, PartId)
)

CREATE TABLE PartsNeeded(
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
	Quantity INT CHECK(Quantity>0) DEFAULT 1 NOT NULL
	PRIMARY KEY (JobId, PartId)
)

--2

INSERT INTO Clients( FirstName, LastName, Phone)
VALUES
('Teri',	'Ennaco',	'570-889-5187'),
('Merlyn',	'Lawler',	'201-588-7810'),
('Georgene',	'Montezuma',	'925-615-5185'),
('Jettie',	'Mconnell',	'908-802-3564'),
('Lemuel',	'Latzke',	'631-748-6479'),
('Melodie',	'Knipp',	'805-690-1682'),
('Candida',	'Corbley',	'908-275-8357')

INSERT INTO Parts(SerialNumber,Description,Price,VendorId)
VALUES
('WP8182119',	'Door Boot Seal',	117.86, 2),
('W10780048',	'Suspension Rod',	42.81,	1),
('W10841140',	'Silicone Adhesive', 	6.77,	4),
('WPY055980',	'High Temperature Adhesive',	13.94,	3)

--3

SELECT * FROM Mechanics
	WHERE FirstName='Ryan'

UPDATE Jobs
	SET MechanicId=3, Status='In Progress'
	WHERE Status='Pending'

--4

DELETE FROM OrderParts
	WHERE OrderId=19

DELETE FROM Orders
	WHERE OrderId=19

--5

SELECT M.FirstName+' '+M.LastName'Mechanic', J.Status, J.IssueDate FROM Mechanics M
	JOIN Jobs J ON J.MechanicId=M.MechanicId
	ORDER BY M.MechanicId, J.IssueDate, J.JobId

--6

SELECT C.FirstName+' '+C.LastName'Client', DATEDIFF(DAY, J.IssueDate, '2017-04-24') 'Days Going', J.Status FROM Clients C
	JOIN Jobs J ON J.ClientId =C.ClientId
	WHERE J.Status!='Finished'
	ORDER BY [Days Going] DESC, C.ClientId

--7

SELECT M.FirstName+' '+M.LastName 'Mechanic', AVG(DATEDIFF(DAY, J.IssueDate, J.FinishDate))'Average Days' FROM Mechanics M
	JOIN Jobs J  ON J.MechanicId=M.MechanicId
	GROUP BY M.MechanicId,M.FirstName,M.LastName
	ORDER BY M.MechanicId

--8

SELECT M.FirstName+' '+M.LastName 'Available' FROM(
SELECT DISTINCT(M.MechanicId) FROM Mechanics M
	WHERE M.MechanicId NOT IN (
				SELECT M.MechanicId FROM Mechanics M
				LEFT JOIN Jobs J ON J.MechanicId = M.MechanicId
				WHERE J.FinishDate IS NULL AND J.JobId IS NOT NULL)
				) TEMP
	JOIN Mechanics M ON M.MechanicId=TEMP.MechanicId
	ORDER BY TEMP.MechanicId

--9

SELECT J.JobId, 
	CASE
	WHEN SUM(P.Price*OP.Quantity) IS NULL THEN 0.00
	ELSE
	SUM(P.Price*OP.Quantity)
	END
	'Total' FROM Jobs J
	LEFT JOIN Orders O ON O.JobId=J.JobId
	LEFT JOIN OrderParts OP ON OP.OrderId=O.OrderId
	LEFT JOIN Parts P ON P.PartId = OP.PartId
	WHERE J.Status='Finished'
	GROUP BY J.JobId
	ORDER BY Total DESC, J.JobId

--10

SELECT P.PartId, P.Description, PN.Quantity 'Required', P.StockQty 'In Stock', 0 'Ordered' FROM Parts P
	JOIN PartsNeeded PN ON PN.PartId=P.PartId
	JOIN Jobs J ON J.JobId = PN.JobId
	WHERE J.Status != 'Finished' AND P.StockQty < PN.Quantity
	ORDER BY P.PartId

--11

CREATE OR ALTER PROC usp_PlaceOrder(@JobsId INT, @PartSerial VARCHAR(50), @Quantity INT)
AS
BEGIN
	IF @Quantity<=0
		THROW 50012, 'Part quantity must be more than zero!', 1
	ELSE IF NOT EXISTS(SELECT * FROM Jobs J WHERE J.JobId=@JobsId)
		THROW 50013, 'Job not found!', 1
	ELSE IF EXISTS(SELECT * FROM Jobs J WHERE J.JobId=@JobsId AND J.Status='Finished')
		THROW 50011, 'This job is not active!', 1
	ELSE IF NOT EXISTS(SELECT * FROM Parts P WHERE P.SerialNumber=@PartSerial)
		THROW 50014, 'Part not found!', 1

		DECLARE @PartId INT
					SELECT @PartId=P.PartId FROM Parts P
						WHERE P.SerialNumber=@PartSerial


	DECLARE @ExistingOrderId INT
	SELECT @ExistingOrderId=O.OrderId FROM Orders O
		JOIN Jobs J ON J.JobId=O.JobId
		JOIN OrderParts OP ON OP.OrderId=O.OrderId
		WHERE O.IssueDate IS NULL AND J.JobId=@JobsId AND OP.PartId=@PartId

	IF (@ExistingOrderId IS NULL)
		BEGIN
			INSERT INTO Orders(JobId, IssueDate)
			VALUES
			(@JobsId, NULL)

			SELECT @ExistingOrderId=O.OrderId FROM Orders O
				JOIN Jobs J ON J.JobId=O.JobId
				WHERE O.IssueDate IS NULL AND J.JobId=@JobsId

					

					INSERT INTO OrderParts(OrderId,PartId,Quantity)
					VALUES
					(@ExistingOrderId, @PartId, @Quantity)
		END
	ELSE
		BEGIN
			UPDATE OrderParts
				SET Quantity+=@Quantity
				WHERE OrderId=@ExistingOrderId
		END
END


SELECT * FROM Jobs
EXEC usp_PlaceOrder 46, '285753A', 6
SELECT * FROM OrderParts


--12

CREATE FUNCTION udf_GetCost(@JobId INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @SUM DECIMAL(18,2)
	SELECT @SUM= SUM(P.Price*OP.Quantity) FROM Jobs J
		JOIN Orders O ON O.JobId =J.JobId
		JOIN OrderParts OP ON OP.OrderId=O.OrderId
		JOIN Parts P ON P.PartId=OP.PartId
		WHERE J.JobId=@JobId
		GROUP BY J.JobId
	IF @SUM IS NULL
		SET @SUM = 0
	RETURN @SUM
END

SELECT dbo.udf_GetCost(555)
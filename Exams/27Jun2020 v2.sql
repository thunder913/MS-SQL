CREATE DATABASE WMS
GO
USE WMS
GO
--1
CREATE TABLE Clients(
	ClientId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Phone VARCHAR(12) CHECK(LEN(Phone)=12) NOT NULL
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
	Status VARCHAR(11) CHECK(Status IN('Pending','In Progress','Finished')) DEFAULT 'Pending' NOT NULL,
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
	Price DECIMAL(8,2) CHECK(Price>0) NOT NULL,
	VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
	StockQty INT DEFAULT 0 NOT NULL
)

CREATE TABLE OrderParts(
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
	Quantity INT CHECK(Quantity>0) DEFAULT 1 NOT NULL
	PRIMARY KEY(OrderId, PartId)
)

CREATE TABLE PartsNeeded(
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
	Quantity INT CHECK(Quantity>0) DEFAULT 1 NOT NULL
	PRIMARY KEY (JobId, PartId)
)

--2

INSERT INTO Clients(FirstName,LastName,Phone)
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
('WP8182119',	'Door Boot Seal',	117.86,	2),
('W10780048',	'Suspension Rod',	42.81,	1),
('W10841140',	'Silicone Adhesive', 	6.77,	4),
('WPY055980',	'High Temperature Adhesive',	13.94,	3)


--3

UPDATE Jobs
	SET MechanicId=(SELECT MechanicId FROM Mechanics WHERE FirstName='Ryan' AND LastName='Harnos'), Status='In Progress'
	WHERE Status='Pending'

--4

DELETE FROM OrderParts
	WHERE OrderId=19

DELETE FROM Orders
	WHERE OrderId=19


	
--5
SELECT M.FirstName+' '+M.LastName 'Mechanic', J.Status, J.IssueDate FROM Mechanics M
	JOIN Jobs J ON J.MechanicId=M.MechanicId
	order by M.MechanicId, J.IssueDate, J.JobId

--6

SELECT C.FirstName+' '+C.LastName 'Client', DATEDIFF(DAY, J.IssueDate, '4-24-2017') 'Days Going', J.Status FROM Clients C
	JOIN Jobs J ON J.ClientId=C.ClientId
	WHERE J.Status!='Finished'
	ORDER BY [Days Going] DESC, C.ClientId

--7

SELECT M.FirstName+' '+M.LastName 'Mechanic', AVG(DATEDIFF(DAY, J.IssueDate, J.FinishDate)) 'Average Days' FROM Mechanics M
	JOIN Jobs J ON J.MechanicId=M.MechanicId
	GROUP BY M.MechanicId,M.FirstName, M.LastName
	ORDER BY M.MechanicId

--8


SELECT M.FirstName+' '+M.LastName 'Available' FROM Mechanics M
	WHERE M.MechanicId NOT IN (SELECT M.MechanicId FROM Mechanics M
				JOIN Jobs J ON J.MechanicId=M.MechanicId
				WHERE J.FinishDate IS NULL)
				ORDER BY M.MechanicId

--9

SELECT J.JobId, 
CASE 
	WHEN SUM(OP.Quantity*P.Price) IS NULL THEN 0.00
	ELSE SUM(OP.Quantity*P.Price) END 'Total' FROM Jobs J
	LEFT JOIN Orders O ON O.JobId=J.JobId
	LEFT JOIN OrderParts OP ON OP.OrderId=O.OrderId
	LEFT JOIN Parts P ON P.PartId=OP.PartId
	WHERE J.FinishDate IS NOT NULL
	GROUP BY J.JobId
	ORDER BY Total DESC, J.JobId

--10


	SELECT P.PartId,P.Description, ISNULL(SUM(PN.Quantity),0) 'Required', ISNULL(SUM(P.StockQty),0) 'In Stock', ISNULL(SUM(OP.Quantity),0) 'Ordered' FROM Jobs J
		LEFT JOIN PartsNeeded PN ON PN.JobId=J.JobId
		LEFT JOIN Parts P ON P.PartId=PN.PartId
		LEFT JOIN Orders O ON O.JobId=J.JobId
		LEFT JOIN OrderParts OP ON OP.OrderId=O.OrderId
		WHERE J.Status!='Finished'
		GROUP BY P.PartId, P.Description
		HAVING ISNULL(SUM(PN.Quantity),0)> ISNULL(SUM(P.StockQty),0)+ ISNULL(SUM(OP.Quantity),0)
		ORDER BY P.PartId


--11 DOESNT WORK

CREATE OR ALTER PROC usp_PlaceOrder(@jobId INT, @serialNumber VARCHAR(50), @quantity INT)
AS
BEGIN
	IF @quantity<=0 
		BEGIN
			THROW 50012, 'Part quantity must be more than zero!', 1
		END
	ELSE IF EXISTS(SELECT * FROM Jobs J WHERE J.JobId=@jobId AND J.Status='Finished')
		BEGIN
			THROW 50011, 'This job is not active!', 1
		END
	ELSE IF NOT EXISTS(SELECT * FROM Jobs J WHERE J.JobId=@jobId)
		BEGIN
			THROW 50013, 'Job not found!', 1
		END
	ELSE IF NOT EXISTS(SELECT * FROM Parts P WHERE P.SerialNumber=@serialNumber)
		BEGIN
			THROW 50014, 'Part not found!', 1
		END

	DECLARE @orderId INT = (SELECT OrderId FROM Orders WHERE IssueDate IS NULL AND JobId=@jobId)
	DECLARE @partId INT = (SELECT PartId FROM Parts WHERE SerialNumber=@serialNumber)

	IF EXISTS(SELECT * FROM OrderParts WHERE OrderId=@orderId AND PartId=@partId)
		BEGIN
			UPDATE OrderParts
				SET Quantity+=@quantity
				WHERE PartId=@partId AND OrderId=@orderId
		END
	ELSE IF @orderId IS NULL
		BEGIN
			INSERT INTO Orders(JobId, IssueDate)
			VALUES
			(@jobId, NULL)

			SET @orderId = (SELECT TOP(1) OrderId  FROM Orders ORDER BY OrderId DESC)
		END
	ELSE
		BEGIN	
			INSERT INTO OrderParts(OrderId, PartId, Quantity)
			VALUES
			(@orderId, @partId, @quantity)
		END
END
SELECT * FROM Parts
SELECT * FROM Orders

UPDATE Jobs
	SET Status='In Progress'
	WHERE JobId=1

EXEC dbo.usp_PlaceOrder 45, '285753A', 9
EXEC dbo.usp_PlaceOrder 45, 'WPW10512946', 9
EXEC dbo.usp_PlaceOrder 45, '285811', 9

SELECT * FROM OrderParts
	

--12

ALTER FUNCTION udf_GetCost(@jobId INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @sum DECIMAL(18,2)= (SELECT SUM(OP.Quantity*P.Price)'Sum' FROM Orders O
		JOIN OrderParts OP ON OP.OrderId=O.OrderId
		JOIN Parts P ON P.PartId=OP.PartId
		WHERE O.JobId=@jobId)
	IF @sum IS NULL
		RETURN 0
	RETURN @sum
END

SELECT dbo.udf_GetCost(1)

SELECT dbo.udf_GetCost1(1)
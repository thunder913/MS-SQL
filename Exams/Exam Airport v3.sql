CREATE DATABASE Airport
GO
USE AIRPORT
GO

--1
CREATE TABLE Planes(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(30) NOT NULL,
	Seats INT NOT NULL,
	Range INT NOT NULL
)

CREATE TABLE Flights(
	Id INT PRIMARY KEY IDENTITY,
	DepartureTime DATETIME,
	ArrivalTime DATETIME,
	Origin NVARCHAR(50) NOT NULL,
	Destination NVARCHAR(50) NOT NULL,
	PlaneId INT FOREIGN KEY REFERENCES Planes(Id) NOT NULL
)

CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Age INT NOT NULL,
	Address NVARCHAR(30) NOT NULL,
	PassportId NVARCHAR(11) NOT NULL
)


CREATE TABLE LuggageTypes(
	Id INT PRIMARY KEY IDENTITY,
	Type NVARCHAR(30) NOT NULL
)

CREATE TABLE Luggages(
	Id INT PRIMARY KEY IDENTITY,
	LuggageTypeId INT FOREIGN KEY REFERENCES LuggageTypes(Id) NOT NULL,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL
)

CREATE TABLE Tickets(
	Id INT PRIMARY KEY IDENTITY,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
	FlightId INT FOREIGN KEY REFERENCES Flights(Id) NOT NULL,
	LuggageId INT FOREIGN KEY REFERENCES Luggages(Id) NOT NULL,
	Price DECIMAL(18,2) NOT NULL
)

--2

INSERT INTO Planes(Name, Seats, Range)
VALUES
('Airbus 336',	112,	5132),
('Airbus 330',	432,	5325),
('Boeing 369',	231,	2355),
('Stelt 297',	254,	2143),
('Boeing 338',	165,	5111),
('Airbus 558',	387,	1342),
('Boeing 128',	345,	5541)


INSERT INTO LuggageTypes(Type)
VALUES
('Crossbody Bag'),
('School Backpack'),
('Shoulder Bag')


--3

UPDATE T
	SET T.Price*=1.13
	FROM Tickets T 
	JOIN Flights F ON F.Id=T.FlightId
	WHERE F.Destination='Carlsbad'

	SELECT * FROM Tickets T
		JOIN Flights F ON F.Id=T.FlightId
		WHERE F.Destination='Carlsbad'

--4

DELETE FROM Tickets
	WHERE FlightId IN (SELECT Id FROM Flights WHERE Destination='Ayn Halagim')

DELETE FROM Flights
	WHERE Destination='Ayn Halagim'

	select * from Flights
		WHERE Destination='Ayn Halagim'

--5

SELECT Id,Name,Seats,Range FROM Planes
	WHERE Name LIKE '%tr%'
	ORDER BY Id, Name, Seats, Range

--6

SELECT F.Id, SUM(T.Price) 'Price' FROM Flights F
	JOIN Tickets T ON T.FlightId=F.Id
	GROUP BY F.Id
	ORDER BY Price DESC, F.Id

--7

SELECT P.FirstName+' '+P.LastName 'Full Name', F.Origin, F.Destination FROM Passengers P
	JOIN Tickets T ON T.PassengerId=P.Id
	JOIN Flights F ON F.Id=T.FlightId
	ORDER BY [Full Name], Origin, Destination

--8

SELECT P.FirstName, P.LastName, P.Age FROM Passengers P
	FULL JOIN Tickets T ON T.PassengerId=P.Id
	WHERE T.Id IS NULL
	GROUP BY P.FirstName, P.LastName, P.Age
	ORDER BY P.Age DESC, P.FirstName, P.LastName

--9

SELECT P.FirstName+' '+P.LastName 'Full Name',PL.Name, F.Origin +' - '+F.Destination 'Trip', LT.Type 'Luggage Type'  FROM Passengers P
	JOIN Tickets T ON T.PassengerId=P.Id
	JOIN Flights F ON F.Id=T.FlightId
	JOIN Planes PL ON PL.Id=F.PlaneId
	JOIN Luggages L ON L.Id=T.LuggageId
	JOIN LuggageTypes LT ON LT.Id=L.LuggageTypeId
	WHERE T.Id IS NOT NULL
	ORDER BY [Full Name], PL.Name, Origin, Destination, [Luggage Type]

--10

SELECT P.Name, P.Seats, COUNT(T.Id) 'Passengers Count' FROM Planes P
	LEFT JOIN Flights F ON F.PlaneId=P.Id
	LEFT JOIN Tickets T ON T.FlightId=F.Id
	GROUP BY P.Name,P.Seats
	ORDER BY [Passengers Count] DESC, P.Name, P.Seats

--11

CREATE OR ALTER FUNCTION udf_CalculateTickets(@origin NVARCHAR(50), @destination NVARCHAR(50), @peopleCount INT)
RETURNS NVARCHAR(100)
AS
BEGIN
DECLARE @flightId INT
SET @flightId = (SELECT F.Id FROM Flights F WHERE F.Origin=@origin AND F.Destination=@destination)
	IF @peopleCount <= 0
		BEGIN
			RETURN 'Invalid people count!'
		END
	ELSE IF @flightId IS NULL
		BEGIN
			RETURN 'Invalid flight!'
		END

	RETURN 'Total price ' + CONVERT(VARCHAR, (SELECT @peopleCount*T.Price FROM Flights F JOIN Tickets T ON T.FlightId=F.Id WHERE F.Id=@flightId))
END


SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', 33)
SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', -1)

SELECT dbo.udf_CalculateTickets('Invalid','Rancabolang', 33)


--12

ALTER PROC usp_CancelFlights
AS
BEGIN
	UPDATE Flights
		SET DepartureTime=NULL, ArrivalTime=NULL
		WHERE ArrivalTime>DepartureTime
END	

EXEC usp_CancelFlights

SELECT DATEDIFF(SECOND, DepartureTime,ArrivalTime) FROM Flights
	WHERE ArrivalTime<DepartureTime


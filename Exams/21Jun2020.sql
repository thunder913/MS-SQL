CREATE DATABASE TripService
USE TripService

CREATE TABLE Cities(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	CountryCode NVARCHAR(2) NOT NULL
)

CREATE TABLE Hotels(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	CityId INT NOT NULL FOREIGN KEY REFERENCES Cities(Id),
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(18,2)
)

CREATE TABLE Rooms(
	Id INT PRIMARY KEY IDENTITY,
	Price DECIMAL(18,2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT NOT NULL FOREIGN KEY REFERENCES Hotels(Id)
)

CREATE TABLE Trips(
	Id INT PRIMARY KEY IDENTITY,
	RoomId INT NOT NULL FOREIGN KEY REFERENCES Rooms(Id),
	BookDate DATE NOT NULL,
	ArrivalDate DATE NOT NULL,
	ReturnDate DATE NOT NULL,
	CancelDate Date,
	CHECK(BookDate<ArrivalDate),
	CHECK(ArrivalDate<ReturnDate)
)

CREATE TABLE Accounts(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName NVARCHAR(50) NOT NULL,
	CityId INT NOT NULL FOREIGN KEY REFERENCES Cities(Id),
	BirthDate DATE NOT NULL,
	Email NVARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips(
	AccountId INT NOT NULL FOREIGN KEY REFERENCES Accounts(Id),
	TripId INT NOT NULL FOREIGN KEY REFERENCES Trips(Id),
	Luggage INT NOT NULL CHECK(Luggage>=0),
	PRIMARY KEY (AccountId, TripId)
)

GO

--2

INSERT INTO Accounts(FirstName,MiddleName,LastName,CityId, BirthDate, Email)
VALUES
('John',	'Smith',	'Smith',	34,	'1975-07-21',	'j_smith@gmail.com'),
('Gosho',	NULL,	'Petrov',	11,	'1978-05-16',	'g_petrov@gmail.com'),
('Ivan',	'Petrovich',	'Pavlov',	59,'1849-09-26','i_pavlov@softuni.bg'),
('Friedrich',	'Wilhelm',	'Nietzsche',	2,	'1844-10-15',	'f_nietzsche@softuni.bg')

INSERT INTO Trips(RoomId, BookDate,ArrivalDate, ReturnDate, CancelDate)
VALUES
(101,	'2015-04-12',	'2015-04-14',	'2015-04-20',	'2015-02-02'),
(102,	'2015-07-07',	'2015-07-15',	'2015-07-22',	'2015-04-29'),
(103,	'2013-07-17',	'2013-07-23',	'2013-07-24',	NULL),
(104,	'2012-03-17',	'2012-03-31',	'2012-04-01',	'2012-01-10'),
(109,	'2017-08-07',	'2017-08-28',	'2017-08-29',	NULL)

GO
--3

UPDATE Rooms
	SET Price*=1.14
	WHERE HotelId IN (5,7,9)

GO

--4

DELETE FROM AccountsTrips
	WHERE AccountId = 47

--5

SELECT A.FirstName,A.LastName,FORMAT(A.BirthDate, 'MM-dd-yyyy') 'BirthDate',C.Name,A.Email FROM Accounts A
	JOIN Cities C ON C.Id=A.CityId
	WHERE A.Email LIKE 'e%'
	ORDER BY C.Name

--6

SELECT C.Name, COUNT(*) 'Hotels' FROM Cities C
	JOIN Hotels H ON H.CityId = C.Id
	GROUP BY C.Id,C.Name
	HAVING COUNT(*)>0
	ORDER BY COUNT(*) DESC, C.Name
	
--7

	SELECT * FROM(
SELECT AT.AccountId, A.FirstName + ' ' + A.LastName 'FullName', MAX(DATEDIFF(DAY, T.ArrivalDate, T.ReturnDate)) 'LongestTrip', MIN(DATEDIFF(DAY, T.ArrivalDate, T.ReturnDate)) 'ShortestTrip' FROM Accounts A
	JOIN AccountsTrips AT ON AT.AccountId = A.Id
	JOIN Trips T ON T.Id = AT.TripId
	WHERE T.CancelDate IS NULL AND A.MiddleName IS NULL
	GROUP BY AT.AccountId, A.FirstName, A.LastName) TEMP
	ORDER BY TEMP.LongestTrip DESC, TEMP.ShortestTrip

--8

SELECT TOP(10) C.Id, C.Name, C.CountryCode, COUNT(*) 'Accounts' FROM Cities C
	JOIN Accounts A ON A.CityId = C.Id
	GROUP BY C.Id, C.Name, C.CountryCode
	ORDER BY COUNT(*) DESC

--9

SELECT A.Id, A.Email, HOME.Name 'City', COUNT(*) 'Trips'  FROM Accounts A
	JOIN Cities HOME ON HOME.Id = A.CityId
	JOIN AccountsTrips AT ON AT.AccountId = A.Id
	JOIN Trips T ON T.Id = AT.TripId
	JOIN Rooms R ON R.Id = T.RoomId
	JOIN Hotels H ON H.Id = R.HotelId
	JOIN Cities HOTEL ON HOTEL.Id = H.CityId
	WHERE HOTEL.Id = HOME.Id
	GROUP BY A.Id, A.Email, HOME.Name
	ORDER BY COUNT(*) DESC, A.Id

--10

SELECT T.Id, 
	CASE
		WHEN A.MiddleName IS NOT NULL THEN  A.FirstName + ' ' + A.MiddleName + ' '+A.LastName 
		ELSE
			A.FirstName + ' ' + A.LastName
		END
		'Full Name', Home.Name 'From', C.Name 'To',
	CASE
		WHEN CancelDate IS NULL THEN CONVERT(VARCHAR, DATEDIFF(DAY, T.ArrivalDate, T.ReturnDate)) + ' days'
		ELSE 'Canceled'
	END
		'Duration'
	FROM Trips T
	JOIN AccountsTrips AT ON AT.TripId = T.Id
	JOIN Accounts A ON A.Id = AT.AccountId
	JOIN Rooms R ON R.Id = T.RoomId
	JOIN Hotels H ON H.Id = R.HotelId
	JOIN Cities C ON C.Id = H.CityId
	JOIN Cities Home ON Home.Id = A.CityId
	ORDER BY [Full Name], T.Id


--11

CREATE OR ALTER FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATE, @People INT)
RETURNS VARCHAR(200)
BEGIN
	
	DECLARE @RoomId INT
	DECLARE @RoomType VARCHAR(50)
	DECLARE @Beds INT
	DECLARE @TotalPrice DECIMAL(18,2)

	

	SELECT TOP(1) @RoomId = R.Id, @RoomType = R.Type, @Beds = R.Beds, @TotalPrice = ((H.BaseRate+R.Price)*@People) FROM Rooms R
		JOIN Hotels H ON H.Id = R.HotelId
		JOIN Trips T ON T.RoomId = R.Id
		WHERE H.Id = @HotelId AND R.Id NOT IN(
										SELECT R.Id FROM Rooms R
										JOIN Hotels H ON H.Id = R.HotelId AND H.Id = @HotelId
										JOIN Trips T ON T.RoomId = R.Id
										WHERE (@DATE BETWEEN T.ArrivalDate AND T.ReturnDate) OR T.CancelDate IS NOT NULL) 
						AND R.Beds>=@People
		ORDER BY ((H.BaseRate+R.Price)*@People) DESC
		
	DECLARE @ToReturn VARCHAR(MAX)

	IF(@RoomId IS NULL)
		BEGIN
			SET @ToReturn = 'No rooms available'
		END
	ELSE
		BEGIN
			SET @ToReturn = 'Room '+ CONVERT(VARCHAR, @RoomId) +': '+ @RoomType +' ('+ CONVERT(VARCHAR, @Beds) +' beds) - $'+ CONVERT(VARCHAR, @TotalPrice)
		END
	RETURN @ToReturn
END


SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)

SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)

--12

CREATE OR ALTER PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN
	DECLARE @People INT

	SELECT @People = COUNT(*) FROM Accounts A
		JOIN AccountsTrips AT ON AT.AccountId = A.Id
		JOIN Trips T ON T.Id = AT.TripId
		WHERE T.Id=@TripId

	IF (EXISTS(SELECT * FROM Trips T
			JOIN Rooms RNEW ON RNEW.Id=@TargetRoomId
			JOIN Rooms ROLD ON ROLD.Id=T.RoomId
				WHERE T.Id = @TripId AND RNEW.HotelId!=ROLD.HotelId))
				THROW 50001, 'Target room is in another hotel!', 1
	IF(EXISTS(SELECT * FROM Rooms R
		WHERE R.Id = @TargetRoomId AND R.Beds<@People))
			THROW 50002, 'Not enough beds in target room!', 1
	ELSE
		BEGIN
		UPDATE Trips
			SET RoomId=@TargetRoomId
			WHERE Id=@TripId
	END
END

CREATE DATABASE ColonialJourney
GO
USE ColonialJourney
GO

--1

CREATE TABLE Planets(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports(
	Id INT PRIMARY KEY IDENTiTY,
	Name VARCHAR(50) NOT NULL,
	PlanetId INT FOREIGN KEY REFERENCES Planets(Id) NOT NULL
)

CREATE TABLE Spaceships(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) UNIQUE NOT NULL,
	BirthDate DATE NOT NULL
)

CREATE TABLE Journeys(
	Id INT PRIMARY KEY IDENTITY,
		JourneyStart DATETIME NOT NULL,
		JourneyEnd DATETIME NOT NULL,
		Purpose VARCHAR(11) CHECK(Purpose IN ('Medical','Technical','Educational','Military')),
		DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id) NOT NULL,
		SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id) NOT NULL
)

CREATE TABLE TravelCards(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber VARCHAR(10) UNIQUE NOT NULL,
	JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney IN ('Pilot','Engineer','Cleaner','Cook','Trooper')),
	ColonistId INT FOREIGN KEY REFERENCES Colonists(Id) NOT NULL,
	JourneyId INT FOREIGN KEY REFERENCES Journeys(Id) NOT NULL
)

--2

INSERT INTO Planets(Name)
VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')


INSERT INTO Spaceships(Name,Manufacturer, LightSpeedRate)
VALUES
('Golf',	'VW',	3),
('WakaWaka',	'Wakanda',	4),
('Falcon9',	'SpaceX',	1),
('Bed',	'Vidolov',	6)

--3

UPDATE Spaceships
	SET LightSpeedRate+=1
	WHERE Id BETWEEN 8 AND 12


--4

DELETE FROM TravelCards
	WHERE JourneyId IN (1,2,3)

DELETE FROM Journeys
	WHERE Id IN (1,2,3)

--5

SELECT J.Id, FORMAT(J.JourneyStart,'dd/MM/yyyy') 'JourneyStart', FORMAT(J.JourneyEnd,'dd/MM/yyyy') 'JourneyEnd' FROM Journeys J
	WHERE J.Purpose='Military'
	ORDER BY J.JourneyStart

--6

SELECT C.Id, CONCAT(C.FirstName,' ',C.LastName)'full_name' FROM Colonists C
	JOIN TravelCards TC ON TC.ColonistId=C.Id
	WHERE TC.JobDuringJourney='Pilot'
	ORDER BY C.Id

--7

SELECT COUNT(*) 'count' FROM Colonists C
	JOIN TravelCards TC ON TC.ColonistId=C.Id
	JOIN Journeys J ON J.Id=TC.JourneyId
	WHERE J.Purpose = 'Technical'

--8

SELECT S.Name,S.Manufacturer FROM Spaceships S
	JOIN Journeys J ON J.SpaceshipId=S.Id
	JOIN TravelCards TC ON TC.JourneyId=J.Id
	JOIN Colonists C ON C.Id=TC.ColonistId
	WHERE TC.JobDuringJourney='Pilot' AND DATEDIFF(YEAR, C.BirthDate, '01/01/2019')<30
	ORDER BY S.Name

--9

SELECT P.Name, COUNT(*) 'Count' FROM Planets P
	JOIN Spaceports SP ON SP.PlanetId=P.Id
	JOIN Journeys J ON J.DestinationSpaceportId=SP.Id
	GROUP BY P.Name
	ORDER BY Count DESC, P.Name

--10
SELECT * FROM(
SELECT TC.JobDuringJourney, CONCAT(C.FirstName,' ', C.LastName) 'FullName', DENSE_RANK() OVER (PARTITION BY TC.JobDuringJourney ORDER BY C.Birthdate ASC) 'JobRank' FROM Colonists C
	JOIN TravelCards TC ON TC.ColonistId=C.Id) TEMP
	WHERE TEMP.JobRank=2

--11

CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR(30))
RETURNS INT
AS
BEGIN
DECLARE @Count INT
SELECT @Count =COUNT(*) FROM TravelCards TC
	JOIN Journeys J ON J.Id= TC.JourneyId
	JOIN Spaceports SP ON SP.Id=J.DestinationSpaceportId
	JOIN Planets P ON P.Id=SP.PlanetId
	WHERE P.Name=@PlanetName
RETURN @Count
END

SELECT dbo.udf_GetColonistsCount('Otroyphus')

--12

CREATE or alter PROC usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM Journeys WHERE Id=@JourneyId)
		THROW 50001, 'The journey does not exist!', 1
	ELSE IF EXISTS(SELECT * FROM Journeys WHERE Purpose=@NewPurpose AND Id=@JourneyId)
		THROW 50002, 'You cannot change the purpose!',1
	ELSE 
	BEGIN
	UPDATE Journeys
		SET Purpose=@NewPurpose
		WHERE Id=@JourneyId
	END
END

EXEC usp_ChangeJourneyPurpose 5, 'Technical'

EXEC usp_ChangeJourneyPurpose 2, 'Educational'
EXEC usp_ChangeJourneyPurpose 196, 'Technical'

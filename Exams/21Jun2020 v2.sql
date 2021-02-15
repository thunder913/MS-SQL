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
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL,
	PlanetId INT FOREIGN KEY REFERENCES Planets(Id)
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
	Purpose VARCHAR(11) CHECK(Purpose IN ('Medical','Technical','Educational', 'Military')) NOT NULL,
	DestinationSpaceportId INT FOREIGN KEY REFERENCES Spaceports(Id) NOT NULL,
	SpaceshipId INT FOREIGN KEY REFERENCES Spaceships(Id) NOT NULL
)

CREATE TABLE TravelCards(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber VARCHAR(10) UNIQUE NOT NULL,
	JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney IN ('Pilot','Engineer', 'Trooper', 'Cleaner','Cook')) NOT NULL,
	ColonistId INT FOREIGN KEY REFERENCES Colonists(Id) NOT NULL,
	JourneyId INT FOREIGN KEY REFERENCES Journeys(Id) NOT NULL
)

--2

INSERT INTO Planets(Name)
VALUES
('Mars'),('Earth'),('Jupiter'),('Saturn')

INSERT INTO Spaceships(Name,Manufacturer,LightSpeedRate)
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

SELECT Id, FORMAT(JourneyStart,'dd/MM/yyyy') 'JourneyStart', FORMAT(JourneyEnd, 'dd/MM/yyyy') 'JourneyEnd' FROM Journeys
	WHERE Purpose='Military'
	ORDER BY JourneyStart

--6

SELECT C.Id, C.FirstName+' '+C.LastName 'full_name' FROM TravelCards TC
	JOIN Colonists C ON C.Id=TC.ColonistId
	WHERE JobDuringJourney ='Pilot'
	ORDER BY C.Id 

--7

SELECT COUNT(*) 'count' FROM Journeys J
	RIGHT JOIN TravelCards TC ON TC.JourneyId=J.Id
	RIGHT JOIN Colonists C ON C.Id=TC.ColonistId
	WHERE Purpose='Technical'

--8

SELECT SS.Name, SS.Manufacturer FROM Colonists C
	JOIN TravelCards TC ON TC.ColonistId=C.Id
	JOIN Journeys J ON J.Id=TC.JourneyId
	JOIN Spaceships SS ON SS.Id=J.SpaceshipId
	WHERE TC.JobDuringJourney='Pilot' AND DATEDIFF(YEAR, C.BirthDate, '01/01/2019')<30
	ORDER BY SS.Name

--9

SELECT P.Name, COUNT(J.Id) 'JourneysCount' FROM Planets P
	JOIN Spaceports SP ON SP.PlanetId=P.Id
	JOIN Journeys J ON J.DestinationSpaceportId=SP.Id
	GROUP BY P.Name
	ORDER BY JourneysCount DESC, P.Name

--10

SELECT * FROM(
SELECT  TC.JobDuringJourney, C.FirstName+' '+C.LastName 'FullName', DENSE_RANK() OVER(PARTITION BY TC.JobDuringJourney ORDER BY C.BirthDate) 'JobRank' FROM Colonists C
	JOIN TravelCards TC ON TC.ColonistId=C.Id) T
	WHERE T.JobRank=2

--11

CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR (30))
RETURNS INT
BEGIN
	DECLARE @count INT = (SELECT COUNT(*) FROM Planets P
		JOIN Spaceports SP ON SP.PlanetId=P.Id
		JOIN Journeys J ON J.DestinationSpaceportId=SP.Id
		JOIN TravelCards TC ON TC.JourneyId=J.Id
		WHERE P.Name=@PlanetName)
	RETURN @count
END

--12

CREATE PROC usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM Journeys J WHERE J.Id=@JourneyId)
		BEGIN
			RAISERROR('The journey does not exist!', 16,1)
		END
		ELSE IF (SELECT J.Purpose FROM Journeys J WHERE J.Id=@JourneyId)=@NewPurpose
			BEGIN
				RAISERROR('You cannot change the purpose!',16,1)
			END

	UPDATE Journeys
		SET Purpose=@NewPurpose
		WHERE Id=@JourneyId
END


EXEC usp_ChangeJourneyPurpose 4, 'Technical'
EXEC usp_ChangeJourneyPurpose 2, 'Educational'
EXEC usp_ChangeJourneyPurpose 196, 'Technical'

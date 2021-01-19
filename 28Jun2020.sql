CREATE DATABASE ColonialJourney

USE ColonialJourney

 CREATE TABLE Planets(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(30) NOT NULL
 )

CREATE TABLE Spaceports(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL,
	PlanetId INT NOT NULL FOREIGN KEY REFERENCES Planets(Id)
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
	Purpose VARCHAR(11) CHECK(Purpose IN('Medical', 'Technical', 'Educational', 'Military')),
	DestinationSpaceportId INT NOT NULL FOREIGN KEY REFERENCES Spaceports(Id),
	SpaceshipId INT NOT NULL FOREIGN KEY REFERENCES Spaceships(Id)
)

CREATE TABLE TravelCards(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber VARCHAR(10) NOT NULL UNIQUE,
	JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney in('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
	ColonistId INT NOT NULL FOREIGN KEY REFERENCES Colonists(Id),
	JourneyId INT NOT NULL FOREIGN KEY REFERENCES Journeys(Id)
)


--2

INSERT INTO Planets(Name)
VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')

INSERT INTO Spaceships(Name, Manufacturer, LightSpeedRate)
VALUES
('Golf', 'VW', 3),
('WakaWaka', 'Wakanda', 4),
('Falcon9', 'SpaceX', 1),
('Bed', 'Vidolov', 6)

--3

UPDATE Spaceships
	SET LightSpeedRate+=1
	WHERE Id BETWEEN 8 AND 12

--4

DELETE FROM TravelCards
	WHERE JourneyId<= 3
	
DELETE TOP(3) FROM Journeys

--5

SELECT Id, FORMAT(JourneyStart, 'dd/MM/yyyy') JourneyStart, FORMAT(JourneyEnd, 'dd/MM/yyyy') JourneyEnd FROM Journeys J
	WHERE J.Purpose='Military'
	ORDER BY J.JourneyStart

--6

SELECT C.Id, C.FirstName+' '+C.LastName full_name FROM TravelCards TC
	JOIN Colonists C ON C.Id=TC.ColonistId
	WHERE TC.JobDuringJourney='Pilot'
	ORDER BY TC.ColonistId

--7

SELECT COUNT(*) count FROM Colonists C
	JOIN TravelCards TC ON TC.ColonistId = C.Id
	JOIN Journeys J ON J.Id=TC.JourneyId
	WHERE J.Purpose='Technical'

--8

SELECT SS.Name, SS.Manufacturer FROM TravelCards TC
	JOIN Colonists C ON C.Id = TC.ColonistId
	JOIN Journeys J ON J.Id = TC.JourneyId
	JOIN Spaceships SS ON SS.Id = J.SpaceshipId
	WHERE TC.JobDuringJourney ='Pilot' AND DATEDIFF(YEAR, C.BirthDate, '01/01/2019')<30
	ORDER BY SS.Name

--9

SELECT P.Name, COUNT(*) FROM Journeys J
	JOIN Spaceports S ON S.Id = J.DestinationSpaceportId
	JOIN Planets P ON P.Id = S.PlanetId
	GROUP BY P.Name
	ORDER BY COUNT(*) DESC, P.Name

--10

SELECT * FROM(
SELECT TC.JobDuringJourney, C.FirstName+' '+C.LastName 'FullName', DENSE_RANK() OVER(PARTITION BY TC.JobDuringJourney ORDER BY C.BirthDate) 'JobRank' FROM Colonists C
	JOIN TravelCards TC ON TC.ColonistId=C.Id) TEMP
	WHERE TEMP.JobRank=2


--11
CREATE FUNCTION dbo.udf_GetColonistsCount(@PlanetName VARCHAR (30)) 
RETURNS INT
AS
BEGIN
	DECLARE @Count INT
	SELECT @Count = COUNT(*) FROM Planets P
		JOIN Spaceports SP ON SP.PlanetId = P.Id
		JOIN Journeys J ON J.DestinationSpaceportId = SP.Id
		JOIN TravelCards TC ON TC.JourneyId = J.Id
		WHERE P.Name=@PlanetName
	RETURN @Count
END

SELECT dbo.udf_GetColonistsCount('Otroyphus')


--12


CREATE or ALTER PROC usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
BEGIN
	IF EXISTS(SELECT * FROM Journeys J
				WHERE J.Id = @JourneyId)
		BEGIN
			IF EXISTS(SELECT J.Purpose FROM Journeys J
						WHERE J.Id = @JourneyId)
				BEGIN
				RAISERROR('You cannot change the purpose!', 16,0)
				END
				ELSE
				BEGIN
					UPDATE Journeys
						SET Purpose = @NewPurpose
						WHERE Id=@JourneyId
				END
		END
	ELSE
		BEGIN
		RAISERROR('The journey does not exist!', 16,0)
		END
END

EXEC usp_ChangeJourneyPurpose 4, 'Technical'
EXEC usp_ChangeJourneyPurpose 2, 'Educational'
EXEC usp_ChangeJourneyPurpose 196, 'Technical'


--Exam 28 Jun 2020

CREATE DATABASE ColonialJourney
USE ColonialJourney

CREATE TABLE Planets
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PlanetId INT NOT NULL FOREIGN KEY REFERENCES Planets(Id)
)

CREATE TABLE Spaceships
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) UNIQUE,
	BirthDate DATE NOT NULL
)

CREATE TABLE Journeys
(
	Id INT PRIMARY KEY IDENTITY,
	JourneyStart DATETIME NOT NULL,
	JourneyEnd DATETIME NOT NULL,
	Purpose VARCHAR(11) CHECK(Purpose in('Medical', 'Technical', 'Educational', 'Military')),
	DestinationSpaceportId INT NOT NULL REFERENCES Spaceports(Id),
	SpaceshipId INT NOT NULL REFERENCES Spaceships(Id)
)

CREATE TABLE TravelCards
(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber VARCHAR(10) NOT NULL UNIQUE,
	JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney in('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
	ColonistId INT NOT NULL REFERENCES Colonists(Id),
	JourneyId INT NOT NULL REFERENCES Journeys(Id)
)

--2
INSERT INTO Planets(Name)
VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')

INSERT INTO Spaceships(Name,Manufacturer,LightSpeedRate)
VALUES
('Golf', 'VW', 3),
('WakaWaka', 'Wakanda' ,4),
('Falcon9',	'SpaceX', 1),
('Bed' , 'Vidolov',	6)

--3

UPDATE Spaceships
	SET LightSpeedRate += 1
	WHERE Id BETWEEN 8 AND 12

--4

DELETE FROM TravelCards
	WHERE JourneyId <= 3
delete from Journeys
	WHERE ID<=3

--5

SELECT ID, FORMAT(JourneyStart, 'dd/MM/yyyy') AS JourneyStart, FORMAT(JourneyEnd,'dd/MM/yyyy') AS JourneyEnd FROM Journeys
	WHERE Purpose = 'Military'
	ORDER BY JourneyStart

--6

SELECT C.ID, FirstName + ' ' + LastName as FullName FROM Colonists C
	JOIN TravelCards TC ON C.Id = TC.ColonistId
	WHERE TC.JobDuringJourney = 'Pilot'
	ORDER BY C.ID

--7

SELECT COUNT(*) FROM TravelCards TC
	JOIN Journeys J ON J.Id = TC.JourneyId
	WHERE J.Purpose = 'Technical'

--8
SELECT S.Name AS [Name], S.Manufacturer FROM TravelCards TC
	JOIN Colonists C ON C.Id = TC.ColonistId
	JOIN Journeys J ON J.Id = TC.JourneyId
	JOIN Spaceships S ON S.Id = J.SpaceshipId
	WHERE TC.JobDuringJourney = 'Pilot' AND DATEDIFF(YEAR,C.BirthDate, '01/01/2019')<= 30
	ORDER BY S.Name

--9
SELECT P.Name, COUNT(*) FROM Journeys J
	JOIN Spaceports SP ON SP.Id = J.DestinationSpaceportId
	JOIN Planets P ON P.Id = SP.PlanetId
	GROUP BY P.Name
	ORDER BY COUNT(*) DESC, P.Name

--10
SELECT JobDuringJourney, C.FirstName + ' ' + C.LastName AS FullName ,'2' AS JobRank FROM(
SELECT TEMP.JobDuringJourney,MIN(COL.BirthDate) over (partition by TEMP.JobDuringJourney) AS FinalBirthDate, COL.Id FROM(
SELECT TC.JobDuringJourney, C.Id, MIN(BIRTHDATE) over (partition by TC.JobDuringJourney) AS Birthdate, c.Id as Iden
FROM Colonists C
	JOIN TravelCards TC ON TC.ColonistId = C.Id) TEMP
	JOIN Colonists COL ON COL.Id = TEMP.Iden
	WHERE COL.Birthdate != TEMP.Birthdate) AS TEMP2
	JOIN Colonists C ON C.Id = TEMP2.Id
		WHERE C.BirthDate = TEMP2.FinalBirthDate

--11
GO
CREATE FUNCTION udf_GetColonistsCount(@PlanetName VARCHAR (30))
RETURNS INT
AS
BEGIN
		DECLARE @Count INT = (SELECT COUNT(*) FROM Colonists C
		JOIN TravelCards TC ON TC.ColonistId = C.Id
		JOIN Journeys J ON J.Id = TC.JourneyId
		JOIN Spaceports SP ON SP.Id = J.DestinationSpaceportId
		JOIN Planets P ON P.Id = SP.PlanetId
		WHERE P.Name = @PlanetName)

		RETURN @COUNT
END

SELECT dbo.udf_GetColonistsCount('Otroyphus')

--12
GO

CREATE OR ALTER PROC usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(50))
AS
BEGIN
	BEGIN TRANSACTION
	IF((SELECT COUNT(*) FROM Journeys J
			WHERE J.Id = @JourneyId) = 0)
		BEGIN
			THROW 50001, 'The journey does not exist!', 1
			ROLLBACK
		END
	ELSE IF((SELECT J.Purpose FROM Journeys J
			WHERE J.Id = @JourneyId) = @NewPurpose)
		BEGIN 
			THROW 50002, 'You cannot change the purpose!',1
		END
	ELSE
	BEGIN 
		UPDATE Journeys
			SET Purpose = @NewPurpose
				WHERE Id = @JourneyId
	END
	COMMIT
END

EXEC usp_ChangeJourneyPurpose 4, 'Technical'
EXEC usp_ChangeJourneyPurpose 2, 'Educational'
EXEC usp_ChangeJourneyPurpose 196, 'Technical'

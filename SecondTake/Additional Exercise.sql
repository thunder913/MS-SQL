
USE Diablo

--1

SELECT  RIGHT(Email, LEN(Email) - CHARINDEX('@', Email)) 'Email Provider', COUNT(*) 'Number Of Users' FROM Users
	GROUP BY RIGHT(Email, LEN(Email) - CHARINDEX('@', Email))
	ORDER BY [Number Of Users] DESC, [Email Provider]

--2

SELECT G.Name 'Game', GT.Name 'Game Type', U.Username 'Username', UG.Level 'Level', UG.Cash 'Cash', C.Name 'Character' FROM Users U
	JOIN UsersGames UG ON UG.UserId=U.ID
	JOIN Games G ON G.Id=UG.GameId
	JOIN GameTypes GT ON G.GameTypeId=GT.Id
	JOIN Characters C ON C.Id=UG.CharacterId
	ORDER BY UG.Level DESC, U.Username, G.Name

--3
	
SELECT U.Username, G.Name, COUNT(*) 'Count', SUM(I.Price) 'Price' FROM Users U
	JOIN UsersGames UG ON UG.UserId=U.Id
	JOIN UserGameItems UGI ON UGI.UserGameId=UG.Id
	JOIN Items I ON I.Id=UGI.ItemId
	JOIN Games G ON G.Id=UG.GameId
	GROUP BY U.Username, G.Name
	HAVING COUNT(*)>=10
	ORDER BY Count DESC, Price DESC, U.Username ASC

--4

SELECT U.Username, G.Name,
	MAX(C.Name) 'Character',
	SUM(SIT.Strength)+MAX(GTS.Strength) + MAX(SCH.Strength) 'Strength',
	SUM(SIT.Defence)+MAX(GTS.Defence) + MAX(SCH.Defence) 'Defence',
	SUM(SIT.Speed)+MAX(GTS.Speed) + MAX(SCH.Speed) 'Speed',
	SUM(SIT.Mind)+MAX(GTS.Mind) + MAX(SCH.Mind) 'Mind',
	SUM(SIT.Luck)+MAX(GTS.Luck) + MAX(SCH.Luck) 'Luck'
	FROM Users U
	JOIN UsersGames UG ON UG.UserId=U.Id
	JOIN Games G ON G.Id=UG.GameId
	JOIN UserGameItems UGI ON UGI.UserGameId=UG.Id
	JOIN Characters C ON C.Id=UG.CharacterId
	JOIN [Statistics] SCH ON SCH.Id=C.StatisticId
	JOIN Items I ON I.Id= UGI.ItemId
	JOIN [Statistics] SIT ON SIT.Id=I.StatisticId
	JOIN GameTypes GT ON GT.Id=G.GameTypeId
	JOIN [Statistics] GTS ON GTS.Id=GT.BonusStatsId
	GROUP BY U.Username, G.Name
	ORDER BY Strength DESC, Defence DESC, Speed DESC, Mind DESC, Luck DESC

--5

SELECT I.Name, I.Price, I.MinLevel, S.Strength, S.Defence, S.Speed, S.Luck, S.Mind FROM Items I
	JOIN [Statistics] S ON S.Id=I.StatisticId
	WHERE S.Mind>(SELECT AVG(Mind) FROM [Statistics]) AND S.Luck>(SELECT AVG(Luck) FROM [Statistics])
	AND S.Speed>(SELECT AVG(Speed) FROM [Statistics])
	ORDER BY I.Name

--6

SELECT I.Name, I.Price, I.MinLevel, GT.Name FROM Items I
	LEFT JOIN GameTypeForbiddenItems GTFI ON GTFI.ItemId=I.Id
	LEFT JOIN GameTypes GT ON GT.Id=GTFI.GameTypeId
	ORDER BY GT.Name DESC, I.Name

--7

UPDATE UsersGames
	SET Cash -=	(SELECT SUM(I.Price) FROM Items I
	WHERE Name IN ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 
						'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet'))
	WHERE Id=235

INSERT INTO UserGameItems
SELECT I.Id,235 FROM Items I
	WHERE Name IN ('Blackguard', 'Bottomless Potion of Amplification', 'Eye of Etlich (Diablo III)', 
						'Gem of Efficacious Toxin', 'Golden Gorget of Leoric', 'Hellfire Amulet')

SELECT U.Username, G.Name, UG.Cash ,I.Name FROM Users U
	JOIN UsersGames UG ON UG.UserId=U.Id
	JOIN UserGameItems UGI ON UGI.UserGameId=UG.Id
	JOIN Games G ON G.Id=UG.GameId
	JOIN Items I ON I.Id=UGI.ItemId
	WHERE G.Name='Edinburgh'
	ORDER BY I.Name
	
--8

USE Geography

SELECT P.PeakName, M.MountainRange, P.Elevation FROM Peaks P
	JOIN Mountains M ON M.Id=P.MountainId
	ORDER BY P.Elevation DESC

--9

SELECT P.PeakName, M.MountainRange, C.CountryName, CON.ContinentName FROM Peaks P
	JOIN Mountains M ON M.Id=P.MountainId
	JOIN MountainsCountries MC ON MC.MountainId=M.Id
	JOIN Countries C ON C.CountryCode=MC.CountryCode
	JOIN Continents CON ON CON.ContinentCode=C.ContinentCode
	ORDER BY P.PeakName, C.CountryName

--10

SELECT C.CountryName, CON.ContinentName, 
COUNT(R.Id)
'RiversCount',
ISNULL(SUM(R.Length),0)
'TotalLength' FROM Countries C
	LEFT JOIN Continents CON ON CON.ContinentCode=C.ContinentCode
	LEFT JOIN CountriesRivers CR ON CR.CountryCode=C.CountryCode
	LEFT JOIN Rivers R ON CR.RiverId=R.Id
	GROUP BY C.CountryName, CON.ContinentName
	ORDER BY RiversCount DESC, TotalLength DESC, C.CountryName

--11

SELECT CUR.CurrencyCode, CUR.Description 'Currency',
COUNT(C.CountryCode)
'NumberOfCountries' FROM Countries C
	RIGHT JOIN Currencies CUR ON CUR.CurrencyCode=C.CurrencyCode
	GROUP BY CUR.CurrencyCode, CUR.Description
	ORDER BY NumberOfCountries DESC, CUR.Description
	

--12

SELECT CON.ContinentName, SUM(CONVERT(BIGINT, C.AreaInSqKm)) 'CountriesArea', SUM(CONVERT(BIGINT,C.Population)) 'CountriesPopulation' FROM Continents CON
	JOIN Countries C ON C.ContinentCode=CON.ContinentCode
	GROUP BY CON.ContinentName
	ORDER BY [CountriesPopulation] DESC

--13

CREATE TABLE Monasteries(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(100),
	CountryCode CHAR(2) FOREIGN KEY REFERENCES Countries(CountryCode)
	)

INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR')



ALTER TABLE Countries
	ADD IsDeleted BIT DEFAULT 0

UPDATE Countries
	SET IsDeleted = 1
	WHERE CountryCode IN (SELECT C.CountryCode FROM Countries C
		JOIN CountriesRivers CR ON CR.CountryCode=C.CountryCode
		JOIN Rivers R ON R.Id=CR.RiverId
		GROUP BY C.CountryCode
		HAVING COUNT(*)>3)


SELECT M.Name 'Monastery', C.CountryName 'Country' FROM Monasteries M
	JOIN Countries C ON C.CountryCode=M.CountryCode
	WHERE C.IsDeleted = 0
	ORDER BY M.Name

--14

UPDATE Countries
	SET CountryName = 'Burma'
	WHERE CountryName='Myanmar'

INSERT INTO Monasteries(Name, CountryCode)
VALUES
('Hanga Abbey', (SELECT TOP(1) C.CountryCode FROM Countries C WHERE C.CountryName='Myanmar')),
('Myin-Tin-Daik', (SELECT TOP(1) C.CountryCode FROM Countries C WHERE C.CountryName='Tanzania'))

SELECT CON.ContinentName,C.CountryName , 
	COUNT(M.Id) 'MonasteriesCount'
	FROM Continents CON
		LEFT JOIN Countries C ON C.ContinentCode=CON.ContinentCode
		LEFT JOIN Monasteries M ON M.CountryCode=C.CountryCode
	WHERE C.IsDeleted = 0
	GROUP BY CON.ContinentName, C.CountryName
	ORDER BY MonasteriesCount DESC, C.CountryName
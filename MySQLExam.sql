CREATE DATABASE Bitbucket
GO
USE BitBucket
GO

--1

CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	Password VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors(
	RepositoryId INT REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT REFERENCES Users(Id) NOT NULL,
	PRIMARY KEY (RepositoryId, ContributorId)
)

CREATE TABLE Issues(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(255) NOT NULL,
	IssueStatus VARCHAR(6) NOT NULL,
	RepositoryId INT REFERENCES Repositories(Id) NOT NULL,
	AssigneeId INT REFERENCES Users(Id)
)

CREATE TABLE Commits(
	Id INT PRIMARY KEY IDENTITY,
	Message VARCHAR(255) NOT NULL,
	IssueId INT REFERENCES Issues(Id),
	RepositoryId INT REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Files(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(100) NOT NULL,
	Size DECIMAL(18,2) NOT NULL,
	ParentId INT REFERENCES Files(Id),
	CommitId INT REFERENCES Commits(Id) NOT NULL
)

--2

INSERT INTO Files(Name,Size, ParentId,CommitId)
VALUES
('Trade.idk',	2598.0,	1,	1),
('menu.net',	9238.31,	2,	2),
('Administrate.soshy',	1246.93,	3,	3),
('Controller.php',	7353.15,	4,	4),
('Find.java',	9957.86,	5,	5),
('Controller.json',	14034.87,	3,	6),
('Operate.xix',	7662.92,	7,	7)

INSERT INTO Issues(Title,IssueStatus,RepositoryId,AssigneeId)
VALUES
('Critical Problem with HomeController.cs file',	'open',	1,	4),
('Typo fix in Judge.html',	'open',	4,	3),
('Implement documentation for UsersService.cs',	'closed',	8,	2),
('Unreachable code in Index.cs',	'open',	9,	8)


--3

UPDATE Issues
	SET IssueStatus='closed'
	WHERE AssigneeId=6

--4

DELETE FROM Issues
	WHERE RepositoryId IN (SELECT Id FROM Repositories WHERE Name='Softuni-Teamwork')

DELETE FROM Files
	WHERE CommitId IN (SELECT C.Id FROM Commits C JOIN Repositories R ON R.Id=C.RepositoryId WHERE R.Id IN (SELECT Id FROM Repositories WHERE Name='Softuni-Teamwork'))

DELETE FROM Commits
	WHERE RepositoryId IN (SELECT Id FROM Repositories WHERE Name='Softuni-Teamwork')

DELETE FROM RepositoriesContributors 
	WHERE RepositoryId IN(SELECT Id FROM Repositories WHERE Name='Softuni-Teamwork')

DELETE FROM Repositories
	WHERE Name='Softuni-Teamwork'


--5

SELECT C.Id,C.Message, C.RepositoryId,C.ContributorId FROM Commits C
	ORDER BY C.Id, C.Message,C.RepositoryId, C.ContributorId

--6

SELECT F.Id, F.Name, F.Size FROM Files F
	WHERE F.Size>1000 AND F.Name LIKE '%html%'
	ORDER BY F.Size DESC, F.Id, F.Name

--7

SELECT I.Id, U.Username+' : '+I.Title 'IssueAssignee' FROM Issues I
	JOIN Users U ON U.Id=I.AssigneeId
	ORDER BY I.Id DESC, I.AssigneeId


--8


SELECT F.Id, F.Name, CONVERT(VARCHAR, F.Size)+'KB' 'Size' FROM Files F
	WHERE F.Id NOT IN (SELECT ParentId FROM Files WHERE ParentId IS NOT NULL)
	ORDER BY F.Id, F.Name, F.Size DESC

--9

SELECT TOP(5) R.Id, R.Name, COUNT(*) 'Commits' FROM RepositoriesContributors RC
	JOIN Repositories R ON R.Id=RC.RepositoryId
	JOIN Commits C ON C.RepositoryId=R.Id
	GROUP BY R.Id,R.Name
	ORDER BY Commits DESC, R.Id,R.Name
--10

SELECT U.Username, AVG(F.Size) 'Size' FROM Users U
	JOIN Commits C ON C.ContributorId=U.Id
	JOIN Files F ON F.CommitId=C.Id
	GROUP BY U.Username
	ORDER BY Size DESC, U.Username

--11

CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT
BEGIN
	DECLARE @count INT = (SELECT COUNT(*) FROM Users U
		JOIN Commits C ON C.ContributorId=U.Id
		WHERE U.Username=@username)
	RETURN @count
END

--12

CREATE PROC usp_SearchForFiles(@fileExtension VARCHAR(MAX))
AS
BEGIN
	SELECT F.Id, F.Name, CONVERT(VARCHAR, F.Size)+'KB' 'Size' FROM Files F
		WHERE F.Name LIKE ('%.'+@fileExtension)
		ORDER BY F.Id, F.Name, F.Size DESC
END

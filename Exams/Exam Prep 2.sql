CREATE DATABASE School
GO
USE School
GO

CREATE TABLE Students(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	MiddleName NVARCHAR(25),
	LastName NVARCHAR(30) NOT NULL,
	Age INT CHECK(Age>=5 AND Age<=100),
	Address NVARCHAR(50),
	Phone NVARCHAR(10) CHECK(LEN(Phone)=10)
)

CREATE TABLE Subjects(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(20) NOT NULL,
	Lessons INT CHECK(Lessons>0) NOT NULL
)

CREATE TABLE StudentsSubjects(
	Id INT PRIMARY KEY IDENTITY,
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL,
	Grade DECIMAL(18,2) CHECK(Grade>=2 AND Grade<=6) NOT NULL
)

CREATE TABLE Exams(
	Id INT PRIMARY KEY IDENTITY,
	Date DATETIME,
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsExams(
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	ExamId INT FOREIGN KEY REFERENCES Exams(Id) NOT NULL,
	Grade DECIMAL(18,2) CHECK(Grade>=2 AND Grade<=6) NOT NULL
	PRIMARY KEY(StudentId, ExamId)
)

CREATE TABLE Teachers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(20) NOT NULL,
	LastName NVARCHAR(20) NOT NULL,
	Address NVARCHAR(20) NOT NULL,
	Phone VARCHAR(10) CHECK(LEN(Phone)=10),
	SubjectId INT FOREIGN KEY REFERENCES Subjects(Id) NOT NULL
)

CREATE TABLE StudentsTeachers(
	StudentId INT FOREIGN KEY REFERENCES Students(Id) NOT NULL,
	TeacherId INT FOREIGN KEY REFERENCES Teachers(Id) NOT NULL,
	PRIMARY KEY(StudentId, TeacherId)
)


--2

INSERT INTO Teachers(FirstName,LastName,Address,Phone,SubjectId)
VALUES
('Ruthanne',	'Bamb',	'84948 Mesta Junction',	'3105500146',	6),
('Gerrard',	'Lowin',	'370 Talisman Plaza',	'3324874824',	2),
('Merrile',	'Lambdin',	'81 Dahle Plaza',	'4373065154',	5),
('Bert', 'Ivie',	'2 Gateway Circle',	'4409584510',	4)

INSERT INTO Subjects(Name, Lessons)
VALUES
('Geometry', 12),
('Health', 10),
('Drama', 7),
('Sports', 9)

--3

UPDATE StudentsSubjects
	SET Grade=6.00
	WHERE SubjectId IN(1,2) AND Grade>=5.50


--4

DELETE FROM StudentsTeachers
	WHERE TeacherId IN (SELECT Id FROM Teachers WHERE Phone LIKE '%72%')

DELETE FROM Teachers
	WHERE Phone LIKE '%72%'


--5

SELECT FirstName, LastName, Age FROM Students
	WHERE Age>=12
	ORDER BY FirstName, LastName

--6

SELECT S.FirstName, S.LastName, TEMP.TeachersCount FROM(
SELECT S.Id, COUNT(ST.TeacherId) 'TeachersCount' FROM Students S
	JOIN StudentsTeachers ST ON ST.StudentId=S.Id
	GROUP BY S.Id) TEMP
	JOIN Students S ON S.Id=TEMP.Id
	ORDER BY S.LastName

--7

SELECT S.FirstName+' '+S.LastName 'Full Name' FROM Students S
	FULL JOIN StudentsExams SE ON SE.StudentId=S.Id
	WHERE SE.ExamId IS NULL
	ORDER BY [Full Name]

--8


SELECT TOP(10) S.FirstName, S.LastName, CONVERT(DECIMAL(5,2) ,AVG(SE.Grade)) 'Grade' FROM Students S
	JOIN StudentsExams SE ON SE.StudentId=S.Id
	GROUP BY S.Id, S.FirstName, S.LastName
	ORDER BY Grade DESC, S.FirstName, S.LastName

--9

SELECT 
CASE
WHEN S.MiddleName IS NULL THEN S.FirstName+' '+S.LastName
ELSE S.FirstName+' '+S.MiddleName+' '+S.LastName
END
'Full Name'
FROM Students S
	LEFT JOIN StudentsSubjects SS ON SS.StudentId=S.Id
	WHERE SS.SubjectId IS NULL
	ORDER BY [Full Name]

--10

SELECT S.Name, AVG(SS.Grade) 'AverageGrade' FROM Subjects S
	JOIN StudentsSubjects SS ON SS.SubjectId=S.Id
	GROUP BY S.Id, S.Name
	ORDER BY S.Id

--11

CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(18,2))
RETURNS NVARCHAR(100)
BEGIN
	IF NOT EXISTS(SELECT Id FROM Students WHERE Id=@studentId)
		BEGIN
			RETURN 'The student with provided id does not exist in the school!'
		END
	ELSE IF @grade>6
		BEGIN
			RETURN 'Grade cannot be above 6.00!';
		END
	DECLARE @firstName VARCHAR(20), @count INT

	SELECT @firstName=S.FirstName, @count=COUNT(*) FROM Students S
		JOIN StudentsExams SE ON SE.StudentId=S.Id
		WHERE S.Id=@studentId AND SE.Grade>= @grade AND SE.Grade<= @grade+0.5
		GROUP BY S.FirstName

	RETURN 'You have to update '+ CONVERT(VARCHAR, @count) +' grades for the student '+ CONVERT(VARCHAR, @firstName)
END

SELECT dbo.udf_ExamGradesToUpdate(121, 5.50)
SELECT dbo.udf_ExamGradesToUpdate(12, 6.20)

SELECT dbo.udf_ExamGradesToUpdate(12, 5.50)


--12

CREATE PROC usp_ExcludeFromSchool(@StudentId INT)
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM Students WHERE ID=@StudentId)
		BEGIN
			RAISERROR('This school has no student with the provided id!', 16,1)
		END

	DELETE FROM StudentsExams
		WHERE StudentId=@StudentId

	DELETE FROM StudentsSubjects
		WHERE StudentId=@StudentId

	DELETE FROM StudentsTeachers
		WHERE StudentId=@StudentId

	DELETE FROM Students
		WHERE Id=@StudentId
END

EXEC usp_ExcludeFromSchool 1
SELECT COUNT(*) FROM Students
EXEC usp_ExcludeFromSchool 301
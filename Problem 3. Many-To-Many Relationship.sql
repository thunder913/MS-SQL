CREATE TABLE Students(
	StudentID int PRIMARY KEY IDENTITY,
	[Name] nvarchar(30)
)

CREATE TABLE Exams(
	ExamID int PRIMARY KEY IDENTITY(101,1),
	[Name] nvarchar(30)
)

CREATE TABLE StudentsExams(
	StudentID int NOT NULL,
	ExamID int NOT NULL
	CONSTRAINT PK_SEID PRIMARY KEY (ExamID, StudentID)
)

INSERT INTO Students([Name])
VALUES
('Mila'),
('Toni'),
('Ron')

INSERT INTO EXAMS([Name])
VALUES
('SpringMVC'),
('Neo4j'),
('Oracle 11g')

INSERT INTO StudentsExams(StudentID,ExamID)
VALUES
(1,101),
(1,102),
(2,101),
(3,103),
(2,102),
(2,103)

ALTER TABLE StudentsExams
	ADD FOREIGN KEY (ExamID) REFERENCES Exams(ExamID)
	
ALTER TABLE StudentsExams
	ADD FOREIGN KEY (StudentID) REFERENCES Students(StudentID)





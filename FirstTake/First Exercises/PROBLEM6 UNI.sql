CREATE DATABASE University

USE UNIVERSITY

CREATE TABLE Subjects(
	SubjectID int PRIMARY KEY,
	SubjectName nvarchar(30)
)

CREATE TABLE Agenda(
	StudentID int,
	SubjectID int,
	PRIMARY KEY (StudentID, SubjectID)
)

CREATE TABLE Students(
	StudentID int PRIMARY KEY,
	StudentNumber int,
	StudentName nvarchar(30),
	MajorID int
)

CREATE TABLE Majors(
	MajorID int PRIMARY KEY,
	[Name] nvarchar(30)
)

CREATE TABLE Payments(
	PaymendID int PRIMARY KEY,
	PaymentDate date,
	PaymentAmount decimal(10,2),
	StudentID int
)

ALTER TABLE Agenda
	ADD FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID)

ALTER TABLE Agenda
	ADD FOREIGN KEY (StudentID) REFERENCES Students(StudentID)

ALTER TABLE Students
	ADD FOREIGN KEY (MajorID) REFERENCES Majors(MajorID)

ALTER TABLE Payments
	ADD FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
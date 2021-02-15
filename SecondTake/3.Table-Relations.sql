CREATE DATABASE TableRelationsDB

USE TableRelationsDB

--1

CREATE TABLE Passports(
	PassportID INT PRIMARY KEY IDENTITY(101,1),
	PassportNumber NVARCHAR(8)
)

CREATE TABLE Persons(
	PersonID INT NOT NULL,
	FirstName NVARCHAR(50),
	Salary DECIMAL(9,2),
	PassportID INT
)

INSERT INTO Persons(PersonID ,FirstName, Salary, PassportID)
VALUES
(1, 'Roberto', 43300.00, 102),
(2,'Tom', 56100.00, 103),
(3, 'Yana', 60200.00, 101)

INSERT INTO Passports(PassportNumber)
VALUES
('N34FG21B'),
('K65LO4R7'),
('ZE657QP2')


ALTER TABLE Persons
	ALTER COLUMN PersonID
		INT NOT NULL
	
ALTER TABLE Persons
	ADD PRIMARY KEY (PersonID) 

ALTER TABLE Persons
	ADD CONSTRAINT FK_PASSPORT
	FOREIGN KEY (PassportID) REFERENCES Passports(PassportID)

--2

CREATE TABLE Models(
	ModelID INT PRIMARY KEY IDENTITY (101,1),
	Name NVARCHAR(50),
	ManufacturerID INT
)

CREATE TABLE Manufacturers(
	ManufacturerID INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(50),
	EstablishedOn DATE
)

INSERT INTO Models(Name, ManufacturerID)
VALUES
('X1', 1),
('i6', 1),
('Model S', 2),
('Model X', 2),
('Model 3', 2),
('Nova', 3)

INSERT INTO Manufacturers(Name, EstablishedOn)
VALUES
('BMW', '07/03/1916'),
('Tesla', '01/01/2003'),
('Lada', '01/05/1966')

ALTER TABLE Models
	ADD CONSTRAINT 
	FK_Manufacturers FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)


--3

CREATE TABLE Students(
	StudentID INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50)
)

CREATE TABLE Exams(
	ExamID INT PRIMARY KEY IDENTITY(101,1),
	[Name] NVARCHAR(100)
)

CREATE TABLE StudentsExams(
	StudentID INT,
	ExamID INT,
	PRIMARY KEY (StudentID, ExamID)
)

INSERT INTO Students(Name)
VALUES
('Mila'),
('Toni'),
('Ron')

INSERT INTO Exams(Name)
VALUES
('SpringMVC'),
('Neo4j'),
('Oracle 11g')

INSERT INTO StudentsExams(StudentID, ExamID)
VALUES
(1, 101),
(1, 102),
(2, 101),
(3, 103),
(2, 102),
(2, 103)


ALTER TABLE StudentsExams
	ADD CONSTRAINT FK_STUDENT FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
	CONSTRAINT FK_EXAM FOREIGN KEY (ExamID) REFERENCES Exams(ExamID)


--4

CREATE TABLE Teachers(
	TeacherID INT PRIMARY KEY IDENTITY(101,1),
	Name NVARCHAR(50),
	ManagerID INT REFERENCES Teachers(TeacherID)
)

INSERT INTO Teachers(Name, ManagerID)
VALUES
('John', NULL),
('Maya', 106),
('Silvia', 106),
('Ted', 105),
('Mark', 101),
('Greta', 101)


--5
CREATE DATABASE OnlineStoreDB
USE OnlineStoreDB

CREATE TABLE ItemTypes(
	ItemTypeID INT PRIMARY KEY IDENTITY,
	Name varchar(50)
)

CREATE TABLE Items(
	ItemID INT PRIMARY KEY IDENTITY,
	Name varchar(50),
	ItemTypeID INT FOREIGN KEY REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE Cities(
	CityID INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50)
)

CREATE TABLE Customers(
	CustomerID INT PRIMARY KEY IDENTITY,
	Name varchar(50),
	Birthday DATE,
	CityID INT FOREIGN KEY REFERENCES Cities(CityID)
)

CREATE TABLE Orders(
	OrderID INT PRIMARY KEY IDENTITY,
	CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
)

CREATE TABLE OrderItems(
	OrderID INT NOT NULL,
	ItemID INT NOT NULL
	PRIMARY KEY (OrderID, ItemID)
	FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
	FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
)

--6

CREATE TABLE Subjects(
	SubjectID INT PRIMARY KEY IDENTITY,
	SubjectName NVARCHAR(50)
)

CREATE TABLE Majors(
	MajorID INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(50)
)

CREATE TABLE Students(
	StudentID INT PRIMARY KEY IDENTITY,
	StudentNumber VARCHAR(50),
	StudentName NVARCHAR(100),
	MajorID INT FOREIGN KEY REFERENCES Majors(MajorID)
)

CREATE TABLE Payments(
	PaymentID INT PRIMARY KEY IDENTITY,
	PaymentDate DATE,
	PaymentAmount DECIMAL(9,2),
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID)
)

CREATE TABLE Agenda(
	StudentID INT,
	SubjectID INT,
	PRIMARY KEY (StudentID, SubjectID),
	FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
	FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID)
)


--9

USE Geography

SELECT M.MountainRange, P.PeakName, P.Elevation FROM Peaks P
	JOIN Mountains M ON P.MountainId = M.Id
	WHERE M.MountainRange='Rila'
	ORDER BY P.Elevation DESC
CREATE DATABASE TableRelations

Use TableRelations

CREATE TABLE Passports(
	PassportID int PRIMARY KEY IDENTITY(101,1) NOT NULL,
	PassportNumber nvarchar(30)
)

CREATE Table Persons(
	PersonID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	FirstName nvarchar(30),
	Salary decimal(10,2),
	PassportID int FOREIGN KEY REFERENCES Passports(PassportID)
)


INSERT INTO Passports(PassportNumber)
VALUES
('N34FG21B'),
('K65LO4R7'),
('ZE657QP2')

INSERT INTO Persons(FirstName, Salary, PassportID)
VALUES
('Roberto', 43300.00, 102),
('Tom', 56100.00, 103),
('Yana', 60200.00, 101)

SELECT * FROM Passports
CREATE DATABASE SoftUni

USE SOFTUNI

CREATE TABLE TOWNS(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50)
)

CREATE TABLE Addresses (
Id INT PRIMARY KEY IDENTITY NOT NULL,
AddressText NVARCHAR(50),
TownId INT FOREIGN KEY REFERENCES TOWNS(ID)
)

CREATE TABLE Departments (
Id INT PRIMARY KEY IDENTITY NOT NULL,
[Name] NVARCHAR(50)
)

CREATE TABLE Employees (
Id INT PRIMARY KEY IDENTITY NOT NULL, 
FirstName NVARCHAR(30), 
MiddleName NVARCHAR(30), 
LastName NVARCHAR(30), 
JobTitle NVARCHAR(30), 
DepartmentId INT FOREIGN KEY REFERENCES DEPARTMENTS(ID), 
HireDate DATETIME2, 
Salary DECIMAL(10,2), 
AddressId NVARCHAR(100)
)

BACKUP DATABASE SOFTUNI TO DISK = 'softuni-backup.bak'

DROP DATABASE SOFTUNI

RESTORE DATABASE SOFTUNI FROM DISK = 'softuni-backup.bak'


INSERT INTO TOWNS([Name])
VALUES
('Sofia'), 
('Plovdiv'), 
('Varna'), 
('Burgas')

INSERT INTO Departments([NAME])
VALUES
('Engineering'), ('Sales'), ('Marketing'), ('Software Development'), ('Quality Assurance')


INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary)
VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer',4, '01/02/2013', 3500.00),
('Petar', 'Petrov', 'Petrov',	'Senior Engineer',1,	'03/02/2004',	4000.00),
('Maria', 'Petrova', 'Ivanova',	'Intern', 5,	'08/28/2016',	525.25),
('Georgi', 'Teziev', 'Ivanov',	'CEO',	2,	'12/09/2007',	3000.00),
('Peter', 'Pan', 'Pan',	'Intern',	3,	'08/28/2016',	599.88)


SELECT * FROM TOWNS

SELECT * FROM Departments

SELECT * FROM Employees

SELECT *FROM TOWNS
ORDER BY [NAME]

SELECT * FROM Departments
ORDER BY [NAME]

SELECT * FROM Employees
ORDER BY Salary DESC


SELECT [NAME] FROM TOWNS
ORDER BY [NAME]

SELECT [NAME] FROM DEPARTMENTS
ORDER BY [NAME]

SELECT FirstName,LastName,JobTitle,Salary FROM Employees
ORDER BY Salary DESC

UPDATE Employees SET Salary = Salary*1.1

SELECT SALARY FROM Employees

USE HOTEL

UPDATE Payments SET TaxRate *= 0.97

SELECT TAXRATE FROM Payments

TRUNCATE TABLE OCCUPANCIES

SELECT * FROM Occupancies
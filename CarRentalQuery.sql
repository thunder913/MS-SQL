

CREATE DATABASE CarRental

USE CarRental

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	CategoryName VARCHAR(30) NOT NULL,
	DailyRate DECIMAL(10,2),
	WeeklyRate DECIMAL(10,2), 
	MonthlyRate DECIMAL(10,2), 
	WeekendRate DECIMAL(10,2)
)
CREATE TABLE Cars(
Id INT PRIMARY KEY IDENTITY NOT NULL, 
PlateNumber VARCHAR(10) NOT NULL,
Manufacturer VARCHAR(30) NOT NULL, 
Model VARCHAR(20) NOT NULL, 
CarYear DATE, 
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL, 
Doors INT, 
Picture VARBINARY(MAX), 
Condition VARCHAR(MAX), 
Available BIT
)

CREATE TABLE Employees (
Id INT PRIMARY KEY IDENTITY NOT NULL,
FirstName NVARCHAR(50) NOT NULL, 
LastName NVARCHAR(50) NOT NULL, 
Title NVARCHAR(30) NOT NULL,
Notes NVARCHAR(MAX)
)

CREATE TABLE Customers (
Id INT PRIMARY KEY IDENTITY NOT NULL, 
DriverLicenceNumber VARCHAR(10) NOT NULL, 
FullName NVARCHAR(50), 
[Address] NVARCHAR(30), 
City NVARCHAR(30), 
ZIPCode INT, 
Notes NVARCHAR(MAX))

CREATE TABLE RentalOrders (
Id INT PRIMARY KEY IDENTITY, 
EmployeeId INT FOREIGN KEY REFERENCES EMPLOYEES(Id), 
CustomerId INT FOREIGN KEY REFERENCES Customers(Id), 
CarId INT FOREIGN KEY REFERENCES Cars(Id), 
TankLevel DECIMAL(10,2), 
KilometrageStart INT, 
KilometrageEnd INT, 
TotalKilometrage INT, 
StartDate DATETIME, 
EndDate DATETIME, 
TotalDays INT, 
RateApplied DECIMAL(10,2), 
TaxRate INT, 
OrderStatus BIT, 
Notes NVARCHAR(MAX))

INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES
('CONVERTABLE', 60.5, 300.5, 4000.1, 300.2),
('SPORTS', 99.99, 500.0, 6000.0, 900.0),
('TIR', 39.99, 400.0, 7000.0, 800.0)

SELECT * FROM Categories

INSERT INTO CARS(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available)
VALUES
('SV5523', 'BMW', 'X5', '2020-05-22', 1, 5, NULL, 'GOOD', 0),
('SV5523', 'AUDI', 'A5', '2000-05-22', 2, 5, NULL, 'GOOD', 0),
('SV5523', 'MERCEDES', 'BENZ', '2010-05-22', 3, 5, NULL, 'GOOD', 0)

SELECT * FROM CARS

INSERT INTO Employees (FirstName, LastName, Title, Notes)
VALUES
('IVAN', 'PETROV', 'WORKER', NULL),
('GEROGI', 'IVANOV', 'WORKER', NULL),
('PETUR', 'GEORGIEV', 'WORKER', NULL)

SELECT * FROM Employees

INSERT INTO Customers (DriverLicenceNumber, FullName, [Address], City, ZIPCode, Notes)
VALUES
(1242145124, 'IVAN PETROV', 'BORIS SARAFOV 17A', 'PLOVDIV', 4912, 'BAD DRIVER'),
(12312412, 'ANDON PETROV', 'BORIS ULICA 17A', 'DOBRICH', 3123, 'NOT WORTHWHILE DRIVER'),
(123124124, 'IVAN GEORGIEV', 'PETUR BERON 17A', 'SANDANSKI', 4123, 'GOOD DRIVER')

SELECT * FROM Customers

INSERT INTO RentalOrders (EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd,
TotalKilometrage, StartDate, EndDate, TotalDays, RateApplied, TaxRate, OrderStatus, Notes)
VALUES
(1, 1, 1, 100, 100000, 125000, 25000, '2020-5-22 11:22:33', '2020-6-22 11:23:34', 31, 420, 5, 1, NULL),
(2, 2, 2, 100, 100000, 125000, 25000, '2020-5-22 11:22:33', '2020-6-22 11:23:34', 31, 420, 5, 1, NULL),
(3, 3, 3, 100, 100000, 125000, 25000, '2020-5-22 11:22:33', '2020-6-22 11:23:34', 31, 420, 5, 1, NULL)

SELECT * FROM RentalOrders
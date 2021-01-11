USE Minions

--1

CREATE DATABASE Minions

--2

CREATE TABLE Minions(
	Id INT PRIMARY KEY,
	Name NVARCHAR(255),
	Age Int
)

CREATE TABLE Towns(
	Id INT PRIMARY KEY,
	NAME NVARCHAR(255)
)

--3

ALTER TABLE Minions
	ADD TownId INT FOREIGN KEY REFERENCES Towns(Id)

--4

INSERT INTO Towns(Id, Name)
VALUES (1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')


INSERT INTO MINIONS(Id, Name,Age, TownId)
VALUES(1, 'Kevin', 22, 1),
(2,'Bob',15, 3),
(3, 'Steward',NULL,2)

--5

TRUNCATE TABLE MINIONS

--6

DROP TABLE MINIONS
DROP Table TOWNS

--7

CREATE TABLE People(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(200) NOT NULL,
	Picture VARBINARY(2000),
	Height DECIMAL(5,2),
	Weight DECIMAL(5,2),
	Gender VARCHAR(1) NOT NULL,
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX)
)

INSERT INTO PEOPLE(Name, Picture, Height, Weight, Gender, Birthdate, Biography)
VALUES
('Ivan', NULL, 1.55, 100, 'm', '2000-02-01', 'Ivan is stupid'),
('Georgi', NULL, 1.55, 100, 'm', '2000-02-01', 'Georgi is stupid'),
('Petur', NULL, 1.55, 100, 'm', '2000-02-01', 'Petur is stupid'),
('Gosho', NULL, 1.55, 100, 'f', '2000-02-01', 'Gosho is stupid'),
('Bai ivna', NULL, 1.55, 100, 'm', '2000-02-01', 'Ivna is stupid')

--8

CREATE TABLE Users(
	Id BIGINT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) UNIQUE NOT NULL,
	Password VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(900),
	LastLoginTime DATETIME,
	IsDeleted BIT
)

INSERT INTO Users(Username,Password, ProfilePicture, LastLoginTime, IsDeleted)
VALUES
('vancho', 'vancho', NULL, '2020-01-02', 1),
('dari', 'dari', NULL, '2020-01-02', 1),
('gosho', 'gosho', NULL, '2020-01-02', 1),
('georig', 'georig', NULL, '2020-01-02', 1),
('ivna', 'ivna', NULL, '2020-01-02', 1)

--9

ALTER TABLE Users
	DROP CONSTRAINT PK__Users__3214EC0798365C88

	--10

ALTER TABLE Users
	ADD PRIMARY KEY (ID,Username)
	--11
ALTER TABLE Users
	ADD CONSTRAINT df_login DEFAULT GETDATE() FOR LastLoginTime
	--12
	ALTER TABLE Users
		DROP CONSTRAINT PK__Users__77222459AD79233A
		
	ALTER TABLE Users
		ADD PRIMARY KEY (Id)

	ALTER TABLE Users
		ADD CONSTRAINT username_min_lenght CHECK (LEN(Username)>=3)


--13
CREATE DATABASE Movies

USE Movies

CREATE TABLE Directors(
	Id INT PRIMARY KEY IDENTITY,
	DirectorName NVARCHAR(100) NOT NULL,
	Notes NVARCHAR(300)
)

CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY,
	GenreName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(300)
)

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName NVARCHAR(100) NOT NULL,
	Notes NVARCHAR(300)
)

CREATE TABLE Movies(
	Id INT PRIMARY KEY IDENTITY,
	Title NVARCHAR(50) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
	CopyrightYear DATE,
	Lenght TIME,
	GenreId INT FOREIGN KEY REFERENCES Genres(Id),
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Rating DECIMAL(5,2),
	Notes NVARCHAR(300)
)

INSERT INTO Directors(DirectorName,Notes)
VALUES
('Name1', 'Note11'),
('Name2', 'Note22'),
('Name3', 'Note33'),
('Name4', 'Note44'),
('Name5', 'Note55')

INSERT INTO Genres(GenreName,Notes)
VALUES
('Name1', 'Note11'),
('Name2', 'Note22'),
('Name3', 'Note33'),
('Name4', 'Note44'),
('Name5', 'Note55')

INSERT INTO Categories(CategoryName, Notes)
VALUES
('Name1', 'Note11'),
('Name2', 'Note22'),
('Name3', 'Note33'),
('Name4', 'Note44'),
('Name5', 'Note55')

INSERT INTO Movies(Title, DirectorId, CopyrightYear, Lenght, GenreId, CategoryId, Rating, Notes)
VALUES
('Title1', 1, '2020', '02:55:02', 1, 1, 4.55, 'Good one'),
('Title2', 2, '2020', '02:55:02', 2, 2, 4.55, 'Good one'),
('Title3', 3, '2020', '02:55:02', 3, 3, 4.55, 'Good one'),
('Title4', 4, '2020', '02:55:02', 4, 4, 4.55, 'Good one'),
('Title5', 5, '2020', '02:55:02', 5, 5, 4.55, 'Good one')


--14

CREATE DATABASE CarRental

USE CarRental

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY, 
	CategoryName NVARCHAR(50) NOT NULL,
	DailyRate DECIMAL(5,2),
	WeeklyRate DECIMAL(5,2),
	MonthlyRate DECIMAL(5,2),
	WeekendRate DECIMAL(5,2)
	)

CREATE TABLE Cars(
	Id INT PRIMARY KEY IDENTITY,
	PlateNumber NVARCHAR(10) NOT NULL,
	Manufacturer NVARCHAR(50) NOT NULL,
	Model NVARCHAR(50) NOT NULL,
	CarYear DATE,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Doors INT,
	Picture VARBINARY(MAX),
	Condition NVARCHAR(30),
	Available BIT)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Title NVARCHAR(30),
	Notes NVARCHAR(300)
)

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY,
	DriverLicenceNumber NVARCHAR(30),
	FullName NVARCHAR(100),
	Address NVARCHAR(100),
	City NVARCHAR(100),
	ZIPCode INT,
	Notes NVARCHAR(300)
)

CREATE TABLE RentalOrders(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id),
	CarId INT FOREIGN KEY REFERENCES Cars(Id),
	TankLevel DECIMAL(5,2),
	KilometrageStart INT,
	KilometrageEnd INT,
	TotalKilometrage INT,
	StartDate DATETIME,
	EndDate DATETIME,
	TotalDays INT,
	RateApplied DECIMAL(5,2),
	TaxRate DECIMAL(5,2),
	OrderStatus NVARCHAR(20),
	Notes NVARCHAR(300)
)

INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES
('SUV', 3, 4, 5, 6),
('Truck', 3, 4, 5, 6),
('Test', 3, 4, 5, 6)

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available)
VALUES
('Test123', 'test', 'test', '2020', 1, 4, NULL, 'GOOD', 0),
('Test123', 'test', 'test', '2020', 2, 4, NULL, 'GOOD', 1),
('Test123', 'test', 'test', '2005', 3, 4, NULL, 'GOOD', 1)

INSERT INTO Employees(FirstName, LastName, Title, Notes)
VALUES
('Ivan', 'Petrov', 'Test', 'OK'),
('Ivan', 'Petrov', 'Test', 'OK'),
('Ivan', 'Petrov', 'Test', 'OK')

INSERT INTO Customers(DriverLicenceNumber, FullName, Address, City, ZIPCode, Notes)
VALUES
('123123as2', 'Ivan Petrov', 'Ulica Stamboliiska 23', 'Sofiq', '1000', 'GOOD'),
('123123as2', 'Ivan Petrov', 'Ulica Stamboliiska 23', 'Sofiq', '1000', 'GOOD'),
('123123as2', 'Ivan Petrov', 'Ulica Stamboliiska 23', 'Sofiq', '1000', 'GOOD')

INSERT INTO RentalOrders(EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd, TotalKilometrage, StartDate, EndDate, TotalDays, RateApplied, TaxRate, OrderStatus, Notes)
VALUES
(1,1,1,500,1200,1300,100,'2020-02-01', '2020-02-05', 4, 50, 0.1, 'DONE', 'DONE'),
(2,2,2,500,1200,1300,100,'2020-02-01', '2020-02-05', 4, 50, 0.1, 'DONE', 'DONE'),
(3,3,3,500,1200,1300,100,'2020-02-01', '2020-02-05', 4, 50, 0.1, 'DONE', 'DONE')

--15

CREATE DATABASE Hotel

USE HOTEL

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	Title NVARCHAR(50),
	Notes NVARCHAR(100)
)

CREATE TABLE Customers (
	AccountNumber INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	PhoneNumber NVARCHAR(20),
	EmergencyName NVARCHAR(50),
	EmergencyNumber NVARCHAR(20),
	Notes NVARCHAR(300)
)

CREATE TABLE RoomStatus(
	RoomStatus NVARCHAR(300),
	Notes NVARCHAR(300)
)

CREATE TABLE RoomTypes(
	RoomType NVARCHAR(300),
	Notes NVARCHAR(300)
)

CREATE TABLE BedTypes(
	BedType NVARCHAR(300),
	NOTES NVARCHAR(300)
)

CREATE TABLE Rooms(
	RoomNumber INT PRIMARY KEY IDENTITY,
	RoomType NVARCHAR(300),
	BedType NVARCHAR(300),
	Rate DECIMAL(5,2),
	RoomStatus NVARCHAR(300),
	Notes NVARCHAR(300)
)

CREATE TABLE Payments(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	PaymentDate DATE,
	AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber),
	FirstDateOccupied DATE,
	LastDateOccupied DATE,
	TotalDays INT,
	AmountCharged DECIMAL(9,2),
	TaxRate DECIMAL(5,2),
	TaxAmount DECIMAL(5,2),
	PaymentTotal DECIMAL(9,2),
	Notes NVARCHAR(300)
)

CREATE TABLE Occupancies(
	Id INT PRIMARY KEY IDENTITY,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	DateOccupied DATE,
	AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber),
	RoomNumber INT,
	RateApplied DECIMAL(5,2),
	PhoneCharge DECIMAL(5,2),
	Notes NVARCHAR(300)
)


INSERT INTO Employees(FirstName, LastName, Title, Notes)
VALUES
('Gosho','Ivanov','Rabotnik', 'Good Guy'),
('Gosho','Ivanov','Rabotnik', 'Good Guy'),
('Gosho','Ivanov','Rabotnik', 'Good Guy')

INSERT INTO Customers(FirstName, LastName, PhoneNumber, EmergencyName, EmergencyNumber, Notes)
VALUES
('Ivan', 'Petrov', '0123213', 'Ivankaaa', '123123123', 'Good'),
('Ivan', 'Petrov', '0123213', 'Ivankaaa', '123123123', 'Good'),
('Ivan', 'Petrov', '0123213', 'Ivankaaa', '123123123', 'Good')

INSERT INTO RoomStatus(RoomStatus,Notes)
VALUES
('GOOD', 'Well behaved'),
('GOOD', 'Well behaved'),
('GOOD', 'Well behaved')

INSERT INTO RoomTypes(RoomType, Notes)
VALUES
('GOOD', 'Well behaved'),
('GOOD', 'Well behaved'),
('GOOD', 'Well behaved')

INSERT INTO BedTypes(BedType, Notes)
VALUES
('GOOD', 'Well behaved'),
('GOOD', 'Well behaved'),
('GOOD', 'Well behaved')

INSERT INTO Rooms(RoomType, BedType, Rate, RoomStatus, Notes)
VALUES
('GOOD', 'GOOD', 5, 'GOOD', 'GOOD'),
('GOOD', 'GOOD', 5, 'GOOD', 'GOOD'),
('GOOD', 'GOOD', 5, 'GOOD', 'GOOD')

INSERT INTO Payments(EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, TotalDays, AmountCharged, TaxRate, TaxAmount, PaymentTotal, Notes)
VALUES
(1, '2020', 1, '2019', '2021', 365, 399, 0.20,100, 500, 'Deal'),
(2, '2020', 2, '2019', '2021', 365, 399, 0.20,100, 500, 'Deal'),
(3, '2020', 3, '2019', '2021', 365, 399, 0.20,100, 500, 'Deal')

INSERT INTO Occupancies(EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied, PhoneCharge, Notes)
VALUES
(1,'2019',1,1,12,13,'ok'),
(2,'2019',2,2,12,13,'ok'),
(3,'2019',3,3,12,13,'ok')

--16

CREATE DATABASE SoftUni

USE SoftUni

CREATE TABLE Towns(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(100)
)

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY,
	AddressText NVARCHAR(50),
	TownId INT FOREIGN KEY REFERENCES Towns(Id)
)

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(30)
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30),
	MiddleName NVARCHAR(30),
	LastName NVARCHAR(30),
	JobTitle NVARCHAR(30),
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id),
	HireDate DATE,
	Salary DECIMAL(9,2),
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id)
)

--18

INSERT INTO Towns(Name)
VALUES
('Sofia'),('Plovdiv'),('Varna'),('Burgas')

INSERT INTO Departments(Name)
VALUES
('Engineering'), ('Sales'), ('Marketing'), ('Software Development'), ('Quality Assurance')

INSERT INTO Employees(FirstName, MiddleName, LastName,JobTitle, DepartmentId, HireDate, Salary)
VALUES
('Ivan', 'Ivanov', 'Ivanov',	'.NET Developer',	4,	'2013/02/01',	3500.00),
('Petar', 'Petrov', 'Petrov',	'Senior Engineer', 1, '2004/03/02',	4000.00),
('Maria', 'Petrova', 'Ivanova',	'Intern', 5 ,'2016/08/28',	525.25),
('Georgi', 'Teziev', 'Ivanov',	'CEO', 2, '2007/12/09',	3000.00),
('Peter', 'Pan', 'Pan',	'Intern',3, '2016/08/28', 599.88)

--19

SELECT * FROM Towns
SELECT * FROM Departments
SELECT * FROM Employees

--20

SELECT * FROM TOWNS ORDER BY Towns.Name

SELECT * FROM Departments ORDER BY Departments.Name

SELECT * FROM Employees ORDER BY Employees.Salary DESC

--21

SELECT Name FROM Towns ORDER BY Towns.Name
SELECT Name FROM Departments ORDER BY Departments.Name
SELECT FirstName, LastName, JobTitle, Salary FROM Employees ORDER BY Employees.Salary DESC

--22

UPDATE Employees
	SET Salary = Salary * 1.1

SELECT Salary FROM Employees

--23

USE Hotel

UPDATE Payments
	SET TaxRate *= 0.97

SELECT TaxRate FROM Payments

--24

TRUNCATE TABLE Occupancies
CREATE DATABASE Bakery
GO
USE Bakery
GO

--1

CREATE TABLE Countries(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(50) UNIQUE
)

CREATE TABLE Products(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(25) UNIQUE,
	Description NVARCHAR(250),
	Recipe NVARCHAR(MAX),
	Price DECIMAL(18,2) CHECK(Price>=0)
)

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR(1) CHECK(Gender IN ('M', 'F')),
	Age INT,
	PhoneNumber VARCHAR(10) CHECK(LEN(PhoneNumber)=10),
	CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Feedbacks(
	Id INT PRIMARY KEY IDENTITY,
	Description NVARCHAR(255),
	Rate DECIMAL(18,2) CHECK(Rate BETWEEN 0 AND 10),
	ProductId INT FOREIGN KEY REFERENCES Products(Id),
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id)
)

CREATE TABLE Distributors(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(25) UNIQUE,
	AddressText NVARCHAR(30),
	Summary NVARCHAR(200),
	CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Ingredients(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(30),
	Description NVARCHAR(200),
	OriginCountryId INT FOREIGN KEY REFERENCES Countries(Id),
	DistributorId INT FOREIGN KEY REFERENCES Distributors(Id)

)

CREATE TABLE ProductsIngredients(
	ProductId INT FOREIGN KEY REFERENCES Products(Id),
	IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id),
	PRIMARY KEY(ProductId, IngredientId)
)

--2

INSERT INTO Distributors(Name,CountryId,AddressText, Summary)
VALUES
('Deloitte & Touche',	2,	'6 Arch St #9757',	'Customizable neutral traveling'),
('Congress Title',	13,	'58 Hancock St',	'Customer loyalty'),
('Kitchen People',	1,	'3 E 31st St #77',	'Triple-buffered stable delivery'),
('General Color Co Inc',	21,	'6185 Bohn St #72',	'Focus group'),
('Beck Corporation',	23,	'21 E 64th Ave',	'Quality-focused 4th generation hardware')


INSERT INTO Customers(FirstName,LastName,Age,Gender,PhoneNumber,CountryId)
VALUES
('Francoise',	'Rautenstrauch',	15,	'M',	'0195698399',	5),
('Kendra',	'Loud',	22,	'F',	'0063631526',	11),
('Lourdes',	'Bauswell',	50,	'M',	'0139037043',	8),
('Hannah',	'Edmison',	18,	'F',	'0043343686',	1),
('Tom',	'Loeza',	31,	'M',	'0144876096',	23),
('Queenie',	'Kramarczyk',	30,	'F',	'0064215793',	29),
('Hiu',	'Portaro',	25,	'M',	'0068277755',	16),
('Josefa',	'Opitz',	43,	'F',	'0197887645',	17)



--3

UPDATE Ingredients
	SET DistributorId=35
	WHERE Name IN ('Bay Leaf','Paprika','Poppy')

UPDATE Ingredients
	SET OriginCountryId=14
	WHERE OriginCountryId=8

--4

DELETE FROM Feedbacks
	WHERE CustomerId=14 OR ProductId=5


--5

SELECT P.Name, P.Price,P.Description FROM Products P
	ORDER BY P.Price DESC, P.Name 

--6

SELECT F.ProductId, F.Rate, F.Description, F.CustomerId, C.Age, C.Gender FROM Feedbacks F
	JOIN Customers C ON C.Id=F.CustomerId
	WHERE F.Rate<5
	ORDER BY F.ProductId DESC, F.Rate

--7

SELECT CONCAT(C.FirstName, ' ', C.LastName) 'CustomerName',C.PhoneNumber, C.Gender FROM Customers C
	LEFT JOIN Feedbacks F ON F.CustomerId=C.Id
	WHERE F.Id IS NULL
	ORDER BY C.Id

--8

SELECT C.FirstName, C.Age, C.PhoneNumber FROM Customers C
	JOIN Countries CON ON CON.ID=C.CountryId
	WHERE (FirstName LIKE '%an%' OR PhoneNumber LIKE '%38') AND CON.Name!='Greece' AND C.Age>=21
	ORDER BY C.FirstName,C.Age DESC

--9

SELECT DISTINCT D.Name, I.Name, P.Name, T.Rate  FROM(
SELECT P.Id, AVG(F.Rate)  'Rate' FROM Distributors D
	JOIN Ingredients I ON I.DistributorId=D.Id
	JOIN ProductsIngredients PIN ON PIN.IngredientId=I.Id
	JOIN Products P ON P.Id=PIN.ProductId
	JOIN Feedbacks F ON F.ProductId=P.Id
	GROUP BY P.Id
	HAVING AVG(F.Rate) BETWEEN 5 AND 8) T
	JOIN Feedbacks F ON F.ProductId=T.Id
	JOIN Products P ON P.Id=F.ProductId
	JOIN ProductsIngredients PIN ON PIN.ProductId=P.Id
	JOIN Ingredients I ON I.Id=PIN.IngredientId
	JOIN Distributors D ON D.Id=I.DistributorId
	ORDER BY D.Name, I.Name, P.Name

--10

SELECT T.CountryName,T.DistributorName FROM(
SELECT C.Name 'CountryName', D.Name 'DistributorName', DENSE_RANK() OVER(PARTITION BY C.Name ORDER BY COUNT(I.ID) DESC) 'Rank'  FROM Countries C
	JOIN Distributors D ON D.CountryId=C.Id
	LEFT JOIN Ingredients I ON I.DistributorId=D.Id
	GROUP BY C.Name, D.Name
	) T
	WHERE T.Rank=1
	ORDER BY T.CountryName,T.DistributorName

--11

CREATE VIEW v_UserWithCountries 
AS
SELECT CONCAT(C.FirstName, ' ',C.LastName) 'CustomerName', C.Age,C.Gender, CON.Name FROM Customers C
	JOIN Countries CON ON CON.Id=C.CountryId

--12

CREATE TRIGGER tr_ProductDelete ON Products INSTEAD OF DELETE
AS
BEGIN
	DECLARE @deleteId INT
	SELECT @deleteId=Id FROM deleted

	DELETE FROM ProductsIngredients
		WHERE ProductId=@deleteId

	DELETE FROM Feedbacks
		WHERE ProductId=@deleteId

	DELETE FROM Products
		WHERE Id=@deleteId
END


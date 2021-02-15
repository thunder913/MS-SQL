CREATE DATABASE Bakery
GO
USE BAKERY
GO

CREATE TABLE Countries(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(50) UNIQUE
)

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender VARCHAR(1) CHECK(Gender IN ('M','F')),
	Age INT,
	PhoneNumber VARCHAR(10),
	CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Products(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(25) UNIQUE,
	Description NVARCHAR(250),
	Recipe NVARCHAR(MAX),
	Price DECIMAL(18,2) CHECK(Price>0)
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
	ProductId INT FOREIGN KEY REFERENCES Products(Id) NOT NULL,
	IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id) NOT NULL,
	PRIMARY KEY (ProductId, IngredientId)
)

--2

INSERT INTO Distributors(Name, CountryId, AddressText, Summary)
VALUES
('Deloitte & Touche',	2,	'6 Arch St #9757',	'Customizable neutral traveling'),
('Congress Title',	13,	'58 Hancock St',	'Customer loyalty'),
('Kitchen People',	1,	'3 E 31st St #77',	'Triple-buffered stable delivery'),
('General Color Co Inc',	21,	'6185 Bohn St #72',	'Focus group'),
('Beck Corporation', 23,	'21 E 64th Ave',	'Quality-focused 4th generation hardware')


INSERT INTO Customers(FirstName,LastName,Age,Gender,PhoneNumber,CountryId)
VALUES
('Francoise', 'Rautenstrauch',	15,	'M',	'0195698399', 5),
('Kendra',	'Loud',	22,	'F',	'0063631526',	11),
('Lourdes',	'Bauswell',	50,	'M',	'0139037043',	8),
('Hannah',	'Edmison',	18,	'F',	'0043343686',	1),
('Tom',	'Loeza',	31,	'M', '0144876096',	23),
('Queenie',	'Kramarczyk',	30,	'F',	'0064215793',	29),
('Hiu',	'Portaro',	25,	'M',	'0068277755',	16),
('Josefa',	'Opitz',	43,	'F',	'0197887645',	17)


--3
UPDATE Ingredients
	SET DistributorId=35
	WHERE Name IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
	SET OriginCountryId=14
	WHERE OriginCountryId=8

--4

DELETE FROM Feedbacks
	WHERE CustomerId=14 OR ProductId=5

--5

SELECT P.Name, P.Price, P.Description FROM Products P
	ORDER BY P.Price DESC, P.Name ASC

--6

SELECT F.ProductId, F.Rate, F.Description, F.CustomerId, C.Age, C.Gender FROM Feedbacks F
	JOIN Customers C ON C.Id = F.CustomerId
	WHERE F.Rate<5.0
	ORDER BY F.ProductId DESC, F.Rate ASC

--7

SELECT CONCAT(C.FirstName,' ',C.LastName) 'CustomerName', C.PhoneNumber, C.Gender FROM(
SELECT DISTINCT C.Id FROM Customers C
	LEFT JOIN Feedbacks F ON F.CustomerId=C.Id
	WHERE F.Id IS NULL) TEMP
	JOIN Customers C ON C.Id=TEMP.Id
	ORDER BY C.Id

--8

SELECT C.FirstName, C.Age, C.PhoneNumber FROM Customers C
	JOIN Countries CO ON CO.Id = C.CountryId
	WHERE C.Age>=21 AND (C.FirstName LIKE '%an%' OR C.PhoneNumber LIKE '%38') AND CO.Name!='Greece'
	ORDER BY C.FirstName, C.Age DESC

--9

SELECT D.Name, I.Name, P.Name, AVG(F.Rate) 'AverageRate' FROM Distributors D
	JOIN Ingredients I ON I.DistributorId=D.Id
	JOIN ProductsIngredients PI ON PI.IngredientId = I.Id
	JOIN Products P ON P.Id=PI.ProductId
	JOIN Feedbacks F ON F.ProductId=P.Id
	GROUP BY D.Name, I.Name, P.Name
	HAVING AVG(F.Rate) BETWEEN 5 AND 8
	ORDER BY D.Name, I.Name, P.Name

--10

SELECT D.Id,COUNT(*) 'Count' INTO hasIngredients FROM Distributors D
	JOIN Ingredients I ON I.DistributorId=D.Id
	GROUP BY D.Id

SELECT C.Name, D.Name FROM(
SELECT D.Id 'DistributorId',C.Id 'CountryId', CASE
			WHEN HI.Id IS NULL THEN 0
			ELSE
				HI.Count
			END
			'Count',
			DENSE_RANK() OVER(PARTITION BY C.Id ORDER BY Count DESC) 'Rank'
		FROM Distributors D
	LEFT JOIN hasIngredients HI ON HI.Id=D.Id
	JOIN Countries C ON C.Id=D.CountryId) TEMP
	JOIN Distributors D ON D.Id=TEMP.DistributorId
	JOIN Countries C ON C.Id=D.CountryId
	WHERE TEMP.Rank=1
	ORDER BY C.Name,D.Name

--11

CREATE VIEW v_UserWithCountries AS
	SELECT CONCAT(C.FirstName, ' ', C.LastName)'CustomerName', C.Age, C.Gender, CO.Name FROM Customers C
		JOIN Countries CO ON CO.Id=C.CountryId


--12

CREATE TRIGGER tr_deleteProducts ON Products INSTEAD OF DELETE
AS
BEGIN
	DECLARE @RemoveId INT
	SELECT @RemoveId= Id FROM deleted
	
	DELETE FROM ProductsIngredients
		WHERE ProductId=@RemoveId

	DELETE FROM Feedbacks
		WHERE ProductId=@RemoveId

	DELETE FROM Products
		WHERE Id=@RemoveId
END

DELETE FROM Products WHERE Id = 7
CREATE TABLE Manufacturers(
	ManufacturerID int PRIMARY KEY IDENTITY,
	[Name] nvarchar(30),
	[EstablishedOn] date
)

CREATE TABLE Models(
	ModelID int PRIMARY KEY IDENTITY(101,1) NOT NULL,
	[Name] nvarchar(30),
	ManufacturerID int FOREIGN KEY REFERENCES Manufacturers(ManufacturerID)
)


INSERT INTO Manufacturers(Name, EstablishedOn)
VALUES
('BMW', '07/03/1916'),
('Tesla', '01/01/2003'),
('Lada', '01/05/1966')

INSERT INTO Models(Name, ManufacturerID)
VALUES
('X1', 1),
('i6', 1),
('Model S',	2),
('Model X',	2),
('Model 3',	2),
('Nova', 3)


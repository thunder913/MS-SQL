CREATE TABLE Teachers(
	TeacherID int IDENTITY(101,1),
	[Name] nvarchar(30) NOT NULL,
	ManagerID int
)

INSERT INTO Teachers([Name], ManagerID)
VALUES
('John', NULL),
('Maya', 106),
('Silvia', 106),
('Ted',	105),
('Mark', 101),
('Greta', 101)


ALTER TABLE Teachers
	ADD PRIMARY KEY (TeacherID)


ALTER TABLE Teachers
	ADD FOREIGN KEY (ManagerID) REFERENCES Teachers(TeacherID)


SELECT * FROM Teachers


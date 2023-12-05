DROP DATABASE IF EXISTS aoc2023;
GO

CREATE DATABASE aoc2023;
GO

USE aoc2023;
GO

CREATE SCHEMA ComputatioII;
GO

CREATE TABLE ComputatioII.LineEntry(
    [line entry] VARCHAR(256) NOT NULL
);
GO

CREATE TABLE ComputatioII.Game(
    [game number] INTEGER NOT NULL PRIMARY KEY
);
GO

CREATE TABLE ComputatioII.Bag(
    [game number] INTEGER NOT NULL,
    [blue cubes] INTEGER NOT NULL,
    [green cubes] INTEGER NOT NULL,
    [red cubes] INTEGER NOT NULL,
    FOREIGN KEY ([game number]) REFERENCES ComputatioII.Game([game number]),
    PRIMARY KEY ([game number], [blue cubes], [green cubes], [red cubes])
);
GO

BULK INSERT ComputatioII.LineEntry
FROM '/tmp/Input-II.txt'
WITH(
    ROWTERMINATOR = '\n' 
);
GO

CREATE OR ALTER PROCEDURE ComputatioII.Cube(@bag VARCHAR(256)) RETURNS @return TABLE (
    [green cube] INTEGER NOT NULL,
    [blue cube] INTEGER NOT NULL,
    [red cube] INTEGER NOT NULL
) AS BEGIN
WITH Cubes([blue cube], [red cube], [green cube]) AS (
    SELECT CASE
            WHEN (value LIKE '%blue%') THEN TRIM(REPLACE(value, 'blue', ''))
            ELSE 0
           END AS [blue cube],
           CASE
            WHEN (value LIKE '%red%') THEN TRIM(REPLACE(value, 'red', ''))
            ELSE 0
           END AS [red cube],
           CASE
            WHEN (value LIKE '%green%') THEN TRIM(REPLACE(value, 'green', ''))
            ELSE 0
           END AS [green cube]
    FROM STRING_SPLIT(@bag, ','))
INSERT @return
SELECT [green cube], [blue cube], [red cube] FROM Cubes
RETURN
END;
GO

CREATE OR ALTER FUNCTION ComputatioII.MatchBags(@line VARCHAR(256))
RETURNS @return TABLE (
    [bag] VARCHAR(256) NOT NULL
) AS BEGIN
WITH Bag([bag]) AS (
        SELECT value AS [bag] FROM 
        STRING_SPLIT(SUBSTRING(@line,
                            CAST(PATINDEX('%:%', @line) AS INTEGER) + 1,
                            LEN(@line)),
                    ';'))
INSERT @return
SELECT bag FROM Bag
RETURN
END;
GO

INSERT ComputatioII.Game
SELECT SUBSTRING([line entry], 5, CAST(PATINDEX('%:%', [line entry]) AS INTEGER) - 5) AS [game number]
FROM ComputatioII.LineEntry;

INSERT ComputatioII.Bag
SELECT 
FROM ComputatioII.LineEntry AS li
CROSS JOIN ComputatioII.Game AS g;

SELECT * FROM ComputatioII.Cube(' 2 green, 1 blue');
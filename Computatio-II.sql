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

CREATE OR ALTER PROCEDURE ComputatioII.Cube @bag VARCHAR(256), @gameNumber INTEGER AS
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
INSERT INTO ComputatioII.Bag([game number], [blue cubes], [red cubes], [green cubes])
SELECT @gameNumber AS [game number], SUM([blue cube]), SUM([red cube]), SUM([green cube]) FROM Cubes;
GO

CREATE OR ALTER PROCEDURE ComputatioII.MatchBags @line VARCHAR(256), @gameNumber INTEGER
AS BEGIN

DECLARE @bag VARCHAR(256)
DECLARE cur CURSOR LOCAL for
    SELECT value AS [bag] FROM 
        STRING_SPLIT(SUBSTRING(@line,
                            CAST(PATINDEX('%:%', @line) AS INTEGER) + 1,
                            LEN(@line)),
                    ';')
open cur

fetch next from cur into @bag

WHILE @@FETCH_STATUS = 0 BEGIN

    IF NOT EXISTS (SELECT [game number] FROM ComputatioII.Game WHERE [game number] = @gameNumber)
        INSERT INTO ComputatioII.Game VALUES (@gameNumber);

    EXECUTE ComputatioII.Cube @bag, @gameNumber;

    fetch next from cur into @bag
END

close cur;
deallocate cur;

END;
GO


DECLARE @gameNumber INTEGER
DECLARE @line VARCHAR(256)
DECLARE cur CURSOR LOCAL for
    SELECT SUBSTRING([line entry], 5, CAST(PATINDEX('%:%', [line entry]) AS INTEGER) - 5) AS [game number],
           [line entry]
    FROM ComputatioII.LineEntry

open cur

fetch next from cur into @gameNumber, @line

WHILE @@FETCH_STATUS = 0 BEGIN

    --execute your sproc on each row
    execute ComputatioII.MatchBags @line, @gameNumber;

    fetch next from cur into @gameNumber, @line
END

close cur;
deallocate cur;

-- Possible games given number
DECLARE @green INTEGER = 13;
DECLARE @red   INTEGER = 12;
DECLARE @blue  INTEGER = 14;

SELECT bag.[game number] AS possible
FROM ComputatioII.Bag bag
GROUP BY bag.[game number]
HAVING SUM(bag.[blue cubes]) <= @blue 
AND SUM(bag.[red cubes]) <= @red
AND SUM(bag.[green cubes]) <= @green

SELECT bag.[game number] AS impossible
FROM ComputatioII.Bag bag
GROUP BY bag.[game number]
HAVING SUM(bag.[blue cubes]) > @blue 
OR SUM(bag.[red cubes]) > @red
OR SUM(bag.[green cubes]) > @green;
DROP DATABASE IF EXISTS aoc2023;
GO

CREATE DATABASE aoc2023;
GO

USE aoc2023;
GO

CREATE SCHEMA ComputatioI;
GO

CREATE TABLE ComputatioI.Input(
    [line entry] VARCHAR(128) NOT NULL
);
GO

BULK INSERT ComputatioI.Input
FROM '/tmp/Input.txt'
WITH(
    ROWTERMINATOR = '\n' 
);
GO

CREATE OR ALTER PROCEDURE ComputatioI.CalculateCalibrationValue
AS WITH CalibrationValues([number]) AS (
    SELECT CAST(
    SUBSTRING([line entry], PATINDEX('%[0-9]%', [line entry]), 1) +
    SUBSTRING(REVERSE([line entry]), PATINDEX('%[0-9]%', REVERSE([line entry])), 1) 
    AS INTEGER) FROM ComputatioI.Input
)
SELECT SUM([number]) FROM CalibrationValues;

EXECUTE ComputatioI.CalculateCalibrationValue;

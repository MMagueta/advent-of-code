/*
The newly-improved calibration document consists of lines of text;
each line originally contained a specific calibration value that the
Elves now need to recover. On each line, the calibration value can be
found by combining the first digit and the last digit (in that order)
to form a single two-digit number.

For example:

1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet

In this example, the calibration values of these four lines are 12,
38, 15, and 77. Adding these together produces 142.
*/

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

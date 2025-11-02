--Database
USE [GenAI];
GO

-- Creating a clean table
IF OBJECT_ID('dbo.Enterprise_GenAI_Adoption_Clean','U') IS NULL
BEGIN
    CREATE TABLE dbo.Enterprise_GenAI_Adoption_Clean (
        Company_Name                  nvarchar(200)  NULL,
        Industry                      nvarchar(100)  NULL,
        Country                       nvarchar(100)  NULL,
        GenAI_Tool                    nvarchar(50)   NULL,
        Adoption_Year                 int            NULL,
        Number_of_Employees_Impacted  int            NULL,
        New_Roles_Created             int            NULL,
        Training_Hours_Provided       int            NULL,
        Productivity_Change           decimal(10,2)  NULL,
        Employee_Sentiment            nvarchar(max)  NULL
    );
END
GO

--Cleaning the table to avoid duplicates
TRUNCATE TABLE dbo.Enterprise_GenAI_Adoption_Clean;
GO

-- Replacing the nulls with the right values
INSERT INTO dbo.Enterprise_GenAI_Adoption_Clean (
    Company_Name, Industry, Country, GenAI_Tool,
    Adoption_Year, Number_of_Employees_Impacted,
    New_Roles_Created, Training_Hours_Provided,
    Productivity_Change, Employee_Sentiment
)
SELECT
    Company_Name,
    Industry,
    Country,
    GenAI_Tool,
    TRY_CONVERT(int,               NULLIF(Adoption_Year, '')),
    TRY_CONVERT(int,               NULLIF(Number_of_Employees_Impacted, '')),
    TRY_CONVERT(int,               NULLIF(New_Roles_Created, '')),
    TRY_CONVERT(int,               NULLIF(Training_Hours_Provided, '')),
    TRY_CONVERT(decimal(10,2),     REPLACE(NULLIF(Productivity_Change, ''), ',', '.')),
    Employee_Sentiment
FROM dbo.Enterprise_GenAI_Adoption_Impact;   -- original data
GO

-- Quick validation
SELECT 
    COUNT(*)                                        AS TotalLinhas,
    SUM(CASE WHEN Adoption_Year                IS NULL THEN 1 ELSE 0 END) AS Nulos_Adoption_Year,
    SUM(CASE WHEN Number_of_Employees_Impacted IS NULL THEN 1 ELSE 0 END) AS Nulos_Employees,
    SUM(CASE WHEN New_Roles_Created            IS NULL THEN 1 ELSE 0 END) AS Nulos_NewRoles,
    SUM(CASE WHEN Training_Hours_Provided      IS NULL THEN 1 ELSE 0 END) AS Nulos_Training,
    SUM(CASE WHEN Productivity_Change          IS NULL THEN 1 ELSE 0 END) AS Nulos_Productivity
FROM dbo.Enterprise_GenAI_Adoption_Clean;

SELECT TOP 10 *
FROM dbo.Enterprise_GenAI_Adoption_Clean;

-- Beggining analysis
-- Averages
SELECT
  AVG(CAST(New_Roles_Created            AS float)) AS Avg_NewRoles,
  AVG(CAST(Number_of_Employees_Impacted AS float)) AS Avg_Employees,
  AVG(CAST(Training_Hours_Provided      AS float)) AS Avg_Training,
  AVG(CAST(Productivity_Change          AS float)) AS Avg_Productivity
FROM dbo.Enterprise_GenAI_Adoption_Clean;

-- Country distribuition
SELECT Country, COUNT(*) AS Empresas
FROM dbo.Enterprise_GenAI_Adoption_Clean
GROUP BY Country
ORDER BY Empresas DESC;

-- Tools productivity
SELECT GenAI_Tool, AVG(CAST(Productivity_Change AS float)) AS MediaProd
FROM dbo.Enterprise_GenAI_Adoption_Clean
GROUP BY GenAI_Tool
ORDER BY MediaProd DESC;

-- Top 10 companies which the employes were more impacted 
SELECT TOP 10 Company_Name, Number_of_Employees_Impacted
FROM dbo.Enterprise_GenAI_Adoption_Clean
ORDER BY Number_of_Employees_Impacted DESC;

select avg(new_roles_created) from dbo.Enterprise_GenAI_Adoption_Clean
SELECT 
    COUNT(*) AS Total,
    COUNT(Adoption_Year)               AS ComValor_Year,
    COUNT(Number_of_Employees_Impacted) AS ComValor_Employees,
    COUNT(New_Roles_Created)           AS ComValor_NewRoles,
    COUNT(Training_Hours_Provided)     AS ComValor_Training,
    COUNT(Productivity_Change)         AS ComValor_Productivity
FROM dbo.Enterprise_GenAI_Adoption_Clean;
-- Validation of the data
SELECT DISTINCT Adoption_Year 
FROM dbo.Enterprise_GenAI_Adoption_Clean
WHERE Adoption_Year NOT BETWEEN 2000 AND 2030;

-- Negative productivity or too high
SELECT MIN(Productivity_Change) MinProd, MAX(Productivity_Change) MaxProd
FROM dbo.Enterprise_GenAI_Adoption_Clean;

-- Duplicate companies
SELECT Company_Name, COUNT(*) 
FROM dbo.Enterprise_GenAI_Adoption_Clean
GROUP BY Company_Name
HAVING COUNT(*) > 1;

-- Checking the outlier "15"
SELECT Adoption_Year, COUNT(*) AS n
FROM dbo.Enterprise_GenAI_Adoption_Clean
WHERE Adoption_Year NOT BETWEEN 2000 AND 2030
GROUP BY Adoption_Year;

-- Check some lines
SELECT TOP 10 Company_Name, Country, GenAI_Tool, Adoption_Year
FROM dbo.Enterprise_GenAI_Adoption_Clean
WHERE Adoption_Year NOT BETWEEN 2000 AND 2030
ORDER BY Company_Name;

-- Replace the outlier with value "null"
UPDATE dbo.Enterprise_GenAI_Adoption_Clean
SET Adoption_Year = NULL
WHERE Adoption_Year NOT BETWEEN 2000 AND 2030;


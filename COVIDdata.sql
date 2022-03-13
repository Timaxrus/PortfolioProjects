SELECT *
FROM PortfolioProject1.dbo.CovidDeath
ORDER BY 3, 4

--Data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.dbo.CovidDeath
ORDER BY 1, 2

--Death Rate per Total cases Global, ordered by desc

SELECT location, MAX(CAST(total_cases AS INT)) total_case, MAX(CAST(total_deaths AS INT)) total_deaths, MAX(CAST(total_deaths AS INT))/MAX(total_cases)*100 AS Death_Rate
FROM PortfolioProject1.dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Death_Rate DESC

-- Death Rate per Total cases Uzbekistan

SELECT location, MAX(CAST(total_cases AS INT)) total_case, MAX(CAST(total_deaths AS INT)) total_deaths, MAX(CAST(total_deaths AS INT))/MAX(total_cases)*100 AS Death_Rate
FROM PortfolioProject1.dbo.CovidDeath
WHERE location = 'Uzbekistan'
GROUP BY location
ORDER BY 1

-- Total case per population Global

SELECT location, population, MAX(CAST(total_cases AS INT)) total_case, MAX(total_cases)/population*100 AS Infection_Rate
FROM PortfolioProject1.dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 1

-- Total case per population Uzbekistan

SELECT location, population, MAX(CAST(total_cases AS INT)) total_case, MAX(total_cases)/population*100 AS Infection_Rate
FROM PortfolioProject1.dbo.CovidDeath
WHERE location = 'Uzbekistan'
GROUP BY location, population


-- Country with lowest infection rate per population

WITH tb1 AS (SELECT location, Population, MAX(CAST(total_cases AS INT)) total_case, MAX(total_cases)/population*100 AS Infection_Rate
FROM PortfolioProject1.dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population),

tb2 AS (SELECT MIN(Infection_Rate) infection_rate
FROM tb1)


SELECT location, population, total_case, tb1.Infection_Rate
FROM tb1 
JOIN tb2
ON tb1.Infection_Rate = tb2.infection_rate

-- Country with highest infection rate per population

WITH tb1 AS (SELECT location, Population, MAX(CAST(total_cases AS INT)) total_case, MAX(total_cases)/population*100 AS Infection_Rate
FROM PortfolioProject1.dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population),

tb2 AS (SELECT MAX(Infection_Rate) infection_rate
FROM tb1)


SELECT location, population, total_case, tb1.Infection_Rate
FROM tb1 
JOIN tb2
ON tb1.Infection_Rate = tb2.infection_rate

-- Covid death rate per population. Golobal ordered by desc.

SELECT location, population, MAX(CAST(total_deaths AS INT)) total_death, MAX(CAST(total_deaths AS INT))/population*100 DeathRatePerPop
FROM PortfolioProject1.dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY DeathRatePerPop DESC

-- COVID death rate per population. Uzbekistan

SELECT location, population, MAX(CAST(total_deaths AS INT)) total_death, MAX(CAST(total_deaths AS INT))/population*100 DeathRatePerPop
FROM PortfolioProject1.dbo.CovidDeath
WHERE location = 'Uzbekistan'
GROUP BY location, population

-- Maximu Death Globally by country

SELECT location, MAX(CAST(total_deaths AS INT)) total_death
FROM PortfolioProject1.dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death DESC

-- Maximum Death globally by Continent

SELECT location, MAX(CAST(total_deaths AS INT)) total_death
FROM PortfolioProject1.dbo.CovidDeath
WHERE continent IS NULL AND location IN ('World', 'North America', 'Europe', 'Asia', 'South America', 'Africa', 'Oceania')
GROUP BY location
ORDER BY total_death DESC

-- Global total new cases vs total new death

SELECT SUM(new_cases) TotalNewCases, SUM(CAST(new_deaths AS INT)) TotalNewDeath, SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS DeathRate
FROM PortfolioProject1.dbo.CovidDeath
WHERE continent IS NOT NULL




-- Vaccination information

-- Total number of people vaccinated and total number of people fully vaccincated: Uzbekistan vs Global

SELECT location, population, MAX(CAST(people_vaccinated AS INT)) totalVaccinatedPeople, MAX(CAST(people_fully_vaccinated AS INT)) TotalFullyVaccinatedPeople
FROM PortfolioProject1.dbo.CovidVac
WHERE continent IS NOT NULL and location = 'Uzbekistan'
GROUP BY location, population

SELECT location, population, MAX(CAST(people_vaccinated AS INT)) TotalVaccinatedPeople, MAX(CAST(people_fully_vaccinated AS INT)) TotalFullyVaccinatedPeople
FROM PortfolioProject1.dbo.CovidVac
WHERE continent IS NOT NULL 
GROUP BY location, population

-- Percentage of total number of people vaccinated and fully vaccinated

SELECT location, population, MAX(CAST(people_vaccinated AS INT)) / population*100 AS VaccinatedPeoplePercent, MAX(CAST(people_fully_vaccinated AS INT))/population*100 AS FullyVaccinatedPeoplePercent
FROM PortfolioProject1.dbo.CovidVac
WHERE continent IS NOT NULL and location = 'Uzbekistan'
GROUP BY location, population


SELECT location, population, MAX(CAST(people_vaccinated AS INT)) / population*100 AS VaccinatedPeoplePercent, MAX(CAST(people_fully_vaccinated AS INT))/population*100 AS FullyVaccinatedPeoplePercent
FROM PortfolioProject1.dbo.CovidVac
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY 1

-- Total number of new vaccinations per location

SELECT continent, location, date, population, new_vaccinations, SUM(CONVERT(float, new_vaccinations)) 
OVER (PARTITION BY location ORDER BY location, date) AS NewVacCount
FROM PortfolioProject1.dbo.CovidVac 
WHERE continent IS NOT NULL
ORDER BY 2, 3

-- Temp Table

DROP TABLE IF EXISTS #CountryWithHighestVacPop

CREATE TABLE #CountryWithHighestVacPop
(
location nvarchar(255),
population numeric,
vaccinatedPeoplePercent float,
fullyVaccinatedPeoplePercent float
)

INSERT INTO #CountryWithHighestVacPop
SELECT TOP 1 location, population, MAX(CAST(people_vaccinated AS float)) / population*100 AS VaccinatedPeoplePercent, MAX(CAST(people_fully_vaccinated AS float))/population*100 AS FullyVaccinatedPeoplePercent
FROM PortfolioProject1.dbo.CovidVac
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC


SELECT *
FROM #CountryWithHighestVacPop


-- Creating Views for Visualization

CREATE VIEW GlobalNumbers AS
SELECT SUM(new_cases) TotalNewCases, SUM(CAST(new_deaths AS INT)) TotalNewDeath, SUM(CAST(new_deaths AS INT))/SUM(new_cases) *100 AS DeathRate
FROM PortfolioProject1.dbo.CovidDeath
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1, 2

CREATE VIEW VaccinateRate AS
SELECT location, population, MAX(CAST(people_vaccinated AS INT)) / population*100 AS VaccinatedPeoplePercent, MAX(CAST(people_fully_vaccinated AS INT))/population*100 AS FullyVaccinatedPeoplePercent
FROM PortfolioProject1.dbo.CovidVac
WHERE continent IS NOT NULL 
GROUP BY location, population


CREATE VIEW VaccinateRateUZ AS
SELECT location, population, MAX(CAST(people_vaccinated AS INT)) / population*100 AS VaccinatedPeoplePercent, MAX(CAST(people_fully_vaccinated AS INT))/population*100 AS FullyVaccinatedPeoplePercent
FROM PortfolioProject1.dbo.CovidVac
WHERE continent IS NOT NULL and location = 'Uzbekistan'
GROUP BY location, population

CREATE VIEW GlobalCovidDeath AS
SELECT location, MAX(CAST(total_deaths AS INT)) total_death
FROM PortfolioProject1.dbo.CovidDeath
WHERE continent IS NULL AND location IN ('World', 'North America', 'Europe', 'Asia', 'South America', 'Africa', 'Oceania')
GROUP BY location

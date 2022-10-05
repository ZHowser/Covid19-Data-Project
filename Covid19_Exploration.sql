-- Selecting data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `portfolioproject-364517.CovidData.CovidDeaths`
ORDER BY location, date


-- Looking at Total Cases vs Total Deaths
-- Shows the chance of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `portfolioproject-364517.CovidData.CovidDeaths`
ORDER BY location, date


-- Looking at Total Cases vs Population
-- Shows what percentage of the population has contracted covid-19

SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPopulationPercentage
FROM `portfolioproject-364517.CovidData.CovidDeaths`
ORDER BY location, date


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS HighestInfectedPercentage
FROM `portfolioproject-364517.CovidData.CovidDeaths`
GROUP BY location, population
ORDER BY HighestInfectedPercentage DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM `portfolioproject-364517.CovidData.CovidDeaths`
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing Continents with Highest Death Count

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM `portfolioproject-364517.CovidData.CovidDeaths`
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
FROM `portfolioproject-364517.CovidData.CovidDeaths`
WHERE continent is not null
GROUP BY date
ORDER BY 1,2



-- Looking at Total Populations vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `portfolioproject-364517.CovidData.CovidDeaths` AS dea
JOIN `portfolioproject-364517.CovidData.CovidVaccinations` AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- TEMP TABLE WORKAROUND

WITH PercentPopVaccinated AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM `portfolioproject-364517.CovidData.CovidDeaths` AS dea
  JOIN `portfolioproject-364517.CovidData.CovidVaccinations` AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopVaccinated


-- Creating View to Store Data for Later Vizualizations

CREATE VIEW IF NOT EXISTS `portfolioproject-364517.CovidData.View` AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `portfolioproject-364517.CovidData.CovidDeaths` AS dea
JOIN `portfolioproject-364517.CovidData.CovidVaccinations` AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3
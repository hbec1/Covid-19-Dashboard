SELECT * FROM PortfolioProject..coviddeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT * FROM PortfolioProject..covidvaccinations$
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..coviddeaths$
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..coviddeaths$
WHERE LOCATION LIKE '%states%'
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT Location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..coviddeaths$
--WHERE LOCATION LIKE '%states%'
ORDER BY 1,2


--Looking at Countries with Highes Infection Rate compared to Population
SELECT Location,population,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..coviddeaths$
--WHERE LOCATION LIKE '%states%'
GROUP BY Location, Population 
ORDER BY PercentagePopulationInfected desc

--Showing countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeaths$
--WHERE LOCATION LIKE '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT 

SELECT continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeaths$
--WHERE LOCATION LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Showing continets with the highest death count per population


SELECT continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeaths$
--WHERE LOCATION LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers
SELECT SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS deathpercentage
FROM PortfolioProject..coviddeaths$
--Where locations like '%states%'
WHERE continent is not null
--Group by date
ORDER BY 1,2



--Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE 

WITH PopvsVac(continent,Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPoluationVaccinated
Create Table #PercentPoluationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPoluationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPoluationVaccinated

-- Creating View to store for later visualization

Create View PercentPoluationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--ORDER  BY 2,3


SELECT * FROM PercentPoluationVaccinated
SELECT * 
FROM covid..CovidDeath
order by 1,4

--SELECT * 
--FROM covid..CovidVaccine
--order by 3,4

--SELECT location, date, total_cases, total_deaths, population
--FROM covid..CovidDeath
--order by 1,2


-- Total Cases VS Total Death

SELECT location, date, population, total_cases,(CAST(total_cases as float)/CAST(population as float))*100 as Death_Percentage
FROM covid..CovidDeath
--WHERE location like '%Malaysia%'
order by 1,2


--Contries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as Highest_Count,MAX((CAST(total_cases as float))/CAST(population as float))*100 as PercentPopulationInfected
FROM covid..CovidDeath
--WHERE location like '%Malaysia%'
GROUP BY population, location
order by PercentPopulationInfected DESC

--Showing countries with highes death count per Population
SELECT location, MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM covid..CovidDeath
--WHERE location like '%Malaysia%'
WHERE continent is not NULL
GROUP BY location
order by Total_Death_Count DESC 


-- Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeath
FROM covid..CovidDeath
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeath DESC

-- Global numbers

SELECT SUM(new_cases), SUM(CAST(new_deaths as int)), SUM(CAST(new_deaths as int))/SUM(new_cases)*100
FROM covid..CovidDeath
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Total Population VS Vaccinations
WITH PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeople)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeople
--, ()*100
FROM covid..CovidDeath dea
JOIN covid..CovidVaccine vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeople/Population)*100
FROM PopvsVac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime,
population float,
new_vaccinations int,
RollingPeople nvarchar(255)
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeople
FROM covid..CovidDeath dea
JOIN covid..CovidVaccine vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeople/Population)*100
FROM #PercentPopulationVaccinated

Create View PercentPopulations as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeople
FROM covid..CovidDeath dea
JOIN covid..CovidVaccine vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

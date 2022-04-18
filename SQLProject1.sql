SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--SELECTION OF OUR DATA 

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- TOTAL CASES VS TOTAL DEATHS
SELECT location, date, total_cases, total_deaths, population, (total_deaths)/(total_cases)*100 as RatioDeaths
FROM PortfolioProject..CovidDeaths
--WHERE location like '%France%'
WHERE location = 'France'
ORDER BY 1,2

-- TOTAL CASES VS POPULATION 
-- PERCENTAGE OF POPULATION GOT COVID
SELECT location, date, total_cases, population, (total_cases)/(population)*100 as RatioCases
FROM PortfolioProject..CovidDeaths
WHERE location = 'France'
ORDER BY 1,2

-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as HighestRatioInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY HighestRatioInfected desc

-- COUNTRIES WITH THE HIGHEST DEATHS COUNT
SELECT location, MAX(cast(Total_deaths as int)) as MaxDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY MaxDeaths desc

-- CONTINENTS WITH THE HIGHEST DEATHS COUNT PER POPULATION
SELECT continent, MAX(cast(Total_deaths as int)) as MaxDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY MaxDeaths desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- JOINING TABLES 
SELECT *
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--TOTAL VACCINATIONS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingNewVaccinations
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- USE CTE TO CALCUL NEW DOSES COMPARED TO POPULATION

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePeopleWithNewDose
From PopvsVac
--where location ='France'
order by location, date

-- SAME THING WITH A TABLE 

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 PercentagePeopleWithNewDose
From PercentPopulationVaccinated
--Where location ='France'
Order by location, date



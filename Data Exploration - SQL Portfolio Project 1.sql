SELECT *
FROM PortfolioProject..CovidDeaths
--where continent is not null
where continent is null


--Looking at TotalCases vs TotalDeaths and their Percentage
--DeathPercentage column shows the likelihood of dying if you contract Covid in India on specific dates

select location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float))*100 as DeathPercentage  
from PortfolioProject..CovidDeaths
where location like '%india%' and continent is not null
order by 1,2


--Looking at TotalCases vs Populaton
--Shows percentage of people who contracted Covid

select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
--where location like 'india'
where continent is not null
order by 1,2


--Countries with Highest Infection rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/MAX(population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
Group By location, population
order by PercentPopulationInfected DESC


--Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount DESC


--Let's break things down by continents
--This is one way to do this [Way-1]

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 DESC


--This is another way to do this [Way-2]

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
Group By location
Order By TotalDeathCount DESC


--GLOBAL NUMBERS
--Grouping By Date

select date, SUM(new_cases) as TotalCases, SUM(new_deaths) TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and new_cases <> 0
Group By date
Order By 1


--Total cases, Total Deaths, Death Percentage till last date in CovidDeaths file

select SUM(new_cases) as TotalCases, SUM(new_deaths) TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Order By 1


--Taking a look into CovidVaccinations Table

select *
from PortfolioProject..CovidVaccinations


--Let's Join CovidDeaths Table and CovidVaccinations Table on Date and Location

select *
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = dea.date


--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--The below SUM is a Rolling Count
, SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as PeopleVaccinatedTillDateByLocation
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--[USING A CTE] Finding People-Vaccinated per Population by date by creating a CTE
--CTE

WITH PopVsVac(continent, location, date, population, new_vaccinations, PeopleVaccinatedTillDateByLocation)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--The below SUM is a Rolling Count
, SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as PeopleVaccinatedTillDateByLocation
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (PeopleVaccinatedTillDateByLocation/population)*100 as PeopleVaccinatedPerPopulationPercentage
from PopVsVac


--[USING A TEMP TABLE] Finding People-Vaccinated per Population by date by creating a TEMP TABLE
--TEMP TABLE

DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinatedTillDateByLocation numeric
)

INSERT INTO #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--The below SUM is a Rolling Count
, SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as PeopleVaccinatedTillDateByLocation
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (PeopleVaccinatedTillDateByLocation/Population)*100
FROM #PercentPeopleVaccinated


--Creating VIEW to store or use data for later visualizations

Create VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--The below SUM is a Rolling Count
, SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as PeopleVaccinatedTillDateByLocation
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3


--Using VIEW we created above

select *
from PercentPopulationVaccinated

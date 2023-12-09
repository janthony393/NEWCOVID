select *
from CovidDeaths$

ORDER BY 3,4


--select *
--from CovidVaccinations$
--ORDER BY 3,4


Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
ORDER BY 1,2

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

-- Total Cases vs Population

Select location, date, total_cases, population, (total_cases/population)*100 AS PopvsCase
from CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

-- Countries Highest Infection Rate Compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopInfected
from CovidDeaths$
Group by location, population
ORDER BY PercentofPopInfected desc

-- Showing Countries with Highest Death Count Per Population



Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
WHERE continent is null
Group by location
order by TotalDeathCount desc

-- Continent with highest DeathCount per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(New_deaths as int))/SUM (new_cases)*100 as DeathPercentage
from CovidDeaths$
--WHERE location like '%states%'
where continent is not null
--GROUP BY date
ORDER BY 1,2

Select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(New_deaths as int))/SUM (new_cases)*100 as DeathPercentage
from CovidDeaths$
--WHERE location like '%states%'
where continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
   ORDER BY 2,3

-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, new_Vaccinations, RollingPeopleVacinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

select *, (RollingPeopleVacinated)*100
from PopvsVac

-- Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (225),
Location nvarchar (225),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select *, (RollingPeopleVacinated)*100
from #PercentPopulationVaccinated

--Creating View

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select *
from PercentPopulationVaccinated
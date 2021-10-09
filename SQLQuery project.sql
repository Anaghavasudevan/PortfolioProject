Select *
From portfolioProject..['covid deaths$']
where continent is not null
order by 3,4


Select*
From portfolioProject..covidvaccinations$
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From portfolioProject..['covid deaths$']
order by 1,2

--Looking at Total cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From portfolioProject..['covid deaths$']
where location like '%canada%'
order by 1,2

--Looking at total cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as PercentAffectedpopulation
From portfolioProject..['covid deaths$']
--where location like '%canada%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, Max(total_cases) as highestinfectionrate, Max((total_cases/population))*100 as percentAffectedpopulation
From portfolioProject..['covid deaths$']
--where location like '%canada%'
Group by location,population
order by PercentAffectedpopulation desc

--Countries with the Highest Death rate per population

Select location, Max(cast(total_deaths as int)) as Totaldeathcount
From portfolioProject..['covid deaths$']
--where location like '%canada%'
where continent is not null
Group by location
order by Totaldeathcount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, Max(cast(total_deaths as int)) as Totaldeathcount
From portfolioProject..['covid deaths$']
--where location like '%canada%'
where continent is not null
Group by continent
order by Totaldeathcount desc

--showing the continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as Totaldeathcount
From portfolioProject..['covid deaths$']
--where location like '%canada%'
where continent is not null
Group by continent
order by Totaldeathcount desc


-- Global Numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From portfolioProject..['covid deaths$']
--where location like '%canada%'
where continent is not null
group by date
order by 1,2

-- total cases 

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From portfolioProject..['covid deaths$']
--where location like '%canada%'
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccinatination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from portfolioProject..['covid deaths$'] dea
Join portfolioProject..covidvaccinations$  vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with popvsvac (continent,location,date,population, new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from portfolioProject..['covid deaths$'] dea
Join portfolioProject..covidvaccinations$  vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac



--TEMP TABLE

DROP TABLE IF EXISTS #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from portfolioProject..['covid deaths$'] dea
Join portfolioProject..covidvaccinations$  vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #percentpopulationvaccinated

-- Creating view to store data for later visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from portfolioProject..['covid deaths$'] dea
Join portfolioProject..covidvaccinations$  vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
From percentpopulationvaccinated

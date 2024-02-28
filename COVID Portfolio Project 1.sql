select *
from PortfolioProject1..CovidDeath
order by 3,4

--select *
--from PortfolioProject1..CovidVaccination
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeath
order by 1,2

--Look at Total Cases vs Total Deaths
--shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
from PortfolioProject1..CovidDeath
where location like '%Nigeria%'
order by 1,2
--OR (error occured in the above query due unmatching data type, hence I applied the steps below)

select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / Nullif (CONVERT(float, total_cases),0))*100 As DeathPercentage
from PortfolioProject1..CovidDeath
where location like '%Nigeria%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population that got covid

select location, date, total_cases, population, (total_cases/population) *100 As PercentPopulationInfected
from PortfolioProject1..CovidDeath
--where location like '%Nigeria%'
order by 1,2

--Looking at Countries with the highest infection rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population) *100 As PercentPopulationInfected
from PortfolioProject1..CovidDeath
--where location like '%Nigeria%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Looking at Countries with Highest Death Count per Population

select location, Max(cast(total_Deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeath
--where location like '%Nigeria%'
where continent is null
group by location
order by TotalDeathCount desc

--Breaking it down by Continent

select continent, Max(cast(total_Deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeath
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population

select continent, Max(cast(total_Deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeath
--where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing continents with the highest infection rate

select continent, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population) *100 As PercentPopulationInfected
from PortfolioProject1..CovidDeath
--where location like '%Nigeria%'
where continent is not null
group by continent, population
order by PercentPopulationInfected desc


-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)*100 / nullif (sum(new_cases), 0) as DeathPercentage
from PortfolioProject1..CovidDeath
--where location like '%Nigeria%'
Where continent is not null 
Group by date
order by 1,2

--Overall total_cases, total_deaths and death Percentage across the world

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)*100 / nullif (sum(new_cases), 0) as DeathPercentage
from PortfolioProject1..CovidDeath
--where location like '%Nigeria%'
Where continent is not null 
--Group by date
order by 1,2

-- Joining CovidDeath & CovidVaccination table on location and dates

select *
from PortfolioProject1..CovidDeath dea
join PortfolioProject1..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date

-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject1..CovidDeath dea
join PortfolioProject1..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject1..CovidDeath dea
join PortfolioProject1..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject1..CovidDeath dea
join PortfolioProject1..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as Percentagevaccinated
from PopvsVac



--TEMP TABLE

--drop table if exists #percentPopulationVaccinated
create table #PercentPopulationVaccinated1
(
Continent varchar (255),
Location varchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentPopulationVaccinated1 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject1..CovidDeath dea
join PortfolioProject1..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as Percentagevaccinated
from #PercentPopulationVaccinated1


--CREATING VIEWS TO STORE FOR LATER VISUALIZATION
 
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from PortfolioProject1..CovidDeath dea
join PortfolioProject1..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *
from PercentPopulationVaccinated




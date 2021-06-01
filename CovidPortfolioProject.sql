select *
from [Portfolio Project]..CovidDeaths
where continent is not null

select * 
from [Portfolio Project]..CovidVaccinations
where continent is not null



Select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths 
where continent is not null
order by 1,2





-- Looking at Total Cases vs Total Deaths
--Likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths 
where location like '%India%' and continent is not null
order by 1,2


--Looking at the total cases vs population
--Shows what percentage of population got Covid
Select location, date,population,  total_cases, (total_cases/population) * 100 as CasesPercentage
from [Portfolio Project]..CovidDeaths 
--where location like '%India%' and continent is not null
order by 1,2

--Looking at countries with Highest Infection Rate compared to population

Select location, population, MAX(total_cases) as HighestInfection, MAX(total_cases/population) * 100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths 
where continent is not null
group by population, location
order by PercentPopulationInfected desc


--Showing the countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCOunt
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by TotalDeathCOunt desc


--Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCOunt
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCOunt desc


--Global Numbers

Select date, sum(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location like '%India%' 
where continent is not null
group by date
order by 1,2


Select  sum(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location like '%India%' 
where continent is not null
--group by date
order by 1,2


--Joing Covid Death and Covid Vaccination Table
--Looking at Total Population vs Total Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) Over(partition by dea.location order by dea.location , dea.date)
as CummulativePeopleVaccinated
from [Portfolio Project]..CovidDeaths as dea 
join [Portfolio Project]..CovidVaccinations as Vac
 on dea.location = vac.location
 and dea.date= vac.date
 where dea.continent is not null 
 order by 2,3


 --Use CTE

 with PopvsVac (Continent, location, Date, population, new_vaccination, CummulativePeopleVaccinated)
 as
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) Over(partition by dea.location order by dea.location , dea.date)
as CummulativePeopleVaccinated
from [Portfolio Project]..CovidDeaths as dea 
join [Portfolio Project]..CovidVaccinations as Vac
 on dea.location = vac.location
 and dea.date= vac.date
 where dea.continent is not null 
 --order by 2,3

 )
select *, (CummulativePeopleVaccinated/population) * 100
from PopvsVac



--TEMP TABLE	

create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location  nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CummulativePeopleVaccinated numeric 
)


Insert into #PercentagePopulationVaccinated 
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) Over(partition by dea.location order by dea.location , dea.date)
as CummulativePeopleVaccinated
from [Portfolio Project]..CovidDeaths as dea 
join [Portfolio Project]..CovidVaccinations as Vac
 on dea.location = vac.location
 and dea.date= vac.date
 where dea.continent is not null 
 --order by 2,3

 select *, (CummulativePeopleVaccinated/population) * 100
from #PercentagePopulationVaccinated




--Creating view to store data for later visulalization

create view PercentPopulationVaccinated 
as select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) Over(partition by dea.location order by dea.location , dea.date)
as CummulativePeopleVaccinated
from [Portfolio Project]..CovidDeaths as dea 
join [Portfolio Project]..CovidVaccinations as Vac
 on dea.location = vac.location
 and dea.date= vac.date
 where dea.continent is not null 
 --order by 2,3


 select * 
 from PercentPopulationVaccinated
select * 
from POrtfolio..CovidDeaths$
where continent is not null
order by 3,4

--select * 
--from POrtfolio..CovidVaccinations$
--order by 3,4

--looking at Total Cases vs total deaths


Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage

From POrtfolio..CovidDeaths$
where continent is not null 
and location like '%India%'

order by 1, 2


--looking at total cases vs total population 
--shows what percentage of population got covid 


Select location, date,  population ,total_cases, (cast(total_cases as float)/cast( population as float))*100 as Percentpopulationinfected

From POrtfolio..CovidDeaths$
where location like '%India%'
and continent is not null

order by 1, 2

--looking at countries with highest infection rate  compared to population 

Select location,  population ,MAX(total_cases ) as HighestInfectionCount, MAX(cast(total_cases as float)/cast( population as float))*100 as Percentpopulationinfected
From POrtfolio..CovidDeaths$
--where location like '%India%'
group by  location,  population
order by Percentpopulationinfected desc


--Showing countries with highest death count per population 


Select location,  Max(cast(total_deaths as int)) as TotalDeathCount
From POrtfolio..CovidDeaths$
--where location like '%India%'
where continent is not null
group by  location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT
Select continent,  Max(cast(total_deaths as int)) as TotalDeathCount
From POrtfolio..CovidDeaths$
--where location like '%India%'
where continent is not null
group by  continent
order by TotalDeathCount desc

--global numbers

Select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From POrtfolio..CovidDeaths$
--where location like '%India%'
where continent is not null
--group by date

order by 1, 2
--looking at the total population vs vaccination s

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations )) over(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
from POrtfolio..CovidDeaths$ dea
join POrtfolio..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--USE CTE

with popvsvac(Continent ,location, date ,population,New_vaccinations,Rollingpeoplevaccinated)
as
( 
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations )) over(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
from POrtfolio..CovidDeaths$ dea
join POrtfolio..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3

)
select *,(Rollingpeoplevaccinated/population)*100
from popvsvac

--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 Rollingpeoplevaccinated numeric
 )
insert into #percentpopulationvaccinated
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations )) over(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
from POrtfolio..CovidDeaths$ dea
join POrtfolio..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3
select*,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--creating view to store data for later visualization 

create view percentpopulationvaccinated as
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations )) over(partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
from POrtfolio..CovidDeaths$ dea
join POrtfolio..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3

select * from percentpopulationvaccinated
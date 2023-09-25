--select *
--from [dbo].[CovidVaccination]
--order by 3,4


select *
from [dbo].[CovidDeath]
where continent is not null
order by 3,4

---------- SELECT DATA TO B USED IN COVIDDEATH

select location, date, total_cases, new_cases, total_deaths, population
from jerrymy..CovidDeath
where continent is not null
order by 1,2



---------------- TOTAL CASES VS TOTAL DEATH ----------

select location, date, total_cases, total_deaths ,(cast(total_deaths as int)/total_cases)*100 as DeathPercentage
from jerrymy..CovidDeath
where location like '%states%' 
order by 1,2



----------------- TOTALCASES VS POPULATION -----------
select location, date, population, total_cases --,(total_cases/population)*100 as PopulationPercentage
from jerrymy..CovidDeath
-- where location like '%states%' 
order by 1,2


---------------- LOOKING AT COUNTRY WITH HIGHEST INFECTION RATE COMPARE TO POPULATION ------------

select location, population, max(total_cases) as HighestInfectionRate,max((total_cases/population))*100 as PopulationPercentageInfected
from jerrymy..CovidDeath
-- where location like '%states%'
group by location, population
order by PopulationPercentageInfected desc





------------------ COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION -----------

select location, max(cast(Total_Deaths as int)) as TotalDeathCount
from jerrymy..CovidDeath
-- where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc



-------------------- BREAK DOWN BY CONTINENT ------------

select location, max(cast(Total_Deaths as int)) as TotalDeathCount
from jerrymy..CovidDeath
-- where location like '%states%'
where continent is  null
group by location
order by TotalDeathCount desc



------------- CONTINENT WITH HIGHEST DEATHCOUNT --------------

select continent, max(cast(Total_Deaths as int)) as TotalDeathCount
from jerrymy..CovidDeath
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc





----------- GLOBAL NUMBERS ----------

select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from jerrymy..CovidDeath
where continent is not null
-- group by date
order by 1,2


------------ Total population vs Vaccination ------------


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from jerrymy..CovidDeath dea
join jerrymy..CovidVaccination vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 2,3

---------------- CTE ------------------


With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
   select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
   over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
   from jerrymy..CovidDeath dea
   join jerrymy..CovidVaccination vac
       on dea.location = vac.location
       and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3
)
select * ,(RollingPeopleVaccinated/Population)*100
from PopvsVac


----------------TEMP TABLE-----------------

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from jerrymy..CovidDeath dea
join jerrymy..CovidVaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from jerrymy..CovidDeath dea
join jerrymy..CovidVaccination vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
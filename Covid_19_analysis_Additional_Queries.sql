select * 
from [Portfolio Project]..CovidDeaths$
order by 3,4

--select * 
--from [Portfolio Project]..CovidVaccinations$
--order by 3,4

--Ensure that changes are made to Portfolio Project
USE [Portfolio Project]

--- Select the relevant data for project
create view RelevantData as 
select location, date, total_cases,new_cases,total_deaths,population
from [Portfolio Project]..CovidDeaths$
where continent is not null
--order by 1,2

select * from RelevantData

-- Total cases v.s. total deaths
create view DeathPercentage as
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from [Portfolio Project]..CovidDeaths$
where continent is not null
--order by 1,2

-- Total cases v.s. total deaths for united states (likelyhood of dying of covid in United States)
create view DeathPercentage_unitedstates as
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from [Portfolio Project]..CovidDeaths$
where location like '%states%' and continent is not null
--order by 1,2

-- Total cases v.s. total deaths for India (likelyhood of dying of covid in India)
create view DeathPercentage_india as
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from [Portfolio Project]..CovidDeaths$
where location like '%india%' and continent is not null
--order by 1,2

-- Total cases v.s the population united states(% of population that has covid)
create view PercentPopulationInfected_unitedstates as
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
where location like '%states%' and continent is not null
--order by 1,2

-- Total cases v.s the population India (% of population that has covid)
create view PercentPopulationInfected_india as
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
where location like '%india%' and continent is not null
--order by 1,2

-- Total cases v.s the population (% of population that has covid)
create view PercentPopulationInfected_draft as
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
where continent is not null
--order by 1,2

-- Countries with highest infection rate compared to population

create view Heighest_infectrate_vs_Population_with_date as
select location, population,date, max(total_cases) as HeighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by population, location,date
--order by PercentPopulationInfected desc
select * from Heighest_infectrate_vs_Population_with_date

create view Heighest_infectrate_vs_Population as
select location, population,date, max(total_cases) as HeighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
where continent is not null


-- Countries with heighest deathcount per population
create view TotalDeathCount as
select location, max(cast(total_deaths as float)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by location
--order by TotalDeathCount desc

-- Deathcount by continent
create view TotalDeathCount_by_continent_maxlocation as
select continent, max(cast(total_deaths as float)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by continent
--order by TotalDeathCount desc

-- Another way by continent
create view TotalDeathCount_by_continent as
select location, max(cast(total_deaths as float)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is null
group by location
--order by TotalDeathCount desc

-- Continents with heighest deathcount per population
create view TotalDeathCount_per_population as
select location, max(cast(total_deaths as float)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is null and location not like '%world%'
group by location
--order by TotalDeathCount desc

-- Global Values
create view TotalDeathCount_world as
select sum(new_cases) as TotalCases, sum(cast(new_deaths as float)) as TotalDeaths, sum(cast(new_deaths as float))*100/sum(new_cases)  as DeathPercentage 
from [Portfolio Project]..CovidDeaths$
where continent is not null
--group by date
--order by 1,2

--Joining the Covid Death and Covid Vaccination tables -
select *
from [Portfolio Project]..CovidDeaths$ as dea join [Portfolio Project]..CovidVaccinations$ as vac
	on  dea.location = vac.location and dea.date = vac.date

-- Total population v.s. vaccination
create view population_vs_vaccination as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(float,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ as dea join [Portfolio Project]..CovidVaccinations$ as vac
	on  dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

-- Rolling Count of Vaccinated Population
-- Create a CTE

 with popvsvacc (Continent, Location, Date, Population, New_Vaccinations, RollingCountPeopleVaccinated)
 as
 (
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(float,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ as dea join [Portfolio Project]..CovidVaccinations$ as vac
	on  dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
 )


select *, (RollingCountPeopleVaccinated/Population)*100
from popvsvacc



-- Rolling Count of Vaccinated Population using Temp Table 

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_Vaccinations numeric, RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(float,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ as dea join [Portfolio Project]..CovidVaccinations$ as vac
	on  dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null

	select * from #PercentPopulationVaccinated

	
	select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
from #PercentPopulationVaccinated


-- Creating a view for the above

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(convert(float,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ as dea join [Portfolio Project]..CovidVaccinations$ as vac
	on  dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null

	select * from PercentPopulationVaccinated





Create View PercentPeopleVaccinated_final as
select *, (RollingCountPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
from PercentPopulationVaccinated

select * from PercentPeopleVaccinated_final


-- Final Vaccinated Population
create view maxVaxinatedPopulatioPercent as
select ppvf.continent,ppvf.location, ppvf.population, max(ppvf.RollingCountPeopleVaccinated) as TotalVaccinatedPopulation, max(ppvf.PercentPeopleVaccinated) as Total_vaccinated_percent
from PercentPeopleVaccinated_final ppvf
group by ppvf.continent,ppvf.location, ppvf.population

select * from maxVaxinatedPopulatioPercent
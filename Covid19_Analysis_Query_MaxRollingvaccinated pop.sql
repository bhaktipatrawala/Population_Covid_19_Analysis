
-- Rolling Count of Vaccinated Population - Maximum
-- Create a CTE
with popvsvaccmax (Continent, Location, Population, New_Vaccinations, RollingCountPeopleVaccinated, RowNum)
as
(
    select 
        dea.continent, 
        dea.location, 
        dea.population,
        vac.new_vaccinations,
        sum(convert(float,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountPeopleVaccinated,
        ROW_NUMBER() over (partition by dea.location order by dea.location, dea.date desc) as RowNum
    from 
        [Portfolio Project]..CovidDeaths$ as dea 
    join 
        [Portfolio Project]..CovidVaccinations$ as vac on dea.location = vac.location and dea.date = vac.date
    where 
        dea.continent is not null
)
select 
    Continent, 
    Location, 
    Population, 
    New_Vaccinations,
    RollingCountPeopleVaccinated,
    max((RollingCountPeopleVaccinated/Population)*100) as MaxPercentPeopleVaccinated
from 
    popvsvaccmax
where 
    RowNum = 1
group by 
    Continent, 
    Location, 
    Population, 
    New_Vaccinations,
    RollingCountPeopleVaccinated;

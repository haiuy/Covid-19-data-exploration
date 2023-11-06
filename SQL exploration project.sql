Select *
From CovidDeaths$
order by 3,4


Select *
From CovidVaccinations$
order by 3,4
-- Vietnam Death percentage
Select Location, date, total_cases, total_deaths, (convert (float, total_deaths)/NULLif(Convert(Float,total_cases),0))*100 as DeathPercentage
From CovidDeaths$
where location like 'vietnam'
Order by 1,2
-- Vietnam infected rate
select location, date, total_cases, population, (convert(float,total_cases)/population)*100 as InfectedRate
From CovidDeaths$
where location like 'Vietnam'
order by 1,2
-- highest infected rate countries
select location, population, max(total_cases) as HighestInfectionCount, max(convert(float,total_cases)/population)*100 as InfectedRate
From CovidDeaths$
where continent is not null
Group by location, population
order by InfectedRate desc
--countries with highest death count
select location, max(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths$
where continent is not null
group by location
order by HighestDeathCount desc
--Total death count by continent
select location, max(cast(total_deaths as int)) as HighestDeathCount
From CovidDeaths$
where continent is null
group by location
order by HighestDeathCount desc
--Global number
select date, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/Nullif(sum(new_cases),0)*100 as DeathRate
From CovidDeaths$
where continent is not null
Group by date
order by 1,2 desc
--looking at total population vs total vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations) ) over (partition by dea.location order by dea.location, dea.date) as CumulativeVaccination
From CovidDeaths$ dea
Join CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3
--UseCTE
with PopvsVac (Continent, Location, Date, Populations, New_vaccinations, CumulativeVaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations) ) over (partition by dea.location order by dea.location, dea.date) as CumulativeVaccination
From CovidDeaths$ dea
Join CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

)
select *, (CumulativeVaccination/Populations)*100
From PopvsVac
--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations float,
CumulativeVaccination float
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations) ) over (partition by dea.location order by dea.location, dea.date) as CumulativeVaccination
From CovidDeaths$ dea
Join CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select*, (CumulativeVaccination/Population)*100
From #PercentPopulationVaccinated
--Creating view to store data for later visualisation
Create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float,vac.new_vaccinations) ) over (partition by dea.location order by dea.location, dea.date) as CumulativeVaccination
From CovidDeaths$ dea
Join CovidVaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select*
From PercentagePopulationVaccinated
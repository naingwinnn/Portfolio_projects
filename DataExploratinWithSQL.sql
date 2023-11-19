select * from dbo.covid19death
order by 1,2

select location,date,total_cases,new_cases,total_deaths,population
from dbo.covid19death
order by 1,2

--looking at total cases vs total deaths
--show the likelihood of dying if you contact covid
select location,date,Total_cases,Total_deaths,(Total_deaths/Total_cases)*100 as DeathPercentage
from dbo.covid19death
where location = 'Myanmar'
order by 1,2

--total cases vs population
select location,date,Total_cases,population,(Total_cases/population)*100 as ContactPercentage
from dbo.covid19death
where location = 'Myanmar'
order by 1,2

--looking at countries with highest infection rate per population
select location,population,max(Total_cases) as HighestInfectionCount,max((Total_cases/population))*100 as PercentPopulationInfected
from dbo.covid19death
group by location,population
order by PercentPopulationInfected desc

--showing countries with highest deathcount per population
select location,max(Total_deaths) as TotalDeathCount
from dbo.covid19death
where continent is not null
group by location
order by TotalDeathCount desc

--showing continents with highest deathcount per population
select continent,max(Total_deaths) as TotalDeathCount
from dbo.covid19death
where continent is not null
group by continent
order by TotalDeathCount desc

---Global numbers
select date,sum(Total_cases),sum(Total_deaths)
from dbo.covid19death
where continent is not null
group by date 
order by 1,2

--looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations)over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated / dea.population)*100 
from dbo.covid19death dea
join dbo.covid19vaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--create cte
with PopvsVac(continent,location,date,population,new_vaccinatons,RollingPeopleVaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(CONVERT(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.covid19death dea
join dbo.covid19vaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 
from PopvsVac;

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(CONVERT(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.covid19death dea
join dbo.covid19vaccination vac
on dea.location = vac.location and
dea.date = vac.date

select *,(RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated;

--creating view to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(CONVERT(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo.covid19death dea
join dbo.covid19vaccination vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null


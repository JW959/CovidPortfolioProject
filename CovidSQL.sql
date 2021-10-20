select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4




select location,date,total_cases, new_cases, total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Total cases vs Total Deaths
select location,date,total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%australia%'
order by 1,2

--Total cases vs Population
select location,date,total_cases, population, (total_cases/population)*100 as CasesPercentage 
from PortfolioProject..CovidDeaths
where location like '%australia%'
order by 1,2


--Higest Infected Rate
select location,max(total_cases) as MaxCount, population, (max(total_cases)/population)*100 as MaxCasesPercentage 
from PortfolioProject..CovidDeaths
group by location,population
order by MaxCasesPercentage desc


--Continents with the highest Deathcount
select continent, max(cast(total_deaths as int)) as MaxDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by MaxDeaths desc



--CTE
with PopVsVacci (Continent, location, date ,population , new_vaccinations,PeopleVaccinated )
as
(
--Total population vs. Vaccination in Certain Location
select d.continent, d.location, d.date, population, v.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition BY d.location order by d.location, d.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
	on d.location=v.location and
		d.date = v.date
where d.continent is not null
)

select*,(PeopleVaccinated/population)*100 as VaccinatedPercentage
from PopVsVacci
order by VaccinatedPercentage desc



--TEMP Table
Drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, population, v.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition BY d.location order by d.location, d.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
	on d.location=v.location and
		d.date = v.date
where d.continent is not null

select*,(PeopleVaccinated/population)*100 as VaccinatedPercentage
from #PercentPopulationVaccinated


--create View to store data

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, population, v.new_vaccinations,
sum(cast(new_vaccinations as bigint)) OVER (Partition BY d.location order by d.location, d.date) as PeopleVaccinated
from PortfolioProject..CovidDeaths d
join PortfolioProject..CovidVaccination v
	on d.location=v.location and
		d.date = v.date
where d.continent is not null


select *
from PercentPopulationVaccinated

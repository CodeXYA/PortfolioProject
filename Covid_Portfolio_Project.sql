SELECT * 
FROM portfolioproject.covid_vaccinations
where continent is not null
order by 3,4;

-- SELECT * 
-- FROM portfolioproject.covid_deaths
-- order by 3,4;

select location, date, total_cases, total_deaths, population
from portfolioproject.covid_deaths
where location like '%india%' and continent is not null
order by 1,2;

-- Looking at Total Cases vs Total Deaths  
-- Shows the Likelyhood od dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolioproject.covid_deaths
where location like '%india%'
order by 1,2;

-- Looking at the total cases vs population
-- Shows what percentage of population got covid
select location, date, total_cases, (total_cases/population)*100 as death_percentage
from portfolioproject.covid_deaths
order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population
select location, total_cases, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as percent_population_infected
from portfolioproject.covid_deaths
group by location, population
order by percent_population_infected desc;

-- Showing countries with Highest Deatch count per population
select location, MAX(cast(total_deaths as signed)) as total_death_count
from portfolioproject.covid_deaths
where continent is not null
group by location
order by total_death_count desc;

-- LET'S BREAK DOWN BY CONTINENT

select continent, MAX(cast(total_deaths as signed)) as total_death_count
from portfolioproject.covid_deaths
where continent is not null
group by continent
order by total_death_count desc;

-- Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as signed)) as total_deaths, sum(cast(new_deaths as signed))/sum(new_cases)*100 as death_percentage
from portfolioproject.covid_deaths
where continent is not null and total_cases is not null
group by date
order by date, total_cases;


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.date) as rolling_people_vaccinated
from portfolioproject.covid_deaths dea
join portfolioproject.covid_vaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- With Pop vs Vac
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(vac.new_vaccinations,signed)) over (partition by dea.location order by dea.date) as rolling_people_vaccinated
from portfolioproject.covid_deaths dea
join portfolioproject.covid_vaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (rolling_people_vaccinated/population)*100
from PopvsVac;

-- TEMP TABLE
use portfolioproject;
drop table if exists percent_population_vaccinated;
create temporary Table percent_population_vaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population int,
new_vaccination float,
rolling_people_vaccinated float
);
insert into percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(vac.new_vaccinations,signed)) over (partition by dea.location order by dea.date) as rolling_people_vaccinated
from portfolioproject.covid_deaths dea
join portfolioproject.covid_vaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

select *, (rolling_people_vaccinated/population)*100
from percent_population_vaccinated;

-- CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATION

create view percentagepopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(vac.new_vaccinations,signed)) over (partition by dea.location order by dea.date) as rolling_people_vaccinated
from portfolioproject.covid_deaths dea
join portfolioproject.covid_vaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
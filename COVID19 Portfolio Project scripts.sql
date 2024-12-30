

SELECT * FROM portfolioproject.coviddeaths;
-- LOAD DATA infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CovidDeaths.csv' INTO TABLE coviddeaths FIELDS terminated by ',' enclosed by '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- SHOW VARIABLES LIKE 'secure_file_priv';
-- set session sql_mode = '';
-- set session sql_mode = 'STRICT_TRANS_TABLES';


-- describe coviddeaths;

select * from PortfolioProject.coviddeaths
where continent is not null
order by 3,4;

-- select * from PortfolioProject.covidvaccinations
-- order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject.coviddeaths order by 1,2;

-- looking at total cases vs total deaths
-- shows a likelihood of dying if you get covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.coviddeaths
where location like '%states%'
order by 1,2;

-- update coviddeaths
-- set date = 
-- str_to_date(date,'%m/%d/%y');


-- update covidvaccinations
-- set date = 
-- str_to_date(date,'%m/%d/%y');

-- looking at total cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
from PortfolioProject.coviddeaths
where location like '%ghana%'
order by 1,2;

-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentageOfPopulationInfected
from PortfolioProject.coviddeaths
-- where location like '%ghana%'
group by location, population
order by percentageofPopulationInfected desc;

-- showing countries with highest death count per population

select location,
max(cast(total_deaths as signed)) as TotalDeathCount
from PortfolioProject.coviddeaths
-- where location like '%ghana%'
-- where continent is not null
group by location
order by TotalDeathCount desc;


-- LETS BREAK THINGS DOWN BY CONTINENT

select location,
max(cast(total_deaths as signed)) as TotalDeathCount
from PortfolioProject.coviddeaths
-- where location like '%ghana%'
-- where continent is null
group by location
order by TotalDeathCount desc;

-- showing continent with higest death count

select continent,
max(cast(total_deaths as signed)) as TotalDeathCount
from PortfolioProject.coviddeaths
-- where location like '%ghana%'
where continent is not null
group by continent
order by TotalDeathCount desc;

-- global number

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as signed)) as TotalDeaths,
sum(cast(new_deaths as signed))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.coviddeaths
-- where location like '%states%'
where location is not null
group by date
order by 1,2;

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as signed)) as TotalDeaths,
sum(cast(new_deaths as signed))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.coviddeaths
-- where location like '%states%'
where location is not null
-- group by date
order by 1,2;

-- looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as SIGNED)) over (PARTITION BY dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated

from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
	on dea.location =vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as SIGNED)) over (PARTITION BY dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated

from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
	on dea.location =vac.location
    and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;


-- temp table
DROP TEMPORARY TABLE  if EXISTS  PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as SIGNED)) over (PARTITION BY dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
	on dea.location =vac.location
    and dea.date = vac.date;
-- where dea.continent is not null;
-- order by 2,3;


SELECT 
    *, (RollingPeopleVaccinated / population) * 100
FROM
    PercentPopulationVaccinated;


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as SIGNED)) over (PARTITION BY dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
	on dea.location =vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

select *
from percentpopulationvaccinated;


create view DeathPercentage as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.coviddeaths
-- where location like '%states%'
order by 1,2;

select *
from deathpercentage;

create view PercentageofPopulationInfected as
select location, date, population, total_cases, (total_cases/population)*100 as PercentageOfPopulationInfected
from PortfolioProject.coviddeaths
-- where location like '%ghana%'
order by 1,2;



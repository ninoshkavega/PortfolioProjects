Select *
from PortfolioProject ..CovidDeaths 
where continent is not null
order by 3,4

Select *
from PortfolioProject ..CovidVaccinations
order by 3,4

-- select the data we are going to be using
select Location, date,total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- whats the percentage 

Select Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%panama%'
order by 1,2
 
 --looking at the total cases vs the population

 Select Location, date,total_cases as 'total de casos', population, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where location like '%Panama%'
order by 1,2

--what countries has the highest infection rate compared to population
-- Andorra sería el lugar con más infectados de acuerdo a su poblacion
-- con una poblacion de 77265, el 17% infectados 

 Select Location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%Panama%'
group by location, population
order by PercentagePopulationInfected desc


--Showing the countries with highest death count per population
-- error in data type total death convert to int using cast 
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%Panama%'
where continent is not null
group by location
order by TotalDeathCount desc

-- LETS BREAK THING DOWN BY CONTINENT 
-- showing continents with the highest death count population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%Panama%'
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS 

Select date, SUM(new_cases) as 'Daily Cases Globally', SUM(cast(new_deaths as int)) as 'Daily Deaths Globally', sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage  -- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2

--JOINING TABLES OF THE DATABASE 
--ALIAS DEA Y VAC 
Select *
from PortfolioProject ..CovidVaccinations dea
Join PortfolioProject..CovidDeaths vac
on dea.location = vac.location
and dea.date = vac.date

--USE CTE 
with PopvsVac (Continent, location,date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
--LOOKING AT TOTAL POPULATON VS VACCINATIONS 
-- specifying from which table we are taking the columns (dea or vac)
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date ) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not  null
--order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100 as 'Vaccinated Percentage'
from PopvsVac


--TEMP TABLE 
DROP TABLE IF EXISTS #TABLA 
Create Table #TABLA
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #TABLA
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date ) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not  null
--order by 2,3
select *,(RollingPeopleVaccinated/population)*100
from #TABLA


-- Create one view to store data for late visualization 

Create view PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) Over (Partition by dea.Location order by dea.Location, dea.date ) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentagePopulationVaccinated
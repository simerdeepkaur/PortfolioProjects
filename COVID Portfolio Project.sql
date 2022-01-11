select * 
from PortfolioProject..CoDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CoVaccinations
--order by 3,4

--select the data we are going to be using

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CoDeaths
order by 1,2

--Looking at the Total Cases Vs Total Deaths
--shows likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CoDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of population got covid

select Location,date,total_cases,Population, (total_cases/population)*100 as PercentPopulation
from PortfolioProject..CoDeaths
--where location like '%states%'
order by 1,2

--Looking at countries with highest Rate compared to Population

select Location,Population,max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CoDeaths
--where location like '%states%'
group by location,population
order by PercentPopulationInfected desc


--Showing the countries ith the highest Death Count per Population
select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CoDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Lets break things down by continent

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CoDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--showing continents with the highest death count per population

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CoDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100  as DeathPercentage
from PortfolioProject..CoDeaths
--where location like '%states%'
where continent is not null
--Group By date
order by 1,2

--JOINING TABLE
--Looking at Total Population Vs Vaccination

Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CoDeaths dea
Join PortfolioProject..CoVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CoDeaths dea
Join PortfolioProject..CoVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CoDeaths dea
Join PortfolioProject..CoVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CoDeaths dea
Join PortfolioProject..CoVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
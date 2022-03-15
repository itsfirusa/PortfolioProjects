Select *
From PortfolioProject..CovidDeaths
WHERE continent is not null
Order by 3,4

----Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From PortfolioProject..CovidDeaths
Where location like '%turkey'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Popualation
-- Shows what percentage of population got covid
Select location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%turkey'
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%turkey'
Group by location, population
order by PercentPopulationInfected DESC

-- Showing countries with highest death count per population
Select location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%turkey'
Where continent is not null
Group by location
order by TotalDeathCount DESC

--LET'S BREAK THÝNGS DOWN BY CONTINENT


-- Showing continents with highest death count per population

Select continent, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%turkey'
Where continent is not null
Group by continent
order by TotalDeathCount DESC

-- Global Numbers

Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int )) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage --total_deaths, (total_deaths/total_cases)*100 AS death_percentage
From PortfolioProject..CovidDeaths
--Where location like '%turkey'
Where continent is not null
Group By date
order by 1,2

Select SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int )) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
From PortfolioProject..CovidDeaths
--Where location like '%turkey'
Where continent is not null
--Group By date
order by 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
and new_vaccinations is not null
Order by 2,3

-- Using CTE
-- the number of columns using CTE must be equal with the columns you select

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--Order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select * 
From PercentPopulationVaccinated
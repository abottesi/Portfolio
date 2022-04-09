--Looking at the CovidDeaths Table
SELECT *
FROM 
    [PortfolioProject-Covid]..CovidDeaths
WHERE
    continent is not null
Order by 3,4;


--Looking at the CovidVaccinations Table
SELECT * 
FROM [PortfolioProject-Covid]..CovidVaccinations
WHERE
    continent is not null
Order by 3,4;


--Selecting Data that is nessary for project
SELECT
    Location, date, total_cases, new_cases, total_deaths, population
FROM
    [PortfolioProject-Covid]..CovidDeaths
WHERE
    continent is not null
ORDER by    
    1,2;


--Looking at Total Cases vs Total Deaths
--Shows the probability of dying if a person contracts covid in their country 
SELECT
    Location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as Death_Percentage
FROM
    [PortfolioProject-Covid]..CovidDeaths
WHERE 
    Location = 'United States'
    and continent is not null
ORDER by    
    1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of the population got Covid in the United States
SELECT
    Location, date, total_cases, population, (total_cases/population)* 100 as Percent_Population_Infected
FROM
    [PortfolioProject-Covid]..CovidDeaths
WHERE 
    Location = 'United States'
   and continent is not null
ORDER by    
    1,2;


-- Shows what percentage of the population got Covid
SELECT
    Location, date, total_cases, population, (total_cases/population)* 100 as Percent_Population_Infected
FROM
    [PortfolioProject-Covid]..CovidDeaths
WHERE 
     continent is not null
ORDER by    
    1,2;


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT
    Location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))* 100 as Percent_Population_Infected
FROM
    [PortfolioProject-Covid]..CovidDeaths
WHERE
    continent is not null 
GROUP by 
    Location, population
ORDER by    
    Percent_Population_Infected DESC;


-- Showing Countries with the Highest Death Count per Population
SELECT
    Location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM
    [PortfolioProject-Covid]..CovidDeaths
WHERE
    continent is not null
GROUP by 
    Location
ORDER by    
   Total_Death_Count DESC;


-- Focusing on Continents
--Showing contintents with the highest death count per population
SELECT
   continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM
    [PortfolioProject-Covid]..CovidDeaths
WHERE
    continent is not null
GROUP by 
    continent
ORDER by    
   Total_Death_Count DESC;


--Global Numbers
--Global Numbers: Per Day
SELECT
    date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases) *100 as Death_Percentage
FROM
    [PortfolioProject-Covid]..CovidDeaths
WHERE 
    continent is not null
Group By 
    date
ORDER by    
    1,2;

--Global Numbers: Overall
SELECT
    SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases) *100 as Death_Percentage
FROM
    [PortfolioProject-Covid]..CovidDeaths
WHERE 
    continent is not null
ORDER by    
    1,2;

--Looking at Total Population vs Vaccinations
 SELECT
    dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as Bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
 FROM
    [PortfolioProject-Covid]..CovidDeaths dea
    JOIN   
    [PortfolioProject-Covid]..CovidVaccinations vac
    ON 
        dea.location = vac.location
        and dea.date = vac.date
 WHERE 
    dea.continent is not null
 ORDER by 2,3;


 --USE CTE

With PopvsVac (continent, location, date, population,new_vaccinations, Rolling_People_Vaccinated)
 as
 (
	SELECT
    dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as Bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
	FROM
    [PortfolioProject-Covid]..CovidDeaths dea
    JOIN   
    [PortfolioProject-Covid]..CovidVaccinations vac
    ON 
        dea.location = vac.location
        and dea.date = vac.date
	WHERE 
    dea.continent is not null
)
SELECT
	*, (Rolling_People_Vaccinated/population)*100
FROM
	PopvsVac;


	--TEMP TABLE 
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	New_vaccinations numeric,
	Rolling_People_Vaccinated numeric,
)
INSERT into #PercentPopulationVaccinated
	SELECT
    dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as Bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
	FROM
    [PortfolioProject-Covid]..CovidDeaths dea
    JOIN   
    [PortfolioProject-Covid]..CovidVaccinations vac
    ON 
        dea.location = vac.location
        and dea.date = vac.date
	WHERE 
    dea.continent is not null

SELECT
	*, (Rolling_People_Vaccinated/population)*100
FROM
	#PercentPopulationVaccinated;


--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
	SELECT
    dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as Bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
	FROM
    [PortfolioProject-Covid]..CovidDeaths dea
    JOIN   
    [PortfolioProject-Covid]..CovidVaccinations vac
    ON 
        dea.location = vac.location
        and dea.date = vac.date
	WHERE 
    dea.continent is not null;

	Select 
		*
	FROM
		PercentPopulationVaccinated;
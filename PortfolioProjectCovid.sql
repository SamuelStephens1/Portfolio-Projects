select*
From PortfolioProject..[Covid Deaths]
Where continent is not null
order by 3,4

--select*
--From PortfolioProject..[Covid Vaccinations]
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[Covid Deaths]
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CASE
        WHEN TRY_CAST(total_cases AS float) IS NOT NULL AND TRY_CAST(total_cases AS float) <> 0
            THEN (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100
        ELSE NULL
    END AS DeathPercentage
FROM
    PortfolioProject..[Covid Deaths]
ORDER BY
    location,
    date;

	-- Looking at Total Cases vs Population
	-- Shows what percentage of population got covid
	Select continent, date, total_cases, Population, (total_cases/population)*100 as GotCovid
From PortfolioProject..[Covid Deaths]
Where continent is not null
order by 1,2


-- Looking at Countries with highest infection Rate compared to Population

Select continent, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..[Covid Deaths]
Group by continent, Population
order by PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[Covid Deaths]
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing the continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[Covid Deaths]
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..[Covid Deaths]
where continent is not null
order by 1,2

SELECT
    date,
    SUM(new_cases) AS total_new_cases,
    SUM(new_deaths) AS total_new_deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE (SUM(new_deaths) * 100.0) / NULLIF(SUM(new_cases), 0)
    END AS deathPercentage
FROM
    PortfolioProject..[Covid Deaths]
WHERE
   continent is not null
GROUP BY
    date
ORDER BY
    date;

	-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
--
From PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[Covid Vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac(Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[Covid Vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingpeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

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
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.Date) as RollingPeopleVaccinated
From PortfolioProject..[Covid Deaths] dea
Join PortfolioProject..[Covid Vaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, (RollingpeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulatioVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM
    PortfolioProject..[Covid Deaths] dea
JOIN
    PortfolioProject..[Covid Vaccinations] vac
ON
    dea.location = vac.location
    AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;


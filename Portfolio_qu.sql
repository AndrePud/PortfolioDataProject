Select *
From PorfolioP..CovidDeaths$
Order by 3,4

-- Select the data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PorfolioP..CovidDeaths$
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Looking at the percentage for United States
-- Shows the chances of you dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PorfolioP..CovidDeaths$
Where location like '%states%'
Order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of the population got covid

Select location, date, population, total_cases, (total_cases/population) * 100 as PopulationCovidPercentage
From PorfolioP..CovidDeaths$
--Where location like '%states%'
Order by 1,2


-- Lookinh at countries with Highest Infection Rate compared to Population
-- Displaying your own country infection percentage

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PopulationInfectedPercent
From PorfolioP..CovidDeaths$
--Where location like '%states%'
GROUP By location, population 
Order by PopulationInfectedPercent desc


-- Looking at countries with Highest Death Count compare to population 
-- Only displaying results that aren't null 

Select continent, MAX(Convert(int,total_deaths)) as TotalDeathCount
From PorfolioP..CovidDeaths$
Where continent is not null
GROUP By continent
Order by TotalDeathCount desc

--Breaking it down by continents

Select location, MAX(Convert(int,total_deaths)) as TotalDeathCount
From PorfolioP..CovidDeaths$
Where continent is not null
GROUP By continent
Order by TotalDeathCount desc 

-- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as GlobaldeathPercentage
From PorfolioP..CovidDeaths$
Where continent is not null
GROUP By date 
Order by 1,2



--Joining the two tables
--Join on location and date
-- Looking at total Population Vs Vaccination
--displaying continent and location when showing the percentage
--Want to do a rolling count in vaccination to add up from the last one
--So using partition by to help accomplish this
-- Remember to convert vaccinations into integer from floats
-- Partition it by the location, so the count can start over and not have the SUM keep rising without end
--Then order by in the Partition by the location and date which will seperate it out
-- Then name the no column name Rolling People Vaccination 
-- Can't do a aggrigate function for a column just created
-- Use a Cte to help determine how many people are vaccinate from dividing rolling people and population

With PopsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeoVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeoVaccination
From PorfolioP..CovidDeaths$ as dea
Join PorfolioP..CovidVaccinations$ as vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
)


--Now can use the Cte Popsvac to do the calculation mentioned above

Select *, (RollingPeoVaccination/Population) * 100 as PercentVacPeop
From PopsVac


--Creating a Temp table
-- Adding Drop table incase any changes needs to be made

DROP Table if exists #PercenPopulationVac

Create Table #PercenPopulationVac
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccination numeric,
RollingPeoVaccination numeric,
)

-- inserting the data

Insert into #PercenPopulationVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeoVaccination
From PorfolioP..CovidDeaths$ as dea
Join PorfolioP..CovidVaccinations$ as vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeoVaccination/Population) * 100 as PercentVacPeop
From #PercenPopulationVac  


--Creating View to store data for late visiluzation 
DROP View IF exists PercenPopulation
CREATE VIEW PercenPopulation as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingPeoVaccination
From PorfolioP..CovidDeaths$ as dea
Join PorfolioP..CovidVaccinations$ as vac
	On dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
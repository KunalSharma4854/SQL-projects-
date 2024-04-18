Select * 
from CovidDeath 

-- data we are going to use 

select location, date, total_cases, total_deaths, population
from CovidDeath
order by 1,2
 
 -- looking at total cases Vs total deaths 
 -- likely hood of dying if you if you contract covid in your country 
 select location, date, total_cases, total_deaths, population,
 (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 as DeathPercentage 
 from CovidDeath
 Where location like '%India%'
 order by 1,2 

 -- looking at total cases vs population 

 select location, date, total_cases, population,
 (CONVERT(float, total_cases)/ population)* 100 as effectedpopulationperc
 from CovidDeath
 Where location like '%states%'
 order by 1,2 
 

 -- country wiith Highest infection rate 
  select location, Max(total_cases) as Highest_Infection_count, population,
 Max((CONVERT(float,total_cases)/ population))* 100 as Effected_Population_Perc
 from CovidDeath
 Group by location, population
 order by Effected_Population_Perc desc
 
 -- showing countries with highest Death count per population 

  select location, Max(total_deaths) as Total_Death_count 
 from CovidDeath
 where continent is not null
 Group by location
 order by Total_Death_count desc
  
 select location, Max(total_deaths) as Total_Death_count 
 from CovidDeath
 where continent is  null
 Group by location
 order by Total_Death_count desc


 -- Global numbers
 -- Daily number of new cases 
 
  select  date, sum(new_cases) as Total_cases, sum(convert(float,new_deaths)) as Total_deaths , sum(convert(float,new_deaths)) / sum(new_cases) *100 as Death_Percentage
 --(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 as DeathPercentage 
 from CovidDeath
 where continent is not null
 Group by date
 order by 1,2 

   select   sum(new_cases) as Total_cases, sum(convert(float,new_deaths)) as Total_deaths , sum(convert(float,new_deaths)) / sum(new_cases) *100 as Death_Percentage
 --(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 as DeathPercentage 
 from CovidDeath
 where continent is not null
 --Group by date
 order by 1,2 

 -- joining of tables 
 
 select dea.continent, dea.location, dea.date, dea.population,
 vac.new_vaccinations
 from CovidVaccination vac
 join CovidDeath dea
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null 
 order by 2,3

 -- Total population vs Vaccinaation look into this 

 select dea.continent, dea.location, dea.date, dea.population,
 vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
 order by  convert(varchar(50),dea.location), dea.date) as Rolling_People_Vaccinated
 from CovidVaccination vac
 join CovidDeath dea
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null 
 order by 2,3

 -- use CTE

 with PopVsVac (continent, location, date, population,New_Vaccination, Rolling_People_Vaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population,
 vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
 order by  convert(varchar(50),dea.location), dea.date) as Rolling_People_Vaccinated
 from CovidVaccination vac
 join CovidDeath dea
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null 
 --order by 2,3
 )
 select *, ((convert(float, Rolling_People_Vaccinated))/population)* 100
 from PopVsVac




 -- use temp table 


 Drop table if exists #PercentagePopulationVaccinated
 Create table #PercentagePopulationVaccinated
 (
 Continent nvarchar(250),
 location varchar(250), 
 date datetime,
 population numeric, 
 new_Vaccination numeric,
 Rolling_People_Vaccinated numeric
 )

 Insert into #PercentagePopulationVaccinated
  select dea.continent, dea.location, dea.date, dea.population,
 vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
 order by  convert(varchar(50),dea.location), dea.date) as Rolling_People_Vaccinated
 from CovidVaccination vac
 join CovidDeath dea
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null 
 --order by 2,3

 select *, ((convert(float, Rolling_People_Vaccinated))/population)* 100
 from #PercentagePopulationVaccinated
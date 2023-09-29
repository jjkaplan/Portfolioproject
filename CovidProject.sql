-- Retrieve data from coviddeaths and order by date and location
SELECT
    date,
    location,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths
ORDER BY
    date,
    location;

-- Calculate death percentage by location for records containing "state" in the location name
SELECT
    id,
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 2) AS DeathPercentage,
    population
FROM
    coviddeaths
WHERE
    location LIKE "%state%"
ORDER BY
    id,
    date;

-- Calculate percentage of population infected for records in coviddeaths
SELECT
    id,
    location,
    date,
    total_cases,
    population,
    ROUND((total_cases / population) * 100, 2) AS PercentagePopulationInfected
FROM
    coviddeaths
ORDER BY
    id,
    date;

-- Find countries with the highest infection rate compared to population
SELECT
    location,
    population,
    MAX(CAST(total_cases AS SIGNED)) AS HighestInfected,
    (MAX(total_cases / population)) * 100 AS PercentagePopulationInfected
FROM
    coviddeaths
GROUP BY
    location,
    population
ORDER BY
    PercentagePopulationInfected DESC;

-- Find countries with the highest death count per population
SELECT
    location,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY
    location
ORDER BY
    TotalDeathCount DESC;

-- Break down death counts by continent
SELECT
    continent,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY
    continent
ORDER BY
    TotalDeathCount DESC;

-- Show continent with the highest death count per population
SELECT
    continent,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
GROUP BY
    continent
ORDER BY
    TotalDeathCount DESC;

-- Calculate global numbers for total cases, total deaths, and death percentage
SELECT
    date,
    SUM(CAST(total_cases AS SIGNED)) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_death,
    ROUND(SUM(CAST(new_deaths AS SIGNED)) / SUM(CAST(new_cases AS SIGNED)) * 100, 2) AS DeathPercentage
FROM
    coviddeaths
GROUP BY
    date
ORDER BY
    date;

-- Calculate global total cases, total deaths, and death percentage
SELECT
    SUM(CAST(total_cases AS SIGNED)) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_death,
    ROUND(SUM(CAST(new_deaths AS SIGNED)) / SUM(CAST(new_cases AS SIGNED)) * 100, 2) AS DeathPercentage
FROM
    coviddeaths;

-- Join coviddeaths and covidvaccinations data on location
SELECT *
FROM
    coviddeaths AS cd
JOIN
    covidvaccinations AS cv
ON
    cd.location = cv.location;

-- Calculate population vs. vaccinations and rolling people vaccinated using a CTE
WITH PopvsVac (
    continent,
    location,
    date,
    population,
    new_vaccinations,
    RollingpeopleVaccinated
)
AS
(
    SELECT
        cd.continent,
        cd.location,
        cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingpeopleVaccinated
    FROM
        coviddeaths AS cd
    JOIN
        covidvaccinations AS cv
    ON
        cd.location = cv.location
    WHERE
        cd.continent IS NOT NULL
)
SELECT *,
    (RollingpeopleVaccinated / population) * 100 AS PercentagePopulationVaccinated
FROM PopvsVac;

-- Create a temporary table to store population vs. vaccinations data
DROP TABLE IF EXISTS percentagepopulationVaccinated;
CREATE TABLE percentagepopulationVaccinated (
    continent VARCHAR(255),
    location VARCHAR(255),
    date VARCHAR(255),
    population INT,
    new_vaccinations VARCHAR(255),
    RollingpeopleVaccinated DECIMAL(10, 2)
);
INSERT INTO percentagepopulationVaccinated
SELECT
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingpeopleVaccinated
FROM
    coviddeaths AS cd
JOIN
    covidvaccinations AS cv
ON
    cd.location = cv.location;
SELECT *, (RollingpeopleVaccinated / population) * 100 AS PercentagePopulationVaccinated
FROM percentagepopulationVaccinated;

-- Create a view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingpeopleVaccinated
FROM
    coviddeaths AS cd
    JOIN covidvaccinations as cv
    on cd.location = cv.location
    WHERE continent is not null;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

CREATE TABLE country (
    country_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    continent VARCHAR(50) NOT NULL,
    population BIGINT NOT NULL
);

CREATE TABLE state (
    state_id INT PRIMARY KEY,
    country_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    population BIGINT NOT NULL,

    CONSTRAINT fk_state_country
        FOREIGN KEY (country_id)
        REFERENCES country(country_id),

    CONSTRAINT uq_state_country_name
        UNIQUE (country_id, name)
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

CREATE TABLE district (
    district_id INT PRIMARY KEY,
    state_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,

    CONSTRAINT fk_district_state
        FOREIGN KEY (state_id)
        REFERENCES state(state_id),

    CONSTRAINT uq_district_state_name
        UNIQUE (state_id, name)
);
CREATE TABLE covid_case_stats (
    case_id INT PRIMARY KEY,
    country_id INT NOT NULL,
    state_id INT NOT NULL,
    district_id INT,
    report_date DATE NOT NULL,
    report_time TIME NOT NULL DEFAULT '08:00:00',

    confirmed INT NOT NULL DEFAULT 0,
    deaths INT NOT NULL DEFAULT 0,
    recovered INT NOT NULL DEFAULT 0,

    new_confirmed INT NOT NULL DEFAULT 0,
    new_deaths INT NOT NULL DEFAULT 0,
    active_cases INT NOT NULL DEFAULT 0,

    CONSTRAINT fk_cases_country
        FOREIGN KEY (country_id)
        REFERENCES country(country_id),

    CONSTRAINT fk_cases_state
        FOREIGN KEY (state_id)
        REFERENCES state(state_id),

    CONSTRAINT fk_cases_district
        FOREIGN KEY (district_id)
        REFERENCES district(district_id),

    CONSTRAINT uq_case_scope_date
        UNIQUE (country_id, state_id, district_id, report_date)
);
CREATE TABLE vaccination (
    vaccine_id INT PRIMARY KEY,
    state_id INT NOT NULL,
    date DATE NOT NULL,

    total_doses BIGINT NOT NULL DEFAULT 0,
    first_dose BIGINT NOT NULL DEFAULT 0,
    second_dose BIGINT NOT NULL DEFAULT 0,

    covaxin BIGINT NOT NULL DEFAULT 0,
    covishield BIGINT NOT NULL DEFAULT 0,
    sputnik_v BIGINT NOT NULL DEFAULT 0,

    precaution_dose BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT fk_vaccine_state
        FOREIGN KEY (state_id)
        REFERENCES state(state_id),

    CONSTRAINT uq_vaccine_state_date
        UNIQUE (state_id, date)
);
CREATE TABLE testing (
    testing_id INT PRIMARY KEY,
    state_id INT NOT NULL,
    date DATE NOT NULL,
    total_samples BIGINT NOT NULL DEFAULT 0,
    positive_cases BIGINT,
    negative_cases BIGINT,

    CONSTRAINT fk_testing_state
        FOREIGN KEY (state_id)
        REFERENCES state(state_id),

    CONSTRAINT uq_testing_state_date
        UNIQUE (state_id, date)
);
CREATE TABLE global_covid_stats (
    global_stat_id INT PRIMARY KEY,
    country_id INT NOT NULL,
    report_date DATE NOT NULL,

    confirmed BIGINT NOT NULL DEFAULT 0,
    deaths BIGINT NOT NULL DEFAULT 0,
    recovered BIGINT NOT NULL DEFAULT 0,
    new_confirmed BIGINT NOT NULL DEFAULT 0,
    new_deaths BIGINT NOT NULL DEFAULT 0,
    active_cases BIGINT NOT NULL DEFAULT 0,

    people_vaccinated_1dose BIGINT NOT NULL DEFAULT 0,
    people_fully_vaccinated BIGINT NOT NULL DEFAULT 0,

    CONSTRAINT fk_global_country
        FOREIGN KEY (country_id)
        REFERENCES country(country_id),

    CONSTRAINT uq_global_country_date
        UNIQUE (country_id, report_date)
);
CREATE INDEX idx_cases_date
ON covid_case_stats(report_date);

CREATE INDEX idx_cases_state_date
ON covid_case_stats(state_id, report_date);

CREATE INDEX idx_vaccine_date
ON vaccination(date);

CREATE INDEX idx_testing_date
ON testing(date);

CREATE INDEX idx_global_date
ON global_covid_stats(report_date);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT * FROM country;

COPY country(country_id, name, continent, population)
FROM 'D:/Stundets_Shared_covid_db_project (2)/Stundets_Shared_covid_db_project/data/countries.csv'
DELIMITER ','
CSV HEADER;

COPY state(state_id, name, population, country_id)
FROM 'D:/Stundets_Shared_covid_db_project (2)/Stundets_Shared_covid_db_project/data/states.csv'
DELIMITER ','
CSV HEADER;

COPY district(district_id, state_id, name)
FROM 'D:/Stundets_Shared_covid_db_project (2)/Stundets_Shared_covid_db_project/data/districts.csv'
DELIMITER ','
CSV HEADER;

COPY covid_case_stats(
    case_id,
    country_id,
    state_id,
    report_date,
    report_time,
    confirmed,
    deaths,
    recovered,
    new_confirmed,
    new_deaths,
    active_cases
)
FROM 'D:/Stundets_Shared_covid_db_project (2)/Stundets_Shared_covid_db_project/data/covid_case_stats.csv'
DELIMITER ','
CSV HEADER;

COPY vaccination(
    vaccine_id,
    state_id,
    date,
    total_doses,
    first_dose,
    second_dose,
    covaxin,
    covishield,
    sputnik_v,
    precaution_dose
)
FROM 'D:/Stundets_Shared_covid_db_project (2)/Stundets_Shared_covid_db_project/data/vaccination.csv'
DELIMITER ','
CSV HEADER;

COPY testing(
    testing_id,
    state_id,
    date,
    total_samples,
    positive_cases,
    negative_cases
)
FROM 'D:/Stundets_Shared_covid_db_project (2)/Stundets_Shared_covid_db_project/data/testing.csv'
DELIMITER ','
CSV HEADER;

CREATE TEMP TABLE testing_temp (
    testing_id TEXT,
    state_id TEXT,
    date TEXT,
    total_samples TEXT,
    positive_cases TEXT,
    negative_cases TEXT
);

COPY testing_temp
FROM 'D:/Stundets_Shared_covid_db_project (2)/Stundets_Shared_covid_db_project/data/testing.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO testing (
    testing_id,
    state_id,
    date,
    total_samples,
    positive_cases,
    negative_cases
)
SELECT
    testing_id::INT,
    state_id::INT,
    date::DATE,
    total_samples::NUMERIC::BIGINT,
    NULLIF(positive_cases, '')::NUMERIC::BIGINT,
    NULLIF(negative_cases, '')::NUMERIC::BIGINT
FROM testing_temp;

SELECT COUNT(*) FROM testing;

COPY global_covid_stats(
    global_stat_id,
    country_id,
    report_date,
    confirmed,
    deaths,
    recovered,
    new_confirmed,
    new_deaths,
    active_cases,
    people_vaccinated_1dose,
    people_fully_vaccinated
)
FROM 'D:/Stundets_Shared_covid_db_project (2)/Stundets_Shared_covid_db_project/data/global_covid_stats.csv'
DELIMITER ','
CSV HEADER;

-- 1. Count countries
SELECT COUNT(*) AS total_countries
FROM country;

-- 2. Count states
SELECT COUNT(*) AS total_states
FROM state;

-- 3. Count districts
SELECT COUNT(*) AS total_districts
FROM district;

-- 4. Count COVID case records
SELECT COUNT(*) AS total_case_records
FROM covid_case_stats;

-- 5. Count vaccination records
SELECT COUNT(*) AS total_vaccination_records
FROM vaccination;

-- 6. Count testing records
SELECT COUNT(*) AS total_testing_records
FROM testing;

-- 7. Count global records
SELECT COUNT(*) AS total_global_records
FROM global_covid_stats;
-- 1. Country with the highest confirmed cases on a specific date
SELECT c.name AS country, g.confirmed
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
WHERE g.report_date = '2021-09-30'
ORDER BY g.confirmed DESC LIMIT 1;

-- 2. Total deaths in each country on a specific date
SELECT c.name AS country, g.deaths
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
WHERE g.report_date = '2021-09-30'
ORDER BY g.deaths DESC;

-- 3. Total confirmed cases, deaths and recoveries by continent
SELECT c.continent, SUM(g.confirmed) AS total_confirmed,
       SUM(g.deaths) AS total_deaths, SUM(g.recovered) AS total_recovered
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.continent ORDER BY total_confirmed DESC;

-- 4. Average number of new deaths per day across all countries
SELECT AVG(new_deaths) AS average_new_deaths_per_day FROM global_covid_stats;

-- 5. Maximum active cases on a specific date
SELECT c.name AS country, g.active_cases
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
WHERE g.report_date = '2021-09-30'
ORDER BY g.active_cases DESC LIMIT 1;

-- 6. Stored procedure to return recovered cases for a country and date
CREATE OR REPLACE PROCEDURE get_recovered_cases(p_country_id INT, p_date DATE)
LANGUAGE plpgsql AS $$
BEGIN
    SELECT c.name AS country, g.report_date, g.recovered
    FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
    WHERE g.country_id = p_country_id AND g.report_date = p_date;
END;
$$

-- 7. Stored procedure to update deaths for a country and date
CREATE OR REPLACE PROCEDURE update_deaths(p_country_id INT, p_date DATE, p_deaths BIGINT)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE global_covid_stats SET deaths = p_deaths
    WHERE country_id = p_country_id AND report_date = p_date;
END;
$$;

-- 8. View for country cases
CREATE OR REPLACE VIEW country_cases_on_date AS
SELECT c.name AS country, g.report_date, g.confirmed, g.deaths, g.recovered
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id;

-- 9. View showing latest data for each country
CREATE OR REPLACE VIEW latest_country_data AS
SELECT c.name AS country, g.report_date, g.confirmed, g.deaths, g.recovered
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
WHERE g.report_date = (
    SELECT MAX(g2.report_date) FROM global_covid_stats g2
    WHERE g2.country_id = g.country_id
);

-- 10. Total cases for each country
SELECT c.name AS country,
       MAX(g.confirmed) + MAX(g.deaths) + MAX(g.recovered) AS total_cases
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.name ORDER BY total_cases DESC;

-- 11. Country with the highest new cases on a specific date
SELECT c.name AS country, g.new_confirmed
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
WHERE g.report_date = '2021-09-30'
ORDER BY g.new_confirmed DESC LIMIT 1;

-- 12. Percentage increase in confirmed cases over the past week
WITH dates AS (
    SELECT MAX(report_date) AS latest_date FROM global_covid_stats
),
weekly AS (
    SELECT g.country_id,
           MAX(g.confirmed) FILTER (WHERE g.report_date = d.latest_date) AS current_cases,
           MAX(g.confirmed) FILTER (WHERE g.report_date = d.latest_date - INTERVAL '7 days') AS previous_cases
    FROM global_covid_stats g CROSS JOIN dates d
    GROUP BY g.country_id
)
SELECT c.name AS country, current_cases, previous_cases,
       ROUND((current_cases - previous_cases) * 100.0 / NULLIF(previous_cases, 0), 2) AS percentage_increase
FROM weekly w JOIN country c ON w.country_id = c.country_id
ORDER BY percentage_increase DESC;

-- 13. Country with the highest active cases currently
WITH latest_date AS (SELECT MAX(report_date) AS report_date FROM global_covid_stats)
SELECT c.name AS country, g.active_cases
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
JOIN latest_date l ON g.report_date = l.report_date
ORDER BY g.active_cases DESC LIMIT 1;

-- 14. Index on country name
CREATE INDEX IF NOT EXISTS idx_country_name ON country(name);

-- 15. Mortality rate function
CREATE OR REPLACE FUNCTION mortality_rate(p_country_id INT)
RETURNS NUMERIC LANGUAGE plpgsql AS $$
DECLARE result NUMERIC;
BEGIN
    SELECT MAX(deaths) * 100.0 / NULLIF(MAX(confirmed), 0)
    INTO result FROM global_covid_stats WHERE country_id = p_country_id;
    RETURN COALESCE(result, 0);
END;
$$;

-- 16. Recovery rate function
CREATE OR REPLACE FUNCTION recovery_rate(p_country_id INT, p_date DATE)
RETURNS NUMERIC LANGUAGE plpgsql AS $$
DECLARE result NUMERIC;
BEGIN
    SELECT recovered * 100.0 / NULLIF(confirmed, 0)
    INTO result FROM global_covid_stats
    WHERE country_id = p_country_id AND report_date = p_date;
    RETURN COALESCE(result, 0);
END;
$$;

-- 17. Confirmed cases by continent
SELECT c.continent, SUM(g.confirmed) AS total_confirmed
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.continent ORDER BY total_confirmed DESC;

-- 18. Deaths and recoveries by date
SELECT report_date, SUM(deaths) AS total_deaths, SUM(recovered) AS total_recovered
FROM global_covid_stats GROUP BY report_date ORDER BY report_date;

-- 19. Average daily new cases by country
SELECT c.name AS country, AVG(g.new_confirmed) AS average_daily_new_cases
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.name ORDER BY average_daily_new_cases DESC;

-- 20. Local death percentage
SELECT c.name AS country,
       MAX(g.deaths) * 100.0 / NULLIF(MAX(g.confirmed), 0) AS death_percentage
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.name ORDER BY death_percentage DESC;

-- 21. Global death percentage
SELECT SUM(deaths) * 100.0 / NULLIF(SUM(confirmed), 0) AS global_death_percentage
FROM global_covid_stats;

-- 22. Local infected population percentage
SELECT c.name AS country,
       MAX(g.confirmed) * 100.0 / NULLIF(c.population, 0) AS infected_population_percentage
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.name, c.population ORDER BY infected_population_percentage DESC;

-- 23. Global infected population percentage
SELECT SUM(g.confirmed) * 100.0 / NULLIF(SUM(c.population), 0) AS global_infected_population_percentage
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id;

-- 24. Countries with the highest infection rates
SELECT c.name AS country,
       MAX(g.confirmed) * 100.0 / NULLIF(c.population, 0) AS infection_rate
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.name, c.population ORDER BY infection_rate DESC;

-- 25. Countries with the highest death counts
SELECT c.name AS country, MAX(g.deaths) AS total_deaths
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.name ORDER BY total_deaths DESC;

-- 26. Continents with the highest death counts
SELECT c.continent, SUM(g.deaths) AS total_deaths
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.continent ORDER BY total_deaths DESC;

-- 27. Average deaths by continent
SELECT c.continent, AVG(g.new_deaths) AS average_daily_deaths
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.continent ORDER BY average_daily_deaths DESC;

-- 28. Average deaths by country
SELECT c.name AS country, AVG(g.new_deaths) AS average_daily_deaths
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.name ORDER BY average_daily_deaths DESC;

-- 29. Top 10 countries by cases compared with population
SELECT c.name AS country, MAX(g.confirmed) AS total_cases, c.population,
       MAX(g.confirmed) * 100.0 / NULLIF(c.population, 0) AS cases_percentage
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.name, c.population
ORDER BY cases_percentage DESC LIMIT 10;

-- 30. Total vaccinated with at least one dose over time
SELECT report_date, SUM(people_vaccinated_1dose) AS total_vaccinated
FROM global_covid_stats GROUP BY report_date ORDER BY report_date;

-- 31. Top 3 countries by first-dose coverage until 30-09-2021
SELECT c.name AS country, MAX(g.people_vaccinated_1dose) AS vaccinated,
       c.population,
       MAX(g.people_vaccinated_1dose) * 100.0 / NULLIF(c.population, 0) AS vaccination_percentage
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
WHERE g.report_date <= '2021-09-30'
GROUP BY c.name, c.population
ORDER BY vaccination_percentage DESC LIMIT 3;

-- 32. Population versus vaccinated people
SELECT c.name AS country, c.population,
       MAX(g.people_vaccinated_1dose) AS vaccinated_first_dose,
       MAX(g.people_vaccinated_1dose) * 100.0 / NULLIF(c.population, 0) AS vaccinated_percentage
FROM global_covid_stats g JOIN country c ON g.country_id = c.country_id
GROUP BY c.name, c.population ORDER BY vaccinated_percentage DESC;

-- 33. Percentage of different vaccine brands
SELECT s.name AS state,
       SUM(v.covaxin) AS covaxin, SUM(v.covishield) AS covishield, SUM(v.sputnik_v) AS sputnik_v,
       SUM(v.covaxin) * 100.0 / NULLIF(SUM(v.covaxin + v.covishield + v.sputnik_v), 0) AS covaxin_percentage,
       SUM(v.covishield) * 100.0 / NULLIF(SUM(v.covaxin + v.covishield + v.sputnik_v), 0) AS covishield_percentage,
       SUM(v.sputnik_v) * 100.0 / NULLIF(SUM(v.covaxin + v.covishield + v.sputnik_v), 0) AS sputnik_percentage
FROM vaccination v JOIN state s ON v.state_id = s.state_id
GROUP BY s.name;

-- 34. Percentage of people who took both doses
SELECT s.name AS state, MAX(v.first_dose) AS first_dose, MAX(v.second_dose) AS second_dose,
       MAX(v.second_dose) * 100.0 / NULLIF(MAX(v.first_dose), 0) AS both_doses_percentage
FROM vaccination v JOIN state s ON v.state_id = s.state_id
GROUP BY s.name ORDER BY both_doses_percentage DESC;

-- 35. Total state-wise confirmed cases
SELECT s.name AS state, MAX(c.confirmed) AS total_confirmed
FROM covid_case_stats c JOIN state s ON c.state_id = s.state_id
GROUP BY s.name ORDER BY total_confirmed DESC;

-- 36. Maximum active cases state-wise till date
SELECT s.name AS state, MAX(c.active_cases) AS maximum_active_cases
FROM covid_case_stats c JOIN state s ON c.state_id = s.state_id
GROUP BY s.name ORDER BY maximum_active_cases DESC;

-- 37. Maximum per-day confirmed cases in states
SELECT s.name AS state, MAX(c.new_confirmed) AS max_per_day_confirmed
FROM covid_case_stats c JOIN state s ON c.state_id = s.state_id
GROUP BY s.name ORDER BY max_per_day_confirmed DESC;

-- 38. Maximum per-day death cases in states
SELECT s.name AS state, MAX(c.new_deaths) AS max_per_day_deaths
FROM covid_case_stats c JOIN state s ON c.state_id = s.state_id
GROUP BY s.name ORDER BY max_per_day_deaths DESC;

-- 39. State-wise mortality rate
SELECT s.name AS state,
       MAX(c.deaths) * 100.0 / NULLIF(MAX(c.confirmed), 0) AS mortality_rate
FROM covid_case_stats c JOIN state s ON c.state_id = s.state_id
GROUP BY s.name ORDER BY mortality_rate DESC;

-- 40. Mumbai COVID waves
SELECT c.report_date, c.confirmed, c.new_confirmed, c.deaths, c.new_deaths, c.active_cases
FROM covid_case_stats c JOIN district d ON c.district_id = d.district_id
WHERE d.name = 'Mumbai'
ORDER BY c.report_date;


-- 1. Tables check
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2. Row counts
SELECT 'country' AS table_name, COUNT(*) AS total_rows FROM country
UNION ALL
SELECT 'state', COUNT(*) FROM state
UNION ALL
SELECT 'district', COUNT(*) FROM district
UNION ALL
SELECT 'covid_case_stats', COUNT(*) FROM covid_case_stats
UNION ALL
SELECT 'vaccination', COUNT(*) FROM vaccination
UNION ALL
SELECT 'testing', COUNT(*) FROM testing
UNION ALL
SELECT 'global_covid_stats', COUNT(*) FROM global_covid_stats;

-- 3. Country data
SELECT * FROM country LIMIT 5;

-- 4. State data
SELECT * FROM state LIMIT 5;

-- 5. COVID case data
SELECT * FROM covid_case_stats LIMIT 5;

-- 6. Vaccination data
SELECT * FROM vaccination LIMIT 5;

-- 7. Testing data
SELECT * FROM testing LIMIT 5;

-- 8. Global COVID data
SELECT * FROM global_covid_stats LIMIT 5;

-- 9. View check
SELECT * FROM country_cases_on_date LIMIT 5;

SELECT * FROM latest_country_data LIMIT 5;

-- 10. Procedure check
CALL get_recovered_cases(1, '2021-09-30');

-- 11. Function check
SELECT mortality_rate(1);

SELECT recovery_rate(1, '2021-09-30');

-- 12. CTE check
WITH latest_data AS (
    SELECT
        country_id,
        MAX(report_date) AS latest_date
    FROM global_covid_stats
    GROUP BY country_id
)
SELECT *
FROM latest_data
ORDER BY country_id;

-- 13. Indexes check
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

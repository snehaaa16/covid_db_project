# COVID-19 Database Management System Project
### Complete Student Pack & Implementation Guide

This project folder contains all corrected, sanitized, and complete datasets, relational schemas, automated data-loading scripts, and query solutions needed to implement an end-to-end COVID-19 SQL analytical database.

---

## Folder Structure

```text
covid_db_project/
│
├── schema/
│   ├── CovidSchema_fixed.sql       # Production MySQL DDL with proper lengths, constraints & PK/FK
│   └── load_data.sql               # Automated LOAD DATA INFILE bulk insertion script
│
├── data/                           # Sanitized, canonicalized, deduplicated CSV datasets
│   ├── countries.csv               # 20 Countries dimension with continent and population
│   ├── states.csv                  # 36 Indian States/UTs with 2021 census projected population
│   ├── districts.csv               # District dimension (including Mumbai)
│   ├── covid_case_stats.csv        # 18,000+ daily state-level case facts (clean 24hr time & active cases)
│   ├── vaccination.csv             # Cleaned daily vaccination numbers + Covaxin/Covishield/Sputnik breakdown
│   ├── testing.csv                 # Cleaned testing sample metrics
│   ├── global_covid_stats.csv      # Global pandemic records for continental/country queries
│   └── mumbai_case_stats.csv       # Dedicated district-level records for "Mumbai Covid Waves"
│
├── queries_and_solutions/
│   └── solutions.sql               # Complete SQL solutions for all 20+ assigned use cases
│
└── docs/
    └── Project_Overview_and_Setup.md
```

---

## Quick Setup Instructions for Students

### Step 1: Clone or Copy to Drive
Copy this `covid_db_project` folder to your local drive (e.g. `D:\covid_db_project`).

### Step 2: Create the Database & Schema
Open MySQL Workbench, DBeaver, or command line and run:
```sql
SOURCE D:/covid_db_project/schema/CovidSchema_fixed.sql;
```

### Step 3: Enable Local Infile and Load Data
Ensure MySQL allows local infile loading:
```sql
SET GLOBAL local_infile = 1;
```
Then execute:
```sql
SOURCE D:/covid_db_project/schema/load_data.sql;
```
*(Or import using the GUI Import Wizard in MySQL Workbench for each CSV in the `data/` folder).*

### Step 4: Run & Verify Queries
Open `queries_and_solutions/solutions.sql` and execute the queries covering:
- Continental & Global aggregates
- State-wise Mortality Rates and Daily Peak analyses
- Vaccine Brand Distribution & Population Coverage
- Stored Procedures, Views, and User Defined Functions (UDFs)

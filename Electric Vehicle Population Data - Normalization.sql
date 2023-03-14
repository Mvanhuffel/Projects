--Staging table used to import csv file
CREATE TABLE ev (
  id SERIAL PRIMARY KEY,
  vin TEXT NOT NULL,
  county VARCHAR(55) NOT NULL,
  city VARCHAR(55) NOT NULL,
  state VARCHAR(55) NOT NULL,
  postal_code VARCHAR(10) NOT NULL,
  model_year INT NOT NULL,
  make VARCHAR(25) NOT NULL,
  model TEXT NOT NULL,
  electric_vehicle_type VARCHAR(10) NOT NULL CHECK (electric_vehicle_type IN ('BEV', 'PHEV')),
  cafv_eligibility VARCHAR(255),
  electric_range INT,
  base_msrp INT,
  legislative_district INT,
  vehicle_id INT,
  vehicle_location TEXT,
  electric_utility TEXT,
  census_tract TEXT
);

--Normalized tables:

--County table
CREATE TABLE county  (
  id SERIAL PRIMARY KEY, 
  name VARCHAR(55) UNIQUE NOT NULL
);
--Make table
CREATE TABLE make  (
  id SERIAL PRIMARY KEY, 
  name VARCHAR(25) UNIQUE NOT NULL
);
--Model table
CREATE TABLE model (
  id SERIAL PRIMARY KEY, 
  name VARCHAR(55) UNIQUE NOT NULL
);

--Electric vehicle type table
CREATE TABLE electric_vehicle_type (
  id SERIAL PRIMARY KEY,
  type VARCHAR(10) NOT NULL CHECK (type IN ('BEV', 'PHEV'))
);

--Vehicle table
CREATE TABLE vehicle (
  id SERIAL PRIMARY KEY, 
  vin TEXT NOT NULL, 
  county_id INT NOT NULL REFERENCES county(id), 
  city VARCHAR(55) NOT NULL, 
  state VARCHAR(55) NOT NULL, 
  postal_code CHAR(5) NOT NULL, 
  model_year INT NOT NULL, 
  make_id INT NOT NULL REFERENCES make(id), 
  model_id INT NOT NULL REFERENCES model(id), 
  electric_range INT NOT NULL, 
  base_msrp NUMERIC(10, 2) NOT NULL, 
  legislative_district INT NOT NULL, 
  vehicle_id INT NOT NULL, 
  vehicle_location TEXT NOT NULL, 
  electric_utility TEXT NOT NULL, 
  census_tract TEXT NOT NULL, 
  electric_vehicle_type_id INT NOT NULL REFERENCES electric_vehicle_type (id), 
  cafv_eligibility VARCHAR(255) NOT NULL
);

-- Insert statements for county table
INSERT INTO county (name)
SELECT DISTINCT county FROM ev;

-- Insert statements for make table
INSERT INTO make (name)
SELECT DISTINCT make FROM ev;

-- Insert statements for model table
INSERT INTO model (name)
SELECT DISTINCT model FROM ev;

-- Insert statements for electricVehicleType table
INSERT INTO electric_vehicle_type (type)
VALUES ('BEV'), ('PHEV');

-- Insert statements for vehicle table
INSERT INTO vehicle (vin, county_id, city, state, postal_code, model_year, make_id, model_id, electric_range, base_msrp, legislative_district, vehicle_id, vehicle_location, electric_utility, census_tract, electric_vehicle_type_id, cafv_eligibility)
SELECT ev.vin, county.id, ev.city, ev.state, ev.postal_code, ev.model_year, make.id, model.id, ev.electric_range, ev.base_msrp, 
       CASE WHEN ev.legislative_district IS NULL THEN 0 ELSE ev.legislative_district END, ev.vehicle_id, ev.vehicle_location, ev.electric_utility, ev.census_tract, electric_vehicle_type.id, ev.cafv_eligibility
FROM ev
INNER JOIN county ON ev.county = county.name
INNER JOIN make ON ev.make = make.name
INNER JOIN model ON ev.model = model.name
INNER JOIN electric_vehicle_type ON ev.electric_vehicle_type = electric_vehicle_type.type;

--Analysis:

--Top 10 Avg mileage
SELECT make.name AS make, model.name AS model, electric_vehicle_type.type AS electric_vehicle_type, AVG(vehicle.electric_range) AS avg_electric_range
FROM vehicle
INNER JOIN make ON vehicle.make_id = make.id
INNER JOIN model ON vehicle.model_id = model.id
INNER JOIN electric_vehicle_type ON vehicle.electric_vehicle_type_id = electric_vehicle_type.id
GROUP BY make.name, model.name, electric_vehicle_type.type
ORDER BY avg_electric_range DESC
LIMIT 10;

--Top 10 Count
select count(distinct vehicle.vin), county.name
from vehicle
inner join county on vehicle.county_id = county.id
group by county.name
order by count(distinct vehicle.vin) desc
limit 10;

--Top 5 models electric range
SELECT make.name, model.name, vehicle.electric_range
FROM vehicle
INNER JOIN make ON vehicle.make_id = make.id
INNER JOIN model ON vehicle.model_id = model.id
WHERE vehicle.electric_vehicle_type_id = 1 -- assuming electric_vehicle_type_id 1 represents BEV
ORDER BY vehicle.electric_range DESC
LIMIT 5;

--Count of electric vehicles by county and legislative district
SELECT county.name, vehicle.legislative_district, COUNT(*)
FROM vehicle
INNER JOIN county ON vehicle.county_id = county.id
GROUP BY county.name, vehicle.legislative_district;

-- Top 10 most popular vehicle makes and models, based on the number of vehicles sold
SELECT make.name AS make, model.name AS model, COUNT(vehicle.id) AS num_vehicles_sold
FROM vehicle
INNER JOIN make ON vehicle.make_id = make.id
INNER JOIN model ON vehicle.model_id = model.id
GROUP BY make.name, model.name
ORDER BY num_vehicles_sold DESC
LIMIT 10;
--


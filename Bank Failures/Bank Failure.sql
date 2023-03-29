--STAGING
create table failedbank (
id serial, 
bank_name text, 
closing_date date,
city text, 
state varchar(2),
acquiring_institution text,
asset int,
deposit int,
primary key(id)
);

truncate table failedbank;
select * from failedbank;

--QUERIES

--total assets by year
SELECT EXTRACT(YEAR FROM closing_date) AS year, SUM(asset) AS total_assets
FROM failedbank
GROUP BY year
order by year asc;

--top 10 banks by largest assets
SELECT bank_name, SUM(asset) AS total_assets
FROM failedbank 
GROUP BY bank_name 
ORDER BY total_assets DESC 
LIMIT 5;

--total assets
select sum(asset) from failedbank;

--top 10 banks by largest assets with year
SELECT bank_name, EXTRACT(YEAR FROM closing_date) AS year, asset
FROM failedbank
WHERE closing_date BETWEEN '2001-01-01' AND '2023-12-31'
ORDER BY asset DESC
LIMIT 10;
 
--number of banks failed by year
SELECT EXTRACT(YEAR FROM closing_date) AS year, COUNT(*) AS num_failed_banks
FROM failedbank
GROUP BY year
order by year asc;

--top 10 acquiring institutions by number of failed banks
SELECT acquiring_institution, COUNT(*) AS num_failed_banks
FROM failedbank
WHERE acquiring_institution IS NOT NULL
GROUP BY acquiring_institution
ORDER BY num_failed_banks DESC
LIMIT 11;

--total deposits by year
SELECT EXTRACT(YEAR FROM closing_date) AS year, SUM(deposit) AS total_deposits
FROM failedbank
GROUP BY year;

--number of failed banks for each state
SELECT state, COUNT(bank_name) AS num_failed_banks
FROM failedbank
GROUP BY state
order by num_failed_banks desc;



--top 10 cities with the most failed banks
SELECT city, COUNT(*) AS num_failed_banks
FROM failedbank
GROUP BY city
ORDER BY num_failed_banks DESC
LIMIT 10;

--failed banks by year and state
SELECT EXTRACT(YEAR FROM closing_date) AS year, state, COUNT(*) AS num_failed_banks
FROM failedbank
GROUP BY year, state
order by year asc;

--select bank_name, acquiring_institution, SUM(asset) AS total_assets_acquired
FROM failedbank
WHERE acquiring_institution IS NOT NULL
GROUP BY acquiring_institution, bank_name 
ORDER BY total_assets_acquired DESC
LIMIT 10;

--smallest bank failure
SELECT bank_name, asset, EXTRACT(YEAR FROM closing_date) AS year
FROM failedbank
ORDER BY asset ASC
LIMIT 1;









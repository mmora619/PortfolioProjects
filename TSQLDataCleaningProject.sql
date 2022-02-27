/*

Some Quick Data Cleaning in SQL Queries 

*/

SELECT *
FROM DataCleaningProject.dbo.train$

-----------------------------------------------------------

-- Change Table Name

EXEC sp_RENAME 'DataCleaningProject.dbo.train$' , 'PropertyMaintenanceBlightTicketCompliance';

------------------------------------------------------------

-- Change Column Names 

SELECT *
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance

EXEC sp_RENAME 'PropertyMaintenanceBlightTicketCompliance.mailing_address_str_number', 'mailing_address_street_number', 'COLUMN';

EXEC sp_RENAME 'PropertyMaintenanceBlightTicketCompliance.mailing_address_str_name', 'mailing_address_street_name', 'COLUMN';

EXEC sp_RENAME 'PropertyMaintenanceBlightTicketCompliance.non_us_str_code', 'non_us_street_code', 'COLUMN';

----------------------------------------------------------

/*

Alter Column to convert data type from numeric into varchar and then 
Change compliance column values: 
	1 = responsible, compliant
	0 = responsible, non-compliant
	NULL = not responsible 

*/

SELECT *
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance;

EXEC sp_help 'PropertyMaintenanceBlightTicketCompliance';

ALTER TABLE PropertyMaintenanceBlightTicketCompliance
ALTER COLUMN compliance VARCHAR(50);

SELECT compliance
, CASE WHEN compliance = '1' THEN 'responsible, compliant'
	   WHEN compliance = '0' THEN 'responsible, non-compliant'
	   WHEN compliance IS NULL THEN 'not responsible'
	   ELSE compliance
	   END
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance;

UPDATE PropertyMaintenanceBlightTicketCompliance
SET compliance = CASE WHEN compliance = '1' THEN 'responsible, compliant'
	   WHEN compliance = '0' THEN 'responsible, non-compliant'
	   WHEN compliance IS NULL THEN 'not responsible'
	   ELSE compliance
	   END
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance;

-----------------------------------------------------------

-- Standardize Date Format
-- Change the payment_date column to match the date format of the ticket_issued_date and hearing_date columns

SELECT *
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance;

EXEC sp_help 'PropertyMaintenanceBlightTicketCompliance';

ALTER TABLE PropertyMaintenanceBlightTicketCompliance
ALTER COLUMN payment_date DATETIME;

----------------------------------------------------------- 

-- Standardize city Column Values

SELECT *
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance;

SELECT city, COUNT(city)
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
GROUP BY city;

SELECT city, UPPER(city)
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
GROUP BY city;

UPDATE PropertyMaintenanceBlightTicketCompliance
SET city = UPPER(city);

----------------------------------------------------------- 

--  Break out the location column into individual columns: (city, state, country)

SELECT *
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance;

SELECT 
  SUBSTRING(location, 1, CHARINDEX(',', location) -1) AS city
, SUBSTRING(location, 9, 3) AS state
, REVERSE(SUBSTRING(REVERSE(location),1,CHARINDEX(',',REVERSE(location)) -1)) AS country
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance;

ALTER TABLE DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
ADD city VARCHAR(50);

UPDATE DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
SET city = SUBSTRING(location, 1, CHARINDEX(',', location) -1);

ALTER TABLE DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
ADD state VARCHAR(50);

UPDATE DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
SET state = SUBSTRING(location, 9, 3);

ALTER TABLE DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
ADD country VARCHAR(50);

UPDATE DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
SET country = REVERSE(SUBSTRING(REVERSE(location),1,CHARINDEX(',',REVERSE(location)) -1));

-----------------------------------------------------------

-- Combine two columns (violation_street_name, violation_street_number) into one column

SELECT *
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance;


SELECT CONCAT(a.violation_street_number, ', ', a.violation_street_name)
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance a
JOIN DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance b
	ON a.violation_street_number = b.violation_street_number
	AND a.violation_street_name = b.violation_street_name;

ALTER TABLE DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
ADD violation_street_number_and_name VARCHAR(50);

UPDATE a
SET a.violation_street_number_and_name = 
CONCAT(a.violation_street_number, ', ', a.violation_street_name)
From DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance a
JOIN DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance b
	ON a.violation_street_number = b.violation_street_number
	AND a.violation_street_name = b.violation_street_name;

SELECT *
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance;
-----------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance;

ALTER TABLE DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
DROP COLUMN location; 

ALTER TABLE DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
DROP COLUMN violation_street_name;

ALTER TABLE DataCleaningProject.dbo.PropertyMaintenanceBlightTicketCompliance
DROP COLUMN violation_street_number;  


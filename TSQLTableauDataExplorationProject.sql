/*

Some Quick Data Cleaning in SQL Queries

*/

SELECT *
FROM DataExplorationProject.dbo.SalesDataA


SELECT *
FROM DataExplorationProject.dbo.SalesDataB

-----------------------------------------------------------

-- Standardize Date Format

SELECT ORDERDATE, CONVERT(DATE, ORDERDATE)
FROM DataExplorationProject.dbo.SalesDataA;

ALTER TABLE DataExplorationProject.dbo.SalesDataA
ADD ORDERDATEConverted DATE;

Update DataExplorationProject.dbo.SalesDataA
SET ORDERDATEConverted = CONVERT(Date,ORDERDATE)

-----------------------------------------------------------

-- Delete Unused Column

ALTER TABLE DataExplorationProject.dbo.SalesDataA
DROP COLUMN ORDERDATE

-----------------------------------------------------------

-- Change Column Name

EXEC sp_RENAME 'SalesDataA.ORDERDATEConverted', 'ORDERDATE', 'COLUMN'

--------------------------------------------------------------------------------------------------------------------------
/*

Sales Data Exploration 

Skills used: Subqueries, Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views

*/

SELECT *
FROM DataExplorationProject.dbo.SalesDataA

SELECT *
FROM DataExplorationProject.dbo.SalesDataB

-----------------------------------------------------------

-- Sales by Year, Month
-- What has been Company A and Company B's sales by month? 

SELECT YEAR_ID, MONTH_ID, SALES
FROM DataExplorationProject.dbo.SalesDataA
ORDER BY 1, 2, 3

SELECT orderdate_year, orderdate_month, sales
FROM DataExplorationProject.dbo.SalesDataB
ORDER BY 1, 2, 3

--I then use a couple of joins to combine the data into one results table and finish the calculation

SELECT A.YEAR_ID AS Year, A.MONTH_ID AS Month
, SUM(DISTINCT A.SALES) AS SalesCompanyA
, SUM(DISTINCT b.sales) AS SalesCompanyB
FROM DataExplorationProject.dbo.SalesDataA AS A
INNER JOIN DataExplorationProject.dbo.SalesDataB AS B
ON A.YEAR_ID = B.orderdate_year
AND A.MONTH_ID = B.orderdate_month
GROUP BY  A.YEAR_ID, A.MONTH_ID
ORDER BY YEAR_ID, MONTH_ID

-----------------------------------------------------------

-- Growth Rate of Sales by Year
-- What is Company A's 2013-2015 sales growth rate compared to Company B's?


SELECT SUM(A.Sales) AS CompanyA2013Sales
FROM DataExplorationProject.dbo.SalesDataA A
WHERE Year_ID = 2013

SELECT SUM(A.Sales) AS CompanyA2014Sales
FROM DataExplorationProject.dbo.SalesDataA A
WHERE Year_ID = 2014

SELECT SUM(A.Sales) AS CompanyA2015Sales
FROM DataExplorationProject.dbo.SalesDataA A
WHERE Year_ID = 2015

SELECT SUM(B.sales) AS CompanyB2013Sales
FROM DataExplorationProject.dbo.SalesDataB B
WHERE orderdate_year = 2013

SELECT SUM(B.sales) AS CompanyB2014Sales
FROM DataExplorationProject.dbo.SalesDataB B
WHERE orderdate_year = 2014

SELECT SUM(B.sales) AS CompanyB2015Sales
FROM DataExplorationProject.dbo.SalesDataB B
WHERE orderdate_year = 2015

-- I use a temp table to reorganize all of the data from the above queries. 

DROP TABLE IF EXISTS temp_CompanySalesGrowth;

CREATE TABLE temp_CompanySalesGrowth
(
  Year INT
, SumSalesCompanyA DECIMAL (18,2)
, SumSalesCompanyB DECIMAL (18,2)
)

INSERT INTO temp_CompanySalesGrowth
VALUES ('2013', '3516979.54', '484247.498099999')

INSERT INTO temp_CompanySalesGrowth
VALUES ('2014', '4724162.6', '470532.508999999')

INSERT INTO  temp_CompanySalesGrowth
VALUES ('2015', '1791486.71', '608473.830000001')

SELECT *
FROM  temp_CompanySalesGrowth;


-- I then perform the growth rate calculations using CTE's and comparison operators

WITH CTE_GrowthRate AS
   (SELECT
   (SELECT SumSalesCompanyA FROM temp_CompanySalesGrowth WHERE Year = 2014)
 - (SELECT SumSalesCompanyA FROM temp_CompanySalesGrowth WHERE Year = 2013) AS difference
 FROM temp_CompanySalesGrowth)
 SELECT TOP 1 difference
 /(SELECT SumSalesCompanyA FROM temp_CompanySalesGrowth WHERE Year = 2013)
 *100 AS 'A2014GrowthRate'
 FROM CTE_GrowthRate;

WITH CTE_GrowthRate AS
   (SELECT
   (SELECT SumSalesCompanyA FROM temp_CompanySalesGrowth WHERE Year = 2015)
 - (SELECT SumSalesCompanyA FROM temp_CompanySalesGrowth WHERE Year = 2014) AS difference
 FROM temp_CompanySalesGrowth)
 SELECT TOP 1 difference
 /(SELECT SumSalesCompanyA FROM temp_CompanySalesGrowth WHERE Year = 2014)
 *100 AS 'A2015GrowthRate'
 FROM CTE_GrowthRate;

 WITH CTE_GrowthRate AS
   (SELECT
   (SELECT SumSalesCompanyB FROM temp_CompanySalesGrowth WHERE Year = 2014)
 - (SELECT SumSalesCompanyB FROM temp_CompanySalesGrowth WHERE Year = 2013) AS difference
 FROM temp_CompanySalesGrowth)
 SELECT TOP 1 difference
 /(SELECT SumSalesCompanyB FROM temp_CompanySalesGrowth WHERE Year = 2013)
 *100 AS 'B2014GrowthRate'
 FROM CTE_GrowthRate;

 WITH CTE_GrowthRate AS
   (SELECT
   (SELECT SumSalesCompanyB FROM temp_CompanySalesGrowth WHERE Year = 2015)
 - (SELECT SumSalesCompanyB FROM temp_CompanySalesGrowth WHERE Year = 2014) AS difference
 FROM temp_CompanySalesGrowth)
 SELECT TOP 1 difference
 /(SELECT SumSalesCompanyB FROM temp_CompanySalesGrowth WHERE Year = 2014)
 *100 AS 'B2015GrowthRate'
 FROM CTE_GrowthRate;

 -- I put the new data into the redone version of the temp table

DROP TABLE IF EXISTS temp_CompanySalesGrowth;

CREATE TABLE temp_CompanySalesGrowth
(
  Year INT
, SumSalesCompanyA DECIMAL (18,2)
, CompanyAGrowthRate DECIMAL (6,2)
, SumSalesCompanyB DECIMAL (18,2)
, CompanyBGrowthRate DECIMAL (6,2)
)

INSERT INTO temp_CompanySalesGrowth
VALUES ('2013', '3516979.54', '0', '484247.498099999','0')

INSERT INTO temp_CompanySalesGrowth
VALUES ('2014', '4724162.6', '34.324420383397119', '470532.508999999', '-2.832025805012731')

INSERT INTO  temp_CompanySalesGrowth
VALUES ('2015', '1791486.71', '-62.078213643348039', '608473.830000001', '29.315903454167933')

SELECT *
FROM  temp_CompanySalesGrowth

-----------------------------------------------------------

-- Growth Rate of Sales by Year and Month
-- What is Company A's 2013-2015 sales growth rate compared to Company B's by month?


SELECT *
FROM DataExplorationProject.dbo.SalesDataA AS A

SELECT *
FROM DataExplorationProject.dbo.SalesDataB AS B

SELECT A.YEAR_ID, A.MONTH_ID
, A.SALES AS SalesCompanyA
, B.sales AS SalesCompanyB
FROM DataExplorationProject.dbo.SalesDataA AS A
INNER JOIN DataExplorationProject.dbo.SalesDataB AS B
ON A.YEAR_ID = B.orderdate_year
AND A.MONTH_ID = B.orderdate_month
ORDER BY B.SALES

-- I use a couple of temp tables to reorganize the data into something I can better explore

DROP TABLE IF EXISTS temp_MonthlyCompanySalesGrowth;

CREATE TABLE temp_MonthlyCompanySalesGrowth
(
  Year INT
, Month INT 
, SalesCompanyA DECIMAL(18,2)
, SalesCompanyB DECIMAL(18,2)
)

INSERT INTO temp_MonthlyCompanySalesGrowth
SELECT A.YEAR_ID, A.MONTH_ID
, A.SALES AS SalesCompanyA
, B.sales AS SalesCompanyB
FROM DataExplorationProject.dbo.SalesDataA AS A
INNER JOIN DataExplorationProject.dbo.SalesDataB AS B
ON A.YEAR_ID = B.orderdate_year
AND A.MONTH_ID = B.orderdate_month

SELECT *
FROM temp_MonthlyCompanySalesGrowth

SELECT DISTINCT Year, Month
, SUM(DISTINCT SalesCompanyA) AS SalesByMonthCompanyA
, SUM(DISTINCT SalesCompanyB) AS SalesByMonthCompanyB
FROM temp_MonthlyCompanySalesGrowth
GROUP BY Year, Month
ORDER BY Year, Month

DROP TABLE IF EXISTS temp_MonthlyCompanySalesGrowth1;

CREATE TABLE temp_MonthlyCompanySalesGrowth1
(
  Year INT
, Month INT 
, SalesByMonthCompanyA DECIMAL(18,2)
, SalesByMonthCompanyB DECIMAL(18,2)
)

INSERT INTO temp_MonthlyCompanySalesGrowth1

SELECT DISTINCT Year, Month
, SUM(DISTINCT SalesCompanyA) AS SalesByMonthCompanyA
, SUM(DISTINCT SalesCompanyB) AS SalesByMonthCompanyB
FROM temp_MonthlyCompanySalesGrowth
GROUP BY Year, Month
ORDER BY Year, Month

SELECT *
FROM temp_MonthlyCompanySalesGrowth1
ORDER BY Year, Month

-- I then use the LAG statement with a couple comparison operators to find the monthly sales growth and the monthly sales percentage growth of both companies A and B. 

SELECT Year
, Month
, SalesByMonthCompanyA
, SalesByMonthCompanyA - LAG(SalesByMonthCompanyA) OVER(ORDER BY Year, Month) AS CompanyAMonthlySalesGrowth
, (SalesByMonthCompanyA - LAG(SalesByMonthCompanyA) OVER(ORDER BY Year, Month)) / LAG(SalesByMonthCompanyA) OVER(ORDER BY Year, Month)*100 AS CompanyAMonthlySalesPercentageGrowth
, SalesByMonthCompanyB
, SalesByMonthCompanyB - LAG(SalesByMonthCompanyB) OVER(ORDER BY Year, Month) AS CompanyBMonthlySalesGrowth
, (SalesByMonthCompanyB - LAG(SalesByMonthCompanyB) OVER(ORDER BY Year, Month)) / LAG(SalesByMonthCompanyB) OVER(ORDER BY Year, Month)*100 AS CompanyBMonthlySalesPercentageGrowth
FROM temp_MonthlyCompanySalesGrowth1
ORDER BY 1, 2

-- I finish with projecting future sales using the LEAD statement to project future monthly sales growth. 

SELECT Year
, Month
, SalesByMonthCompanyA
, SalesByMonthCompanyA - LAG(SalesByMonthCompanyA) OVER(ORDER BY Year, Month) AS CompanyAMonthlySalesGrowth
, (SalesByMonthCompanyA - LAG(SalesByMonthCompanyA) OVER(ORDER BY Year, Month)) / LAG(SalesByMonthCompanyA) OVER(ORDER BY Year, Month)*100 AS CompanyAMonthlySalesPercentageGrowth
, LEAD(SalesByMonthCompanyA, 12) OVER(ORDER BY Year, Month) AS ProjectedCompanyAMonthlySalesGrowth
, SalesByMonthCompanyB
, SalesByMonthCompanyB - LAG(SalesByMonthCompanyB) OVER(ORDER BY Year, Month) AS CompanyBMonthlySalesGrowth
, (SalesByMonthCompanyB - LAG(SalesByMonthCompanyB) OVER(ORDER BY Year, Month)) / LAG(SalesByMonthCompanyB) OVER(ORDER BY Year, Month)*100 AS CompanyBMonthlySalesPercentageGrowth
, LEAD(SalesByMonthCompanyB, 12) OVER(ORDER BY Year, Month) AS ProjectedCompanyBMonthlySalesGrowth
FROM temp_MonthlyCompanySalesGrowth1
ORDER BY 1, 2

-----------------------------------------------------------

-- Which customer bought the most amount of sales in a single purchase? What year did this sale occur?

SELECT *
FROM DataExplorationProject.dbo.SalesDataA AS A

SELECT *
FROM DataExplorationProject.dbo.SalesDataB AS B

-- I first find the largest sale to occur for Company A

SELECT MAX(A.SALES)
FROM DataExplorationProject.dbo.SalesDataA AS A

-- I then use a subquery to figure out the customer name and year of the sale

SELECT DISTINCT A.YEAR_ID AS Year
, A.CUSTOMERNAME AS Customer
FROM DataExplorationProject.dbo.SalesDataA AS A
WHERE A.SALES IN
(
	SELECT A.SALES
	FROM DataExplorationProject.dbo.SalesDataA AS A
	WHERE SALES = 14082.8
)

-----------------------------------------------------------

-- Sales by Product Sold
-- What is Company A's total number of sales compared to Company B's by product?

SELECT *
FROM DataExplorationProject.dbo.SalesDataA AS A

SELECT *
FROM DataExplorationProject.dbo.SalesDataB AS B

-- I insert a join into a temp table to better explore the data

SELECT A.PRODUCTLINE AS Product
, A.SALES AS SalesCompanyA
, B.sales AS SalesCompanyB
FROM DataExplorationProject.dbo.SalesDataA AS A
INNER JOIN DataExplorationProject.dbo.SalesDataB AS B
ON A.PRODUCTLINE = B.subcategory;

DROP TABLE IF EXISTS temp_SalesByProduct

CREATE TABLE temp_SalesByProduct
(

 Product VARCHAR(50)
, SalesCompanyA DECIMAL(18,2)
, SalesCompanyB DECIMAL(18,2)

)

INSERT INTO temp_SalesByProduct
SELECT A.PRODUCTLINE AS Product
, A.SALES AS SalesCompanyA
, B.sales AS SalesCompanyB
FROM DataExplorationProject.dbo.SalesDataA AS A
INNER JOIN DataExplorationProject.dbo.SalesDataB AS B
ON A.PRODUCTLINE = B.subcategory

SELECT *
FROM temp_SalesByProduct;

-- I use some aggregate functions, group by and order by to find what I'm looking for

SELECT Product
, SUM(DISTINCT SalesCompanyA) AS SumSalesCompanyA
, SUM(DISTINCT SalesCompanyB) AS SumSalesCompanyB
FROM temp_SalesByProduct
GROUP BY Product
ORDER BY 2 DESC, 3 

-----------------------------------------------------------

-- Sales by Country
-- What is Company A's total number of sales by country? How does each country compare to another by percentage of sales?
-- I start by using a windowed function to to find the Sum of Company A's total sales by country

SELECT *
FROM DataExplorationProject.dbo.SalesDataA AS A

SELECT DISTINCT A.COUNTRY AS Country
, SUM(A.SALES) OVER(PARTITION BY COUNTRY) AS Sales
FROM DataExplorationProject.dbo.SalesDataA AS A	
ORDER BY 2 DESC


-- I then use a temp table to visualize each country's share of their percentage of Company A's total sales

DROP TABLE IF EXISTS temp_SalesByCountry;

CREATE TABLE temp_SalesByCountry
(

 Country VARCHAR(50)
, Sales DECIMAL(18,2)

)

INSERT INTO temp_SalesByCountry

SELECT A.COUNTRY AS Country
, SUM(A.SALES) AS Sales
FROM DataExplorationProject.dbo.SalesDataA AS A	
GROUP BY A.COUNTRY
ORDER BY 2 DESC

SELECT *
FROM temp_SalesByCountry;

SELECT *
, Sales *100/
	(
	SELECT SUM(Sales) 
	FROM temp_SalesByCountry
	) AS PercentageSalesByCountry
FROM temp_SalesByCountry
ORDER BY 2 DESC


-----------------------------------------------------------

-- Sales by US State
-- What is Company A versus Company B's total number of sales by US State? How does each US State within both companies compare to another by percentage of sales?

SELECT *
FROM DataExplorationProject.dbo.SalesDataA AS A

SELECT *
FROM DataExplorationProject.dbo.SalesDataB AS B

-- First, I need to see which US States both companies sell to

SELECT A.STATE, COUNT(A.STATE)
FROM DataExplorationProject.dbo.SalesDataA AS A
WHERE COUNTRY = 'USA'
GROUP BY A.STATE
ORDER BY 2 DESC

SELECT B.state, COUNT(B.state)
FROM DataExplorationProject.dbo.SalesDataB AS B
GROUP BY B.state
ORDER BY 2 DESC;

-- I use a temp table to further explore the data

DROP TABLE IF EXISTS temp_SalesByState;

CREATE TABLE temp_SalesByState
(

 State VARCHAR(50)
, SalesCompanyA DECIMAL(18,2)
)

INSERT INTO temp_SalesByState
SELECT A.STATE AS State
, A.SALES AS SalesCompanyA
FROM DataExplorationProject.dbo.SalesDataA AS A
WHERE COUNTRY = 'USA'

SELECT *
FROM temp_SalesByState;

ALTER TABLE temp_SalesByState
ADD SalesCompanyB DECIMAL(18,2);

INSERT INTO temp_SalesByState (State, SalesCompanyB)
SELECT B.state AS State
, B.sales AS SalesCompanyB
FROM DataExplorationProject.dbo.SalesDataB AS B

SELECT *
FROM temp_SalesByState;

SELECT DISTINCT State
, SUM(DISTINCT SalesCompanyA) AS SalesCompanyA
, SUM(DISTINCT SalesCompanyB) AS SalesCompanyB
FROM temp_SalesByState
GROUP BY State
ORDER BY 1;

--I create another couple of temp tables to visualize how both companies compare to another by percentage of sales

DROP TABLE IF EXISTS temp_SalesByState1;

CREATE TABLE temp_SalesByState1
(

 State VARCHAR(50)
, SalesCompanyA DECIMAL(18,2)
, SalesCompanyB DECIMAL(18,2)
)

INSERT INTO temp_SalesByState1

SELECT DISTINCT State
, SUM(DISTINCT SalesCompanyA) AS SalesCompanyA
, SUM(DISTINCT SalesCompanyB) AS SalesCompanyB
FROM temp_SalesByState
GROUP BY State
ORDER BY 1;

SELECT *
FROM temp_SalesByState1;

SELECT *
, SalesCompanyA *100/
	(
	SELECT SUM(DISTINCT SalesCompanyA) 
	FROM temp_SalesByState1
	) AS PercentageSalesByStateCompanyA
FROM temp_SalesByState1
ORDER BY 2 DESC;

SELECT State
, SalesCompanyA
, SalesCompanyA *100/
	(
	SELECT SUM(DISTINCT SalesCompanyA) 
	FROM temp_SalesByState1
	) AS PercentageSalesByStateCompanyA
, SalesCompanyB
FROM temp_SalesByState1;

DROP TABLE IF EXISTS temp_SalesByState2;

CREATE TABLE temp_SalesByState2
(

 State VARCHAR(50)
, SalesCompanyA DECIMAL(18,2)
, PercentageSalesByStateCompanyA DECIMAL(18,2)
, SalesCompanyB DECIMAL(18,2)
)

INSERT INTO temp_SalesByState2
SELECT *
, SalesCompanyA *100/
	(
	SELECT SUM(DISTINCT SalesCompanyA) 
	FROM temp_SalesByState1
	) AS PercentageSalesByStateCompanyA
FROM temp_SalesByState1
ORDER BY 2 DESC;

SELECT *
FROM temp_SalesByState2;

SELECT *
, SalesCompanyB *100/
	(
	SELECT SUM(DISTINCT SalesCompanyB) 
	FROM temp_SalesByState2
	) AS PercentageSalesByStateCompanyB
FROM temp_SalesByState2
ORDER BY 1 ASC;

-----------------------------------------------------------

-- Create a view to store data for later visualizations

SELECT Year
, Month
, SalesByMonthCompanyA
, SalesByMonthCompanyA - LAG(SalesByMonthCompanyA) OVER(ORDER BY Year, Month) AS CompanyAMonthlySalesGrowth
, (SalesByMonthCompanyA - LAG(SalesByMonthCompanyA) OVER(ORDER BY Year, Month)) / LAG(SalesByMonthCompanyA) OVER(ORDER BY Year, Month)*100 AS CompanyAMonthlySalesPercentageGrowth
, LEAD(SalesByMonthCompanyA, 12) OVER(ORDER BY Year, Month) AS ProjectedCompanyAMonthlySalesGrowth
, SalesByMonthCompanyB
, SalesByMonthCompanyB - LAG(SalesByMonthCompanyB) OVER(ORDER BY Year, Month) AS CompanyBMonthlySalesGrowth
, (SalesByMonthCompanyB - LAG(SalesByMonthCompanyB) OVER(ORDER BY Year, Month)) / LAG(SalesByMonthCompanyB) OVER(ORDER BY Year, Month)*100 AS CompanyBMonthlySalesPercentageGrowth
, LEAD(SalesByMonthCompanyB, 12) OVER(ORDER BY Year, Month) AS ProjectedCompanyBMonthlySalesGrowth
FROM temp_MonthlyCompanySalesGrowth1
ORDER BY 1, 2


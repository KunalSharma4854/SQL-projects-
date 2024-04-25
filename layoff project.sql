select * from layoffs

-- Firstly we are creating a table on which we are going to perform our tasks 
-- so our orignal data is not disturbed.


-- Create a new table with the same structure
SELECT TOP 0 *  -- This ensures no data is copied
INTO layoff_staging  -- New table name
FROM layoffs;  -- Source table

select * from layoff_staging
USE [Layoff project]
GO

--/****** Object:  Table [dbo].[layoffs]    Script Date: 22-04-2024 15:03:17 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO


--Drop table if exists [layoffs_New]
--CREATE TABLE [dbo].[layoffs_New](
--	[company] [varchar](max) NOT NULL,
--	[location] [varchar](max) NOT NULL,
--	[industry] [varchar](max) NULL,
--	[total_laid_off] [int] NULL,
--	[percentage_laid_off] [nvarchar](50) NULL,
--	[date] [date] NULL,
--	[stage] [nvarchar](max) NOT NULL,
--	[country] [varchar](max) NOT NULL,
--	[funds_raised_millions] [int] NULL
--) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
--GO


select * from layoff_staging
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------






--- for finding the duplicate values we are using ROW_NUMBER window function with CTE
with RownumCTE as (
select *, ROW_NUMBER() over (
partition by company, 
			location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions order by company) as rownum
from layoff_staging
)
select * 
from RownumCTE
WHERE rownum>1

--delete                       (for deleting the duplicate values)
--from RownumCTE
--WHERE rownum>1

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- The Next step is standardization of data



select company, trim(company)      -- (to remove the unnecessary spaces before and after the data)
from layoff_staging

update layoff_staging
set company = trim(company)

select distinct(industry)
from layoff_staging
order by 1 desc

select *                           -- (standardizing the similar looking fields in industry)
from layoff_staging
where industry like 'Crypto%'

update layoff_staging
set industry = 'Crypto'
where industry like 'Crypto%'


select distinct(country)           -- (standardizing the similar looking fields in industry)
from layoff_staging


select *
from layoff_staging
where country like '%.'


update layoff_staging
set country = 'United States'
where country like 'United States%'


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Population of possible null values 


select * from layoff_staging               --(checking the data for the possible null values to populated)

--converting the 'NULL' string to a null value 

update layoff_staging                     --( converting the string NULL to a null value)
set industry = null
where industry = 'NULL'

update layoff_staging                     --( converting the string NULL to a null value)
set stage = null
where stage = 'NULL'

update layoff_staging                     --( converting the string NULL to a null value)
set funds_raised_millions = null
where funds_raised_millions = 'NULL'

update layoff_staging
set industry = null
where date = 'NULL'

update layoff_staging
set total_laid_off = null
where total_laid_off = 'NULL'


update layoff_staging
set percentage_laid_off = null
where percentage_laid_off = 'NULL'




select * from layoff_staging               -- (finding the null values)
where  industry is null 


select a.industry, b.industry              -- (populating the null values using the value from same company at same location)
from layoff_staging a
join layoff_staging b
on a.company = b.company
and a.location = b.location
where  a.industry is null and b.industry is not null 

update a
set a.industry = b.industry

from layoff_staging a
join layoff_staging b
on a.company = b.company
and a.location = b.location

where  a.industry is null
and b.industry is not null





----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Standardization of date 



select date from layoff_staging
where [date] is  null 

update layoff_staging
set date = cast([date] as date)


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--correcting data types of different columns 

update layoff_staging                     --( changing the data  type)
set funds_raised_millions = convert(float, funds_raised_millions)


update layoff_staging                     --( changing the data  type)
set total_laid_off = convert (int,total_laid_off)


update layoff_staging                     --( changing the data  type)
set percentage_laid_off = convert(float,percentage_laid_off)


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-----removing unnecessary columns 


select* from layoff_staging

delete from layoff_staging
where total_laid_off is null 
and percentage_laid_off is null 

select * from layoff_staging
where industry is null

delete from layoff_staging 
where company = 'Blackbaud'















---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- EDA

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

SELECT * 
FROM layoff_staging

-- top 5 companies which laid_off most employees 

SELECT top 5 company, MAX(convert (int,total_laid_off)) as Max_laidoff
FROM layoff_staging
group by company 
order by Max_laidoff desc


-- Looking at Percentage to see how big these layoffs were
SELECT MAX(convert(float,percentage_laid_off)),  MIN(convert(float,percentage_laid_off))
FROM layoff_staging
WHERE  percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT company
FROM layoff_staging
WHERE  convert(float, percentage_laid_off) = 1;

-- how many companies laid_off
SELECT count(company)
FROM layoff_staging
WHERE  convert(float, percentage_laid_off) = 1;


-- if we order by funds_raised_millions we can see how big some of these companies were
SELECT *
FROM layoff_staging
WHERE  convert(float, percentage_laid_off) = 1
ORDER BY convert(float, funds_raised_millions) DESC;

-- these are mostly startups it looks like who all went out of business during this time















---------------------------------------------------------------------------------------------------------

-- Companies with the biggest single Layoff

SELECT  company, convert (int, total_laid_off) as layoff_number ,date 
FROM layoff_staging
ORDER BY 2 DESC

-- now that's just on a single day

-- Companies with the most Total Layoffs

select top 10 company, SUM(convert (int, total_laid_off))
FROM layoff_staging
GROUP BY company
ORDER BY 2 DESC



--by industry

SELECT top 5 industry, SUM(convert (int, total_laid_off))
FROM layoff_staging
GROUP BY industry
ORDER BY 2 DESC;


-- by location
SELECT top 10 location, SUM(convert (int, total_laid_off))
FROM layoff_staging
GROUP BY location
ORDER BY 2 DESC


-- country 

SELECT top 5 country, SUM(convert (int, total_laid_off))
FROM layoff_staging
GROUP BY country 
ORDER BY 2 DESC;

-- this it total in the past 3 years or in the dataset

SELECT YEAR(date) as years, SUM(convert (int, total_laid_off))as total_layoffs
FROM layoff_staging
GROUP BY YEAR(date)
ORDER BY 1 ASC;





SELECT stage, SUM(convert (int, total_laid_off)) as total_layoffs
FROM layoff_staging
GROUP BY stage
ORDER BY 2 DESC;






---------------------------------------------------------------------------------------------------------------------------------------

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year.

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(convert (int, total_laid_off)) AS total_laid_off
  FROM layoff_staging
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;




-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) as dates, SUM(convert (int, total_laid_off)) AS total_laid_off
FROM layoff_staging
GROUP BY date
ORDER BY date ASC;

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(convert (int, total_laid_off)) AS total_laid_off
FROM layoff_staging
GROUP BY date
--ORDER BY dates ASC
)
SELECT dates, SUM(convert (int, total_laid_off)) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;



















































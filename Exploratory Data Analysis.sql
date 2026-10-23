-- Exploratory Data Analysis
-- sometimes we do exploring it and cleaning it at same time

select *
from layoffs_staging2;

-- most of time we are working with total_laid_off and percentage_laid_off column, mostly with total_laid_off
-- because we did not have column that tells us how many total number of employees that company actually have

select max(total_laid_off)
from layoffs_staging2;-- means a company have some day total_laid_off 12000 employees

select max(percentage_laid_off)
from layoffs_staging2; -- means there is companies who have total laid_off 100% of employees, because 1 means 100%

select *
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off DESC;

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions DESC;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 DESC
;

select min(`date`),max(`date`)
from layoffs_staging2; -- it slike when covid pendamic started in 2020-03-11 and so on till 2023-03-06 we have the data

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 DESC
; -- we will also see that which industry actually got hit really hard during this time, and we can see that consumer, retail,
-- transpotation and finance, healthcare and food industry have maximum laid_off 
-- while industries like manufacturing, Fin-Tech, Aerospace and Energy have minimum laid_offs

select *
from layoffs_staging2;

-- now we have looked at the company and industry vise, now i am intrested in looking at country vise laid_offs

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 DESC
; -- United States, India, Netherlands, Sweden, Brazil and Germany have mamimum laid_offs
-- while Poland, Chile, New Zealand have minimum laid_offs 

-- lets take a look by date column, year wise

select YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by YEAR(`date`)
order by 2 DESC
; -- 2022, 2023 and 2020 have reporded the maximum laid_offs wile 2021 have the minimum laid_off compare to other years
-- as we have only data of first 3 monts of 2023 and 1 lac 25 thousand people laid_off within it
 
-- we do also look laid_off stage wise

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 DESC
; -- Post-IPO companies include Amazon, Google one's that have the maximum laid offs of 2 lac plus employees\

-- i am intrested in seeing the progression of layoffs, we can also called it the Rolling Sum of layoffs

select *
from layoffs_staging2;

select substring(`date`, 1, 7) as `Month` , sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `Month`
order by 1
;-- substring starts taking value from date column start at position 1 and took 7 values

-- we perform Rolling Total using the CTE

with Rolling_total as
(
select substring(`date`, 1, 7) as `Month` , sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by `Month`
order by 1
)
select `Month`, total_off, sum(total_off) over (order by `Month`)
from Rolling_total
;-- we can now see clearly that 2020-03 have only 9,628 layoff but the end of 2020-12 we have total 80,998
-- in the start of 2021-01 we have 6,813 layoffs and that total became 87,811 and by the end of 2021-12 we have total 96,821 layoffs
-- in the start of 2022-01 we have 510 layoffs and that total became 97,331 and by the end of 2022-12 we have total 257,482 layoffs
-- in the start of 2023-01 we have 84,714 layoffs and that total became 342,196 and by the 2023-03 we have total 383,159 layoffs
-- means total 383,159 persons lost there job reported according to the dataset from 2020-03 to 2023-03


-- now we will check layoffs that companies did year wise

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 DESC
;-- and we can see that 8x8 first laid_off 200 eployees in 2022 and then in 2023 they laid_off 155 employees
-- and we can see that Airbnb first laid_off 1900 eployees in 2020 and then in 2023 they laid_off 30 employees
-- and we can see that Amazon first laid_off 10,150 eployees in 2022 and then in 2023 they laid_off 8,000 employees
-- Google laid off 12,000 in 2023, Meta laid off 11,000 in 2022, Microsoft laid off 10,000 in 2023, 
-- Salesforce laid off 8,000 in 2023, Uber laid of 7,525 in 2020, Dell laid off 6,650 in 2023

-- the highest one based of laid_off to be rank no. 1, thats the year thaey laid of most people
-- for that we use CTE

with Company_Year (company, years, total_laid_off) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), Company_Year_Rank as
(
select *, DENSE_RANK() OVER(Partition By years order by total_laid_off DESC) as Ranking
from Company_year
where years is not null
)
select *
from Company_Year_Rank
where Ranking <= 5
;
-- in 2020 Uber have highest laid offs of 7,525 then Booking.com highest laid offs of 4,375, then Groupon, Swiggy and Airbnb
-- in 2021 Bytedance have highest laid offs of 3,600 then Katerra highest laid offs of 2,434, then Zilow, Instacart and WhiteHat Jr
-- in 2022 Meta have highest laid offs of 11,000 then Amazon highest laid offs of 10,150, then Cisco, Peloton, Carvana and Philips
-- in 2023 Google have highest laid offs of 12,000 then Microsoft highest laid offs of 10,000, then Ericsson, Amazon, Salesforce, Dell
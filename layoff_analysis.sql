use world_layoffs;

SELECT * FROM
    layoffs LIMIT 5;

CREATE TABLE layoff_staging LIKE layoffs;
INSERT layoff_staging select * from layoffs;

SELECT * FROM
    layoff_staging LIMIT 10;
    
-- TO identify duplicates

WITH dedup as (SELECT *, 
		ROW_NUMBER()OVER(PARTITION BY company, 
		location, industry, total_laid_off, 
		percentage_laid_off, 'date', 
		stage, country, funds_raised_millions) as row_num FROM layoff_staging)
        
        SELECT * from dedup WHERE row_num > 1;
        
        
-- Creating another table which contains only duplicate rows that need to be deleted
DROP TABLE layoff_staging2;
CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoff_staging2;

INSERT INTO layoff_staging2 SELECT *, 
		ROW_NUMBER()OVER(PARTITION BY company, 
		location, industry, total_laid_off, 
		percentage_laid_off, 'date', 
		stage, country, funds_raised_millions) as row_num FROM layoff_staging;
        
SELECT * FROM layoff_staging2 WHERE row_num>1;

-- Deleting the duplicates
DELETE FROM layoff_staging2 WHERE row_num>1;

-- Standardizing
#SET SQL_SAFE_UPDATES = 0;---------------------------------------------------------------------

SELECT distinct(company), TRIM(company) FROM layoff_staging2;

UPDATE layoff_staging2 SET company = TRIM(company);

SELECT DISTINCT(industry) from layoff_staging2 ORDER BY industry;

SELECT * from layoff_staging2 where industry like '%Crypto%';

UPDATE layoff_staging2 SET industry = 'Crypto' WHERE industry like '%Crypto%';

SELECT distinct(country) FROM layoff_staging2 order by 1;
UPDATE layoff_staging2 SET country = 'United States' WHERE country LIKE '%United States%'; -- Another method is to use TRIM, Trailing

SELECT `date`, str_to_date(`date`, '%m/%d/%Y')from layoff_staging2;
UPDATE layoff_staging2 SET `date` =  str_to_date(`date`, '%m/%d/%Y'); -- Alteratively we can do this by ALTER TABLE 
SELECT `date` from layoff_staging2;

-- To update the null values in industry column

UPDATE layoff_staging2 SET industry = NULL WHERE industry = '';

SELECT t1.industry, t2.industry 
FROM layoff_staging2 t1 
JOIN layoff_staging2 t2 ON t1.company = t2.company 
WHERE (t1.industry IS NULL) AND t2.industry IS NOT NULL;

UPDATE layoff_staging2 t1 
JOIN layoff_staging2 t2  
ON t1.company = t2.company 
SET t1.industry = t2.industry 
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

SELECT * FROM layoff_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
DELETE FROM layoff_staging2 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
SELECT * FROM layoff_staging2;
ALTER TABLE layoff_staging2 DROP COLUMN row_num;
SELECT * FROM layoff_staging2;

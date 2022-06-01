--select * from [SQL Practice]..[GPU_benchmarks$]

--select * from sysobjects 
--where xtype = 'U'

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'GPU_benchmarks$'

SELECT * INTO GPU_BENCHMARK_CLEANED FROM GPU_benchmarks$
SELECT * FROM GPU_BENCHMARK_CLEANED

SELECT DISTINCT(COUNT(GPUNAME)) FROM GPU_BENCHMARK_CLEANED

ALTER TABLE GPU_BENCHMARK_CLEANED
ADD PRIMARY KEY(gpuName)

ALTER TABLE GPU_BENCHMARK_CLEANED
ALTER COLUMN gpuName NVARCHAR(255) NOT NULL

SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
WHERE TABLE_NAME = 'GPU_BENCHMARK_CLEANED'

SELECT gpuName, TDP FROM GPU_BENCHMARK_CLEANED

--NO DUPLICATES

--COMPUTING MISSING VALUES

SELECT SUM(CASE 
			WHEN TDP is null THEN 1 ELSE 0 
			END) AS [Number Of Null Values] 
    , COUNT(TDP) AS [TDP] 
	, SUM(CASE 
			WHEN price is null THEN 1 ELSE 0 
			END) AS [Number Of Null Values] 
    , COUNT(price) AS [price] 
	,SUM(CASE 
			WHEN gpuValue is null THEN 1 ELSE 0 
			END) AS [Number Of Null Values] 
    , COUNT(gpuValue) AS [gpuValue] 
	,SUM(CASE 
			WHEN powerPerformance is null THEN 1 ELSE 0 
			END) AS [Number Of Null Values] 
    , COUNT(powerPerformance) AS [powerPerfomance] 
    FROM GPU_BENCHMARK_CLEANED

-- CLEANING THE DATASET

SELECT gpuName
FROM GPU_BENCHMARK_CLEANED
WHERE price IS NULL

BEGIN TRANSACTION

DELETE 
FROM GPU_BENCHMARK_CLEANED
WHERE category = 'Unknown'

COMMIT TRANSACTION


SELECT CEILING(AVG(TDP)) FROM GPU_BENCHMARK_CLEANED
SELECT CEILING(AVG(PRICE)) FROM GPU_BENCHMARK_CLEANED
SELECT CEILING(AVG(gpuValue)) FROM GPU_BENCHMARK_CLEANED
SELECT CEILING(AVG(powerPerformance)) FROM GPU_BENCHMARK_CLEANED

select * from GPU_BENCHMARK_CLEANED
where category = 'Mobile, Workstation' OR category = 'Desktop, Mobile'

SELECT category, CEILING(AVG(TDP)) FROM GPU_BENCHMARK_CLEANED
GROUP BY category


SELECT COUNT(*) FROM GPU_BENCHMARK_CLEANED
WHERE category = 'Mobile, Workstation' OR category = 'Desktop, Mobile'

with compl_cte 
as
(
	SELECT gpuName, G3Dmark, G2Dmark, TDP, price, gpuValue, powerPerformance, trim(cs.value) as category--SplitData
	from GPU_BENCHMARK_CLEANED
	cross apply STRING_SPLIT (category, ',') cs
)
SELECT * INTO GPU_Benchmark_1 FROM compl_cte

SELECT category, floor(AVG(TDP)), floor(AVG(price)) FROM GPU_Benchmark_1
GROUP BY category

select count(*) from GPU_Benchmark_1
where category = 'Workstation' 

select price, category from GPU_Benchmark_1
WHERE category = 'Desktop'

BEGIN TRANSACTION


UPDATE GPU_Benchmark_1
SET gpuValue_2D = G2Dmark/price


UPDATE GPU_Benchmark_1
SET powerPerformance_2D = G2Dmark/TDP


UPDATE GPU_Benchmark_1
SET TDP = 53
WHERE category = 'Mobile' AND TDP IS NULL

UPDATE GPU_Benchmark_1
SET price = 633
WHERE category = 'Workstation' AND price IS NULL

COMMIT TRANSACTION
gpuValue

SELECT category, floor(AVG(TDP)) FROM GPU_Benchmark_1
GROUP BY category

SELECT category, CEILING(AVG(price)) FROM GPU_Benchmark_1
GROUP BY category

ALTER TABLE GPU_Benchmark_1
ALTER COLUMN powerPerformance INT

SELECT * FROM [SQL Practice]..GPU_Benchmark_1

ALTER TABLE GPU_Benchmark_1
ADD gpuValue_2D int,
	powerPerformance_2D int

-----EXPLORATORY DATA ANALYSIS

SELECT category, AVG(PRICE) FROM GPU_Benchmark_1
GROUP BY category


WITH RANK_CTE
AS
(
	SELECT gpuName, price, TDP, gpuValue, powerPerformance, category, DENSE_RANK() OVER(PARTITION BY CATEGORY ORDER BY price desc) AS desnsrank
	FROM GPU_Benchmark_1
)
SELECT * FROM RANK_CTE 
WHERE desnsrank = 1

SELECT category, COUNT(*) AS Total_count FROM GPU_Benchmark_1
GROUP BY category
ORDER BY Total_count DESC


SELECT TOP 10 gpuName, powerPerformance FROM GPU_Benchmark_1
ORDER BY powerPerformance DESC

SELECT TOP 10 gpuName, G3Dmark FROM GPU_Benchmark_1
ORDER BY G3Dmark DESC

ALTER TABLE GPU_Benchmark_1
DROP COLUMN Performance_Category 

CREATE VIEW vwGPU_Analysis
AS
SELECT *,(	
		CASE
		WHEN G3Dmark BETWEEN 0 AND 8960 THEN 'Low Performance'
		WHEN G3Dmark BETWEEN 8961 AND 17919 THEN 'Medium Performance'
		WHEN G3Dmark BETWEEN 17920 AND 26878 THEN 'High Performance'
		END
		) AS Perfomance_Category
FROM GPU_Benchmark_1

SELECT * FROM vwGPU_Analysis

SELECT Perfomance_Category, COUNT(*) AS Total_Count FROM vwGPU_Analysis
GROUP BY Perfomance_Category
ORDER BY Total_Count DESC

SELECT * FROM GPU_Benchmark_1

WITH GPU_CTE
AS
(
	SELECT *,	
			CASE
			WHEN G3Dmark BETWEEN 0 AND 8960 THEN 'Low Performance'
			WHEN G3Dmark BETWEEN 8961 AND 17919 THEN 'Medium Performance'
			WHEN G3Dmark BETWEEN 17920 AND 26878 THEN 'High Performance'
			END AS Perfomance_Category
	FROM GPU_Benchmark_1
)




SELECT * INTO GPU_Analysis FROM vwGPU_Analysis

SELECT * FROM GPU_Analysis

SELECT Perfomance_Category, COUNT(*) AS Total_Count FROM GPU_Analysis
GROUP BY Perfomance_Category
ORDER BY Total_Count DESC

SELECT * FROM GPU_Analysis
WHERE Perfomance_Category = 'High Performance'
ORDER BY G3Dmark DESC

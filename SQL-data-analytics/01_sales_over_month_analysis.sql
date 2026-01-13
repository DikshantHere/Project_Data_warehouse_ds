-- creating deep report about the data 

-- TOTAL SALES OVER YEAR

SELECT 
	DATEPART (YEAR,order_date) AS YEAR 
	,SUM(sales_amount) AS TOTAL_SALE
	,COUNT(DISTINCT customer_key) AS TOTAL_CUSTOMERS
	,SUM(quantity) AS TOTAL_QUANTITY
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEPART(YEAR,order_date)
ORDER BY 2 DESC

--  BY MONTH 

SELECT 
	FORMAT(order_date,'yyy-MMMM') AS YEAR 
	,SUM(sales_amount) AS TOTAL_SALE
	,COUNT(DISTINCT customer_key) AS TOTAL_CUSTOMERS
	,SUM(quantity) AS TOTAL_QUANTITY
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR,order_date),FORMAT(order_date,'yyy-MMMM'),DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(YEAR,order_date) DESC ,DATETRUNC(MONTH,order_date) 

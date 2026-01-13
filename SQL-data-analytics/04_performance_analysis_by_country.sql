
--which COUNTRY contributed most in the sales 
WITH cte_sales_cntry 
AS (
	SELECT 
		country
		,SUM(sales_amount) AS sales_per_country
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_customer AS c
	ON s.customer_key = c.customer_key
	GROUP BY country )

SELECT 
	country
	,sales_per_country
	,SUM(sales_per_country) OVER () AS total_country 
	,CAST(ROUND(CAST(sales_per_country AS float)/SUM(sales_per_country) OVER () * 100 ,2) AS nvarchar) + '%'AS contribution_in_sales
FROM cte_sales_cntry
ORDER BY 2 DESC ;

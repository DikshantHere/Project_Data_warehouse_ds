
-- WHICH CATOGARY CONTRIBUTED MOST IN THE SALES

WITH cte_sales_cat
AS (
	SELECT 
		p.product_catogary
		,SUM(sales_amount) AS sales_per_catogary
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_products AS P
	ON s.product_key = P.product_key
	GROUP BY p.product_catogary)

SELECT 
	product_catogary
	,sales_per_catogary
	,SUM(sales_per_catogary) OVER () AS total_per_cat
	,CAST(ROUND(CAST(sales_per_catogary AS float)/SUM(sales_per_catogary) OVER () * 100 ,2) AS nvarchar) + '%'AS contribution_in_sales
FROM cte_sales_cat
ORDER BY 2 DESC ;


--segment product into  ranges and count how many product fall into each segment 
WITH cte_cost_range 
AS (
	SELECT
		 product_key
		,product_name
		,CASE WHEN product_cost < 100 THEN 'Below 100'
			WHEN product_cost BETWEEN 100 AND 500 THEN '100-500' 
			WHEN product_cost BETWEEN 500 AND 1000 THEN'500-1000'
			WHEN product_cost BETWEEN 1000 AND 1500 THEN'1000-1500'
			ELSE 'Above 1500'
		END AS Cost_range
	FROM gold.dim_products
)
SELECT
	Cost_range
	,COUNT(*) AS product_count
FROM cte_cost_range
GROUP BY Cost_range
ORDER BY 2 DESC

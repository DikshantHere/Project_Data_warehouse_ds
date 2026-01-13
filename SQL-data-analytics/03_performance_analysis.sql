--ANLAYZE YEARLY PERFORMANCE OF THE PRODUCT BY COMPARING THERE SALES TO BOTH 
-- AVERAGE SALES PERFORMANCE OF THE PRODUCT AND THE PREVIOUS YEAR'S SALES
WITH cte_yearly_sale AS (
SELECT 
	YEAR(s.order_date) AS order_date
	,p.product_name
	,SUM (s.sales_amount) AS total_sales
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p 
ON s.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(s.order_date),p.product_name
)

SELECT 
	order_date
	,product_name
	,total_sales
	,AVG(TOTAL_SALES) OVER(PARTITION BY product_name) AS avg_sale
	,TOTAL_SALES - AVG(TOTAL_SALES) OVER(PARTITION BY product_name)  AS Difference_bw_avg_tsales 
	,CASE WHEN TOTAL_SALES - AVG(TOTAL_SALES) OVER(PARTITION BY product_name) <0 THEN 'Below Average'
		WHEN TOTAL_SALES - AVG(TOTAL_SALES) OVER(PARTITION BY product_name) > 0 THEN 'Above Average'
		ELSE 'Average'
	END AS diff_flag
	,LAG(TOTAL_SALES) OVER (PARTITION BY product_name ORDER BY order_date ) AS Previous_year_sales 
	,total_sales - LAG(TOTAL_SALES) OVER (PARTITION BY product_name ORDER BY order_date ) AS diff_from_previous_year
	,CASE WHEN total_sales - LAG(TOTAL_SALES) OVER (PARTITION BY product_name ORDER BY order_date ) > 0 THEN 'Increaseing'
		WHEN total_sales - LAG(TOTAL_SALES) OVER (PARTITION BY product_name ORDER BY order_date ) < 0 THEN 'Decreasing'
		ELSE 'No Change '
	END AS year_sales_flag
FROM cte_yearly_sale

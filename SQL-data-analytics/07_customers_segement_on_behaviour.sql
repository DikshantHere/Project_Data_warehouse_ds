/* Group customers into thee segments based on their spending behavior:
- VIP: at least 12 months of history and spending more than 5000 .
-Regular: at least 12 months of history but spending 5000 or less.
-New : lifespan less than 12 months.
And find the total number of customers by each group .
*/
WITH cte_cust_lifespan 
AS (
	SELECT 
		c.first_name
		,c.last_name
		,MIN(order_date) AS first_orderdate
		,MAX(order_date) AS last_orderdate
		,SUM(sales_amount) AS sales_per_cust
		,DATEDIFF (MONTH,MIN(order_date),MAX(order_date)) AS life_span_cust
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_customer AS c
	ON s.customer_key = c.customer_key
	WHERE S.order_date IS NOT NULL
	GROUP BY c.first_name,c.last_name
)

SELECT
	cust_segment
	,COUNT(*) AS total_customers
FROM(
	SELECT 
		first_name
		,last_name
		,sales_per_cust
		,life_span_cust
		,CASE 
	 		WHEN life_span_cust>=12 AND sales_per_cust > 5000 THEN 'VIP'
			WHEN life_span_cust>=12 AND sales_per_cust <= 5000 THEN 'REGULAR'
			WHEN life_span_cust<12 THEN 'NEW'
		 END AS cust_segment
	FROM cte_cust_lifespan
)t
GROUP BY cust_segment
ORDER BY CASE cust_segment
    WHEN 'VIP'     THEN 1
    WHEN 'REGULAR' THEN 2
    WHEN 'NEW'     THEN 3
END ASC


/*
================================================================================
Customer Report
================================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend
================================================================================
*/
IF OBJECT_ID('gold.cust_report','V')IS NOT NULL
	DROP VIEW gold.cust_report;
GO
CREATE OR ALTER VIEW gold.cust_report AS
with cte_base_query 
AS (
	SELECT 
		CONCAT(c.first_name,c.last_name) AS name
		,c.customer_key
		,c.customer_number
		,DATEDIFF (YEAR,c.birthdate ,GETDATE()) AS age
		,s.order_number
		,s.order_date
		,s.quantity
		,s.sales_amount
		,s.product_key
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_customer AS c
	ON s.customer_key = c.customer_key
	WHERE s.order_date IS NOT NULL
),
cte_second_base 
AS (
	SELECT 
		 name
		,age
		,customer_key
		,customer_number
		,SUM(sales_amount) AS total_sales
		,SUM(quantity) AS total_quantity 
		,COUNT(order_number) AS total_orders
		,count(product_key) AS total_products
		,MAX(order_date) AS last_order
		,DATEDIFF (MONTH,MIN(order_date),MAX(order_date)) AS life_span_cust
	FROM cte_base_query
	GROUP BY customer_key,customer_number,name,age
)

SELECT 
name
,age
,CASE 
	WHEN age < 20 THEN 'Below 20'
	WHEN age BETWEEN 20 AND 30 THEN '20-30'
	WHEN age BETWEEN 31 AND 40 THEN '31-40'
	WHEN age BETWEEN 41 AND 50 THEN '41-50'
	ELSE 'Above 50'
 END AS age_group
,customer_key
,customer_number
,total_sales
,total_quantity
,total_orders
,CASE 
	WHEN  total_products = 0 THEN 0 
	ELSE total_sales/total_products 
 END AS avg_order_value
,total_products
,last_order
,DATEDIFF (MONTH,last_order,GETDATE()) AS recency
,CASE WHEN life_span_cust = 0 THEN total_orders
	ELSE total_orders/life_span_cust 
 END AS avg_monthly_spend
,life_span_cust
,CASE 
	WHEN life_span_cust>=12 AND total_sales > 5000 THEN 'VIP'
	WHEN life_span_cust>=12 AND total_sales<= 5000 THEN 'REGULAR'
	WHEN life_span_cust<12 THEN 'NEW'
	END AS cust_segment
FROM cte_second_base;
GO
SELECT 
	* 
FROM gold.cust_report
;

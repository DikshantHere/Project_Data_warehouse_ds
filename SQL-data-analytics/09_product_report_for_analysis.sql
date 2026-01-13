/*
Product Report
Purpose: - This report consolidates key product metrics and behaviors.

Highlights: 1. Gathers essential fields such as product name, category, subcategory, and cost.
2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers. 
3. Aggregates product-level metrics:
- total orders
- total sales
- total quantity sold 
- total customers (unique)
- lifespan (in months) 
4. Calculates valuable KPIs: 
- recency (months since last sale)
- average order revenue (AOR) 
- average monthly revenue
*/
IF OBJECT_ID ('gold.product_report','V') IS NOT NULL
	DROP VIEW gold.product_report;
GO
CREATE VIEW gold.product_report AS 
with cte_product_base 
AS (
SELECT 
 	 p.product_name
	,p.product_key
	,p.product_number
	,p.product_catogary
	,p.subcatogary
	,s.customer_key
	,p.product_cost
	,s.order_date
	,s.sales_amount
	,s.quantity
	,s.order_number
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.product_key
),
cte_product_agg AS (
	SELECT 
		 product_name
		,product_key
		,product_number
		,product_catogary
		,subcatogary
		,product_cost
		,COUNT(DISTINCT customer_key) AS total_customers
		,DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS life_span
		,MAX(order_date) AS last_order
		,SUM(sales_amount) AS total_sales
		,ROUND(AVG(CAST (sales_amount AS float)/NULLIF (quantity,0)),1)AS avg_sales_price
		,SUM(quantity) AS total_quantity
		,COUNT(DISTINCT order_number) AS total_orders
	FROM cte_product_base
	GROUP BY product_key,product_name, product_number,product_catogary,subcatogary,product_cost
)

SELECT 
	 product_name
	,product_key
	,product_number
	,product_catogary
	,subcatogary
	,product_cost
	,total_customers
	,life_span
	,last_order
	,DATEDIFF(MONTH,last_order,GETDATE()) AS recency
	,total_sales
	,CASE 
		WHEN total_sales > 50000 THEN 'High-Performance'
		WHEN total_sales >= 10000 THEN 'Mid Range'
		ELSE 'Low-Performance'
	 END AS sales_segment
	,CASE 
		WHEN life_span = 0 THEN total_sales
		ELSE total_sales / life_span 
	 END AS avg_monthly_revenue
	,avg_sales_price
	,total_quantity
	,total_orders
	,CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales/total_orders 
	 END AS avg_order_revenue
FROM cte_product_agg;

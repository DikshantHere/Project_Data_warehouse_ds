/* 
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customer
-- =============================================================================

IF OBJECT_ID ('gold.dim_customer','V') IS NOT NULL
	DROP VIEW gold.dim_customer ;
GO

CREATE VIEW gold.dim_customer AS 
SELECT
	 ROW_NUMBER () OVER (ORDER BY ci.cst_id) AS customer_key
	,ci.cst_id AS customer_id
	,ci.cst_key AS customer_number
	,ci.cst_firstname AS first_name
	,ci.cst_lastname AS last_name
	,clc.CNTRY AS country
	,CASE WHEN ci.cst_gndr != 'N/A' THEN COALESCE(ci.cst_gndr,'N/A')
		  ELSE COALESCE(cbd.GEN,'N/A')
	 END AS Gender
	,ci.cst_marital_status AS marital_status
	,cbd.BDATE AS birthdate
	,ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_CUST_AZ12 AS cbd
ON ci.cst_key = cbd.CID
LEFT JOIN silver.erp_LOC_A101 clc
ON ci.cst_key = clc.CID;
GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID ('gold.dim_products','V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS 
SELECT
	 ROW_NUMBER () OVER (ORDER BY pd.prd_id ,pd.prd_key) AS product_key
	,pd.prd_id AS product_id
	,pd.prd_key AS product_number
	,pd.prd_nm AS product_name
	,pd.prd_cat_id AS product_cat_id
	,pdc.CAT AS  product_catogary 
	,pdc.SUBCAT AS subcatogary
	,pdc.MAINTENANCE AS mainatenance
	,pd.prd_cost AS product_cost
	,pd.prd_line AS product_line
	,pd.prd_start_dt AS product_start_date
FROM silver.crm_prd_info AS pd
LEFT JOIN silver.erp_PX_CAT_G1V2 AS pdc
ON pd.prd_cat_id = pdc.ID
WHERE prd_end_dt IS NULL;
GO

-- =============================================================================
-- Create Dimension: gold.fact_sales
-- =============================================================================
IF OBJECT_ID ('gold.fact_sales','v') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS 
SELECT 
	 sl.sls_ord_num AS order_number 
	,gdp.product_key AS product_key
	,gdc.customer_key AS customer_key
	,sl.sls_order_dt AS order_date
	,sl.sls_ship_dt AS shipping_date
	,sl.sls_due_dt AS due_date
	,sl.sls_sales AS sales_amount
	,sl.sls_quantity AS quantity
	,sl.sls_price AS price
FROM silver.crm_sales_details AS sl
LEFT JOIN gold.dim_products AS gdp
ON SL.sls_prd_key = gdp.product_number
LEFT JOIN gold.dim_customer AS gdc
ON sl.sls_cust_id = gdc.customer_id;

--data quality check before ETL to silver
--bronze layer
--quality check queries
-- crm.cust_info table  quality check
--checking for duplicates in id
SELECT
*
FROM (
	SELECT 
		*
		, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS duplicate_check
	FROM [bronze].[crm_cust_info]
)t
WHERE duplicate_check > 1 OR cst_id IS NULL
-- checking name for unwanted spaces
select 
	cst_firstname
	,cst_lastname
FROM [bronze].[crm_cust_info]
WHERE cst_firstname != TRIM(cst_firstname)
OR cst_lastname != TRIM(cst_lastname)
--cheking for non-standardized values in cst_marital_status and cst_gndr

select DISTINCT
	cst_gndr
FROM [bronze].[crm_cust_info];


select DISTINCT
	cst_marital_status
FROM [bronze].[crm_cust_info];

--------------------------------
-- data quality check for table bronze.crm_prd_info
-- finding duplicates in prd_id and prd key
select *
FROM (
	SELECT *
		, ROW_NUMBER() OVER (PARTITION BY prd_id ORDER BY prd_start_dt DESC) AS duplicate_flag_id
	FROM bronze.crm_prd_info
)t
where duplicate_flag_id > 1 ;
-- checking for duplicate key
--duplicate key is allowed becase it have information about increasing cost of the product by year 
select *
FROM (
	SELECT *
		, ROW_NUMBER() OVER (PARTITION BY prd_key ORDER BY prd_start_dt DESC) AS duplicate_flag_key
	FROM bronze.crm_prd_info
)t
where duplicate_flag_key > 1 

--check for extraspaces in prd_nm column
select *
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM (prd_nm)

--checking for distinct values in prd_line 
select DISTINCT prd_line
FROM bronze.crm_prd_info

--check for negetive cost or null 
select *
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost is NULL

-- chek for start date is greater than end date 
--to fix this we created new end date from the logic becaue start date is perfect in this data set

select *
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt

---------------------------------------------
--quality checks for the column bronze.crm_sales_details
--checking for extra space in the column sls_ord_num

SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

-- checking availablity of the sls_prd_key in the conecting table silver.crm_prd_info

SELECT
sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN ( SELECT 
 prd_key
FROM silver.crm_prd_info) 

-- checking for availablity of the sls_cust_id in the connecting table silver.crm_prd_info

SELECT
sls_cust_id
FROM bronze.crm_sales_details
WHERE  sls_cust_id NOT IN  ( SELECT
 cst_id
FROM silver.crm_cust_info) 

--CHECKING for valid sls_order_dt and sls_ship_date not less then  0 and have 8 char for changing the dtype to date
-- and order date is less then ship date
SELECT
sls_order_dt
FROM bronze.crm_sales_details 
WHERE sls_order_dt <=0 OR LEN(sls_order_dt ) != 8;

SELECT
sls_ship_dt
FROM bronze.crm_sales_details 
WHERE sls_ship_dt <=0 OR LEN(sls_ship_dt ) != 8; 

SELECT
sls_due_dt 
FROM bronze.crm_sales_details 
WHERE sls_due_dt <=0 OR LEN(sls_due_dt  ) != 8; 


SELECT 
*
FROM bronze.crm_sales_details 
WHERE sls_order_dt > sls_ship_dt

--check for invalid or negetive sls_sales and price and quantity
select
	sls_sales
	,sls_quantity
	,sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity*sls_price 
OR sls_sales <= 0 OR sls_quantity <=0 OR sls_price <= 0  
OR sls_sales IS NULL OR  sls_quantity IS NULL OR sls_price IS NULL

-------------------------------------------
--checking tables from source erp ---
-- table silver.cust_az12
-- checking for key abailablility to connect to other table .
-- need to transform key to and extract key

SELECT 
CID
FROM bronze.erp_CUST_AZ12
WHERE CID NOT IN ( SELECT 
 cst_key
FROM silver.crm_cust_info)

-- checking for birthdate in future 
SELECT
	BDATE
FROM bronze.erp_CUST_AZ12
WHERE BDATE > GETDATE()

--CHECK for all the distinct value in the gender column
SELECT DISTINCT GEN
FROM bronze.erp_CUST_AZ12

----------------------------
-- quality check for the tabale [bronze.].[erp_LOC_A101]
--CHECKING ID  MATCHING WITH CONECTING COLUMN
-- removing - from the middle of the id and checking for extra space in id
select *
FROM [bronze].[erp_LOC_A101]
--WHERE CID != TRIM(CID);

select TOP 100 
*
FROM silver.crm_cust_info

-- CHECKING for distinct contry names and giving standardized values
SELECT DISTINCT CNTRY
FROM bronze.erp_LOC_A101
-----------------------------------
--QUALITY CHECK OF THE TABLE erp_PX_CAT_G1V2
-- checking for id avalable in conncting table 
-- THIS CASE THERE IS ID WITH NO SELL
SELECT *
FROM bronze.erp_PX_CAT_G1V2
WHERE ID NOT IN (SELECT prd_key FROM bronze.crm_prd_info)

-- CHECKING FOR EXTRA spaces in the strings
SELECT *
FROM bronze.erp_PX_CAT_G1V2
WHERE CAT != TRIM(CAT) OR SUBCAT != TRIM(SUBCAT)
OR MAINTENANCE != TRIM(MAINTENANCE)
 -- checking for data standardization and consistency 
 SELECT DISTINCT 
CAT
FROM bronze.erp_PX_CAT_G1V2
---------------------------------

/*
This script is used to create table for the data set from the bronze layer.
and add a new metadat column creation date 
this script make sure to delete the old table named 
silver.crm_cust_info 
,silver.crm_prd_info 
,silver.crm_sales_details
,silver.erp_CUST_AZ12,
silver.erp_LOC_A101
,silver.erp_PX_CAT_G1V2  and create them again with new constraints and data type and
trnasformed clean data .

*/
USE warehouse_project;
GO

IF OBJECT_ID ('silver.crm_cust_info','U') IS NOT NULL
	BEGIN 
		DROP TABLE silver.crm_cust_info
		PRINT 'EXISTING silver.crm_cust_info  TABLE DELETED '
		PRINT '--------------------------------------------'
	END;
GO

CREATE TABLE silver.crm_cust_info (
	cst_id INT 
	,cst_key NVARCHAR(50) 
	,cst_firstname NVARCHAR(50)
	,cst_lastname NVARCHAR(50)
	,cst_marital_status NVARCHAR(10)
	,cst_gndr NVARCHAR(10)
	,cst_create_date DATE
	,dwhp_creation_date DATETIME DEFAULT GETDATE()
)
PRINT '01 NEW silver.crm_cust_info TABLE CREATED '
PRINT '===================================='
;
GO

IF OBJECT_ID ('silver.crm_prd_info','U') IS NOT NULL
	BEGIN 
		DROP TABLE silver.crm_prd_info 
		PRINT 'EXISTING silver.crm_prd_info  TABLE DELETED '
		PRINT '--------------------------------------------'
	END;
GO
CREATE TABLE silver.crm_prd_info (
	prd_id INT 
	,prd_cat_id NVARCHAR(50) 
	,prd_key NVARCHAR(50)
	,prd_nm NVARCHAR(50)
	,prd_cost  INT
	,prd_line NVARCHAR(50)
	,prd_start_dt DATE
	,prd_end_dt DATE
	,dwhp_creation_date DATETIME DEFAULT GETDATE()
)
PRINT '02 NEW silver.crm_prd_info  TABLE CREATED '
PRINT '====================================';
GO

IF OBJECT_ID ('silver.crm_sales_details','U') IS NOT NULL
	BEGIN 
		DROP TABLE silver.crm_sales_details
		PRINT 'EXISTING silver.crm_sales_details TABLE DELETED '
		PRINT '--------------------------------------------'
	END;
GO
CREATE TABLE silver.crm_sales_details(
	sls_ord_num NVARCHAR(50) 
	,sls_prd_key NVARCHAR(50) 
	,sls_cust_id INT 
	,sls_order_dt DATE
	,sls_ship_dt DATE
	,sls_due_dt DATE
	,sls_sales INT
	,sls_quantity INT
	,sls_price INT
	,dwhp_creation_date DATETIME DEFAULT GETDATE()
)
PRINT '03 NEW silver.crm_sales_details TABLE CREATED '
PRINT '====================================';
GO

IF OBJECT_ID ('silver.erp_CUST_AZ12','U') IS NOT NULL
	BEGIN 
		DROP TABLE silver.erp_CUST_AZ12
		PRINT 'EXISTING silver.erp_CUST_AZ12 TABLE DELETED '
		PRINT '--------------------------------------------'
	END;
GO 
CREATE TABLE silver.erp_CUST_AZ12(
	CID NVARCHAR (50) 
	,BDATE DATE
	,GEN NVARCHAR (50)
	,dwhp_creation_date DATETIME DEFAULT GETDATE()
)
PRINT '04 NEW silver.erp_CUST_AZ12 TABLE CREATED '
PRINT '====================================';
GO 

IF OBJECT_ID ('silver.erp_LOC_A101','U') IS NOT NULL
	BEGIN 
		DROP TABLE silver.erp_LOC_A101
		PRINT 'EXISTING silver.erp_LOC_A101 TABLE DELETED '
		PRINT '--------------------------------------------'
	END;
GO
CREATE TABLE silver.erp_LOC_A101(
	CID NVARCHAR(50)
	,CNTRY NVARCHAR(50)
	,dwhp_creation_date DATETIME DEFAULT GETDATE()
)
PRINT '05 NEW silver.erp_LOC_A101 IS CREATED '
PRINT '====================================';
GO

IF OBJECT_ID ('silver.erp_PX_CAT_G1V2','U') IS NOT NULL
	BEGIN 
		DROP TABLE silver.erp_PX_CAT_G1V2
		PRINT 'EXISTING silver.erp_PX_CAT_G1V2 TABLE DELETED '
		PRINT '--------------------------------------------'
	END;
GO
CREATE TABLE silver.erp_PX_CAT_G1V2(
	ID NVARCHAR(50) 
	,CAT NVARCHAR(50)
	,SUBCAT NVARCHAR(50)
	,MAINTENANCE NVARCHAR(10)
	,dwhp_creation_date DATETIME DEFAULT GETDATE()
)
PRINT '06 NEW silver.erp_PX_CAT_G1V2 TABLE CREATED '
PRINT '====================================';
GO

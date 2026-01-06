--moving data from the bronze to silver dml insert into 
/*
===============================================================================
Stored Procedure: Load silver Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'silver' schema from the table of the 'bronze' schema . 
    It performs the following actions:
    - Truncates the silver tables before loading data.
	- Extract the data from the bronze layer and transform the data after the quality check 
    - LOAD the clean data into the tables of 'silver' schema or silver layer.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.full_load_silver;
===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.full_load_silver AS 
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME , @end_time DATETIME , @batch_start_time DATETIME , @batch_end_time DATETIME;

		SET @batch_start_time = GETDATE();
		PRINT '-----------------------------------------------------------------------';
		PRINT '----------------------- SILVER LAYER LOADING ---------------------------';
		PRINT '------------------------------------------------------------------------';
		PRINT '----------------------- SOURCE CRM LODING ------------------------';

		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>>> LODING TABLE : silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
				[cst_id]
			  ,[cst_key]
			  ,[cst_firstname]
			  ,[cst_lastname]
			  ,[cst_marital_status]
			  ,[cst_gndr]
			  ,[cst_create_date]
		)
		(
		SELECT
			cst_id
			,cst_key
			,TRIM(cst_firstname) AS cst_firstname
			,TRIM(cst_lastname) AS cst_lastname
			,CASE UPPER(TRIM(cst_marital_status))
				WHEN 'M' THEN 'Married'
				WHEN 'S' THEN 'Single'
				ELSE 'N/A'
			END AS cst_marital_status
			,
			CASE UPPER(TRIM(cst_gndr))
				WHEN 'M' THEN 'Male'
				WHEN 'F' THEN 'Female'
				ELSE 'N/A'
			END AS cst_gndr
			,cst_create_date
		FROM (
			SELECT 
				*
				, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS duplicate_check
			FROM [bronze].[crm_cust_info]
			WHERE cst_id IS NOT NULL
		)t
		WHERE duplicate_check = 1 
		);
		SET @end_time = GETDATE();
		PRINT '>>>LODING TIME silver.crm_cust_info : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================';
		--------------------
		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>>> LODING TABLE : silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
			 prd_id 
			,prd_cat_id  
			,prd_key 
			,prd_nm 
			,prd_cost  
			,prd_line 
			,prd_start_dt 
			,prd_end_dt
		)

		( SELECT
			   [prd_id]
			  ,REPLACE(SUBSTRING(prd_key,1,5),'-','_' )AS prd_cat_id
			  ,SUBSTRING(prd_key,7) AS prd_key
			  ,TRIM([prd_nm]) AS prd_nm
			  ,ISNULL([prd_cost],0) AS prd_cost
			  ,CASE UPPER(TRIM([prd_line]))
					WHEN 'M'THEN 'Mountain'
					WHEN 'R'THEN 'Road'
					WHEN 'T'THEN 'Touring'
					WHEN 'S'THEN 'Other Sales'
					ELSE 'N/A'
				END AS [prd_line]
			  ,[prd_start_dt]
			  ,DATEADD(DAY,-1,LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt )) AS prd_end_dt
		FROM bronze.crm_prd_info
		);
		SET @end_time = GETDATE();
		PRINT '>>>LODING TIME silver.crm_prd_info : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================';
		------------------------------------------
		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>>> LODING TABLE : silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
			 sls_ord_num 
			,sls_prd_key 
			,sls_cust_id 
			,sls_order_dt 
			,sls_ship_dt 
			,sls_due_dt 
			,sls_sales 
			,sls_quantity 
			,sls_price )
		(
		SELECT 
			 sls_ord_num 
			,sls_prd_key 
			,sls_cust_id 
			,CASE WHEN sls_order_dt <=0 OR LEN(sls_order_dt)!=8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
			END AS sls_order_dt
			,CASE WHEN sls_ship_dt <=0 OR LEN(sls_ship_dt)!=8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
			END AS sls_ship_dt 
			,CASE WHEN sls_due_dt <=0 OR LEN(sls_due_dt )!=8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
			END AS sls_due_dt 
			,CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price) 
				 THEN sls_quantity* ABS(sls_price)
				 ELSE sls_sales
				 END AS sls_sales
			,sls_quantity 
			,CASE WHEN sls_price IS NULL OR sls_price <=0 THEN ABS(sls_sales) / NULLIF(sls_quantity,0)
			 ELSE sls_price 
			 END AS sls_price
		FROM bronze.crm_sales_details
		);
		PRINT '>>>LODING TIME sales.crm_sales_details : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================';
		
		PRINT '----------------------- SOURCE ERP LODING ------------------------';

		-----------------------
		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : silver.erp_CUST_AZ12';
		TRUNCATE TABLE silver.erp_CUST_AZ12;
		PRINT '>>> LODING TABLE : silver.erp_CUST_AZ12';
		INSERT INTO silver.erp_CUST_AZ12(
			CID 
			,BDATE 
			,GEN)
		(
		SELECT 
			 CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(TRIM(CID),4)
				ELSE CID
			 END AS CID
			,CASE WHEN BDATE > GETDATE() THEN NULL
				ELSE BDATE
			 END AS BDATE
			,CASE WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
				ELSE 'N/A'
			END AS GEN
		FROM bronze.erp_CUST_AZ12
		);
		SET @end_time = GETDATE();
		PRINT '>>>LODING TIME silver.erp_CUST_AZ12 : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================';
		---------------------------------
		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : silver.erp_LOC_A101';
		TRUNCATE TABLE silver.erp_LOC_A101;
		PRINT '>>> LODING TABLE : silver.erp_LOC_A101';
		INSERT INTO silver.erp_LOC_A101 (
			CID
			,CNTRY
		)
		(SELECT
			REPLACE (CID,'-','') AS CID
			,CASE WHEN UPPER(TRIM(CNTRY)) IN ('US','USA') THEN 'United States'
				 WHEN UPPER(TRIM(CNTRY)) ='DE' THEN 'Germany'
				 WHEN CNTRY = '' OR CNTRY IS NULL THEN 'N/A'
				 ELSE TRIM(CNTRY)
			END AS CNTRY
		FROM [bronze].[erp_LOC_A101]
		);
		SET @end_time = GETDATE();
		PRINT '>>>LODING TIME silver.erp_LOC_A101 : '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================';
		-----------------------------
		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : silver.erp_PX_CAT_G1V2';
		TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
		PRINT '>>> LODING TABLE : silver.erp_PX_CAT_G1V2';
		INSERT INTO silver.erp_PX_CAT_G1V2(
			ID
			,CAT
			,SUBCAT
			,MAINTENANCE)
		(SELECT 
			ID
			,CAT
			,SUBCAT
			,MAINTENANCE
		FROM bronze.erp_PX_CAT_G1V2
		);
		SET @end_time = GETDATE();
		PRINT '>>>LODING TIME silver.erp_PX_CAT_G1V2 : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================'
		
		SET @batch_end_time = GETDATE();
		PRINT '-----------------------------------------------------------------------';
		PRINT 'loading time silver layer : ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR)+'SECONDS';
		PRINT '========================================================================';
	END TRY 
	BEGIN CATCH
		PRINT '----------------------  ERORR DETEDCTED DURING LOADING SILVER LAYER -----------------';
		PRINT 'Error massage : ' + ERROR_MESSAGE();
		PRINT 'Error state : '+ CAST (ERROR_STATE() AS NVARCHAR );
		PRINT 'Error NUMBER : '+ CAST (ERROR_NUMBER() AS NVARCHAR );
		PRINT 'Error SEVERITY : '+ CAST (ERROR_SEVERITY() AS NVARCHAR );
	END CATCH
END

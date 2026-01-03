/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME , @end_time DATETIME , @batch_start_time DATETIME , @batch_end_time DATETIME;
		SET @batch_start_time = GETDATE();

		PRINT '-----------------------------------------------------------------------';
		PRINT '----------------------- BRONZE LAYER LOADING ---------------------------';
		PRINT '------------------------------------------------------------------------';
		PRINT '----------------------- SOURCE CRM  LODING ------------------------';

		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>>> LODING TABLE : bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'D:\my_sql_new\Data werehouse project Dikshant\Dataset\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2
			,FIELDTERMINATOR = ','
			,TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>>>LODING TIME bronze.crm_cust_info : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================';
		
		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>>> LODING TABLE : bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'D:\my_sql_new\Data werehouse project Dikshant\Dataset\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2
			,FIELDTERMINATOR = ',' 
			,TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>>LODING TIME bronze.crm_prd_info : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================';

		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details ;
		PRINT '>>> LODING TABLE : bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'D:\my_sql_new\Data werehouse project Dikshant\Dataset\source_crm\sales_details.csv'
		WITH(
			FIRSTROW = 2
			,FIELDTERMINATOR = ','
			,TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>>LODING TIME bronze.crm_sales_details : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================';
		
		PRINT '----------------------- SOURCE ERP LODING ------------------------';

		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : bronze.erp_CUST_AZ12';
		TRUNCATE TABLE bronze.erp_CUST_AZ12;
		PRINT '>>> LODING TABLE : bronze.erp_CUST_AZ12';
		BULK INSERT bronze.erp_CUST_AZ12
		FROM 'D:\my_sql_new\Data werehouse project Dikshant\Dataset\source_erp\CUST_AZ12.csv'
		WITH(
			FIRSTROW = 2
			,FIELDTERMINATOR = ','
			,TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT '>>>LODING TIME bronze.erp_CUST_AZ12 : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================';
		
		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : bronze.erp_LOC_A101';
		TRUNCATE TABLE bronze.erp_LOC_A101;
		PRINT '>>> LODING TABLE : bronze.erp_LOC_A101';
		BULK INSERT bronze.erp_LOC_A101
		FROM 'D:\my_sql_new\Data werehouse project Dikshant\Dataset\source_erp\LOC_A101.csv'
		WITH(
			FIRSTROW =2 
			,FIELDTERMINATOR = ','
			,TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT '>>>LODING TIME bronze.erp_LOC_A101 : '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================';
		
		SET @start_time = GETDATE();
		PRINT '>>> TRUNCATING TABLE : bronze.erp_PX_CAT_G1V2';
		TRUNCATE TABLE bronze.erp_PX_CAT_G1V2 ;
		PRINT '>>> LODING TABLE : bronze.erp_PX_CAT_G1V2';
		BULK INSERT bronze.erp_PX_CAT_G1V2
		FROM 'D:\my_sql_new\Data werehouse project Dikshant\Dataset\source_erp\PX_CAT_G1V2.csv'
		WITH(
			FIRSTROW = 2
			,FIELDTERMINATOR = ',' 
			,TABLOCK 
		);
		SET @end_time = GETDATE();
		PRINT '>>>LODING TIME bronze.erp_PX_CAT_G1V2 : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR ) + 'SECONDS';
		PRINT '========================================================================'
		
		SET @batch_end_time = GETDATE();
		PRINT '-----------------------------------------------------------------------';
		PRINT 'loading time BRONZE layer : ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR)+'SECONDS';
		PRINT '========================================================================';
	END TRY 
	BEGIN CATCH 
		PRINT '----------------------  ERORR DETEDCTED DURING LOADING -----------------';
		PRINT 'Error massage : ' + ERROR_MESSAGE();
		PRINT 'Error state : '+ CAST (ERROR_STATE() AS NVARCHAR );
		PRINT 'Error NUMBER : '+ CAST (ERROR_NUMBER() AS NVARCHAR );
		PRINT 'Error SEVERITY : '+ CAST (ERROR_SEVERITY() AS NVARCHAR );
	END CATCH

END

/*
*******************************************************************
LOAD SCRIPT: 
This script truncates and loads the data to the bronze layer.
*******************************************************************
*/

EXEC bronze.load_bronze;

USE DataWarehouse;
GO
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
	
BEGIN 
	DECLARE @var_start_time DATETIME, @var_end_time DATETIME;
	DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY
		
		SET @batch_start_time = GETDATE();

		PRINT('===============================================');
		PRINT('Loading the Bronze Layer');
		PRINT('===============================================');

		PRINT('>>>>>>>>>>>   LOADING CRM TABLES   >>>>>>>>>>>>');

		SET @var_start_time = GETDATE();

		PRINT('-----------------------------------------------');
		PRINT('Truncating table: bronze.crm_cust_info');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: bronze.crm_cust_info');
		PRINT('-----------------------------------------------');

		BULK INSERT bronze.crm_cust_info
		FROM 'C:\DataWarehouse_Project\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @var_end_time = GETDATE();

		PRINT('==================***************==============');
		PRINT(' Load Duration: ' + CAST(DATEDIFF(second, @var_start_time, @var_end_time) AS NVARCHAR) +'seconds');
		PRINT('==================***************==============');

		-------------------

		SET @var_start_time = GETDATE();
		PRINT('-----------------------------------------------');
		PRINT('Truncating table: bronze.crm_prd_info');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: bronze.crm_prd_info');
		PRINT('-----------------------------------------------');

		BULK INSERT bronze.crm_prd_info
		FROM 'C:\DataWarehouse_Project\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @var_end_time = GETDATE();

		PRINT('==================***************==============');
		PRINT('Loaded in : ' + CAST( DATEDIFF(second, @var_start_time, @var_end_time) AS NVARCHAR) + 'seconds');
		PRINT('==================***************==============');
		---------------------

		SET @var_start_time = GETDATE();

		PRINT('-----------------------------------------------');
		PRINT('Truncating table: bronze.crm_sales_details');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: bronze.crm_sales_details');
		PRINT('-----------------------------------------------');

		BULK INSERT bronze.crm_sales_details
		FROM 'C:\DataWarehouse_Project\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @var_end_time = GETDATE();

		PRINT('==================***************==============');
		PRINT('Loaded in: ' + CAST(DATEDIFF(second, @var_start_time, @var_end_time) AS NVARCHAR) + 'seconds');
		PRINT('==================***************==============');

		----------------------

		PRINT('>>>>>>>>>>>   LOADING ERP TABLES   >>>>>>>>>>>>');

		SET @var_start_time = GETDATE();

		PRINT('-----------------------------------------------');
		PRINT('Truncating table: bronze.erp_cust_az12');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: bronze.erp_cust_az12');
		PRINT('-----------------------------------------------');

		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\DataWarehouse_Project\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @var_end_time = GETDATE();

		PRINT('==================***************==============');
		PRINT('Loaded in: ' + CAST(DATEDIFF(second, @var_start_time, @var_end_time) AS NVARCHAR) + 'seconds');
		PRINT('==================***************==============');

		-----------------------

		SET @var_start_time = GETDATE();

		PRINT('-----------------------------------------------');
		PRINT('Truncating table: bronze.erp_location_a101');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE bronze.erp_location_a101;

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: bronze.erp_location_a101');
		PRINT('-----------------------------------------------');

		BULK INSERT bronze.erp_location_a101
		FROM 'C:\DataWarehouse_Project\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @var_end_time = GETDATE();

		PRINT('==================***************==============');
		PRINT('Loaded in: ' + CAST(DATEDIFF(second, @var_start_time, @var_end_time) AS VARCHAR) + 'seconds');
		PRINT('==================***************==============');

		------------------------

		SET @var_start_time = GETDATE();

		PRINT('-----------------------------------------------');
		PRINT('Truncating table: bronze.erp_px_cat_g1v2');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: bronze.erp_px_cat_g1v2');
		PRINT('-----------------------------------------------');

		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\DataWarehouse_Project\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @var_end_time = GETDATE();

		PRINT('==================***************==============');
		PRINT('Loaded in: ' + CAST(DATEDIFF(second, @var_start_time, @var_end_time) AS NVARCHAR) + 'seconds');
		PRINT('==================***************==============');

		SET @batch_end_time = GETDATE();

		PRINT('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
		PRINT('Loading Bronze Layer is Completed');
		PRINT('Batch Load Duration: ' + CAST(DATEDIFF( second, @batch_start_time, @batch_end_time) AS VARCHAR ) + 'seconds');
		PRINT('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');

	END TRY

	BEGIN CATCH
		PRINT('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
		PRINT('ERROR MESSAGE!') + ERROR_MESSAGE();
		PRINT('ERROR MESSAGE !!') + CAST( ERROR_NUMBER() AS NVARCHAR );
		PRINT('ERROR MESSAGE !!!') + CAST( ERROR_STATE() AS NVARCHAR );
		PRINT('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
	END CATCH

END

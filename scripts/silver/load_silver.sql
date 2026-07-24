/*
=====================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=====================================================================================
Script Purpose:
	This stored procedure performs the ETL ( Extract, Transform, Load ) process 
	to populate the Silver schema tables from the bronze schema tables.

Actions Performed:
	- Truncates Silver tables.
	- Inserts transformed and cleansed date from Bronze into Silver tables.

Parameters:
	None.
	This stored procedure does not accept any parameters or return any values.

Usage Example:
	EXEC Silver.load_silver;

=====================================================================================
*/

EXEC silver.load_silver;

USE DataWarehouse;
GO
CREATE OR ALTER PROCEDURE silver.load_silver AS

BEGIN
	
	DECLARE @start_time DATETIME, @end_time DATETIME;
	DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY

		SET @batch_start_time = GETDATE();

		PRINT('===============================================')
		PRINT('Batch Loading the Silver Layer')
		PRINT('===============================================')

		PRINT('>>>>>>>>>>>   LOADING CRM TABLES   >>>>>>>>>>>>');

		SET @start_time = GETDATE();

		PRINT('-----------------------------------------------');
		PRINT('Truncating table: silver.crm_cust_info');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE silver.crm_cust_info

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: silver.crm_cust_info');
		PRINT('-----------------------------------------------');

		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)

		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname)	AS cst_firstname, -- Removing unwanted spaces
			TRIM(cst_lastname) AS cst_lastname,
			CASE	-- Standardize marital status values to readable format
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'n\a'
			END AS cst_marital_status,
			CASE	-- Standardize gender values to readable format
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n\a'
			END AS cst_gndr,
			cst_create_date
		FROM (
			SELECT *,	-- Removing duplicate values by taking values which have the latest create date only
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL	--Removing NULL values
		) AS result WHERE flag_last = 1	-- Selecting the most recent record per customer;

		SET @end_time = GETDATE();

		PRINT('*************************************************************')
		PRINT('Load Duration for silver.crm_cust_info: ' + CAST(DATEDIFF( second, @start_time, @end_time) AS NVARCHAR) + 'seconds');
		PRINT('*************************************************************')

		----------------------------------------

		SET @start_time = GETDATE();

		PRINT('-----------------------------------------------');
		PRINT('Truncating table: silver.crm_prd_info');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE silver.crm_prd_info

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: silver.crm_prd_info');
		PRINT('-----------------------------------------------');

		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)

		SELECT
			prd_id,
			REPLACE( SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,	-- Extract category id
			SUBSTRING( prd_key, 7, len(prd_key)) AS prd_key,	-- Extract product key
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,	-- Replacing NULL with zero
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,	-- Standardizing values in prd_line by mapping codes to descriptive values
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(
				LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
				AS DATE) AS prd_end_dt	-- Calculate end date as one day before the next start date
		FROM bronze.crm_prd_info;

		SET @end_time = GETDATE();

		PRINT('*************************************************************')
		PRINT('Load Duration for Table silver.crm_prd_info: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds');
		PRINT('*************************************************************')

		----------------------------------------

		SET @start_time = GETDATE();

		PRINT('-----------------------------------------------');
		PRINT('Truncating table: silver.crm_sales_details');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE silver.crm_sales_details

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: silver.crm_sales_details');
		PRINT('-----------------------------------------------');

		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)

		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR len(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR len(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR len(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE 
				WHEN sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
				THEN sls_quantity * abs(sls_price)
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE
				WHEN sls_price is null or sls_price <=0
				THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;

		SET @end_time = GETDATE();

		PRINT('*************************************************************')
		PRINT('Load Duration for Table silver.crm_sales_details: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds');
		PRINT('*************************************************************')

		----------------------------------------

		PRINT('>>>>>>>>>>>   LOADING ERP TABLES   >>>>>>>>>>>>');

		SET @start_time = GETDATE();

		PRINT('-----------------------------------------------');
		PRINT('Truncating table: silver.erp_cust_az12');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE silver.erp_cust_az12

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: silver.erp_cust_az12');
		PRINT('-----------------------------------------------');

		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)

		SELECT 
			CASE
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				ELSE cid
			END AS cid,
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE 
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12;

		SET @end_time = GETDATE();

		PRINT('*************************************************************')
		PRINT('Load Duration for Table silver.erp_cust_az12: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds');
		PRINT('*************************************************************')

		----------------------------------------

		SET @start_time = GETDATE();

		PRINT('-----------------------------------------------');
		PRINT('Truncating table: silver.erp_location_a101');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE silver.erp_location_a101

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: silver.erp_location_a101');
		PRINT('-----------------------------------------------');

		INSERT INTO silver.erp_location_a101 (
			cid,
			cntry
		)

		SELECT 
		REPLACE(cid, '-','') AS cid,
		CASE
			WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
			WHEN UPPER(TRIM(cntry)) IN ('USA', 'US') THEN 'United States'
			WHEN TRIM(cntry) = ' ' THEN NULL
			ELSE TRIM(cntry)
		END AS cntry
		FROM
		bronze.erp_location_a101;

		SET @end_time = GETDATE();

		PRINT('*************************************************************')
		PRINT('Load Duration for Table silver.erp_location_a101: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds');
		PRINT('*************************************************************')

		----------------------------------------

		SET @start_time = GETDATE();

		PRINT('-----------------------------------------------');
		PRINT('Truncating table: silver.erp_px_cat_g1v2');
		PRINT('-----------------------------------------------');

		TRUNCATE TABLE silver.erp_px_cat_g1v2

		PRINT('-----------------------------------------------');
		PRINT('Inserting into table: silver.erp_px_cat_g1v2');
		PRINT('-----------------------------------------------');

		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)

		select 
			id,
			cat,
			subcat,
			maintenance
		from bronze.erp_px_cat_g1v2;

		SET @end_time = GETDATE();
		PRINT('*************************************************************')
		PRINT('Load Duration for Table silver.erp_px_cat_g1v2: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds');
		PRINT('*************************************************************')

		SET @batch_end_time = GETDATE();

		PRINT('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
		PRINT('Batch Load for Silver Layer Completed')
		PRINT('Load Duration for the Silver Layer: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds');
		PRINT('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')

	END TRY

	BEGIN CATCH

		PRINT('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
		PRINT('Error Message: ') + ERROR_MESSAGE()
		PRINT('Error Number: ') + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT('Error State: ') + CAST(ERROR_STATE() AS NVARCHAR)
		PRINT('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')

	END CATCH
END

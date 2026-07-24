/*
===============================================================================
Data Quality Checks
===============================================================================

Script Purpose:
This scritp performs various quality checks for data consistency,
accuracy, and standardization across the 'silver' schemas.
It includes checks for:
	- Null or duplicate primary keys.
	- Unwanted spaces in string fields.
	- Data standardization and consistency.
	- Invalid date ranges and orders.
	- Data consistency between related fields.

Usage Notes:
	- Run these checks after data loading Silver Layer.
	- Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-------------------------------------------------------
-- Checking Table bronze.crm_cust_info
-------------------------------------------------------

-- Checking on duplicate values for primary key cst_id
-- Checking for null values for cst_id

select cst_id, count(*) from bronze.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null;

select *,
ROW_NUMBER() over (partition by cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info;

-- Checking unwanted spaces and null values

SELECT * 
FROM (
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
) as result WHERE flag_last = 1 and (cst_firstname is null or cst_lastname is null);

select cst_firstname
from bronze.crm_cust_info where cst_firstname != trim(cst_firstname);

select cst_lastname
from bronze.crm_cust_info where cst_lastname != trim(cst_lastname);

-- Data Standardization and Consistency

SELECT DISTINCT cst_marital_status from silver.crm_cust_info;

-------------------------------------------------------
-- Checking Table bronze.crm_prd_info
-------------------------------------------------------

-- checking duplicates in prd_id
select count(*) from silver.crm_prd_info group by prd_id having count(*) > 1;

-- checking for null values
select * from silver.crm_prd_info where prd_id is null;

-- prd_key
select prd_key from silver.crm_prd_info

-- prd_nm -> checking unwanted spaces
select prd_nm from silver.crm_prd_info where trim(prd_nm) != prd_nm;

-- prd_Cost -> checking negative and null values
select prd_cost from silver.crm_prd_info where prd_cost<0 or prd_cost is null;

-- prd_line -> Data Standardisation
select distinct prd_line from silver.crm_prd_info;

-- prd_start_dt and prd_end_dt
select * from silver.crm_prd_info where prd_start_dt > prd_end_dt;

select * from bronze.crm_prd_info where prd_start_dt > prd_end_dt and prd_key = 'AC-HE-HL-U509-R';

select *,
lead(prd_start_dt) OVER (Partition by prd_key order by prd_start_dt) - 1 as prd_end_date_test
from bronze.crm_prd_info where prd_key in ('AC-HE-HL-U509-B','AC-HE-HL-U509-R')

SELECT * FROM silver.crm_prd_info;

-------------------------------------------------------
-- Checking Table bronze.sales_details
-------------------------------------------------------

-- sls_ord_num -> checking nulls
SELECT * from bronze.crm_sales_details where sls_ord_num is null;

-- having more than one items on a sales order is fine
SELECT sls_ord_num, count(*) FROM bronze.crm_sales_details group by sls_ord_num having count(*) > 1;

-- checking data integrity with prd_key 
SELECT * from bronze.crm_sales_details 
where sls_prd_key not in 
(SELECT distinct prd_key from silver.crm_prd_info);

-- checking data integrity with cst_id
SELECT * from bronze.crm_sales_details 
where sls_cust_id not in 
(SELECT distinct cst_id from silver.crm_cust_info);

-- order_dt, ship_dt, due_dt

Select sls_order_dt, sls_ship_dt, sls_due_dt from bronze.crm_sales_details;

select sls_order_dt from bronze.crm_sales_details 
where sls_order_dt < 1900101 
or sls_order_dt > 20500101 
or sls_order_dt <= 0
or len(sls_order_dt) != 8;

-- Check for invalid date orders

select * from bronze.crm_sales_details where
sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt;

select sls_ship_dt from bronze.crm_sales_details 
where sls_ship_dt < 1900101 
or sls_ship_dt > 20500101 
or sls_ship_dt <= 0
or len(sls_ship_dt) != 8;

select sls_due_dt from bronze.crm_sales_details 
where sls_due_dt < 1900101 
or sls_due_dt > 20500101 
or sls_due_dt <= 0
or len(sls_due_dt) != 8;

-- sls_sales, sls_quantity, sls_price

select sls_sales, sls_quantity, sls_price
from silver.crm_sales_details where
sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0
or sls_sales != sls_quantity * sls_price
order by sls_sales, sls_quantity, sls_price

-- Data inconsistency found in sls_sales and sls_price
select CASE WHEN sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)
THEN sls_quantity * abs(sls_price)
ELSE sls_sales
END AS sls_sales from silver.crm_sales_details

select * from silver.crm_sales_details

-------------------------------------------------------
-- Checking Table bronze.erp_cust_az12
-------------------------------------------------------

-- Data Standardization

-- values in cid should be compaitble with the customer key in customer table

select distinct cid from bronze.erp_cust_az12 where cid not in (select cst_key from bronze.crm_cust_info);

-- The NAS in the customer id isn't quite significant and it doesn't make any sense hence removing it.

select
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
ELSE cid
END AS cid
FROM bronze.erp_cust_az12 WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
ELSE cid
END not in 
(select cst_key from silver.crm_cust_info);

-- bdate

select bdate from bronze.erp_cust_az12
where bdate < '1920-02-01' or bdate > getdate();

-- fix bdate

select
case when bdate > getdate() then NULL
ELSE bdate
END AS bdate
FROM bronze.erp_cust_az12;

-- Data Standardization
-- gen

select distinct gen from bronze.erp_cust_az12;

-- fix gen

select
CASE 
	WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	ELSE 'n/a'
END AS gen
FROM bronze.erp_cust_az12

-------------------------------------------------------
-- Checking Table bronze.erp_location_a101
-------------------------------------------------------

-- Data Standardization

select cid from bronze.erp_location_a101;

select REPLACE(cid, '-','') AS cid
from bronze.erp_location_a101;

-- cntry

select distinct cntry from bronze.erp_location_a101;

select 
CASE
	WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
	WHEN UPPER(TRIM(cntry)) IN ('USA', 'US') THEN 'United States'
	WHEN TRIM(cntry) = ' ' THEN NULL
	ELSE TRIM(cntry)
END AS cntry
FROM bronze.erp_location_a101;

-------------------------------------------------------
-- Checking Table bronze.erp_px_cat_g1v2
-------------------------------------------------------

--	Checking unwanted spaces

select * from bronze.erp_px_cat_g1v2
where cat != trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance);

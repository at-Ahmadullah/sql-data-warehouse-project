/*
=================================================================================

DDL Script: Create Gold Views
=================================================================================
Script Purpose:
  This script creates views for the Gold layer in the data warehouse.
  The Gold layer represents the final dimension and fact tables (Star Schema).

  Each view performs transformations and combines data from the Silver layer
  to produce a clean, enriched, and busniess ready dataset.

Usage:
  - These views can be queried directly for analytics and reporting.
=================================================================================
*/

---------------------------------------------------------------------------------
-- Create View gold.dim_products
---------------------------------------------------------------------------------

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY A.prd_start_dt, A.prd_key) AS product_key,
	A.prd_id AS product_id,
	A.prd_key AS product_number,
	A.prd_nm AS product_name,
	A.prd_cost AS cost,
	A.prd_line AS product_line,
	A.cat_id AS category_id,
	B.CAT AS category,
	B.SUBCAT AS sub_category,
	B.MAINTENANCE AS maintenance,
	A.prd_start_dt AS start_date
FROM silver.crm_prd_info AS A 
LEFT JOIN
silver.erp_px_cat_g1v2 AS B
ON A.cat_id = B.ID
WHERE A.prd_end_dt IS NULL -- Removing the historical data;

---------------------------------------------------------------------------------
-- Create View gold.fact_sales
---------------------------------------------------------------------------------

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	A.cst_id AS customer_ID,
	A.cst_key AS customer_number,
	A.cst_firstname AS first_name,
	A.cst_lastname AS last_name,
	C.CNTRY AS country,
	A.cst_marital_status AS marital_status,
	CASE 
		WHEN A.cst_gndr != 'n/a' THEN A.cst_gndr
		ELSE COALESCE(B.GEN, 'n/a')
	END AS gender,
	B.BDATE AS birth_date,
	A.cst_create_date AS create_date
FROM silver.crm_cust_info A
LEFT JOIN silver.erp_cust_az12 B
ON A.cst_key = B.cid
LEFT JOIN silver.erp_location_a101 C
ON A.cst_key = C.CID;

---------------------------------------------------------------------------------
-- Create View gold.fact_sales
---------------------------------------------------------------------------------
CREATE VIEW gold.fact_sales AS
SELECT
	S.sls_ord_num AS order_number,
	C.customer_key,
	P.product_key,
	S.sls_sales AS sales_amount,
    S.sls_quantity AS quantity,
    S.sls_price AS price,
    S.sls_order_dt AS order_date,
    S.sls_ship_dt AS shipment_date,
    S.sls_due_dt AS due_date
  FROM silver.crm_sales_details AS S
  LEFT JOIN gold.dim_customers AS C
  ON S.sls_cust_id = C.customer_ID
  LEFT JOIN gold.dim_products P
  ON S.sls_prd_key = P.product_number;

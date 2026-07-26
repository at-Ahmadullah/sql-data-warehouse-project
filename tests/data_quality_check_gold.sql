/*
============================================================================
Quality Checks
============================================================================
Script Purpose:
  This script performs quality checks to validate the integrity, consistency,
  and accuracy of the Gold Layer. These checks ensure:
  - Uniqueness of surrogate keys in dimension tables.
  - Referential Integrity between fact and dimension tables.
  - Validation of relationships in the data model for analytical purposes.

Usage notes:
  - Run these checks after data loading Silver Layer.
  - Investigate and resolve any discrepancies found during the checks.
==============================================================================
*/

------------------------------------------------------------------------------
-- Checking 'gold.dim_customers'
------------------------------------------------------------------------------
-- Check for uniqueness of the customer key.
-- Expectation: No results.
SELECT customer_key, count(*)
from gold.dim_customers
group by customer_key
having count(*) > 1;

------------------------------------------------------------------------------
-- Checking 'gold.dim_products'
------------------------------------------------------------------------------
-- Check for uniqueness of the product key.
-- Expectation: No results.

SELECT product_key, count(*)
from gold.dim_products
group by product_key
having count(*) > 1;

------------------------------------------------------------------------------
-- Checking 'gold.fact_sales'
------------------------------------------------------------------------------
-- Check Foreign Key Integrity ( Dimensions ) Check

SELECT * FROM gold.fact_sales S
LEFT JOIN gold.dim_customers C
ON S.customer_key = C.customer_key
LEFT JOIN gold.dim_products P
ON S.product_key = P.product_key
WHERE P.product_key IS NULL;


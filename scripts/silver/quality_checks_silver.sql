/*
========================================
Quality Checks
========================================
Script Purpose:
This script performs various quality checks for data consistency, accuracy, and standardization across the 'silver' schemas. It includes checks for:
  - Null or duplicate primary keys.
  - Unwanted spaces in string fields.
  - Data standardization and consistency.
  - Invalid date ranges and orders.
  - Data consistency between related fields.
*/

-- silver.crm_cust_info

	-- Check for NULLs or Duplicates in PK 
	SELECT cst_id, COUNT(*) 
	FROM silver.crm_cust_info
	GROUP BY cst_id
	HAVING COUNT(*) > 1 OR cst_id IS NULL

	-- Check for unwanted spaces
	SELECT cst_firstname
	FROM silver.crm_cust_info
	WHERE cst_firstname != TRIM(cst_firstname)


	-- Data Standartization & Consistency
	SELECT DISTINCT cst_gndr
	FROM silver.crm_cust_info



-- silver.crm_prd_info

	-- Check for NULLs or Duplicates in PK 
	SELECT prd_id, COUNT(*) 
	FROM silver.crm_prd_info
	GROUP BY prd_id
	HAVING COUNT(*) > 1 OR prd_id IS NULL

	-- Check for unwanted spaces
	SELECT prd_nm
	FROM silver.crm_prd_info
	WHERE prd_nm != TRIM(prd_nm)

	-- Check for NULLs or Negative Numbers
	SELECT prd_cost
	FROM silver.crm_prd_info
	WHERE prd_cost < 0 OR prd_cost IS NULL

	-- Data Standartization & Consistency
	SELECT DISTINCT prd_line
	FROM silver.crm_prd_info

	-- Check for Invalid Date Orders
	SELECT *
	FROM silver.crm_prd_info
	WHERE prd_end_dt < prd_start_dt



-- silver.crm_sales_details

	-- Check for Invalid dates
	SELECT sls_order_dt
	FROM silver.crm_sales_details
	WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) !=8

	-- Check for Invalid date Orders
	SELECT sls_order_dt
	FROM silver.crm_sales_details
	WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

	-- Check Data Consistency between Sales, Quantity and Price
	-- >> Sales = Quantity * Price
	-- >> Values must not be NULL, zero or -
	SELECT sls_sales, sls_quantity, sls_price
	/*
	CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
		 THEN sls_quantity * ABS(sls_price)
		 ELSE sls_sales
	END AS sls_sales,

	CASE WHEN sls_price IS NULL OR sls_price <=0
		 THEN sls_sales / NULLIF(sls_quantity, 0)
		 ELSE sls_price
	END AS sls_price
	*/
	FROM silver.crm_sales_details
	WHERE sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
	OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
	ORDER BY sls_sales, sls_quantity, sls_price



-- silver.erp_cust_az12

	-- Identify Out-of-Range Dates
	-- Expectation: Birthdates between 1924-01-01 and Today
	SELECT DISTINCT 
		bdate 
	FROM silver.erp_cust_az12
	WHERE bdate < '1924-01-01' 
	   OR bdate > GETDATE();

	-- Data Standardization & Consistency
	SELECT DISTINCT 
		gen 
	FROM silver.erp_cust_az12;



-- silver.erp_loc_a101

	-- Get rid of -'s
	SELECT 
	REPLACE(cid, '-', '') cid,
	cntry
	FROM silver.erp_loc_a101;

	-- Data Standardization & Consistency
	SELECT DISTINCT 
	cntry AS old_cntry,
		CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
		 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	END AS cntry
	FROM silver.erp_loc_a101
	ORDER BY cntry;



-- silver.erp_px_cat_g1v2
	SELECT * FROM silver.erp_px_cat_g1v2

	-- Check for unwanted spaces
	SELECT * FROM silver.erp_px_cat_g1v2
	WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) 
	OR maintenance != TRIM(maintenance);

	-- Data Standardization & Consistency
	SELECT DISTINCT
	maintenance
	FROM silver.erp_px_cat_g1v2;

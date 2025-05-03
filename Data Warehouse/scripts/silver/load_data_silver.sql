DELIMITER $$
DROP PROCEDURE IF EXISTS silver_load_silver$$

CREATE PROCEDURE silver_load_silver()
BEGIN
  DECLARE start_time DATETIME;
  DECLARE end_time DATETIME;
  DECLARE batch_start_time DATETIME;
  DECLARE batch_end_time DATETIME;
  
  SET batch_start_time = NOW();
  
  SELECT '================================================' AS status;
  SELECT 'Loading Silver Layer' AS status;
  SELECT '================================================' AS status;
  
  -- silver_crm_cust_info
  SET start_time = NOW();
  SELECT '>> Truncating Table: silver_crm_cust_info' AS status;
  TRUNCATE TABLE silver_crm_cust_info;
  SELECT '>> Inserting Data Into: silver_crm_cust_info' AS status;
  INSERT IGNORE INTO silver_crm_cust_info (
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
    TRIM(cst_firstname),
    TRIM(cst_lastname),
    CASE 
      WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
      WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
      ELSE 'n/a'
    END,
    CASE 
      WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
      WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
      ELSE 'n/a'
    END,
    cst_create_date
  FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze_crm_cust_info
    WHERE cst_id IS NOT NULL
  ) t
  WHERE flag_last = 1;
  SET end_time = NOW();
  SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS status;
  SELECT '------------------------------------------------' AS status;
  
  -- silver_crm_prd_info
  SET start_time = NOW();
  SELECT '>> Truncating Table: silver_crm_prd_info' AS status;
  TRUNCATE TABLE silver_crm_prd_info;
  SELECT '>> Inserting Data Into: silver_crm_prd_info' AS status;
  INSERT INTO silver_crm_prd_info (
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
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
    SUBSTRING(prd_key, 7, CHAR_LENGTH(prd_key)),
    prd_nm,
    prd_cost,
    CASE 
      WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
      WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
      WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
      WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
      ELSE 'n/a'
    END,
    DATE(prd_start_dt),
    DATE(DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY))
  FROM bronze_crm_prd_info;
  SET end_time = NOW();
  SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS status;
  SELECT '------------------------------------------------' AS status;
  
  -- silver_crm_sales_details
  SET start_time = NOW();
  SELECT '>> Truncating Table: silver_crm_sales_details' AS status;
  TRUNCATE TABLE silver_crm_sales_details;
  SELECT '>> Inserting Data Into: silver_crm_sales_details' AS status;
  INSERT INTO silver_crm_sales_details(
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
    CASE WHEN sls_order_dt = 0 OR CHAR_LENGTH(sls_order_dt) != 8 THEN NULL
         ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
    END,
    CASE WHEN sls_ship_dt = 0 OR CHAR_LENGTH(sls_ship_dt) != 8 THEN NULL
         ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
    END,
    CASE WHEN sls_due_dt = 0 OR CHAR_LENGTH(sls_due_dt) != 8 THEN NULL
         ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
    END, 
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
         THEN sls_quantity * ABS(sls_price) 
         ELSE sls_sales
    END,
    sls_quantity,
    CASE WHEN sls_price IS NULL OR sls_price <= 0 
         THEN sls_sales / NULLIF(sls_quantity, 0)
         ELSE sls_price
    END
  FROM bronze_crm_sales_details;
  SET end_time = NOW();
  SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS status;
  SELECT '------------------------------------------------' AS status;
  
  -- silver_erp_cust_az12
  SET start_time = NOW();
  SELECT '>> Truncating Table: silver_erp_cust_az12' AS status;
  TRUNCATE TABLE silver_erp_cust_az12;
  SELECT '>> Inserting Data Into: silver_erp_cust_az12' AS status;
  INSERT INTO silver_erp_cust_az12 (
    cid,
    bdate,
    gen
  )
  SELECT 
    CASE 
      WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, CHAR_LENGTH(cid))
      ELSE cid
    END,
    CASE 
      WHEN bdate > NOW() THEN NULL 
      ELSE bdate
    END,
    gen
  FROM bronze_erp_cust_az12;
  SET end_time = NOW();
  SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS status;
  SELECT '------------------------------------------------' AS status;
  
  -- silver_erp_loc_a101
  SET start_time = NOW();
  SELECT '>> Truncating Table: silver_erp_loc_a101' AS status;
  TRUNCATE TABLE silver_erp_loc_a101;
  SELECT '>> Inserting Data Into: silver_erp_loc_a101' AS status;
  INSERT INTO silver_erp_loc_a101 (
    cid,
    cntry
  )
  SELECT
    REPLACE(cid, '-', ''),
    CASE 
      WHEN REGEXP_REPLACE(cntry, '[\\s\\r\\n\\t]', '') = 'DE' THEN 'Germany'
      WHEN REGEXP_REPLACE(cntry, '[\\s\\r\\n\\t]', '') IN ('US', 'USA') THEN 'United States'
      WHEN REGEXP_REPLACE(cntry, '[\\s\\r\\n\\t]', '') = '' OR cntry IS NULL THEN 'n/a'
      ELSE TRIM(BOTH '\r\n\t ' FROM cntry)
    END
  FROM bronze_erp_loc_a101;
  SET end_time = NOW();
  SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS status;
  SELECT '------------------------------------------------' AS status;
  
  -- silver_erp_px_cat_g1v2
  SET start_time = NOW();
  SELECT '>> Truncating Table: silver_erp_px_cat_g1v2' AS status;
  TRUNCATE TABLE silver_erp_px_cat_g1v2;
  SELECT '>> Inserting Data Into: silver_erp_px_cat_g1v2' AS status;
  INSERT INTO silver_erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
  )
  SELECT 
    id,
    cat,
    subcat,
    maintenance
  FROM bronze_erp_px_cat_g1v2;
  SET end_time = NOW();
  SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS status;
  SELECT '------------------------------------------------' AS status;
  
  SET batch_end_time = NOW();
  
  SELECT '==========================================' AS status;
  SELECT 'Loading Silver Layer is Completed' AS status;
  SELECT CONCAT('   - Total Load Duration: ', TIMESTAMPDIFF(SECOND, batch_start_time, batch_end_time), ' seconds') AS status;
  SELECT '==========================================' AS status;
END$$
DELIMITER ;

call silver_load_silver();


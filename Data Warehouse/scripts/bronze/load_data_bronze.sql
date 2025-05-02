DELIMITER $$

CREATE PROCEDURE load_bronze()
BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE batch_start_time DATETIME;
    DECLARE batch_end_time DATETIME;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT '==========================================' AS msg;
        SELECT 'ERROR OCCURRED DURING LOADING BRONZE LAYER' AS msg;
        SHOW ERRORS;
        SELECT '==========================================' AS msg;
    END;

    SET batch_start_time = NOW();
    SELECT '================================================' AS msg;
    SELECT 'Loading Bronze Layer' AS msg;
    SELECT '================================================' AS msg;

    -- CRM Tables
    SELECT '------------------------------------------------' AS msg;
    SELECT 'Loading CRM Tables' AS msg;
    SELECT '------------------------------------------------' AS msg;

    SET start_time = NOW();
    SELECT '>> Truncating Table: bronze.crm_cust_info' AS msg;
    TRUNCATE TABLE bronze.crm_cust_info;

    SELECT '>> Inserting Data Into: bronze.crm_cust_info' AS msg;
    LOAD DATA LOCAL INFILE '/path/to/cust_info.csv'
    INTO TABLE bronze.crm_cust_info
    FIELDS TERMINATED BY ','
    IGNORE 1 ROWS;

    SET end_time = NOW();
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS msg;

    SET start_time = NOW();
    SELECT '>> Truncating Table: bronze.crm_prd_info' AS msg;
    TRUNCATE TABLE bronze.crm_prd_info;

    SELECT '>> Inserting Data Into: bronze.crm_prd_info' AS msg;
    LOAD DATA LOCAL INFILE '/path/to/prd_info.csv'
    INTO TABLE bronze.crm_prd_info
    FIELDS TERMINATED BY ','
    IGNORE 1 ROWS;

    SET end_time = NOW();
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS msg;

    SET start_time = NOW();
    SELECT '>> Truncating Table: bronze.crm_sales_details' AS msg;
    TRUNCATE TABLE bronze.crm_sales_details;

    SELECT '>> Inserting Data Into: bronze.crm_sales_details' AS msg;
    LOAD DATA LOCAL INFILE '/path/to/sales_details.csv'
    INTO TABLE bronze.crm_sales_details
    FIELDS TERMINATED BY ','
    IGNORE 1 ROWS;

    SET end_time = NOW();
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS msg;

    -- ERP Tables
    SELECT '------------------------------------------------' AS msg;
    SELECT 'Loading ERP Tables' AS msg;
    SELECT '------------------------------------------------' AS msg;

    SET start_time = NOW();
    SELECT '>> Truncating Table: bronze.erp_loc_a101' AS msg;
    TRUNCATE TABLE bronze.erp_loc_a101;

    SELECT '>> Inserting Data Into: bronze.erp_loc_a101' AS msg;
    LOAD DATA LOCAL INFILE '/path/to/loc_a101.csv'
    INTO TABLE bronze.erp_loc_a101
    FIELDS TERMINATED BY ','
    IGNORE 1 ROWS;

    SET end_time = NOW();
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS msg;

    SET start_time = NOW();
    SELECT '>> Truncating Table: bronze.erp_cust_az12' AS msg;
    TRUNCATE TABLE bronze.erp_cust_az12;

    SELECT '>> Inserting Data Into: bronze.erp_cust_az12' AS msg;
    LOAD DATA LOCAL INFILE '/path/to/cust_az12.csv'
    INTO TABLE bronze.erp_cust_az12
    FIELDS TERMINATED BY ','
    IGNORE 1 ROWS;

    SET end_time = NOW();
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS msg;

    SET start_time = NOW();
    SELECT '>> Truncating Table: bronze.erp_px_cat_g1v2' AS msg;
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    SELECT '>> Inserting Data Into: bronze.erp_px_cat_g1v2' AS msg;
    LOAD DATA LOCAL INFILE '/path/to/px_cat_g1v2.csv'
    INTO TABLE bronze.erp_px_cat_g1v2
    FIELDS TERMINATED BY ','
    IGNORE 1 ROWS;

    SET end_time = NOW();
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') AS msg;

    SET batch_end_time = NOW();
    SELECT '==========================================' AS msg;
    SELECT 'Loading Bronze Layer is Completed' AS msg;
    SELECT CONCAT('   - Total Load Duration: ', TIMESTAMPDIFF(SECOND, batch_start_time, batch_end_time), ' seconds') AS msg;
    SELECT '==========================================' AS msg;
END$$

DELIMITER ;
use DataWarehouse;
create table silver_crm_cust_info(
	cst_id int,
	cst_key varchar(50),
	cst_firstname varchar(50),
	cst_lastname varchar(50),
	cst_marital_status varchar(50),
	cst_gndr varchar(50),
	cst_create_date date,
    dwh_create_date Datetime Default CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS silver_crm_prd_info;
CREATE TABLE silver_crm_prd_info (
    prd_id INT,
    cat_id VARCHAR(50),
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE silver_crm_sales_details (
    sls_ord_num  varchar(50),
    sls_prd_key  varchar(50),
    sls_cust_id  int,
    sls_order_dt date,
    sls_ship_dt  date,
    sls_due_dt   date,
    sls_sales    int,
    sls_quantity int,
    sls_price    int,
    dwh_create_date Datetime Default CURRENT_TIMESTAMP
);

CREATE TABLE silver_erp_loc_a101 (
    cid    varchar(50),
    cntry  varchar(50),
    dwh_create_date Datetime Default CURRENT_TIMESTAMP
);

CREATE TABLE silver_erp_cust_az12 (
    cid    varchar(50),
    bdate  DATE,
    gen    varchar(50),
    dwh_create_date Datetime Default CURRENT_TIMESTAMP
);

CREATE TABLE silver_erp_px_cat_g1v2 (
    id varchar(50),
    cat varchar(50),
    subcat varchar(50),
    maintenance varchar(50),
    dwh_create_date Datetime Default CURRENT_TIMESTAMP
);

create view gold_dim_customers as
select 
	row_number() over (order by cst_id) as customer_key,
	ci.cst_id as Customer_id,
	ci.cst_key as Customer_Number,
	ci.cst_firstname as Firstname,
	ci.cst_lastname as Lastname,
    la.cntry as Country,
    ci.cst_marital_status as Marital_status,
    case when ci.cst_gndr != 'n/a' then ci.cst_gndr -- CRM is the master table 
         else coalesce (ca.gen, 'n/a')
	end as Gender,
    ca.bdate as Birthdate,
	ci.cst_create_date as Create_Date
from silver_crm_cust_info ci
left join silver_erp_cust_az12 ca
on ci.cst_key=ca.cid
left join silver_erp_loc_a101 la
on  ci.cst_key=la.cid;

-- Product Dimensions Create
create view gold_dim_products as 
select 
row_number() over (order by pn.prd_start_dt, pn.prd_key) as product_key,
pn.prd_id as Product_id,
pn.prd_key as Product_Number,
pn.prd_nm as Product_Name,
pn.cat_id as Category_Id,
pc.cat as Category,
pc.subcat as SubCategory,
pc.maintenance,
pn.prd_cost as Cost,
pn.prd_line as Product_line,
pn.prd_start_dt as Start_date
from silver_crm_prd_info  pn
left join silver_erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
where prd_end_dt is NULL; -- FIlter out historical data


-- Create fact sales
create view gold_fact_sales as
select 
sd.sls_ord_num as Order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as Order_date,
sd.sls_ship_dt as Shipping_date,
sd.sls_due_dt as Due_date,
sd.sls_sales as Sales_amount,
sd.sls_quantity,
sd.sls_price as Price
from silver_crm_sales_details sd
left join gold_dim_products pr
on sd.sls_prd_key=pr.Product_Number
left join gold_dim_customers cu
on sd.sls_cust_id=cu.Customer_id


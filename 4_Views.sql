-- Create a view to see what product categories are the most profitable

create secure view profit_avgs
as
select
productcategory,
avg(productprofitmarginunitpercent) as avg
from  dim_product
group by productcategory
order by avg desc

select * from profit_avgs
drop view profit_avgs

-- Create views for each existing DIM and FACT table that contain all their contents


create secure view v_dim_channel
as
select
dimchannelid,
channelid,
channelcategoryid,
channelname,
channelcategory
from dim_channel

create secure view v_dim_customer
as
select
dimcustomerid,
dimlocationid,
customerid,
customerfullname,
customerfirstname,
customerlastname,
customergender
from dim_customer

create secure view v_dim_date
as
select
date_pkey,
date,
full_date_desc,
day_num_in_week,
day_num_in_month,
day_num_in_year,
day_name,
day_abbrev,
weekday_ind,
us_holiday_ind,
_holiday_ind,
month_end_ind,
week_begin_date_nkey,
week_begin_date,
week_end_date_nkey,
week_end_date,
week_num_in_year,
month_name,
month_abbrev,
month_num_in_year,
yearmonth,
quarter,
yearquarter,
year,
fiscal_week_num,
fiscal_month_num,
fiscal_yearmonth,
fiscal_quarter,
fiscal_yearquarter,
fiscal_halfyear,
fiscal_year,
sql_timestamp,
current_row_ind,
effective_date,
expiration_date
from dim_date

create secure view v_dim_location
as
select
dimlocationid,
address,
city,
postalcode,
state_province,
country
from dim_location



create secure view v_dim_product
as
select
dimproductid,
productid,
producttypeid,
productcategoryid,
productname,
producttype,
productcategory,
productretailprice,
productwholesaleprice,
productcost,
productretailprofit,
productwholesaleunitprofit,
productprofitmarginunitpercent
from dim_product


create secure view v_dim_reseller
as
select
dimresellerid,
dimlocationid,
resellerid,
resellername,
contactname,
phonenumber,
email
from dim_reseller

create secure view v_dim_store
as
select
dimstoreid,
dimlocationid,
sourcestoreid,
storename,
storenumber,
storemanager
from dim_store


create secure view v_fact_productsalestarget
as
select
dimproductid,
dimtargetdateid,
producttargetsalesquantity
from fact_productsalestarget


create secure view v_fact_salesactual
as
select
dimproductid,
dimstoreid,
dimresellerid,
dimcustomerid,
dimchannelid,
dimsaledateid,
dimlocationid,
salesheaderid,
salesdetailid,
salesamount,
salesquantity,
saleunitprice,
saleextendedcost,
saletotalprofit
from fact_salesactual


create secure view v_fact_srcsalestarget
as
select
dimstoreid,
dimresellerid,
dimchannelid,
dimtargetdateid,
salestargetamount
from fact_srcsalestarget



-- create secure view v_daily_quantities
-- as
-- select distinct
-- dim_date.full_date_desc,
-- fact_salesactual.salesquantity,
-- dim_product.productname,
-- dim_store.storename
-- from fact_salesactual
-- inner join dim_date on dim_date.date_pkey = fact_salesactual.dimsaledateid
-- inner join dim_product on dim_product.dimproductid = fact_salesactual.dimproductid
-- inner join dim_store on dim_store.dimstoreid = fact_salesactual.dimstoreid
-- where dim_store.dimstoreid = 4 or dim_store.dimstoreid = 2
-- order by salesquantity desc

-- Create a view to see what each product's target sales quantity is for each year

create secure view v_yearly_product_targets
as
select distinct
dim_date.year as "Target Sales Year",
fact_productsalestarget.producttargetsalesquantity,
dim_product.productname
from fact_productsalestarget
inner join dim_date on dim_date.date_pkey = fact_productsalestarget.dimtargetdateid
inner join dim_product on dim_product.dimproductid = fact_productsalestarget.dimproductid
order by productname



-- Create a view to see what each store's target sales amount is for each year



create secure view v_yearly_seller_targets
as
select distinct
dim_date.year as "Target Sales Year",
dim_store.storename,
fact_srcsalestarget.salestargetamount
from fact_srcsalestarget
inner join dim_date on dim_date.date_pkey = fact_srcsalestarget.dimtargetdateid
inner join dim_store on dim_store.dimstoreid = fact_srcsalestarget.dimstoreid
where storename = 'Store Number 10' or storename = 'Store Number 21'
order by storename

-- Create a view to see how much of each product each store is selling each year


create secure view v_yearly_sales
as
select distinct
dim_date.year,
sum(fact_salesactual.salesquantity) as "Yearly Sales Quantity",
dim_product.productname,
dim_store.storename
from fact_salesactual
inner join dim_date on dim_date.date_pkey = fact_salesactual.dimsaledateid
inner join dim_product on dim_product.dimproductid = fact_salesactual.dimproductid
inner join dim_store on dim_store.dimstoreid = fact_salesactual.dimstoreid
where dim_store.dimstoreid = 4 or dim_store.dimstoreid = 2
group by dim_date.year, dim_product.productname, dim_store.storename -- you always have to group by whatever isn't in your aggregate (the sum)
order by productname


-- Create a view to see how the profits from each store compare to the target sales amounts



create secure view v_sales_comparisons
as
select
sum((v_yearly_sales."Yearly Sales Quantity")*dim_product.productretailprofit) as "Sales Profits",
v_yearly_seller_targets.*
from v_yearly_seller_targets
inner join v_yearly_sales on v_yearly_sales.storename = v_yearly_seller_targets.storename
and v_yearly_seller_targets."Target Sales Year" = v_yearly_sales.year
inner join dim_product on dim_product.productname = v_yearly_sales.productname
group by v_yearly_seller_targets."Target Sales Year", v_yearly_seller_targets.storename, v_yearly_seller_targets.salestargetamount



-- Create a view to see what the percentage of actual sales compared to the target sales to determine which store could be closed

select * from v_pcts

create secure view v_pcts
as
select
(sum("Sales Profits") / sum(v_yearly_seller_targets.salestargetamount)) * 100 as "Percentage",
v_sales_comparisons.*
from v_sales_comparisons
inner join v_yearly_seller_targets on v_yearly_seller_targets.storename = v_sales_comparisons.storename
group by v_sales_comparisons."Target Sales Year", v_sales_comparisons.storename, v_sales_comparisons."Sales Profits", V_SALES_COMPARISONS.SALESTARGETAMOUNT


-- Create a view to see the average product profit margin unit percentage compared to actual sales

create secure view v_profits
as
select
dim_product.PRODUCTPROFITMARGINUNITPERCENT,
fact_salesactual.*
from fact_salesactual
inner join dim_product on dim_product.dimproductid = fact_salesactual.dimproductid
where dimstoreid = 4 or dimstoreid = 2



-- Create a view to see the average product profit margin unit percentage of sales from each store to determine how to maximize profits next year

create secure view v_avg_profits
as
select
avg(v_profits.PRODUCTPROFITMARGINUNITPERCENT) as "Average Profit Margin",
dim_date.year,
dim_store.storename,
from v_profits
inner join dim_date on dim_date.date_pkey = v_profits.dimsaledateid
inner join dim_store on dim_store.dimstoreid = v_profits.dimstoreid
group by dim_date.year, dim_store.storename


-- Create a view to total the percentages

create secure view v_bonus
as
select
sum(v_pcts."Percentage") as "Total Performance",
from v_pcts
where "Target Sales Year" = 2013

-- Add a year dimension to compare potential bonuses for 2013 and 2014

create or replace secure view v_bonus2 as
select
    "Target Sales Year" as year,
    sum("Percentage") as "Total Performance"
from v_pcts
group by "Target Sales Year";


-- Create a view to see how much of a $2,000,000 bonus should be awarded to each store based on 2013 numbers



create secure view v_bonus_allocations
as
select
    v_pcts.storename,
    v_pcts."Percentage",
    (select "Total Performance" from v_bonus) as "Total Performance", -- We can't use the total before it's created, so we pull it with a subquery.
    (v_pcts."Percentage" / (select "Total Performance" from v_bonus)) as "Share",
    ((v_pcts."Percentage" / (select "Total Performance" from v_bonus)) * 2000000) as "Bonus Allocation from $2M"
from v_pcts
where v_pcts."Target Sales Year" = 2013;


create secure view v_bonus_allocations2 as
select
    v_pcts.storename,
    v_pcts."Target Sales Year" as year,
    v_pcts."Percentage",
    b."Total Performance",
    (v_pcts."Percentage" / b."Total Performance") as "Share",
    (v_pcts."Percentage" / b."Total Performance") * 2000000
        as "Bonus Allocation from $2M"
from v_pcts
join v_bonus2 b
  on b.year = v_pcts."Target Sales Year";

select * from v_bonus_allocations2

-- Create a view to compare sales by days of the week

create secure view v_day_sales
as
select -- you can never do select distinct with an aggregate
dim_product.productname,
dim_date.day_name,
dim_date.year,
dim_store.storename,
sum(fact_salesactual.salesquantity) as "Daily Sales" -- always name your aggregate
from fact_salesactual
inner join dim_product on dim_product.dimproductid = fact_salesactual.dimproductid
inner join dim_date on dim_date.date_pkey = fact_salesactual.dimsaledateid
inner join dim_store on dim_store.dimstoreid = fact_salesactual.dimstoreid
where fact_salesactual.dimstoreid = 4 or fact_salesactual.dimstoreid = 2
group by dim_product.productname, dim_date.day_name, dim_store.storename, dim_date.year
order by "Daily Sales" desc

drop view v_day_sales
select * from v_day_sales

-- create a view to see daily averages

create secure view v_day_totals
as
select
v_day_sales.day_name,
v_day_sales.storename,
v_day_sales.year,
avg(v_day_sales."Daily Sales") as "Daily Average"
from v_day_sales
--inner join dim_date on dim_date.day_name = v_day_sales.day_name
group by v_day_sales.day_name, v_day_sales.storename, v_day_sales.year
order by "Daily Average" desc



-- create a view to see sales by location

create secure view v_location_sales
as
select
sum(fact_salesactual.saletotalprofit) as "Total Store Profits",
dim_store.storename,
dim_location.city,
dim_location.state_province,
--dim_reseller.resellername,
dim_date.year
from fact_salesactual
inner join dim_store on dim_store.dimstoreid = fact_salesactual.dimstoreid
inner join dim_location on dim_location.dimlocationid = fact_salesactual.dimlocationid
--left join dim_reseller on dim_reseller.dimresellerid = fact_salesactual.dimresellerid
inner join dim_date on dim_date.date_pkey = fact_salesactual.dimsaledateid
where fact_salesactual.dimstoreid <> -1
group by dim_store.storename, dim_location.city, dim_location.state_province, dim_date.year --,dim_reseller.resellername,
order by "Total Store Profits" desc


drop view v_location_sales
select * from   v_location_sales

-- Create a view to see best sellers by product category

create secure view v_category_sales
as
select
dim_product.productcategory,
sum(fact_salesactual.saletotalprofit) as "Total Profit",
dim_date.year,
dim_store.storename
from fact_salesactual
inner join dim_product on dim_product.dimproductid = fact_salesactual.dimproductid
inner join dim_store on dim_store.dimstoreid = fact_salesactual.dimstoreid
inner join dim_date on dim_date.date_pkey = fact_salesactual.dimsaledateid
where fact_salesactual.dimstoreid = 4 or fact_salesactual.dimstoreid = 2
group by dim_product.productcategory, dim_date.year, dim_store.storename
order by "Total Profit" desc

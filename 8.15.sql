

-- create fact table with foreign keys referencing dim tables

create table fact_productsalestarget(
DimProductID INT references Dim_Product(dimproductID),
DimTargetDateID Number(9) references dim_date(Date_Pkey),
ProductTargetSalesQuantity INT NOT NULL);

insert into fact_productsalestarget(
DimProductID,
DimTargetDateID,
ProductTargetSalesQuantity
)

select
NVL(dim_product.dimproductID,-1) as DimProductID, --We had to add NVLs here to ensure that the values would never be null, breaking referential integrity. Instead of null, it would populate -1.
NVL(dim_date.Date_Pkey,-1) as DimTargetDateID,
stage_target_data_product.sales_quantity_target

-- join from separate dim tables to form fact tables

from stage_target_data_product
inner join dim_product on stage_target_data_product.product_id = dim_product.productid
left join dim_date  on dim_date.year = stage_target_data_product.year
   and dim_date.month_num_in_year = 1
   and dim_date.day_num_in_month = 1 -- We had to join on Jan 1st; joining on just Year gives us 365 rows for each year



create table Fact_SRCSalesTarget(
DimStoreID INT references Dim_Store(DimstoreID),
DimResellerID INT references Dim_Reseller(DimResellerID),
DimChannelID INT references Dim_Channel(DimChannelID),
DimTargetDateID number(9) references Dim_Date(Date_PKey),
SalesTargetAmount FLOAT NOT NULL);

insert into Fact_SRCSalesTarget(
DimstoreID,
DimResellerID,
DimChannelID,
DimTargetDateID,
SalesTargetAmount)



-- use outer joins because some of these values are mutually exclusive and we want to include everything
select
NVL(Dim_store.DimstoreID,    -1) as DimStoreID,
NVL(Dim_Reseller.DimresellerID, -1) as DimResellerID,
NVL(Dim_Channel.DimChannelID,   -1) as DimChannelID,
NVL(Dim_Date.Date_PKey,      -1) as DimTargetDateID,
STAGE_TARGET_DATA_CHANNEL.Target_Sales_Amount
from stage_target_data_channel
inner join dim_channel on lower(replace(dim_channel.ChannelName, '-', '')) = lower(replace(stage_target_data_channel.Channel_Name, '-', '')) -- cleans up naming inconsistencies
left join dim_date  on dim_date.year = stage_target_data_channel.year
   and dim_date.month_num_in_year = 1
   and dim_date.day_num_in_month = 1
left outer join dim_reseller on dim_reseller.resellername = stage_target_data_channel.target_name -- cleans up naming inconsistencies
LEFT JOIN Dim_Store
    ON
    (CASE
        WHEN Stage_Target_Data_Channel.Target_Name = 'Store Number 5' Then '5'
        WHEN Stage_Target_Data_Channel.Target_Name = 'Store Number 8' Then '8'
        WHEN Stage_Target_Data_Channel.Target_Name = 'Store Number 10' Then '10'
        WHEN Stage_Target_Data_Channel.Target_Name = 'Store Number 21' Then '21'
        WHEN Stage_Target_Data_Channel.Target_Name = 'Store Number 34' Then '34'
        WHEN Stage_Target_Data_Channel.Target_Name = 'Store Number 39' Then '39'
        ELSE Stage_Target_Data_Channel.Target_Name
        END) = CAST(Dim_Store.StoreNumber AS VARCHAR(255))




create table fact_salesactual(
DimProductID INT references Dim_Product(DimProductID),
DimStoreID INT references Dim_Store(DimstoreID),
DimResellerID INT references Dim_Reseller(DimResellerID),
DimCustomerID INT references Dim_Customer(DimCustomerID),
DimChannelID INT references Dim_Channel(DimChannelID),
DimSaleDateID Number(9) references Dim_Date(Date_Pkey),
DimLocationID INT references Dim_Location(DimLocationID),
SalesHeaderID INT,
SalesDetailID INT NOT NULL,
SalesAmount INT NOT NULL,
SalesQuantity INT NOT NULL,
SaleUnitPrice FLOAT NOT NULL,
SaleExtendedCost FLOAT NOT NULL,
SaleTotalProfit FLOAT NOT NULL
);


insert into fact_salesactual(
DimProductID,
DimstoreID,
DimResellerID,
DimCustomerID,
DimChannelID,
DimSaleDateID,
DimLocationID,
SalesHeaderID,
SalesDetailID,
SalesAmount,
SalesQuantity,
SaleUnitPrice,
SaleExtendedCost,
SaleTotalProfit)

-- if tables don't directly connect via joins we have to add "another link in the chain" so to speak, eg., stage_sales_header, even though that's not the one we are directly joining from



select
NVL(Dim_Product.DimProductID,      -1) as DimProductID,
NVL(Dim_Store.DimstoreID,          -1) as DimStoreID,
NVL(Dim_Reseller.DimResellerID,    -1) as DimResellerID,
NVL(Dim_Customer.DimCustomerID,    -1) as DimCustomerID,
NVL(Dim_Channel.DimChannelID,      -1) as DimChannelID,
NVL(Dim_Date.Date_Pkey,            -1) as DimSaleDateID,
NVL(
    COALESCE(
        Dim_Store.DimLocationID,
        Dim_Reseller.DimLocationID,
        Dim_Customer.DimLocationID
    ),
    -1 -- Coalesce is used to check whether a value is null, and if so, proceed to the next value
) as DimLocationID,
stage_sales_header.sales_header,
stage_sales_detail.sales_detail_ID,
stage_sales_detail.sales_amount,
stage_sales_detail.sales_quantity,
(stage_sales_detail.sales_amount)/(stage_sales_detail.sales_quantity),
(dim_product.productcost)*(stage_sales_detail.sales_quantity),
(stage_sales_detail.sales_amount) - ((dim_product.productcost)*(stage_sales_detail.sales_quantity))
from stage_sales_detail
inner join stage_sales_header on stage_sales_detail.sales_header = stage_sales_header.sales_header
left outer join dim_product on dim_product.productid = stage_sales_detail.product_id
left outer join dim_customer on dim_customer.customerid = stage_sales_header.customer_id
left outer join dim_reseller on dim_reseller.resellerid = stage_sales_header.reseller_id
left outer join dim_store on dim_store.sourcestoreid = stage_sales_header.store_id
left outer join dim_channel on dim_channel.channelid = stage_sales_header.channel_id
left join dim_date on dim_date.date = TO_DATE(stage_sales_header.date, 'MM/DD/YY')
-- we have to convert the date format to match, the other fact tables were easier since the staging tables had a year column

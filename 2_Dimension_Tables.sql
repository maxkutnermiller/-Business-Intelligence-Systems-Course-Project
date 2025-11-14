
-- create dim table with primary key

create table dim_location (
    DimLocationID INT IDENTITY(1,1) CONSTRAINT PK_dim_location PRIMARY KEY NOT NULL,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(255) NOT NULL,
    PostalCode INT NOT NULL,
    State_Province VARCHAR(255) NOT NULL,
    Country VARCHAR(255) NOT NULL
);


insert into dim_location (
    DimLocationID,
    Address,
    City,
    PostalCode,
    State_Province,
    Country
)
values (
    -1,
    'Unknown',
    'Unknown',
    -1,
    'Unknown',
    'Unknown'
);


insert into dim_location (
    Address,
    City,
    PostalCode,
    State_Province,
    Country
)
select distinct
    Address,
    City,
    Postal_Code as PostalCode,
    StateProvince as State_Province,
    Country
from (
    select Address, City, Postal_Code, StateProvince, Country from stage_customer
    -- Add each identifier individually so we don't get duplicates and account for places that might have identical addreses for example
    union all
    select Address, City, Postal_Code, StateProvince, Country from stage_store
    union all
    select Address, City, Postal_Code, StateProvince, Country from stage_reseller
) as Combined;


create table dim_store(
    DimStoreID INT IDENTITY (1,1) CONSTRAINT PK_dimstoreID PRIMARY KEY NOT NULL,
    DimLocationID INT REFERENCES dim_location(DimLocationID),
    SourceStoreID INT NOT NULL,
    StoreName Varchar (255) NOT NULL,
    StoreNumber INT NOT NULL,
    StoreManager Varchar (255) NOT NULL
);

insert into dim_store(
    DimStoreID,
    DimLocationID,
    SourceStoreID,
    StoreName,
    StoreNumber,
    StoreManager
)

Values(
    -1,
    -1,
    -1,
    'Unknown',
    -1,
    'Unknown'
);



insert into dim_store(
    DimLocationID,
    SourceStoreID,
    StoreName,
    StoreNumber,
    StoreManager
)

-- Since dim tables need combined data from CSVs, we use joins to combine rows from separate staging tables

    Select
    dim_location.dimlocationID as DimLocationID,
    STORE_ID as SourceStoreID,
    'Store Number ' || store_number as StoreName,
    STORE_NUMBER as StoreNumber,
    STORE_MANAGER as Storemanager
    from stage_store
    inner join dim_location on dim_location.address = stage_store.address
    and dim_location.city=stage_store.city
    and dim_location.postalcode=stage_store.postal_code
    and dim_location.state_province=stage_store.stateprovince
    and dim_location.country=stage_store.country




create table dim_reseller(
    DimResellerID INT IDENTITY(1,1) CONSTRAINT PK_DimResellerID PRIMARY KEY NOT NULL,
    DimLocationID INT REFERENCES dim_location(DimLocationID),
    ResellerID Varchar(255)  NOT NULL,
    ResellerName Varchar(255)  NOT NULL,
    ContactName Varchar(255) NOT NULL,
    PhoneNumber Varchar (255)  NOT NULL,
    Email Varchar (255)  NOT NULL
);


insert into dim_reseller(
    DimResellerID,
    DimLocationID,
    ResellerID,
    ResellerName,
    ContactName,
    PhoneNumber,
    Email)

Values(
    -1,
    -1,
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown'
);


insert into dim_reseller(
    DimLocationID,
    ResellerID,
    ContactName,
    ResellerName,
    Email,
    PhoneNumber)

    SELECT
    dim_location.dimlocationID as DimLocationID,
    RESELLER_ID as ResellerID,
    Contact as ContactName,
    stage_reseller.Reseller_Name as ResellerName,
    Email_Address as Email,
    Phone_Number as PhoneNumber
    from stage_reseller
    inner join dim_location on dim_location.address = stage_reseller.address
    and dim_location.city=stage_reseller.city
    and dim_location.postalcode=stage_reseller.postal_code
    and dim_location.state_province=stage_reseller.stateprovince
    and dim_location.country=stage_reseller.country


create table dim_customer(
    DimCustomerID INT IDENTITY(1,1) CONSTRAINT PK_DimCustomerID PRIMARY KEY NOT NULL,
    DimLocationID INT References dim_location(DimLocationID),
    CustomerID Varchar (255) NOT NULL,
    CustomerFullName Varchar (255) NOT NULL,
    CustomerFirstName Varchar (255)  NOT NULL,
    CustomerLastName Varchar (255)  NOT NULL,
    CustomerGender Varchar (255) NOT NULL

);

insert into dim_customer(
    DimCustomerID,
    DimLocationID,
    CustomerID,
    CustomerFullName,
    CustomerFirstName,
    CustomerLastName,
    CustomerGender
)
Values(
    -1,
    -1,
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown',
    'Unknown'
);


insert into dim_customer(
    DimLocationID,
    CustomerID,
    CustomerFullName,
    CustomerFirstName,
    CustomerLastName,
    CustomerGender)

    Select distinct -- selecting Distinct here to eliminate duplicate customer IDs
    dim_location.dimlocationID as DimLocationID,
    Customer_ID as CustomerID,
    FirstName || ' ' || LastName AS CustomerFullName,
    Firstname as CustomerFirstName,
    LastName as CustomerLastName,
    Gender as CustomerGender,
    from stage_customer
    inner join dim_location on stage_customer.address=dim_location.address
    and dim_location.city=stage_customer.city
    and dim_location.postalcode=stage_customer.postal_code
    and dim_location.state_province=stage_customer.stateprovince
    and dim_location.country=stage_customer.country



create table dim_channel(
    DimChannelID INT IDENTITY (1,1) CONSTRAINT PK_DimChannelID PRIMARY KEY NOT NULL,
    ChannelID INT NOT NULL,
    ChannelCategoryID INT NOT NULL,
    ChannelName Varchar (255) NOT NULL,
    ChannelCategory Varchar (255) NOT NULL
);

insert into dim_channel(
    DimChannelID,
    ChannelID,
    ChannelCategoryID,
    ChannelName,
    ChannelCategory)

Values(
    -1,
    -1,
    -1,
    'Unknown',
    'Unknown'
    );


insert into dim_channel (
    ChannelID,
    ChannelCategoryID,
    ChannelName,
    ChannelCategory
)
select
    sc.channel_id as ChannelID,
    sc.channel_category_id as ChannelCategoryID,
    sc.channel as ChannelName,
    scc.channel_category as ChannelCategory
from stage_channel as sc
inner join stage_channel_category as scc
    on sc.channel_category_id = scc.channel_category_id;




create table dim_product (
    DimProductID INT IDENTITY (1,1) CONSTRAINT PK_DimProductID PRIMARY KEY NOT NULL,
    ProductID INT  NOT NULL,
    ProductTypeID INT  NOT NULL,
    ProductCategoryID INT  NOT NULL,
    ProductName Varchar (255)  NOT NULL,
    ProductType Varchar (255) NOT NULL,
    ProductCategory Varchar (255) NOT NULL,
    ProductRetailPrice FLOAT  NOT NULL,
    ProductWholesalePrice FLOAT  NOT NULL,
    ProductCost FLOAT  NOT NULL,
    ProductRetailProfit FLOAT  NOT NULL,
    ProductWholesaleUnitProfit FLOAT  NOT NULL,
    ProductProfitMarginUnitPercent FLOAT  NOT NULL
    );

insert into dim_product(
    DimProductID,
    ProductID,
    ProductTypeID,
    ProductCategoryID,
    ProductName,
    ProductType,
    ProductCategory,
    ProductRetailPrice,
    ProductWholesalePrice,
    ProductCost,
    ProductRetailProfit,
    ProductWholesaleUnitProfit,
    ProductProfitMarginUnitPercent
)
Values (
    -1,
    -1,
    -1,
    -1,
    'Unknown',
    'Unknown',
    'Unknown',
    -1,
    -1,
    -1,
    -1,
    -1,
    -1
);


insert into dim_product(
    ProductID,
    ProductTypeID,
    ProductCategoryID,
    ProductName,
    ProductType,
    ProductCategory,
    ProductRetailPrice,
    ProductWholesalePrice,
    ProductCost,
    ProductRetailProfit,
    ProductWholesaleUnitProfit,
    ProductProfitMarginUnitPercent
)

-- Need aliases to keep separate values from getting confused

    Select
    sp.Product_ID as ProductID,
    sp.Product_TYPE as ProductTypeID,
    sc.Product_Category_ID as ProductCategoryID,
    sp.Product as ProductName,
    st.Product_Type as ProductType,
    sc.Product_Category as ProductCategory,
    sp.Price as ProductRetailPrice,
    sp.Wholesale_Price as ProductWholesalePrice,
    sp.Cost as ProductCost,
    (sp.Price - sp.Cost) as ProductRetailProfit,
    (sp.Wholesale_Price - sp.Cost) as ProductWholesaleUnitProfit,
    ((sp.price-sp.cost)/sp.price) * 100 as ProductProfitMarginUnitPercent -- multiply by 100 to convert to a true percentage
    from stage_product as sp
    inner join stage_product_type as st on st.Product_Type_ID = sp.Product_Type
    inner join stage_product_category sc on sc.Product_Category_ID = st.Product_Category_ID

select * from dim_product


-- Date table was provided by professor


Create or replace table DIM_DATE (
	DATE_PKEY				number(9) PRIMARY KEY,
	DATE					date not null,
	FULL_DATE_DESC			varchar(64) not null,
	DAY_NUM_IN_WEEK			number(1) not null,
	DAY_NUM_IN_MONTH		number(2) not null,
	DAY_NUM_IN_YEAR			number(3) not null,
	DAY_NAME				varchar(10) not null,
	DAY_ABBREV				varchar(3) not null,
	WEEKDAY_IND				varchar(64) not null,
	US_HOLIDAY_IND			varchar(64) not null,
	/*<COMPANYNAME>*/_HOLIDAY_IND varchar(64) not null,
	MONTH_END_IND			varchar(64) not null,
	WEEK_BEGIN_DATE_NKEY		number(9) not null,
	WEEK_BEGIN_DATE			date not null,
	WEEK_END_DATE_NKEY		number(9) not null,
	WEEK_END_DATE			date not null,
	WEEK_NUM_IN_YEAR		number(9) not null,
	MONTH_NAME				varchar(10) not null,
	MONTH_ABBREV			varchar(3) not null,
	MONTH_NUM_IN_YEAR		number(2) not null,
	YEARMONTH				varchar(10) not null,
	QUARTER					number(1) not null,
	YEARQUARTER				varchar(10) not null,
	YEAR					number(5) not null,
	FISCAL_WEEK_NUM			number(2) not null,
	FISCAL_MONTH_NUM		number(2) not null,
	FISCAL_YEARMONTH		varchar(10) not null,
	FISCAL_QUARTER			number(1) not null,
	FISCAL_YEARQUARTER		varchar(10) not null,
	FISCAL_HALFYEAR			number(1) not null,
	FISCAL_YEAR				number(5) not null,
	SQL_TIMESTAMP			timestamp_ntz,
	CURRENT_ROW_IND			char(1) default 'Y',
	EFFECTIVE_DATE			date default to_date(current_timestamp),
	EXPIRATION_DATE			date default To_date('9999-12-31')
)
comment = 'Type 0 Dimension Table Housing Calendar and Fiscal Year Date Attributes';

-- Populate data into DIM_DATE
insert into DIM_DATE
select DATE_PKEY,
		DATE_COLUMN,
        FULL_DATE_DESC,
		DAY_NUM_IN_WEEK,
		DAY_NUM_IN_MONTH,
		DAY_NUM_IN_YEAR,
		DAY_NAME,
		DAY_ABBREV,
		WEEKDAY_IND,
		US_HOLIDAY_IND,
        COMPANY_HOLIDAY_IND,
		MONTH_END_IND,
		WEEK_BEGIN_DATE_NKEY,
		WEEK_BEGIN_DATE,
		WEEK_END_DATE_NKEY,
		WEEK_END_DATE,
		WEEK_NUM_IN_YEAR,
		MONTH_NAME,
		MONTH_ABBREV,
		MONTH_NUM_IN_YEAR,
		YEARMONTH,
		CURRENT_QUARTER,
		YEARQUARTER,
		CURRENT_YEAR,
		FISCAL_WEEK_NUM,
		FISCAL_MONTH_NUM,
		FISCAL_YEARMONTH,
		FISCAL_QUARTER,
		FISCAL_YEARQUARTER,
		FISCAL_HALFYEAR,
		FISCAL_YEAR,
		SQL_TIMESTAMP,
		CURRENT_ROW_IND,
		EFFECTIVE_DATE,
		EXPIRA_DATE
	from


    --( select to_date('01-25-2019 23:25:11.120','MM-DD-YYYY HH24:MI:SS.FF') as DD, /*<<Modify date for preferred table start date*/
    --( select to_date('2013-01-01 00:00:01','YYYY-MM-DD HH24:MI:SS') as DD, /*<<Modify date for preferred table start date*/
	  ( select to_date('2012-12-31 23:59:59','YYYY-MM-DD HH24:MI:SS') as DD, /*<<Modify date for preferred table start date*/
			seq1() as Sl,row_number() over (order by Sl) as row_numbers,
			dateadd(day,row_numbers,DD) as V_DATE,
			case when date_part(dd, V_DATE) < 10 and date_part(mm, V_DATE) > 9 then
				date_part(year, V_DATE)||date_part(mm, V_DATE)||'0'||date_part(dd, V_DATE)
				 when date_part(dd, V_DATE) < 10 and  date_part(mm, V_DATE) < 10 then
				 date_part(year, V_DATE)||'0'||date_part(mm, V_DATE)||'0'||date_part(dd, V_DATE)
				 when date_part(dd, V_DATE) > 9 and  date_part(mm, V_DATE) < 10 then
				 date_part(year, V_DATE)||'0'||date_part(mm, V_DATE)||date_part(dd, V_DATE)
				 when date_part(dd, V_DATE) > 9 and  date_part(mm, V_DATE) > 9 then
				 date_part(year, V_DATE)||date_part(mm, V_DATE)||date_part(dd, V_DATE) end as DATE_PKEY,
			V_DATE as DATE_COLUMN,
			dayname(dateadd(day,row_numbers,DD)) as DAY_NAME_1,
			case
				when dayname(dateadd(day,row_numbers,DD)) = 'Mon' then 'Monday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Tue' then 'Tuesday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Wed' then 'Wednesday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Thu' then 'Thursday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Fri' then 'Friday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Sat' then 'Saturday'
				when dayname(dateadd(day,row_numbers,DD)) = 'Sun' then 'Sunday' end ||', '||
			case when monthname(dateadd(day,row_numbers,DD)) ='Jan' then 'January'
				   when monthname(dateadd(day,row_numbers,DD)) ='Feb' then 'February'
				   when monthname(dateadd(day,row_numbers,DD)) ='Mar' then 'March'
				   when monthname(dateadd(day,row_numbers,DD)) ='Apr' then 'April'
				   when monthname(dateadd(day,row_numbers,DD)) ='May' then 'May'
				   when monthname(dateadd(day,row_numbers,DD)) ='Jun' then 'June'
				   when monthname(dateadd(day,row_numbers,DD)) ='Jul' then 'July'
				   when monthname(dateadd(day,row_numbers,DD)) ='Aug' then 'August'
				   when monthname(dateadd(day,row_numbers,DD)) ='Sep' then 'September'
				   when monthname(dateadd(day,row_numbers,DD)) ='Oct' then 'October'
				   when monthname(dateadd(day,row_numbers,DD)) ='Nov' then 'November'
				   when monthname(dateadd(day,row_numbers,DD)) ='Dec' then 'December' end
				   ||' '|| to_varchar(dateadd(day,row_numbers,DD), ' dd, yyyy') as FULL_DATE_DESC,
			dateadd(day,row_numbers,DD) as V_DATE_1,
			dayofweek(V_DATE_1)+1 as DAY_NUM_IN_WEEK,
			Date_part(dd,V_DATE_1) as DAY_NUM_IN_MONTH,
			dayofyear(V_DATE_1) as DAY_NUM_IN_YEAR,
			case
				when dayname(V_DATE_1) = 'Mon' then 'Monday'
				when dayname(V_DATE_1) = 'Tue' then 'Tuesday'
				when dayname(V_DATE_1) = 'Wed' then 'Wednesday'
				when dayname(V_DATE_1) = 'Thu' then 'Thursday'
				when dayname(V_DATE_1) = 'Fri' then 'Friday'
				when dayname(V_DATE_1) = 'Sat' then 'Saturday'
				when dayname(V_DATE_1) = 'Sun' then 'Sunday' end as	DAY_NAME,
			dayname(dateadd(day,row_numbers,DD)) as DAY_ABBREV,
			case
				when dayname(V_DATE_1) = 'Sun' and dayname(V_DATE_1) = 'Sat' then
                 'Not-Weekday'
				else 'Weekday' end as WEEKDAY_IND,
			 case
				when (DATE_PKEY = date_part(year, V_DATE)||'0101' or DATE_PKEY = date_part(year, V_DATE)||'0704' or
				DATE_PKEY = date_part(year, V_DATE)||'1225' or DATE_PKEY = date_part(year, V_DATE)||'1226') then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Wed'
				and dateadd(day,-2,last_day(V_DATE_1)) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Thu'
				and dateadd(day,-3,last_day(V_DATE_1)) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Fri'
				and dateadd(day,-4,last_day(V_DATE_1)) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Sat'
				and dateadd(day,-5,last_day(V_DATE_1)) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Sun'
				and dateadd(day,-6,last_day(V_DATE_1)) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Mon'
				and last_day(V_DATE_1) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='May' and dayname(last_day(V_DATE_1)) = 'Tue'
				and dateadd(day,-1 ,last_day(V_DATE_1)) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Wed'
				and dateadd(day,5,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Thu'
				and dateadd(day,4,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Fri'
				and dateadd(day,3,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Sat'
				and dateadd(day,2,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Sun'
				and dateadd(day,1,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Mon'
				and date_part(year, V_DATE_1)||'-09-01' = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Tue'
				and dateadd(day,6 ,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Wed'
				and (dateadd(day,23,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1  or
					 dateadd(day,22,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Thu'
				and ( dateadd(day,22,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or
					 dateadd(day,21,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Fri'
				and ( dateadd(day,21,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or
					 dateadd(day,20,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				 'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Sat'
				and ( dateadd(day,27,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or
					 dateadd(day,26,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Sun'
				and ( dateadd(day,26,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or
					 dateadd(day,25,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Mon'
				and (dateadd(day,25,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or
					 dateadd(day,24,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Tue'
				and (dateadd(day,24,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 or
					 dateadd(day,23,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 ) then
				 'Holiday'
				else
				'Not-Holiday' end as US_HOLIDAY_IND,
			/*Modify the following for Company Specific Holidays*/
			case
				when (DATE_PKEY = date_part(year, V_DATE)||'0101' or DATE_PKEY = date_part(year, V_DATE)||'0219'
				or DATE_PKEY = date_part(year, V_DATE)||'0528' or DATE_PKEY = date_part(year, V_DATE)||'0704'
				or DATE_PKEY = date_part(year, V_DATE)||'1225' )then
				'Holiday'
                when monthname(V_DATE_1) ='Mar' and dayname(last_day(V_DATE_1)) = 'Fri'
				and last_day(V_DATE_1) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Mar' and dayname(last_day(V_DATE_1)) = 'Sat'
				and dateadd(day,-1,last_day(V_DATE_1)) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Mar' and dayname(last_day(V_DATE_1)) = 'Sun'
				and dateadd(day,-2,last_day(V_DATE_1)) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Tue'
                and dateadd(day,3,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Wed'
				and dateadd(day,2,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Thu'
                and dateadd(day,1,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Fri'
				and date_part(year, V_DATE_1)||'-04-01' = V_DATE_1 then
				'Holiday'
                when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Wed'
				and dateadd(day,5,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Thu'
				and dateadd(day,4,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Fri'
				and dateadd(day,3,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Sat'
				and dateadd(day,2,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Sun'
				and dateadd(day,1,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Mon'
                and date_part(year, V_DATE_1)||'-04-01'= V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Apr' and dayname(date_part(year, V_DATE_1)||'-04-01') = 'Tue'
				and dateadd(day,6 ,(date_part(year, V_DATE_1)||'-04-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Wed'
				and dateadd(day,5,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Thu'
				and dateadd(day,4,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Fri'
				and dateadd(day,3,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Sat'
				and dateadd(day,2,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Sun'
				and dateadd(day,1,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Mon'
                and date_part(year, V_DATE_1)||'-09-01' = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Sep' and dayname(date_part(year, V_DATE_1)||'-09-01') = 'Tue'
				and dateadd(day,6 ,(date_part(year, V_DATE_1)||'-09-01')) = V_DATE_1  then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Wed'
				and dateadd(day,23,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Thu'
				and dateadd(day,22,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Fri'
				and dateadd(day,21,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1  then
				 'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Sat'
				and dateadd(day,27,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Sun'
				and dateadd(day,26,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Mon'
				and dateadd(day,25,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1 then
				'Holiday'
				when monthname(V_DATE_1) ='Nov' and dayname(date_part(year, V_DATE_1)||'-11-01') = 'Tue'
				and dateadd(day,24,(date_part(year, V_DATE_1)||'-11-01')) = V_DATE_1  then
				 'Holiday'
				else
				'Not-Holiday' end as COMPANY_HOLIDAY_IND,
			case
				when last_day(V_DATE_1) = V_DATE_1 then
				'Month-end'
				else 'Not-Month-end' end as MONTH_END_IND,

			case when date_part(mm,date_trunc('week',V_DATE_1)) < 10 and date_part(dd,date_trunc('week',V_DATE_1)) < 10 then
					  date_part(yyyy,date_trunc('week',V_DATE_1))||'0'||
					  date_part(mm,date_trunc('week',V_DATE_1))||'0'||
					  date_part(dd,date_trunc('week',V_DATE_1))
				 when date_part(mm,date_trunc('week',V_DATE_1)) < 10 and date_part(dd,date_trunc('week',V_DATE_1)) > 9 then
						date_part(yyyy,date_trunc('week',V_DATE_1))||'0'||
						date_part(mm,date_trunc('week',V_DATE_1))||date_part(dd,date_trunc('week',V_DATE_1))
				 when date_part(mm,date_trunc('week',V_DATE_1)) > 9 and date_part(dd,date_trunc('week',V_DATE_1)) < 10 then
						date_part(yyyy,date_trunc('week',V_DATE_1))||date_part(mm,date_trunc('week',V_DATE_1))||
						'0'||date_part(dd,date_trunc('week',V_DATE_1))
				when date_part(mm,date_trunc('week',V_DATE_1)) > 9 and date_part(dd,date_trunc('week',V_DATE_1)) > 9 then
						date_part(yyyy,date_trunc('week',V_DATE_1))||
						date_part(mm,date_trunc('week',V_DATE_1))||
						date_part(dd,date_trunc('week',V_DATE_1)) end as WEEK_BEGIN_DATE_NKEY,
			date_trunc('week',V_DATE_1) as WEEK_BEGIN_DATE,

			case when  date_part(mm,last_day(V_DATE_1,'week')) < 10 and date_part(dd,last_day(V_DATE_1,'week')) < 10 then
					  date_part(yyyy,last_day(V_DATE_1,'week'))||'0'||
					  date_part(mm,last_day(V_DATE_1,'week'))||'0'||
					  date_part(dd,last_day(V_DATE_1,'week'))
				 when  date_part(mm,last_day(V_DATE_1,'week')) < 10 and date_part(dd,last_day(V_DATE_1,'week')) > 9 then
					  date_part(yyyy,last_day(V_DATE_1,'week'))||'0'||
					  date_part(mm,last_day(V_DATE_1,'week'))||date_part(dd,last_day(V_DATE_1,'week'))
				 when  date_part(mm,last_day(V_DATE_1,'week')) > 9 and date_part(dd,last_day(V_DATE_1,'week')) < 10  then
					  date_part(yyyy,last_day(V_DATE_1,'week'))||date_part(mm,last_day(V_DATE_1,'week'))||'0'||
					  date_part(dd,last_day(V_DATE_1,'week'))
				 when  date_part(mm,last_day(V_DATE_1,'week')) > 9 and date_part(dd,last_day(V_DATE_1,'week')) > 9 then
					  date_part(yyyy,last_day(V_DATE_1,'week'))||
					  date_part(mm,last_day(V_DATE_1,'week'))||
					  date_part(dd,last_day(V_DATE_1,'week')) end as WEEK_END_DATE_NKEY,
			last_day(V_DATE_1,'week') as WEEK_END_DATE,
			week(V_DATE_1) as WEEK_NUM_IN_YEAR,
			case when monthname(V_DATE_1) ='Jan' then 'January'
				   when monthname(V_DATE_1) ='Feb' then 'February'
				   when monthname(V_DATE_1) ='Mar' then 'March'
				   when monthname(V_DATE_1) ='Apr' then 'April'
				   when monthname(V_DATE_1) ='May' then 'May'
				   when monthname(V_DATE_1) ='Jun' then 'June'
				   when monthname(V_DATE_1) ='Jul' then 'July'
				   when monthname(V_DATE_1) ='Aug' then 'August'
				   when monthname(V_DATE_1) ='Sep' then 'September'
				   when monthname(V_DATE_1) ='Oct' then 'October'
				   when monthname(V_DATE_1) ='Nov' then 'November'
				   when monthname(V_DATE_1) ='Dec' then 'December' end as MONTH_NAME,
			monthname(V_DATE_1) as MONTH_ABBREV,
			month(V_DATE_1) as MONTH_NUM_IN_YEAR,
			case when month(V_DATE_1) < 10 then
			year(V_DATE_1)||'-0'||month(V_DATE_1)
			else year(V_DATE_1)||'-'||month(V_DATE_1) end as YEARMONTH,
			quarter(V_DATE_1) as CURRENT_QUARTER,
			year(V_DATE_1)||'-0'||quarter(V_DATE_1) as YEARQUARTER,
			year(V_DATE_1) as CURRENT_YEAR,
			/*Modify the following based on company fiscal year - assumes Jan 01*/
            to_date(year(V_DATE_1)||'-01-01','YYYY-MM-DD') as FISCAL_CUR_YEAR,
            to_date(year(V_DATE_1) -1||'-01-01','YYYY-MM-DD') as FISCAL_PREV_YEAR,
			case when   V_DATE_1 < FISCAL_CUR_YEAR then
			datediff('week', FISCAL_PREV_YEAR,V_DATE_1)
			else
			datediff('week', FISCAL_CUR_YEAR,V_DATE_1)  end as FISCAL_WEEK_NUM  ,
			decode(datediff('MONTH',FISCAL_CUR_YEAR, V_DATE_1)+1 ,-2,10,-1,11,0,12,
                   datediff('MONTH',FISCAL_CUR_YEAR, V_DATE_1)+1 ) as FISCAL_MONTH_NUM,
			concat( year(FISCAL_CUR_YEAR)
				   ,case when to_number(FISCAL_MONTH_NUM) = 10 or
							to_number(FISCAL_MONTH_NUM) = 11 or
                            to_number(FISCAL_MONTH_NUM) = 12  then
							'-'||FISCAL_MONTH_NUM
					else  concat('-0',FISCAL_MONTH_NUM) end ) as FISCAL_YEARMONTH,
			case when quarter(V_DATE_1) = 4 then 4
				 when quarter(V_DATE_1) = 3 then 3
				 when quarter(V_DATE_1) = 2 then 2
				 when quarter(V_DATE_1) = 1 then 1 end as FISCAL_QUARTER,

			case when   V_DATE_1 < FISCAL_CUR_YEAR then
					year(FISCAL_CUR_YEAR)
					else year(FISCAL_CUR_YEAR)+1 end
					||'-0'||case when quarter(V_DATE_1) = 4 then 4
					 when quarter(V_DATE_1) = 3 then 3
					 when quarter(V_DATE_1) = 2 then 2
					 when quarter(V_DATE_1) = 1 then 1 end as FISCAL_YEARQUARTER,
			case when quarter(V_DATE_1) = 4  then 2 when quarter(V_DATE_1) = 3 then 2
				when quarter(V_DATE_1) = 1  then 1 when quarter(V_DATE_1) = 2 then 1
			end as FISCAL_HALFYEAR,
			year(FISCAL_CUR_YEAR) as FISCAL_YEAR,
			to_timestamp_ntz(V_DATE) as SQL_TIMESTAMP,
			'Y' as CURRENT_ROW_IND,
			to_date(current_timestamp) as EFFECTIVE_DATE,
			to_date('9999-12-31') as EXPIRA_DATE
			--from table(generator(rowcount => 8401)) /*<< Set to generate 20 years. Modify rowcount to increase or decrease size*/
	        from table(generator(rowcount => 730)) /*<< Set to generate 20 years. Modify rowcount to increase or decrease size*/
    )v;

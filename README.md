[![2-Minute Project Breakdown](https://img.youtube.com/vi/VIDEO_ID/maxresdefault.jpg)]([[https://www.youtube.com/watch?v=VIDEO_ID](https://youtu.be/7lbdTC3QQJs)](https://youtu.be/7lbdTC3QQJs))

[View the interactive Tableau dashboard](https://public.tableau.com/views/MaxMillerBISystemsCourseProject/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)


**Overview**

This project implements a dimensional data warehouse for retail sales data. It includes staging, dimension modeling, fact table construction, and analytical views. The warehouse supports analysis of sales performance, profitability, sales targets, store comparisons, and customer behavior.

**Architecture**

Source CSVs were loaded into staging tables, transformed into cleaned dimension tables, and then used to populate fact tables. Analytical views were built on top of the facts and dimensions to support business intelligence use cases.

Dimensions include Date, Product, Store, Reseller, Customer, Channel, and Location.
Fact tables include Sales Actuals, Product Sales Targets, and Store/Reseller/Channel Sales Targets.
The warehouse uses a star schema.

**Key Technical Work**

Referential Integrity

All fact table foreign keys are guaranteed to be non-null by mapping missing values to the “Unknown” dimension member.

Preventing Data Loss

All dimension joins in fact table loads use left joins so that transactions are never dropped when a dimension record is missing.

Location Assignment

Location data exists in stores, customers, and resellers. The fact table selects the correct location key by checking these in order of priority.

Correct Date Matching

Yearly target data links to a single canonical date (the January 1st entry for each year) to avoid duplicating records.

Data Quality

Staging and fact tables were compared using row counts to confirm no unintended duplicates or dropped records.

**Analytical Views**

The warehouse supports reporting on:

Yearly product and store targets

Actual sales by product, store, and year

Profit and margin analysis

Day-of-week sales patterns

Bonus allocation modeling

Location-based store and reseller performance

**Skills Demonstrated**

Dimensional modeling and star schema design

SQL-based ETL and transformation logic

Data quality checks and validation

Cleaning and structuring inconsistent source data

Analytical query development

Working with Snowflake

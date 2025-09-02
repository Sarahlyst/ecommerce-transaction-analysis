# E-commerce Data Analysis Portfolio Project

## Table of Contents
- [Project Overview](#project-overview)
- [Dataset Info](#dataset-info)
- [Key Features & Workflow](#key-features-&-workflow)
- [Example Query](#example-query)
- [Technical Skills Demonstrated](#technical-skills-demonstrated)
- [How to Use This Project](#how-to-use-this-project)

### Project Overview

This project showcases a comprehensive retail data analytics workflow using PostgreSQL and an open-source e-commerce dataset. 
The goal was to demonstrate advanced SQL skills by building a robust ETL pipeline, data modelling, and insightful business analyses typical of a professional data analyst role.

### Dataset Info
- Source: "[https://www.kaggle.com/datasets/carrie1/ecommerce-data](https://www.kaggle.com/datasets/carrie1/ecommerce-data)"
- Size: ~500,000 rows
- Scope: UK-based online retail data from Dec 2010 to Dec 2011
- Fields: InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country

### Key Features & Workflow
1.  Staging Table Creation
    -	*Imported raw transactional data into a dedicated staging table (customer_transaction) to preserve source integrity.*
2. Data Cleaning & Transformation
    - *Wrote cleaning queries to check data quality*
    - *Cleaned data (duplicates, missing values, category standardization)*
3.  Data Enrichment
    - *Normalized clean data into dimension tables (customers, products) and fact tables (invoices, invoicedetails) following star schema best practices.*
4. Advanced SQL Analysis
   -	Developed 11 complex SQL queries demonstrating:
        -	*Revenue trends and seasonality*
        -	*Customer Segmentation with RFM and churn detection*
        -	*Cohort retention analysis*
        -	*Market basket and basket size analysis*
        -	*Customer lifetime value and revenue contribution*
        -	*Country with top average order value*

### Example Query
Below is one of the interesting code I worked with to create a conditional column that show customers with different levels of attrition 
```sql
-- RFM analysis
with transactions as (
select i.customerid, i.invoiceno, i.invoicedate, 
sum(id.revenue) as revenue
from invoices i
join invoicedetails id on i.invoiceno=id.invoiceno
group by i.customerid, i.invoiceno, i.invoicedate
),
rfm_base as (
select customerid, max(invoicedate) as lastpurchase,
count(distinct(invoiceno)) as frequency,
sum(revenue) as  monetary from transactions
group by customerid
),
rfm_calc as(
select customerid,
extract(day from ((select max(invoicedate)+interval '1 day'
from transactions)-lastpurchase))::int as recency,
frequency, monetary from rfm_base
order by monetary desc
)
select * from rfm_calc;
```
```sql
-- churn detection (customers with no purchase in the last 90 days)
with last_purchase as (
select customerid, max(invoicedate) as lastpurchasedate
from invoices group by customerid
),
max_purchase as (
select max(invoicedate)+interval '1 day' as currentdate
from invoices
)
select l.customerid, l.lastpurchasedate,
(m.currentdate::date - l.lastpurchasedate::date) 
as days_sincce_last_purchase,
case
when (m.currentdate::date-l.lastpurchasedate::date)>90 
then 'churned'
else 'active'
end as customer_status
from last_purchase l
cross join max_purchase m;
```
```sql
-- customer lifetime value
with customer_revenue as (
select i.customerid as customerid, id.revenue as revenue, 
count(distinct i.invoiceno) as total_orders
from invoices i join invoicedetails id on
i.invoiceno=id.invoiceno
group by i.customerid, id.revenue
)
select customerid, revenue, total_orders,
round(revenue/nullif (total_orders,0),2)as avg_order_value
from customer_revenue
order by revenue desc
limit 20;
```
### Technical Skills Demonstrated
-	Proficient use of PostgreSQL features:
     - Common Table Expressions (CTEs)
     - Window Functions 
     - Date and Time calculations
     - Aggregation, joins, and subqueries
-	Data warehousing concepts: staging, dimensions, facts, star schema
-	Business problem solving through SQL-driven insights


### How to Use This Project
-	The SQL scripts are split into four clear sections: staging load, transformation, enrichment, and analysis.
-	Run the scripts sequentially to reproduce the entire ETL pipeline and analytics output.
-	Modify the queries or tables to tailor insights for other datasets or business cases.


--PHASE 4 - ADVANCED ANALYSIS QUERIES
-- top revenue per month
select 
extract (year from i.invoicedate) as SalesYear,
extract (month from i.invoicedate) as SalesMonth,
sum(id.revenue) as TotalRevenue
from invoices i
join invoicedetails id 
on i.invoiceno = id.invoiceno
group by SalesYear, SalesMonth
order by totalrevenue desc;

-- top 10 products per total sold
select
extract (year from i.invoicedate) as SalesYear,
extract (month from i.invoicedate) as SalesMonth,
p.description, sum(id.quantity) as totalsold
from invoices i 
join invoicedetails id on i.invoiceno = id.invoiceno
join products p on id.stockcode=p.stockcode
group by salesyear, salesmonth, p.description
order by totalsold desc
limit 10;

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

--market basket analysis: frequently bought together
select a.stockcode as itemA, b.stockcode as itemB, 
count(*) as frequency
from invoicedetails a
join invoicedetails b
on a.invoiceno=b.invoiceno and a.stockcode<b.stockcode
group by a.stockcode, b.stockcode
order by frequency desc;

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

-- cohort analysis: Customer Retention Over months
with first_purchase as (
select customerid, min(invoicedate) as firstorderdate
from invoices group by customerid
),
cohort as(
select i.customerid, date_trunc('month',fp.firstorderdate)
as cohort_month,
date_trunc('month',i.invoicedate) as purchasemonth,
extract (month from age(date_trunc('month', i.invoicedate),
date_trunc('month', fp.firstorderdate))) as month_offset
from invoices i join first_purchase fp 
on i.customerid = fp.customerid
)
select cohort_month, month_offset, 
count(distinct customerid) as active_customers from cohort
group by cohort_month, month_offset
order by cohort_month, month_offset;

-- average order value by country
select country, round(sum(quantity*unitprice)::numeric
/count(distinct invoiceno),2) as avg_order_value
from customer_transaction
group by country order by avg_order_value desc;

-- seasonal sales pattern by month(month with top sales)
select to_char(i.invoicedate,'month') as salesmonth,
sum(id.revenue) as revenue from invoices i 
join invoicedetails id on i.invoiceno=id.invoiceno
group by salesmonth, extract(month from invoicedate)
order by revenue desc;

-- top 20 customers by revenue
select customerid, 
round(sum(quantity*unitprice)::numeric,2) as revenue
from customer_transaction
group by customerid order by revenue desc
limit 20;

-- Basket Size Analysis(products per invoice)
select invoiceno, count(distinct stockcode) as unique_products,
sum(quantity) as total_quantity,
sum(revenue) as basket_value
from invoicedetails
group by invoiceno
order by basket_value desc;
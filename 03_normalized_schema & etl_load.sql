--PHASE 3 - CREATE CLEAN, NORMALIZED TABLES
-- customers table
create table customers(
customerid text,
country varchar(50)
);
insert into customers(customerid, country)
select distinct customerid, country
from customer_transaction
where customerid is not null;

-- products table
create table products(
stockcode varchar(20),
description varchar(255),
unitprice decimal(10,2),
category varchar(50)
);
insert into products(stockcode, description, unitprice, category )
select distinct stockcode, description, unitprice, null   
from customer_transaction;

-- invoices table
create table invoices(
invoiceno varchar(20),
invoicedate timestamp,
customerid text
);
insert into invoices(invoiceno, invoicedate, customerid)
select distinct invoiceno, invoicedate, customerid   
from customer_transaction
where customerid is not null;

-- Invoice Details table
create table invoicedetails(
invoiceno varchar(20),
stockcode varchar(20),
quantity int,
revenue decimal(10,2)
);
insert into invoicedetails(invoiceno, stockcode, 
quantity, revenue)
select distinct invoiceno, stockcode, quantity, quantity*unitprice
from customer_transaction;

-- categorize products
update products
set category = case 
when description like '%card%' then 'stationery'
when description like '%bag%' then 'bags'
when description like '%mug%' then 'kitchenware'
else 'other'
end;
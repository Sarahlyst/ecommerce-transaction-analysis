--PHASE 2 - DATA QUALITY CHECKS AND CLEANING
-- 1. check total rows
select count(*) as total_rows 
from customer_transaction;

-- misssing values per column
select 
sum(case when InvoiceNo is null then 1
else 0 end) as missing_InvoiceNo,
sum(case when StockCode is null then 1
else 0 end) as missing_StockCode,
sum(case when Description is null then 1
else 0 end) as missing_Description,
sum(case when Quantity is null then 1
else 0 end) as missing_Quantity,
sum(case when InvoiceDate is null then 1
else 0 end) as missing_InvoiceDate,
sum(case when UnitPrice is null then 1
else 0 end) as missing_UnitPrice,
sum(case when CustomerID is null then 1
else 0 end) as missing_CustomerID,
sum(case when Country is null then 1
else 0 end) as missing_Country
from customer_transaction;
-- we have some missing Description and CustomerID

-- Replace the missing decription with 'unknown product'
update customer_transaction
set Description = 'Unkwnown Product'
where Description is null or trim(Description) = '';

-- Replace missing customer IDs with 'Guest' for tracking
alter table customer_transaction
alter column CustomerID type text
using CustomerID::text;

update customer_transaction
set CustomerID = 'Guest'
where CustomerID is null or trim(CustomerID) = '';


-- check for negative or zero prices
select * 
from customer_transaction
where UnitPrice<=0;
-- since there are zero prices, we remove records with zero prices
delete from customer_transaction
where unitprice <=0;

-- Negative quantities 
select count(*) 
from customer_transaction
where Quantity<0;
-- we remove records with negative quantities
delete from customer_transaction
where Quantity <0;

-- Duplicates check 
select InvoiceNo, StockCode, description, unitprice,
quantity, customerid, count(*) as DuplicateCount
from customer_transaction
group by InvoiceNo, StockCode, description, unitprice,
quantity, customerid
having count(*)>1;
--to remove remove duplicates, I keep one copy, delete the rest.
delete from customer_transaction 
where ctid not in (select min(ctid)
from customer_transaction 
group by InvoiceNo, StockCode, description, unitprice,
quantity, customerid
);

-- Date range check (should be Dec 2010 to Dec 2011)
select min(InvoiceDate) as MinDate,
max(InvoiceDate) as MinDate
from customer_transaction;
-- no errors with the date
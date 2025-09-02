-- PHASE 1 - IMPORT INTO SQL
create table customer_transaction(
InvoiceNo varchar(20),
StockCode varchar(20),
Description text,
Quantity integer,
InvoiceDate timestamp,
UnitPrice numeric(10,2),
CustomerID integer,
Country varchar(50)
);

select * from customer_transaction;
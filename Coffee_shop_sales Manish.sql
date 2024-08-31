Create database coffee_shop_sale_db ;

Use coffee_shop_sale_db;

Create table coffee_shop_sales(
transaction_id int not null,
transaction_date Date,
transaction_time time,
transaction_qty int,
store_id int,
store_location varchar(200),
product_id int,
unit_price double(4,2),
product_category varchar(150),
product_type varchar(200),
product_detail varchar(200)
);


Alter table coffee_shop_sales 
modify column transaction_qty double(4,2);


Select * from coffee_shop_sales;

Load data infile 'D:/Manish/MYSQL + Power BI/Coffee Shop Sales.csv' 
into table coffee_shop_sales
fields terminated by ','
ignore 1 Lines;

Select * from coffee_shop_sales;

Describe coffee_shop_sales;


-- 1. Calculate the total sales for each respective month------------

SELECT 
    ROUND(SUM((transaction_qty * unit_price)), 2) AS Total_Sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 3; -- Jan month


-- 2.Deterine the Month on month increase or decrease in sales.

Select	month(transaction_date) as month, -- No of month
round(sum(transaction_qty * unit_price),2) as Total_sales,
(sum(transaction_qty * unit_price) - LAG(sum(transaction_qty * unit_price),1)  -- 1 means it will go 1 row back i.e 1 month back (Moths salr diff.)
Over (Order by month(transaction_date)))/LAG(sum(transaction_qty * unit_price),1) 
Over (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
from coffee_shop_sales
where month(transaction_date) in(4,5)  -- for month April & May
Group by month(transaction_date)
order by month(transaction_date);

 
-- 3.Total no. of orders for each respective month.
SELECT 
    MONTH(transaction_date) AS Month,
    COUNT(transaction_id) AS Total_orders
FROM
    coffee_shop_sales
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);

-- 4.Month on month increase or decrease in the numbers of orders
Select 
month(transaction_date) as Month,
count(transaction_id) as Total_orders,
(count(transaction_id)-Lag(count(transaction_id),1)
Over (order by month(transaction_date)))/Lag(count(transaction_id),1)
Over (order by month(transaction_date)) * 100 as mom_increase_Percentage
from coffee_shop_sales
Group by month(transaction_date)
Order by month(transaction_date);

-- 5.Calculate the diff in numbers of orders between the selected month & prev. month
Select 
month(transaction_date) as Month,
count(transaction_id) as Total_orders,
(count(transaction_id) - Lag(count(transaction_id),1)
Over(order by month(transaction_date)))
from coffee_shop_sales
where month(transaction_date) in (4,5)
group by month(transaction_date)
order by month(transaction_date);


-- 6.Calculate the total qty sold for each respective month
SELECT 
    MONTH(transaction_date) as Month, COUNT(Transaction_qty) as Total_sales
FROM
    coffee_shop_sales
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);

-- 7.Calculate the diff in total qty sold between the selected month & prev month
Select 
Month(transaction_date) as Month,
Sum(transaction_qty) as Total_orders,
(sum(transaction_qty) - Lag(sum(transaction_qty),1)
Over(Order by Month(transaction_date))) as MOM_Increase_qty
from coffee_shop_sales
group by Month(transaction_date)
order by Month(transaction_date);


-- 8.Calculate month on month increase or decrease in the total qty sold
Select
Month(transaction_date) as Month,
sum(transaction_qty) as Total_orders,
(sum(transaction_qty) - Lag(sum(transaction_qty),1)
Over(Order by Month(transaction_date)))/(Lag(sum(transaction_qty),1)
Over(order by Month(transaction_date))) *100 as MOM_Increase_percentage
from coffee_shop_sales
group by Month(transaction_date)
order by Month(transaction_date);

-- 9.Total sales, sold qty and orders
Select
Concat(Round(Sum(transaction_qty * unit_price)/1000,1), 'K') as Total_sales,
Concat(Round(Sum(transaction_qty)/1000,1), 'K') as Total_Sold_qty,
Concat(Round(Count(transaction_id)/1000,1), 'K') as Total_orders
from coffee_shop_sales
where
	transaction_date = '2023-05-18';


-- Weekdays & Weekends wise sales
-- Sun = 1
-- Mon = 2
-- .
-- Sat = 7

Select 
Case When dayofweek(transaction_date) in (1,7) then 'Weekends'
Else 'Weekdays'
End as day_of_week,
sum(transaction_qty * unit_price) as Total_sales
from coffee_shop_sales
where month(transaction_date) = 5   -- for may month
Group by day_of_week;


-- Store location wise sales
Select 
store_location,
Sum(transaction_qty * unit_price) as Total_sales
from coffee_shop_sales
where month(transaction_date) = 5  -- for may month 
group by store_location
order by Total_sales;


-- Avg sales--------------
select
avg(Total_sales) as Avg_sales
from
(select
Sum(transaction_qty * unit_price) as Total_sales
from coffee_shop_sales
where month(transaction_date) = 4
Group by transaction_date) as Internal_query;


-- Sales_status ---------------
Select 
day_of_month,
Case 
	When Total_sales > Avg_sales then 'Above Average'
    When Total_sales < Avg_sales then 'Below Average'
    Else 'Average'
    End as Sales_status,
    Total_sales
from 
(Select 
day(transaction_date) as day_of_month,
sum(transaction_qty * unit_price) as Total_sales,
avg(sum(transaction_qty * unit_price)) over () as Avg_sales 
from coffee_shop_sales
where month(transaction_date) = 3
group by day(transaction_date)
) as sales_data
order by day_of_month;


-- Sales by product_category
SELECT 
    product_category,
    SUM(transaction_qty * unit_price) AS Total_sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY Total_sales;


-- Top 10 products sales
SELECT 
    product_type,
    SUM(transaction_qty * unit_price) AS Total_sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY product_type
ORDER BY Total_sales DESC
LIMIT 10;


-- Sales analysis by day & hour
SELECT 
    SUM(transaction_qty * unit_price) AS Total_sales,
    SUM(transaction_qty) AS Sold_qty,
    COUNT(transaction_qty) AS Total_orders
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5
        AND DAYOFWEEK(transaction_date) = 2
        AND HOUR(transaction_time) = 8






    
		
    
    






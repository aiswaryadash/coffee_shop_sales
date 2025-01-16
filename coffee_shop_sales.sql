-- no of records present in table
SELECT count(*) FROM coffee_shop_sales;

-- details of each column
describe coffee_shop_sales;

-- change the datatype to date
update coffee_shop_sales
set transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

alter table coffee_shop_sales
modify column transaction_date DATE;

-- change the datatype to time
update coffee_shop_sales
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');

alter table coffee_shop_sales
modify column transaction_time time;

-- change the column name
alter table coffee_shop_sales
change column ï»¿transaction_id transaction_id int;

##  business requirment queries 
select * from coffee_shop_sales;

-- total sales of each month
select round(sum(unit_price * transaction_qty), 2) as total_sales
from coffee_shop_sales where  month(transaction_date) = 5 ;

-- month on month increase or decrease in sales
select 
	month(transaction_date) as month,
    round(sum(unit_price * transaction_qty), 2) as total_sales,
    -- month_on_month_sale% = current_month_sales - previous_month_sale/ previous_month_sale * 100
    (sum(unit_price * transaction_qty) - LAG(sum(unit_price * transaction_qty), 1) 
    over(order by month(transaction_date))) / LAG(sum(unit_price * transaction_qty), 1)
    over(order by month(transaction_date)) * 100 As mom_increase_percentage
from 
	coffee_shop_sales
where month(transaction_date) in (4, 5)
group by month(transaction_date)
order by month(transaction_date);

-- total no of orders for each month
select count(transaction_id) as total_orders
from coffee_shop_sales
where month(transaction_date) = 5;

-- month on month difference in order qty
select
	month(transaction_date) as month,
	count(transaction_id) as total_orders,
    (count(transaction_id) - lag(count(transaction_id))
    over(order by month(transaction_date))) / lag(count(transaction_id))
    over(order by month(transaction_date)) * 100 as mom_increase_percentage
from coffee_shop_sales
where month(transaction_date) in (4, 5)
group by month(transaction_date)
order by month(transaction_date);

-- total qty sold of each month
select round(sum(transaction_qty), 2) as total_qty_sold
from coffee_shop_sales where  month(transaction_date) = 5 ;

-- month on month incresae in sold qty
select 
	month(transaction_date) as month,
    sum(transaction_qty) as total_qty_sold,
    (sum(transaction_qty) - lag(sum(transaction_qty), 1)
    over(order by month(transaction_date))) / lag(sum(transaction_qty), 1)
    over(order by month(transaction_date)) * 100 as mom_increase_percentage
from coffee_shop_sales
where month(transaction_date) in (4, 5)
group by month(transaction_date)
order by month(transaction_date);

-- sales, no_of_orders, total_qty of each day
select
	round(sum(unit_price * transaction_qty), 2) as total_sales,
    sum(transaction_qty) as total_qty_sold,
    count(transaction_id) as total_orders
from coffee_shop_sales
where transaction_date = '2023-05-18' ;

-- sales analysis by weekdays and weekends
select
	case when dayofweek(transaction_date) in (1, 7) then 'weekend'
    else 'weekdays'
    end as day_type,
    sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by 
	case when dayofweek(transaction_date) in (1, 7) then 'weekend'
    else 'weekdays'
    end;
    
-- sales by store location
select store_location,
round(sum(unit_price * transaction_qty), 2) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by store_location
order by round(sum(unit_price * transaction_qty), 2) desc;

-- average sales of months
select avg(total_sales) as avg_sales
from (
select sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales where month(transaction_date) = 5
group by transaction_date) as internal_query;

-- comparison of each day sale with the avg sale of that month
select day_of_month, total_sales, 
	case when total_sales > avg_sales then 'above_average'
    when total_sales < avg_sales then 'below_average'
    else 'equal'
    end as status
    from (
select day(transaction_date) as day_of_month,
sum(unit_price * transaction_qty) as total_sales,
avg(sum(unit_price * transaction_qty)) over() as avg_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by day(transaction_date)
) as daily_sales
order by day_of_month ;

-- sales by product category
select product_category,
sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales 
where month(transaction_date) = 5
group by product_category
order by sum(unit_price * transaction_qty) desc;

-- top 10 products by sales
select product_type,
sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales 
where month(transaction_date) = 5
group by product_type
order by sum(unit_price * transaction_qty) desc
limit 10;

-- sales, total_order, total_qty analysis by days and hours
select sum(unit_price * transaction_qty) as total_sales,
sum(transaction_qty) as total_qty,
count(*) as total_orders
from coffee_shop_sales
where month(transaction_date) = 5 -- may month
and dayofweek(transaction_date) = 2 -- monday
and hour(transaction_time) = 8 ;-- 8 hour

-- sales by hours
select hour(transaction_time) as hour,
sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by hour(transaction_time)
order by hour(transaction_time);

-- sales by days
select 
	case when dayofweek(transaction_date) = 2 then 'monday'
    when dayofweek(transaction_date) = 3 then 'tuesday'
    when dayofweek(transaction_date) = 4 then 'wednesday'
    when dayofweek(transaction_date) = 5 then 'thrusday'
    when dayofweek(transaction_date) = 6 then 'friday'
    when dayofweek(transaction_date) = 7 then 'saturday'
    else 'sunday'
    end as days,
    sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by 
case when dayofweek(transaction_date) = 2 then 'monday'
    when dayofweek(transaction_date) = 3 then 'tuesday'
    when dayofweek(transaction_date) = 4 then 'wednesday'
    when dayofweek(transaction_date) = 5 then 'thrusday'
    when dayofweek(transaction_date) = 6 then 'friday'
    when dayofweek(transaction_date) = 7 then 'saturday'
    else 'sunday'
    end ;
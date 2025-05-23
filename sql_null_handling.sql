CREATE DATABASE shop_sales;
USE shop_sales;
CREATE TABLE sales (
    date DATE,
    sales INT
);
INSERT into sales (date, sales)
values ('2024-12-05' , 543),
('2024-12-06' , 453),
('2024-12-08' , 149),
('2024-12-09' , 348),
('2024-12-11' , 981),
('2024-12-12' , 560),
('2024-12-14' , 496);

select * from sales;

#Created a table and populated with values including null values.


WITH recursive cte as (select cast('2024-12-06' as date) as date_v
UNION
select date_v + interval 1 day
FROM cte WHERE date_v < cast('2024-12-15' as date))

SELECT cte.date_v, sales.sales, coalesce(sales.sales, round((SELECT avg(sales.sales) from sales),2))  as sales_estimate,
coalesce(sales.sales, round((lag(sales.sales) over ()+lead(sales.sales) over())/2 ,2)) as sales_estimate2

from cte LEFT JOIN sales ON sales.date = cte.date_v;


#Techniques Used:
   #Recursive CTE: To generate a sequence of dates.
   #LEFT JOIN: To combine generated dates with existing sales data.
   #COALESCE Function: To handle NULL values by providing default estimates.
   #Window Functions (LAG, LEAD): To access previous and next rows for estimating missing values.
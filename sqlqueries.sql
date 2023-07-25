-- Monthly Sales trends for macbooks in NA
-- Use DATE_TRUNC to group by purchase_month

SELECT
  DATE_TRUNC(purchase_ts, MONTH) AS purchase_month,
  COUNT(orders.id) AS total_orders,
  ROUND(SUM(usd_price), 2) AS total_sales
FROM
  elist-390902.elist.orders AS orders
LEFT JOIN
  elist-390902.elist.customers AS customers
  ON orders.customer_id = customers.id
LEFT JOIN
  elist-390902.elist.geo_lookup AS geo_lookup
  ON customers.country_code = geo_lookup.country
WHERE
  LOWER(orders.product_name) LIKE LOWER('%macbook%')
  AND geo_lookup.region = 'NA'
GROUP BY
  1
ORDER BY
  1;

-- Quarterly Sales trends for macbooks in NA
-- Use DATE_TRUNC to group by quarter

SELECT
  DATE_TRUNC(purchase_ts, QUARTER) AS purchase_quarter,
  COUNT(orders.id) AS total_orders,
  ROUND(SUM(usd_price), 2) AS total_sales
FROM
  elist-390902.elist.orders AS orders
LEFT JOIN
  elist-390902.elist.customers AS customers
  ON orders.customer_id = customers.id
LEFT JOIN
  elist-390902.elist.geo_lookup AS geo_lookup
  ON customers.country_code = geo_lookup.country
WHERE
  LOWER(orders.product_name) LIKE LOWER('%macbook%')
  AND geo_lookup.region = 'NA'
GROUP BY
  1
ORDER BY
  1;

-- Monthly refund rate for purchases made in 2020
-- Count refunds using order_status.refund_ts column (not null) and divide by total orders

SELECT
  DATE_TRUNC(orders.purchase_ts, MONTH) AS purchase_month,
  SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) AS total_refunds,
  COUNT(orders.id) AS total_orders,
  SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) / COUNT(orders.id) AS refund_rate
FROM
  elist-390902.elist.orders AS orders
LEFT JOIN
  elist-390902.elist.order_status AS order_status
  ON orders.id = order_status.order_id
WHERE
  EXTRACT(YEAR FROM orders.purchase_ts) = 2020
GROUP BY
  1
ORDER BY
  1;

-- Monthly refunds for Apple products in 2021
-- Join orders and order status tables to locate refunded orders
-- Count refunds using order_status.refund_ts column (not null) and divide by total orders
-- Use a WHERE statement to filter out Apple products and include Macbook

SELECT
  DATE_TRUNC(orders.purchase_ts, MONTH) AS purchase_month,
  SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) AS total_refunds,
  COUNT(orders.id) AS total_orders,
  SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) / COUNT(orders.id) AS refund_rate
FROM
  elist-390902.elist.orders AS orders
LEFT JOIN
  elist-390902.elist.order_status AS order_status
  ON orders.id = order_status.order_id
WHERE
  EXTRACT(YEAR FROM orders.purchase_ts) = 2021
  AND (LOWER(orders.product_name) LIKE LOWER('%apple%')
  OR LOWER(orders.product_name) LIKE LOWER('%macbook%'))
GROUP BY
  1
ORDER BY
  1;

-- Refund analysis by product
-- Count the number of products sold, total refund count, and refund rate

SELECT
  CASE WHEN orders.product_name = '27in"" 4k gaming monitor' THEN '27in 4K gaming monitor' ELSE orders.product_name END,
  COUNT(orders.id) AS total_orders,
  SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) AS total_refunds,
  SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) / COUNT(orders.id) AS refund_rate
FROM
  elist-390902.elist.orders AS orders
LEFT JOIN
  elist-390902.elist.order_status AS order_status
  ON orders.id = order_status.order_id
GROUP BY
  1
ORDER BY
  4 DESC;

-- Top 3 most frequently refunded products across all years
-- Count the number of products sold, total refund count, and refund rate
-- Limit the results to 3

SELECT
  CASE WHEN orders.product_name = '27in"" 4k gaming monitor' THEN '27in 4K gaming monitor' ELSE orders.product_name END,
  COUNT(orders.id) AS total_orders,
  SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) AS total_refunds,
  SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) / COUNT(orders.id) AS refund_rate
FROM
  elist-390902.elist.orders AS orders
LEFT JOIN
  elist-390902.elist.order_status AS order_status
  ON orders.id = order_status.order_id
GROUP BY
  1
ORDER BY
  4 DESC
LIMIT 3;

-- Top 3 most frequently refunded products across all years
-- Count the number of products sold, total refund count, and refund rate
-- Limit the results to 3

SELECT
  CASE WHEN orders.product_name = '27in"" 4k gaming monitor' THEN '27in 4K gaming monitor' ELSE orders.product_name END,
  COUNT(orders.id) AS total_orders,
  SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) AS total_refunds,
  SUM(CASE WHEN refund_ts IS NOT NULL THEN 1 ELSE 0 END) / COUNT(orders.id) AS refund_rate
FROM
  elist-390902.elist.orders AS orders
LEFT JOIN
  elist-390902.elist.order_status AS order_status
  ON orders.id = order_status.order_id
GROUP BY
  1
ORDER BY
  4 DESC
LIMIT 3;

-- Average order value across different account creation methods in the first two months of 2022
-- Join orders and customers tables to query AOV and account creation method
-- Specify the first two months of 2022 (Date between)

SELECT
  customers.account_creation_method AS account_creation_method,
  AVG(usd_price) AS aov
FROM
  elist-390902.elist.orders AS orders
LEFT JOIN
  elist-390902.elist.customers AS customers
  ON orders.customer_id = customers.id
WHERE
  purchase_ts BETWEEN '2022-01-01' AND '2022-02-28'
GROUP BY
  1;

--calculate days to purchase by taking date difference
--take the average of the number of days to purchase

with days_to_purchase_cte as (
    select customers.id as customer_id, 
	    orders.id as order_id,
	    customers.created_on,
	    orders.purchase_ts, 
	    date_diff(orders.purchase_ts, customers.created_on,day) as days_to_purchase
		from `elist-390902.elist.customers` customers
		left join `elist-390902.elist.orders` orders
		    on customers.id = orders.customer_id
		order by 1,2,3)

select avg(days_to_purchase) 
from days_to_purchase_cte;

--total number of orders and total sales by region and registration channel
--channels ranked by total sales, and order the dataset by this ranking to surface the top channels per region first

with region_orders as (
    select geo_lookup.region, 
    customers.marketing_channel,
    count(distinct orders.id) as num_orders, 
    sum(orders.usd_price) as total_sales,
    avg(orders.usd_price) as aov
from `elist-390902.elist.orders` orders
left join `elist-390902.elist.customers` customers
    on orders.customer_id = customers.id
left join elist.geo_lookup
    on customers.country_code = geo_lookup.country
group by 1,2
order by 1,2)

select *, 
	row_number() over (partition by region order by num_orders desc) as ranking
from region_orders
order by 6 asc

--customers with over 4 purchases first
  
with over_4_purchases as (
  select customer_id, 
		count(id)
  from `elist-390902.elist.orders` orders
  group by 1
  having (count(id)) >= 4
)

-- rank customer orders by most recent first
-- select the most recent orders using a qualify 
-- choose only customers who had more than 4 purchases with inner join
  
select orders.customer_id, 
  orders.id, 
  orders.product_name, 
  orders.purchase_ts,
  row_number() over (partition by orders.customer_id order by orders.purchase_ts desc) as order_ranking
from `elist-390902.elist.orders` orders
inner join over_4_purchases 
  on over_4_purchases.customer_id = orders.customer_id
qualify row_number() over (partition by customer_id order by purchase_ts desc) = 1

--brand categories and filter to 2020
--count the number of refunds per month
  
with brand_refunds as (
	select 
	  case when lower(product_name) like '%apple%' or lower(product_name) like '%macbook%' then 'Apple'
	    when lower(product_name) like '%thinkpad%' then 'ThinkPad'
	    when lower(product_name) like '%samsung%' then 'Samsung'
	    when lower(product_name) like '%bose%' then 'Bose'
	    else 'Unknown'
	  end as brand,
	  date_trunc(refund_ts, month) as refund_month,
	  count(refund_ts) as refunds
	from `elist-390902.elist.orders` orders
	left join `elist-390902.elist.order_status` order_status
		on orders.id = order_status.order_id
	where extract(year from refund_ts) = 2020
	group by 1,2)

--select the month per brand based on the highest number of refunds
select * 
from brand_refunds
qualify row_number() over (partition by brand order by refunds desc) = 1




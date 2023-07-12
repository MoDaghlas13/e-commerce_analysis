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






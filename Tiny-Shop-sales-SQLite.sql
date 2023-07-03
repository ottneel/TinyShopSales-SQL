CREATE TABLE customers (
    customer_id integer PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(100)
);

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name varchar(100),
    price decimal
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    customer_id integer,
    order_date date
);

CREATE TABLE order_items (
    order_id integer,
    product_id integer,
    quantity integer
);

INSERT INTO customers (customer_id, first_name, last_name, email) VALUES
(1, 'John', 'Doe', 'johndoe@email.com'),
(2, 'Jane', 'Smith', 'janesmith@email.com'),
(3, 'Bob', 'Johnson', 'bobjohnson@email.com'),
(4, 'Alice', 'Brown', 'alicebrown@email.com'),
(5, 'Charlie', 'Davis', 'charliedavis@email.com'),
(6, 'Eva', 'Fisher', 'evafisher@email.com'),
(7, 'George', 'Harris', 'georgeharris@email.com'),
(8, 'Ivy', 'Jones', 'ivyjones@email.com'),
(9, 'Kevin', 'Miller', 'kevinmiller@email.com'),
(10, 'Lily', 'Nelson', 'lilynelson@email.com'),
(11, 'Oliver', 'Patterson', 'oliverpatterson@email.com'),
(12, 'Quinn', 'Roberts', 'quinnroberts@email.com'),
(13, 'Sophia', 'Thomas', 'sophiathomas@email.com');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Product A', 10.00),
(2, 'Product B', 15.00),
(3, 'Product C', 20.00),
(4, 'Product D', 25.00),
(5, 'Product E', 30.00),
(6, 'Product F', 35.00),
(7, 'Product G', 40.00),
(8, 'Product H', 45.00),
(9, 'Product I', 50.00),
(10, 'Product J', 55.00),
(11, 'Product K', 60.00),
(12, 'Product L', 65.00),
(13, 'Product M', 70.00);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
(1, 1, '2023-05-01'),
(2, 2, '2023-05-02'),
(3, 3, '2023-05-03'),
(4, 1, '2023-05-04'),
(5, 2, '2023-05-05'),
(6, 3, '2023-05-06'),
(7, 4, '2023-05-07'),
(8, 5, '2023-05-08'),
(9, 6, '2023-05-09'),
(10, 7, '2023-05-10'),
(11, 8, '2023-05-11'),
(12, 9, '2023-05-12'),
(13, 10, '2023-05-13'),
(14, 11, '2023-05-14'),
(15, 12, '2023-05-15'),
(16, 13, '2023-05-16');

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 2, 1),
(2, 3, 3),
(3, 1, 1),
(3, 3, 2),
(4, 2, 4),
(4, 3, 1),
(5, 1, 1),
(5, 3, 2),
(6, 2, 3),
(6, 1, 1),
(7, 4, 1),
(7, 5, 2),
(8, 6, 3),
(8, 7, 1),
(9, 8, 2),
(9, 9, 1),
(10, 10, 3),
(10, 11, 2),
(11, 12, 1),
(11, 13, 3),
(12, 4, 2),
(12, 5, 1),
(13, 6, 3),
(13, 7, 2),
(14, 8, 1),
(14, 9, 2),
(15, 10, 3),
(15, 11, 1),
(16, 12, 2),
(16, 13, 3);

--1) Which product has the highest price? Only return a single row.
SELECT
	product_name, price as Most_Expensive_Product
FROM
	products
order by 
	Most_Expensive_Product desc
limit 1;


--2) Which customer has made the most orders?
select 
	(c.first_name||' '||c.last_name) as customer_name,
    count(order_id) as order_count
from 
	customers as c
inner join 
	orders as o using(customer_id)
group by 
	customer_name
order by
	order_count desc
limit 3;

--3) What’s the total revenue per product?
-- join the products and order_item on the product_id key, then find the sum of the quantity, * by price and then group by the product_name
select
	p.product_id, p.product_name,(sum(oi.quantity)*p.price) as revenue
from
	products as p
inner join
	order_items as oi using(product_id)
group by 
	p.product_name
order by 
	revenue desc;


--4) Find the day with the highest revenue 
SELECT
	SUM(p.price * oi.quantity) as revenue, o.order_date
from
	products p
inner join
	order_items oi using(product_id)
inner join
	orders as o using(order_id)
group by
	o.order_date
order by
	revenue desc
LIMIT 1;

--5) Find the first order (by date) for each customer.
SELECT
	distinct FIRST_VALUE(o.order_date) OVER (PARTITION by customer_id order by o.order_date) AS Customer_first_order, c.first_name || ' ' || c.last_name as customer_name
from
	customers as c
inner join
	orders o using (customer_id);


--6) Find the top 3 customers who have ordered the most distinct products
-- joined the 3 tables together in a CTE named fulltable
with full_table as(
  select *
  from
  	customers c
  inner join
  	orders o using (customer_id)
  inner join
  	order_items oi using(order_id)
  inner join
  	products p using (product_id)
  )
 -- from the fulltable, i got the fullname,count of orders,productname
SELECT
	first_name || ' ' || last_name as full_name, 
    count(DISTINCT order_id) as distinct_product_count , product_name
FROM
	full_table
group by
	customer_id
order by
	distinct_product_count desc
limit 3;

--7) Which product has been bought the least in terms of quantity?
select 
	sum(quantity) as total_quantity,p.product_name
from
	order_items oi
inner join
	products p using(product_id)
group by
	p.product_name
having 
	total_quantity IN (SELECT MIN(total_quantity) FROM (SELECT SUM(quantity) AS total_quantity FROM order_items GROUP BY product_id) AS subquery)
order by
	total_quantity;



--8) What is the median order total?
-- Define a Cte called total_rev that finds the total revenue for each distinct product
with total_rev as (
  select
  	distinct product_name ,sum(p.price * oi.quantity) over (partition by p.product_name) as total_revenue
  from
  	products p
  inner join
  	order_items oi using (product_id)
),
-- define another cte that assigns row number to each row
row_numbering_cte as (
  select
  	total_revenue, row_NUMBER() over (order by total_revenue) as row_numberr, count(*) over () as total_rows
  from
  	total_rev
)
-- find the average of the total revenue, then in the where clause, find the row_numberr that has the value in the where clause ( which finds the value of the middle row)
SELECT
	ROUND(AVG(Total_Revenue), 2) AS `Median Total`
FROM
	row_numbering_cte
WHERE
	row_numberr IN ((total_rows + 1) / 2, (total_rows + 2) / 2);

--9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.
SELECT order_id, (
	case when
  		order_total >300 then 'Expensive'
    WHEN
  		order_total >100 then 'affordable'
    else 'cheap'
    end) as order_type
from (
  SELECT
	sum(quantity*price) as order_total, order_id
  from
  	orders
  inner join
  	order_items using(order_id)
  inner join
  	products using(product_id)
  GROUP by
  	order_id
);
-- to count the different order types.
select
	order_type,
    count(order_type) as order_type_total
from (
  	SELECT order_id, (
	case when
  		order_total >300 then 'Expensive'
    WHEN
  		order_total >100 then 'affordable'
    else 'cheap'
    end) as order_type
from (
  SELECT
	sum(quantity*price) as order_total, order_id
  from
  	orders
  inner join
  	order_items using(order_id)
  inner join
  	products using(product_id)
  GROUP by
  	order_id) as subsubquery
) as subquery
group by order_type
order by order_type_total DESC;



--10) Find customers who have ordered the product with the highest price.
select 
	(c.first_name||' '||c.last_name) as full_name, p.product_name, p.price
from 
	customers c
inner join 
	orders o using (customer_id)
inner join 
	order_items oi using (order_id)
inner join 
	products p using (product_id)
where
	p.price=(select max(price) from products);


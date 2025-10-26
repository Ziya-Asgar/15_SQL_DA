-- Create tables for customers, products, and sales
CREATE TABLE dim_customers (
	customer_key int,
	customer_id int,
	customer_number varchar(50),
	first_name varchar(50),
	last_name varchar(50),
	country varchar(50),
	marital_status varchar(50),
	gender varchar(50),
	birthdate date,
	create_date date
);

CREATE TABLE dim_products (
	product_key int,
	product_id int,
	product_number varchar(50),
	product_name varchar(50),
	category_id varchar(50),
	category varchar(50),
	subcategory varchar(50),
	maintenance varchar(50),
	cost int,
	product_line varchar(50),
	start_date date
);

CREATE TABLE fact_sales (
	order_number varchar(50),
	product_key int,
	customer_key int,
	order_date date,
	shipping_date date,
	due_date date,
	sales_amount int,
	quantity int,
	price int
);

-- Copy the data from csv files to the tables
COPY dim_customers (
	customer_key,
	customer_id,
	customer_number,
	first_name,
	last_name,
	country,
	marital_status,
	gender,
	birthdate,
	create_date
)
FROM
	'C:\gold.dim_customers.csv' DELIMITER ',' CSV HEADER;

COPY dim_products (
	product_key,
	product_id,
	product_number,
	product_name,
	category_id,
	category,
	subcategory,
	maintenance,
	cost,
	product_line,
	start_date
)
FROM
	'C:\gold.dim_products.csv' DELIMITER ',' CSV HEADER;

COPY fact_sales (
	order_number,
	product_key,
	customer_key,
	order_date,
	shipping_date,
	due_date,
	sales_amount,
	quantity,
	price
)
FROM
	'C:\gold.fact_sales.csv' DELIMITER ',' CSV HEADER;

-- Check all the columns in the created tables
SELECT
	*
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	table_schema = 'public'
ORDER BY
	table_name,
	ordinal_position;

-- Check the trends - changes over time
-- Initial look at the sales ordered by the date
SELECT
	order_date,
	sales_amount
FROM
	fact_sales
WHERE
	order_date IS NOT NULL
ORDER BY
	order_date;

-- Summing the sales by dates
SELECT
	order_date,
	SUM(sales_amount) total_sales
FROM
	fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	order_date
ORDER BY
	order_date;

-- Summing the sales by years
SELECT
	EXTRACT(
		YEAR
		FROM
			order_date
	) order_year,
	SUM(sales_amount) total_sales
FROM
	fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	order_year
ORDER BY
	order_year;

-- Summing the sales and counting the number of customers by years 
SELECT
	EXTRACT(
		YEAR
		FROM
			order_date
	) order_year,
	SUM(sales_amount) total_sales,
	COUNT(DISTINCT customer_key) total_customers
FROM
	fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	order_year
ORDER BY
	order_year;

-- Summing the sales and quantities, and counting the number of customers by years 
SELECT
	EXTRACT(
		YEAR
		FROM
			order_date
	) order_year,
	SUM(sales_amount) total_sales,
	COUNT(DISTINCT customer_key) total_customers,
	SUM(quantity) total_quantity
FROM
	fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	order_year
ORDER BY
	order_year;

-- Summing the sales and quantities, and counting the number of customers by months 
SELECT
	EXTRACT(
		MONTH
		FROM
			order_date
	) order_month,
	SUM(sales_amount) total_sales,
	COUNT(DISTINCT customer_key) total_customers,
	SUM(quantity) total_quantity
FROM
	fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	order_month
ORDER BY
	order_month;

-- Summing the sales and quantities, and counting the number of customers by years and months 
SELECT
	EXTRACT(
		YEAR
		FROM
			order_date
	) order_year,
	EXTRACT(
		MONTH
		FROM
			order_date
	) order_month,
	SUM(sales_amount) total_sales,
	COUNT(DISTINCT customer_key) total_customers,
	SUM(quantity) total_quantity
FROM
	fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	order_year,
	order_month
ORDER BY
	order_year,
	order_month;

-- Summing the sales and quantities, and counting the number of customers by years and months 
-- Presenting data with years and months in a single column, and truncating the dates up to month level
SELECT
	DATE_TRUNC('month', order_date) order_date,
	SUM(sales_amount) total_sales,
	COUNT(DISTINCT customer_key) total_customers,
	SUM(quantity) total_quantity
FROM
	fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	DATE_TRUNC('month', order_date)
ORDER BY
	DATE_TRUNC('month', order_date);

-- Summing the sales and ordered quantities, and counting the number of customers by years and months 
-- Presenting data with years and months in a single column, and truncating the dates up to year level
SELECT
	DATE_TRUNC('year', order_date) order_date,
	SUM(sales_amount) total_sales,
	COUNT(DISTINCT customer_key) total_customers,
	SUM(quantity) total_quantity
FROM
	fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	DATE_TRUNC('year', order_date)
ORDER BY
	DATE_TRUNC('year', order_date);

-- Summing the sales and quantities, and counting the number of customers by years and months 
-- Presenting data with years and months in a single column in a desired string format
SELECT
	TO_CHAR(order_date, 'yyyy-Mon') order_date,
	SUM(sales_amount) total_sales,
	COUNT(DISTINCT customer_key) total_customers,
	SUM(quantity) total_quantity
FROM
	fact_sales
WHERE
	order_date IS NOT NULL
GROUP BY
	TO_CHAR(order_date, 'yyyy-Mon')
ORDER BY
	TO_CHAR(order_date, 'yyyy-Mon');

-- Cumulative Analysis
-- Aggregate the data progressively over time
-- Helps to understand whether our business is growing or declining
--
-- calculate the total sales per month
-- and the running total sales over time
SELECT
	order_date,
	total_sales,
	-- window function
	SUM(total_sales) OVER (
		ORDER BY
			order_date
	) running_total_sales
FROM
	(
		SELECT
			DATE_TRUNC('month', order_date) order_date,
			SUM(sales_amount) total_sales
		FROM
			fact_sales
		WHERE
			order_date IS NOT NULL
		GROUP BY
			DATE_TRUNC('month', order_date)
		ORDER BY
			DATE_TRUNC('month', order_date)
	);

-- cumulative total per month partitioned by each year
SELECT
	order_date,
	total_sales,
	-- window function
	SUM(total_sales) OVER (
		PARTITION BY
			DATE_TRUNC('year', order_date)
		ORDER BY
			order_date
	) running_total_sales
FROM
	(
		SELECT
			DATE_TRUNC('month', order_date) order_date,
			SUM(sales_amount) total_sales
		FROM
			fact_sales
		WHERE
			order_date IS NOT NULL
		GROUP BY
			DATE_TRUNC('month', order_date)
		ORDER BY
			DATE_TRUNC('month', order_date)
	);

-- cumulative total per year
SELECT
	order_date,
	total_sales,
	-- window function
	SUM(total_sales) OVER (
		ORDER BY
			order_date
	) running_total_sales
FROM
	(
		SELECT
			DATE_TRUNC('year', order_date) order_date,
			SUM(sales_amount) total_sales
		FROM
			fact_sales
		WHERE
			order_date IS NOT NULL
		GROUP BY
			DATE_TRUNC('year', order_date)
		ORDER BY
			DATE_TRUNC('year', order_date)
	);

-- moving average of the price
SELECT
	order_date,
	total_sales,
	ROUND(avg_price, 0) avg_price,
	-- window function
	ROUND(
		AVG(avg_price) OVER (
			ORDER BY
				order_date
		),
		0
	) moving_average_price
FROM
	(
		SELECT
			DATE_TRUNC('year', order_date) order_date,
			SUM(sales_amount) total_sales,
			AVG(price) avg_price
		FROM
			fact_sales
		WHERE
			order_date IS NOT NULL
		GROUP BY
			DATE_TRUNC('year', order_date)
		ORDER BY
			DATE_TRUNC('year', order_date)
	);

-- Performance Analysis
-- Comparing the current value to a target value
-- Helps measure success and compare performance
--
-- Analyze the yearly performance of products by comparing their sales to
-- both the average sales performance of the product and the previous year's sales
WITH
	yearly_product_sales AS (
		SELECT
			EXTRACT(
				YEAR
				FROM
					f.order_date
			) order_year,
			p.product_name,
			SUM(f.sales_amount) current_sales
		FROM
			fact_sales f
			LEFT JOIN dim_products p ON f.product_key = p.product_key
		WHERE
			f.order_date IS NOT NULL
		GROUP BY
			order_year,
			p.product_name
	)
SELECT
	order_year,
	product_name,
	current_sales,
	ROUND(
		AVG(current_sales) OVER (
			PARTITION BY
				product_name
		),
		0
	) avg_sales,
	current_sales - ROUND(
		AVG(current_sales) OVER (
			PARTITION BY
				product_name
		),
		0
	) diff_avg,
	CASE
		WHEN current_sales - ROUND(
			AVG(current_sales) OVER (
				PARTITION BY
					product_name
			),
			0
		) > 0 THEN 'Above Avg'
		WHEN current_sales - ROUND(
			AVG(current_sales) OVER (
				PARTITION BY
					product_name
			),
			0
		) < 0 THEN 'Below Avg'
		ELSE 'Avg'
	END avg_change,
	-- Year-over-year Analysis
	LAG(current_sales) OVER (
		PARTITION BY
			product_name
		ORDER BY
			order_year ASC
	) py_sales,
	current_sales - LAG(current_sales) OVER (
		PARTITION BY
			product_name
		ORDER BY
			order_year ASC
	) diff_py,
	CASE
		WHEN current_sales - LAG(current_sales) OVER (
			PARTITION BY
				product_name
			ORDER BY
				order_year ASC
		) > 0 THEN 'Increase'
		WHEN current_sales - LAG(current_sales) OVER (
			PARTITION BY
				product_name
			ORDER BY
				order_year ASC
		) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END py_change
FROM
	yearly_product_sales
ORDER BY
	product_name,
	order_year;

-- Part-to-whole Analysis - Proportionality Analysis
-- Analyze how an individual part is performing compared to the overall
-- Allows to understand which category has the greatest impact on the business
--
-- Which categories contribute the most to overall sales
WITH
	category_sales AS (
		SELECT
			category,
			SUM(sales_amount) total_sales
		FROM
			fact_sales f
			LEFT JOIN dim_products p ON p.product_key = f.product_key
		GROUP BY
			category
	)
SELECT
	category,
	total_sales,
	SUM(total_sales) OVER () overall_sales,
	CONCAT(
		ROUND(
			CAST(
				(total_sales / SUM(total_sales) OVER ()) * 100 AS DECIMAL
			),
			2
		),
		'%'
	) percentage_of_total
FROM
	category_sales
ORDER BY
	total_sales DESC;

-- Data Segmentation
-- Group the data based on a specific range
-- Helps understand the correlation between two measures
--
-- Segment products into cost ranges and
-- count how many products fall into each segment
WITH
	product_segments AS (
		SELECT
			product_key,
			product_name,
			cost,
			CASE
				WHEN cost < 100 THEN 'Below 100'
				WHEN cost BETWEEN 100 AND 500  THEN '100-500'
				WHEN cost BETWEEN 500 AND 1000  THEN '500-1000'
				ELSE 'Above 1000'
			END cost_range
		FROM
			dim_products
	)
SELECT
	cost_range,
	COUNT(product_key) total_products
FROM
	product_segments
GROUP BY
	cost_range
ORDER BY
	total_products DESC;

-- Group customers into three segments based on their spending behavior:
-- VIP: at least 12 months of history and spending more than 5000
-- Regular: at least 12 months of history but spending 5000 or less
-- New: lifespan less than 12 months
-- And find the total number of customers by each group
WITH
	customer_spending AS (
		SELECT
			c.customer_key,
			SUM(f.sales_amount) total_spending,
			MIN(order_date) first_order,
			MAX(order_date) last_order,
			EXTRACT(
				YEAR
				FROM
					AGE (MAX(order_date), MIN(order_date))
			) * 12 + EXTRACT(
				MONTH
				FROM
					JUSTIFY_DAYS(AGE (MAX(order_date), MIN(order_date)))
			) lifespan
		FROM
			fact_sales f
			LEFT JOIN dim_customers c ON f.customer_key = c.customer_key
		GROUP BY
			c.customer_key
	)
SELECT
	customer_segment,
	COUNT(customer_key) total_customers
FROM
	(
		SELECT
			customer_key,
			CASE
				WHEN lifespan >= 12
				AND total_spending > 5000 THEN 'VIP'
				WHEN lifespan >= 12
				AND total_spending <= 5000 THEN 'Regular'
				ELSE 'New'
			END customer_segment
		FROM
			customer_spending
	)
GROUP BY
	customer_segment
ORDER BY
	total_customers DESC;

/* 
Customer Report
Consolidates key customer metrics and behaviors
Highlights:
1. Gathers essential fields such as names, ages, and transaction details
2. Segments customers into categories (VIP, Regular, New) and age groups
3. Aggregates customer-level metrics:
	total orders
	total sales
	total quantity purchased
	total products
	lifespan (in months)
4. Calculates valuable KPIs:
	recency (months since last order)
	average order value
	average monthly spend 
*/
CREATE OR REPLACE VIEW report_customers AS
WITH
	base_query AS (
		-- base query retrieves core columns from tables
		SELECT
			f.order_number,
			f.product_key,
			f.order_date,
			f.sales_amount,
			f.quantity,
			c.customer_key,
			c.customer_number,
			CONCAT(c.first_name, ' ', c.last_name) customer_name,
			EXTRACT(
				YEAR
				FROM
					AGE (NOW(), c.birthdate)
			) age
		FROM
			fact_sales f
			LEFT JOIN dim_customers c ON c.customer_key = f.customer_key
		WHERE
			order_date IS NOT NULL
	),
	customer_aggregation AS (
		SELECT
			customer_key,
			customer_number,
			customer_name,
			age,
			COUNT(DISTINCT order_number) total_orders,
			SUM(sales_amount) total_sales,
			SUM(quantity) total_quantity,
			COUNT(DISTINCT product_key) total_products,
			MAX(order_date) last_order_date,
			EXTRACT(
				YEAR
				FROM
					AGE (MAX(order_date), MIN(order_date))
			) * 12 + EXTRACT(
				MONTH
				FROM
					JUSTIFY_DAYS(AGE (MAX(order_date), MIN(order_date)))
			) lifespan
		FROM
			base_query
		GROUP BY
			customer_key,
			customer_number,
			customer_name,
			age
	)
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29  THEN '20-29'
		WHEN age BETWEEN 30 AND 39  THEN '30-39'
		WHEN age BETWEEN 40 AND 49  THEN '40-49'
		ELSE '50 and above'
	END age_group,
	CASE
		WHEN lifespan >= 12
		AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12
		AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_segment,
	last_order_date,
	EXTRACT(
		YEAR
		FROM
			AGE (NOW(), last_order_date)
	) * 12 + EXTRACT(
		MONTH
		FROM
			JUSTIFY_DAYS(AGE (NOW(), last_order_date))
	) recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- Compute average order value 
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END avg_order_value,
	-- Compute average monthly spend
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE ROUND(total_sales / lifespan, 0)
	END avg_monthly_spend
FROM
	customer_aggregation;

SELECT
	*
FROM
	report_customers;

SELECT
	age_group,
	COUNT(customer_number) total_customers,
	SUM(total_sales) total_sales
FROM
	report_customers
GROUP BY
	age_group;

/* 
Product Report
Consolidates key product metrics and behaviors
Highlights:
1. Gathers essential fields such as product name, category, subcategory, and cost
2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers
3. Aggregates product-level metrics:
	total orders
	total sales
	total quantity sold
	total customers (unique)
	lifespan (in months)
4. Calculates valuable KPIs:
	recency (months since last sale)
	average order revenue
	average monthly revenue 
*/
CREATE OR REPLACE VIEW report_products AS
WITH
	base_query AS (
		SELECT
			p.product_name,
			p.category,
			p.subcategory,
			p.cost,
			f.order_number,
			f.sales_amount,
			f.quantity,
			f.customer_key,
			order_date
		FROM
			fact_sales f
			LEFT JOIN dim_products p ON f.product_key = p.product_key
		WHERE
			order_date IS NOT NULL
	),
	product_aggregations AS (
		SELECT
			product_name,
			category,
			subcategory,
			cost,
			COUNT(DISTINCT order_number) total_orders,
			SUM(sales_amount) total_sales,
			SUM(quantity) total_quantity,
			COUNT(DISTINCT customer_key) total_customers,
			EXTRACT(
				YEAR
				FROM
					AGE (MAX(order_date), MIN(order_date))
			) * 12 + EXTRACT(
				MONTH
				FROM
					JUSTIFY_DAYS(AGE (MAX(order_date), MIN(order_date)))
			) lifespan,
			MAX(order_date) last_order_date
		FROM
			base_query
		GROUP BY
			product_name,
			category,
			subcategory,
			cost
	)
SELECT
	product_name,
	category,
	subcategory,
	cost,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	lifespan,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 50000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END prod_group,
	last_order_date,
	EXTRACT(
		YEAR
		FROM
			AGE (NOW(), last_order_date)
	) * 12 + EXTRACT(
		MONTH
		FROM
			JUSTIFY_DAYS(AGE (NOW(), last_order_date))
	) recency,
	total_sales / NULLIF(total_orders, 0) avg_order_revenue,
	ROUND(total_sales / NULLIF(lifespan, 0), 0) avg_monthly_revenue
FROM
	product_aggregations;

SELECT
	*
FROM
	report_products;

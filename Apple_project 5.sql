-- Apple Sales Dataset Project

CREATE DATABASE apple;

CREATE TABLE category
(
	category_id VARCHAR(255) PRIMARY KEY,
	category_name VARCHAR(255)
);

CREATE TABLE products
(
	product_id VARCHAR(255) PRIMARY KEY, 
	product_name VARCHAR(255),	
	category_id	VARCHAR(255),
	launch_date DATE,	
	price FLOAT,
	FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE CASCADE
);

CREATE TABLE stores
(
	store_id VARCHAR(255) PRIMARY KEY,	
    store_name VARCHAR(255),
    city VARCHAR(255),	
    country VARCHAR(255)
);

CREATE TABLE sales
(
sale_id VARCHAR(255) PRIMARY KEY, 
sale_date DATE,
store_id VARCHAR(255),
product_id VARCHAR(255),
quantity INT,
FOREIGN KEY (store_id) REFERENCES stores(store_id) ON DELETE CASCADE,
FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE warranty
(
	claim_id VARCHAR(255) PRIMARY KEY,	
    claim_date DATE,
    sale_id VARCHAR(255),
    repair_status VARCHAR(255),
    FOREIGN KEY(sale_id) REFERENCES sales (sale_id) ON DELETE CASCADE
);

SELECT * FROM category;
SELECT * FROM products;
SELECT * FROM stores;
SELECT * FROM sales;
SELECT * FROM warranty;

-- Improving Query Performance
	-- execution time before index : 338 ms
	-- execution time after index : 56 ms
EXPLAIN ANALYZE
SELECT * FROM sales WHERE product_id = 'P-44';

CREATE INDEX sales_product_id ON sales(product_id);
CREATE INDEX sales_store_id ON sales(store_id);
CREATE INDEX sales_sale_date ON sales(sale_date);


-- Q1: Find the number of stores in each country.
SELECT
	country,
    COUNT(store_id) AS total_stores
FROM stores
GROUP BY country
ORDER BY total_stores DESC;

-- Q2: Calculate the total number of units sold by each store.

SELECT
	s.store_id,
    st.store_name,
    SUM(quantity) AS total_quantity
FROM sales s
JOIN stores st
	ON s.store_id = st.store_id
GROUP BY 1,2
ORDER BY total_quantity DESC;

-- Q:3 Identify how many sales occurred in December 2023.
SELECT
    SUM(quantity) AS total_quantity,
    COUNT(sale_id) AS total_transaction
FROM sales
WHERE sale_date BETWEEN '2023-12-01' AND '2023-12-31';

SELECT
    SUM(quantity) AS total_quantity,
    COUNT(sale_id) AS total_transaction
FROM sales
WHERE YEAR(sale_date) = 2023 
  AND MONTH(sale_date) = 12;

-- Q:4 Determine how many stores have never had a warranty claim filed.
SELECT 
	COUNT(*) AS total_store
FROM stores
WHERE store_id NOT IN (
						SELECT 
							DISTINCT store_id
						FROM sales s
						RIGHT JOIN warranty w
							ON w.sale_id = s.sale_id);

-- Q:5 Calculate the percentage of warranty claims marked as "Rejected".
SELECT
	ROUND(COUNT(*)/ (SELECT COUNT(*) FROM warranty) * 100, 2) AS rejected_percentage
FROM warranty
WHERE repair_status = "Rejected";

-- Q:6 Identify which store had the highest total units sold in the last year.
SELECT 
	s.store_id,
    st.store_name,
    SUM(quantity) AS total_sales_unit
FROM sales s
JOIN stores st
	ON s.store_id = st.store_id
WHERE sale_date >= CURRENT_DATE - INTERVAL 1 YEAR 
GROUP BY s.store_id
ORDER BY total_sales_unit DESC
LIMIT 1;

-- Q:7 Count the number of unique products sold in the last year.
SELECT 
	s.product_id,
    p.product_name,
	SUM(quantity) AS total_sales
FROM sales s
JOIN products p
	ON s.product_id = p.product_id
WHERE sale_date >= CURRENT_DATE - INTERVAL 1 YEAR 
GROUP BY s.product_id
ORDER BY total_sales DESC;

-- Q:8 Find the average price of products in each category.
SELECT 
	p.category_id,
    c.category_name,
    ROUND(AVG(p.price), 2) AS avg_price
FROM products p
JOIN category c
	ON p.category_id = c.category_id
GROUP BY 1,2
ORDER BY avg_price DESC;

-- Q:9 How many warranty claims were filed in 2020?
SELECT 
	COUNT(*) AS total_warranty_claim_2020
FROM warranty
WHERE YEAR(claim_date) = 2020;

-- Q:10 For each store, identify the best-selling day based on highest quantity sold.
WITH daily_sales
AS
(
	SELECT
		store_id,
		DAYNAME(sale_date) AS sale_day,
		SUM(quantity) AS total_sale,
		RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) as ranking
	FROM sales
	GROUP BY 1,2
	ORDER BY store_id, total_sale DESC
)
SELECT 
	*
FROM daily_sales
WHERE ranking = 1
ORDER BY store_id, total_sale DESC;

-- Q:11 Identify the least selling product in each country for each year based on total units sold.
	-- least selling product, each country , each year
	-- products, store, sales
SELECT
	t1.country,
    t1.product_id,
    p.product_name,
    t1.yearly,
    t1.total_sale
FROM
(
	SELECT
		st.country,
		s.product_id,
		EXTRACT(YEAR FROM sale_date) AS yearly,
		SUM(quantity) AS total_sale,
		RANK() OVER(PARTITION BY st.country, EXTRACT(YEAR FROM sale_date) ORDER BY SUM(quantity) ASC) AS ranking
	FROM sales s
	JOIN stores st
		ON s.store_id = st.store_id
	GROUP BY 1,2,3
) AS t1
JOIN products p
	ON t1.product_id = p.product_id
WHERE ranking = 1;

-- Q:12: Calculate how many warranty claims were filed within 180 days of a product sale.
SELECT
	COUNT(*) as total_claim
FROM
(
	SELECT
		s.sale_date,
		w.claim_date,
		s.product_id,
		DATEDIFF(w.claim_date, s.sale_date) AS duration
	FROM warranty w
	JOIN sales s
		ON s.sale_id = w.sale_id
) AS t1
WHERE duration BETWEEN 0 AND 180;

-- Q:13 Determine how many warranty claims were filed for products launched in the last two years.
SELECT
	p.product_name,
    COUNT(w.claim_id) As total_claim,
    COUNT(s.sale_id) AS total_sales,
    ROUND(COUNT(w.claim_id)/COUNT(s.sale_id) * 100, 2) AS claim_percentage
FROM warranty w
RIGHT JOIN sales s
	ON w.sale_id = s.sale_id
JOIN products p
	ON p.product_id = s.product_id
WHERE p.launch_date >= CURRENT_DATE - INTERVAL 2 YEAR
GROUP BY p.product_name;

-- Q:14 List the months in the last three years where sales exceeded 5,000 units in the USA.
SELECT
    YEAR(s.sale_date) AS years,
    MONTH(s.sale_date) AS months,
	SUM(s.quantity) AS total_sales
FROM sales s
JOIN stores st 
	ON s.store_id = st.store_id
WHERE st.country = 'United States' 
AND s.sale_date >= CURRENT_DATE - INTERVAL 3 YEAR
GROUP BY years, months
HAVING total_sales > 5000
ORDER BY years, months; 

-- Q:15 Identify the product category with the most warranty claims filed in the last two years.
SELECT
	p.category_id,
    c.category_name,
    COUNT(claim_id) AS total_claim
FROM warranty w
LEFT JOIN sales s
	ON s.sale_id = w.sale_id
JOIN products p
	ON p.product_id = s.product_id
JOIN category c
	ON c.category_id = p.category_id
WHERE w.claim_date >= CURRENT_DATE - INTERVAL 2 YEAR
GROUP BY 1,2
ORDER BY total_claim  DESC;

-- Q:16 Determine the percentage chance of receiving warranty claims after each purchase for each country.
SELECT
	st.country,
    COUNT(w.claim_id) AS total_claim,
    SUM(s.quantity) AS total_sale,
	ROUND(COUNT(w.claim_id)/SUM(s.quantity)*100, 2) AS claim_percentage
FROM warranty w
RIGHT JOIN sales s
	ON w.sale_id = s.sale_id
JOIN stores st
	ON st.store_id = s.store_id
GROUP BY st.country
ORDER BY claim_percentage;

-- Q:17 Analyze the year-by-year growth ratio for each store.
	-- growth ratio (current-previous)/previous * 100
WITH sales_growth AS
(
SELECT
    st.store_id,
    st.store_name,
    YEAR(sale_date) as yearly,
    SUM(s.quantity * p.price) AS total_sales,
    LAG(SUM(s.quantity * p.price)) OVER(PARTITION BY st.store_id ORDER BY YEAR(sale_date)) AS previous_sales
FROM sales s
JOIN products p
	ON s.product_id = p.product_id
JOIN stores st
	ON s.store_id = st.store_id
GROUP BY st.store_id, st.store_name, yearly
)
SELECT
	store_id,
    store_name,
    yearly,
	previous_sales,
	total_sales AS current_year_sales,
    ROUND(((total_sales-previous_sales)/previous_sales)*100, 2) AS growth_rate
FROM sales_growth
WHERE previous_sales IS NOT NULL;

-- Q:18 Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
	-- warranty claim by price segment 

SELECT 
	CASE 
		WHEN p.price < 500 THEN "Less Expensive Product"
        WHEN p.price BETWEEN 500 AND 1000 THEN "Mid Expensive Product"
        ELSE "Expensive Product"
	END AS price_segment,
    COUNT(w.claim_id) AS total_claim
FROM warranty w 
JOIN sales s
	ON w.sale_id = s.sale_id
JOIN products p
	ON p.product_id = s.product_id
WHERE s.sale_date >= CURRENT_DATE - INTERVAL 5 YEAR
GROUP BY price_segment
ORDER BY total_claim;

-- Q:19 Identify the store with the highest percentage of "Completed" claims relative to total claims filed.

WITH completed_claim AS
(
SELECT
	s.store_id,
    COUNT(claim_id) as total_completed_claim
FROM warranty w
JOIN sales s
	ON s.sale_id = w.sale_id
WHERE w.repair_status = 'Completed'
GROUP BY s.store_id
),
total_claim AS
(
SELECT
	s.store_id,
    COUNT(claim_id) as total_claim
FROM warranty w
JOIN sales s
	ON s.sale_id = w.sale_id
GROUP BY s.store_id
)
SELECT
	cc.store_id,
    st.store_name,
    cc.total_completed_claim,
    tc.total_claim,
    ROUND(total_completed_claim/total_claim *100, 2) AS completed_claim_percentage
FROM completed_claim cc
JOIN total_claim tc
	ON cc.store_id = tc.store_id
JOIN stores as st
	ON tc.store_id = st.store_id
ORDER BY completed_claim_percentage DESC
LIMIT 1;


-- Q:20 Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.
	-- monthly running total of sales - each store - past four years 

WITH monthly_sales AS
(
SELECT
	s.store_id,
	YEAR(sale_date) AS yearly,
	MONTH(sale_date) AS monthly,
    SUM(p.price * s.quantity) AS total_revenue
FROM sales s
JOIN products p 
	ON s.product_id = p.product_id
WHERE s.sale_date >= CURRENT_DATE - INTERVAL 4 YEAR
GROUP BY 1,2,3
ORDER BY 1,2,3
)
SELECT
	store_id,
    yearly,
    monthly,
    total_revenue,
    SUM(total_revenue) OVER(PARTITION BY store_id ORDER BY yearly, monthly) AS running_total
FROM monthly_sales;

-- Q:21 Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
	-- sales trend -- segment from launch

SELECT
    p.product_name,
	CASE
		WHEN s.sale_date BETWEEN p.launch_date AND p.launch_date + INTERVAL 6 MONTH THEN '0-6 month'
        WHEN s.sale_date BETWEEN p.launch_date + INTERVAL 6 MONTH AND p.launch_date + INTERVAL 12 MONTH THEN '6-12 month'
        WHEN s.sale_date BETWEEN p.launch_date + INTERVAL 12 MONTH AND p.launch_date + INTERVAL 18 MONTH THEN '12-18 month'
        ELSE '18+'
        END AS duration_segment,
	SUM(s.quantity) AS total_sales
FROM sales s
JOIN products p
	ON s.product_id = p.product_id
GROUP BY 1,2
ORDER BY 1,3 DESC;




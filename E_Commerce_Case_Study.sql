-- Creating a database
CREATE DATABASE e_commerce;

-- Using a particular database
USE e_commerce;

-- Analyze the tables by describing them 
DESC customers;
DESC orderdetails;
DESC orders;
DESC products;

-- Market Segmentation Analysis
/* In this we are identifying the top 3 cities with the highest customers 
to determine key markets for targeted marketing and logistic optimization. */
SELECT 
    location, COUNT(*) AS number_of_customers
FROM
    customers
GROUP BY location
ORDER BY number_of_customers DESC
LIMIT 3;
-- INSIGHTS: Delhi, Chennai, Jaipur are the top 3 cities with highest number of customers


-- Engagement Depth Analysis
/* Determine the distribution of customers by the number of orders placed. This 
insight will help in segmenting customers into one-time buyers, occasional shoppers, 
and regular customers for tailored marketing strategies. */

/*
 Number of Orders       Terms
		1    			One-Time Buyer
	   2-4 				Occassional Shoppers
	    >4				Regular Customers
*/
SELECT * FROM orders;

SELECT 
    NumberOfOrders, COUNT(*) AS CustomerCount
FROM
    (SELECT 
        customer_id, COUNT(*) AS NumberOfOrders
    FROM
        orders
    GROUP BY customer_id) AS order_count
GROUP BY NumberOfOrders
ORDER BY NumberOfOrders;

/* INSIGHTS:
			1. As Number of Order increases the number of customer decreases
            2. Occasional shoppers are the biggest category
*/


-- Purchase High-Value Products
/* Identify products where the average purchase quantity per order is 
2 but with a high total revenue, suggesting premium product trends. */

SELECT * FROM orderdetails;

SELECT 
    product_id, 
    AVG(quantity) AS AvgQuantity, 
    SUM(quantity * price_per_unit) AS TotalRevenue
FROM orderdetails
GROUP BY product_id
HAVING AVG(quantity) = 2
ORDER BY TotalRevenue DESC;
/* INSIGHTS:
			1. Product 1 exhibit the highest total revenue */
            

-- Category - wise Customer Reach
/* For each product category, calculate the unique number of customers purchasing from it. 
This will help understand which categories have wider appeal across the customer base. */
SELECT * FROM products;
SELECT *  FROM orderdetails;
SELECT * FROM orders;

SELECT 
    p.category,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM products p
JOIN orderdetails od ON od.product_id = p.product_id
JOIN orders o ON o.order_id = od.order_id
GROUP BY p.category
ORDER BY unique_customers DESC;

/* INSIGHTS:
			1. Electronics is in high demand among the customers */
            

-- Sales Trend Analysis
/* Analyze the month-on-month percentage change in total sales to identify growth trends.*/

SELECT * FROM orders;

WITH sales AS(
	SELECT 
		date_format(str_to_date(order_date,'%Y-%m-%d'),'%Y-%m') AS Month,
        SUM(total_amount) AS TotalSales
	FROM orders
    GROUP BY Month
    )
SELECT 
	Month, 
    TotalSales, 
    ROUND(((TotalSales - LAG(TotalSales) OVER(ORDER BY Month))/ LAG(TotalSales) OVER(ORDER BY Month))*100,2) AS PercentChange
FROM sales;

/* INSIGHTS:
			1. February 2024 experience the largest decline.
            2. July and December 2023 experiece the largest growth in sales.
            3. Sales are Fluctuating thus showing no clear trend.*/


-- Average Order Value Fluctuation
/* Examine how the average order value changes month-on-month.Insights 
can guide pricing and promotional strategies to enhance order value. */

WITH avg_sales as (
	SELECT 
	date_format(order_date, '%Y-%m') as Month, 
    AVG(total_amount) as AvgOrderValue
    FROM orders
    GROUP BY Month
)
SELECT 
	Month, 
    AvgOrderValue,
    ROUND((AvgOrderValue - LAG(AvgOrderValue) OVER(ORDER BY Month)),2) as ChangeInValue
FROM avg_Sales
ORDER BY ChangeInValue DESC;

/* INSIGHTS:
			1. Decmeber is having the highest change in value. */
            

--  Inventory Refresh Sales
/* Based on sales data, identify products with the fastest turnover rates, 
suggesting high demand and the need for frequent restocking. */
SELECT * FROM orderdetails;

SELECT product_id, COUNT(*) as SalesFrequency
FROM orderdetails
GROUP BY product_id
ORDER BY SalesFrequency DESC
LIMIT 5;

/* INSIGHTS:
			1. product_id "7" has the highest turnover rates and needs to be restocked frequently.
*/


-- Low Engagement Products
/* List products purchased by less than 40% of the customer base, 
indicating potential mismatches between inventory and customer interest. */
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM orderdetails;
SELECT * FROM customers;

SELECT COUNT(*) FROM customers c;

SELECT 
	p.Product_id, 
    p.name AS Name,
    COUNT(DISTINCT c.customer_id) AS UniqueCustomerCount
FROM products p 
JOIN orderdetails od ON od.product_id = p.product_id
JOIN orders o ON o.order_id = od.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY p.Product_id, Name
HAVING UniqueCustomerCount < 0.4*(SELECT COUNT(DISTINCT customer_id) FROM customers);

/* INSIGHTS:
			1. Poor visibility might be the issue for this less thann 40% purchases.
            2. Smartphone and Wireless Earbuds have less than 40% engagement. */


-- Customer Acquisition Trends
/* Evaluate the month-on-month growth rate in the customer base to understand 
the effectiveness of marketing campaigns and market expansion efforts. */
SELECT * FROM orders;

WITH monthly_sales AS(
	SELECT customer_id, DATE_FORMAT(MIN(order_date),'%Y-%m') AS FirstPurchaseMonth
	FROM orders
	GROUP BY customer_id
)
SELECT FirstPurchaseMonth, COUNT(*) AS TotalNewCustomers
FROM monthly_sales
GROUP BY FirstPurchaseMonth
ORDER BY FirstPurchaseMonth;

/* INSIGHTS:
			1. Its a downtrend and company should more focus on its marketing Campaingns. */
            

-- Peak Sales Identification Period
/* Identify the months with the highest sales volume,aiding in planning for stock 
levels, marketing efforts, and staffing in anticipation of peak demand periods. */

SELECT * FROM orders;

SELECT DATE_FORMAT(order_date, '%Y-%m') AS Month, SUM(total_amount) as TotalSales
FROM orders
GROUP BY Month
ORDER BY TotalSales DESC
LIMIT 3;

/* INSIGHTS:
			1. September and December are the months of major sales and 
				it will require major restocking of productsand increased staffs. */
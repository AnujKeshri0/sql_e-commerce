**Project Overview**
Title: E-commerce Sales and Customer Insights Analysis

Description: This project analyzes e-commerce data to extract insights about sales performance, customer behavior, and product popularity. The goal is to use data-driven findings to support business decision-making, improve marketing strategies, and enhance customer satisfaction.

Project Objectives
Analyze Sales Performance: Understand total sales figures and trends over time to gauge business health.
Segment Customers: Identify different customer groups based on spending habits to tailor marketing efforts.
Evaluate Product Performance: Determine which products sell best and which have high return rates.
Conduct Cohort Analysis: Assess customer retention and repeat purchase behavior to improve customer loyalty.
    
Project Structure
Data Model:
Users
Orders_d
OrderItems
Products
    
Data Analysis:
SQL queries for sales performance, customer segmentation, product analysis, and cohort analysis.
Insights and Visualizations:

Key findings on sales trends, customer segments, top-selling products, and retention rates.
Charts and graphs to illustrate data visually.
    
Key Insights
Sales Performance: Total sales and average order value help gauge business health.
Customer Segmentation: Groups based on spending allow for targeted marketing.
Product Performance: Identifies best-sellers and areas for improvement based on returns.
Cohort Analysis: Measures customer loyalty and informs retention strategies.

-- This query calculates the total sales amount for each product.   
SELECT 
    p.product_name,
    SUM(oi.price * oi.quantity) AS total_sales
FROM 
    OrderItems oi
JOIN 
    Products p ON oi.product_id = p.product_id
GROUP BY 
    p.product_name
ORDER BY 
    total_sales DESC;

-- Total Orders by User
SELECT 
    u.username,
    COUNT(o.order_id) AS total_orders
FROM 
    Users u
LEFT JOIN 
    Orders_d o ON u.user_id = o.user_id
GROUP BY 
    u.username
ORDER BY 
    total_orders DESC;

-- Orders in the Last 30 Days:
SELECT 
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_sales
FROM 
    Orders_d
WHERE 
    order_date >= NOW() - INTERVAL 30 DAY;

-- Sales Trend Over Time:
SELECT 
    DATE(order_date) AS order_day,
    SUM(total_amount) AS total_sales
FROM 
    Orders_d
GROUP BY 
    order_day
ORDER BY 
    order_day;
    
    -- Most Active Users:

SELECT 
    u.username,
    COUNT(o.order_id) AS total_orders
FROM 
    Users u
JOIN 
    Orders_d o ON u.user_id = o.user_id
GROUP BY 
    u.username
ORDER BY 
    total_orders DESC
LIMIT 5;

-- Running Total of Sales
-- This query calculates a running total of sales for each day, showing how sales accumulate over time.

SELECT 
    DATE(order_date) AS order_day,
    SUM(total_amount) AS daily_sales,
    SUM(SUM(total_amount)) OVER (ORDER BY DATE(order_date)) AS running_total
FROM 
    Orders_d
GROUP BY 
    order_day
ORDER BY 
    order_day;

-- Top Products by Sales with Ranks
SELECT 
    p.product_name,
    SUM(oi.price * oi.quantity) AS total_sales,
    RANK() OVER (ORDER BY SUM(oi.price * oi.quantity) DESC) AS sales_rank
FROM 
    OrderItems oi
JOIN 
    Products p ON oi.product_id = p.product_id
GROUP BY 
    p.product_name
ORDER BY 
    sales_rank;

-- Customer Purchase Patterns
-- This query identifies users who have made multiple purchases and calculates their total spending.

SELECT 
    u.username,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spending
FROM 
    Users u
JOIN 
    Orders_d o ON u.user_id = o.user_id
GROUP BY 
    u.username
HAVING 
    total_orders > 1
ORDER BY 
    total_spending DESC;

 -- Monthly Sales Growth
-- This query calculates the percentage growth in sales from one month to the next.

WITH MonthlySales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount) AS total_sales
    FROM 
        Orders_d
    GROUP BY 
        month
)
SELECT 
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
    ((total_sales - LAG(total_sales) OVER (ORDER BY month)) / 
    NULLIF(LAG(total_sales) OVER (ORDER BY month), 0)) * 100 AS sales_growth_percentage
FROM 
    MonthlySales;

-- Products with No Sales
-- This query finds products that have never been sold.

SELECT 
    p.product_name
FROM 
    Products p
LEFT JOIN 
    OrderItems oi ON p.product_id = oi.product_id
WHERE 
    oi.order_item_id IS NULL;

-- Yearly Revenue
-- This query calculates total revenue per year.

SELECT 
    YEAR(order_date) AS order_year,
    SUM(total_amount) AS total_revenue
FROM 
    Orders_d
GROUP BY 
    order_year
ORDER BY 
    order_year;

-- Year-over-Year Sales Comparison
-- This query compares sales for each year to the previous year, highlighting growth or decline.

WITH YearlySales AS (
    SELECT 
        YEAR(order_date) AS order_year,
        SUM(total_amount) AS total_sales
    FROM 
        Orders_d
    GROUP BY 
        order_year
)
SELECT 
    current.order_year,
    current.total_sales,
    COALESCE(previous.total_sales, 0) AS previous_year_sales,
    (current.total_sales - COALESCE(previous.total_sales, 0)) AS sales_difference,
    CASE 
        WHEN previous.total_sales IS NULL THEN 'N/A'
        ELSE ROUND(((current.total_sales - previous.total_sales) / previous.total_sales) * 100, 2)
    END AS sales_growth_percentage
FROM 
    YearlySales current
LEFT JOIN 
    YearlySales previous ON current.order_year = previous.order_year + 1
ORDER BY 
    current.order_year;

-- User Segmentation by Spending
-- This query segments users based on their total spending into different tiers.
SELECT 
    u.username,
    SUM(o.total_amount) AS total_spending,
    CASE 
        WHEN SUM(o.total_amount) >= 1000 THEN 'Platinum'
        WHEN SUM(o.total_amount) BETWEEN 500 AND 999 THEN 'Gold'
        WHEN SUM(o.total_amount) BETWEEN 100 AND 499 THEN 'Silver'
        ELSE 'Bronze'
    END AS spending_tier
FROM 
    Users u
LEFT JOIN 
    Orders_d o ON u.user_id = o.user_id
GROUP BY 
    u.username
ORDER BY 
    total_spending DESC;

 -- Monthly Unique Customer Analysis
-- This query counts the number of unique customers who placed orders each month.

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(DISTINCT user_id) AS unique_customers
FROM 
    Orders_d
GROUP BY 
    month
ORDER BY 
    month;


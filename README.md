📊 **E-commerce Sales and Customer Insights Analysis**

**Description****
This project analyzes e-commerce data to extract insights about sales performance, customer behavior, and product popularity. The goal is to use data-driven findings to support business decision-making, improve marketing strategies, and enhance customer satisfaction.

**Project Objectives**
🟢 Analyze Sales Performance: Understand total sales figures and trends over time to gauge business health.
🔵 Segment Customers: Identify different customer groups based on spending habits to tailor marketing efforts.
🟣 Evaluate Product Performance: Determine which products sell best and which have high return rates.
🟠 Conduct Cohort Analysis: Assess customer retention and repeat purchase behavior to improve customer loyalty.

**Project Structure**
Data Model:
Users
Orders_d
OrderItems
Products

**Data Analysis:**
SQL queries for sales performance, customer segmentation, product analysis, and cohort analysis. Insights


**SQL Queries and Insights
-- 1. This query calculates the total sales amount for each product**
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
-- 💡 **Insight:** Reveals top-selling products, guiding marketing efforts and inventory decisions.

**-- 2. Total Orders by User**
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
**-- 💡 Insight:** Identifies frequent users for targeted marketing and loyalty programs.

**-- 3. Orders in the Last 30 Days**
SELECT 
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_sales
FROM 
    Orders_d
WHERE 
    order_date >= NOW() - INTERVAL 30 DAY;
**-- 💡 Insight:** Assesses current sales activity for timely marketing adjustments.

**-- 4. Sales Trend Over Time**
SELECT 
    DATE(order_date) AS order_day,
    SUM(total_amount) AS total_sales
FROM 
    Orders_d
GROUP BY 
    order_day
ORDER BY 
    order_day;
**-- 💡 Insight:** Highlights daily sales patterns to inform inventory management.

**-- 5. Most Active Users**
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
**-- 💡 Insight:** Tailors communication to top users, enhancing customer relationships.

**-- 6. Running Total of Sales**
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
**-- 💡 Insight:** Visualizes revenue accumulation, aiding financial planning.

**-- 7. Top Products by Sales with Ranks**
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
**-- 💡 Insight:** Ranks best-sellers, guiding marketing and inventory decisions.

**-- 8. Customer Purchase Patterns**
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
**-- 💡 Insight:** Highlights loyal customers for personalized marketing strategies.

**-- 9. Monthly Sales Growth**
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
**-- 💡 Insight:** Tracks monthly sales growth to spot trends and marketing effectiveness.

**-- 10. Products with No Sales**
SELECT 
    p.product_name
FROM 
    Products p
LEFT JOIN 
    OrderItems oi ON p.product_id = oi.product_id
WHERE 
    oi.order_item_id IS NULL;
**-- 💡 Insight:** Identifies unsold products for inventory management decisions.

**-- 11. Yearly Revenue**
SELECT 
    YEAR(order_date) AS order_year,
    SUM(total_amount) AS total_revenue
FROM 
    Orders_d
GROUP BY 
    order_year
ORDER BY 
    order_year;
**-- 💡 Insight:** Provides a high-level view of annual performance for strategic planning.

**-- 12. Year-over-Year Sales Comparison**
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
**-- 💡 Insight:** Compares annual sales to highlight growth trends and strategic adjustments.

**-- 13. User Segmentation by Spending**
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
**-- 💡 Insight:** Segments users for targeted promotions, enhancing customer satisfaction.

**-- 14. Monthly Unique Customer Analysis**
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(DISTINCT user_id) AS unique_customers
FROM 
    Orders_d
GROUP BY 
    month
ORDER BY 
    month;
**-- 💡 Insight:** Assesses customer acquisition and retention effectiveness.

Overall Findings
📈 Sales Trends: Consistent growth observed in sales, especially during promotional periods and holidays.
👥 Customer Insights: Active users tend to make repeat purchases, highlighting the effectiveness of loyalty programs.
📦 Product Popularity: Certain products consistently rank as best-sellers, indicating potential for upselling and cross-selling.
🔄 Retention Rates: Cohort analysis shows improvements in customer retention, with targeted marketing playing a significant role.

**Conclusion**
The E-commerce Sales and Customer Insights Analysis project effectively leverages data to provide valuable insights into sales performance and customer behavior.
The analysis has demonstrated how understanding sales trends, customer segments, and product performance can drive strategic decisions and enhance overall business success.


# Apple Sales Analytics: End-to-End SQL Project


## Project Overview

This project is designed to showcase advanced SQL querying techniques through the analysis of over 1 million rows of Apple retail sales data. The dataset includes information about products, stores, sales transactions, and warranty claims across various Apple retail locations globally. Using a series of complex SQL queries, I explored various business metrics such as sales trends, product performance, and customer service efficiency.

The goal was to transform raw data into actionable insights that could help the organization to identify the performance of different stores, find out the most and least selling products, optimize inventory, improve warranty processing and analyze year by year growth for each stores.

---

## Database Schema

The project uses five main tables:

1. **stores**: Contains information about Apple retail stores.
   - `store_id`: Unique identifier for each store.
   - `store_name`: Name of the store.
   - `city`: City where the store is located.
   - `country`: Country of the store.

2. **category**: Holds product category information.
   - `category_id`: Unique identifier for each product category.
   - `category_name`: Name of the category.

3. **products**: Details about Apple products.
   - `product_id`: Unique identifier for each product.
   - `product_name`: Name of the product.
   - `category_id`: References the category table.
   - `launch_date`: Date when the product was launched.
   - `price`: Price of the product.

4. **sales**: Stores sales transactions.
   - `sale_id`: Unique identifier for each sale.
   - `sale_date`: Date of the sale.
   - `store_id`: References the store table.
   - `product_id`: References the product table.
   - `quantity`: Number of units sold.

5. warranty**: Contains information about warranty claims.
   - `claim_id`: Unique identifier for each warranty claim.
   - `claim_date`: Date the claim was made.
   - `sale_id`: References the sales table.
   - `repair_status`: Status of the warranty claim (e.g., Paid Repaired, Warranty Void).

## Business Problems Solved

The SQL scripts address 20+ specific business questions, categorized by complexity:

**Store Distribution**: Counting the number of stores per country.
**Volume Tracking**: Calculating total units sold per store and identifying sales spikes.
**Product Insights**: Finding average prices per category and identifying unique product counts.
**Claim Efficiency**: Calculating the percentage of "Warranty Void" claims.
**Timeliness**: Identifying claims filed within the first 180 days of purchase to evaluate product reliability.
**Claim Success Rate**: Identifying the store with the highest percentage of 'Completed' and 'Rejected' claims relative to total claims filed to monitor service quality."
**Best-Selling Days**: Using window functions to identify the specific day of the week each store hits peak sales.
**Growth Ratios**: Analyzing year-over-year growth for individual store locations.
**Product Lifecycle**: Segmenting sales trends into periods (0-6 months, 6-12 months, etc.) to understand the sales decay curve of new launches
**Least Selling Products**: Identifying the lowest-performing product in each country per year using ranking functions."
**Geographic Sales Trends**: Filtering high-volume sales months (over 5,000 units) specifically for the United States market."
**Correlation**: Analyzing the relationship between product price points and the frequency of warranty claims

## Project Focus

This project primarily focuses on developing and showcasing the following SQL skills:

- **Complex Joins and Aggregations**: Demonstrating the ability to perform complex SQL joins and aggregate data meaningfully.
- **Window Functions**: Using advanced window functions for running totals, growth analysis, and time-based queries.
- **Data Segmentation**: Analyzing data across different time frames to gain insights into product performance.
- **Correlation Analysis**: Applying SQL functions to determine relationships between variables, such as product price and warranty claims.
- **Real-World Problem Solving**: Answering business-related questions that reflect real-world scenarios faced by data analysts.


## Dataset

- **Size**: 1 million+ rows of sales data.
- **Period Covered**: The data spans multiple years, allowing for long-term trend analysis.
- **Geographical Coverage**: Sales data from Apple stores across various countries.

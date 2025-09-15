Project Overview

This project is an end-to-end retail analytics solution for RetailNova Inc., a mid-sized retail & e-commerce company. The goal was to analyze sales, customer, product, store, and returns data to generate actionable business insights that improve profitability, customer retention, and product performance.

The project covers data cleaning, preprocessing, SQL analysis, and interactive dashboards in Power BI.

Data Sources

sales_data.csv → Transaction-level sales (order, product, quantity, discounts, amount)

customers.csv → Customer demographics (age, gender, region, signup date)

products.csv → Product details (category, brand, cost, margin)

stores.csv → Store info (type, region, operating cost)

returns.csv → Returns data (reasons, categories, dates)

Tools & Technologies

Python: Pandas, NumPy, Seaborn, Matplotlib, Scikit-learn

SQL: Data modeling, queries for KPIs & business questions

Power BI: Interactive dashboards, slicers, KPIs, charts

GitHub: Version control & documentation

Project Workflow

Data Cleaning & EDA (Python)

Missing value imputation (KNN, logical fills)

Outlier detection (IQR, Z-score)

Standardization of text fields (region, gender, brands)

Feature engineering (Age groups, Profit per unit, Margin categories, Return reason grouping)

SQL Analysis

Designed ER diagram & relational schema

Created metrics: profit, revenue per customer, return rate, etc.

Wrote queries to answer 10+ business questions

Dashboard Development (Power BI)

Built 5 dashboards with KPIs, slicers, and charts

Added interactivity for region, date, customer segmentation

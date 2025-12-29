# Notes

## Intro

This is a SQL Data Analysis project. The project involves

- creating tables,
- importing data from csv files,
- querying the tables,
- grouping,
- ordering,
- `JOIN`s,
- using aliases for table names,
- subqueries,
- CTEs,
- window functions,
- aggregate functions,
- date functions.

The project can be coded along following this video:  
[SQL Data Analyst Portfolio Project](https://www.youtube.com/watch?v=2jGhQpbzHes)

My code differs from the video, as I implemented this project in PostgreSQL, whereas the video is based on a different SQL Database Management System.

## Project Details

The project starts with creating 3 tables and importing 3 datasets into these tables:

- 2 dimension tables and
- 1 fact table.

The project proceeds with

- Database exploration that involves listing the columns in all the user-created tables,
- Trend analysis that involves reviewing the sales ordered by the date, finding total sales, total number of customers, and total quantity of orders for days, months, and years,
- Cumulative analysis that involves calculating the total sales and cumulative total sales per month, cumulative total sales that resets each year, average price for each year and moving average price across years,
- Performance Analysis that involves comparing the product sales to average sales, and previous year's sales,
- Proportionality Analysis that involves calculating the sales per each category and what percentage a category constitutes in total sales,
- Data Segmentation that involves grouping the data based on specific ranges such as classifying products by their costs, grouping customers depending if they are VIP, regular, or new.

After analyzing the data from different aspects, I generate customer and product reports and save them as views in the database. I also query those views to further show how they might be used to easily regenerate the analysis.

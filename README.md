# Walmart_Sales_Analysis

## Table of Contents
- [Data Cleaning](#data-cleaning)
- [Exploratory Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Findings](#findings)
- [Recommendation](#recommendation)
- [Limitations](#limitations)


### Project Overview
---

The purpose of this data analytics project is to analyze Walmart's sales data to identify key trends and patterns that can inform business strategies and improve decision-making processes. By leveraging advanced analytical techniques, the project aims to provide actionable insights into sales performance, customer behavior, and inventory management.

### Data Source(s)

Walmart Retail Data: Sourced from Kaggle via [here]([https://catalog.data.gov/dataset/freight-analysis-framework](https://www.kaggle.com/datasets/mikhail1681/walmart-sales )).\
Walmart Stock Data: Sourced from Kaggle via [here]( https://www.kaggle.com/datasets/middlehigh/walmart-stocks-from-2000).

### Tools

  - SQL - Data Analysis
  - Python - Cleaning and SQLite Database Setup

### Data Cleaning

Loaded Raw CSV into Python

```Python
import sqlite3
import pandas as pd

#reading CSV's
df1 = pd.read_csv('Walmart_Sales.csv')
df2 = pd.read_csv('WMT.csv')

```
Basic Data Cleaning and Formatting Dates
 
```python
#basic data clean
df1.columns = df1.columns.str.strip()
df2.columns = df2.columns.str.strip()

#cleaning date formats
df1['Date'] = pd.to_datetime(df1['Date'], format='%d-%m-%Y').dt.strftime('%Y-%m-%d')
df2['Date'] = pd.to_datetime(df2['Date'], format='%m/%d/%Y').dt.strftime('%Y-%m-%d')

```

Setting up SQLite database
```Python
#connect to sql lite database
conn = sqlite3.connect('Walmart_Data.db')

#upload each dataframe to a seperate table within the new database
df1.to_sql('Walmart_Sales_Table', conn, if_exists='replace', index=False)
df2.to_sql('Walmart_Stock_Table', conn, if_exists='replace', index=False)

#close connection
conn.close

```

### Exploratory Data Analysis

#### Key Areas

1. Trend Analysis:
   - Rescaled time data to identify weekly, monthly, yearly, and seasonl trends in sales activity given the 2 years of data.
   - Identifed key performance indicators for sales given time values.

2. Correlation Analysis:
   - Assessed relationships between weekly_sales, fuel price, temperatures, consumer price index, unemployment, dates, and stock price.

### Data Analysis 


### Findings 


### Recommendation


### Limitations
-

[Go Back Up](#walmart_sales_analysis)

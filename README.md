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

### Standout Data Analysis 

#### Stores by Average Weekly Sales
```sql
select
    store,
    round(avg(weekly_sales),2) as avg_daily_sales
from 
    walmart_sales_table
group by 
    store
order by 
    avg_daily_sales desc;

```
Top five stores are respectively: #20, #4, #14, #13, #2
Worst two are respectively: #33, #44

#### Store Sales Performance on Holidays vs Non-Holidays Difference
```sql
select
    store,
    round((avg_holiday_sales - avg_nonholiday_sales),0) as holiday_sales_difference,
    round(
        (((avg_holiday_sales-avg_nonholiday_sales)/avg_nonholiday_sales) * 100),2
        ) || '%' as holiday_to_nonholiday_sales_rate
from (
    select
        store,
        round(avg(
                case
                when holiday_flag = 0 
                then weekly_sales end
                )
            ,2) as avg_nonholiday_sales,
        round(avg(
            case 
            when holiday_flag = 1 
            then weekly_sales end
            ),2) as avg_holiday_sales
    from walmart_sales_table
    group by store 
    )
order by holiday_to_nonholiday_sales_rate desc

```
Identified store #10 has the largest positive difference in sales output on holidays to non-holidays
Identified that the worst performing store #37 has a negative difference in sales output on holidays to non-holidays
Stores #44, #36, #38, and #30 also have negative difference in sales output on holidays to non-holidays

#### Calculating PCC between Unemployment and Weekly Sales
```sql
select
    (count(*) * sum(unemployment * weekly_sales)- sum(unemployment) * sum(weekly_sales))
    /
    sqrt(
        (count(*) * sum(unemployment * unemployment) - power(sum(unemployment),2))
        *
        (count(*) * sum(weekly_sales * weekly_sales) - power(sum(weekly_sales),2))
    ) as Temp_Sales_Correlation
from
    walmart_sales_table

```
The result comes out to -.10
Given this sample, the PCC of -.10 reveals a weak negative correlation between unemployment and weekly sales.

#### Best and Worst Months for Sales
```sql
with monthly_sales as (
    select
        strftime('%m',date) as month,
        round(sum(weekly_sales),2) as total_sales
    from
        walmart_sales_table
    group by
        month
)
selectc
    month,
    total_sales
from
    monthly_sales
order by
    total_sales desc;

```
Top three months of the year for sales: July, April, June
Worst three months of the year for sales: January, November, May

### Findings 

1. On average, store sales perform better on holidays than non-holidays given the sample.
2. Increasing unemployment will decrease weekly sales.
3. There is no linearity given the data currently regarding weekly sales performance to dates however better and worse performing months can still be noted.

### Recommendation

1. Given the increase in sales on holidays, all positively performing stores should invest in increased marketing and customer experience amplifiers coming up to those days. Stores that perform poorer on holidays than non-holidays require further research utilizing location data (location is absent in data set) to find the cause for decreased sales.
   - IE: Low performing store on holiday may be used more as a quick drop in location while its larger sister stores may be used as the primary stores for holiday shopping.
2. As Walmart is an enterprise that focuses on providing affordable products to its customers, statistics such as unemployment and by extension inflation and other macroeconomic indicators must be carefully tracked by corporate in order to anticipate and account for neccesary price changes to remain competitive in sales during harsher seasons of unemployment and economic difficulty.
3. Given the identification that some months perform better and some worse, each store's regional and local management should accordingly pivot to these changes. IE: Certain months in a season such as July in Summer require more emphasis on marketing and sales rather than June and August. Lower performing months can be strategic times for stores to prepare for upcoming better performing months as well as necistate corporate to research further indiciators that affect sales during these times. 


### Limitations

- Certain current data in data sets including temperatures, CPI, and fuel prices are unfortunately of little significance at the moment. Additional data gathering is neccesitated. Decisions for further data research can be built off of recomendations.
- Essential data such as location bars the user of the data set from conducting additional data research externally to build on top of the original data set. 

[Go Back Up](#walmart_sales_analysis)

----------------------------
-- Walmart Sales Analysis --
----------------------------

--View table
select
    *
from
    Walmart_Sales_Table ;

select
    *
from
    Walmart_Stock_Table ;


------------------------
--OVERALL SALES TRENDS--
------------------------

--Weekly Sales Trends
select
    strftime('%Y', date) AS year,
    strftime('%W', date) AS week,
    round(sum(weekly_sales),2) as total_weekly_sales
from
    walmart_sales_table
group by
    year, week
order by
    year, week;


--Monthly Sales Trends
select
    strftime('%Y', date) AS year,
    strftime('%m', date) AS month,
    round(sum(weekly_sales),2) as total_monthly_sales
from
    walmart_sales_table
group by
    year, month
order by
    year, month;


--Year-Over-Year Sales Comparison
with monthly_sales as (
    select
        strftime('%Y', date) AS year,
        strftime('%m', date) AS month,
        sum(weekly_sales) as total_monthly_sales
    from
        walmart_sales_table
    group by
        year, month
    order by
        year, month
)
select
    a.month as month,
    round(a.total_monthly_sales,2) as sales_current_year,
    round(b.total_monthly_sales,2) as sales_previous_year,
    round(((a.total_monthly_sales - b.total_monthly_sales)* 100 / b.total_monthly_sales), 2) as YoY_growth_percentage
from
    monthly_sales a
join 
    monthly_sales b
on
    a.month = b.month
and 
    cast(a.year as INTEGER) = cast(b.year AS INTEGER) + 1
order by
    a.year, a.month;


--Month-Over-Month Sales Comparison
with monthly_sales as (
    select
        strftime('%m', date) AS month,
        sum(weekly_sales) as total_monthly_sales
    from
        walmart_sales_table
    group by
        month
),
    MoM_Comparison AS (
        select
            month,
            total_monthly_sales,
            lag(total_monthly_sales) over (order by month) as previous_month_sales
        from
            monthly_sales
)
select
    month,
    round(total_monthly_sales,2) as current_month_sales,
    round(previous_month_sales,2) as previous_month_sales,
    case
        when previous_month_sales = 0 then null
        else round(((total_monthly_sales - previous_month_sales) / previous_month_sales * 100),2)
    end as MoM_percentage_change
from 
    MoM_Comparison
Order by
    month;
    

--Seasonal Sales Trends (Quarterly)
select
    strftime('%Y', date) AS year,
    CASE 
        WHEN strftime('%m', date) IN ('01', '02', '03') THEN 'Q1'
        WHEN strftime('%m', date) IN ('04', '05', '06') THEN 'Q2'
        WHEN strftime('%m', date) IN ('07', '08', '09') THEN 'Q3'
        WHEN strftime('%m', date) IN ('10', '11', '12') THEN 'Q4'
    END AS quarter,
    round(sum(weekly_sales),2) AS total_quarterly_sales
from
    walmart_sales_table
group by
    year, quarter
order by
    year, quarter;


--Moving Average (3 month) for Smoothing Trends
select
    a.date,
    strftime('%Y', a.date) AS year,
    strftime('%m', a.date) AS month,
    a.weekly_sales AS current_month_sales,
    ROUND(AVG(b.weekly_sales), 2) AS moving_avg_3_months
from 
    walmart_sales_table a
join
    walmart_sales_table b 
on
    (strftime('%Y', a.date) = strftime('%Y', b.date) AND
     CAST(strftime('%m', a.date) AS INTEGER) - CAST(strftime('%m', b.date) AS INTEGER) BETWEEN 0 AND 2)
    OR
    (strftime('%Y', a.date) - strftime('%Y', b.date) = 1 AND
     CAST(strftime('%m', a.date) AS INTEGER) - CAST(strftime('%m', b.date) AS INTEGER) = -10)
group by 
    a.date
order by
    a.date;




----------------------------
--ANALYSIS by STORE NUMBER--
----------------------------

--Total sales by store number
--Top store is #20
select
    store,
    round(sum(weekly_sales),0) as total_sales
from
    Walmart_Sales_Table
group by
    store
order by 
    total_sales desc;


--Average sales by store number
select
    store,
    round(avg(weekly_sales),2) as avg_daily_sales
from 
    walmart_sales_table
group by 
    store
order by 
    avg_daily_sales desc;


--Average temps by store number
--Coldest store on average is #7. Warmest store on average is #33
 select 
    store,
    round(avg(temperature),2) as average_temps
from
    Walmart_Sales_Table
group by   
    store
order by 
    average_temps


--Calculating PCC (Pearson Correlation Coefficient) between temps and weekly_sales
select
    (count(*) * sum(temperature * weekly_sales)- sum(temperature) * sum(weekly_sales))
    /
    sqrt(
        (count(*) * sum(temperature * temperature) - sum(temperature)*sum(temperature))
        *
        (count(*) * sum(weekly_sales * weekly_sales) - sum(weekly_sales) * sum(weekly_sales))
    ) as Temp_Sales_Correlation
from
    walmart_sales_table

-- Result is (-0.06)
--Given that -0.06 is very close to 0, there is little to no linear correlation between temperature and sales given this sample of stores.


--Average Sales not on Holiday
-- Highest average is store #20 and lowest is #33
select
    store,
    round(avg(
        case
            when holiday_flag = 0 
            then weekly_sales end
            ),2) as avg_nonholiday_sales
from
    walmart_sales_table
group by
     store
order by
    average_nonholiday_sales desc;


--Average Sales on Holiday
-- Highest average is store #20 and lowest is #33
select 
    store,
    round(avg(
        case 
            when holiday_flag = 1 
            then weekly_sales end
            ),2) as avg_holiday_sales
from
    walmart_sales_table
group by 
    store
order by 
    average_holiday_sales desc;


--By how much do sales on average perform better on holidays than on non-holidays?
--Largest positive rate performance on holiday is from store #16. Worst performance is store #30.

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
--if order by holiday_sales_diference desc
--Store #10 with largest positive difference in sales output on holidays to nonholidays
--Store #37 with worst difference (negatve) in sales output on holidays to nonholidays


--Analyzing average weekly sales and fuel price
select
    round(avg(weekly_sales),2) as avg_weekly_sales,
    round(avg(fuel_price),2) as avg_fuel_price,
    store
from
    walmart_sales_table
group by
    store
order by 
    avg_weekly_sales desc;


--Calculating PCC between fuel_prices and weekly_sales
select
    (count(*) * sum(fuel_price * weekly_sales)- sum(fuel_price) * sum(weekly_sales))
    /
    sqrt(
        (count(*) * sum(fuel_price * fuel_price) - power(sum(fuel_price),2))
        *
        (count(*) * sum(weekly_sales * weekly_sales) - power(sum(weekly_sales),2))
    ) as Temp_Sales_Correlation
from
    walmart_sales_table

-- Result is 0.009
--Given that the result is close to 0, there is little to no correlation between fuel price and weekly_sales given this sample.


--Average CPI by store (including avg temps)
--Store #9, #8, #11, and #3 were tied with highest avg CPI's. Over 10 stores tied for lowest.

select
    store,
    round(avg(CPI),2) as Avg_CPI,
    round(avg(temperature),2) as Avg_Temp
from
    walmart_sales_table
group by
    store
order by Avg_CPI desc; 


--Calculating PCC between CPI and weekly_sales
select
    (count(*) * sum(CPI * weekly_sales)- sum(CPI) * sum(weekly_sales))
    /
    sqrt(
        (count(*) * sum(CPI * CPI) - power(sum(CPI),2))
        *
        (count(*) * sum(weekly_sales * weekly_sales) - power(sum(weekly_sales),2))
    ) as Temp_Sales_Correlation
from
    walmart_sales_table

--Result is -0.07.
--Given that the result is close to o, there is little to no correlation between CPI and weekly_sales given the sameple.


--Calculating PCC between CPI and temperature
select
    (count(*) * sum(CPI * temperature)- sum(CPI) * sum(temperature))
    /
    sqrt(
        (count(*) * sum(CPI * CPI) - power(sum(CPI),2))
        *
        (count(*) * sum(temperature * temperature) - power(sum(temperature),2))
    ) as Temp_Sales_Correlation
from
    walmart_sales_table

--Result is 0.17
--The result reveals a weak positive correlation between CPI and temperature given the sample.


--Calculating PCC between unemployment and weekly_sales
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

-- Result is -0.10
--The result reveals a weak negative correlation between unemployment and weekly_sales given the sample.


--Finding Best and Worst Months for Sales (Including Years)
with monthly_sales as (
    select
        strftime('%Y-%m',date) as month,
        round(sum(weekly_sales),2) as total_sales
    from
        walmart_sales_table
    group by
        month
)
select
    month,
    total_sales
from 
    monthly_sales
order by 
    total_sales desc;


--Finding Best and Worst Months for Sales (not including years)
with monthly_sales as (
    select
        strftime('%m',date) as month,
        round(sum(weekly_sales),2) as total_sales
    from
        walmart_sales_table
    group by
        month
)
select
    month,
    total_sales
from
    monthly_sales
order by
    total_sales desc;

--Best month is July
--Worst month is January


--Finding Best and Worst Days of the Month for Sales
with daily_sales as (
    select
        cast(strftime('%d', date) as INTEGER) as day,
        weekly_sales
    from
        walmart_sales_table
),
average_sales_per_day as (
    select
        day,
        avg(weekly_sales) as avg_daily_sales
    from
        daily_sales
    group by
        day
)
select
    day,
    round(avg_daily_sales,2) as avg_daily_sales
from
    average_sales_per_day
order by
    avg_daily_sales desc;

--Average best day in any given month is 24 followed by 23 and 17
--Average worst day in any given month is 14 preceeded by 27 and 31


--PCC of correlation of day of month to daily sale amount
with daily_sales as (
    select
        cast(strftime('%d', date) as INTEGER) as day,
        weekly_sales
    from
        walmart_sales_table
)
select
    (count(*) * sum(day * weekly_sales)- sum(day) * sum(weekly_sales))
    /
    sqrt(
        (count(*) * sum(day * day) - power(sum(day),2))
        *
        (count(*) * sum(weekly_sales * weekly_sales) - power(sum(weekly_sales),2))
    ) as Temp_Sales_Correlation
from
    daily_sales
--Result is -.017
--Given result is close to 0, there is no correlation day of given month and daily sales amount given the sample.




-----------------------------------------
--ANALYSIS USING SALES AND STOCK TABLES--
-----------------------------------------

-- Sales vs. Stock Price Correlation
with monthly_sales as (
    select
        strftime('%Y-%m',date) as month,
        sum(weekly_sales) as total_sales
    from
        walmart_sales_table
    group by
        month
),
monthly_stock_prices as (
    select
        strftime('%Y-%m',date) as month,
        avg(close) as avg_close_price,
        avg("adj close") as avg_adj_close_price
    from
        walmart_stock_table
    group by
        month
)
select
    sa.month,
    total_sales,
    avg_close_price,
    avg_adj_close_price
from
    monthly_sales sa
join
    monthly_stock_prices SP on sa.month = sp.month
order by
    sa.month;


--Weekly Sales vs. Current Stock Price
select
    sa.date,
    sa.weekly_sales,
    st.close as stock_close
    st."adj_close" as stock_adj_close
from
    walmart_sales_table sa
join
    walmart_stock_table st
on 
    sa.date = st.date
order by
    sa.date;


--Stock Price Trends and Sales Seasonality  (Adding on top of MoM Sales Analysis)
with monthly_sales as (
    select
        date,
        strftime('%m', date) AS month,
        sum(weekly_sales) as total_monthly_sales
    from
        walmart_sales_table
    group by
        month
),
    MoM_Comparison AS (
        select
            date,
            month,
            total_monthly_sales,
            lag(total_monthly_sales) over (order by month) as previous_month_sales
        from
            monthly_sales
)
select
    mo.month,
    st.close as stock_close,
    st."adj close" as stock_adj_close,
    round(mo.total_monthly_sales,2) as current_month_sales,
    round(mo.previous_month_sales,2) as previous_month_sales,
    case
        when mo.previous_month_sales = 0 then null
        else round(((mo.total_monthly_sales - mo.previous_month_sales) / mo.previous_month_sales * 100),2)
    end as MoM_percentage_change
from 
    MoM_Comparison mo
join
    Walmart_Stock_Table st
on
    mo.date = st.date
Order by
    month;



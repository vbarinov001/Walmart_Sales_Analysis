import sqlite3
import pandas as pd

#read csv 1
df1 = pd.read_csv('Walmart_Sales.csv')
df2 = pd.read_csv('WMT.csv')

#basic data clean
df1.columns = df1.columns.str.strip()
df2.columns = df2.columns.str.strip()

#cleaning date formats
df1['Date'] = pd.to_datetime(df1['Date'], format='%d-%m-%Y').dt.strftime('%Y-%m-%d')
df2['Date'] = pd.to_datetime(df2['Date'], format='%m/%d/%Y').dt.strftime('%Y-%m-%d')

#connect to sql lite database
conn = sqlite3.connect('Walmart_Data.db')

#upload each dataframe to a seperate table within the new database
df1.to_sql('Walmart_Sales_Table', conn, if_exists='replace', index=False)
df2.to_sql('Walmart_Stock_Table', conn, if_exists='replace', index=False)

#close connection
conn.close
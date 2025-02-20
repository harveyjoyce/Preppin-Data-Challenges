import os
import pandas as pd
import numpy as np

from pandas import concat, ExcelFile, melt, read_csv

# Create a file path
file_path = r"C:\Users\HarveyJoyce\Downloads\PDC_unprepped\PD 2021 Wk 4 Input.xlsx"

# Load Excel File tabs
xls = pd.ExcelFile(file_path)

# Append all tabs together, create a Store column from the data
dfIn = None
for sheet in [a for a in xls.sheet_names if a != 'Targets']:
    dfNew = xls.parse(sheet)
    dfNew['Store'] = sheet
    dfIn = dfNew if dfIn is None else concat([dfIn, dfNew], ignore_index=True)

# Pivot 'New' and 'Existing' columns
o1 = dfIn.melt(id_vars=['Date', 'Store'], 
        var_name='Customer Type - Product',
        value_name='Values')

# Rename the measure created by the Pivot as 'Products Sold'
o1.rename(columns={'Values':'Products Sold'}, inplace=True)

# Split the former column headers to form: Customer Type and Product
o1[['Customer Type', 'Product']] = o1['Customer Type - Product'].str.split(' - ', expand=True)

# Turn Date into Quarter
o1['Date'] = pd.to_datetime(o1['Date'], format="%Y/%m/%d")
o1['Quarter'] = o1['Date'].dt.quarter 

# Sum up the products sold by Store and Quarter 
output_1 = o1.groupby(
    ['Store', 'Quarter']
    ).agg(
        Products_Sold = ('Products Sold', 'sum'),
    ).reset_index()

# Join on Target Sheet
target = pd.read_excel(file_path, sheet_name = 'Targets')

joined = output_1.merge(target, how='left', on=['Quarter', 'Store'])

# Calculate the variance between each Store's Quarterly actual sales and the target
joined['Variance to Target'] = joined['Products_Sold'] - joined['Target']

# Rank the Store's based on the Variance to Target in each quarter
joined['Rank'] = joined.groupby('Quarter')['Variance to Target'].rank(ascending=False)

joined = joined.sort_values(by=['Quarter', 'Rank'])

# Create output file path
output_path = r"C:\Users\HarveyJoyce\Downloads\PDC_prepped\PD 2021 Wk 4 output.csv"

# Output the data as a .csv file
joined.to_csv(output_path, index=False)
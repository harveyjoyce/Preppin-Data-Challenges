import os
import pandas as pd
import numpy as np

from pandas import concat, ExcelFile, melt, read_csv

# Create a file path
file_path = r"C:\Users\HarveyJoyce\Downloads\PDC_unprepped\PD 2021 Wk 3 Input.xlsx"

# Load Excel File tabs
xls = pd.ExcelFile(file_path)

# Append all tabs together, create a Store column from the data
dfIn = None
for sheet in xls.sheet_names:
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

# Aggregate to form two separate outputs of the number of products sold by:
# 1. Product, Quarter
output_1 = o1.groupby(
    ['Product', 'Quarter']
    ).agg(
        Product_Sold = ('Products Sold', 'sum'),
    ).reset_index()

# 2. Store, Customer Type, Product
output_2 = o1.groupby(
    ['Store', 'Customer Type','Product']
    ).agg(
        Product_Sold = ('Products Sold', 'sum'),
    ).reset_index()

# Create output file paths
output1_path = r"C:\Users\HarveyJoyce\Downloads\PDC_prepped\PD 2021 Wk 3_output1.csv"
output2_path = r"C:\Users\HarveyJoyce\Downloads\PDC_prepped\PD 2021 Wk 3_output2.csv"

# Output the data as a .csv file
output_1.to_csv(output1_path, index=False)
output_2.to_csv(output2_path, index=False)
import os
import pandas as pd
import numpy as np
import re

# Create a file path
file_path = r"C:\Users\HarveyJoyce\Downloads\PDC_unprepped\PD 2021 Wk 2 Input - Bike Model Sales (3).csv"

# Read .csv file
df = pd.read_csv(file_path)

# Clean up the Model field to leave only the letters to represent the Brand of the bike
df['Brand'] = df['Model'].str.extract(r'([a-zA-Z]+)') # Using Regex to keep only letters

# Workout the Order Value using Value per Bike and Quantity
df['Order Value'] = df['Quantity'] * df['Value per Bike']

# Aggregate Value per Bike, Order Value and Quantity by Brand and Bike Type to form:
# - Quantity Sold
# - Order Value
# - Average Value Sold per Brand, Type
o1 = df.groupby(
    ['Brand', 'Bike Type']
    ).agg(
        Quantity_Sold = ('Quantity', 'sum'),
        Order_Value = ('Order Value', 'sum'),
        Avg_Bike_Value_per_Brand_Type = ('Value per Bike', 'mean')
    ).reset_index()

# Round any averaged values to one decimal place to make the values easier to read
o1['Avg_Bike_Value_per_Brand_Type'] = o1['Avg_Bike_Value_per_Brand_Type'].round(1)

# Calculate Days to ship by measuring the difference between when an order was placed and when it was shipped as 'Days to Ship'
df['Order Date'] = pd.to_datetime(df['Order Date'], format="%d/%m/%Y")
df['Shipping Date'] = pd.to_datetime(df['Shipping Date'], format="%d/%m/%Y")
df['Days to Ship'] = (df['Shipping Date'] - df['Order Date']).dt.days

# Aggregate Order Value, Quantity and Days to Ship by Brand and Store to form:
# - Total Quantity Sold
# - Total Order Value
# - Average Days to Ship
o2 = df.groupby(
    ['Brand', 'Store']
    ).agg(
        Total_Quantity_Sold = ('Quantity', 'sum'),
        Total_Order_Value = ('Order Value', 'sum'),
        Avg_Days_to_Ship = ('Days to Ship', 'mean')
    ).reset_index()

# Round any averaged values to one decimal place to make the values easier to read
o2['Avg_Days_to_Ship'] = o2['Avg_Days_to_Ship'].round(1)

# Create output file paths
output1_path = r"C:\Users\HarveyJoyce\Downloads\PDC_prepped\PD 2021 Wk 2_output1.csv"
output2_path = r"C:\Users\HarveyJoyce\Downloads\PDC_prepped\PD 2021 Wk 2_output2.csv"

# Output the data as a .csv file
o1.to_csv(output1_path, index=False)
o2.to_csv(output2_path, index=False)
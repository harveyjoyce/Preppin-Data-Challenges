# Preppin' Data Challenge 2021 Week 1

import os
import pandas as pd
import numpy as np

# Create a file path
file_path = r"C:\Users\HarveyJoyce\Downloads\PDC_unprepped\PD 2021 Wk 1 Input - Bike Sales (2).csv"

# Read .csv file
df = pd.read_csv(file_path)

# Split the 'Store-Bike' field into 'Store' and 'Bike' 
df[['Store', 'Bike']] = df['Store - Bike'].str.split(' - ', expand=True)

# Clean up the 'Bike' field to leave just three values in the 'Bike' field (Mountain, Gravel, Road)
df['Bike'] = df['Bike'].str.lower() # Make everything lower case
df['Bike'] = df['Bike'].str[0] # Keep the first letter of each word
df['Bike'] = np.where(df['Bike']=='m','Mountain',np.where(df['Bike']=='r','Road','Gravel')) # Match the first letter to the type

# Create a 'Quarter' and 'Day of Month' fields
df['Date'] = pd.to_datetime(df['Date']) # Convert the string field to datetime
df['Quarter'] = df['Date'].dt.quarter # Format to quarter
df['Day of Month'] = df['Date'].dt.day # Format to day of month

# Remove 'Store-Bike' and 'Date' fields
df = df.drop(['Store - Bike', 'Date'], axis=1)

# Remove the first 10 orders
df = df[df['Order ID'] >= 11]

# Create an output file path
output_path = r"C:\Users\HarveyJoyce\Downloads\PDC_prepped\PD 2021 Wk 1 output.csv"

# Output the data as a .csv file
df.to_csv(output_path, index=False)
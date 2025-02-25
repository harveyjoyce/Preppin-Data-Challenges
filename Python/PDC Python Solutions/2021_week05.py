import os
import pandas as pd
import numpy as np
import re

# Create a file path
file_path = r"C:\Users\HarveyJoyce\Downloads\PDC_unprepped\PD 2021 Wk 5 Input.csv"

# Read .csv file
df = pd.read_csv(file_path)

df['From Date'] = pd.to_datetime(df['From Date'], format="%d/%m/%Y")
df['1'] = 1

# For each Client, work out who the most recent Account Manager is
am = df.groupby(
    ['Client', 'Client ID', 'Account Manager', 'From Date']
).agg(
        Count = ('1', 'sum'),
    ).reset_index()

am = am.drop(['Count'], axis=1)

mxdate = am.groupby(
    ['Client']
).agg(
        Max_Date = ('From Date', 'max'), # Finds the most recent date for each client
    ).reset_index()

# Keep all the training data separate
tr = df.groupby(
    ['Training', 'Contact Email', 'Contact Name', 'Client']
).agg(
        Count = ('1', 'sum'),
    ).reset_index()

tr = tr.drop(['Count'], axis=1)

# Filter the data so that only the most recent Account Manager remains
merged_am = pd.merge(am, mxdate, left_on=['Client', 'From Date'], right_on=['Client', 'Max_Date'], how='inner')
output = pd.merge(tr, merged_am, left_on=['Client'], right_on=['Client'], how='inner')

output = output.drop(['Max_Date'], axis=1)

# Create an output file path
output_path = r"C:\Users\HarveyJoyce\Downloads\PDC_prepped\PD 2021 Wk 5 output.csv"

# Output the data as a .csv file
output.to_csv(output_path, index=False)

print(output)


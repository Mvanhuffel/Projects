import pandas as pd
import cpi

# Read the CSV file
df = pd.read_csv('merged_file.csv')

# Mark all duplicates as True and keep them based on Asset, Deposit, State, and Acquiring Institution
duplicates = df.duplicated(subset=['Bank Name'], keep=False)

# Convert the 'Closing Date' column to datetime
df['Year'] = pd.to_datetime(df['Year'], format='%Y')

# Filter out any rows with dates after 2022-01-01
df = df[df['Year'] < pd.to_datetime('2023-01-01')]

# Convert the 'Asset' and 'Deposit' columns to integers
df['Asset'] = df['Asset'].astype(int)
df['Deposit'] = df['Deposit'].astype(int)

# Create new columns for inflation-adjusted 'Asset' and 'Deposit' values
df['Inflation-Adjusted Asset'] = df.apply(lambda x: cpi.inflate(int(x['Asset']), int(x['Year'].year)), axis=1)
df['Inflation-Adjusted Deposit'] = df.apply(lambda x: cpi.inflate(int(x['Deposit']), int(x['Year'].year)), axis=1)

# Write the updated DataFrame to a new CSV file
df.to_csv('inflation_adjusted.csv', index=False)












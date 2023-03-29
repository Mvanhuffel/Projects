import pandas as pd

df1 = pd.read_csv('bfb-data.csv')
df2 = pd.read_csv('banklist.csv')

merged_df = pd.merge(df1, df2, on=['Bank Name', 'Closing Date'])

merged_df.to_csv('merged_file.csv', index=False)


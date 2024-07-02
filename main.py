import pandas as pd
import os 
import time

def compute_data_and_exp():

    df = pd.read_csv("data/activity.csv")

    df["BLOCK_TIME"] = pd.to_datetime(df['BLOCK_TIME']).astype(int) // 10**9

    df = df.sort_values(by=['BLOCK_TIME'])

    # get the next txn involving the same (user, mint)
    df["NEXT_BLOCK_TIME"] = df.groupby(["USER"])["BLOCK_TIME"].shift(-1)
    df["NEXT_BLOCK_TIME"] = df["NEXT_BLOCK_TIME"].fillna(int(time.time())) # last wonderland pre exp unix timestamp

    # Calculate the difference in minutes
    df['MINUTES_IN_BETWEEN'] = (df['NEXT_BLOCK_TIME'] - df['BLOCK_TIME']) / 60

    # Group by USER and calculate cumulative balance
    df['CUMULATIVE_BALANCE'] = df.groupby(["USER"])['AMOUNT'].cumsum()

    # Calculate the EXP column based on the condition
    df['EXP'] = df['MINUTES_IN_BETWEEN'] * df['CUMULATIVE_BALANCE'] * 10

    df = df.groupby("USER", as_index=False)["EXP"].sum()
    df = df.sort_values(by=['EXP'])

    df = df[df["EXP"] > 0]

    # Wallets to exclude
    exclude_values = ['AYhux5gJzCoeoc1PoJ1VxwPDe22RwcvpHviLDD1oCGvW', 'GRwm4EXMyVwtftQeTft7DZT3HBRxx439PrKq4oM6BwoZ']

    # Filtering out rows with exclude_values in column_name
    df = df[~df['USER'].isin(exclude_values)]

    # Save the resulting DataFrame to a new CSV file
    df.to_csv('exp.csv', index=False)

compute_data_and_exp()

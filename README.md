# How to obtain pathSOL data

1. Run the Dune query

```sql
SELECT
    BLOCK_TIME,
    TOKEN_BALANCE_OWNER as USER,
    (post_token_balance - pre_token_balance) as AMOUNT
FROM
solana.account_activity
WHERE
    BLOCK_TIME >= TIMESTAMP '2024-04-09 19:30:00'
    AND token_mint_address = 'pathdXw4He1Xk3eX84pDdDZnGKEme3GivBamGCVPZ5a'
    AND tx_success = TRUE
```

2. Get the execution ID from Dune (button that says "Last run ...")

3. Use the execution ID and Dune API key as parameters for the bash script

```bashEXECUTION_ID
sh get_data.sh <EXECUTION_ID> <API_KEY>
```

4. Run the python SCRIPT

```python
python main.py
```

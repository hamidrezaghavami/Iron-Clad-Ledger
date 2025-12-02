-- user table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    firstName TEXT,
    lastName TEXT,
    country TEXT
);

-- Saving Account table 
CREATE TABLE savingaccount (
    users SERIAL PRIMARY KEY,
    price NUMERIC(10, 2) NOT NULL,
    balance NUMERIC(10,2) NOT NULL
);

-- Checking Account table ( money checker )
CREATE TABLE checkingaccount (
    users SERIAL PRIMARY KEY,
    price NUMERIC(10,2) NOT NULL,
    balance NUMERIC(10,2) NOT NULL CHECK ( balance >= 0 )
);

-- currency specifics types
CREATE TYPE price AS ENUM ( 'USD', 'EUR', 'GPB' );

-- check balance non negative
ALTER TABLE checkingaccount ADD CONSTRAINT check_non_negative_column CHECK ( balance >= 0 );

-- Needs from_account_id, to_account_id, amount, timestamp, and status.
SELECT account_id FROM TABLE users WHERE account_status = "B1"
AND account_change_date BETWEEN '31/12/2025' AND '31/12/2026'
AND valid_to_date = '31/12/2100'
AND NOT EXISTS ( SELECT * FROM TABLE checkingaccount WHERE 
checkingaccount.account_id = savingaccount.account_id
AND checkingaccount.account_status = 'B1'
AND savingaccount.account_change_date < savingaccount.account_change_date );
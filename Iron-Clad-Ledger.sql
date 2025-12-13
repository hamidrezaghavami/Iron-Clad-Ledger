-- user table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    country TEXT
);

-- Saving Account table 
CREATE TABLE savingaccount (
    id SERIAL PRIMARY KEY,
    price NUMERIC(10, 2) NOT NULL,
    balance NUMERIC(10,2) NOT NULL
);

-- Checking Account table
CREATE TABLE checkingaccount (
    id SERIAL PRIMARY KEY,
    price NUMERIC(10,2) NOT NULL,
    balance NUMERIC(10,2) NOT NULL DEFAULT 0.00 
);

-- Transactions tables 
CREATE TABLE Transactions (
    id SERIAL PRIMARY KEY,
    from_account_id INTEGER,
    to_account_id INTEGER,
    amount NUMERIC(10, 2),
    timestamp TIMESTAMP,
    status TEXT
);

-- currency specifics types
CREATE TYPE currency_type AS ENUM ( 'USD', 'EUR', 'GBP' );
 
-- Add this column to your users or accounts
ALTER TABLE checkingaccount ADD COLUMN currency currency_type NOT NULL DEFAULT 'USD';

-- check balance non negative
ALTER TABLE checkingaccount ADD CONSTRAINT check_balance_positive CHECK ( balance >= 0 );

-- Add missing columns to Users
ALTER TABLE users ADD COLUMN account_status TEXT;
ALTER TABLE users ADD COLUMN account_change_date DATE;
ALTER TABLE users ADD COLUMN valid_to_date DATE;

-- Add missing columns to checking account
ALTER TABLE checkingaccount ADD COLUMN account_status TEXT;
ALTER TABLE checkingaccount ADD COLUMN account_change_date DATE;

-- Add missing columns to Saving account
ALTER TABLE savingaccount ADD COLUMN account_change_date DATE;

-- Needs from_account_id, to_account_id, amount, timestamp, and status.
SELECT id
FROM users
WHERE account_status = 'B1'
AND account_change_date BETWEEN '2025-12-31' AND '2026-12-31'
AND valid_to_date = '2100-12-31'
AND NOT EXISTS (
    SELECT 1
    FROM checkingaccount, savingaccount
    WHERE checkingaccount.id = users.id
    AND savingaccount.id = users.id
    AND checkingaccount.account_status = 'B1'
    AND savingaccount.account_change_date < users.account_change_date
);

-- inserting some data into our user table
INSERT INTO users ( id, first_name, last_name, country )
VALUES
(1, 'Elena', 'Rossi', 'Italy'),
(2, 'David', 'Kim', 'South Korea'),
(3, 'Fatima', 'Al-Sayed', 'Egypt'),
(4, 'Lukas', 'Weber', 'Germany'),
(5, 'Sofia', 'Silva', 'Brazil');

-- insert data for Saving account
INSERT INTO savingaccount ( price, balance )
VALUES
( 10.00, 500.00),
( 12.00, 400.00);

-- insert data for checking account
INSERT INTO checkingaccount ( price, balance, currency )
VALUES
(15.00, 1200.00, 'EUR'),
(13.00, 1255.00, 'USD');

-- PL/pgSQL Function
CREATE OR REPLACE FUNCTION transfer_funds ( from_id INTEGER, to_id INTEGER, amount NUMERIC ) RETURNS BOOLEAN AS
$$
DECLARE
v_balance NUMERIC;

BEGIN
-- Check Sender's Balance
SELECT balance INTO v_balance
FROM savingaccount
WHERE id = from_id;

IF v_balance < amount THEN
RAISE NOTICE 'Money in account is not enough! Current: %', v_balance;
RETURN false;
END IF;

-- Deduct from Sender
UPDATE savingaccount
SET balance = balance - amount
WHERE id = from_id;
RAISE NOTICE 'Deduction successful! Old Balance %', v_balance;

-- Add to Receiver
UPDATE savingaccount
SET balance = balance + amount
WHERE id = to_id;


-- Record Transaction
INSERT INTO Transactions ( from_account_id, to_account_id, amount, timestamp, status )
VALUES ( from_id, to_id, amount, NOW(), 'completed');

RETURN true;

END;
$$
LANGUAGE plpgsql;
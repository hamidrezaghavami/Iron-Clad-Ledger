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

-- 3. Checking Account table
CREATE TABLE checkingaccount (
    id SERIAL PRIMARY KEY,
    price NUMERIC(10,2) NOT NULL,
    balance NUMERIC(10,2) NOT NULL DEFAULT 0.00
);

-- currency specifics types
CREATE TYPE currency_type AS ENUM ( 'USD', 'EUR', 'GBP' );
 
-- Add this column to your users or accounts
ALTER TABLE checking_accounts ADD COLUMN currency currency_type NOT NULL DEFAULT 'USD';

-- check balance non negative
ALTER TABLE checking_accounts ADD CONSTRAINT check_balance_positive CHECK ( balance >= 0 );

-- Needs from_account_id, to_account_id, amount, timestamp, and status.
SELECT account_id
FROM users
WHERE account_status = 'B1'
AND account_change_date BETWEEN '2025-12-31' AND '2026-12-31'
AND valid_to_date = '2100-12-31'
AND NOT EXISTS (
    SELECT * FROM checkingaccount 
    WHERE checkingaccount.account_id = users.account_id
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

-- PL/pgSQL Functions
CREATE OR REPLACE FUNCTION transfer_funds ( from_id UUID, to_id UUID, amount NUMERIC ) RETURNS BOOLEAN AS
$$
DECLARE
v-balance NUMERIC;

BEGIN
SELECT balance INTO v_balance
FROM savingaccount
WHERE users = from_id;

IF v_balance < amount THEN
RAISE NOTICE 'Money in account is not enough! Current: %', v_balance;
RETURN true;

ELSE
RAISE NOTICE 'Balance is zero or less', v_balance;
RETURN false;
END IF;

-- Deduct from Sender
UPDATE savingaccount
SET balance = balance - amount
WHERE users= from_id;
RAISE NOTICE 'Deduction successful! Old Balance %', v_balance;

-- Add to Receiver
UPDATE savingaccount
SET balance = balance + amount
WHERE users = to_id;


-- Record Transaction
INSERT INTO Transactions ( from_account_id, to_account_id, amount, timestamp, status )
VALUES ( form_id, to_id, amount, NOW(), 'completed');

RETURN true;

END;
$$
LANGUAGE plpgsql;
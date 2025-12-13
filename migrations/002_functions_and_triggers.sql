-- PL/pgSQL Function
CREATE OR REPLACE FUNCTION transfer_funds ( from_id INTEGER, to_id INTEGER, amount NUMERIC ) RETURNS BOOLEAN AS
$$
DECLARE
v_balance NUMERIC;
v_sender_country TEXT;
v_reciver_country TEXT;
v_fee NUMERIC := 0.00; -- default 0

BEGIN
-- check for International Transfer
SELECT country INTO v_sender_country FROM users WHERE id = from_id;
SELECT country INTO v_reciver_country FROM users WHERE id = to_id;

-- calculate fee (1% if countries are different)
IF v_sender_country <> v_reciver_country THEN
v_fee := amount * 0.01;
END IF;

-- Check Sender's Balance
SELECT balance INTO v_balance
FROM savingaccount
WHERE id = from_id;

IF v_balance < (amount + v_fee ) THEN
RAISE NOTICE 'Not enough funds! Balance: %, Needed: %', v_balance, (amount + v_fee);
RETURN false;
END IF;

-- Deduct from Sender
UPDATE savingaccount
SET balance = balance - (amount + v_fee )
WHERE id = from_id;
RAISE NOTICE 'Deduction successful! Fee paid: %', v_fee;

-- Add to Receiver ( only amount )
UPDATE savingaccount
SET balance = balance + amount
WHERE id = to_id;


-- Record Transaction
INSERT INTO Transactions ( from_account_id, to_account_id, amount, timestamp, status, fee )
VALUES ( from_id, to_id, amount, NOW(), 'completed', v_fee);

RETURN TRUE;

END;
$$
LANGUAGE plpgsql;
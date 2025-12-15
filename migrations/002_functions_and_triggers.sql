CREATE OR REPLACE FUNCTION transfer_funds ( from_id INTEGER, to_id INTEGER, amount NUMERIC ) RETURNS BOOLEAN AS
$$
DECLARE
    v_balance NUMERIC;
    v_sender_country TEXT;
    v_receiver_country TEXT;
    v_fee NUMERIC := 0.00;
    v_system_user_id INTEGER;

BEGIN
    -- 1. Get Countries
    SELECT country INTO v_sender_country FROM users WHERE id = from_id;
    SELECT country INTO v_receiver_country FROM users WHERE id = to_id;

    -- 2. Calculate Fee (1% if countries are different)
    IF v_sender_country <> v_receiver_country THEN
        v_fee := amount * 0.01;
    END IF;

    -- 3. Check Sender's Balance
    SELECT balance INTO v_balance 
    FROM savingaccount 
    WHERE id = from_id
    FOR UPDATE; -- missing line

    IF v_balance < (amount + v_fee) THEN
        RAISE NOTICE 'Not enough funds! Balance: %, Needed: %', v_balance, (amount + v_fee);
        RETURN FALSE;
    END IF;

    -- 4. Deduct from Sender
    UPDATE savingaccount
    SET balance = balance - (amount + v_fee)
    WHERE id = from_id;

    -- 5. Add to Receiver
    UPDATE savingaccount
    SET balance = balance + amount
    WHERE id = to_id;

    -- 6. DEPOSIT FEE TO SYSTEM BANK
    IF v_fee > 0 THEN
        -- Find System Bank User ID
        SELECT id INTO v_system_user_id FROM users WHERE first_name = 'System' AND last_name = 'Bank' LIMIT 1;
        
        -- Deposit Fee into the account belonging to that User ID
        UPDATE savingaccount
        SET balance = balance + v_fee
        WHERE user_id = v_system_user_id;
    END IF;

    -- 7. Record Transaction
    INSERT INTO Transactions ( from_account_id, to_account_id, amount, timestamp, status, fee )
    VALUES ( from_id, to_id, amount, NOW(), 'completed', v_fee );

    RETURN TRUE;

END;
$$
LANGUAGE plpgsql;
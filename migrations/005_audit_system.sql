-- status column to account
ALTER TABLE savingaccount ADD COLUMN status VARCHAR(20) DEFAULT 'active';
ALTER TABLE checkingaccount ADD COLUMN status VARCHAR(20) DEFAULT 'active';

-- creating audit log table
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id INTEGER NOT NULL,
    column_name TEXT NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_at TIMESTAMP DEFAULT NOW()
);

-- brain trigger function
CREATE OR REPLACE FUNCTION log_changes()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if Last Name changed
    IF TG_TABLE_NAME = 'users' AND OLD.last_name <> NEW.last_name THEN
        INSERT INTO audit_logs (table_name, record_id, column_name, old_value, new_value)
        VALUES ('users', OLD.id, 'last_name', OLD.last_name, NEW.last_name);
    END IF;

    -- Check if Account Status changed (Works for both Saving and Checking)
    IF (TG_TABLE_NAME = 'savingaccount' OR TG_TABLE_NAME = 'checkingaccount') 
       AND OLD.status <> NEW.status THEN
        INSERT INTO audit_logs (table_name, record_id, column_name, old_value, new_value)
        VALUES (TG_TABLE_NAME, OLD.id, 'status', OLD.status, NEW.status);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- watchers the trigger
-- watch the user table
CREATE TRIGGER audit_users_trigger
AFTER UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION log_changes();

-- watch the saving account table
CREATE TRIGGER audit_saving_trigger
AFTER UPDATE ON savingaccount
FOR EACH ROW
EXECUTE FUNCTION log_changes();

-- watch the checking account table
CREATE TRIGGER audit_checking_trigger
AFTER UPDATE ON checkingaccount
FOR EACH ROW
EXECUTE FUNCTION log_changes();

/* 
watcher tables and pgsql function above It automatically records
"What it was" (OLD) and "What it is now"
(NEW) into your audit_logs table.
*/
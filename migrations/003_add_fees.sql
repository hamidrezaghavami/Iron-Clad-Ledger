CREATE TABLE Transactions (
    id SERIAL PRIMARY KEY,
    from_account_id INTEGER,
    to_account_id INTEGER,
    amount NUMERIC(10, 2),
    timestamp TIMESTAMP,
    status TEXT,
    fee NUMERIC(10, 2) NOT NULL DEFAULT 0.00 -- prevent Oh No migration
);
-- Create Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- Create Saving Account Table
CREATE TABLE savingaccount (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    price NUMERIC(10, 2),
    balance NUMERIC(10, 2)
);

-- Create Checking Account Table
CREATE TABLE checkingaccount (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    balance NUMERIC(10, 2)
);

CREATE TABLE Transactions (
    id SERIAL PRIMARY KEY,
    from_account_id INTEGER,
    to_account_id INTEGER,
    amount NUMERIC(10,2),
    timestamp TIMESTAMP,
    status TEXT,
    fee NUMERIC(10,2) NOT NULL DEFAULT 0.00
);

INSERT INTO users ( id, first_name, last_name, country ) VALUES
(1, 'Elena', 'Rossi', 'Italy'),
(2, 'David', 'Kim', 'South Korea'),
(3, 'Fatima', 'Al-Sayed', 'Egypt'),
(4, 'Lukas', 'Weber', 'Germany'),
(5, 'Sofia', 'Silva', 'Brazil'),
(99, 'System', 'Bank', 'Switzerland');

-- seed data for savingaccount 
INSERT INTO savingaccount (user_id, price, balance) VALUES
(1, 10.00, 1000.00),
(2, 10.00, 1000.00),
(3, 10.00, 1000.00),
(99, 0.00, 0.00);

-- Seed Checking Accounts
INSERT INTO checkingaccount (user_id, balance) VALUES
(1, 1200.00),
(2, 1255.00);
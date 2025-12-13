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
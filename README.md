The Iron-Clad Ledger

📖 #Overview

The Iron-Clad Ledger is a high-integrity financial database system built entirely within PostgreSQL.

Unlike traditional architectures that rely on application-layer logic for data consistency, this project enforces business rules, transactional integrity, and race condition prevention directly at the database level using PL/pgSQL Stored Procedures, Triggers, and strict Schema Constraints.

The goal is to simulate a banking environment where data loss is mathematically impossible, handling multi-currency accounts, atomic transfers, and automated auditing.

🚀 #Key Features

ACID Compliance: All fund transfers utilize atomic transactions with rollback capabilities to ensure money is never created or destroyed during failures.

Concurrency Control: Implements SELECT ... FOR UPDATE row locking to prevent race conditions (double-spending) during simultaneous high-frequency transactions.

Strict Typing: Utilizes NUMERIC types for precise financial calculations (avoiding floating-point errors) and INET for security logging.

Automated Auditing: Database triggers automatically record state changes to sensitive tables (Users/Accounts) into an immutable audit_logs table.

Performance: Optimized reporting using Materialized Views and Window Functions for monthly statements.

🛠 #Database Schema

The core logic revolves around four primary entities:

users: Identity management with PII protections.

accounts: Ledger accounts with strict non-negative constraints and currency isolation.

transactions: Double-entry bookkeeping records.

audit_logs: Historical tracking of data mutations.

💻 #Installation & Setup

Prerequisites

PostgreSQL 14 or higher.

psql CLI tool or a GUI like pgAdmin/DBeaver.

Quick Start

Clone the repository:

git clone [https://github.com/hamidrezaghavami/iron-clad-ledger.git](https://github.com/hamidrezaghavami/iron-clad-ledger.git)
cd iron-clad-ledger


Initialize the Database:

psql -U postgres -f init_schema.sql


Load Seed Data (Optional):

psql -U postgres -d ledger_db -f seeds.sql


⚙️ #Usage

Executing a Transfer

This system uses Stored Procedures to handle logic. Do not insert into the transactions table directly.

-- Transfer $100.00 from Account ID 1 to Account ID 5
CALL transfer_funds(
    sender_id => 1,
    receiver_id => 5,
    amount => 100.00
);


Generating a Monthly Statement

Reports are generated via optimized views to avoid N+1 query performance issues.

SELECT * FROM monthly_user_summary 
WHERE user_id = 1 
AND month = '2023-10';


🧪 #Testing Concurrency

To verify the system's resilience against race conditions, you can run the provided concurrency script (Python/Bash) which attempts to fire 50 simultaneous transfers from a single account.

Expected Result: Correct balance deduction without going negative.

📚 #Concepts Demonstrated

This project serves as a practical implementation of advanced RDBMS concepts:

Database Normalization (3NF)

Pessimistic Locking strategies

Stored Procedures (PL/pgSQL)

Database Migrations & Versioning

Query Optimization (EXPLAIN ANALYZE)

📝 #License

This project is licensed under the MIT License.
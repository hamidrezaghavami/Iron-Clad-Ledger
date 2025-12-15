# 🏦 The Iron-Clad Ledger

**A High-Integrity Banking Database System built with PostgreSQL.**

## 📖 Overview
The **Iron-Clad Ledger** is a robust backend database system designed to handle multi-currency accounts, secure money transfers, and automated monthly reporting.
The core philosophy of this project is data integrity: it is architected to make it impossible to "lose" money, even in the event of server crashes or concurrent high-volume transactions.

Unlike standard CRUD applications, this system enforces business logic directly at the database level using Stored Procedures, Triggers, and Strict Constraints.

---

## 🚀 Key Features & Engineering Challenges

### 1. 🛡️ Strict Schema & Data Safety (Phase 1)
**Zero Negative Balances:** Implemented CHECK constraints to ensure account balances never drop below zero at the database level.
**Precision Math:** utilized NUMERIC/DECIMAL types instead of FLOAT or DOUBLE to prevent floating-point rounding errors common in financial software.
**Multi-Currency Support:** Strict enforcement of currency codes (USD, EUR, GBP) per account.

### 2. 💸 ACID-Compliant Money Transfers (Phase 2)
**Atomic Transactions:** handles debits and credits in a single atomic block using **PL/pgSQL Transaction Management**.
**Race Condition Handling:** Solved potential double-spending issues by implementing row-level locking (SELECT ... FOR UPDATE) to handle simultaneous transaction requests safely.
**Automatic Rollbacks:** If any step fails (e.g., insufficient funds or locked account), the entire transaction rolls back to prevent data inconsistency.

### 3. 🌍 International Logic & Migrations (Phase 3)
**Zero-Downtime Migration:** Successfully altered the live schema to support new features without corrupting existing transaction history.
**Automated Fee System:** Implemented logic to detect international transfers (e.g., USA to Turkey) and automatically apply a **1% transaction fee**.
**System Revenue Tracking:** Fees are automatically routed to a designated "System Bank Account".

### 4. ⚡ Performance Optimization (Phase 4)
**Efficient Reporting:** Created a monthly_user_summary view to calculate deposits, withdrawals, and net worth instantly.
**Solving the N+1 Problem:** Optimized query performance by implementing Database Indexes on the transactions table (from_account_id, to_account_id, timestamp). This reduced report generation time from linear scans to constant-time index seeks (<50ms).

### 5. 👻 "Invisible" Audit System (Phase 5)
**Database Triggers:** Implemented a "Watcher" system that automatically intercepts UPDATE commands on sensitive tables.
**Tamper-Proof Logging:** Any change to a user's name or account status is automatically recorded in an audit_logs table with OLD and NEW values, completely independent of the application layer.

---

## 🛠️ Technical Stack
**Database:** PostgreSQL
**Languages:** SQL, PL/pgSQL
**Concepts:** ACID Transactions, Stored Procedures, Triggers, Views, Indexing, Normalization.

---

## 📂 Project Structure
The project is built incrementally via the following migration scripts:

* 001_initial_schema.sql: Sets up Users, Accounts, and Transaction tables.
* 002_transaction_logic.sql: Defines the atomic transfer_funds stored procedure.
* 003_migration_fees.sql: (Merged into initial schema for stability).
* 004_reporting_views.sql: Adds performance indexes and reporting views.
* 005_audit_system.sql: Implements triggers for audit logging.

## 🏁 How to Run
To deploy the full system, execute the SQL files in order:

```bash
# 1. Initialize Schema
psql -U postgres -d banking_db -f 001_initial_schema.sql

# 2. Add Transaction Logic
psql -U postgres -d banking_db -f 002_transaction_logic.sql

# 3. Apply Migrations
psql -U postgres -d banking_db -f 003_migration_fees.sql

# 4. Create Reports & Indexes
psql -U postgres -d banking_db -f 004_reporting_views.sql

# 5. Attach Audit Triggers
psql -U postgres -d banking_db -f 005_audit_system.sql
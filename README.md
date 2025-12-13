# 🏦 The Iron-Clad Ledger

**A High-Integrity Banking Database System built with PostgreSQL.**

## 📖 Overview
[cite_start]The **Iron-Clad Ledger** is a robust backend database system designed to handle multi-currency accounts, secure money transfers, and automated monthly reporting[cite: 3]. [cite_start]The core philosophy of this project is data integrity: it is architected to make it impossible to "lose" money, even in the event of server crashes or concurrent high-volume transactions[cite: 4].

Unlike standard CRUD applications, this system enforces business logic directly at the database level using Stored Procedures, Triggers, and Strict Constraints.

---

## 🚀 Key Features & Engineering Challenges

### 1. 🛡️ Strict Schema & Data Safety (Phase 1)
* [cite_start]**Zero Negative Balances:** Implemented `CHECK` constraints to ensure account balances never drop below zero at the database level[cite: 12].
* [cite_start]**Precision Math:** utilized `NUMERIC/DECIMAL` types instead of `FLOAT` or `DOUBLE` to prevent floating-point rounding errors common in financial software[cite: 13, 14].
* [cite_start]**Multi-Currency Support:** Strict enforcement of currency codes (USD, EUR, GBP) per account[cite: 11].

### 2. 💸 ACID-Compliant Money Transfers (Phase 2)
* [cite_start]**Atomic Transactions:** Built a custom PL/pgSQL function `transfer_funds` that handles debits and credits in a single atomic block using `BEGIN / COMMIT`[cite: 22, 28].
* [cite_start]**Race Condition Handling:** Solved potential double-spending issues by implementing row-level locking (`SELECT ... FOR UPDATE`) to handle simultaneous transaction requests safely[cite: 30, 31].
* [cite_start]**Automatic Rollbacks:** If any step fails (e.g., insufficient funds or locked account), the entire transaction rolls back to prevent data inconsistency[cite: 29].

### 3. 🌍 International Logic & Migrations (Phase 3)
* [cite_start]**Zero-Downtime Migration:** Successfully altered the live schema to support new features without corrupting existing transaction history[cite: 33].
* [cite_start]**Automated Fee System:** Implemented logic to detect international transfers (e.g., USA to Turkey) and automatically apply a **1% transaction fee**[cite: 35].
* [cite_start]**System Revenue Tracking:** Fees are automatically routed to a designated "System Bank Account"[cite: 38].

### 4. ⚡ Performance Optimization (Phase 4)
* [cite_start]**Efficient Reporting:** Created a `monthly_user_summary` view to calculate deposits, withdrawals, and net worth instantly[cite: 43].
* **Solving the N+1 Problem:** Optimized query performance by implementing Database Indexes on the `transactions` table (`from_account_id`, `to_account_id`, `timestamp`). [cite_start]This reduced report generation time from linear scans to constant-time index seeks (<50ms)[cite: 48, 51, 52].

### 5. 👻 "Invisible" Audit System (Phase 5)
* [cite_start]**Database Triggers:** Implemented a "Watcher" system that automatically intercepts `UPDATE` commands on sensitive tables[cite: 56].
* [cite_start]**Tamper-Proof Logging:** Any change to a user's name or account status is automatically recorded in an `audit_logs` table with `OLD` and `NEW` values, completely independent of the application layer[cite: 57].

---

## 🛠️ Technical Stack
* **Database:** PostgreSQL
* **Languages:** SQL, PL/pgSQL
* **Concepts:** ACID Transactions, Stored Procedures, Triggers, Views, Indexing, Normalization.

---

## 📂 Project Structure
The project is built incrementally via the following migration scripts:

* `001_initial_schema.sql`: Sets up Users, Accounts, and Transaction tables.
* `002_transaction_logic.sql`: Defines the atomic `transfer_funds` stored procedure.
* `003_migration_fees.sql`: Updates schema for international fees and system revenue.
* `004_reporting_views.sql`: Adds performance indexes and reporting views.
* `005_audit_system.sql`: Implements triggers for audit logging.

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
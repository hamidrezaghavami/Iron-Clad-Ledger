-- Create Indexes (This solves the "50ms Trap")
CREATE INDEX idx_transactions_from ON transactions(from_account_id);
CREATE INDEX idx_transactions_to ON transactions(to_account_id);
CREATE INDEX idx_transactions_ts ON transactions(timestamp);

CREATE VIEW monthly_users_summary AS
SELECT 
    us.id, 
    
    us.first_name || ' ' || us.last_name AS user_name,

    (COALESCE(s.balance, 0) + COALESCE(h.balance, 0)) AS net_worth,

    -- Total Deposited
    (
        SELECT COALESCE(SUM(t.amount), 0)
        FROM transactions t 
        WHERE t.to_account_id = s.id
        AND DATE_TRUNC('month', t.timestamp) = DATE_TRUNC('month', CURRENT_DATE)
    ) AS total_deposited,

    -- Total Withdrawn
    (
        SELECT COALESCE(SUM(t.amount), 0)
        FROM transactions t 
        WHERE t.from_account_id = s.id
        AND DATE_TRUNC('month', t.timestamp) = DATE_TRUNC('month', CURRENT_DATE)
    ) AS total_withdrawn

FROM users us
LEFT JOIN savingaccount s ON us.id = s.user_id
LEFT JOIN checkingaccount h ON us.id = h.user_id;

/* * PERFORMANCE TRAP: THE N+1 PROBLEM
 * The Issue: 
 * Without indexes, the 'monthly_user_summary' view falls into a performance trap.
 * For every single user (N), the database has to scan the entire 'transactions' 
 * table twice (once for deposits, once for withdrawals).
 * If you have 1,000 users, the database performs 2,000 full table scans!
 *
 * The Solution: Database Indexes
 * Indexes act like a "Table of Contents" for your database. 
 * Instead of reading every page (Full Scan) to find a user's transactions, 
 * the database looks at the Index and jumps straight to the answer (Index Seek).
 * This reduces query time from seconds to milliseconds.
 */
-- RUN THIS COMMAND IN TERMINAL TO FIX IT:
-- psql -U ICL -d banking_db -c "CREATE INDEX idx_transactions_from ON transactions(from_account_id); CREATE INDEX idx_transactions_to ON transactions(to_account_id); CREATE INDEX idx_transactions_ts ON transactions(timestamp);"


/* 
REPORT: 

<sql -U ICL -d banking_db -c "SELECT * FROM monthly_users_summary;"                                                        <sql -U ICL -d banking_db -c "SELECT * FROM monthly_users_summary;"
 id |  user_name  | net_worth | total_deposited | total_withdrawn 
----+-------------+-----------+-----------------+-----------------
  2 | Alice Smith |    899.00 |               0 |          100.00
  1 | System Bank |      1.00 |               0 |               0
  3 | Bob Jones   |    100.00 |          100.00 |               0
(3 rows)
*/
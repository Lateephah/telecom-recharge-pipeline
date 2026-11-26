CREATE TABLE recharge_transactions (
    transaction_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone_number VARCHAR(15) NOT NULL,
    network_provider VARCHAR(50) NOT NULL,
    recharge_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    recharge_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

SELECT *
from recharge_transactions
LIMIT 30;

ALTER TABLE recharge_transactions
ALTER COLUMN phone_number TYPE VARCHAR(30);

SELECT COUNT(*) AS total_transactions,
       SUM(recharge_amount) AS total_revenue
FROM recharge_transactions;


SELECT COUNT(*) AS number_of_entries
FROM recharge_transactions
where status = 'Failed';

SELECT status, COUNT(*), SUM(recharge_amount) as total_amount
FROM recharge_transactions
GROUP BY status;

SELECT network_provider, COUNT(*) as total
FROM recharge_transactions
GROUP BY network_provider
ORDER BY total DESC;

TRUNCATE TABLE recharge_transactions RESTART IDENTITY CASCADE;
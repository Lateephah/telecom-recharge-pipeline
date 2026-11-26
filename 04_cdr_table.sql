CREATE TABLE IF NOT EXISTS cdr_records (
    cdr_id SERIAL PRIMARY KEY,
    caller_number VARCHAR(11) NOT NULL,
    receiver_number VARCHAR(11) NOT NULL,
    network_provider VARCHAR(20) NOT NULL,
    call_type VARCHAR(20) NOT NULL, -- Voice, SMS, Data
    call_duration_seconds INT, -- NULL for SMS
    call_start_time TIMESTAMP DEFAULT NOW(),
    call_cost NUMERIC(10, 2),
    call_status VARCHAR(20) DEFAULT 'Completed'
);
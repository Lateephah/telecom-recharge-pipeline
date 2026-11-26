
CREATE TABLE daily_summary (
    summary_date DATE NOT NULL,
    network_provider VARCHAR(20) NOT NULL,
    total_recharges INT DEFAULT 0,
    total_recharge_amount NUMERIC DEFAULT 0,
    total_calls INT DEFAULT 0,
    total_call_cost NUMERIC DEFAULT 0,
    total_revenue NUMERIC DEFAULT 0,
    PRIMARY KEY (summary_date, network_provider)
);


CREATE OR REPLACE PROCEDURE generate_daily_summary(
    IN p_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    INSERT INTO daily_summary (
        summary_date, network_provider,
        total_recharges, total_recharge_amount,
        total_calls, total_call_cost, total_revenue
    )
    SELECT
        p_date,
        n.network_provider,
        COALESCE(r.total_recharges, 0),
        COALESCE(r.total_amount, 0),
        COALESCE(c.total_calls, 0),
        COALESCE(c.total_cost, 0),
        COALESCE(r.total_amount, 0) + COALESCE(c.total_cost, 0)
    FROM
        (SELECT DISTINCT network_provider FROM recharge_transactions
         UNION
         SELECT DISTINCT network_provider FROM cdr_records) n
    LEFT JOIN (
        SELECT network_provider, COUNT(*) AS total_recharges, SUM(recharge_amount) AS total_amount
        FROM recharge_transactions
        WHERE DATE(recharge_date) = p_date
        GROUP BY network_provider
    ) r ON n.network_provider = r.network_provider
    LEFT JOIN (
        SELECT network_provider, COUNT(*) AS total_calls, SUM(call_cost) AS total_cost
        FROM cdr_records
        WHERE DATE(call_start_time) = p_date
        GROUP BY network_provider
    ) c ON n.network_provider = c.network_provider;
END;
$$;
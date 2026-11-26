CREATE OR REPLACE PROCEDURE process_cdr(
    IN p_caller VARCHAR,
    IN p_receiver VARCHAR,
    IN p_network VARCHAR,
    IN p_call_type VARCHAR,
    IN p_duration INT,
    OUT p_cdr_id INT,
    OUT p_cost NUMERIC,
    OUT p_message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rate_per_second NUMERIC := 0;
BEGIN

    -- 1. Set rate based on call type
    IF p_call_type = 'Voice' THEN
        v_rate_per_second := 0.50; -- 50 kobo per second = N30 per minute
    ELSIF p_call_type = 'SMS' THEN
        v_rate_per_second := 0; -- SMS is flat rate
        p_cost := 4.00; -- N4 per SMS
    ELSIF p_call_type = 'Data' THEN
        v_rate_per_second := 0.10; -- Data charge
    ELSE
        p_message := 'Invalid call type. Must be Voice, SMS or Data.';
        p_cdr_id := NULL;
        p_cost := 0;
        RETURN;
    END IF;

    -- 2. Calculate cost for Voice and Data
    IF p_call_type IN ('Voice', 'Data') THEN
        p_cost := p_duration * v_rate_per_second;
    END IF;

    -- 3. Insert CDR record
    INSERT INTO cdr_records (
        caller_number, receiver_number, network_provider,
        call_type, call_duration_seconds, call_cost, call_status
    )
    VALUES (
        p_caller, p_receiver, p_network,
        p_call_type, p_duration, p_cost, 'Completed'
    )
    RETURNING cdr_id INTO p_cdr_id;

    p_message := 'CDR processed successfully. Cost: N' || p_cost;

END;
$$;
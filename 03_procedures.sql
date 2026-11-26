
CREATE OR REPLACE PROCEDURE process_recharge(
    IN p_name VARCHAR,
    IN p_email VARCHAR,
    IN p_phone VARCHAR,
    IN p_network_provider VARCHAR,
    IN p_amount NUMERIC,
    OUT p_transaction_id INT,
    OUT p_status VARCHAR,
    OUT p_message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_prefix VARCHAR(4);
    v_is_valid_prefix BOOLEAN;
BEGIN
    v_is_valid_prefix := FALSE;
    -- 1. Clean phone number: remove spaces
    p_phone := TRIM(p_phone);
    
    -- 2. Validate phone length (must be 11 digits)
    IF LENGTH(p_phone) != 11 OR p_phone !~ '^[0-9]+$' THEN
        p_status := 'Failed';
        p_message := 'Invalid phone number: Must be 11 digits.';
        INSERT INTO recharge_transactions (name, email, phone_number, network_provider, recharge_amount, status, recharge_date)
        VALUES (p_name, p_email, p_phone, p_network_provider, p_amount, 'Failed', NOW())
        RETURNING transaction_id INTO p_transaction_id;
        RETURN;
    END IF;

    -- 3. Get prefix (first 4 digits)
    v_prefix := LEFT(p_phone, 4);

    -- 4. Validate prefix matches network
    v_is_valid_prefix := CASE
        WHEN p_network_provider = 'MTN' AND v_prefix IN ('0803','0806','0810','0813','0814','0816','0903','0906') THEN TRUE
        WHEN p_network_provider = 'Airtel' AND v_prefix IN ('0802','0808','0812','0902','0907','0912') THEN TRUE
        WHEN p_network_provider = 'Glo' AND v_prefix IN ('0805','0807','0811','0815','0905','0915') THEN TRUE
        WHEN p_network_provider = '9mobile' AND v_prefix IN ('0809','0817','0818','0909','0908') THEN TRUE
        ELSE FALSE
    END;

    IF NOT v_is_valid_prefix THEN
        p_status := 'Failed';
        p_message := 'Prefix ' || v_prefix || ' does not match network ' || p_network_provider;
        INSERT INTO recharge_transactions (name, email, phone_number, network_provider, recharge_amount, status, recharge_date)
        VALUES (p_name, p_email, p_phone, p_network_provider, p_amount, 'Failed', NOW())
        RETURNING transaction_id INTO p_transaction_id;
        RETURN;
    END IF;

    -- 5. Validate amount
    IF p_amount NOT IN (100, 200, 500, 1000, 2000, 5000) THEN
        p_status := 'Failed';
        p_message := 'Invalid amount: Must be 100, 200, 500, 1000, 2000 or 5000.';
        INSERT INTO recharge_transactions (name, email, phone_number, network_provider, recharge_amount, status, recharge_date)
        VALUES (p_name, p_email, p_phone, p_network_provider, p_amount, 'Failed', NOW())
        RETURNING transaction_id INTO p_transaction_id;
        RETURN;
    END IF;

    -- 6. All validations passed -> Success
    p_status := 'Success';
    p_message := 'Recharge successful.';
    INSERT INTO recharge_transactions (name, email, phone_number, network_provider, recharge_amount, status, recharge_date)
    VALUES (p_name, p_email, p_phone, p_network_provider, p_amount, 'Success', NOW())
    RETURNING transaction_id INTO p_transaction_id;

END;
$$;


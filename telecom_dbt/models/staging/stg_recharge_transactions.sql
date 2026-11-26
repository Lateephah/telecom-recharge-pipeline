with source_data as (

    select * from {{ source('telecom_recharge_db', 'recharge_transactions') }}

),

cleaned as (

    select
        transaction_id,
        name as customer_name,
        email,
        phone_number,
        network_provider,
        recharge_amount,
        status as recharge_status,
        recharge_date

    from source_data

)

select * from cleaned
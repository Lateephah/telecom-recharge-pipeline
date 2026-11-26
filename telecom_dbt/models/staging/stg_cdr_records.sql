with source_data as (

    select * from {{ source('telecom_recharge_db', 'cdr_records') }}

),

cleaned as (

    select
        cdr_id,
        caller_number,
        receiver_number,
        network_provider,
        call_type,
        call_duration_seconds,
        call_start_time,
        call_cost,
        call_status

    from source_data

)

select * from cleaned
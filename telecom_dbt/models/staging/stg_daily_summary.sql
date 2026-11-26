with source_data as (

    select * from {{ source('telecom_recharge_db', 'daily_summary') }}

),

cleaned as (

    select
        summary_date,
        network_provider,
        total_recharges,
        total_recharge_amount,
        total_calls,
        total_call_cost,
        total_revenue

    from source_data

)

select * from cleaned
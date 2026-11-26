with recharge_summary as (
    select
        phone_number,
        count(*) as total_recharges,
        sum(recharge_amount) as total_recharge_spent,
        sum(case when recharge_status = 'Success' then 1 else 0 end) as successful_recharges
    from {{ ref('stg_recharge_transactions') }}
    group by phone_number
),

call_summary as (
    select
        caller_number as phone_number,
        count(*) as total_calls,
        sum(call_duration_seconds) as total_call_seconds,
        sum(call_cost) as total_call_cost
    from {{ ref('stg_cdr_records') }}
    group by caller_number
)

select
    c.customer_id,
    c.customer_name,
    c.email,
    c.phone_number,
    c.network_provider,
    coalesce(r.total_recharges, 0) as total_recharges,
    coalesce(r.total_recharge_spent, 0) as total_recharge_spent,
    coalesce(r.successful_recharges, 0) as successful_recharges,
    coalesce(cs.total_calls, 0) as total_calls,
    coalesce(cs.total_call_seconds, 0) as total_call_seconds,
    coalesce(cs.total_call_cost, 0) as total_call_cost,
    coalesce(cs.total_call_cost, 0) + coalesce(r.total_recharge_spent, 0) as total_value_naira
from {{ ref('dim_customers') }} c
left join recharge_summary r
    on c.phone_number = r.phone_number
left join call_summary cs
    on c.phone_number = cs.phone_number
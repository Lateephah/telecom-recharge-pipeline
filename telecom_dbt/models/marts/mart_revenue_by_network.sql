with daily as (

    select * from {{ ref('stg_daily_summary') }}

),

revenue_by_network as (

    select
        network_provider,
        sum(total_recharges) as total_recharges,
        sum(total_recharge_amount) as total_recharge_amount,
        sum(total_calls) as total_calls,
        sum(total_call_cost) as total_call_cost,
        sum(total_revenue) as total_revenue

    from daily
    group by network_provider

)

select * from revenue_by_network
order by total_revenue desc
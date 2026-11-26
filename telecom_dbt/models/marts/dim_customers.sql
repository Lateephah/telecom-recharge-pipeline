with customers as (
    select
        phone_number,
        max(customer_name) as customer_name,
        max(email) as email,
        max(network_provider) as network_provider
    from {{ ref('stg_recharge_transactions') }}
    group by phone_number
),

numbered as (
    select
        *,
        row_number() over (order by phone_number) as row_num
    from customers
)

select
    'CUST/' || lpad(row_num::text, 5, '0') as customer_id,
    phone_number,
    customer_name,
    email,
    network_provider
from numbered
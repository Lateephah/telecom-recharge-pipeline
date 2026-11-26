# telecom-recharge-pipeline
Telecom Customer 360 pipeline - Python → PostgreSQL → dbt → Looker Studio. 99,971 customers, 146.1M Naira revenue. Fixed a  lpad() bug that collapsed 99,971 IDs into 999. Still building, work in progress: data usage, SMS &amp; churn to reach true 360°

# Telecom Customer 360 Dashboard

> End-to-end telecom analytics pipeline: Python generates 99,971 customers + recharge & CDR data, modeled in dbt on PostgreSQL, visualized in Looker Studio. Found & fixed a duplicate customer_id bug that collapsed 99,971 customers into 999. KPIs reconcile: 146.1M Naira revenue - 23.8M usage = 122.2M balance.

**Live Dashboard:** [https://datastudio.google.com/reporting/3dc7c1d2-7f56-4049-a16b-2cc285def118]
**Stack:** Python | PostgreSQL | dbt | Looker Studio

![Dashboard](Dashboard/dashboard.png)

## ✅ Success - What Works

- **Full pipeline works:** Python (generators) -> PostgreSQL -> dbt (staging + marts) -> Looker Studio
- **KPIs reconcile:** Total Revenue (146.1M) - Total Usage (23.8M) = Remaining Balance (122.2M)
- **Customer grain is correct:** `dim_customers` = 99,971 rows, 99,971 unique `customer_id`s. Validated with `COUNT(DISTINCT customer_id)`
- **Customer 360 view:** One row per customer with `total_recharge_spent`, `total_call_cost`, `total_value_naira`, `network_provider`

## ❌ Failure Found & Fixed

**Bug: 99,971 customers collapsed to 999**

Dashboard first showed only 999 customers.

Check:
```sql
SELECT COUNT(*) as total_rows,
       COUNT(DISTINCT customer_id) as unique_ids
FROM dim_customers;
-- Result: 99971 | 999

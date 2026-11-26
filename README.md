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
```
Each customer_id was shared by ∼111 people.
**Root Cause** - in dim_customers.sql:

```sql
'CUST/' || lpad(row_num::text, 3, '0') as customer_id
```

Postgres lpad(..., 3, '0') truncates to 3 chars. So 1000 became 100, colliding with the real CUST/100.
Fix:
```sql
'CUST/' || lpad(row_num::text, 5, '0') as customer_id
```

Re-ran dbt run --select dim_customers+ and re-validated: 99971 | 99971.Impact if missed: Top 10 customers were actually 111 people aggregated together, inflating VIP metrics by 100x.

##⚠️ **Limitations - Currently 270°, Not True 360°** 
Yes, the model is called fct_customer_360, but for now na 270° we get. We see recharge + calls + profile, but back still dey dark.
- **78,293 vs 99,971 in table**: fct_customer_360 uses INNER JOIN, so 21,678 customers who recharged but never called are dropped. Fix: LEFT JOIN from dim_customers.
- **Usage can exceed recharge**: Recharge and CDR generators are independent. Example: recharge 2,000 but call cost 2,677 = negative balance. In production, prepaid balance check would prevent this.
- **Network is uniform**: Generator assigns networks randomly, so 9mobile / Airtel / Glo / MTN each show ∼42M. Not a real market insight.
- **Customers from recharge only**: dim_customers is built from recharge transactions grouped by phone_number.

## 🗺️ Roadmap: 270° to True 360°
- Add data usage (MB consumed)
- Add SMS table
- Add churn flag: no recharge in 90 days = churned
- Add support tickets / complaints
- Add demographics: age, location


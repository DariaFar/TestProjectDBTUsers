{{ config(
      materialized='incremental', 
      unique_key='user_id',
      incremental_strategy='delete+insert'
) }}

with user_orders as (
    select
      user_id,
      count(order_id) as order_count,
      sum(order_amount) as total_purchase_amount,
      avg(order_amount) as avg_purchase_amount,
      max(order_date) as last_order_date
    from {{ source('example_db', 'orders') }}
    group by user_id
  ),
  actual_users as (
    select
      u.user_id,
      u.registration_date,
      first_value(user_status) over (partition by u.user_id order by sync_date desc) as actual_status, 
      max(sync_date) as sync_date
    from {{ source('example_db', 'users') }} u
    group by u.user_id, u.registration_date
  ),
  all_users as (
    select
      u.user_id,
      u.registration_date,
      u.actual_status,
      coalesce(o.order_count, 0) as order_count,
      coalesce(o.total_purchase_amount, 0) as total_purchase_amount,
      coalesce(o.avg_purchase_amount, 0) as avg_purchase_amount,
      o.last_order_date,
      u.sync_date
    from actual_users u
    left join user_orders o on u.user_id = o.user_id
  )

select
  u.user_id,
  u.registration_date,
  u.order_count,
  u.total_purchase_amount,
  u.avg_purchase_amount,
  u.last_order_date,
  u.actual_status
from all_users u

{% if is_incremental() %}
  where u.last_order_date >= date('now', '-7 days')
     or u.registration_date >= date('now', '-7 days')
     or u.sync_date >= date('now', '-7 days')
{% endif %}
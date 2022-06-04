--Step 1: ID distinct tenants who had autopayment fails
with temp as
         (SELECT distinct(p.vhost||p.user_id) as jn, 
       p.vhost,
       p.user_id,
       p.created_at,
       q.error
FROM tportal_qach_request_infos q
JOIN tportal_payments p ON p.vhost = q.vhost
AND p.id = q.request_entity_id
WHERE payment_method LIKE 'cc'
  AND q.created_at > dateadd(month, -3, current_date)
  and error is not null
  and error like '%address%'
  and p.auto_payment_id is not null),

--Step 2: ID distinct tenants who made a payment after the failures began 
temp1 as
        (select distinct(vhost||user_id) as jn,
        paid_on,
        created_at,
        payment_method,
        amount
 from tportal_payments
 where paid_on >= '2022-05-04'
 and paid_on is not null
),


--Step 3: join tenants who made a payment after the failures began to tenant who experienced a failure & determine who made a payment after the failure
 temp2 as (
 select
 temp.vhost,
 temp.user_id,
 temp.created_at,
 temp.error,
 temp1.paid_on,
 temp1.created_at,
 temp1.payment_method,
 temp1.amount,
 case when temp1.created_at > temp.created_at then 1 end as pmt
 from temp 
 left join temp1 ON temp1.jn = temp.jn)
 
--Step 4: Calculate Stats 
select 
  count(distinct(vhost||user_id)) as impacted_tenants,
  sum(pmt) as paid_impacted_tenants,
  paid_impacted_tenants/impacted_tenants * 100 as pct_paid_impacted_tenants,
    COUNT(CASE WHEN pmt = 1 and payment_method = 'ach' then 1 ELSE NULL END) as paid_impacted_tenants_ACH,
  paid_impacted_tenants_ACH/paid_impacted_tenants * 100 as pct_paid_impacted_tenants_ACH
from temp2

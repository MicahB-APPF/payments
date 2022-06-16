--get current schema
set schema_name= (SELECT 'CUPOLA_PROD."' || "schema" || '_default"'
                      FROM cupola_prod.PUBLIC.imports i
                  ORDER BY i."schema" desc
                  LIMIT 1);
use schema identifier ($schema_name);

---roll these data up by month for QA/QC against the Payments: Rent Revenue KPIs Dash -- may looks solid
---count 'manual' payment transactions for tenants with activated t-portals
with offline as(
select channel, 
       tenants.vhost, 
       tenants.tportal_id, 
       tenants.tenant_portal_activated,
       transaction_paid_on,
       transaction_posted_on,
       transaction_rev_rec_date,
       date_trunc('month',transaction_posted_on) as mnt
from appfdw.prod.payments_transactional_fact cc_pay
    left join appfdw.prod.tenant_occupancy_dim tenants on tenants.tenant_id=cc_pay.payer_id and cc_pay.vhost=tenants.vhost
where tenants.tenant_portal_activated = TRUE
and tenants.tportal_hidden_date is null 
and tportal_id is not null
and channel = 'manual'
and cashflow_direction = 'Inflow'
and date_trunc('month',transaction_posted_on) = '2022-05-01'
),

---count t-portal online payment transactions and types
pmt as(
select (case when payment_method like 'cc' and debit_card like 'true' then 'debit'
              when payment_method like 'cc' and (debit_card is null or debit_card like 'false') then 'credit'
              when payment_method like 'ach' then 'ach'
              else 'what' end) as
              payment_method, 
              is_apple_pay,
              p.user_id,
              p.vhost,
              date_trunc('month',paid_on) as mnt
from tportal_users u
left join tportal_payments p on u.id = p.user_id and u.vhost = p.vhost
left join tportal_payment_token_extensions pte on pte.vhost = p.vhost and pte.payment_token_id = p.payment_token_id
full outer join offline o on o.tportal_id = p.user_id and o.vhost = p.vhost
where paid_on is not null
and date_trunc('month',paid_on) = '2022-05-01'), --set to experiment start date, change to greater than

---count both manual and online t-portal payments 
all_pmt as(
select mnt,vhost,tportal_id from offline
union
select mnt,vhost,user_id from pmt),

---join back the data we need
jn as (
select 
       a.mnt,
       a.vhost,
       a.tportal_id,
       o.channel,
       p.payment_method,
       p.is_apple_pay
from all_pmt a
left join offline o on o.tportal_id = a.tportal_id and o.vhost = a.vhost
left join pmt p on p.vhost = a.vhost and p.user_id = a.tportal_id)


----roll up -- now counting on a transaction basis so that numbers tie out
select mnt,
     count(*) as total_payments,
     count(case when channel = 'manual' and payment_method is null then vhost end) as manual,
     count(case when payment_method = 'debit' then vhost end) as debit,
     count(case when payment_method = 'credit' then vhost end) as credit,
     count(case when payment_method = 'ach' then vhost end) as ach,
     count(case when is_apple_pay = TRUE then vhost end) as apple_pay,
     count(case when payment_method = 'debit' and is_apple_pay = TRUE then vhost end) as apple_pay_debit,
     count(case when payment_method = 'credit' and is_apple_pay = TRUE then vhost end) as apple_pay_credit
FROM jn 
group by mnt
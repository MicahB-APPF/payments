---this doesn't run in Cupola for some reason
---PMT - Apple Pay Experiment All Transactions
---Micah Brachman - code last updated 2022-13-10

---select all Apple Pay Transactions, Bucketed Users, and User-level variables

with all_trans as (
select (case when payment_method like 'cc' and debit_card like 'true' then 'debit'
              when payment_method like 'cc' and (debit_card is null or debit_card like 'false') then 'credit'
              when payment_method like 'ach' then 'ach'
              else 'what' end) as
              payment_method, 
              is_apple_pay,
              u.uuid,
              p.user_id,
              p.vhost,
              paid_on,
              address_postal_code,
              email,
              variation_name,
              fee,
              (case when tte.created_at > dateadd('minute',1,u.first_payment_flow_visit) then 'existing user' else 'new user' end) as user_type
from tportal_users u
join tportal_payments p on u.id = p.user_id and u.vhost = p.vhost
left join tportal_payment_token_extensions pte on pte.vhost = p.vhost and pte.payment_token_id = p.payment_token_id
right join tportal_tenant_full_stack_experiments tte on tte.vhost = p.vhost and tte.user_id = p.user_id
where paid_on is not null
and paid_on > '2022-06-15' -- experiment start date 6/16
and experiment_name = 'tportal_apple_pay')

--all users and payment type for each variation
select variation_name,
       user_type,
       count(distinct vhost||uuid) as total_users,
       count(distinct(case when is_apple_pay = TRUE then vhost||uuid END)) as apple_pay_users,
       count(*) as total_transactions,
       count(case when payment_method = 'debit' then payment_method end) as debit_txns,
       count(case when payment_method = 'credit' then payment_method end) as credit_txns,
       count(case when payment_method = 'ach' then payment_method end) as ach_txns,
       ach_txns/total_transactions as pct_ach,
       debit_txns/total_transactions as pct_debit,
       credit_txns/total_transactions as pct_credit,
       (credit_txns + debit_txns)/total_transactions as pct_card,
       count(case when is_apple_pay = TRUE then payment_method end) as apple_pay_txns,
       count(case when payment_method = 'debit' and is_apple_pay = TRUE then payment_method end) as apple_pay_debit_txns,
       count(case when payment_method = 'credit' and is_apple_pay = TRUE then payment_method end) as apple_pay_credit_txns,
       sum(fee) as total_fee_revenue,
       total_fee_revenue/total_transactions as fee_rev_per_txn,
       sum(case when payment_method = 'debit' then fee end) as debit_fee_revenue,
       sum(case when payment_method = 'credit' then fee end) as credit_fee_revenue,
       debit_fee_revenue/debit_txns as debit_rev_per_txn,
       credit_fee_revenue/credit_txns as credit_rev_per_txn
from all_trans a
group by 1,2
order by 1

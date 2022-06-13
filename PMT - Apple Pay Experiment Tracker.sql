---PMT - Apple Pay Experiment Tracker (Cupola)
---Micah Brachman

---select payment methods
with pmt as(
select (case when payment_method like 'cc' and debit_card like 'true' then 'debit'
              when payment_method like 'cc' and (debit_card is null or debit_card like 'false') then 'credit'
              when payment_method like 'ach' then 'ach'
              else 'what' end) as
              payment_method, 
              is_apple_pay,
              p.user_id,
              p.vhost
from tportal_users u
join tportal_payments p on u.id = p.user_id and u.vhost = p.vhost
left join tportal_payment_token_extensions pte on pte.vhost = p.vhost and pte.payment_token_id = p.payment_token_id
where paid_on is not null
and paid_on = '2022-06-13') --set to experiment start date

---roll up stats for each experiment variation
select variation_name,
     count(distinct tte.vhost||tte.user_id) as users,
     count(distinct case when payment_method = 'debit' then tte.vhost||tte.user_id end) as debit,
     count(distinct case when payment_method = 'credit' then tte.vhost||tte.user_id end) as credit,
     count(distinct case when payment_method = 'ach' then tte.vhost||tte.user_id end) as ach,
     count(distinct case when is_apple_pay = TRUE then tte.vhost||tte.user_id end) as apple_pay,
     count(distinct case when payment_method = 'debit' and is_apple_pay = TRUE then tte.vhost||tte.user_id end) as apple_pay_debit,
     count(distinct case when payment_method = 'credit' and is_apple_pay = TRUE then tte.vhost||tte.user_id end) as apple_pay_credit
FROM tportal_tenant_full_stack_experiments tte
JOIN pmt on pmt.vhost = tte.vhost and pmt.user_id = tte.user_id
WHERE experiment_name = 'ri_modular_buyflow' ---change to 'tportal_apple_pay'
group by variation_name

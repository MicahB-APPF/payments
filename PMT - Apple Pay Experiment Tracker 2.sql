--get current schema
set schema_name= (SELECT 'CUPOLA_PROD."' || "schema" || '_unfiltered"'
                      FROM cupola_prod.PUBLIC.imports i
                  ORDER BY i."schema" desc
                  LIMIT 1);
use schema identifier ($schema_name);

---I think everything is joined out...still wouldn't trust the numbers necessarily....
---Micah Brachman
---PMT - Apple Pay Experiment Tracker 2 
---tracks behavior in the payments flow
---stakeholder requirements: 

--Payment flow completion --> (CARD + ACH)/SESSIONS  -- split out debit and credit
--Autopay adoption --> (CARD_AUTOPAY + ACH_AUTOPAY)/SESSIONS -- split out debit and credit
--Apple Pay cancellations - count each of these individually
----'Apple Pay Overlay Dismissed'
----'Apple Pay Button Clicked'
----'Apple Pay Overlay User Canceled'
----'Apple Pay payment method submitted'
--Card errors frequency -- each error by reason code
----tportal_qach_request_infos
----count can_pay_with_apple_pay -- don't use as filter, check for edge cases

with flow as(
select 
    t.user_id,
    t.vhost,
    t.event_description,
    t.payment_id,
    t.saved_payment_token_id, --look at this and saved_account_information_id - if both null then more friction to get to apple pay
    t.mobile_app,
    t.operating_system,
    t.flow_id,
    t.flow_step,
    t.payment_method,
    t.can_pay_with_applepay, --track if true or not
    t.auto_payment_id
from tenant_react_payments_flow t
where t.is_production = TRUE
and t.occurred_at > '2022-06-15'
--and vhost = 'ivyhut'
),

pmt as(
select (case when payment_method like 'cc' and debit_card like 'true' then 'debit'
              when payment_method like 'cc' and (debit_card is null or debit_card like 'false') then 'credit'
              when payment_method like 'ach' then 'ach'
              else 'what' end) as
              payment_method, 
              is_apple_pay,
              p.user_id,
              p.id,
              p.vhost
from tportal_users u
join tportal_payments p on u.id = p.user_id and u.vhost = p.vhost
left join tportal_payment_token_extensions pte on pte.vhost = p.vhost and pte.payment_token_id = p.payment_token_id
where paid_on is not null
and paid_on > '2022-06-15') -- experiment start date 6/16

select variation_name,
     count(distinct flow.flow_id) as sessions,
     count(case when flow.payment_id is not NULL and flow.payment_method = 'cc' then flow.flow_id end) as card_payments,
     count(case when flow.payment_id is not NULL and flow.payment_method = 'ach' then flow.flow_id end) as ach_payments,
     count(case when flow.auto_payment_id is not NULL and flow.payment_method = 'cc' then flow.flow_id end) as card_autopay,
     count(case when flow.auto_payment_id is not NULL and flow.payment_method = 'ach' then flow.flow_id end) as ach_autopay,
     count(case when pmt.payment_method = 'debit' then flow.flow_id end) as debit,
     count(case when pmt.payment_method = 'credit' then flow.flow_id end) as credit,
     count(case when pmt.payment_method = 'ach' then flow.flow_id end) as ach,
     --count(case when flow.auto_payment_id is not NULL and pmt.payment_method = 'debit' then flow.flow_id end) as debit, --hmm not working
     --count(case when flow.auto_payment_id is not NULL and pmt.payment_method = 'credit' then flow.flow_id end) as credit,
     --count(case when flow.auto_payment_id is not NULL and pmt.payment_method = 'ach' then flow.flow_id end) as ach
     count(case when flow.can_pay_with_applepay = TRUE then flow.flow_id end) as can_pay_with_applepay, --why so high?
     count(case when flow.event_description = 'Apple Pay Overlay Dismissed' then flow.flow_id end) as ap_overlay_dismissed,
     count(case when flow.event_description = 'Apple Pay Button Clicked' then flow.flow_id end) as ap_button_clicked,
     count(case when flow.event_description = 'Apple Pay Overlay User Canceled' then flow.flow_id end) as ap_overlay_canceled,
     count(case when flow.event_description = 'Apple Pay payment method submitted' then flow.flow_id end) as ap_payment_submit,
     count(case when q.error like '%address%' then flow.flow_id end) as address_error
FROM tportal_tenant_full_stack_experiments tte
JOIN flow on flow.vhost = tte.vhost and flow.user_id = tte.user_id
left join pmt on pmt.user_id = flow.user_id and pmt.vhost = flow.vhost and flow.payment_id is not null
left join tportal_paymentsapi_request_infos q on q.request_entity_id = pmt.id and q.vhost = pmt.vhost and q.error is not null
WHERE experiment_name = 'tportal_apple_pay' 
group by variation_name

-----end here 2022-06-17
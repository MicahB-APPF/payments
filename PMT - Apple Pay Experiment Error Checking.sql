-- enabled users
with enabled_users AS
  (SELECT user_id,
          vhost,
          created_at,
          variation_name
   FROM tportal_tenant_full_stack_experiments
   WHERE experiment_name LIKE 'tportal_apple_pay'
     --AND variation_name LIKE 'enabled'
     AND created_at > '2022-06-16' ),

--errors
errors AS
(SELECT 
     q.error,
     p.vhost,
     p.user_id,
     p.is_apple_pay
FROM tportal_paymentsapi_request_infos q
JOIN tportal_payments p ON p.vhost = q.vhost
AND p.id = q.request_entity_id
JOIN tportal_payment_token_extensions pt ON pt.vhost = p.vhost
AND pt.payment_token_id = p.payment_token_id
WHERE payment_method LIKE 'cc'
  AND q.created_at > dateadd(month, -3, current_date))
  --AND error is not null)
  
--roll up by apple pay and error type
 select 
        e.is_apple_pay,
        e.error,
        u.variation_name,
        count(*) as count
 from errors e
 join enabled_users u on u.vhost = e.vhost and u.user_id = e.user_id
 group by 1,2,3
 order by 2
 


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
  and p.auto_payment_id is not null)
  
  select temp.vhost,
         user_id,
         temp.created_at,
         error,
         tu.address,
         tu.email,
         tu.first_name,
         tu.last_name
  from temp
  left join tportal_users tu on tu.id = temp.user_id and tu.vhost = temp.vhost
  where temp.vhost in ('investorsmgmt', 'robinsongroup', 'gsfproperties', 'areg', 'nustyledevelopment', 'renumgt', 'volunteerproperties', 'byersharveyrealestate', 'granitesl', 'land')
  order by 1
  

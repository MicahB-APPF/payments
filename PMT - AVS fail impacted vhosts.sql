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
  
  temp1 as (
  select vhost,
         count(distinct vhost||user_id) as tenants_with_failed_autopayments
  from temp
  group by vhost
  order by 2 desc)
  
  
  select temp1.vhost,
         temp1.tenants_with_failed_autopayments,
         a.SFDC_ACCOUNT_KEY,
         b.key_account_flag,
         c.apm_plus,
         d.market_segment,
         d.market_segment_name
   from temp1
   left join APPFDW.PROD.DAILY_CLIENT_USAGE_REPORT a on a.vhost = temp1.vhost
   left join APPFDW.SHARED.CUSTOMERS_DIM b on b.sfdc_account_key = a.sfdc_account_key
   left join APPFDW.PROD.DATABASE_SETTINGS_DIM c on c.vhost = temp1.vhost
   left join APPFDW.SHARED.UNIT_BUCKET_DIM d ON d.UNIT_COUNT = B.TOTAL_ACTIVE_UNITS
   where a.DATE_RECORDED = '2022-06-01'
   and b.CURRENT_RECORD=TRUE
   and b.RECORD_TYPE = 'Property Management'
   and b.ACCOUNT_TYPE = 'Customer'
   and c.churned = FALSE
   order by 2 desc
   
  
  
  

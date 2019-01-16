-- Quickbooks - Bills
 select
b.txnID as id,
b.TxnNumber as Transaction_Number,
b.VendorRef_FullName as Vendor_Name,
concat(b.VendorAddress_City,', ',b.VendorAddress_State,' ',b.VendorAddress_PostalCode) as Vendor_Location,
b.APAccountRef_FullName as Account_Name,
DATE_ADD( cast(b.TxnDate as datetime), INTERVAL TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) HOUR) as Bill_Date,
DATE_ADD( cast(b.DueDate as datetime), INTERVAL TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) HOUR) as Due_Date,
cast(DATE_ADD( DATE_FORMAT(str_to_date(b.timecreated, '%c/%e/%Y %r'), '%Y-%m-%d %T'), INTERVAL TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) HOUR) as datetime) as Created,
cast(DATE_ADD( DATE_FORMAT(str_to_date(b.timemodified, '%c/%e/%Y %r'), '%Y-%m-%d %T'), INTERVAL TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) HOUR) as datetime) as last_updated,
case 
when b.ispaid = 'true' then 0
else timestampdiff(hour, current_timestamp, b.duedate)/24.00 
end as Due_In_X_Days,
CASE when b.ispaid = 'true' then '5. Paid'
WHEN b.ispaid = 'false' and timestampdiff(hour, current_timestamp, b.duedate)/24.00 <= 0 THEN '0. Past Due'
WHEN b.ispaid = 'false' and timestampdiff(hour, current_timestamp, b.duedate)/24.00 > 0 AND timestampdiff(hour, current_timestamp, b.duedate)/24.00 <= 30 THEN '1. 1 - 30 days'
WHEN b.ispaid = 'false' and timestampdiff(hour, current_timestamp, b.duedate)/24.00 > 30 AND DATEDIFF(b.duedate, CURRENT_TIMESTAMP) <= 60 THEN '2. 30-60 days'
WHEN b.ispaid = 'false' and timestampdiff(hour, current_timestamp, b.duedate)/24.00 > 60 AND timestampdiff(hour, current_timestamp, b.duedate)/24.00 <= 90 THEN '3. 60-90 days'
WHEN b.ispaid = 'false' and timestampdiff(hour, current_timestamp, b.duedate)/24.00 > 90 THEN '4. > 90 days'
Else null
END AS Days_Due_Status,
cast(b.AmountDue as decimal) as Amount_Due,
b.RefNumber as Bill_Number,
CASE when b.IsPaid = 'true' then '1'
else '0'
end as Is_Paid,
cast(b.OpenAmount as decimal) as Open_Amount
from bill b 


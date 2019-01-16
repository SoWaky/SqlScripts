-- Quickbooks - Invoices
 select i.txnID as id,
i.TxnNumber as Transaction_Number,
i.CustomerRef_ListID,
i.CustomerREf_FullName as Customer,
i.ARAccountRef_FullName as AR_Account,
concat(i.BillAddress_City,', ',i.BillAddress_State,' ',i.BillAddress_PostalCode) as Account_Location,
cast(DATE_ADD( DATE_FORMAT(str_to_date(i.timecreated, '%c/%e/%Y %r'), '%Y-%m-%d %T'), INTERVAL TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) HOUR) as datetime) as Created,
cast(DATE_ADD( DATE_FORMAT(str_to_date(i.timemodified, '%c/%e/%Y %r'), '%Y-%m-%d %T'), INTERVAL TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) HOUR) as datetime) as last_updated,
DATE_ADD(cast(i.TxnDate as datetime), INTERVAL (TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) + 1) HOUR) AS Transaction_Date,
i.RefNumber as Invoice_Number,
case when i.IsPending = 'true' then '1'
else '0'
end as IsPending,
case when i.IsFinanceCharge = 'true' then '1'
else '0'
end as IsFinanceCharge,
i.PONumber,
i.TermsRef_FullName as Terms,
DATE_ADD(cast(i.DueDate as datetime), INTERVAL (TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) + 1) HOUR) AS DueDate,
cast(CASE WHEN i.IsPaid LIKE 'true' THEN 0
ELSE DATEDIFF(i.duedate, CURRENT_TIMESTAMP) END as decimal(18,2))  AS Due_In_X_Days,
CASE WHEN i.IsPaid = 'true' THEN '5. Paid'
WHEN i.IsPaid = 'false' and DATEDIFF(i.duedate, CURRENT_TIMESTAMP) <= 0 THEN '0. Past Due'
WHEN i.IsPaid = 'false' and DATEDIFF(i.duedate, CURRENT_TIMESTAMP) > 0 AND DATEDIFF(i.duedate, CURRENT_TIMESTAMP) <= 30 THEN '1. 1-30 days'
WHEN i.IsPaid = 'false' and DATEDIFF(i.duedate, CURRENT_TIMESTAMP) > 30 AND DATEDIFF(i.duedate, CURRENT_TIMESTAMP) <= 60 THEN '2. 31-60 days'
WHEN i.IsPaid = 'false' and DATEDIFF(i.duedate, CURRENT_TIMESTAMP) > 60 AND DATEDIFF(i.duedate, CURRENT_TIMESTAMP) <= 90 THEN '3. 61-90 days'
WHEN i.IsPaid = 'false' and DATEDIFF(i.duedate, CURRENT_TIMESTAMP) > 90 THEN '4. > 90 days'
END AS Days_Due_Status,
CASE WHEN i.IsPaid = 'true' THEN '0. Paid'
WHEN i.IsPaid = 'false' and DATEDIFF(i.duedate, CURRENT_TIMESTAMP) >= 0 THEN '1. Current'
WHEN i.IsPaid = 'false' and DATEDIFF(i.duedate, CURRENT_TIMESTAMP) < 0 AND DATEDIFF(i.duedate, CURRENT_TIMESTAMP) >= -30 THEN '2. 1-30 days'
WHEN i.IsPaid = 'false' and DATEDIFF(i.duedate, CURRENT_TIMESTAMP) < -30 AND DATEDIFF(i.duedate, CURRENT_TIMESTAMP) >= -60 THEN '3. 31-60 days'
WHEN i.IsPaid = 'false' and DATEDIFF(i.duedate, CURRENT_TIMESTAMP) < -60 AND DATEDIFF(i.duedate, CURRENT_TIMESTAMP) >= -90 THEN '4. 61-90 days'
WHEN i.IsPaid = 'false' and DATEDIFF(i.duedate, CURRENT_TIMESTAMP) < -90 THEN '5. > 90 days'
END AS aging_status,
DATE_ADD(cast(i.ShipDate as datetime), INTERVAL (TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) + 1) HOUR) AS ShipDate,
i.SalesRepRef_FullName as Sales_Rep,
i.Subtotal,
i.SalesTaxTotal,
i.AppliedAmount,
i.BalanceRemaining,
case when i.IsPaid = 'true' then '1'
else '0'
end as IsPaid,
i.Status 
from invoice i
where i.TxnDate > DATE_SUB(NOW(), INTERVAL 500 DAY) 


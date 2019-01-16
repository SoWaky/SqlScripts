-- QuickBooks - Profit and Loss
 ( Select 
UUID() as 'id',
null as 'Credit',
null as 'Debit',
cast(plly.amount as decimal(18,2)) as 'Total',
cast(plly.amount as decimal(18,2)) as 'Total Cost',
plly.TYPE as 'Type',
DATE_ADD(cast(plly.DATES as datetime), INTERVAL (TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) + 1) HOUR)  AS 'Date',
plly.NAME AS 'Company',
plly.MEMOS as 'Memo',
plly.SPLIT as 'Accounts',
plly.RowDataValue as 'Category',
plly.RowType AS 'Row Type',
a.accounttype AS 'Account Type'
from pldetailly plly
left join account a ON LEFT(plly.RowDataValue, (LOCATE(' ', plly.RowDataValue) - 1)) = a.AccountNumber
where plly.type is not null)
UNION ALL
( Select 
UUID() as 'id',
null as 'Credit',
null as 'Debit',
cast(plytd.amount as decimal(18,2)) as 'Total',
cast(plytd.amount as decimal(18,2)) as 'Total Cost',
plytd.TYPE as 'Type',
DATE_ADD(cast(plytd.DATES as datetime), INTERVAL (TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) + 1) HOUR)  AS 'Date',
plytd.NAME AS 'Company',
plytd.MEMOS as 'Memo',
plytd.SPLIT as 'Accounts',
plytd.RowDataValue as 'Category',
plytd.RowType AS 'Row Type',
a.accounttype AS 'Account Type'
from pldetailytd plytd
left join account a ON LEFT(plytd.RowDataValue, (LOCATE(' ', plytd.RowDataValue) - 1)) = a.AccountNumber 
where plytd.type is not null) 


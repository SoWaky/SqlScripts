
-- CW - Invoice Data

  SELECT DISTINCT
inv.Billing_Log_RecID as 'id',
inv.Invoice_Number,
inv.Invoice_Type,
inv.Company_Name,
CAST(inv.Date_Invoice AS DATETIME) AS 'Date_Invoice',
CAST(inv.Date_Paid AS DATETIME) AS 'Date_Paid',
CASE WHEN inv.Date_Paid IS NOT NULL THEN CAST(ROUND(DATEDIFF(Hour, inv.Date_Invoice, Date_Paid)/24.0, 0) AS NUMERIC)
ELSE CAST(ROUND(DATEDIFF(Hour, inv.Date_Invoice, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) 
END AS 'Aging',
CASE
WHEN inv.Date_Paid IS NOT NULL THEN 'PAID'
WHEN (CAST(ROUND(DATEDIFF(Hour, inv.Date_Invoice, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) < 31) THEN '1-30'
WHEN (CAST(ROUND(DATEDIFF(Hour, inv.Date_Invoice, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) < 61) THEN '31-60'
WHEN (CAST(ROUND(DATEDIFF(Hour, inv.Date_Invoice, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) < 91) THEN '61-90'
ELSE 'Over 90'
END AS 'Aging Status',
inv.Invoice_Amount,
CAST(inv.Due_Date AS DATETIME) AS 'Due_Date',
inv.Billing_Terms,
inv.PO_Number,
inv.Reference,
inv.Adj_Amount,
inv.DownPayment,
inv.Progress_Amount_Applied,
inv.Expense_Amount,
inv.Misc_Amount,
inv.Time_Amount,
inv.Rem_Downpayment,
inv.Sales_Tax_Amount,
inv.Agreement_Name,
inv.AGR_Amount,
inv.AGR_Hours,
CAST(inv.Date_Created AS DATETIME) AS 'Date_Created',
CAST(inv.Date_Closed AS DATETIME) AS 'Date_Closed',
inv.Closed_Flag,
inv.Paid_Amount,
inv.Sent_Flag,
CAST(inv.Last_Update AS DATETIME) AS 'Last_Update',
inv.City,
inv.State_ID,
inv.Zip,
inv.Location

FROM v_rpt_Invoices inv
Where DATEDIFF (DAY, inv.Date_Invoice, CURRENT_TIMESTAMP) <= 365  


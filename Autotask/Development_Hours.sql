-------------------------------------------------------------
-- Eric's Invoicing Report - Based on Billing Periods

select convert(char(10), t.Date_Invoice, 111) as Date_Invoice, T.Invoice_Number, t.company_name, s.TicketNbr, SUM(t.billable_amt) as Billed_Amt, s.Summary
	FROM v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	INNER JOIN SR_Service Svc WITH (NOLOCK)
		ON Svc.sr_service_recid = S.sr_service_recid
	where 1=1
		and Board_Name = '10 Development'
		and t.Date_Invoice BETWEEN '09/01/2017' AND '10/31/2017'
	group by convert(char(10), t.Date_Invoice, 111), T.Invoice_Number, t.company_name, s.TicketNbr, s.Summary
	order by 1,2,3

----------------------------------------------------------------
-- Hours Worked Report - Based on Work Dates

IF OBJECT_ID('tempdb..#Time') IS NOT NULL 
	drop table #Time

select s.TicketNbr, t.company_name, convert(char(10), t.date_start, 111) as Date_Worked, t.hours_actual, T.Billable_Hrs, (T.Billable_Hrs - t.hours_actual) AS Hrs_Variance
		, t.hourly_rate, t.billable_amt, T.NonBillable_Amt, T.Time_Status, T.Billable_Flag
		, T.Invoice_Flag, T.Invoice_Number, convert(char(10), t.Date_Invoice, 111) as Date_Invoice
		, t.agreement, Svc.BillComplete_Flag
		, CASE Option_Id WHEN 'B' THEN 'Billable' WHEN 'NC' THEN 'No Charge' ELSE 'Do Not Bill' END AS Billing
		, case when T.Notes is null or t.Notes = '' then '' else 'Noted' end as TE_Note
		, T.SR_Summary, S.Board_Name, S.status_description AS Ticket_Status
		--, T.Notes, S.Board_Name--, *
INTO #Time
	FROM v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	INNER JOIN SR_Service Svc WITH (NOLOCK)
		ON Svc.sr_service_recid = S.sr_service_recid
	where 1=1
	--and member_id = 'csullivan'
	--and t.company_name = 'Packaging Personified Inc'
	and Board_Name = '10 Development'
	and t.Date_Start BETWEEN '09/01/2017' AND '09/30/2017'
	order by  t.agreement DESC, Svc.BillComplete_Flag DESC, T.Time_Status, T.Invoice_Number, 2, 3


-- Show which tickets have been Billed so far
select * 
	from #Time
	where 1=1
		--and BillComplete_Flag = 1
		--and Ticket_Status <> 'Closed'
		--and company_name <> 'WEBIT Services'
		and time_status like 'Billed%'
		and Billable_Amt <> 0
	order by 3

-- Show which tickets have been not been Billed yet
select * 
	from #Time
	where 1=1
		and time_status not like 'Billed%'
	order by 3


-- Break down work hours by Client
select company_name, sum(hours_actual) as Actual_Hours, sum(case when agreement = '' then Billable_Hrs else 0 end) as Billable_Hrs
		, sum(case when agreement = '' then billable_amt else 0 end) as Billable_Amt
		, sum(nonbillable_amt) as NonBillable_Amt
		, sum(case when time_status = 'Billed' then billable_amt else 0 end) as Billed_Amt
	from #Time
	GROUP BY company_name

-- Break down work hours by Board
select Board_Name, convert(char(7), Date_Worked, 111) as Mon, sum(hours_actual) as Actual_Hours
		, sum(case when agreement = '' then Billable_Hrs else 0 end) as Billable_Hrs
		, sum(case when agreement = '' then billable_amt else 0 end) as Billable_Amt
		, sum(nonbillable_amt) as NonBillable_Amt
		, sum(case when time_status = 'Billed' then billable_amt else 0 end) as Billed_Amt
	from #Time
	--where Board_Name like '01%' or Board_Name like '00%'
	group by Board_Name, convert(char(7), Date_Worked, 111)
	order by 1


-- Show Grand Totals for work hours
select sum(hours_actual) as Actual_Hours
		, sum(case when agreement = '' then Billable_Hrs else 0 end) as Billable_Hrs
		, sum(case when agreement = '' then billable_amt else 0 end) as Billable_Amt
		, sum(nonbillable_amt) as NonBillable_Amt
		, sum(case when time_status = 'Billed' then billable_amt else 0 end) as Billed_Amt
	from #Time


-------------------------
-- Cleanup a time entry

--begin tran
--update time_entry 
--	set time_start = '1900-01-01 10:30:00.043', time_end = '1900-01-01 10:30:00.043'
--	, hours_bill =0, hours_actual = 0, hours_invoiced = 0, updated_by = 'MPrice' 
--	where time_recid = 89120
		
--select * from time_entry where time_recid = 89120
--rollback
--commit

-------------------------
-- All Development board tickets should be set Bill Immediately, not when ticket is closed
--begin tran
--UPDATE SR_Service
--	SET BillComplete_Flag = 0
--	WHERE BillComplete_Flag = 1
--		and SR_Board_RecID = 41	-- 10 Development
--		and SR_Status_RecID <> 1194	-- Closed
--rollback
--commit
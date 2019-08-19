/*****************************************************************************************************
	GGOB Statistics for Matt
	- Central Services
	- Development

	NOTE that these queries are based on Dates: 
	- BDR Tickets
	- # Tickets from CS and Professional Services 
	- Development Revenue for the Quarter

*****************************************************************************************************
*/


set nocount on

----------------------------------------------------------------------------------------------------------------
-- Get all dates and weeks for the current reporting Quarter

DECLARE @StartDt datetime, @EndDt datetime, @StartWk int, @EndWk int, @Counter int, @Yr int, @Mo int

SET @StartDt = '10/01/2017'
SET @EndDt = '12/31/2017'
SET @StartWk = DATEPART(ww, @StartDt)
SET @EndWk = DATEPART(ww, @EndDt)
SET @Counter = @StartWk
SET @Yr = DATEPART(YY, dateadd(dd, -1, getdate()))
SET @Mo = DATEPART(MM, dateadd(dd, -1, getdate()))

PRINT 'Today is Week: ' + cast(DATEPART(ww, GETDATE()) as varchar(10))

EXEC sp_UpdateMspDashboardCompanyStatsByMonth @Yr, @Mo, 1

IF OBJECT_ID('tempdb..#Weeks') IS NOT NULL 
	drop table #Weeks
create table #Weeks (WeekNum int)

while @Counter <= @EndWk
begin
	INSERT INTO #Weeks VALUES (@Counter)
	SET @Counter = @Counter + 1

end



----------------------------------------------------------------------------------------------------------------
-- % of Computers missing 5 or more patches
DECLARE @NumComp decimal(10,5), @NumMissingPatches decimal(10,5)

select @NumComp = NumComp from openquery(WEBW12SRV04, '
SELECT count(*) as NumComp
	FROM v_Computer_Stats Computers 
')

select @NumMissingPatches = NumMissing from openquery(WEBW12SRV04, '
SELECT count(*) as NumMissing
	FROM v_Computer_Stats Computers 
	WHERE 1=1
	and Computers.Num_Patches_Missing >= 1
	-- and Patch_Status = ''>5 Missing''
')
print @NumComp
print @NumMissingPatches
print '% of Computers missing patches: ' + cast(@NumMissingPatches / @NumComp as varchar(20))

select @NumMissingPatches / @NumComp as MissingPatchesPct



----------------------------------------------------------------------------------------------------------------
-- # of Computers missing hosted AV

select * from openquery(WEBW12SRV04, '
SELECT count(*) as NumMissingHostedAV
	FROM v_Computer_Stats Computers 
	WHERE 1=1
		AND NOT EXISTS (SELECT * FROM Software WHERE Software.ComputerID = Computers.ComputerID AND (Software.`Name` like ''%sophos endpoint%'' or Software.`Name` like ''%sophos anti%''))
		AND NOT EXISTS (SELECT * FROM Software WHERE Software.ComputerID = Computers.ComputerID AND (Software.`Name` like ''%ESET%'' or Software.`Name` like ''%NOD32%''))
		')

----------------------------------------------------------------------------------------------------------------
-- # of Computers with Outdated AV

select * from openquery(WEBW12SRV04, '
SELECT count(*) as NumOutdatedAV
	FROM v_Computer_Stats Computers 
	WHERE AV_Status <> ''Up to Date''
		')


----------------------------------------------------------------------------------------------------------------
-- Endpoints and Seats

EXEC sp_UpdateMspDashboardCompanyStatsByMonth @Yr, @Mo, 1

select sum(num_endpoints) as num_endpoints, sum(num_seats) as num_seats, sum(mrr_amount) as MRR_Amount, sum(ORR_Amount) as ORR_Amount
	from MSP_Dashboard.dbo.vw_CompanyStatsByMonth
	where statsyear = @Yr and StatsMonth = @Mo

----------------------------------------------------------------------------------------------------------------
-- Development Revenue for the Quarter

select w.WeekNum, SUM(t.billable_amt) as Billed_Amt
	FROM v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	INNER JOIN SR_Service Svc WITH (NOLOCK)
		ON Svc.sr_service_recid = S.sr_service_recid
	INNER JOIN #Weeks w
		on w.WeekNum = DATEPART(ww, t.Date_Invoice)
		AND t.Date_Invoice BETWEEN @StartDt AND @EndDt
		--and year(t.Date_Invoice) = year(getdate())
	where 1=1
		and Board_Name = '10 Development'
	group by w.WeekNum
	order by 1

select SUM(t.billable_amt) as Billed_Amt_For_Quarter
	FROM v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	INNER JOIN SR_Service Svc WITH (NOLOCK)
		ON Svc.sr_service_recid = S.sr_service_recid
	INNER JOIN #Weeks w
		on w.WeekNum = DATEPART(ww, t.Date_Invoice)
		AND t.Date_Invoice BETWEEN @StartDt AND @EndDt
		--and year(t.Date_Invoice) = year(getdate())
	where 1=1
		and Board_Name = '10 Development'

select SUM(t.billable_amt) as Billed_Amt_For_Month
	FROM v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	INNER JOIN SR_Service Svc WITH (NOLOCK)
		ON Svc.sr_service_recid = S.sr_service_recid		
	where 1=1
		and Board_Name = '10 Development'
		and agreement = ''
		and year(t.Date_Invoice) = year(getdate())
		and month(t.Date_Invoice) = month(getdate())


----------------------------------------------------------------------------------------------------------------
-- BDR Tickets

SELECT w.WeekNum, count(distinct convert(char(10), v_rpt_Service.Date_Entered, 111) + Company_Name) AS Num_Backup_Failures
	FROM #Weeks w
	LEFT JOIN v_rpt_Service WITH (NOLOCK) 
		on w.WeekNum = DATEPART(ww, v_rpt_Service.Date_Entered)
		AND (v_rpt_Service.summary like 'BDR-Backup Job Failed%' or v_rpt_Service.summary like 'Backup Failed%')
		AND v_rpt_Service.Resolved_By NOT IN ('CWLabTech', 'replibit')
		AND v_rpt_Service.Date_Entered BETWEEN @StartDt AND @EndDt
	GROUP BY w.WeekNum
	ORDER BY 1
	
--select top 20 *
--	FROM v_rpt_Service WITH (NOLOCK) 
--		WHERE 1=1
--		AND (v_rpt_Service.summary like 'BDR-Backup Job Failed%' or v_rpt_Service.summary like 'Backup Failed%')
--		AND v_rpt_Service.Resolved_By NOT IN ('CWLabTech', 'replibit')
--	ORDER BY date_entered DESC

----------------------------------------------------------------------------------------------------------------
-- # Tickets from CS and Professional Services work in the last 7 days

-- select * from User_Defined_Field

SELECT COUNT(*) as NumTicketsFromCS
	from SR_Service_User_Defined_Field_Value UDF WITH (NOLOCK)
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON UDF.sr_service_recid = S.SR_Service_RecID
	WHERE UDF.User_defined_Field_RecId = 6		-- C.S. Issue
		AND UDF.User_Defined_Field_Value = 'true'
		AND S.date_entered > DateAdd(dd, -7, GETDATE())
		
select COUNT(*) as NumTicketsFromProSvcs
	from SR_Service_User_Defined_Field_Value UDF WITH (NOLOCK)
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON UDF.sr_service_recid = S.SR_Service_RecID
	WHERE UDF.User_defined_Field_RecId = 7		-- ProSvc Issue
		AND UDF.User_Defined_Field_Value = 'true'
		AND S.date_entered > DateAdd(dd, -7, GETDATE())
		
select COUNT(*) as NumTicketEscalations
	from SR_Service_User_Defined_Field_Value UDF WITH (NOLOCK)
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON UDF.sr_service_recid = S.SR_Service_RecID
	WHERE UDF.User_defined_Field_RecId = 8		-- Escalated
		AND UDF.User_Defined_Field_Value = 'true'
		AND S.date_entered > DateAdd(dd, -7, GETDATE())
		
select COUNT(*) as NumTicketsPreventable
	from SR_Service_User_Defined_Field_Value UDF WITH (NOLOCK)
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON UDF.sr_service_recid = S.SR_Service_RecID
	WHERE UDF.User_defined_Field_RecId = 9		-- Preventable
		AND UDF.User_Defined_Field_Value = 'true'
		AND S.date_entered > DateAdd(dd, -7, GETDATE())
		
select COUNT(*) as NumOnsiteVisitRequests
	from SR_Service_User_Defined_Field_Value UDF WITH (NOLOCK)
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON UDF.sr_service_recid = S.SR_Service_RecID
	WHERE UDF.User_defined_Field_RecId = 20		-- Onsite Reqst
		AND UDF.User_Defined_Field_Value = 'true'
		AND S.date_entered > DateAdd(dd, -7, GETDATE())

select coalesce(UDF1.User_Defined_Field_Value, '') as CSIssue, coalesce(UDF2.User_Defined_Field_Value, '') as ProSrvIssue, coalesce(UDF3.User_Defined_Field_Value, '') as Escalated
		, coalesce(UDF4.User_Defined_Field_Value, '') as Preventable, coalesce(UDF5.User_Defined_Field_Value, '') as OnsiteReq
		, S.TicketNbr, S.company_name, s.Board_Name, s.Hours_Actual, s.Summary, s.Detail_Description, s.Resolution
	from v_rpt_Service S WITH (NOLOCK)
	LEFT JOIN SR_Service_User_Defined_Field_Value UDF1 WITH (NOLOCK)
		ON UDF1.sr_service_recid = S.SR_Service_RecID
		AND UDF1.User_defined_Field_RecId = 6		-- C.S. Issue
		AND UDF1.User_Defined_Field_Value = 'true'
	LEFT JOIN SR_Service_User_Defined_Field_Value UDF2 WITH (NOLOCK)
		ON UDF2.sr_service_recid = S.SR_Service_RecID
		AND UDF2.User_defined_Field_RecId = 7		-- ProSvc Issue
		AND UDF2.User_Defined_Field_Value = 'true'
	LEFT JOIN SR_Service_User_Defined_Field_Value UDF3 WITH (NOLOCK)
		ON UDF3.sr_service_recid = S.SR_Service_RecID
		AND UDF3.User_defined_Field_RecId = 8		-- Escalated
		AND UDF3.User_Defined_Field_Value = 'true'
	LEFT JOIN SR_Service_User_Defined_Field_Value UDF4 WITH (NOLOCK)
		ON UDF4.sr_service_recid = S.SR_Service_RecID
		AND UDF4.User_defined_Field_RecId = 9		-- Preventable
		AND UDF4.User_Defined_Field_Value = 'true'
	LEFT JOIN SR_Service_User_Defined_Field_Value UDF5 WITH (NOLOCK)
		ON UDF5.sr_service_recid = S.SR_Service_RecID
		AND UDF5.User_defined_Field_RecId = 20		-- Onsite Reqst
		AND UDF5.User_Defined_Field_Value = 'true'
	WHERE S.date_entered > DateAdd(dd, -7, GETDATE())
		and (UDF1.User_Defined_Field_Value = 'true'
			or UDF2.User_Defined_Field_Value = 'true'
			or UDF3.User_Defined_Field_Value = 'true'
			or UDF4.User_Defined_Field_Value = 'true'
			or UDF5.User_Defined_Field_Value = 'true'
		)
	ORDER BY 1 desc,2 desc,3 desc,4 desc,5 desc,6
	
select StatsYear, StatsMonth, Num_Reactive_Tickets_Opened as '# Reactive Tickets', Num_Reactive_Hours, Num_Reactive_Tickets_Same_Day_Close as '# Same Day Close', Avg_Minutes_Per_Ticket as 'Time To Res', Tickets_Closed_Same_Day_Pct as 'Same Day Res'
	from MSP_Dashboard.dbo.vw_StatsByMonth
	order by 1,2

select StatsYear, StatsQuarter, Num_Reactive_Tickets_Opened as '# Reactive Tickets', Num_Reactive_Hours, Num_Reactive_Tickets_Same_Day_Close as '# Same Day Close', Avg_Minutes_Per_Ticket as 'Time To Res', Tickets_Closed_Same_Day_Pct as 'Same Day Res'
	from MSP_Dashboard.dbo.vw_StatsByQuarter
	order by 1,2


USE MSP_Dashboard
GO

-----------------------------------------------------------------------
exec sp_UpdateMspDashboardCompanyStatsByMonth 
exec sp_UpdateMspDashboardCompanyStatsLast30Days

exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,1
exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,2
exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,3
exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,4
exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,5
exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,6
exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,7
exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,8
exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,8
exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,10
exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,11
exec sp_UpdateMspDashboardCompanyStatsByMonth 2018,12
exec sp_UpdateMspDashboardCompanyStatsByMonth 2019,1
exec sp_UpdateMspDashboardCompanyStatsByMonth 2019,2
exec sp_UpdateMspDashboardCompanyStatsByMonth 2019,3
exec sp_UpdateMspDashboardCompanyStatsByMonth 2019,4
exec sp_UpdateMspDashboardCompanyStatsByMonth 2019,5
-----------------------------------------------------------------------

begin tran
	delete FROM MSP_Dashboard.dbo.vw_CompanyStatsByMonth where statsmonth = 21 and Company_Name in ('Whitney Inc', 'SAI Financial Services Inc', 'Therm O Web Inc.')
rollback
commit


--select * FROM MSP_Dashboard.dbo.vw_CompanyStatsByMonth MSP where StatsYear = 2017 and statsmonth = 22 order by 5

SELECT * FROM MSP_Dashboard.dbo.vw_CompanyStatsLast30Days order by (num_endpoints - num_seats)
select * FROM MSP_Dashboard.dbo.vw_CompanyStatsByMonth MSP where StatsYear = 2019 and statsmonth = 4 order by 4,5
select * from MSP_Dashboard.dbo.vw_StatsByMonth order by 1,2
select * from MSP_Dashboard.dbo.vw_StatsByMonthManagedClients order by 1,2
select * from MSP_Dashboard.dbo.vw_StatsByMonthModularClients order by 1,2
select * from MSP_Dashboard.dbo.vw_StatsByQuarter order by 1,2
SELECT * FROM MSP_Dashboard.dbo.vw_CompanyStatsByMonth order by 2,3,4,5
SELECT * FROM MSP_Dashboard.dbo.vw_CompanyStatsByQuarter order by 2,3,4,5

select * from MSP_Dashboard.dbo.vw_StatsLast30DaysManagedClients -- MRR
select * from MSP_Dashboard.dbo.vw_StatsLast30DaysModularClients -- ORR

--------------------
-- Rename a company because it was renamed in Autotask

select distinct Company_Name from CompanyStatsByMonth
select * from CompanyStatsByMonth where company_name like '%foot%'
--delete from CompanyStatsByMonth where CompanyStatsByMonth_Id = 1374

update CompanyStatsByMonth set company_name = 'ICC Group' where company_name = 'IL Constructors Corporation'
update CompanyStatsByMonth set ORR_Amount = 0 where company_name = 'Foot First Podiatry Centers' 


SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, DATEDIFF(dd, Ticket.Create_Time, GETDATE()) as Age--, *
into #CS
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND Board.queue_name like '05%'		-- Protective Services
		AND Ticket.Date_Completed IS NULL
		AND COALESCE(Parent.Account_Name, Account.Account_Name) <> 'WEBIT Services'
	ORDER BY 1

SELECT COUNT(*) as NumTickets, SUM(Age) as TotalDays, (SUM(Age) / COUNT(*)) As AvgDays
	FROM #CS

--------------------------------------------------------------------------------------
-- Patching stats for GGOB

select Company_Name, Num_Endpoints, Num_Endpoints_Missing_Patches, Patch_Score 
	FROM MSP_Dashboard.dbo.vw_CompanyStatsByMonth MSP 
	where statsyear = 2018
		and statsmonth = 5
		and Num_Endpoints > 0
	order by 4

select count(*) as Clients_Below_95
	FROM MSP_Dashboard.dbo.vw_CompanyStatsByMonth MSP 
	where statsyear = 2018
		and statsmonth = 5
		and Num_Endpoints > 0
		and Patch_Score < 94.5

select SUM(Num_Endpoints) AS Num_Endpoints, SUM(Num_Endpoints_Missing_Patches) AS Num_Endpoints_Missing_Patches
		, 1 - (cast(COALESCE(SUM(Num_Endpoints_Missing_Patches), 0) as decimal(12, 4)) / cast(SUM(Num_Endpoints) as decimal(12, 4))) AS Patch_Score
	FROM MSP_Dashboard.dbo.vw_CompanyStatsByMonth MSP 
	where statsyear = 2018
		and statsmonth = 5
		and Num_Endpoints > 0


---------------------------------------------------------------------------------------------
-- Endpoints, Seats and Contracts for Weekly Exec stats

select sum(num_seats) as num_seats, sum(num_endpoints) as num_endpoints, sum(mrr_amount) as MRR_Amount, sum(ORR_Amount) as ORR_Amount
	from MSP_Dashboard.dbo.vw_CompanyStatsByMonth
	where statsyear = 2018 and statsmonth = 2

select Company_Type,  sum(num_seats) as num_Seats, sum(num_endpoints) as num_Endpoints
		, sum(case when mrr_amount > 0 then 1 else 0 end) as Num_MRR_Agree
		, sum(case when ORR_Amount > 0 then 1 else 0 end) as Num_ORR_Agree
		, sum(mrr_amount) as MRR_Amount, sum(ORR_Amount) as ORR_Amount
	from MSP_Dashboard.dbo.vw_CompanyStatsByMonth
	where statsyear = 2018 and statsmonth = 2
	group by Company_Type
	order by 1,2

select Company_Type, Company_Name, sum(num_seats) as num_seats, sum(num_endpoints) as num_endpoints, sum(mrr_amount) as MRR_Amount, sum(ORR_Amount) as ORR_Amount
	from MSP_Dashboard.dbo.vw_CompanyStatsByMonth
	where statsyear = 2018 and statsmonth = 2
	group by Company_Type, Company_Name
	order by 1,2

---------------------------------------------------------------------------------------------
-- Month Stats by Company
SELECT cast(StatsYear as char(4)) + '/0' + cast(StatsMonth as varchar(2)) as YrMo, MSP.Company_Type
		, MSP.Company_Name as 'Company', Num_Seats as '# Seats', Num_Endpoints as '# Endpoints'
		, MRR_Amount as 'MRR $', ORR_Amount as 'ORR $', AISP_Amount as 'AISP'
		, Num_Reactive_Tickets_Opened as '# Tickets Opened', Num_Reactive_Tickets_Closed as '# Tickets Closed'
		, Num_Reactive_Tickets_Same_Day_Response as '# Same Day Response', Num_Reactive_Tickets_Same_Day_Close as '# Same Day Close'
		, Num_Reactive_Hours as '# Reactive Hours', Num_CS_Hours as '# CS Hours', Num_NA_Hours as '# NA Hours', Num_PS_Hours as '# PS Hours', Num_vCIO_Hours as '# vCIO Hours'
		, Avg_Minutes_Per_Ticket as 'Hours / Ticket', Avg_Tickets_Per_Endpoint as 'Tickets / Endpoint', Avg_Hours_Per_Endpoint as 'Hours / Endpoint', Avg_Revenue_Per_Hour as 'Rev / Hour'
		--, Num_Scheduled_NA_Visits as '# NA Scheduled', Num_Completed_NA_Visits as '# NA Completed'
		, Patch_Score, Client_Priority_List_Num AS CPL_Num
	FROM MSP_Dashboard.dbo.vw_CompanyStatsByMonth MSP
	WHERE 1=1
		--AND Company_Type LIKE '10 %'
		--AND Company_Name like '%grand%'
		and statsyear = 2018 and statsmonth = 07
	ORDER BY 1,2,3

-- Quarter Stats by Company
SELECT cast(StatsYear as char(4)) + '/' + cast(StatsQuarter as varchar(2)) as 'Quarter'
		, MSP.Company_Name as 'Company', Num_Seats as '# Seats', Num_Endpoints as '# Endpoints'
		, MRR_Amount as 'MRR $', AISP_Amount as 'AISP'
		, Num_Reactive_Tickets as '# Reactive Tickets', Num_Reactive_Tickets_Same_Day_Response as '# Same Day Response', Num_Reactive_Tickets_Same_Day_Close as '# Same Day Close'
		, Num_Reactive_Hours as '# Reactive Hours', Num_CS_Hours as '# CS Hours', Num_NA_Hours as '# NA Hours', Num_PS_Hours as '# PS Hours', Num_vCIO_Hours as '# vCIO Hours'
		, Avg_Minutes_Per_Ticket as 'Hours / Ticket', Avg_Tickets_Per_Endpoint as 'Tickets / Endpoint', Avg_Hours_Per_Endpoint as 'Hours / Endpoint', Avg_Revenue_Per_Hour as 'Rev / Hour'
		, Num_Scheduled_NA_Visits as '# NA Scheduled', Num_Completed_NA_Visits as '# NA Completed'
	FROM MSP_Dashboard.dbo.vw_CompanyStatsByQuarter MSP
	WHERE 1=1
		--AND Company_Name like '%grand%'
	ORDER BY 1,2

-- Eric's Monthly stats by Company
SELECT cast(StatsYear as char(4)) + case when StatsMonth < 10 then '/0' else '/' end + cast(StatsMonth as varchar(2)) as YrMo, Company_Type
		, MSP.Company_Name as 'Company', Num_Seats as '# Seats', Num_Endpoints as '# Endpoints'
		, MRR_Amount as 'MRR $', AISP_Amount as 'AISP'
		, Num_Reactive_Tickets_Opened as '# Tickets Opened', Num_Reactive_Tickets_Closed as '# Tickets Closed', Num_Reactive_Hours as '# Reactive Hours'
		, Avg_Minutes_Per_Ticket as 'Mins / Ticket', Avg_Tickets_Per_Endpoint as 'Tickets / Endpoint'
		, Avg_Hours_Per_Endpoint as 'Hours / Endpoint', Avg_Revenue_Per_Hour as 'Rev / Hour'
	FROM MSP_Dashboard.dbo.vw_CompanyStatsByMonth MSP
	WHERE 1=1
		AND Company_Type not LIKE '95 %'
		--AND Company_Name like '%grand%'
		and statsyear = 2018
		and statsmonth = 4
	ORDER BY 1,2,3
	
-- Eric's Monthly stats Summary
SELECT cast(StatsYear as char(4)) + case when StatsMonth < 10 then '/0' else '/' end + cast(StatsMonth as varchar(2)) as YrMo, Num_Seats as '# Seats', Num_Endpoints as '# Endpoints'
		, MRR_Amount as 'MRR $', AISP_Amount as 'AISP'
		, Num_Reactive_Tickets_Opened as '# Tickets Opened', Num_Reactive_Tickets_Closed as '# Tickets Closed', Num_Reactive_Hours as '# Reactive Hours'
		, Avg_Minutes_Per_Ticket as 'Mins / Ticket', Avg_Tickets_Per_Endpoint as 'Tickets / Endpoint'
		, Avg_Hours_Per_Endpoint as 'Hours / Endpoint', Avg_Revenue_Per_Hour as 'Rev / Hour'

	--FROM MSP_Dashboard.dbo.vw_StatsByMonth MSP
	FROM MSP_Dashboard.dbo.vw_StatsByMonthManagedClients MSP
	--FROM MSP_Dashboard.dbo.vw_StatsByMonthModularClients MSP
	WHERE 1=1
		--AND Company_Name like '%grand%'
		--and StatsMonth = 6
		and statsyear = 2018
		--and statsmonth between 1 and 4
	ORDER BY 1,2,3

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RHEM and TPE Trend

Declare @Yr1 int, @Mo1 int, @Yr2 int, @Mo2 int, @Yr3 int, @Mo3 int, @Yr4 int, @Mo4 int, @Yr5 int, @Mo5 int, @Yr6 int, @Mo6 int, @CalcDate datetime

SET @CalcDate = DATEADD(mm, -1, dbo.GetFirstDayOfMonth(GETDATE()))
PRINT @CalcDate
SET @Yr6 = DATEPART(yy, @CalcDate)
SET @Mo6 = DATEPART(mm, @CalcDate)
SET @CalcDate = DATEADD(mm, -1, @CalcDate)
SET @Yr5 = DATEPART(yy, @CalcDate)
SET @Mo5 = DATEPART(mm, @CalcDate)
SET @CalcDate = DATEADD(mm, -1, @CalcDate)
SET @Yr4 = DATEPART(yy, @CalcDate)
SET @Mo4 = DATEPART(mm, @CalcDate)
SET @CalcDate = DATEADD(mm, -1, @CalcDate)
SET @Yr3 = DATEPART(yy, @CalcDate)
SET @Mo3 = DATEPART(mm, @CalcDate)
SET @CalcDate = DATEADD(mm, -1, @CalcDate)
SET @Yr2 = DATEPART(yy, @CalcDate)
SET @Mo2 = DATEPART(mm, @CalcDate)
SET @CalcDate = DATEADD(mm, -1, @CalcDate)
SET @Yr1 = DATEPART(yy, @CalcDate)
SET @Mo1 = DATEPART(mm, @CalcDate)
PRINT @CalcDate
PRINT 'Month1: ' + cast(@Mo1 as varchar(2))
PRINT 'Month6: ' + cast(@Mo6 as varchar(2))

SELECT MSP.Company_Type, MSP.Company_Name as 'Company', Num_Seats as '# Seats', Num_Endpoints as '# Endpoints'
		, cast(CASE WHEN MRR_Amount <> 0 THEN MRR_Amount ELSE ORR_Amount END as int) as 'Contract $', AISP_Amount as 'AISP $'
		--, Client_Priority_List_Num
		, COALESCE((SELECT Avg_Tickets_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr1
						AND MSP2.StatsMonth = @Mo1
				), 0) as 'TPE1'
		, COALESCE((SELECT Avg_Tickets_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr2
						AND MSP2.StatsMonth = @Mo2
				), 0) as 'TPE2'
		, COALESCE((SELECT Avg_Tickets_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr3
						AND MSP2.StatsMonth = @Mo3
				), 0) as 'TPE3'
		, COALESCE((SELECT Avg_Tickets_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr4
						AND MSP2.StatsMonth = @Mo4
				), 0) as 'TPE4'
		, COALESCE((SELECT Avg_Tickets_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr5
						AND MSP2.StatsMonth = @Mo5
				), 0) as 'TPE5'
		, COALESCE((SELECT Avg_Tickets_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr6
						AND MSP2.StatsMonth = @Mo6
				), 0) as 'TPE6'
			
		, COALESCE((SELECT Avg_Hours_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr1
						AND MSP2.StatsMonth = @Mo1
				), 0) as 'RHEM1'
		, COALESCE((SELECT Avg_Hours_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr2
						AND MSP2.StatsMonth = @Mo2
				), 0) as 'RHEM2'
		, COALESCE((SELECT Avg_Hours_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr3
						AND MSP2.StatsMonth = @Mo3
				), 0) as 'RHEM3'
		, COALESCE((SELECT Avg_Hours_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr4
						AND MSP2.StatsMonth = @Mo4
				), 0) as 'RHEM4'
		, COALESCE((SELECT Avg_Hours_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr5
						AND MSP2.StatsMonth = @Mo5
				), 0) as 'RHEM5'
		, COALESCE((SELECT Avg_Hours_Per_Endpoint
						FROM vw_CompanyStatsByMonth MSP2
						WHERE MSP2.Company_Name = MSP.Company_Name
						AND MSP2.StatsYear = @Yr6
						AND MSP2.StatsMonth = @Mo6
				), 0) as 'RHEM6'
	FROM vw_CompanyStatsByMonth MSP
	WHERE 1=1
		--AND Company_Type LIKE '10 %'
		AND StatsYear = @Yr6
		AND StatsMonth = @Mo6
	ORDER BY 1, 2



-------------------------------------------------------------------------------------
-- AISP amounts that are too low and contracts need to be changed

SELECT cast(StatsYear as char(4)) + '/0' + cast(StatsMonth as varchar(2)) as YrMo
		, MSP.Company_Name as 'Company', Num_Seats_Agreement, Num_Seats as '# Seats', Num_Endpoints as '# Endpoints', AISP_Amount as 'AISP'
		, MRR_Amount as 'MRR $', (Num_Seats * 150) as 'New MRR$', ((Num_Seats * 150) - MRR_Amount) as 'Contract Diff'
	FROM MSP_Dashboard.dbo.vw_CompanyStatsByMonth MSP
	WHERE 1=1
		AND Company_Type LIKE '10 %'
		--AND Company_Name like '%grand%'
		and statsyear = 2018 and StatsMonth = 8
	ORDER BY 2,8 DESC


---------------------------------------------------------------
-- MRR/ORR Contract Lookups

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, [contract].Contract_Name, category.contract_category_name, convert(char(10), contract.start_date, 111) as contract_start, convert(char(10), contract.end_date, 111) as contract_end
			, COALESCE((SELECT SUM(p.contract_period_price)
							FROM Autotask.TF_511394_WH.dbo.wh_contract_service CS WITH (NOLOCK)
							INNER JOIN Autotask.TF_511394_WH.dbo.wh_service S WITH (NOLOCK)
								ON CS.Service_Id = S.Service_Id
							INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_service_period p WITH (NOLOCK)
								ON CS.Contract_Service_Id = p.Contract_Service_Id
								AND GETDATE() BETWEEN p.contract_period_date and p.contract_period_end_date
							WHERE CS.contract_id = contract.contract_id
								AND S.Allocation_Code_ID IN (29683491, 29682901)	-- "Modular Services", "MRR - Monthly Recurring Revenue~IT Service Agreements"
						), 0) AS Contract_Price_Monthly
		FROM Autotask.TF_511394_WH.dbo.wh_contract [contract] WITH (NOLOCK)
		INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_category category WITH (NOLOCK)
			ON contract.contract_category_id = category.contract_category_id	
		INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account WITH (NOLOCK)
			ON Account.account_id = contract.account_id
		INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon WITH (NOLOCK)
			ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
		LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent WITH (NOLOCK)
			ON Parent.account_id = Account.parent_account_id
		WHERE contract.is_active = 1
			AND GETDATE() BETWEEN contract.start_date and contract.end_date
			AND LEFT(category.contract_category_name, 16) in ('Managed Services', 'Other Recurring ')
		GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name), contract.contract_id, [contract].Contract_Name, contract.start_date, contract.end_date, category.contract_category_name
		order by 1,2

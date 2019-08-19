-- TF_511394_WH database

-- exec sp_UpdateMspDashboardCompanyStatsLast30Days

USE MSP_Dashboard
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_UpdateMspDashboardCompanyStatsLast30Days]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_UpdateMspDashboardCompanyStatsLast30Days]
GO

CREATE  PROCEDURE [dbo].[sp_UpdateMspDashboardCompanyStatsLast30Days]
AS 

SET NOCOUNT ON 

/*------------------------------------------------------
*  MRR (Monthly Recurring Revenue) Evaluator Metrics:
	- MRR $	CW - Finance - Agreements - Company type '10' and '25'. Use Billing Amount field.
	# Seats	People - Decision Maker, End User FT, POC1, POC2. = 1 seat.  PT30 - .5 of a seat.  PT15 = .25 of a seat
	# Endpoints	Computers (Managed Servers, Managed Workstations) - should include thin clients
	AISP	MRR / # Seats (our goal is 3,500)
	Avg Ticket Resolution	 # Hours / # Reactive tickets (Only tickets that have time on them)
	Tickets/Endpoint/Month	 # Reactive tickets / # Endpoints
	RHEM	 # Hours / # Endpoints
	Run Rate	 $MRR / # 
------------------------------------------------------			*/

DECLARE @StartDate datetime, @EndDate datetime
SET @EndDate = GETDATE()
SET @StartDate = DATEADD(dd, -30, @EndDate)

PRINT @StartDate
PRINT @EndDate

/*
* key_account_icon_id:
*	201 - 10 Client - Managed Services
*	200 - 15 Client - Modular Service
*	202 - 20 Client - On Demand Service
*	204 - 95 Internal
*	203 - 30 Former Client
*/ 


-- The MSP_Dashboard.dbo.CompanyStatsLast30Days table will always hold the last 30 days worth of data
-- So every time this procedure is run, delete all records and insert new ones with data for the last 30 days

DELETE FROM MSP_Dashboard.dbo.CompanyStatsLast30Days

---------------------------------------------------
-- Load the table with all active companies that have a Managed Services agreement
PRINT 'Inserting records for the month'

INSERT INTO MSP_Dashboard.dbo.CompanyStatsLast30Days (Company_Type, Company_Name, Num_Seats_Agreement, Num_Annual_NA_Visits)		
	SELECT DISTINCT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name
				, COALESCE(AccountUDf.Seats_as_numeric, 0) AS Num_Seats_Agreement
				, COALESCE(AccountUDf.NA_Visits_per_Year_as_numeric, 0) AS Num_Annual_NA_Visits
		FROM Autotask.TF_511394_WH.dbo.wh_account Account
		LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
			ON Account.account_id = AccountUDf.account_id
		LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
			ON Parent.account_id = Account.parent_account_id
		INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon
			ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
		WHERE 1=1
			and Account.is_active = 1
			and Account.key_account_icon_id in (201, 200, 204)	-- 10, 15, 95 clients
		ORDER BY 1,2


-- Update Seats, Endpoints and Agreement info 

PRINT 'Updating Seats and Endpoints...'

---------------------------------------------------
---- # Seats

UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_Seats = Upd.Num_Seats, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN (			
			SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name
					, SUM(CASE WHEN ContactUDF.Contact_Type_stored_value IN ('CL - Decision Maker','CL - End User (FT)','CL - POC 1','CL - POC 2','CL - VIP') THEN 1.00
									WHEN ContactUDF.Contact_Type_stored_value = 'CL - End User (PT30)' THEN 0.50
									WHEN ContactUDF.Contact_Type_stored_value = 'CL - End User (PT15)' THEN 0.25
									ELSE 0 END) AS Num_Seats
				FROM Autotask.TF_511394_WH.dbo.wh_account Account
				LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
					ON Parent.account_id = Account.parent_account_id
				INNER JOIN Autotask.TF_511394_WH.dbo.wh_account_contact Contact
					ON contact.account_id = Account.account_id
				LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_contact_udf ContactUDF
					ON Contact.account_contact_id = ContactUDF.account_contact_id
				WHERE 1=1
						and Account.is_active = 1
						and Contact.is_active = 1
						and Account.key_account_icon_id in (201, 200, 204)	-- 10, 15, 95 clients
				GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
	) Upd ON Upd.Company_Name = MRR.Company_Name

---------------------------------------------------
---- # Endpoints
	
UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_Endpoints = Upd.Num_Endpoints, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN (			
			SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, COUNT(*) as Num_Endpoints
				FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
				LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Account
					ON Account.account_id = InstalledProduct.account_id
				LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
					ON Parent.account_id = Account.parent_account_id
				WHERE 1=1
					AND Account.is_active = 1
					AND InstalledProduct.is_active = 1
					AND InstalledProduct.aem_device_id is not null
				GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
	) Upd ON Upd.Company_Name = MRR.Company_Name

---------------------------------------------------
---- MRR $, ORR $
UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET MRR_Amount = CASE WHEN Company_Type = '10 Client - Managed Services' THEN Upd.Contract_Price ELSE 0 END
			, ORR_Amount = CASE WHEN Company_Type = '15 Client - Modular Services' THEN Upd.Contract_Price ELSE 0 END
			, MRR_Contract_Start_Date = Upd.Start_Date
			, MRR_Contract_End_Date = Upd.End_Date
			, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN (
		SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, C.start_date, C.end_date, SUM(P.Contract_Period_Price) AS Contract_Price
			FROM Autotask.TF_511394_WH.dbo.wh_contract C WITH (NOLOCK)
			INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_service CS WITH (NOLOCK)
				ON CS.contract_id = C.contract_id
			INNER JOIN Autotask.TF_511394_WH.dbo.wh_service S WITH (NOLOCK)
				ON CS.Service_Id = S.Service_Id
			INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_service_period p WITH (NOLOCK)
				ON CS.Contract_Service_Id = p.Contract_Service_Id
			INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_category category WITH (NOLOCK)
				ON C.contract_category_id = category.contract_category_id	
			INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account WITH (NOLOCK)
				ON Account.account_id = C.account_id
			INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon WITH (NOLOCK)
				ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
			LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent WITH (NOLOCK)
				ON Parent.account_id = Account.parent_account_id
			WHERE C.is_active = 1
				AND S.Active = 1
				AND @EndDate BETWEEN C.start_date and C.end_date
				AND @EndDate BETWEEN p.contract_period_date and p.contract_period_end_date
				AND LEFT(category.contract_category_name, 16) in ('Managed Services', 'Other Recurring ')
			GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name), C.start_date, C.end_date
	) Upd ON Upd.Company_Name = MRR.Company_Name


---------------------------------------------------
-- Get Reactive ticket info
PRINT 'Updating Num_Reactive_Tickets_Opened'

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name,  count(*) as Num_Reactive_Tickets_Opened
	INTO #AT1
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND Ticket.Create_Time between @StartDate AND @EndDate
		AND (Board.queue_name like '01%' OR Board.queue_name like '00%')
		AND Ticket.Total_Worked_Hours > 0
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)

UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_Reactive_Tickets_Opened = COALESCE(AT.Num_Reactive_Tickets_Opened, 0)
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT1 AT
		ON AT.Company_Name = MRR.company_name

DROP TABLE #AT1
---------------------------------

PRINT 'Updating Num_Reactive_Tickets_Closed'

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name,  count(*) as Num_Reactive_Tickets_Closed
	INTO #AT2
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND Ticket.Date_Completed between @StartDate AND @EndDate
		AND (Board.queue_name like '01%' OR Board.queue_name like '00%')
		AND Ticket.Total_Worked_Hours > 0
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)

UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_Reactive_Tickets_Closed = COALESCE(AT.Num_Reactive_Tickets_Closed, 0)
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT2 AT
		ON AT.Company_Name = MRR.company_name

DROP TABLE #AT2

---------------------------------

PRINT 'Updating Num_Reactive_Tickets_Resolved_On_Time'

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name,  count(*) as Num_Reactive_Tickets_Resolved_On_Time
	INTO #AT21
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND Ticket.Date_Completed between @StartDate AND @EndDate
		AND (Board.queue_name like '01%' OR Board.queue_name like '00%')
		AND Ticket.Total_Worked_Hours > 0
		AND isnull(Ticket.resolution_actual_time, Ticket.date_completed) < Ticket.due_time	-- Resolved before the Due Date/Time
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)

UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_Reactive_Tickets_Resolved_On_Time = COALESCE(AT.Num_Reactive_Tickets_Resolved_On_Time, 0)
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT21 AT
		ON AT.Company_Name = MRR.company_name

UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_Reactive_Tickets_Resolved_On_Time = 0
		, Update_Date_Time = GETDATE()
	WHERE Num_Reactive_Tickets_Resolved_On_Time IS NULL

DROP TABLE #AT21

---------------------------------

PRINT 'Updating Num_Reactive_Tickets_Same_Day_Response'

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, count(*) as Num_Reactive_Tickets_Same_Day_Response
	INTO #AT3
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_service_level_agreement_event_dates SLA
		ON SLA.task_id = Ticket.task_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND Ticket.Create_Time between @StartDate AND @EndDate
		AND Board.queue_name like '01%'
		AND DATEPART(dw, Ticket.Create_Time) BETWEEN 2 AND 6	-- Only count weekdays
		AND SLA.first_response_elapsed_hours <= 12
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)

UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_Reactive_Tickets_Same_Day_Response = COALESCE(AT.Num_Reactive_Tickets_Same_Day_Response, 0)
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT3 AT
		ON AT.Company_Name = MRR.company_name

DROP TABLE #AT3
---------------------------------

PRINT 'Updating Num_Reactive_Tickets_Same_Day_Close'

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, count(*) as Num_Reactive_Tickets_Same_Day_Close
	INTO #AT4
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_service_level_agreement_event_dates SLA
		ON SLA.task_id = Ticket.task_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND Ticket.Create_Time between @StartDate AND @EndDate
		AND Board.queue_name like '01%'
		AND DATEPART(dw, Ticket.Create_Time) BETWEEN 2 AND 6	-- Only count weekdays
		AND SLA.resolution_elapsed_hours <= 12
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)

UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_Reactive_Tickets_Same_Day_Close = COALESCE(AT.Num_Reactive_Tickets_Same_Day_Close, 0)
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT4 AT
		ON AT.Company_Name = MRR.company_name

DROP TABLE #AT4
---------------------------------


PRINT 'Updating Num_Reactive_Hours'

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, SUM(SubTime.Hours_Worked) as Num_Reactive_Hours
	INTO #AT5
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_item Time
		ON Time.task_id = Ticket.task_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_subitem SubTime 
		ON SubTime.time_item_id = Time.time_item_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND SubTime.Date_Worked between @StartDate AND @EndDate
		AND (Board.queue_name like '01%' OR Board.queue_name like '00%')
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
										
UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_Reactive_Hours = COALESCE(AT.Num_Reactive_Hours, 0)
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT5 AT
		ON AT.Company_Name = MRR.company_name

DROP TABLE #AT5
---------------------------------

PRINT 'Updating Num_Reactive_Hours_On_Closed_Tickets'

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, SUM(Ticket.Total_Worked_Hours) as Num_Reactive_Hours_On_Closed_Tickets
	INTO #AT11
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND Ticket.Date_Completed between @StartDate AND @EndDate
		AND (Board.queue_name like '01%' OR Board.queue_name like '00%')
		AND Ticket.Total_Worked_Hours > 0
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
										
UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_Reactive_Hours_On_Closed_Tickets = COALESCE(AT.Num_Reactive_Hours_On_Closed_Tickets, 0)
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT11 AT
		ON AT.Company_Name = MRR.company_name

DROP TABLE #AT11
---------------------------------

PRINT 'Updating Num_CS_Hours'

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name,  SUM(SubTime.Hours_Worked) as Num_CS_Hours
	INTO #AT6
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_item Time
		ON Time.task_id = Ticket.task_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_subitem SubTime 
		ON SubTime.time_item_id = Time.time_item_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND SubTime.Date_Worked between @StartDate AND @EndDate
		AND Board.queue_name LIKE '05%'
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)


UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_CS_Hours = COALESCE(AT.Num_CS_Hours, 0)
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT6 AT
		ON AT.Company_Name = MRR.company_name

DROP TABLE #AT6
---------------------------------

PRINT 'Updating Num_NA_Hours'

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name,   SUM(SubTime.Hours_Worked) as Num_NA_Hours
	INTO #AT7
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_item Time
		ON Time.task_id = Ticket.task_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_subitem SubTime 
		ON SubTime.time_item_id = Time.time_item_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND SubTime.Date_Worked between @StartDate AND @EndDate
		AND Board.queue_name LIKE '04%'
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
										
UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_NA_Hours = COALESCE(AT.Num_NA_Hours, 0)
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT7 AT
		ON AT.Company_Name = MRR.company_name

DROP TABLE #AT7
---------------------------------

PRINT 'Updating Num_PS_Hours'

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name,   SUM(SubTime.Hours_Worked) as Num_PS_Hours
	INTO #AT8
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_item Time
		ON Time.task_id = Ticket.task_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_subitem SubTime 
		ON SubTime.time_item_id = Time.time_item_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND SubTime.Date_Worked between @StartDate AND @EndDate
		AND (Board.queue_name LIKE '03%' OR Ticket.Project_Id IS NOT NULL)
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
										
UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_PS_Hours = COALESCE(AT.Num_PS_Hours, 0)
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT8 AT
		ON AT.Company_Name = MRR.company_name

DROP TABLE #AT8
---------------------------------

PRINT 'Updating Num_vCIO_Hours'

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name,   SUM(SubTime.Hours_Worked) as Num_vCIO_Hours
	INTO #AT9
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_item Time
		ON Time.task_id = Ticket.task_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_subitem SubTime 
		ON SubTime.time_item_id = Time.time_item_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND SubTime.Date_Worked between @StartDate AND @EndDate
		AND Board.queue_name LIKE '02%'
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
										
UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Num_vCIO_Hours = COALESCE(AT.Num_vCIO_Hours, 0)
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT9 AT
		ON AT.Company_Name = MRR.company_name

DROP TABLE #AT9
---------------------------------
		
PRINT 'Updating Patch_Score'

SELECT AllCompanies.Company_Name, AllCompanies.Total_Endpoints, COALESCE(MissingPatches.Endpoints_Missing_Patches, 0) AS Num_Endpoints_Missing_Patches
		, 1 - (cast(COALESCE(MissingPatches.Endpoints_Missing_Patches, 0) as decimal(12, 4)) / cast(AllCompanies.Total_Endpoints as decimal(12, 4))) AS Patch_Score
	INTO #AT10
	FROM (
SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, COUNT(*) as Total_Endpoints
	FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = InstalledProduct.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_product Product
		ON Product.product_id = InstalledProduct.product_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_device_audit_operating_system_name wh_device_audit_operating_system_name
		ON wh_device_audit_operating_system_name.device_audit_operating_system_name_id = InstalledProduct.device_audit_operating_system_name_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	WHERE 1=1
		AND Account.is_active = 1
		AND InstalledProduct.is_active = 1
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
	) AllCompanies
	LEFT JOIN (
SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, COUNT(*) as Endpoints_Missing_Patches
	FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = InstalledProduct.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_product Product
		ON Product.product_id = InstalledProduct.product_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_device_audit_operating_system_name wh_device_audit_operating_system_name
		ON wh_device_audit_operating_system_name.device_audit_operating_system_name_id = InstalledProduct.device_audit_operating_system_name_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	WHERE 1=1
		AND Account.is_active = 1
		AND InstalledProduct.is_active = 1
		AND InstalledProduct.device_audit_missing_patch_count > 0
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
	) MissingPatches
		ON AllCompanies.Company_Name = MissingPatches.Company_Name
							
UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET Patch_Score = COALESCE(AT.Patch_Score, 0)
		, Num_Endpoints_Missing_Patches = AT.Num_Endpoints_Missing_Patches
		, Update_Date_Time = GETDATE()
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days MRR
	INNER JOIN #AT10 AT
		ON AT.Company_Name = MRR.company_name

DROP TABLE #AT10
---------------------------------

---------------------------------------------------
-- Update Calculated fields

PRINT 'Updating Calculated fields'

UPDATE MSP_Dashboard.dbo.CompanyStatsLast30Days
	SET AISP_Amount = CASE WHEN Num_Seats > 0 THEN (CASE WHEN MRR_Amount > 0 THEN MRR_Amount ELSE ORR_Amount END / Num_Seats) ELSE 0 END
		, Update_Date_Time = GETDATE()

	


GO
-- exec sp_UpdateMspDashboardCompanyStatsByMonth 2017, 10, 1

USE cwwebapp_webit
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_UpdateMspDashboardCompanyStatsByMonth]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_UpdateMspDashboardCompanyStatsByMonth]
GO

CREATE  PROCEDURE [dbo].[sp_UpdateMspDashboardCompanyStatsByMonth](
	@Year int
	, @Month int
	, @ReRunMonth bit = 0
)
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

---------------------------------------------------
---- Tickets info and master list of Companies from CW:

DECLARE @StartDt datetime, @EndDt datetime--, @ReRunMonth bit
if @Month < 10
begin
	print cast(@Year as char(4)) + '-0' + cast(@Month as char(1)) + '-01' 
	SET @StartDt = cast(@Year as char(4)) + '-0' + cast(@Month as char(1)) + '-01' 
end
else
begin
	print cast(@Year as char(4)) + '-' + cast(@Month as char(2)) + '-01'
	SET @StartDt = cast(@Year as char(4)) + '-' + cast(@Month as char(2)) + '-01' 
end

SET @EndDt = DATEADD(ss, -1, DATEADD(mm, 1, @StartDt))

SET @ReRunMonth = 1
PRINT @StartDt
PRINT @EndDt
PRINT @ReRunMonth


---------------------------------------------------
-- Check to see if this month has already been loaded
IF exists (select * 
				FROM MSP_Dashboard.dbo.CompanyStatsByMonth
				WHERE StatsYear = year(@StartDt) 
				and StatsMonth = month(@StartDt))
	and @ReRunMonth <> 1
BEGIN
	PRINT convert(char(10), @StartDt, 111) + ' is already loaded into CompanyStatsByMonth and @ReRunMonth is set to false'
	RETURN
END



---------------------------------------------------
-- Load the table with all active companies that have a Managed Services agreement
-- If this month is already loaded into the table, you can use the @ReRunMonth parm to force an update to the month
-- BUT These fields will NOT be updated: 
--		Company Name, Company Type, # Seats Agreement, # Seats, # Endpoints, MRR $, ORR $

IF not exists (select * 
					FROM MSP_Dashboard.dbo.CompanyStatsByMonth
					WHERE StatsYear = year(@StartDt) 
					and StatsMonth = month(@StartDt))
BEGIN

	INSERT INTO MSP_Dashboard.dbo.CompanyStatsByMonth (StatsYear, StatsMonth, Company_Type, Company_Name, Num_Seats_Agreement)
		SELECT year(@StartDt) as StatsYear, month(@StartDt) as StatsMonth, Company_Type_Desc, Company_Name
				, COALESCE((SELECT User_Defined_Field_Value
								FROM Company_User_Defined_Field_Value WITH (NOLOCK)
								WHERE User_Defined_Field_RecID = 1 
								AND Company_RecID = v_rpt_Company.Company_RecID), 0)
			FROM v_rpt_Company
			WHERE LEFT(Company_Type_Desc, 3) IN ('10 ', '15 ', '95 ')
				and Company_Status_Desc like 'Active%'
				and (exists (SELECT *
								FROM v_agr_search_screen s WITH (NOLOCK)
								WHERE s.agr_status = 'Active'
									AND s.agr_type_desc like 'Managed Services%'
									AND s.Company_RecID = v_rpt_Company.Company_RecID)
					or Company_id = '95 Webit'
					or (Company_id = '10 PackagingPersonified' AND @StartDt < '07/01/2017')	-- PPI terminated at the end of June
					)
			ORDER BY 1,2

	--TODO: this is only needed during development time
	DELETE FROM MSP_Dashboard.dbo.CompanyStatsByMonth 
		WHERE StatsYear = 2017 and StatsMonth < 7 AND Company_Name IN ('Batavia Public Library', 'Perfect Plastic Printing')
END


-- Only update Seats, Endpoints and Agreement info if this the current month.
-- These metrics need to get frozen at the end of each month because there is no way to recalculate them for past dates
IF @EndDt >= dateadd(dd, -1, cast(GETDATE() as date))
BEGIN
	PRINT 'Updating Seats and Endpoints...'

	---------------------------------------------------
	---- # Seats

	UPDATE MSP_Dashboard.dbo.CompanyStatsByMonth
		SET Num_Seats = Upd.Num_Seats
		FROM MSP_Dashboard.dbo.CompanyStatsByMonth MRR
		INNER JOIN (
			SELECT Company_Name, SUM(CASE WHEN contact_type IN ('CL - Decision Maker','CL - End User (FT)','CL - POC 1','CL - POC 2','CL - VIP') THEN 1.00
						WHEN Contact_Type = 'CL - End User (PT30)' THEN 0.50
						WHEN Contact_Type = 'CL - End User (PT15)' THEN 0.25
						ELSE 0 END) AS Num_Seats
				FROM v_ContactSearchList WITH (NOLOCK)
				WHERE Inactive_flag_text = 'Active'
					and contact_type IN ('CL - Decision Maker','CL - End User (FT)','CL - End User (PT15)','CL - End User (PT30)','CL - POC 1','CL - POC 2','CL - VIP')
					--and company_status = 'Active'
					--AND Company_Type in ('10 Client - Managed Services', '15 Client - Modular Service')
				GROUP BY Company_Name
		) Upd ON Upd.Company_Name = MRR.Company_Name
		AND MRR.StatsYear = year(@StartDt)
		AND MRR.StatsMonth = month(@StartDt)
		

	---------------------------------------------------
	---- # Endpoints

	IF OBJECT_ID('tempdb..#Computers') IS NOT NULL
		drop table #Computers

	SELECT * INTO #Computers FROM openquery(WSRMM01, '
	SELECT Clients.Name AS Client_Name, COUNT(*) AS Num_Endpoints
		FROM computers
		INNER JOIN Clients
			ON Clients.ClientId = computers.ClientId
		GROUP BY Clients.Name
	UNION ALL
	SELECT clients.name AS Client_Name, CAST(IFNULL(edfAssigned1.Value, 0) AS UNSIGNED) AS `Num_Comp_Not_Managed`
		FROM Clients 
		LEFT JOIN ExtraFieldData edfAssigned1 
			ON (edfAssigned1.id=Clients.ClientId AND edfAssigned1.ExtraFieldId =(SELECT ExtraField.id FROM ExtraField WHERE LTGuid=''eb08ead0-b2c0-4c98-8f62-8f553b9a540f''))
	')

	UPDATE MSP_Dashboard.dbo.CompanyStatsByMonth
		SET Num_Endpoints = Upd.Num_Endpoints
		FROM MSP_Dashboard.dbo.CompanyStatsByMonth MRR
		INNER JOIN (
			SELECT Company.Company_Name, SUM(LT.Num_Endpoints) as Num_Endpoints
				FROM #Computers LT
				INNER JOIN Company
					ON Company.Company_ID = LT.Client_Name
				GROUP BY Company.Company_Name
		) Upd ON Upd.Company_Name = MRR.Company_Name
		AND MRR.StatsYear = year(@StartDt)
		AND MRR.StatsMonth = month(@StartDt)

	---------------------------------------------------
	---- MRR $, ORR $
	UPDATE MSP_Dashboard.dbo.CompanyStatsByMonth
		SET MRR_Amount = CASE WHEN Company_Type = '10 Client - Managed Services' THEN Upd.MRR_Amount ELSE 0 END
			, ORR_Amount = CASE WHEN Company_Type = '15 Client - Modular Service' THEN Upd.MRR_Amount ELSE 0 END
		FROM MSP_Dashboard.dbo.CompanyStatsByMonth MRR
		INNER JOIN (
			SELECT s.Company_Name, CAST(sum(s.agr_amount) as decimal(10,2)) as MRR_Amount
				FROM v_agr_search_screen s WITH (NOLOCK)
				WHERE s.agr_status = 'Active'
					AND s.agr_type_desc like 'Managed Services%'
				GROUP BY s.Company_Name
		) Upd ON Upd.Company_Name = MRR.Company_Name
		AND MRR.StatsYear = year(@StartDt)
		AND MRR.StatsMonth = month(@StartDt)

	-- PPI contracts where deleted by the time this model was built
	UPDATE MSP_Dashboard.dbo.CompanyStatsByMonth
		SET MRR_Amount = 7000
		WHERE Company_Name = 'Packaging Personified Inc'

	-- DELETE FROM MSP_Dashboard.dbo.CompanyStatsByMonth where MRR_Amount = 0
END

-- select distinct Company_id, Company_Name from v_rpt_Company where  Company_Status_Desc like 'Active%' and  LEFT(Company_Type_Desc, 3) IN ('10 ', '15 ', '95 ') order by 1





---------------------------------------------------
-- Get Reactive ticket info

UPDATE MSP_Dashboard.dbo.CompanyStatsByMonth
	SET Num_Reactive_Tickets_Opened = COALESCE((SELECT count(distinct S.sr_service_recid) as Num_Reactive_Tickets
											from v_rpt_Service S WITH (NOLOCK)
											where S.date_entered between @StartDt AND @EndDt
												AND S.company_name = MRR.company_name
												AND (S.Board_Name LIKE '00%' OR S.Board_Name LIKE '01%')
												AND S.Hours_Actual > 0
										), 0)
		, Num_Reactive_Tickets_Closed = COALESCE((SELECT count(distinct S.sr_service_recid) as Num_Reactive_Tickets
											from v_rpt_Service S WITH (NOLOCK)
											where S.date_closed between @StartDt AND @EndDt
												AND S.company_name = MRR.company_name
												AND (S.Board_Name LIKE '00%' OR S.Board_Name LIKE '01%')
												AND S.Hours_Actual > 0
										), 0)
		, Num_Reactive_Tickets_Same_Day_Response = COALESCE((SELECT count(distinct S.sr_service_recid) as Num_Reactive_Tickets_Same_Day_Response
																from v_rpt_Service S WITH (NOLOCK)
																where S.date_entered between @StartDt AND @EndDt
																	AND S.company_name = MRR.company_name
																	AND (S.Board_Name LIKE '00%' OR S.Board_Name LIKE '01%')
																	AND S.Hours_Actual > 0
																	AND (EXISTS (SELECT * 
																						FROM SR_Detail WITH (NOLOCK) 
																						WHERE SR_Detail.SR_Service_RecID = S.SR_Service_RecID
																						AND SR_Detail.Date_Created < CASE WHEN DATEPART(hh, S.date_entered) <= 18
																															THEN DATEADD(dd, 1, CAST(S.date_entered AS DATE))
																															ELSE DATEADD(dd, 2, CAST(S.date_entered AS DATE)) END	-- If Opened before 6PM, Note must be Same Day, otherwise next day
																						AND SR_Detail.InternalAnalysis_Flag = 0 
																						AND SR_Detail.SR_Detail_Notes <> ''
																						)
																		OR EXISTS (SELECT * 
																						FROM v_rpt_Time WITH (NOLOCK) 
																						WHERE v_rpt_Time.SR_Service_RecID = S.SR_Service_RecID
																						AND v_rpt_Time.Date_Entered_UTC < CASE WHEN DATEPART(hh, S.date_entered) <= 18
																															THEN DATEADD(dd, 1, CAST(S.date_entered AS DATE))
																															ELSE DATEADD(dd, 2, CAST(S.date_entered AS DATE)) END	-- If Opened before 6PM, Note must be Same Day, otherwise next day
																						AND v_rpt_Time.Notes <> ''
																						)
																		)
															), 0)
		, Num_Reactive_Tickets_Same_Day_Close = COALESCE((SELECT count(distinct S.sr_service_recid) as Num_Reactive_Tickets_Same_Day_Close
																from v_rpt_Service S WITH (NOLOCK)
																where S.date_entered between @StartDt AND @EndDt
																	AND S.company_name = MRR.company_name
																	AND (S.Board_Name LIKE '00%' OR S.Board_Name LIKE '01%')
																	AND S.Hours_Actual > 0
																	AND (S.Date_Closed < DATEADD(dd, 1, CAST(S.date_entered AS DATE))
																		OR EXISTS (SELECT *
																						FROM SR_Service_Audit WITH (NOLOCK)
																						WHERE SR_Service_Audit.SR_Service_RecID = S.SR_Service_RecID
																							AND SR_Service_Audit.NewValue_Text = 'Completed (Need Client Signoff)'
																							AND SR_Service_Audit.Date_Entered_UTC < DATEADD(dd, 1, CAST(S.date_entered AS DATE)))
																		)
															), 0)
		, Num_Reactive_Hours = COALESCE((SELECT SUM(T.hours_actual) as Total_Hours_Worked
											from v_rpt_Time T WITH (NOLOCK) 
											INNER JOIN v_rpt_Service S WITH (NOLOCK)
												ON T.sr_service_recid = S.SR_Service_RecID
											where T.Date_Start between @StartDt AND @EndDt
												AND S.company_name = MRR.company_name
												AND (S.Board_Name LIKE '00%' OR S.Board_Name LIKE '01%')
										), 0)
		, Num_CS_Hours = COALESCE((SELECT SUM(T.hours_actual) as Total_Hours_Worked
											from v_rpt_Time T WITH (NOLOCK) 
											INNER JOIN v_rpt_Service S WITH (NOLOCK)
												ON T.sr_service_recid = S.SR_Service_RecID
											where T.Date_Start between @StartDt AND @EndDt
												AND S.company_name = MRR.company_name
												AND (S.Board_Name LIKE '05%')
										), 0)
		, Num_NA_Hours = COALESCE((SELECT SUM(T.hours_actual) as Total_Hours_Worked
											from v_rpt_Time T WITH (NOLOCK) 
											INNER JOIN v_rpt_Service S WITH (NOLOCK)
												ON T.sr_service_recid = S.SR_Service_RecID
											where T.Date_Start between @StartDt AND @EndDt
												AND S.company_name = MRR.company_name
												AND (S.Board_Name LIKE '04%')
										), 0)
		, Num_PS_Hours = COALESCE((SELECT SUM(T.hours_actual) as Total_Hours_Worked
											FROM v_rpt_Time T WITH (NOLOCK) 	
											INNER JOIN SR_Service S WITH (NOLOCK)
												ON T.sr_service_recid = S.SR_Service_RecID
											INNER JOIN Company  WITH (NOLOCK)
												ON Company.company_recid = s.company_recid
											INNER JOIN SR_Board sb  WITH (NOLOCK)
												ON sb.SR_Board_RecID = s.SR_Board_RecID
											where T.Date_Start between @StartDt AND @EndDt
												AND Company.company_name = MRR.company_name
												AND (sb.Board_Name LIKE '03%' OR T.PM_Project_RecID > 0)
										), 0)	-- Hours from the Pro Svcs tickets and the Projects module
		, Num_vCIO_Hours = COALESCE((SELECT SUM(T.hours_actual) as Total_Hours_Worked
											from v_rpt_Time T WITH (NOLOCK) 
											INNER JOIN v_rpt_Service S WITH (NOLOCK)
												ON T.sr_service_recid = S.SR_Service_RecID
											where T.Date_Start between @StartDt AND @EndDt
												AND S.company_name = MRR.company_name
												AND (S.Board_Name LIKE '02%')
										), 0)
		, Num_Scheduled_NA_Visits = COALESCE((SELECT count(distinct S.sr_service_recid) as Num_Scheduled_NA_Visits
											from v_rpt_Service S WITH (NOLOCK)
											where S.Date_Required between @StartDt AND @EndDt
												AND S.company_name = MRR.company_name
												AND S.Board_Name LIKE '04%'
												AND S.Summary like '%NA Scheduled Proactive%'
												AND S.resource_list <> ''
										), 0)
		, Num_Completed_NA_Visits = COALESCE((SELECT count(distinct S.sr_service_recid) as Num_Completed_NA_Visits
											from v_rpt_Service S WITH (NOLOCK)
											where S.Date_Required between @StartDt AND @EndDt
												AND S.company_name = MRR.company_name
												AND S.Board_Name LIKE '04%'
												AND S.Summary like '%NA Scheduled Proactive%'
												AND DatePart(yy, S.Date_Closed) = DatePart(yy, S.Date_Required)
												AND DatePart(mm, S.Date_Closed) = DatePart(mm, S.Date_Required)	-- Ticket was closed the same month that it was Due
										), 0)
	FROM MSP_Dashboard.dbo.CompanyStatsByMonth MRR
	WHERE MRR.StatsYear = year(@StartDt)
	AND MRR.StatsMonth = month(@StartDt)
		

---------------------------------------------------
-- Update Calculated fields

UPDATE MSP_Dashboard.dbo.CompanyStatsByMonth
	SET AISP_Amount = CASE WHEN Num_Seats > 0 THEN (MRR_Amount / Num_Seats) ELSE 0 END
	WHERE StatsYear = year(@StartDt)
	AND StatsMonth = month(@StartDt)


UPDATE MSP_Dashboard.dbo.CompanyStatsByMonth SET Client_Priority_List_Num = 1 WHERE Company_Name = 'Grand Dental Group'


GO
DECLARE @Start1 datetime, @End1 datetime, @Start2 datetime, @End2 datetime, @Start3 datetime, @End3 datetime

SET @Start1 = '03/01/2017'
SET @End1 = '03/31/2017' 
SET @Start2 = '04/01/2017'
SET @End2 = '04/30/2017' 
SET @Start3 = '05/01/2017'
SET @End3 = '05/31/2017' 

SELECT DISTINCT Company_Name
		, (SELECT count(distinct S.sr_service_recid) as Num_Tickets_Opened
				from v_rpt_Service S WITH (NOLOCK)
				where S.date_entered between @Start1 AND @End1
					AND S.company_name = v_rpt_Service.company_name
					AND S.Board_Name LIKE '01%'	-- Reactive
				) as Num_Tickets_Opened1
		, (SELECT SUM(T.hours_actual) as Total_Hours_Worked
				from v_rpt_Time T WITH (NOLOCK) 
				INNER JOIN v_rpt_Service S WITH (NOLOCK)
					ON T.sr_service_recid = S.SR_Service_RecID
				where T.Date_Start between @Start1 AND @End1
					AND S.company_name = v_rpt_Service.company_name
					AND S.Board_Name LIKE '01%'	-- Reactive
				) as Hours_Worked1

		, (SELECT count(distinct S.sr_service_recid) as Num_Tickets_Opened
				from v_rpt_Service S WITH (NOLOCK)
				where S.date_entered between @Start2 AND @End2
					AND S.company_name = v_rpt_Service.company_name
					AND S.Board_Name LIKE '01%'	-- Reactive
				) as Num_Tickets_Opened2
		, (SELECT SUM(T.hours_actual) as Total_Hours_Worked
				from v_rpt_Time T WITH (NOLOCK) 
				INNER JOIN v_rpt_Service S WITH (NOLOCK)
					ON T.sr_service_recid = S.SR_Service_RecID
				where T.Date_Start between @Start2 AND @End2
					AND S.company_name = v_rpt_Service.company_name
					AND S.Board_Name LIKE '01%'	-- Reactive
				) as Hours_Worked2

		, (SELECT count(distinct S.sr_service_recid) as Num_Tickets_Opened
				from v_rpt_Service S WITH (NOLOCK)
				where S.date_entered between @Start3 AND @End3
					AND S.company_name = v_rpt_Service.company_name
					AND S.Board_Name LIKE '01%'	-- Reactive
				) as Num_Tickets_Opened3
		, (SELECT SUM(T.hours_actual) as Total_Hours_Worked
				from v_rpt_Time T WITH (NOLOCK) 
				INNER JOIN v_rpt_Service S WITH (NOLOCK)
					ON T.sr_service_recid = S.SR_Service_RecID
				where T.Date_Start between @Start3 AND @End3
					AND S.company_name = v_rpt_Service.company_name
					AND S.Board_Name LIKE '01%'	-- Reactive
				) as Hours_Worked3

	FROM v_rpt_Service WITH (NOLOCK)
	WHERE date_entered between @Start1 AND @End3
		AND Board_Name LIKE '01%'	-- Reactive
	ORDER BY 1


--select *
--	from v_rpt_Service
--	where company_name = 'Job Applicants'
--	and date_entered >= '03/01/2016'
--	order by date_entered

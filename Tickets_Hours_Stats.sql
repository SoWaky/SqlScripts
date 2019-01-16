DECLARE @Board varchar(10)
SET @Board = '01'

-- Reactive currently open
SELECT S.Company_Name, COUNT(*) AS Open_Tickets
	FROM v_rpt_Service S WITH (NOLOCK)
	where 1=1
		AND S.Board_Name LIKE @Board + '%'
		AND S.date_closed is null
	GROUP BY S.Company_Name
	ORDER BY 2 DESC,1

-- Reactive in the last week
SELECT S.Company_Name, COUNT(*) AS Last_Week_Tickets
	FROM v_rpt_Service S WITH (NOLOCK)
	where 1=1
		AND S.Board_Name LIKE @Board + '%'
		AND S.date_entered >= DATEADD(dd, -7, cast(GETDATE() as date))
	GROUP BY S.Company_Name
	ORDER BY 2 DESC,1

-- Reactive in the last Month
SELECT S.Company_Name, COUNT(*) AS Last_Month_Tickets
	FROM v_rpt_Service S WITH (NOLOCK)
	where 1=1
		AND S.Board_Name LIKE @Board + '%'
		AND S.date_entered >= DATEADD(mm, -1, cast(GETDATE() as date))
	GROUP BY S.Company_Name
	ORDER BY 2 DESC,1

-- Reactive in the last 6 months
SELECT S.Company_Name, COUNT(*) AS _6Months_Tickets
	FROM v_rpt_Service S WITH (NOLOCK)
	where 1=1
		AND S.Board_Name LIKE @Board + '%'
		AND S.date_entered >= DATEADD(mm, -6, cast(GETDATE() as date))
	GROUP BY S.Company_Name
	ORDER BY 2 DESC,1

-----------------------------------------------------------------------------------

-- Reactive Hours Worked in the last week
select t.company_name, SUM(t.hours_actual) as Hours_Worked_Week
	FROM v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where 1=1
		AND S.Board_Name LIKE @Board + '%'
		AND t.Date_Start >= DATEADD(dd, -7, cast(GETDATE() as date))
	GROUP BY T.Company_Name
	ORDER BY 2 DESC,1

-- Reactive Hours Worked in the last month
select t.company_name, SUM(t.hours_actual) as Hours_Worked_1Month
	FROM v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where 1=1
		AND S.Board_Name LIKE @Board + '%'
		AND t.Date_Start >= DATEADD(mm, -1, cast(GETDATE() as date))
	GROUP BY T.Company_Name
	ORDER BY 2 DESC,1


-- Reactive Hours Worked in the last 6 months
select t.company_name, SUM(t.hours_actual) as Hours_Worked_6Months
	FROM v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where 1=1
		AND S.Board_Name LIKE @Board + '%'
		AND t.Date_Start >= DATEADD(mm, -6, cast(GETDATE() as date))
	GROUP BY T.Company_Name
	ORDER BY 2 DESC,1


-- Reactive in the last Month
SELECT S.Company_Name, COUNT(*) AS Num_Tickets
	FROM v_rpt_Service S WITH (NOLOCK)
	where 1=1
		AND S.Board_Name LIKE @Board + '%'
		AND S.date_entered >= DATEADD(mm, -1, cast(GETDATE() as date))
	GROUP BY S.Company_Name
	ORDER BY 2 DESC,1

--------------------------------------------------------------


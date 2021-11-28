--select * from Member order by First_Name
-- select top 100 date_entered, date_closed, DATEDIFF(dd, date_entered, ISNULL(date_closed, getdate())) + 1, * from v_rpt_Service WITH (NOLOCK) order by TicketNbr desc
--select top 10 * from v_rpt_Time WITH (NOLOCK)

-----------------------------------------------------------------------------

DECLARE @StartDt datetime, @EndDt datetime

-- CW time sheets are from Saturday thru Friday
SET @StartDt = '09/24/2017'
SET @EndDt = '10/024/2017'

-----------------------------------------------------------------------------
-- Reactive Dashboard by Member

IF OBJECT_ID('tempdb..#Members') IS NOT NULL
DROP TABLE #Members

SELECT Member_Id, First_Name, Last_Name
	INTO #Members
	FROM Member
	WHERE Member_Id IN ('ezuidema', 'jedwards','CSullivan','NPieczynski', 'oortega', 'bboliger', 'mprice', 'mscannell', 'ralfini')	-- 

SELECT Member_Name
	, Num_Tickets_Opened--, All_Tickets_Opened
	, CASE WHEN Num_Tickets_Opened <> 0 THEN cast(Num_Tickets_Opened as money) / cast(All_Tickets_Opened as money) ELSE 0 END AS Tickets_Opened_Pct
	, Num_Tickets_Closed--, All_Tickets_Closed
	, CASE WHEN Num_Tickets_Closed <> 0 THEN cast(Num_Tickets_Closed as money) / cast(All_Tickets_Closed as money) ELSE 0 END AS Tickets_Closed_Pct
	, Member_Hours_Worked--, All_Hours_Worked
	, CASE WHEN Member_Hours_Worked <> 0 THEN cast(Member_Hours_Worked as money) / cast(All_Hours_Worked as money) ELSE 0 END AS Hours_Worked_Pct
	
	, Num_Tickets_Worked, Num_Tickets_Over_2_days, Num_Time_Entries_Over_1Hour, Num_Time_Entries_Under_10_Min
	FROM 
(
SELECT M.First_Name + ' ' + M.Last_Name as Member_Name

, (SELECT count(distinct S.sr_service_recid) as Num_Tickets_Opened
	from v_rpt_Service S WITH (NOLOCK)
	inner join Member WITH (NOLOCK)
		ON Member.Member_RecID = S.Ticket_Owner_RecID
	where S.date_entered between @StartDt AND @EndDt
		AND Member.Member_Id = M.Member_Id
		AND S.Board_Name LIKE '01%'	-- Reactive
	) as Num_Tickets_Opened

, (SELECT count(distinct S.sr_service_recid) as Num_Tickets_Closed
	from v_rpt_Service S WITH (NOLOCK)
	inner join Member WITH (NOLOCK)
		ON Member.Member_RecID = S.Ticket_Owner_RecID
	where S.date_closed between @StartDt AND @EndDt
		AND Member.Member_Id = M.Member_Id
		AND S.Board_Name LIKE '01%'	-- Reactive
	) as Num_Tickets_Closed

, (SELECT count(distinct T.sr_service_recid) as Num_Tickets_Worked
	from v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where T.Date_Start between @StartDt AND @EndDt
		AND t.member_id = M.Member_Id
		AND S.Board_Name LIKE '01%'	-- Reactive
	) as Num_Tickets_Worked

, (SELECT count(*) as Num_Time_Entries_Over_1Hour
	from v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where T.Date_Start between @StartDt AND @EndDt
		AND T.member_id = M.Member_Id
		AND S.Board_Name LIKE '01%'	-- Reactive
		AND T.hours_actual > 1
	) as Num_Time_Entries_Over_1Hour

, (SELECT count(*) as Num_Time_Entries_Under_10_Min
	from v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where T.Date_Start between @StartDt AND @EndDt
		AND T.member_id = M.Member_Id
		AND S.Board_Name LIKE '01%'	-- Reactive
		AND T.hours_actual < 0.166		-- 10 minutes
	) as Num_Time_Entries_Under_10_Min

, (SELECT count(distinct S.sr_service_recid) as Num_Tickets_Over_2_days
	from v_rpt_Service S WITH (NOLOCK)
	inner join Member WITH (NOLOCK)
		ON Member.Member_RecID = S.Ticket_Owner_RecID
	where Member.Member_Id = M.Member_Id
		AND S.Board_Name LIKE '01%'	-- Reactive
		AND S.date_entered < @EndDt AND ISNULL(S.date_closed, '12/31/9999') > @StartDt	-- Ticket was open during time period
		AND (DATEDIFF(dd, S.date_entered, ISNULL(S.date_closed, @EndDt)) + 1) > 2		-- Opened for 2 or more days
	) as Num_Tickets_Over_2_days

, (SELECT SUM(T.hours_actual) as Total_Hours_Worked
	from v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where T.Date_Start between @StartDt AND @EndDt
	AND T.member_id = M.Member_Id
	AND S.Board_Name LIKE '01%'	-- Reactive
	) as Member_Hours_Worked

, (SELECT SUM(T.hours_actual) as Total_Team_Hours
	from v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where T.Date_Start between @StartDt AND @EndDt
	AND S.Board_Name LIKE '01%'	-- Reactive
	) as All_Hours_Worked

, (SELECT count(distinct S.sr_service_recid) as Num_Tickets_Opened
	from v_rpt_Service S WITH (NOLOCK)
	where S.date_entered between @StartDt AND @EndDt
		AND S.Board_Name LIKE '01%'	-- Reactive
	) as All_Tickets_Opened

, (SELECT count(distinct S.sr_service_recid) as Num_Tickets_Closed
	from v_rpt_Service S WITH (NOLOCK)
	where S.date_closed between @StartDt AND @EndDt
		AND S.Board_Name LIKE '01%'	-- Reactive
	) as All_Tickets_Closed

	FROM #Members M
) x
ORDER BY 2 desc

-----------------------------------------------------------------------------
-- Reactive Dashboard by Board

SELECT Board_Name
	, Num_Tickets_Opened--, All_Tickets_Opened
	, CASE WHEN Num_Tickets_Opened <> 0 THEN cast(Num_Tickets_Opened as money) / cast(All_Tickets_Opened as money) ELSE 0 END AS Tickets_Opened_Pct
	, Num_Tickets_Closed--, All_Tickets_Closed
	, CASE WHEN Num_Tickets_Closed <> 0 THEN cast(Num_Tickets_Closed as money) / cast(All_Tickets_Closed as money) ELSE 0 END AS Tickets_Closed_Pct
	, Member_Hours_Worked--, All_Hours_Worked
	, CASE WHEN Member_Hours_Worked <> 0 THEN cast(Member_Hours_Worked as money) / cast(All_Hours_Worked as money) ELSE 0 END AS Hours_Worked_Pct
	
	, Num_Tickets_Worked, Num_Tickets_Over_2_days, Num_Time_Entries_Over_1Hour, Num_Time_Entries_Under_10_Min
	FROM 
(
SELECT Board.Board_Name

, (SELECT count(distinct S.sr_service_recid) as Num_Tickets_Opened
	from v_rpt_Service S WITH (NOLOCK)
	where S.date_entered between @StartDt AND @EndDt
		AND S.Board_Name  = Board.Board_Name
	) as Num_Tickets_Opened

, (SELECT count(distinct S.sr_service_recid) as Num_Tickets_Closed
	from v_rpt_Service S WITH (NOLOCK)
	where S.date_closed between @StartDt AND @EndDt
		AND S.Board_Name  = Board.Board_Name
	) as Num_Tickets_Closed

, (SELECT count(distinct T.sr_service_recid) as Num_Tickets_Worked
	from v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where T.Date_Start between @StartDt AND @EndDt
		AND S.Board_Name  = Board.Board_Name
	) as Num_Tickets_Worked

, (SELECT count(*) as Num_Time_Entries_Over_1Hour
	from v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where T.Date_Start between @StartDt AND @EndDt
		AND S.Board_Name  = Board.Board_Name
		AND T.hours_actual > 1
	) as Num_Time_Entries_Over_1Hour

, (SELECT count(*) as Num_Time_Entries_Under_10_Min
	from v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where T.Date_Start between @StartDt AND @EndDt
		AND S.Board_Name  = Board.Board_Name
		AND T.hours_actual < 0.166		-- 10 minutes
	) as Num_Time_Entries_Under_10_Min

, (SELECT count(distinct S.sr_service_recid) as Num_Tickets_Over_2_days
	from v_rpt_Service S WITH (NOLOCK)
	where S.Board_Name  = Board.Board_Name
		AND S.date_entered < @EndDt AND ISNULL(S.date_closed, '12/31/9999') > @StartDt	-- Ticket was open during time period
		AND (DATEDIFF(dd, S.date_entered, ISNULL(S.date_closed, @EndDt)) + 1) > 2		-- Opened for 2 or more days
	) as Num_Tickets_Over_2_days

, (SELECT SUM(T.hours_actual) as Member_Hours_Worked
	from v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where T.Date_Start between @StartDt AND @EndDt
	AND S.Board_Name  = Board.Board_Name
	) as Member_Hours_Worked

, (SELECT SUM(T.hours_actual) as All_Hours_Worked
	from v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where T.Date_Start between @StartDt AND @EndDt
		AND S.Board_Name LIKE '01%'	-- Reactive
	) as All_Hours_Worked

, (SELECT count(distinct S.sr_service_recid) as All_Tickets_Opened
	from v_rpt_Service S WITH (NOLOCK)
	where S.date_entered between @StartDt AND @EndDt
		AND S.Board_Name LIKE '01%'	-- Reactive
	) as All_Tickets_Opened

, (SELECT count(distinct S.sr_service_recid) as All_Tickets_Closed
	from v_rpt_Service S WITH (NOLOCK)
	where S.date_closed between @StartDt AND @EndDt
		AND S.Board_Name LIKE '01%'	-- Reactive
	) as All_Tickets_Closed

	FROM sr_board Board WITH (NOLOCK)
		WHERE Board.Board_Name LIKE '01%'	-- Reactive
) x
ORDER BY 1


-------------------------------------------------------------------------------------------------------------------------------------------
---- All Time Entries posted on Reactive Tickets
--select T.Member_Id, Board_Name, T.company_name, CONVERT(char(10), T.Date_Start, 111) as Date_Worked, T.hours_actual as Num_Hours
--		, T.sr_service_recid, T.sr_summary, replace(replace(t.Notes, char(10), ' '), char(13), ' ') as Notes
--		--, *
--	from v_rpt_Time T WITH (NOLOCK) 
--	INNER JOIN v_rpt_Service S WITH (NOLOCK)
--		ON T.sr_service_recid = S.SR_Service_RecID
--	INNER JOIN #Members M 
--		ON M.Member_ID = T.member_id
--	where Date_Start between @StartDt AND @EndDt
--		AND S.Board_Name LIKE '01%'	-- Reactive
--		--AND Notes like '%Called%'
--	order by 1,2,3


-------------------------------------------------------------------------------------------------------------------------------------------
---- Reactive Time entries over 1 hours
--SELECT T.Member_Id, Board_Name, T.company_name, CONVERT(char(10), T.Date_Start, 111) as Date_Worked, T.hours_actual as Num_Hours
--		, T.sr_service_recid, T.sr_summary, replace(replace(t.Notes, char(10), ' '), char(13), ' ') as Notes
--	from v_rpt_Time T WITH (NOLOCK) 
--	INNER JOIN v_rpt_Service S WITH (NOLOCK)
--		ON T.sr_service_recid = S.SR_Service_RecID
--	INNER JOIN #Members M 
--		ON M.Member_ID = T.member_id
--	where Date_Start between @StartDt AND @EndDt
--		AND S.Board_Name LIKE '01%'	-- Reactive
--		AND T.hours_actual > 1
--	Order by 1,2,3

-------------------------------------------------------------------------------------------------------------------------------------------
---- Time entries less than 10 minutes
--SELECT T.Member_Id, Board_Name, T.company_name, CONVERT(char(10), T.Date_Start, 111) as Date_Worked, T.hours_actual as Num_Hours
--		, T.sr_service_recid, T.sr_summary, replace(replace(t.Notes, char(10), ' '), char(13), ' ') as Notes
--	from v_rpt_Time T WITH (NOLOCK) 
--	INNER JOIN v_rpt_Service S WITH (NOLOCK)
--		ON T.sr_service_recid = S.SR_Service_RecID
--			INNER JOIN #Members M 
--				ON M.Member_ID = T.member_id
--	where Date_Start between @StartDt AND @EndDt
--	AND T.hours_actual < 0.166



-------------------------------------------------------------------------------------------------------------------------------------------
---- Reactive Tickets with Hours posted on multiple days
--SELECT T.Member_Id, T.sr_service_recid
--		, CONVERT(char(10), MIN(T.Date_Start), 111) as First_Date, CONVERT(char(10), MAX(T.Date_Start), 111) as Last_Date
--		, COUNT(DISTINCT T.Date_Start) as Num_Days
--		, DATEDIFF(dd, MIN(T.Date_Start), MAX(T.Date_Start)) as Days_Spanned
--		, SUM(T.Hours_Actual) AS Total_Hours
--	FROM v_rpt_Time T WITH (NOLOCK) 
--	WHERE T.sr_service_recid IN 
--		(
--		SELECT T.sr_service_recid
--			from v_rpt_Time T WITH (NOLOCK) 
--			INNER JOIN v_rpt_Service S WITH (NOLOCK)
--				ON T.sr_service_recid = S.SR_Service_RecID
--			INNER JOIN #Members M 
--				ON M.Member_ID = T.member_id
--			where Date_Start between @StartDt AND @EndDt
--				AND S.Board_Name LIKE '01%'	-- Reactive
--		)
--	GROUP BY T.Member_Id, T.sr_service_recid
--	HAVING DATEDIFF(dd, MIN(T.Date_Start), MAX(T.Date_Start)) > 0
--	ORDER BY 1,2


---- Reactive Tickets opened for more than 2 Days
--select M.Member_Id AS Ticket_Owner, S.Board_Name, S.Age, S.Status_Description, S.TicketNbr
--		, S.ServiceType, S.ServiceSubType, S.ServiceSubTypeItem, S.Company_Name, S.Hours_Actual, S.Last_Update, S.Updated_By
--		, replace(replace(S.Summary, char(10), ' '), char(13), ' ') as Summary
--	from v_rpt_service S
--	INNER JOIN sr_service O WITH (NOLOCK)
--		ON O.sr_service_recid = S.sr_service_recid
--	INNER JOIN Member M 
--		ON M.Member_RecID = O.ticket_Owner_RecId
--	where S.Date_Closed IS NULL
--		AND S.Board_Name LIKE '01%'	-- Reactive
--		AND S.Age > 2
--	ORDER BY 1,2,cast(S.Age AS money) DESC



-------------------------------------------------------------------------------------

---- Tickets closed yesterday by Member
	
--SELECT CAST(s.date_closed AS DATE), m.Member_ID, COUNT(*) as Num_Tickets
--	FROM v_rpt_service s WITH (NOLOCK)
--	INNER JOIN Member m WITH (NOLOCK)
--		ON s.Ticket_Owner_RecID = m.Member_RecID
--	WHERE CAST(s.date_closed AS DATE) >= '03/01/2017'	
--		and Board_Name LIKE '01%'
--	GROUP BY CAST(s.date_closed AS DATE), m.Member_ID
--	HAVING COUNT(*) >= 10
--	ORDER BY 1, 3 DESC

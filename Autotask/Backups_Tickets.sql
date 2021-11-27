----select top 10 * from SR_Service where SR_Service_RecID = 75025
----select top 10 * from SR_Detail where SR_Service_RecID = 75025

----------------------------------------------------------------------------------------------------------------
-- BDR Tickets
DECLARE @StartDt datetime, @EndDt datetime, @StartWk int, @EndWk int, @Counter int

SET @StartDt = '04/01/2017'
SET @EndDt = '07/31/2017'
SET @StartWk = DATEPART(ww, @StartDt)
SET @EndWk = DATEPART(ww, @EndDt)
SET @Counter = @StartWk

IF OBJECT_ID('tempdb..#Weeks') IS NOT NULL 
	drop table #Weeks
create table #Weeks (WeekNum int)

while @Counter <= @EndWk
begin
	INSERT INTO #Weeks VALUES (@Counter)
	SET @Counter = @Counter + 1
end

SELECT w.WeekNum, count(distinct convert(char(10), v_rpt_Service.Date_Entered, 111) + Company_Name) AS Num_Failures
	FROM #Weeks w
	LEFT JOIN v_rpt_Service WITH (NOLOCK) 
		on w.WeekNum = DATEPART(ww, v_rpt_Service.Date_Entered)
		AND left(v_rpt_Service.summary, 21) = 'BDR-Backup Job Failed'
		AND v_rpt_Service.Resolved_By <> 'CWLabTech'
		AND v_rpt_Service.Date_Entered BETWEEN @StartDt AND @EndDt
	GROUP BY w.WeekNum
	ORDER BY 1
	
SELECT DISTINCT DATEPART(ww, v_rpt_Service.Date_Entered) as WeekNum, convert(char(10), v_rpt_Service.Date_Entered, 111), Company_Name
	FROM v_rpt_Service WITH(NOLOCK) 
	INNER JOIN #Weeks w
		on w.WeekNum = DATEPART(ww, v_rpt_Service.Date_Entered)
	WHERE LEFT(v_rpt_Service.summary, 21) = 'BDR-Backup Job Failed'
		AND v_rpt_Service.Resolved_By <> 'CWLabTech'
		AND v_rpt_Service.Date_Entered BETWEEN @StartDt AND @EndDt
	ORDER BY 1,2,3

SELECT DATEPART(ww, v_rpt_Service.Date_Entered) as WeekNum,
		v_rpt_Service.TicketNbr AS 'Ticket #'
		, RTRIM(v_rpt_Service.Summary) AS 'Summary'
		, RTRIM(v_rpt_Service.status_description) AS 'Status'
		, v_rpt_Service.Age AS 'Age'
		, convert(char(10), v_rpt_Service.Date_Entered_UTC, 111) AS 'Date Entered'
		, v_rpt_Service.Hours_Actual AS 'Hours Worked'
		, v_rpt_Service.Urgency AS 'Urgency'
		, v_rpt_Service.Resolved_By
		, v_rpt_Service.Company_Name
		, (SELECT TOP 1 SR_Detail_Notes FROM SR_Detail WHERE SR_Detail.SR_Service_RecID = v_rpt_Service.SR_Service_RecID order by SR_Detail_RecID DESC) AS Init_Descr
		--, *
	FROM v_rpt_Service WITH(NOLOCK) 
	INNER JOIN #Weeks w
		on w.WeekNum = DATEPART(ww, v_rpt_Service.Date_Entered)
	WHERE LEFT(v_rpt_Service.summary, 21) = 'BDR-Backup Job Failed'
		AND v_rpt_Service.Resolved_By <> 'CWLabTech'
		AND v_rpt_Service.Date_Entered BETWEEN @StartDt AND @EndDt
	ORDER BY 1,2

	

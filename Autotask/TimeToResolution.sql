declare @StartDt datetime, @EndDt datetime, @NumTickets int, @NumHours decimal(10,2)
SET @StartDt = '07/01/2017'
SET @EndDt = '07/31/2017'

SELECT @NumTickets = count(distinct S.sr_service_recid)
	from v_rpt_Service S WITH (NOLOCK)
	where S.date_closed between @StartDt AND @EndDt
		AND (S.Board_Name LIKE '00%' OR S.Board_Name LIKE '01%')
		AND S.Hours_Actual > 0

SELECT @NumHours = SUM(t.hours_actual) 
	FROM v_rpt_Time T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	where 1=1
		AND (S.Board_Name LIKE '00%' OR S.Board_Name LIKE '01%')
		AND t.Date_Start between @StartDt AND @EndDt

Print '# Tickets: ' + cast(@NumTickets as varchar(100))
Print '# Hours: ' + cast(@NumHours as varchar(100))
Print 'Time to Resolution: ' + cast((@NumHours / @NumTickets) as varchar(100))


-----------------------------------------------------------------------------

DECLARE @StartDt datetime, @EndDt datetime

-- CW time sheets are from Saturday thru Friday
SET @StartDt = '09/24/2017'
SET @EndDt = '10/24/2017'


select distinct m.Title, m.First_Name, m.Last_Name
		, coalesce(cast((SELECT SUM(T2.hours_actual) 
					from v_rpt_Time T2 WITH (NOLOCK) 
					INNER JOIN v_rpt_Service S WITH (NOLOCK)
						ON T2.sr_service_recid = S.SR_Service_RecID
					where T2.member_id = T.member_id
						AND T2.Date_Start between @StartDt AND @EndDt
						AND (S.Board_Name LIKE '01%'
							OR S.Board_Name LIKE '00%')
					) as varchar(10)), '') as SupportDesk
		, coalesce(cast((SELECT SUM(T2.hours_actual) 
					from v_rpt_Time T2 WITH (NOLOCK) 
					INNER JOIN v_rpt_Service S WITH (NOLOCK)
						ON T2.sr_service_recid = S.SR_Service_RecID
					where T2.member_id = T.member_id
						AND T2.Date_Start between @StartDt AND @EndDt
						AND S.Board_Name LIKE '04%'
					) as varchar(10)), '') as NetworkAdmin
		, coalesce(cast((SELECT SUM(T2.hours_actual) 
					from v_rpt_Time T2 WITH (NOLOCK) 
					INNER JOIN v_rpt_Service S WITH (NOLOCK)
						ON T2.sr_service_recid = S.SR_Service_RecID
					where T2.member_id = T.member_id
						AND T2.Date_Start between @StartDt AND @EndDt
						AND S.Board_Name LIKE '02%'
					) as varchar(10)), '') as vCIO
		, coalesce(cast((SELECT SUM(T2.hours_actual) 
					from v_rpt_Time T2 WITH (NOLOCK) 
					INNER JOIN v_rpt_Service S WITH (NOLOCK)
						ON T2.sr_service_recid = S.SR_Service_RecID
					where T2.member_id = T.member_id
						AND T2.Date_Start between @StartDt AND @EndDt
						AND (S.Board_Name LIKE '03%' 
							OR S.Board_Name LIKE '08%')
					) as varchar(10)), '') as Projects
		, coalesce(cast((SELECT SUM(T2.hours_actual) 
					from v_rpt_Time T2 WITH (NOLOCK) 
					INNER JOIN v_rpt_Service S WITH (NOLOCK)
						ON T2.sr_service_recid = S.SR_Service_RecID
					where T2.member_id = T.member_id
						AND T2.Date_Start between @StartDt AND @EndDt
						AND (S.Board_Name LIKE '05%' )
					) as varchar(10)), '') as CentralSvcs
		, coalesce(cast((SELECT SUM(T2.hours_actual) 
					from v_rpt_Time T2 WITH (NOLOCK) 
					INNER JOIN v_rpt_Service S WITH (NOLOCK)
						ON T2.sr_service_recid = S.SR_Service_RecID
					where T2.member_id = T.member_id
						AND T2.Date_Start between @StartDt AND @EndDt
						AND (S.Board_Name LIKE '10%' )
					) as varchar(10)), '') as Development
		, coalesce(cast((SELECT SUM(T2.hours_actual) 
					from v_rpt_Time T2 WITH (NOLOCK) 
					INNER JOIN v_rpt_Service S WITH (NOLOCK)
						ON T2.sr_service_recid = S.SR_Service_RecID
					where T2.member_id = T.member_id
						AND T2.Date_Start between @StartDt AND @EndDt
						AND (S.Board_Name NOT LIKE '00%'
							AND S.Board_Name NOT LIKE '01%'
							AND S.Board_Name NOT LIKE '04%'
							AND S.Board_Name NOT LIKE '02%'
							AND S.Board_Name NOT LIKE '03%'
							AND S.Board_Name NOT LIKE '08%'
							AND S.Board_Name NOT LIKE '05%'
							AND S.Board_Name NOT LIKE '10%' )
					) as varchar(10)), '') as Other
	from v_rpt_Time T
	INNER JOIN Member M
		on M.Member_RecID = t.member_recid
	where T.Date_Start between @StartDt AND @EndDt
		and t.member_id not in ('rvalentine', 'erieger', 'rstanger')
	order by 1,2,3
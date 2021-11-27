--Get all Reactive Boards' Tickets
select CASE 
			WHEN S.Board_Name <> '01.3 Support Tier 3'
				and S.Urgency LIKE 'Priority 1%' 
			THEN 'Tier 3'
			WHEN S.Board_Name = '01 Support'
				and (S.Hours_Actual >= 1 
					OR S.Age >= 3) 
			THEN 'Tier 2 or 3'
			ELSE '' 
			END AS New_Tier
		, S.Board_Name, S.TicketNbr, S.Hours_Actual, S.Age, S.Urgency, S.Status_Description, M.Member_Id as Ticket_Owner, S.Company_Name, S.ServiceType, S.ServiceSubType, S.ServiceSubTypeItem, S.Summary
		, S.*
		--, t.*
	FROM Sr_Service T WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	LEFT JOIN Member M WITH (NOLOCK)
		ON M.Member_RecId = T.Ticket_Owner_RecID
	where 1=1
		AND S.Date_Closed is null
		and S.Status_Description LIKE 'Completed%'
		AND S.Board_Name LIKE '01%'
	order by 1 desc, 2, 4 desc, 5 desc

------------------------------------------------------------------------------
-- Reactive Tickets with Same Day Closure


SELECT Date_Entered, Num_Closed_Same_Day, Num_Completed_Same_Day, Num_Opened
		, round(cast(Num_Closed_Same_Day as decimal(20,4)) / cast(Num_Opened as decimal(20,4)), 10, 3) as Same_Day_Pct
	FROM (
SELECT cast(S.Date_Entered as date) as Date_Entered, count(*) as Num_Closed_Same_Day
		, (SELECT COUNT(*) 
				from v_rpt_Service s2
				where cast(S2.date_entered as date) = cast(s.date_entered as date)
					and cast(S2.Last_Update as date) = cast(s.date_entered as date)
					and S2.Board_Name like '01%'
					and S2.Status_Description LIKE 'Completed%'
			) as Num_Completed_Same_Day
		, (SELECT COUNT(*) 
				from v_rpt_Service s2
				where cast(S2.date_entered as date) = cast(s.date_entered as date)
					and S2.Board_Name like '01%'
			) as Num_Opened
	from v_rpt_Service s
	where 1=1
		and S.date_entered > '05/01/2017'
		and S.Board_Name like '01%'
		and cast(S.date_closed as date) = cast(s.date_entered as date)
	group by cast(S.Date_Entered as date)
		) x
	order by 1

select S.Board_Name, S.Status_Description, s.TicketNbr
		, cast(s.date_entered as date) as date_entered, cast(S.date_closed as date) as date_closed
		, case when cast(S.date_closed as date) = cast(s.date_entered as date) then 1 else 0 end as Closed_Same_Day
	from v_rpt_Service s
	where 1=1
		and S.date_entered > '05/01/2017'
		and S.Board_Name like '01%'
		--and cast(S.date_closed as date) = cast(s.date_entered as date)
	order by 4,5

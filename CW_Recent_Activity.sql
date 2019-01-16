--TODO: notes posted from emails are apparently not in the v_Rpt_Time view.  Find out where they are and include them

select S.Board_Name, convert(varchar(100), Note.date_entered_utc, 120) as Updated_On, Note.Member_Id as Updated_By
		, Note.Notes, s.TicketNbr, Note.SR_Summary
		, S.company_name, S.status_description AS Ticket_Status
		, S.ServiceType, S.ServiceSubType, S.ServiceSubTypeItem, M.Member_Id as Ticket_Owner, S.resource_list--, *
	FROM v_rpt_Time Note WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON Note.sr_service_recid = S.SR_Service_RecID
	INNER JOIN Sr_Service T WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	LEFT JOIN Member M WITH (NOLOCK)
		ON M.Member_RecId = T.Ticket_Owner_RecID
	where 1=1
		and Note.Date_Start > dateadd(dd, -1, GETDATE())
		--and S.resource_list like '%MPRICE%'
		--and S.company_name = 'Filmquest Group'
		--and S.Board_Name in ('10 Development')
	--order by 1,2 desc

UNION ALL

select S.Board_Name, convert(varchar(100), Note.Date_Created, 120) as Updated_On, Note.Created_By as Updated_By
		, Note.SR_Detail_Notes AS Notes, s.TicketNbr, S.Summary
		, S.company_name, S.status_description AS Ticket_Status
		, S.ServiceType, S.ServiceSubType, S.ServiceSubTypeItem, M.Member_Id as Ticket_Owner, S.resource_list--, *
	FROM Sr_Detail Note WITH (NOLOCK) 
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON Note.sr_service_recid = S.SR_Service_RecID
	INNER JOIN Sr_Service T WITH (NOLOCK)
		ON T.sr_service_recid = S.SR_Service_RecID
	LEFT JOIN Member M WITH (NOLOCK)
		ON M.Member_RecId = T.Ticket_Owner_RecID
	where 1=1
		and Note.Date_Created > dateadd(dd, -1, GETDATE())
		--and S.resource_list like '%MPRICE%'
		--and S.company_name = 'Filmquest Group'
		--and S.Board_Name in ('10 Development')
	order by 1,2 desc
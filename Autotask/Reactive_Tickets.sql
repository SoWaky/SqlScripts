SELECT ServiceType, ServiceSubType, ServiceSubTypeItem, Summary, Hours_Actual, TicketNbr, date_entered, date_closed, Board_Name, company_name
	from v_rpt_Service S WITH (NOLOCK)
	inner join Member WITH (NOLOCK)
		ON Member.Member_RecID = S.Ticket_Owner_RecID
	where S.date_entered >= '06/01/2017'
		AND S.Board_Name LIKE '01%'	-- Reactive
		--AND S.company_name = 'Grand Dental Group'
	order by 1,2,3,4
--select * from v_rpt_Contact where company_recid = 40810 order by Company_Address_RecID
--select * from Company_Address where company_recid = 40810 order by Company_Address_RecID
--select * from v_rpt_Company where company_id like '10%' order by 2
-- SELECT top 3 'v_ContactList' as Table_Name, * from v_ContactList
-- select top 10 * from v_rpt_Service
-------------
--select * 
--	from dbo.AutotaskCompanies 
--	where company_type_desc like '10%' or company_type_desc like '15%' or company_type_desc like '20%'
--	order by 1,2



--select coalesce(AutotaskCompanies.AT_Company, rtrim(con.Company_Name) + ' - ' + cl.Site_name), '', '', '', '', '', '', '', '', replace(replace(coalesce(Company_Address.PhoneNbr, Default_Phone), '(', ''), ')', '')
--		, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''
--		, isnull(con.First_Name, ''), '', isnull(con.Last_Name, ''), '', isnull(con.Title, ''), isnull(Default_Email, ''), '', ''
--		, isnull(con.Address_Line1, ''), isnull(con.Address_Line2, ''), isnull(con.City, ''), isnull(con.State_ID, ''), isnull(con.Zip, ''), isnull(con.Country, ''), ''
--		, replace(replace(isnull(comm.Contact_Communication_Desc, ''), '(', ''), ')', ''), isnull(comm.Extension, '')
--		, '', '', '', '', '', '', '', '', '', '', ''
--		, case when con.Inactive_Flag = 1 then 'Inactive' else 'Active' end as ActInact
--		, case when con.Default_Flag = 1 then 'True' else 'False' end as PrimaryCon
--		, isnull(Contact_Type_Desc, 'OT - Non Specified Contact')
--		, isnull(case when udf.Business = 'False' then 'No' else 'Yes' end, 'No'), isnull(case when udf.Technical = 'False' then 'No' else 'Yes' end, 'No')
--	from v_rpt_Contact con with (nolock)
--	left join v_rpt_ContactCommunication comm with (nolock)
--		on comm.Contact_RecID = con.Contact_RecID and comm.Communication_Name = 'Direct'
--	left join v_Contact_Custom_Fields udf with (nolock)
--		on udf.Contact_RecID = con.Contact_RecID
--	left join v_ContactList cl with (nolock)
--		on cl.Contact_RecID = con.Contact_RecID
--	left join AutotaskCompanies with (nolock)
--		on AutotaskCompanies.CompanySite = rtrim(con.Company_Name) + ' - ' + cl.Site_name
--	inner join Company 
--		on company.Company_ID = con.Company_ID
--	left join Company_Address
--		on Company_Address.Company_Address_RecID = con.Company_Address_RecID
--	where 1=1
--		--AND left(cl.company_id, 3) in ('10 ', '15 ', '20 ')
--		AND con.Company_Name like 'webit%'
--	order by 1



-------------------------------------------------------------------------

select top 10000 s.TicketNbr, coalesce(att.Ticket_Number, '') as AT_Ticket_Number, s.summary as title, s.Detail_Description as 'Description'
		, coalesce(AutotaskCompanies.AT_Company, rtrim(s.Company_Name) + ' - ' + s.Site_name) as company_name
		, case when (s.company_name not like '%webit%' and ContactMem.Last_Name like '%sullivan%') then '' 
			when (s.company_name like '%webit%' and ContactMem.Last_Name like '%Rieger%') then 'Techs, WEBIT' 
			else coalesce(RTRIM(ContactMem.last_name) + ', ' + ContactMem.first_name, '') end as Contact
		--, '' as contact

		, AtS.AutotaskStatus, s.severity as 'priority', s.Source, '' as EstHours
		
		, coalesce(RTRIM(OwnerMem.last_name) + ', ' + OwnerMem.first_name, '') as PrimaryResource		
		, case when OwnerMem.last_name = 'Price' then 'Developer'
			when OwnerMem.last_name in ('Scannell','Sullivan','Alfini','Valentine') then 'Service Coordinator'
			when OwnerMem.last_name = 'Bolliger' then 'vCIO'
			when OwnerMem.last_name in('Ortega','Pieczynski','Zuidema') then 'Network Engineer'
			when OwnerMem.last_name = 'Sowa' then 'Project Engineer'
			when OwnerMem.last_name = 'Edwards' then 'Sales'
			when OwnerMem.last_name in ('Palm','Rieger') then 'Administration'
			else '' end as 'Role'		
		--, ''  as PrimaryResource
		--, '' as 'Role'

		, case when s.Board_Name = '01 Support' then '01.1 Support Tier 1' else s.Board_Name end as BoardQueue

		, case 
			when s.Board_Name like '00%' then 'Alert'
			when s.ServiceType like '%problem%' or s.ServiceSubType like '%problem%' or s.ServiceSubTypeItem like '%problem%' then 'Problem'
			when s.ServiceType like '%change%' or s.ServiceSubType like '%change%' or s.ServiceSubTypeItem like '%change%' then 'Change Request'
			else 'Service Request'
			end as TicketType

		, case when s.Board_Name like '10 Dev%' then 'Development'
				when s.Board_Name like '00%' then 'AEM Alert'
				when s.Board_Name like '01%' then 'Support'
				else 'Standard' end as Category

		, case when s.Board_Name like '00%' then 'Inquiry/Problem'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and (s.ServiceSubTypeItem like '%Add%' or s.ServiceSubTypeItem like '%Change%' or s.ServiceSubTypeItem like '%delete%' or s.ServiceSubTypeItem like '%remove%')  then 'Add/Change Request'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library')  then 'Inquiry/Problem'
			when s.Board_Name like '02 vCIO'   then 'Administrative'
			when s.Board_Name like '07 Internal Recurring'   then 'Administrative'
			when s.Board_Name like '09 Training'   then 'Administrative'
			when s.Board_Name like '10 Development'   then 'Software'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				and (s.ServiceType like '%network%' or s.ServiceType like '%internet%' or s.ServiceType like '%firewall%') then 'Network'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				and (s.ServiceType like '%software%' or s.ServiceType like '%service%' or s.ServiceType like '%app%' or s.ServiceType like '%customization%' or s.ServiceType like '%automat%') then 'Software'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 then 'Hardware'
			when s.Board_Name like '05 Centralized Services'   then 'Software'
			else '00 Change Me' end as 'IssueType'

		, case when s.Board_Name like '00%'
				and s.summary like '%offline%' then 'Server'
			when s.Board_Name like '00%'
				and (s.summary like '%backup%' or s.summary like '%vault%') then 'Backups'
			when s.Board_Name like '00%' then 'Change Me'
			when s.Board_Name like '02 vCIO'   then 'vCIO Meeting'
			when s.Board_Name like '07 Internal Recurring'   then 'Meeting'
			when s.Board_Name like '09 Training'   then 'Training'
			when s.Board_Name like '10 Development'  
				and s.ServiceSubType like '%customer LOB%' then 'Customer LOB'
			when s.Board_Name like '10 Development'  then 'Custom'
			when s.Board_Name like '05 Centralized Services' 
				and (s.Summary like '%eset%' or s.Summary like '%webroot%' or s.Summary like '%sophos%')  then 'Anti-virus'
			when s.Board_Name like '05 Centralized Services' then 'Custom'

			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and (s.ServiceSubTypeItem like '%Add%' or s.ServiceSubTypeItem like '%Change%' or s.ServiceSubTypeItem like '%delete%' or s.ServiceSubTypeItem like '%remove%')  
				and s.ServiceSubType like '%email%' then 'E-mail'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and (s.ServiceSubTypeItem like '%Add%' or s.ServiceSubTypeItem like '%Change%' or s.ServiceSubTypeItem like '%delete%' or s.ServiceSubTypeItem like '%remove%')  
				and s.ServiceSubType like '%user%' and s.ServiceSubTypeItem like '%remove%' then 'Remove User'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and (s.ServiceSubTypeItem like '%Add%' or s.ServiceSubTypeItem like '%Change%' or s.ServiceSubTypeItem like '%delete%' or s.ServiceSubTypeItem like '%remove%')  
				and s.ServiceSubType like '%user%'  then 'New User'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and (s.ServiceSubTypeItem like '%Add%' or s.ServiceSubTypeItem like '%Change%' or s.ServiceSubTypeItem like '%delete%' or s.ServiceSubTypeItem like '%remove%')  
				and s.ServiceSubType like '%customer LOB%'  then 'Customer LOB'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and (s.ServiceSubTypeItem like '%Add%' or s.ServiceSubTypeItem like '%Change%' or s.ServiceSubTypeItem like '%delete%' or s.ServiceSubTypeItem like '%remove%')  
				then ''
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%laptop%' then 'Laptop'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%Customer LOB%' then 'Customer LOB'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%email%' then 'E-mail'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%remote%' then 'Remote Access'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%printer%' then 'Printer'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%scanner%' then 'Scanner'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%utility%' then 'Software Utility'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%phone%' then 'VOIP'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%security%' then 'User Management'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%user%' then 'User Management'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%Server%' then 'Server'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%workstation%' then 'Workstation'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%web%' then 'Website'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%UPS%' then 'UPS'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%power%' then 'Environmental'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%browser%' then 'Internet'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				and s.ServiceSubType like '%microsoft%' then 'Microsoft'
			when s.Board_Name in ('01 Support', '01.2 Support Tier 2', '01.3 Support Tier 3','100 Batavia Public Library') 
				then ''

			
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				and (s.ServiceType like '%network%' or s.ServiceType like '%internet%' or s.ServiceType like '%firewall%') 
				and s.ServiceSubType like '%remote%' then 'Remote Access'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				and (s.ServiceType like '%network%' or s.ServiceType like '%internet%' or s.ServiceType like '%firewall%') 
				and s.ServiceSubType like '%security%' then 'Firewall'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				and (s.ServiceType like '%network%' or s.ServiceType like '%internet%' or s.ServiceType like '%firewall%') 
				 then ''

			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				and (s.ServiceType like '%software%' or s.ServiceType like '%service%' or s.ServiceType like '%app%' or s.ServiceType like '%customization%' or s.ServiceType like '%automat%') 
				and s.ServiceSubType like '%Customer LOB%' then 'Customer LOB'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				and (s.ServiceType like '%software%' or s.ServiceType like '%service%' or s.ServiceType like '%app%' or s.ServiceType like '%customization%' or s.ServiceType like '%automat%') 
				and s.ServiceSubType like '%Email%' then 'E-mail'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				and (s.ServiceType like '%software%' or s.ServiceType like '%service%' or s.ServiceType like '%app%' or s.ServiceType like '%customization%' or s.ServiceType like '%automat%') 
				and s.ServiceSubType like '%Utility%' then 'Utility'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				and (s.ServiceType like '%software%' or s.ServiceType like '%service%' or s.ServiceType like '%app%' or s.ServiceType like '%customization%' or s.ServiceType like '%automat%') 
				then ''

			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 and s.ServiceSubType like '%bdr%' then 'Server'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 and s.ServiceSubType like '%server%' then 'Server'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 and s.ServiceSubType like '%workstation%' then 'Workstation'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 and s.ServiceSubType like '%laptop%' then 'Laptop'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 and s.ServiceSubType like '%ups%' then 'UPS'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 and s.Summary like '%Phone%' then 'VOIP'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 and s.ServiceSubType like '%continuity%' then 'Server'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 and s.ServiceSubType like '%voip%' then 'VOIP'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 and s.ServiceSubType like '%firewall%' then 'firewall'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 and s.ServiceSubType like '%security%' then 'firewall'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 and s.Summary like '%firewall%' then 'firewall'
			when s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
				 then ''
			else '' end as 'SubIssueType'

		, '' as 'Work Type', '' as 'Configuration Item Name', '' as 'Configuration Item Serial Number', '' as 'Configuration Item Reference Number', '' as 'Configuration Item Reference Name'

		, case when (s.agreement_name like '%MRR%' or s.agreement_name like '%ORR%')
			 and s.agreement_name not like '%Excel%' and s.agreement_name not like '%gateway%'  and s.agreement_name not like '%Illinois%'
			 then rtrim(ltrim(s.agreement_name)) 
			 else '' end as 'Contract Name'
		--, ''  as 'Contract Name'

		, '' as 'Service Level Agreement', case when att.Ticket_Number is null then convert(varchar(20), s.date_entered, 120) else '' end as 'Create Date/Time', '' as 'Created By Resource', '' as 'Created By Contact'
		, case when AtS.AutotaskStatus = 'Complete' then convert(varchar(20), coalesce(s.date_closed, s.Last_Update), 120)
			else coalesce(convert(varchar(20), s.date_closed, 120), '') end  as 'Complete Date/Time'
		, convert(varchar(20), isnull(s.Date_Required, dateadd(dd, 1, s.date_entered)), 120) as '[required] Due Date/Time'

		, coalesce(convert(varchar(20), s.date_responded_utc, 120), '') as 'First Response Date/Time'
		, coalesce(RTRIM(ResMem.last_name) + ', ' + ResMem.first_name, '') as 'First Response Initiating Resource'
		--, '' as 'First Response Date/Time'
		--, '' as 'First Response Initiating Resource'

		, s.Resolution as 'Resolution'
		, '' as 'UDF:29683108 CreatedBy', '' as 'UDF:29683105 Escalation Needed', '' as 'UDF:29683106 Internal Follow-up Reason', '' as 'UDF:29683107 Onsite Visit', s.TicketNbr as 'UDF:29683094 CW_TicketID'

		--, s.*
	from v_rpt_Service s with (nolock)
	left join AutotaskTickets AtT with (nolock) on s.TicketNbr = att.CW_TicketID
	left join AutoTaskStatuses atS with (nolock) on AtS.status_description = s.status_description
	left join AutotaskCompanies with (nolock)
		on AutotaskCompanies.CompanySite like ('%' + rtrim(s.Company_Name) + ' - ' + s.Site_name + '%')
	left join Member OwnerMem with (nolock) on OwnerMem.Member_RecID = s.Ticket_Owner_RecID
	inner join SR_Service with (nolock) on SR_Service.SR_Service_RecID = s.SR_Service_RecID
	left join Contact ContactMem with (nolock) on ContactMem.Contact_RecID = SR_Service.Contact_RecID
	left join Member ResMem with (nolock) on ResMem.Member_ID = s.Responded_By
	where 1=1
		and (s.date_entered >= '01/01/2017')
		and s.Board_Name not like 'X%'
		--and s.TicketNbr in (101708, 101714)
		--and att.Ticket_Number is null
		and s.company_name like '%webit%'
	order by 1 desc


--select Board_Name, ServiceType, ServiceSubType, ServiceSubTypeItem, count(*)  
--	from v_rpt_Service s  
--	where s.Board_Name in ('04 Network Administration', '03 Projects', '06 Internal Projects', '08 Quotes') 
--	group by Board_Name, ServiceType, ServiceSubType, ServiceSubTypeItem 
--	having count(*) > 10
--	order by 1,2,3,4






------------------------------------------------------------------------
---- Time Entries since database backup was sent to Autotask

--select s.TicketNbr, coalesce(att.Ticket_Number, '') as AT_Ticket_Number
--		, convert(varchar(100), Note.date_entered_utc, 120) as CreatedDateTime
--		, coalesce(RTRIM(OwnerMem.last_name) + ', ' + OwnerMem.first_name, '') as CreatedByResource
--		, '' as CreatedByContact	
--		, coalesce(RTRIM(OwnerMem.last_name) + ', ' + OwnerMem.first_name, '') as CreatedByResource
--		, case when OwnerMem.last_name = 'Price' then 'Developer'
--				when OwnerMem.last_name in ('Scannell','Sullivan','Alfini','Valentine') then 'Service Coordinator'
--				when OwnerMem.last_name = 'Bolliger' then 'vCIO'
--				when OwnerMem.last_name in('Ortega','Pieczynski','Zuidema') then 'Network Engineer'
--				when OwnerMem.last_name = 'Sowa' then 'Project Engineer'
--				when OwnerMem.last_name = 'Edwards' then 'Sales'
--				when OwnerMem.last_name in ('Palm','Rieger') then 'Administration'
--				else '' end as 'Role'		
--		, convert(varchar(11), Note.Date_Start, 120) + coalesce(substring(convert(varchar(100), Note.Time_Start, 120), 12, 8), '') as StartDateTime
--		, convert(varchar(11), Note.Date_Start, 120) + coalesce(substring(convert(varchar(100), Note.Time_End, 120), 12, 8), '') as EndDateTime
--		, '' as BillingOffset
--		, '' as Title, coalesce(Note.Notes, '') as SummaryNote, coalesce(Note.internal_note, '') as InternalNote
--		, '' as NoteType
--		, case when (Note.Agreement like '%MRR%' or Note.Agreement like '%ORR%')
--			 and Note.Agreement not like '%Excel%' and Note.Agreement not like '%gateway%'  and Note.Agreement not like '%Illinois%'
--			 then rtrim(ltrim(Note.Agreement)) 
--			 else '' end as 'ContractName'
--		, 'Remote Support' as WorkType
--		, case when Note.Option_Id = 'NB' then 'True' else '' end as NonBillable
--		, '' as PostedDate
--		--, note.*
--	FROM v_rpt_Time Note WITH (NOLOCK) 
--	INNER JOIN v_rpt_Service S WITH (NOLOCK)
--		ON Note.sr_service_recid = S.SR_Service_RecID
--	left join AutotaskTickets AtT WITH (NOLOCK) on s.TicketNbr = att.CW_TicketID
--	left join Member OwnerMem WITH (NOLOCK) on OwnerMem.Member_RecID = Note.member_recid
--	where 1=1
--		and Note.date_entered_utc >= '08/31/2017'
--		and att.Ticket_Number is not null
--		and coalesce(Note.internal_note, '') = ''
--	order by 1,2,3

------------------------------------------------------------------------
---- Notes posted since database backup was sent to Autotask

--select s.TicketNbr, coalesce(att.Ticket_Number, '') as AT_Ticket_Number
--		, convert(varchar(100), Note.Date_Created, 120) as CreatedDateTime
--		, coalesce(RTRIM(M.last_name) + ', ' + M.first_name, '') as CreatedByResource
--		, case when M.Last_Name IS NULL then coalesce(RTRIM(C.last_name) + ', ' + C.first_name, '') else '' end as CreatedByContact	
--		, '' as CreatedByResource
--		, ''  as 'Role'		
--		, ''  as  StartDateTime
--		, '' as EndDateTime
--		, '' as BillingOffset
--		, case when Note.InternalAnalysis_Flag = 0 then coalesce(cast(Note.SR_Detail_Notes as char(46)), '') else '' end as Title
--		, case when Note.InternalAnalysis_Flag = 0 then coalesce(Note.SR_Detail_Notes, '') else '' end as SummaryNote
--		, case when Note.InternalAnalysis_Flag = 1 then coalesce(Note.SR_Detail_Notes, '') else '' end as InternalNote
--		, 'Task Notes' as NoteType
--		, '' as 'ContractName'
--		, '' as WorkType
--		, '' as NonBillable
--		, '' as PostedDate
--		--, note.*
--	FROM Sr_Detail Note WITH (NOLOCK) 
--	INNER JOIN v_rpt_Service S WITH (NOLOCK)
--		ON Note.sr_service_recid = S.SR_Service_RecID
--	INNER JOIN Sr_Service T WITH (NOLOCK)
--		ON T.sr_service_recid = S.SR_Service_RecID
--	left join AutotaskTickets AtT on s.TicketNbr = att.CW_TicketID
--	LEFT JOIN Member M WITH (NOLOCK)
--		ON M.Member_RecId = Note.Member_RecID
--	Left Join Contact c with (NOLOCK)
--		on C.Contact_RecID = Note.Contact_RecID
--	where 1=1
--		and Note.Date_Created >= '08/31/2017'
--		and att.Ticket_Number is not null
--		and Note.InternalAnalysis_Flag = 1
--		and rtrim(Note.SR_Detail_Notes) <> ''
--	order by 1,2 desc

select ServiceSubType, company_name, Summary, Hours_Actual, Age, Board_Name, ServiceType, ServiceSubTypeItem, Date_Entered, status_description, resource_list
	from v_rpt_Service WITH (NOLOCK)
	where 1=1
	and ServiceSubType IN ('H - Server', 'H - Laptop', 'H - Workstation')
	and ServiceSubTypeItem like '01%'
	and Date_Entered > '10/01/2016'
	order by 1,2,3,4,5
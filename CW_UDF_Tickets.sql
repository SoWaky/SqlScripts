--SELECT top 300 * from User_Defined_Field
--SELECT top 300 * from SR_Service_User_Defined_Field_Value

select S.date_entered, S.TicketNbr, S.Board_Name, S.Status_Description, S.Date_Closed, Hours_Actual, S.Detail_Description
	from SR_Service_User_Defined_Field_Value UDF WITH (NOLOCK)
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON UDF.sr_service_recid = S.SR_Service_RecID
	WHERE UDF.User_defined_Field_RecId = 6		-- C.S. Issue
		AND UDF.User_Defined_Field_Value = 'true'
	ORDER BY 1

select S.date_entered, S.TicketNbr, S.Board_Name, S.Status_Description, S.Date_Closed, Hours_Actual, S.Detail_Description
	from SR_Service_User_Defined_Field_Value UDF WITH (NOLOCK)
	INNER JOIN v_rpt_Service S WITH (NOLOCK)
		ON UDF.sr_service_recid = S.SR_Service_RecID
	WHERE UDF.User_defined_Field_RecId = 7		-- ProSvc Issue
		AND UDF.User_Defined_Field_Value = 'true'
	ORDER BY 1


select Company_Name, date_entered, Summary, Detail_Description, * 
	from v_rpt_Service
	where date_entered > '05/15/2017'
	and (Summary like '%eset%'
		or Summary like '%sophos%'
		or Summary like '%crash%'
		)
	order by 2
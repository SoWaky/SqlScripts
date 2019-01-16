-- CW - Ticket Stats
SELECT
		s.TicketNbr AS 'id',
		s.TicketNbr as 'Ticket_Number',
		s.company_name AS 'Company_Name',
		co.company_id as 'Company_ID',
		s.contact_name AS 'Contact',
		s.source AS 'Source',
		s.team_name,
		s.Territory,
		s.location AS 'Location',
		s.board_name AS 'Board',
		s.summary AS 'Summary',
		s.status_description AS 'Status',
		DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), CAST(s.date_entered AS DATETIME)) AS 'date_opened',
		DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), CAST(s.last_update AS DATETIME))  AS 'date_last_updated',
		DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), CAST(s.Date_Required AS DATETIME))  AS 'Date_Required',
		COALESCE (slaw.Responded_Minutes + slaw.Responded_skipped_minutes, 0) AS 'Time_to_Acknowledgement(Minutes)',
		CAST(s.date_responded_utc AS DATETIME) AS 'acknowledgement_date',
		CASE WHEN slaw.Date_Responded_UTC IS NOT NULL THEN (CASE WHEN slaw.Responded_Minutes + slaw.Responded_skipped_minutes <= 
				(CASE WHEN slap.Responded_Hours IS NOT NULL THEN slap.Responded_Hours ELSE sla.Responded_Hours END
				 * 60) THEN 'Met' ELSE 'Unmet' END) ELSE NULL END AS 'MetResponseSLA',
		CAST(CAST (slaw.Resplan_Minutes + slaw.Resplan_Skipped_Minutes + slaw.Responded_Minutes AS DECIMAL (9, 2)) / 60.0 AS DECIMAL(10,2)) AS 'Time_to_Resolution_Plan(Hours)',
		CAST(s.date_resplan_utc AS DATETIME) AS 'resolution_plan_date',
		CASE WHEN slaw.Date_Resplan_UTC IS NOT NULL THEN (CASE WHEN slaw.Resplan_Minutes + slaw.Resplan_Skipped_Minutes + slaw.Responded_Minutes <= 
			(CASE WHEN slap.Resplan_Hours IS NOT NULL THEN slap.Resplan_Hours ELSE sla.Resplan_Hours END
				* 60) THEN 'Met' ELSE 'Unmet' END) ELSE NULL END AS 'MetResPlanSLA',
		CAST(CAST (slaw.Resolved_Minutes + slaw.resplan_minutes + slaw.responded_minutes AS DECIMAL (9, 2)) / 60.0 AS DECIMAL(10,2)) AS 'Time_to_Resolution(Hours)',
		CAST(s.date_resolved_utc AS DATETIME) AS 'resolution_date',
		CASE WHEN slaw.Date_Resolved_UTC IS NOT NULL THEN (CASE WHEN slaw.Resolved_Minutes  + slaw.resplan_minutes + slaw.responded_minutes <= 
			(CASE WHEN slap.Resolution_Hours IS NOT NULL THEN slap.Resolution_Hours ELSE sla.Resolution_Hours END
				* 60) THEN 'Met' ELSE 'Unmet' END) ELSE NULL END AS 'MetResolutionSLA',
		DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), CAST(s.date_closed AS DATETIME))  AS 'date_closed',
		LOWER(s.resolved_by) AS 'Resolved_By',
		LOWER(s.closed_by) AS 'Closed_By',
		CASE
		When DATEDIFF(DD, s.date_entered, s.date_closed) = 0 Then 'Y'
		ELSE 'N'
		End as 'Same_day_close',
		CASE
		WHEN DATEDIFF(DD,s.Date_Responded_UTC,s.Date_Resolved_UTC) = 0 Then 'Y'
		ELSE 'N'
		End as 'Same_day_resolved',
		s.servicetype AS 'Type',
		s.servicesubtype AS 'SubType',
		s.servicesubtypeitem AS 'Service_Item',
		s.urgency AS 'Priority',
		s.Severity,
		s.Impact,
		s.Hours_Actual, 
		s.Hours_Budget, 
		s.Hours_Scheduled,  
		s.Hours_Billable,   
		s.Hours_NonBillable,    
		s.Hours_Invoiced,   
		s.Hours_Agreement,
		s.agreement_name,
		CASE WHEN slaw.Date_Resolved_UTC IS NOT NULL THEN CAST(ROUND(DATEDIFF(Hour, s.Date_Entered,    slaw.Date_Resolved_UTC)/24.0, 0) AS NUMERIC) 
		ELSE CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) END AS 'Age (Days)',
 
		CASE WHEN slaw.Date_Resolved_UTC IS NULL THEN  
			CASE WHEN 
			CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) < 8 THEN '1. Current'
			WHEN 
			CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) > 7 AND CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) < 15 THEN '2. 1 Week'
			WHEN 
			CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) > 14 AND CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) < 22 THEN '3. 2 Weeks'
			WHEN 
			CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) > 21 AND CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) < 30 THEN '4. 3 Weeks'
			WHEN 
			CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) > 29 THEN '5. 1+ Month'
			END 
		ELSE 'Resolved' END AS 'Unresolved Age (Weeks)' ,
		CASE WHEN s.date_closed IS NULL THEN  
			CASE WHEN 
			CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) < 8 THEN '1. Current'
			WHEN 
			CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) > 7 AND CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) < 15 THEN '2. 1 Week'
			WHEN 
			CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) > 14 AND CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) < 22 THEN '3. 2 Weeks'
			WHEN 
			CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) > 21 AND CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) < 30 THEN '4. 3 Weeks'
			WHEN 
			CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) > 29 THEN '5. 1+ Month'
			END 
		ELSE 'Resolved' END AS 'Unsolved Age (Weeks)' ,
 
		CASE
			WHEN (s.date_resolved_utc IS NOT NULL) THEN 'Resolved'
			ELSE 'Open'
		  END AS 'Resolved_Flag',
		CASE
			WHEN (s.Date_Closed IS NOT NULL) THEN 'Closed'
			ELSE 'Open'
		END AS 'Closed_Flag',
		  CASE
			WHEN (sch.RecID IS NOT NULL) THEN 'Y'
			ELSE 'N'
		  END AS 'Is_Assigned',
 
		sr.CustUpdate_Flag as 'Customer_Responded',
		ISNULL(time.time_entry_count, 0) AS 'Time Entry Count',
		CASE WHEN (SELECT top 1 c.sr_service_recid FROM SR_Config c
		WHERE ticketnbr = c.sr_service_recid) IS NULL THEN 'False'
		ELSE 'True' END AS 'Config_Attached'
 
	FROM v_rpt_service AS s
	LEFT JOIN company as co on s.company_recid = co.company_recid
	LEFT JOIN (SELECT RecID FROM Schedule GROUP BY RecID) sch ON s.ticketnbr = sch.RecID
	LEFT JOIN SR_Service_SLA_Workflow AS slaw ON s.ticketnbr = slaw.SR_Service_RecID
	LEFT JOIN SR_Service AS sr ON s.ticketnbr = sr.sr_service_Recid
	LEFT JOIN SR_Urgency AS sru ON sr.SR_Urgency_RecID = sru.SR_Urgency_RecID
	LEFT JOIN SR_SLA AS sla ON sr.SR_SLA_RECID = sla.SR_SLA_RECID
	LEFT JOIN SR_SLAPriority AS slap ON sr.SR_SLA_RecID = slap.SR_SLA_RecID AND sru.SR_Urgency_RecID = slap.SR_Urgency_RecID
	LEFT JOIN (SELECT SR_Service_RecID, COUNT(SR_Service_Recid) AS 'time_entry_count' FROM Time_Entry GROUP BY SR_Service_RecID) time on s.TicketNbr = time.SR_Service_RecID

WHERE 
(DATEDIFF(DAY, s.Last_Update, Current_Timestamp) <= 120)
AND s.parent is null


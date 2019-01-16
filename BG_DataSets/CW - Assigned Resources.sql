-- CW - Assigned Resources
SQL
  SELECT NEWID() as 'id',
  LOWER(m.Member_ID) AS 'member_id',
  ISNULL(m.First_Name, '') + ' ' + ISNULL(m.Last_Name, '') AS 'Assigned_Resource',
  co.Company_Name AS 'Company Name',
  s.SR_Service_RecID AS 'Ticket_Number',
  s.Summary AS 'Summary',
  Case when s.CustUpdate_Flag = 'C' then 'Y'
  Else 'N'
  End as 'Customer Updated',
  ISNULL (time.sum_hours_actual, 0) AS 'Hours Actual',
  CAST(s.Date_Entered AS DATETIME) AS 'Date Opened',  
  CAST(s.Date_closed AS DATETIME) AS 'Date Closed',  
  CAST(s.Last_Update AS DATETIME) AS 'Date Last Updated',  
  RTRIM (st.Description) AS Status,
  b.Board_Name AS 'Board',
   sru.Description AS 'Priority',
  ISNULL (t.Description, '(none)') AS 'Type',
  ISNULL (subt.Description, '(none)') AS 'Sub Type',
  cast(slaw.date_responded_utc as datetime) as acknowledgement_date,
COALESCE (slaw.Responded_Minutes + slaw.Responded_Skipped_Minutes, 0) AS 'Time to Acknowledgement (Minutes)',
  CASE WHEN slaw.Date_Responded_UTC IS NOT NULL THEN (CASE WHEN slaw.Responded_Minutes + slaw.Responded_Skipped_Minutes <= (slap.Responded_Hours * 60) THEN 'Met' ELSE 'Unmet' END) ELSE NULL END AS 'MetResponseSLA',
CAST(CAST (slaw.Resplan_Minutes + slaw.Resplan_Skipped_Minutes + slaw.Responded_Minutes AS DECIMAL (9, 2)) / 60.0 AS DECIMAL(10,2)) AS 'Time_to_Resolution_Plan(Hours)',
CAST(slaw.date_resplan_utc AS DATETIME) AS 'resolution_plan_date',
CASE WHEN slaw.Date_Resplan_UTC IS NOT NULL THEN (CASE WHEN slaw.Resplan_Minutes + slaw.Resplan_Skipped_Minutes + slaw.Responded_Minutes <= (slap.Resplan_Hours * 60) THEN 'Met' ELSE 'Unmet' END) ELSE NULL END AS 'MetResPlanSLA',
CAST(CAST (slaw.Resolved_Minutes + slaw.resplan_minutes + slaw.responded_minutes AS DECIMAL (9, 2)) / 60.0 AS DECIMAL(10,2)) AS 'Time_to_Resolution(Hours)',
CAST(slaw.date_resolved_utc AS DATETIME) AS 'resolution_date',
CASE WHEN slaw.Date_Resolved_UTC IS NOT NULL THEN (CASE WHEN slaw.Resolved_Minutes  + slaw.resplan_minutes + slaw.responded_minutes <= (slap.Resolution_Hours * 60) THEN 'Met' ELSE 'Unmet' END) ELSE NULL END AS 'MetResolutionSLA',
lower(s.closed_by) as ticket_closed_by,
lower(slaw.resolved_by) as ticket_resolved_by,
  st.closed_flag as 'Closed Flag',
CASE WHEN slaw.Date_Resolved_UTC IS NOT NULL THEN CAST(ROUND(DATEDIFF(Hour, s.Date_Entered,    slaw.Date_Resolved_UTC)/24.0, 0) AS NUMERIC) 
ELSE CAST(ROUND(DATEDIFF(Hour, s.Date_Entered, CURRENT_TIMESTAMP)/24.0, 0) AS NUMERIC) END AS 'Age (Days)',
st.resolved_flag AS 'Resolved_Flag',
CAST(sched.Date_Time_Start AS DATETIME) as 'Scheduled_Date_Start',
CAST(sched.Date_Time_End AS DATETIME) as 'Scheduled_Date_End',
CAST(sched.Date_Entered AS DATETIME) as 'Schedule_Entered',
sched.close_flag AS schedule_close_flag,
sched.ack_flag AS schedule_acknowledgement_flag
FROM 
Member as m 
LEFT JOIN Schedule AS sched ON m.member_recid = sched.xref_Mbr_RecID
JOIN SR_Service AS s on sched.RecId = s.SR_Service_RecID

LEFT JOIN SR_Status AS st on s.SR_Status_RecID = st.SR_Status_RecID
LEFT JOIN Company AS co ON s.Company_RecID = co.Company_RecID
LEFT JOIN SR_Board AS b ON s.SR_Board_RecID = b.SR_Board_RecID
LEFT JOIN SR_Service_SLA_Workflow AS slaw ON s.SR_Service_RecID = slaw.SR_Service_RecID
LEFT JOIN SR_SLA AS sla ON s.SR_SLA_RECID = sla.SR_SLA_RECID
LEFT JOIN SR_Type AS t ON s.SR_Type_RecID = t.SR_Type_RecID
LEFT JOIN SR_SubType AS subt ON s.SR_SubType_RecID = subt.SR_SubType_RecID
LEFT JOIN SR_Urgency AS sru ON s.SR_Urgency_RecID = sru.SR_Urgency_RecID
LEFT JOIN SR_SLAPriority AS slap ON s.SR_SLA_RecID = slap.SR_SLA_RecID AND sru.SR_Urgency_RecID = slap.SR_Urgency_RecID
LEFT JOIN (SELECT Member_RecID, SR_Service_RecID, sum(Hours_Actual) AS 'sum_hours_actual' FROM Time_Entry GROUP BY Member_RecID, SR_Service_RecID) time ON
  (s.SR_Service_RecID = time.SR_Service_RecID and sched.Xref_Mbr_RecID = time.Member_RecID)
WHERE 
  Schedule_type_recid = 4 
  AND (DATEDIFF(DAY, s.Last_Update, Current_Timestamp) <= 120 or s.date_closed is null)
  AND  (
    SELECT SR_Service_RecID
    FROM dbo.SR_Task
    WHERE (Child_RecID = s.SR_Service_RecID)
  ) IS NULL  


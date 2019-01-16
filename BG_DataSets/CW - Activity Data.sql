-- CW - Activity Data
  SELECT NEWID() as id
    , SO_Activity.SO_Activity_RecID AS sch_id
    , SO_Activity.Subject
    , SO_Activity_Type.Description AS [Type]
    , Company.Company_Name AS Company
    , COALESCE (SO_Activity.Contact_Name, Contact.First_Name + ' ' + ISNULL (Contact.Last_Name, '')) AS Contact
    , assignedto.First_Name + ' ' + assignedto.Last_Name AS [Assigned To]
    , assignedby.First_Name + ' ' + assignedby.Last_Name AS [Assigned By]
    , SO_Act_Status.Description AS [Status]
    , SO_Activity.Close_Flag AS [Closed Flag]
    , CAST(SO_Activity.Date_Entered AS DATETIME)  AS [Date Entered]
    , CAST(SO_Activity.Date_Closed AS DATETIME)  AS [Date Closed]
    , CAST(schedule.Date_Scheduled AS DATETIME)  AS [Date Scheduled]
    , CAST(SO_Activity.last_update AS DATETIME) AS [Last Update]
    , cast(CASE WHEN NULLIF (schedule.Hours_Scheduled, 0) IS NOT NULL THEN  so_activity.Date_Time_Start END as datetime) AS [Start Time]
    , cast(CASE WHEN NULLIF (schedule.Hours_Scheduled, 0) IS NOT NULL THEN  so_activity.Date_Time_End END as datetime) AS [End Time]
    , NULLIF (schedule.Hours_Scheduled, 0) AS [Hours Scheduled]
    , (SELECT SUM (hours_actual)
     FROM Time_Entry
     WHERE Time_Entry.SO_Activity_RecID = SO_Activity.SO_Activity_RecID) AS [Hours Actual]
    , SO_Activity_Type.Points_Value AS Points
    , SR_Location.Description AS Location
    , SO_Opportunity.Opportunity_Name AS Opportunity
    , Marketing_Campaign.Marketing_ID AS [Marketing Campaign]
    , SO_Activity.SR_Service_RecID AS [Ticket #]
    , AGR_Header.AGR_Name AS Agreement
    , SO_Activity.Notes
    ,sos.Description as Opportunity_Status
    ,schedule.member_id as scheduled_technician
 FROM
    SO_Activity LEFT JOIN
    SO_Opportunity ON SO_Opportunity.Opportunity_RecID = SO_Activity.Opportunity_Recid
      LEFT JOIN
    Company ON Company.Company_RecID = so_activity.Company_RecID
      LEFT JOIN
    Marketing_Campaign ON Marketing_Campaign.Marketing_Campaign_RecID = SO_Activity.Marketing_Campaign_RecID
      INNER JOIN
    SO_Activity_Type ON SO_Activity.SO_Activity_Type_RecID = SO_Activity_Type.SO_Activity_Type_RecID
      INNER JOIN
    SO_Act_Status ON SO_Activity.so_act_status_recid = SO_Act_Status.SO_Act_Status_RecID
      INNER JOIN
    Member AS assignedto ON SO_Activity.assignto_recid = assignedto.Member_RecID
      INNER JOIN
    Member AS assignedby ON SO_Activity.assignby_recid = assignedby.Member_RecID
      LEFT OUTER JOIN
    AGR_Header ON SO_Activity.AGR_Header_RecID = AGR_Header.AGR_Header_RecID
      LEFT OUTER JOIN
    Contact ON SO_Activity.Contact_RecID = Contact.Contact_RecID
      LEFT OUTER JOIN
    SR_Location ON SO_Activity.SR_Location_RecID = SR_Location.SR_Location_RecID
      LEFT JOIN
    (SELECT RecID
      , cast(Date_Time_Start as date) as Date_Scheduled
      , Date_Time_Start as Start_Time
      , Date_Time_End as End_Time
      , Hours_Sched as Hours_Scheduled
      , member_id
    FROM Schedule
    WHERE Schedule_Type_RecID = 1) AS schedule ON SO_Activity.SO_Activity_RecID = schedule.RecID
    LEFT JOIN SO_Opp_Status as sos on sos.SO_Opp_Status_RecID = SO_Opportunity.SO_Opp_Status_RecID
 WHERE  DATEDIFF (DAY, SO_Activity.last_update, CURRENT_TIMESTAMP) <= 180  


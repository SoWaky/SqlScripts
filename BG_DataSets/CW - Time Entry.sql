-- CW - Time Entry
SQL
  SELECT 
   t.time_recID AS [id]
  ,t.time_recID AS [time_RecID]
  ,LOWER(m.Member_ID) AS [Member_ID]
  ,m.First_Name AS [First_Name]
  ,m.Last_Name AS [Last_Name]
  ,ol.Description AS [Location]
  ,bu.Description AS [Billing_Unit]
  ,c.Company_Name AS [Company]
  ,proj.Project_ID AS [Project]
  ,agr.AGR_Name AS [Agreement]
  ,wr.Description AS [Work_Role]
  ,wt.Description AS [Work_Type]
  ,cc.Description AS [Charge_Code]
  ,CAST(t.Date_Start AS DATETIME) AS Date
  ,CAST(t.Date_Start + t.time_start AS DATETIME)  AS [Start]
  ,CAST(t.Date_Start + t.time_end AS DATETIME) AS [End]
  ,ts.Description [Time_Status]
  ,t.Hours_Actual AS [Hours_Actual]
  ,CASE WHEN t.Billable_Flag = 1 AND t.Invoice_Flag = 1 THEN 'B' 
  WHEN t.Billable_Flag = 0 AND t.Invoice_Flag = 0 THEN 'NB' 
  WHEN t.Billable_Flag = 0 AND t.Invoice_Flag = 1 THEN 'NC' END AS [Billing_Status] 
  ,ISNULL(CASE WHEN t.Billable_Flag = 1 AND t.Invoice_Flag = 1 THEN Hours_Invoiced END,0) AS [Hours_B]
  ,ISNULL(CASE WHEN t.Billable_Flag = 0 AND t.Invoice_Flag = 0 THEN Hours_Invoiced END,0) AS [Hours_NB]
  ,ISNULL(CASE WHEN t.Billable_Flag = 0 AND t.Invoice_Flag = 1 THEN Hours_Invoiced END,0) AS [Hours_NC] 
  ,CASE WHEN wt.Utilization_Flag = 1 THEN 'Y' ELSE 'N' END AS [Utilized]
  ,ISNULL(CASE WHEN wt.Utilization_Flag = 1 THEN hours_actual END,0) AS [Hours_Utilized]
  ,ISNULL(CASE WHEN wt.Utilization_Flag = 0 THEN hours_actual END,0) AS [Hours_Non_utilized]
  ,ISNULL(t.Agr_Hours,0) AS [Hours_Agreement]
  ,t.Hourly_Rate AS [Hourly_Rate]
  ,CONVERT(decimal(9,2),t.Hours_Invoiced * t.Hourly_Rate * t.Billable_Flag) AS [Billable_Amount]
  ,ISNULL(t.Adjustment,0) AS [Adjustment]
  ,ISNULL(t.Agr_Amount,0) AS [Agreement_Amount]
  ,bl.Invoice_Number AS [Invoice_Number]
  ,t.SR_Service_RecID AS [Ticket_Number]
  ,sr.Summary AS [Ticket_Summary]
  ,b.board_name as ticket_board
FROM dbo.Time_Entry AS t INNER JOIN
  dbo.Member AS m ON m.Member_RecID = t.Member_RecID INNER JOIN
  dbo.Company AS c ON c.Company_RecID = t.Company_RecID INNER JOIN
  dbo.Owner_Level AS ol ON ol.Owner_Level_RecID = t.Owner_Level_RecID INNER JOIN
  dbo.Billing_Unit AS bu ON bu.Billing_Unit_RecID = t.Billing_Unit_RecID INNER JOIN
  dbo.Activity_Type AS wt ON wt.Activity_Type_RecID = t.Activity_Type_RecID INNER JOIN
  dbo.TE_Status AS ts ON ts.TE_Status_ID = t.TE_Status_ID INNER JOIN
  dbo.Activity_Class AS wr ON wr.Activity_Class_RecID = t.Activity_Class_RecID LEFT OUTER JOIN
  dbo.TE_Charge_Code AS cc ON cc.TE_Charge_Code_RecID = t.TE_Charge_Code_RecID LEFT OUTER JOIN
  dbo.Billing_Log AS bl ON bl.Billing_Log_RecID = t.Billing_Log_RecID LEFT OUTER JOIN
  dbo.SR_Service AS sr ON sr.SR_Service_RecID = t.SR_Service_RecID LEFT OUTER JOIN
  dbo.PM_Project AS proj ON proj.PM_Project_RecID = t.PM_Project_RecID LEFT OUTER JOIN
  dbo.AGR_Header AS agr ON agr.AGR_Header_RecID = t.Agr_Header_RecID
  left join dbo.sr_board as b on b.sr_board_Recid = sr.sr_board_recid
WHERE 
DATEDIFF (DAY, t.Date_Start, CURRENT_TIMESTAMP) <= 120  

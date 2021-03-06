/****** Script for SelectTopNRows command from SSMS  ******/
SELECT company_name
      ,ProjectName,ProjectManager,ProjectStatus,ProjectType,ProjectStartDate,ProjectEndDate,Percent_Complete_PerTicket,ProjectBillingMethod
	  , p.Billing_Amount, p.Billable_Flag, p.Exp_Billable_Flag, p.Prod_Billable_Flag, p.BillComplete_Flag
      ,Phase,PhaseStatus
      ,TicketNbr,Status_Description as Ticket_Status,Summary,agreement_name,Age
      ,hours_budget
      ,Hours_Scheduled
      ,Hours_Billable
      ,Hours_NonBillable
      ,Hours_Invoiced
      ,Hours_Agreement
      ,Hours_Remaining
      ,Hours_Actual
	FROM v_rpt_Project v
	inner join PM_Project p on p.PM_Project_RecID = v.PM_Project_RecID
	where ProjectStatus <> 'Closed'
		-- ProjectStartDate > '06/01/2017' 
	order by company_name, ProjectName, Phase, TicketNbr
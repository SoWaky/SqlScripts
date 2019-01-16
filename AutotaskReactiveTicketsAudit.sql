IF OBJECT_ID('tempdb..##Tickets') IS NOT NULL
    drop table ##Tickets

SELECT COALESCE(AssignedTo.Full_Name, '') as Assigned_To
		, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name
		, Ticket.task_number AS Ticket_Number, COALESCE(LEFT(Ticket.task_name, 50), '') AS Title
		, COALESCE(convert(char(10), Ticket.Create_Time, 111), '') as Created, COALESCE(convert(char(10), Ticket.Date_Completed, 111), '') as Completed
		, COALESCE(Board.queue_name, '') as Board
		, COALESCE(IssueType.issue_type_name, '') as 'Issue_Type'
		, COALESCE(SubIssueType.subissue_type_name, '') as 'SubIssue_Type'
		, COALESCE(Ticket.Total_Worked_Hours, '') AS Hours_Worked
		, COALESCE(convert(char(10), Ticket.Last_Customer_Notification_Time, 111), '') as Last_Cust_Notif
		, COALESCE(LEFT(Ticket.Task_Description, 50), '') as Ticket_Description
		, COALESCE(LEFT(Ticket.Resolution, 50) + ' ', '') as Resolution
	INTO ##Tickets
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_task_status TStat
		on TStat.task_status_id = Ticket.task_status_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_resource AssignedTo
		ON AssignedTo.resource_id = Ticket.assigned_resource_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_issue_type IssueType
		ON IssueType.issue_type_id = Ticket.issue_type_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_subissue_type SubIssueType
		ON SubIssueType.subissue_type_id = Ticket.subissue_type_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_contract TContract
		ON TContract.contract_id = Ticket.contract_id
	WHERE 1=1
		and Ticket.Date_Completed >= DATEADD(dd,-1, GETDATE())	-- Reactive Tickets closed yesterday
		AND Board.queue_name like '01%'
		and Ticket.task_name not like 'AEM Monitor Alert%'
		and (Ticket.task_description = ''
			or Ticket.assigned_resource_id is null
			or Ticket.total_worked_hours = 0
			or Ticket.issue_type_id is null
			or Ticket.subissue_type_id is null
			or Ticket.Resolution = ''
			or Ticket.last_customer_notification_time is null
			)
	ORDER BY 1,2,3


DECLARE @EmailBody varchar(max)

IF (select COUNT(*) from ##Tickets) > 0 
BEGIN

SET @EmailBody = 'Support Tickets Closed yesterday that are still missing important information.<BR/><BR/><table>'
	+ '<tr><td style="font-weight:bold;  border-bottom: thin solid blue; border-bottom: thin solid blue;">Assigned To</td><td style="font-weight:bold;  border-bottom: thin solid blue;">Company</td><td style="font-weight:bold;  border-bottom: thin solid blue;">Ticket #</td>'
	+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Title</td><td style="font-weight:bold;  border-bottom: thin solid blue;">Created</td><td style="font-weight:bold;  border-bottom: thin solid blue;">Completed</td>'
	+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Queue</td><td style="font-weight:bold;  border-bottom: thin solid blue;">Issue Type</td><td style="font-weight:bold;  border-bottom: thin solid blue;">SubIssue Type</td>'
	+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Hours Worked</td><td style="font-weight:bold;  border-bottom: thin solid blue;">Cust Notification</td><td style="font-weight:bold;  border-bottom: thin solid blue;">Description</td>'
	+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Resolution</td></tr>'


declare @Assigned_To varchar(100), @Company_Name varchar(100), @Ticket_Number varchar(100), @Title varchar(100), @Created varchar(100)
	, @Completed varchar(100), @Board varchar(100), @Issue_Type varchar(100), @SubIssue_Type varchar(100), @Hours_Worked varchar(100)
	, @Last_Cust_Notif varchar(100), @Ticket_Description varchar(100), @Resolution varchar(100)

declare csrUpdates cursor for
	SELECT * 
		FROM ##Tickets
		ORDER BY 1,2,3
	
open csrUpdates
fetch next from csrUpdates INTO @Assigned_To, @Company_Name, @Ticket_Number, @Title, @Created
	, @Completed, @Board, @Issue_Type, @SubIssue_Type, @Hours_Worked
	, @Last_Cust_Notif, @Ticket_Description, @Resolution

while @@Fetch_Status = 0
begin
	SET @EmailBody = @EmailBody + '<tr><td style="white-space: nowrap;">' 
		+ @Assigned_To + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @Company_Name + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @Ticket_Number + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @Title + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @Created + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @Completed + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @Board + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @Issue_Type + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @SubIssue_Type + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @Hours_Worked + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @Last_Cust_Notif + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @Ticket_Description + '</td><td style="white-space: nowrap; border-left: thin solid black;">' 
		+ @Resolution + '</td></tr>'
		
	fetch next from csrUpdates INTO @Assigned_To, @Company_Name, @Ticket_Number, @Title, @Created
		, @Completed, @Board, @Issue_Type, @SubIssue_Type, @Hours_Worked
		, @Last_Cust_Notif, @Ticket_Description, @Resolution
end

SET @EmailBody = @EmailBody + '</table>'

close csrUpdates
deallocate csrUpdates

END
ELSE
BEGIN
	SET @EmailBody = 'There were no Support tickets closed today that are missing important information :)'
END

PRINT @EmailBody

EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'SMTPtoGO'
	, @from_address = 'dev@webitservices.com'
    , @recipients = 'DailyMorningReport@webitservices.com'
    , @subject = 'Daily Support Tickets Report'
    , @body = @EmailBody
	, @body_format = 'HTML'

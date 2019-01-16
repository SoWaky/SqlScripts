DECLARE @CurrentWeek datetime
SET @CurrentWeek = DATEADD(day, -1, DATEADD(week, datepart(week, GETDATE()) - 1, DATEADD(yy, datepart(year, GETDATE()) - 1900, 0)))

-- DEBUG for Reload
--SET @CurrentWeek = '07/01/2018'

-- Delete the current week and reload it

DELETE FROM HoursByWeek	
	WHERE FirstDayOfWeek >= @CurrentWeek

INSERT INTO HoursByWeek (FirstDayOfWeek, Full_Name, Task_Number, Board, WorkRole, HoursWorked)
	SELECT DATEADD(day, -1, DATEADD(week, datepart(week, s.date_worked) - 1, DATEADD(yy, datepart(year, s.date_worked) - 1900, 0))) as FirstDayOfWeek
		, u.Full_Name
		, task.Task_Number
		, COALESCE(Board.queue_name, project.Project_Name, task.Task_Name) as Board
		, CASE WHEN Board.queue_name IN ('00 RMM Alerts','01.1 Support Triage','01.2 Support Tier 2','01.3 Support Tier 3') THEN 'Reactive'
				WHEN Board.queue_name IN ('03 Recurring Client Meetings', '04 Network Administration') THEN 'Network Administration'
				WHEN Board.queue_name = '02 vCIO' THEN 'vCIO'
				WHEN Board.queue_name = '05 Protective Services' THEN 'Protective Services'
				WHEN Board.queue_name = '08 Quotes' THEN 'Design Desk'
				WHEN wh_task_type.task_type_name = 'Project Task' THEN 'Professional Services'
				WHEN Board.queue_name = '10 Development' OR (u.Full_Name = 'Price, Matthew' and wh_task_type.task_type_name ='Project Task') THEN 'Development'
				ELSE 'INTERNAL' END as WorkRole
			, SUM(s.hours_worked) AS HoursWorked	
		from Autotask.TF_511394_WH.dbo.wh_time_item t
		inner join Autotask.TF_511394_WH.dbo.wh_time_subitem s
			on t.time_item_id = s.time_item_id
		left join Autotask.TF_511394_WH.dbo.wh_task task 
			on task.task_id = t.task_id
		inner join Autotask.TF_511394_WH.dbo.wh_resource u
			on u.resource_id = t.[user_id]
		left JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
			ON Board.queue_id = task.ticket_queue_id
		left join Autotask.TF_511394_WH.dbo.wh_task_type wh_task_type
			on wh_task_type.task_type_id = task.task_type_id
		left join Autotask.TF_511394_WH.dbo.wh_project project
			on project.project_id = task.project_id
		where 1=1
			and s.date_worked >=  @CurrentWeek
			and u.full_name in ('Alfini, Ron'
								,'Hoffman, Michael'
								,'LeBaron, Ann'
								,'Ortega, Omar'
								,'Price, Matthew'
								,'Robak, Shawn'
								,'Scannell, Matthew'
								,'Sowa, Scott'
								,'Sullivan, Chad'
								,'Zuidema, Eric')

		GROUP BY DATEADD(day, -1, DATEADD(week, datepart(week, s.date_worked) - 1, DATEADD(yy, datepart(year, s.date_worked) - 1900, 0))) 
		, u.Full_Name
		, task.Task_Number
		, COALESCE(Board.queue_name, project.Project_Name, task.Task_Name)
		, CASE WHEN Board.queue_name IN ('00 RMM Alerts','01.1 Support Triage','01.2 Support Tier 2','01.3 Support Tier 3') THEN 'Reactive'
				WHEN Board.queue_name IN ('03 Recurring Client Meetings', '04 Network Administration') THEN 'Network Administration'
				WHEN Board.queue_name = '02 vCIO' THEN 'vCIO'
				WHEN Board.queue_name = '05 Protective Services' THEN 'Protective Services'
				WHEN Board.queue_name = '08 Quotes' THEN 'Design Desk'
				WHEN wh_task_type.task_type_name = 'Project Task' THEN 'Professional Services'
				WHEN Board.queue_name = '10 Development' OR (u.Full_Name = 'Price, Matthew' and wh_task_type.task_type_name ='Project Task') THEN 'Development'
				ELSE 'INTERNAL' END 
		ORDER by 1,2

-- SELECT * FROM HoursByWeek order by 2,3
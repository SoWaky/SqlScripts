--select isnull(Board.queue_name, wh_task_type.task_type_name) as Board, s.date_worked, s.hours_worked, task.Task_Number, task.Task_Name, u.Full_Name
--	from Autotask.TF_511394_WH.dbo.wh_time_item t
--	inner join Autotask.TF_511394_WH.dbo.wh_time_subitem s
--		on t.time_item_id = s.time_item_id
--	left join Autotask.TF_511394_WH.dbo.wh_task task 
--		on task.task_id = t.task_id
--	inner join Autotask.TF_511394_WH.dbo.wh_resource u
--		on u.resource_id = t.[user_id]
--	left JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
--		ON Board.queue_id = task.ticket_queue_id
--	left join Autotask.TF_511394_WH.dbo.wh_task_type wh_task_type 
--		on wh_task_type.task_type_id = task.task_type_id
--	where s.date_worked between '09/23/2018' and '09/29/2018'
--	and u.full_name = 'Robak, Shawn'
--	order by 1,2,3

drop table #Time

SELECT datepart(week, s.date_worked) as 'WeekOfYear', MIN(s.date_worked) as StartDate
	, u.Full_Name
	, CASE WHEN Board.queue_name IN ('00 RMM Alerts','01.1 Support Triage','01.2 Support Tier 2','01.3 Support Tier 3') THEN 'Reactive'
			WHEN Board.queue_name IN ('03 Recurring Client Meetings', '04 Network Administration') THEN 'Network Administration'
			WHEN Board.queue_name = '10 Development' OR (u.Full_Name = 'Price, Matthew' and wh_task_type.task_type_name ='Project Task') THEN 'Development'
			WHEN Board.queue_name = '02 vCIO' THEN 'vCIO'
			WHEN Board.queue_name = '05 Protective Services' THEN 'Protective Services'
			WHEN wh_task_type.task_type_name = 'Project Task' THEN 'Professional Services'
			WHEN Board.queue_name = '08 Quotes' THEN 'Design Desk'
			ELSE 'INTERNAL' END as TypeofWork		
		, SUM(s.hours_worked) AS HoursWorked
		, (SELECT SUM(s2.hours_worked)
				FROM Autotask.TF_511394_WH.dbo.wh_time_item t2
				inner join Autotask.TF_511394_WH.dbo.wh_time_subitem s2
					on t2.time_item_id = s2.time_item_id
				inner join Autotask.TF_511394_WH.dbo.wh_resource u2
					on u2.resource_id = t2.[user_id]
				where s2.date_worked >= '10/01/2018'
					and u2.full_name = u.full_name) AS TotalHoursForUser
	into #Time
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
	where 1=1
		and s.date_worked >= '01/01/2018'
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

	GROUP BY datepart(week, s.date_worked), CASE WHEN Board.queue_name IN ('00 RMM Alerts','01.1 Support Triage','01.2 Support Tier 2','01.3 Support Tier 3') THEN 'Reactive'
			WHEN Board.queue_name IN ('03 Recurring Client Meetings', '04 Network Administration') THEN 'Network Administration'
			WHEN Board.queue_name = '10 Development' OR (u.Full_Name = 'Price, Matthew' and wh_task_type.task_type_name ='Project Task') THEN 'Development'
			WHEN Board.queue_name = '02 vCIO' THEN 'vCIO'
			WHEN Board.queue_name = '05 Protective Services' THEN 'Protective Services'
			WHEN wh_task_type.task_type_name = 'Project Task' THEN 'Professional Services'
			WHEN Board.queue_name = '08 Quotes' THEN 'Design Desk'
			ELSE 'INTERNAL' END
		, u.Full_Name
	
DELETE FROM ResourceUtilization

INSERT INTO ResourceUtilization (WeekOfYear, StartDate, ResourceName, TypeOfWork, HoursWorked, TotalHoursForUser, UtilizationPct)
	SELECT WeekOfYear, DATEADD(day, -1, DATEADD(week, WeekOfYear - 1, DATEADD(yy, datepart(year, StartDate) - 1900, 0))) as StartDate
			, Full_Name, TypeOfWork, HoursWorked, TotalHoursForUser, (HoursWorked / TotalHoursForUser) as Utilization
		FROM #Time t
		ORDER BY 1,2,3,4

SELECT * FROM ResourceUtilization
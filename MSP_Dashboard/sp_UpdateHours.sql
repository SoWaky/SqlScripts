-- TF_511394_WH database
-- select * from HoursByWeek order by full_name 
-- exec sp_UpdateHours

USE MSP_Dashboard
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_UpdateHours]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sp_UpdateHours]
GO

CREATE  PROCEDURE [dbo].[sp_UpdateHours]
AS 

SET NOCOUNT ON 


DECLARE @StartDate datetime
SET @StartDate = DATEADD(day, -1, DATEADD(week, datepart(week, GETDATE()) - 1, DATEADD(yy, datepart(year, GETDATE()) - 1900, 0)))
SET @StartDate = DATEADD(week, -3, @StartDate)	-- Go back 3 weeks since people are taking a long time to get their hours entered in the system
PRINT @StartDate

-- DEBUG for Reload
--SET @StartDate = '01/01/2019'

-- Delete the current week and reload it

DELETE FROM HoursByWeek	
	WHERE FirstDayOfWeek >= @StartDate

INSERT INTO HoursByWeek (FirstDayOfWeek, Full_Name, Task_Number, Board, WorkRole, WorkType, HoursWorked)
	SELECT DATEADD(day, -1, DATEADD(week, datepart(week, s.date_worked) - 1, DATEADD(yy, datepart(year, s.date_worked) - 1900, 0))) as FirstDayOfWeek
		, u.Full_Name
		, task.Task_Number
		, COALESCE(Board.queue_name, project.Project_Name, task.Task_Name) as Board
		, CASE WHEN LEFT(Board.queue_name, 2) = '00' OR LEFT(Board.queue_name, 2) = '01' THEN 'Reactive'
				WHEN LEFT(Board.queue_name, 2) = '03' OR LEFT(Board.queue_name, 2) = '04' THEN 'Network Administration'
				WHEN LEFT(Board.queue_name, 2) = '02' THEN 'vCIO'
				WHEN LEFT(Board.queue_name, 2) = '05' THEN 'Protective Services'
				WHEN LEFT(Board.queue_name, 2) = '08' THEN 'Design Desk'
				WHEN LEFT(Board.queue_name, 2) = '10' OR (u.Full_Name in ('Price, Matthew', 'Antoon, Chris', 'Finnerty, Annie', 'Errichiello, Frank', 'Rudnick, Matthew') and wh_task_type.task_type_name ='Project Task') THEN 'Development'
				WHEN wh_task_type.task_type_name = 'Project Task' or LEFT(Board.queue_name, 2) = '06' THEN 'Professional Services'
				WHEN LEFT(Board.queue_name, 2) = '11' THEN 'Finance'
				ELSE 'INTERNAL' END as WorkRole
			, allocation.allocation_code_name as WorkType
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
		left join Autotask.TF_511394_WH.dbo.[wh_allocation_code] allocation
			on allocation.allocation_code_id = s.allocation_code_id
		where 1=1
			and s.date_worked >=  @StartDate
			and u.full_name <> 'Valentine, Ross'
		GROUP BY DATEADD(day, -1, DATEADD(week, datepart(week, s.date_worked) - 1, DATEADD(yy, datepart(year, s.date_worked) - 1900, 0))) 
		, u.Full_Name
		, task.Task_Number
		, COALESCE(Board.queue_name, project.Project_Name, task.Task_Name)
		, CASE WHEN LEFT(Board.queue_name, 2) = '00' OR LEFT(Board.queue_name, 2) = '01' THEN 'Reactive'
				WHEN LEFT(Board.queue_name, 2) = '03' OR LEFT(Board.queue_name, 2) = '04' THEN 'Network Administration'
				WHEN LEFT(Board.queue_name, 2) = '02' THEN 'vCIO'
				WHEN LEFT(Board.queue_name, 2) = '05' THEN 'Protective Services'
				WHEN LEFT(Board.queue_name, 2) = '08' THEN 'Design Desk'
				WHEN LEFT(Board.queue_name, 2) = '10' OR (u.Full_Name in ('Price, Matthew', 'Antoon, Chris', 'Finnerty, Annie', 'Errichiello, Frank', 'Rudnick, Matthew') and wh_task_type.task_type_name ='Project Task') THEN 'Development'
				WHEN wh_task_type.task_type_name = 'Project Task' or LEFT(Board.queue_name, 2) = '06' THEN 'Professional Services'
				WHEN LEFT(Board.queue_name, 2) = '11' THEN 'Finance'
				ELSE 'INTERNAL' END
		, allocation.allocation_code_name
		ORDER by 1,2

-- SELECT * FROM HoursByWeek order by 2,3

GO
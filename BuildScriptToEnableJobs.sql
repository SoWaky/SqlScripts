USE msdb
go

---------------------
-- This script finds all job schedules that are currently active on this server
--		and builds a script that will re-enable all those schedules
-- This is useful if you need to disable all job schedules while setting up a new server and then you want to re-enable the original schedules
--
-- Run this query first

SELECT distinct sj.name AS jobName, ss.enabled, ss.name AS scheduleName--, sja.next_scheduled_run_date, sjs.schedule_id
	, 'SELECT @ScheduleId = ss.schedule_id  ' 
		+ ' FROM msdb.dbo.sysjobs sj INNER JOIN msdb.dbo.sysjobactivity sja ON sja.job_id = sj.job_id INNER JOIN msdb.dbo.sysjobschedules sjs ON sjs.job_id = sja.job_id INNER JOIN msdb.dbo.sysschedules ss ON ss.schedule_id = sjs.schedule_id ' 
		+ ' WHERE sj.Name = ''' + sj.Name + ''' AND ss.name = ''' + ss.name + '''; ' 
		--+ ' PRINT @ScheduleId'
		+ ' EXEC msdb.dbo.sp_update_schedule @schedule_id = @ScheduleId, @enabled = 1; ' as sqlex
FROM msdb.dbo.sysjobs sj
INNER JOIN msdb.dbo.sysjobactivity sja ON sja.job_id = sj.job_id
INNER JOIN msdb.dbo.sysjobschedules sjs ON sjs.job_id = sja.job_id
INNER JOIN msdb.dbo.sysschedules ss ON ss.schedule_id = sjs.schedule_id
where ss.enabled = 1
order by 2,1,3


-- Copy the sqlex column from the results for that query and paste them below the DECLARE statement below
-- then move all that code to a SQL script and save them for when you are ready to re-enable all schedules

USE msdb
go

DECLARE @ScheduleId int

-- paste here --

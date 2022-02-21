USE msdb
go

---------------------
-- This script finds all job schedules that are currently active on this server
--		and builds a script that will re-enable all those schedules
-- This is useful if you need to disable all job schedules while setting up a new server and then you want to re-enable the original schedules
--
-- Run this query first

SELECT distinct sj.name AS jobName, ss.enabled, ss.name AS scheduleName--, sja.next_scheduled_run_date, sjs.schedule_id
	, 'SELECT distinct ''EXEC msdb.dbo.sp_update_schedule @schedule_id = '''''' + cast(ss.schedule_id as varchar(100)) + '''''', @enabled = 1; '' as sqlex FROM msdb.dbo.sysjobs sj INNER JOIN msdb.dbo.sysjobactivity sja ON sja.job_id = sj.job_id INNER JOIN msdb.dbo.sysjobschedules sjs ON sjs.job_id = sja.job_id INNER JOIN msdb.dbo.sysschedules ss ON ss.schedule_id = sjs.schedule_id where sj.name = ''' + sj.name + ''' and ss.name = ''' + ss.name + '''  UNION ' as SqlEx
FROM msdb.dbo.sysjobs sj
INNER JOIN msdb.dbo.sysjobactivity sja ON sja.job_id = sj.job_id
INNER JOIN msdb.dbo.sysjobschedules sjs ON sjs.job_id = sja.job_id
INNER JOIN msdb.dbo.sysschedules ss ON ss.schedule_id = sjs.schedule_id
where ss.enabled = 1
order by 2,1,3


-- 1. Run the above query
-- 2. Copy the SqlEx column from the results and paste them into a new Query window
-- 3. Delete the last 'UNION' statement at the end of the script
-- 4. Run that script.  The commands that you pasted below to generate all of the SQL commands that will re-enable every job in the Results window
-- 5. Copy the SqlEx column from that Results window and save them in a SQL script file.
--	 It will have a command for re-enabling every job schedule for when you are ready to re-enable all schedules



SELECT distinct sj.name AS jobName, ss.enabled, ss.name AS scheduleName--, sja.next_scheduled_run_date, sjs.schedule_id
	, 'SELECT distinct ''EXEC msdb.dbo.sp_update_schedule @schedule_id = '''''' + cast(ss.schedule_id as varchar(100)) + '''''', @enabled = 1; '' as sqlex FROM msdb.dbo.sysjobs sj INNER JOIN msdb.dbo.sysjobactivity sja ON sja.job_id = sj.job_id INNER JOIN msdb.dbo.sysjobschedules sjs ON sjs.job_id = sja.job_id INNER JOIN msdb.dbo.sysschedules ss ON ss.schedule_id = sjs.schedule_id where sj.name = ''' + sj.name + ''' and ss.name = ''' + ss.name + '''  ' as enab
FROM msdb.dbo.sysjobs sj
INNER JOIN msdb.dbo.sysjobactivity sja ON sja.job_id = sj.job_id
INNER JOIN msdb.dbo.sysjobschedules sjs ON sjs.job_id = sja.job_id
INNER JOIN msdb.dbo.sysschedules ss ON ss.schedule_id = sjs.schedule_id
where ss.enabled = 1
order by 2,1,3

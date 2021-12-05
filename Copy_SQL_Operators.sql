-- This script generates commands to copy SQL Agent - Operators from one server to another
-- Operators and Proxies must be copied before Jobs can be copied

USE msdb ;  
GO  

select 'EXEC dbo.sp_add_operator @name = N''' + s.[name] + ''''  
    + CASE WHEN s.enabled IS NOT NULL THEN ', @enabled = ' + cast(s.enabled as varchar(1)) ELSE '' END
    + CASE WHEN s.email_address IS NOT NULL THEN ', @email_address = N''' + s.email_address + '''' ELSE '' END
    + CASE WHEN s.pager_address IS NOT NULL THEN ', @pager_address = N''' + s.pager_address + '''' ELSE '' END
    + CASE WHEN s.weekday_pager_start_time IS NOT NULL THEN ', @weekday_pager_start_time = ' + cast(s.weekday_pager_start_time as varchar(100)) ELSE '' END
    + CASE WHEN s.weekday_pager_end_time IS NOT NULL THEN ', @weekday_pager_end_time = ' + cast(s.weekday_pager_end_time as varchar(100))  ELSE '' END
    + CASE WHEN s.pager_days IS NOT NULL THEN ', @pager_days = ' + cast(s.pager_days  as varchar(100)) ELSE '' END
	as sqlex , *
FROM [msdb].[dbo].[sysoperators] s

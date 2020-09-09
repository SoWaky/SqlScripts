SELECT db_name(database_id) as DbName, name as logical_name, physical_name AS CurrentLocation, Type_Desc
	FROM sys.master_files  
	WHERE 1=1
	--and database_id = DB_ID(N'AAMGBACKUP')	
	--and physical_name  like '%.mdf%'
	and db_name(database_id) not in ('master', 'model','msdb','reportserver','reportservertempdb','ssisdb','tempdb')
	order by 3
SELECT distinct 'BACKUP DATABASE [' + db_name(database_id) + '] 
	TO DISK = N''E:\BackUps\MAGIC\' + db_name(database_id) + '_20211127.bak'' 
	WITH NAME = N''' + db_name(database_id) + '_20211127'', NOINIT, RETAINDAYS = 1, STATS = 10, CHECKSUM' 
	FROM sys.master_files  
	WHERE 1=1
	--and database_id = DB_ID(N'AAMGBACKUP')	
	--and physical_name  like '%.mdf%'
	and db_name(database_id) not in ('master', 'model','msdb','reportserver','reportservertempdb','ssisdb','tempdb')
	order by 1
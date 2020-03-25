--ALTER DATABASE AAMGBACKUP SET OFFLINE;
--ALTER DATABASE AAMGBACKUP MODIFY FILE ( NAME = AAMGBACKUP, FILENAME = 'H:\MSSQL\DATA\AAMGBACKUP.mdf' );
--ALTER DATABASE AAMGBACKUP MODIFY FILE ( NAME = AAMGBACKUP_log, FILENAME = 'H:\MSSQL\LOG\AAMGBACKUP_log.ldf' );
--ALTER DATABASE AAMGBACKUP SET ONLINE;



SELECT db_name(database_id) as DbName, name as logical_name, physical_name AS CurrentLocation, state_desc
		, 'ALTER DATABASE ' + db_name(database_id) + ' SET OFFLINE  WITH ROLLBACK IMMEDIATE;' as sql1
		, 'ALTER DATABASE ' + db_name(database_id) + ' MODIFY FILE ( NAME = ' + name + ', FILENAME = ''' + physical_name + ''');' as ql2
		, 'ALTER DATABASE ' + db_name(database_id) + ' SET ONLINE;' as sql3
	FROM sys.master_files  
	WHERE 1=1
	--and database_id = DB_ID(N'AAMGBACKUP')
	--and physical_name not like '%aamg%'
	and physical_name  like '%.mdf%'
	order by 3
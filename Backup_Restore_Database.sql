------------------------------
---- Connect to database to be backed up
-- Check how much space a backup of the current database is going to take up
exec sp_spaceused

------------------------------------------------------------
-- Create a backup file for the given database
-- Connect to master database

BACKUP DATABASE WSCP
	TO DISK = N'E:\Backup\WSCP_20190715.bak' 
	WITH NAME = N'WSCP_20190715'
	, NOINIT	-- Append to an existing media set, if exists
	, RETAINDAYS = 1
	, STATS = 10
	, CHECKSUM

	

------------------------------------------------------------
-- Restore from a backup file over the given database
-- TODO: Change your connection to the Master database first!

-- Make Database to single user Mode first to reduce conflicts
ALTER DATABASE MfgTest803
	SET SINGLE_USER WITH
	ROLLBACK IMMEDIATE
 
-- Restore Database file
RESTORE DATABASE WSCP
	FROM DISK = 'C:\temp\WSCP_20190715.bak'
	WITH STATS = 10
	, CHECKSUM
	, MOVE 'WSCP' TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\WSCP.mdf'
	, MOVE 'WSCP_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\WSCP_log.LDF'
	, REPLACE
 
-- If there is no error in statement before database will be in multiuser mode.
-- If error occurs please execute following command it will convert database in multi user.*/
ALTER DATABASE MfgTest803 
	SET MULTI_USER




------------------------------------------------------------
---- Connect to master database
-- Check database file names to use in the RESTORE

SELECT  DB_NAME([database_id]) [database_name], [file_id], [type_desc] [file_type]
		, [name] [logical_name], [physical_name], [Size], [Max_Size]
		, ', MOVE ''' + [name] + ''' TO ''' + [physical_name] + '''' AS With_Move
		, CASE WHEN type_desc = 'FULLTEXT' 
				THEN 'ALTER FULLTEXT CATALOG ' + REPLACE([name], 'sysft_', '') + ' REBUILD'
				ELSE '' END as Full_Text_Rebuild
	FROM Master.sys.[master_files]
	WHERE [database_id] IN (DB_ID('AXDB_30_SP30_Production_Main'))
	ORDER BY [type], DB_NAME([database_id])

-- Get Database Sizes
SELECT  DB_NAME([database_id]) as [database_name]--, [type_desc] as [file_type]
		, [name] as [logical_name], [physical_name] as [File_Name], [Size] as 'Current_Size'--, [Max_Size]
		, 'USE ' + DB_NAME([database_id]) + '
GO
ALTER DATABASE ' + DB_NAME([database_id]) + ' SET RECOVERY SIMPLE
GO
DBCC SHRINKFILE (' + [name] + ', 1)
GO'
	FROM Master.sys.[master_files]
	WHERE 1=1
		and DB_NAME([database_id]) not in ('tempdb','model','master','msdb','SSISDB','reportserver')
		--AND [physical_name] like 'E:%'
		AND [type_desc] <> 'ROWS'
	ORDER BY 4 desc

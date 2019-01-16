------------------------------
-- Check how much space a backup of the current database is going to take up
exec sp_spaceused

------------------------------------------------------------
-- Create a backup file for the given database

BACKUP DATABASE MfgSys803
	TO DISK = N'D:\Backups\MfgSys803\MfgSys803_backup_20161118.bak' 
	WITH NAME = N'MfgSys803_backup_20161118'
	, NOINIT	-- Append to an existing media set, if exists
	, RETAINDAYS = 1
	, STATS = 10
	, CHECKSUM


------------------------------------------------------------
-- Check database file names to use in the RESTORE

SELECT  DB_NAME([database_id]) [database_name], [file_id], [type_desc] [file_type]
		, [name] [logical_name], [physical_name]
		, ', MOVE ''' + [name] + ''' TO ''' + [physical_name] + '''' AS With_Move
		, CASE WHEN file_type = 'FULLTEXT' 
				THEN 'ALTER FULLTEXT CATALOG ' + REPLACE([name], 'sysft_', '') + ' REBUILD'
				ELSE '' END as Full_Text_Rebuild
	FROM Master.sys.[master_files]
	WHERE [database_id] IN (DB_ID('MfgTest803'))
	ORDER BY [type], DB_NAME([database_id])

------------------------------------------------------------
-- Restore from a backup file over the given database
-- TODO: Change your connection to the Master database first!

-- Make Database to single user Mode first to reduce conflicts
ALTER DATABASE MfgTest803
	SET SINGLE_USER WITH
	ROLLBACK IMMEDIATE
 
-- Restore Database file
RESTORE DATABASE MfgTest803
	FROM DISK = '\\fqw08bdr01\Backups2\FQSQL03\MfgSys803\MfgSys803_backup_20161118.bak'
	WITH STATS = 10
	, CHECKSUM
	, MOVE 'mfgsys803' TO 'F:\MSSQL\MSSQL.1\MSSQL\Data\mfgtest803.mdf'
	, MOVE 'mfgsys803_log' TO 'E:\MSSQL\Data\MfgTest803_log.LDF'
	, REPLACE
 
-- If there is no error in statement before database will be in multiuser mode.
-- If error occurs please execute following command it will convert database in multi user.*/
ALTER DATABASE MfgTest803 
	SET MULTI_USER

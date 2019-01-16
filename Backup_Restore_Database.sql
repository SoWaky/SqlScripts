------------------------------
---- Connect to database to be backed up
-- Check how much space a backup of the current database is going to take up
exec sp_spaceused

------------------------------------------------------------
-- Create a backup file for the given database
-- Connect to master database

BACKUP DATABASE OFC
	TO DISK = N'\\webw10wkst41\Backups\OFC_20180815.bak' 
	WITH NAME = N'OFC_Backup_20180815'
	, NOINIT	-- Append to an existing media set, if exists
	, RETAINDAYS = 1
	, STATS = 10
	, CHECKSUM

	
------------------------------------------------------------
---- Connect to master database
-- Check database file names to use in the RESTORE

SELECT  DB_NAME([database_id]) [database_name], [file_id], [type_desc] [file_type]
		, [name] [logical_name], [physical_name]
		, ', MOVE ''' + [name] + ''' TO ''' + [physical_name] + '''' AS With_Move
		, CASE WHEN type_desc = 'FULLTEXT' 
				THEN 'ALTER FULLTEXT CATALOG ' + REPLACE([name], 'sysft_', '') + ' REBUILD'
				ELSE '' END as Full_Text_Rebuild
	FROM Master.sys.[master_files]
	WHERE [database_id] IN (DB_ID('AXDB_30_SP30_Production_Main'))
	ORDER BY [type], DB_NAME([database_id])


------------------------------------------------------------
-- Restore from a backup file over the given database
-- TODO: Change your connection to the Master database first!

-- Make Database to single user Mode first to reduce conflicts
ALTER DATABASE MfgTest803
	SET SINGLE_USER WITH
	ROLLBACK IMMEDIATE
 
-- Restore Database file
RESTORE DATABASE OFC
	FROM DISK = 'C:\Development\OFCAndFishes\Backups\OFC.bak'
	WITH STATS = 10
	, CHECKSUM
	, MOVE 'OFC' TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\OFC.mdf'
	, MOVE 'OFC_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\OFC_log.LDF'
	, REPLACE
 
-- If there is no error in statement before database will be in multiuser mode.
-- If error occurs please execute following command it will convert database in multi user.*/
ALTER DATABASE MfgTest803 
	SET MULTI_USER
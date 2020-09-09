-- select * FROM [msdb].[dbo].backupset

DECLARE @databaseName sysname, @backupStartDate datetime, @backup_set_id float, @backup_set_id_start INT, @backup_set_id_end INT 
	, @LogicalNameData varchar(100), @LogicalNameLog varchar(100)
	, @DbDataFile varchar(100), @DbLogFile varchar(100), @SqlCmd nvarchar(max), @ViewCommandsOnly bit

---------------------------------------------------------
SET @databaseName = DB_NAME()
PRINT @databaseName

SET @ViewCommandsOnly = 1	-- 0 to actually execute the Restore commands.  1 to only view them
---------------------------------------------------------


-- Get the Logical names for the Data and Log files for the current database
SELECT @LogicalNameData = [name]
	, @DbDataFile = [physical_name]
	FROM [Master].[sys].[master_files]
	WHERE [database_id] = DB_ID(@databaseName)
	AND type_desc = 'ROWS'

SELECT @LogicalNameLog = [name]
	, @DbLogFile = [physical_name]
	FROM [Master].[sys].[master_files]
	WHERE [database_id] = DB_ID(@databaseName)
	AND type_desc = 'LOG'

-- Query the Backups tables over on EXCELMSO-SQL3 to get all of the backups that belong to the current backup chain
SELECT @backup_set_id_start = MAX(backup_set_id) 
	FROM [msdb].[dbo].backupset 
	WHERE database_name = @databaseName AND type = 'D' 
	and [name] like @databaseName + '%'
	PRINT @backup_set_id_start

SELECT @backup_set_id_end = max(backup_set_id) 
	FROM [msdb].[dbo].backupset 
	WHERE database_name = @databaseName AND type = 'I' 
	AND backup_set_id > @backup_set_id_start 


IF @backup_set_id_end IS NULL SET @backup_set_id_end = 999999999 
	PRINT @backup_set_id_end


-- Build a list of all commands necessary to restore each backup file into this database
-- Send that list of commands to a cursor so we can loop through them

DECLARE csrRestore CURSOR 
FOR

--SELECT -2 AS backup_set_id, 'USE master; GO;'  as [SqlCmd]
--UNION

SELECT -1 AS backup_set_id, 'ALTER DATABASE ' + @databaseName + ' SET SINGLE_USER WITH ROLLBACK IMMEDIATE;' as [SqlCmd]

UNION
SELECT backup_set_id, '
RESTORE DATABASE ' + @databaseName + ' 
FROM DISK = ''' + mf.physical_device_name + ''' 
WITH STATS = 10
, REPLACE
, MOVE ''' + @LogicalNameData + ''' TO ''' + @DbDataFile + '''
, MOVE ''' + @LogicalNameLog + ''' TO ''' + @DbLogFile + '''
, NORECOVERY;'
	FROM [msdb].[dbo].backupset b, 
		[msdb].[dbo].backupmediafamily mf 
	WHERE b.media_set_id = mf.media_set_id 
	AND b.database_name = @databaseName 
	AND b.backup_set_id = @backup_set_id_start 

UNION
SELECT backup_set_id, '
RESTORE DATABASE ' + @databaseName + ' 
FROM DISK = ''' + mf.physical_device_name + ''' 
WITH STATS = 10, REPLACE, NORECOVERY;'
	FROM [msdb].[dbo].backupset b, 
	[msdb].[dbo].backupmediafamily mf 
	WHERE b.media_set_id = mf.media_set_id 
	AND b.database_name = @databaseName 
	AND b.backup_set_id > @backup_set_id_start 
	AND b.type = 'I'	-- Incremental Diff

UNION 
SELECT backup_set_id, '
RESTORE LOG ' + @databaseName + ' 
FROM DISK = ''' + mf.physical_device_name
+ ''' WITH NORECOVERY;' 
	FROM [msdb].[dbo].backupset b, 
	[msdb].[dbo].backupmediafamily mf 
	WHERE b.media_set_id = mf.media_set_id 
	AND b.database_name = @databaseName 
	AND b.backup_set_id BETWEEN @backup_set_id_start AND @backup_set_id_end 
	AND b.type = 'L' 
UNION 
SELECT 999999999 AS backup_set_id, '
RESTORE DATABASE ' + @databaseName + ' WITH RECOVERY;' 
UNION
SELECT 9999999999 AS backup_set_id, '
ALTER DATABASE ' + @databaseName + ' SET MULTI_USER;'

	ORDER BY backup_set_id


OPEN csrRestore
FETCH NEXT FROM csrRestore INTO @backup_set_id, @SqlCmd

WHILE @@FETCH_STATUS = 0
BEGIN
	Print @SqlCmd

	IF @ViewCommandsOnly = 0
	BEGIN
		exec sp_executesql @SqlCmd
	END

	FETCH NEXT FROM csrRestore INTO @backup_set_id, @SqlCmd
END
CLOSE csrRestore
DEALLOCATE csrRestore

PRINT 'Finished.'
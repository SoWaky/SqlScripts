EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXEC sp_configure 'xp_cmdshell',1
GO
RECONFIGURE
GO

EXEC XP_CMDSHELL 'net use N: /delete /y'
go

EXEC XP_CMDSHELL 'net use N: \\webitnas406\BackupImages\PPPPERSOSQL1 /persistent:Yes /user:PPP\PPPADMIN M@kePl@stic#19'
go
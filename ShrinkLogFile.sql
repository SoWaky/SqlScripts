USE PMGLive
GO
ALTER DATABASE PMGLive
SET RECOVERY SIMPLE
GO
DBCC SHRINKFILE (DATA41_log, 1)
GO
ALTER DATABASE PMGLive
SET RECOVERY FULL
SELECT [name] AS [Database Name], recovery_model_desc AS [Recovery Model]
		, 'ALTER DATABASE [' + [name] + '] SET RECOVERY SIMPLE; ' as SetSimple
	FROM sys.databases
	order by 2
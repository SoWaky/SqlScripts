SELECT o.Name as View_Name
		, m.Definition as View_SQL
		, 'EXECUTE sp_refreshsqlmodule N''[dbo].[' + o.Name + ']'';' as RegenView
	FROM sys.objects     o
	join sys.sql_modules m on m.object_id = o.object_id
	WHERE o.type      = 'V'
	ORDER BY 1
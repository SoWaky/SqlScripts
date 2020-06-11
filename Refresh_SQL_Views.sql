SELECT DISTINCT 'EXEC sp_refreshview ''' + name + ''''   
	FROM sys.objects AS so   
	INNER JOIN sys.sql_expression_dependencies AS sed   
		ON so.object_id = sed.referencing_id   
	WHERE so.type = 'V' 
		--AND sed.referenced_id = OBJECT_ID('Person.Person');  
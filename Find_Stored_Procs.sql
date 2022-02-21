-- This query searches the text of all Stored Procedures in the currently selected DATABASE

SELECT DB_NAME() AS DATABASENAME, [TYPE_DESC], [NAME],[DEFINITION]
	FROM sys.sql_modules m
	INNER JOIN       sys.objects o
	ON m.object_id = o.object_id
	WHERE [definition] LIKE '%JORDAN%'
	OR [definition] LIKE '%STUART%'
	OR [definition] LIKE '%10.10%'
	OR [definition] LIKE '%SQL2K%'
	OR [definition] LIKE '%UNITEDCENTER%'
	ORDER BY 1,2,3
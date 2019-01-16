SELECT so.name
		, CONVERT (decimal (28,1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) AS improvement_measure
		, 'CREATE INDEX missing_index_' 
			+ CONVERT (varchar, mig.index_group_handle) 
			+ '_' + CONVERT (varchar, mid.index_handle)+ ' ON '   + mid.statement   + ' ('       + ISNULL (mid.equality_columns,'')
			+ CASE WHEN mid.equality_columns IS NOT NULL AND mid.inequality_columns IS NOT NULL THEN ',' ELSE '' END
			+ ISNULL (mid.inequality_columns, '')+ ')'+ ISNULL (' INCLUDE (' + mid.included_columns + ')', '') AS create_index_statement
		, migs.avg_total_user_cost
		, migs.avg_user_impact
		, migs.user_seeks
		, migs.last_user_seek
		, mig.index_group_handle
		, mid.index_handle
		, migs.*
		, mid.database_id
		, mid.object_id
	FROM sys.dm_db_missing_index_groups mig
		INNER JOIN sys.dm_db_missing_index_group_stats migs 
			  ON migs.group_handle = mig.index_group_handle
		INNER JOIN sys.dm_db_missing_index_details mid 
			  ON mig.index_handle = mid.index_handle
		INNER JOIN sys.objects so
			  ON mid.object_id = so.object_id
	WHERE CONVERT (decimal (28,1), migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans)) > 10
		AND  mid.database_id=db_id()
	--    AND  so.name like 'Mc_AhSvc'
	ORDER BY 2 DESC

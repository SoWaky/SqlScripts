-- 0 Seeks, scans and lookups mean an index has not been used since the computer rebooted and stats were reset
SELECT OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME], 
       I.[NAME] AS [INDEX NAME], 
       USER_SEEKS, 
       USER_SCANS, 
       USER_LOOKUPS, 
       USER_UPDATES 
FROM   SYS.DM_DB_INDEX_USAGE_STATS AS S 
       INNER JOIN SYS.INDEXES AS I ON I.[OBJECT_ID] = S.[OBJECT_ID] AND I.INDEX_ID = S.INDEX_ID 
WHERE  OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1
       AND S.database_id = DB_ID()
	   ORDER BY 3,4,5
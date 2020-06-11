select distinct tab.Name AS Table_Nm
	, col.name AS Column_Nm
	--, ' = @' + col.name
	--, ', this.CreateParameter("@' + col.name + '", ' + col.name + ')'
	--, ', string ' + col.name
	--, 'txt' + col.name + '.Text = row["' + col.name + '"].ToString();'
	, typ.Name AS Column_Type
	, COALESCE(col.Prec, 0) as Precision
	, COALESCE(col.Scale, 0) as Scale
	--, col.Status
	, col.IsNullable as Allow_Null_Ind
	, 'SELECT top 3 ''' + RTRIM(tab.name) + ''' as Table_Name, * from [' + tab.name + ']'
	--, 'DELETE FROM ' + RTRIM(tab.name)
	, 'SELECT  ''' + RTRIM(tab.name) + ''' as Table_Name, count(*) as numrecs from [' + tab.name + '] WITH (NOLOCK)'
	--	+ case when db_name() like 'MFG%' THEN '  order by progress_recid desc' else '' END as GetRecs
	, 'UPDATE [' + tab.name + '] set [' + col.name + '] = dateadd(hh, -6, [' + col.name + ']) where 1=1 ' as UpdateRecs
	FROM sysobjects tab
	INNER JOIN syscolumns col ON (tab.id = col.id)
	INNER JOIN systypes typ ON (col.xtype = typ.xtype) 
	WHERE 1=1
		AND tab.type IN ('U','V')  -- 'U' for User Table, 'V' for View
		and tab.name not like 'im%'
		--and tab.name  like 'vw_%'
		--and tab.name <> 'whsebin'
		--AND tab.name like '%programid%'
		--AND col.name like '%datetime%'
	order by 1,2

----- Find Identity Columns
--select COLUMN_NAME, TABLE_NAME
--		, 'set identity_insert ' + rtrim(TABLE_NAME) + ' ON' as IDentOn
--		, 'set identity_insert ' + rtrim(TABLE_NAME) + ' OFF' as IDentOff
--	from INFORMATION_SCHEMA.COLUMNS
--	where COLUMNPROPERTY(object_id(TABLE_SCHEMA+'.'+TABLE_NAME), COLUMN_NAME, 'IsIdentity') = 1
--	order by TABLE_NAME

---- Find tables that have multiple known columns
--select * 
--	FROM sysobjects tab
--	WHERE 1=1
--		AND tab.type IN ('U')  -- 'U' for User Table, 'V' for View
--		AND exists (select * from syscolumns col where (tab.id = col.id) and col.name like '%agr%')
--		AND exists (select * from syscolumns col where (tab.id = col.id) and col.name like '%location%')
	
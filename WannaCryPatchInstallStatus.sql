 --select * from openquery(WEBW12SRV04, 'select * FROM v_Computer_Stats')
 --select * from openquery(WEBW12SRV04, 'SELECT * FROM hotfixdata WHERE kbid in (''2990214'') order by 2, 1')
 --select * from openquery(WEBW12SRV04, 'SELECT * FROM v_hotfixes WHERE kbid = ''2990214'' and Installed = 0')

IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
	drop table #tmp

select * 
into #tmp
	from openquery(WEBW12SRV04, '
SELECT DISTINCT CASE WHEN v_hotfixes.Installed = 0 AND Computers.Online = 0 THEN ''Not Installed - Offline''
			WHEN v_hotfixes.Installed = 0 AND Computers.Online = 1 THEN ''Not Installed''
			WHEN v_hotfixes.Installed = 1 AND CAST(extrafielddata.Value AS DATETIME) IS NOT NULL AND CAST(extrafielddata.Value AS DATETIME) > hotfix.Last_Date THEN ''Completed''
			ELSE ''Installed - Needs Reboot''
			END AS Install_Status
		, Computers.Client_Name, Computers.Location_Name, Computers.Computer_Name, Computers.ComputerId
		, Computers.OS_Version, Computers.Machine_Type, Computers.Online
		, Date_Format(CAST(computers.Last_Contact AS DATETIME), ''%m/%d/%Y %k:%i'') AS Last_Contact
		, LEFT(extrafielddata.Value, 16) AS Last_Reboot -- , Computers.Uptime_Hours
		, Date_Format(hotfix.Last_Date, ''%m/%d/%Y %k:%i'') as Install_Date
		, v_hotfixes.kbid, v_hotfixes.installed -- , v_hotfixes.approved, v_hotfixes.pushed
		, v_hotfixes.severity, v_hotfixes.categoryname 
		 , v_hotfixes.Title
		-- , hotfixdata.DownloadURL
		-- , Computers.Num_Patches_Missing, Computers.AV_Protection_Enabled as Av_On, Computers.Av_Version
	FROM v_hotfixes
	INNER JOIN hotfix
		ON hotfix.hotfixid = v_hotfixes.hotfixid AND hotfix.computerid = v_hotfixes.computerid
	INNER JOIN hotfixdata
		ON hotfixdata.hotfixid = v_hotfixes.hotfixid
	INNER JOIN v_Computer_Stats Computers 
		ON Computers.computerid = v_hotfixes.computerid
	LEFT JOIN extrafielddata 
		ON extrafielddata.id = v_hotfixes.computerid AND extrafielddata.ExtraFieldId = 601
	WHERE 1=1
		  and v_hotfixes.kbid IN (''4012215'', ''4012216'', ''4012598'', ''4013198'',''4019264'',''4019112'', ''4019472'')
		 -- and hotfix.computerid = 2378
')

select 
	*
	--distinct install_status, client_name, location_name, computer_name
from #tmp
where 1=1
	and install_status not in ('Completed', 'Installed - Needs Reboot', 'Not Installed - Offline')
	--and kbID not in ('4019112', '4019264')
	order by 12,1,2,3,4


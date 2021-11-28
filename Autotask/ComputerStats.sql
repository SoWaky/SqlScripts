 -- select * from openquery(WEBW12SRV04, 'select * FROM v_Computer_Stats where computerid = 2744')
 -- select * from openquery(WEBW12SRV04, 'select * from ExtraField')
 -- select * from openquery(WEBW12SRV04, 'SELECT * FROM v_hotfixes WHERE computerid = 1461 order by approved, pushed, installed, title')

IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
	drop table #tmp

select * 
into #tmp
	from openquery(WEBW12SRV04, '
SELECT DISTINCT Computers.Client_Name, Computers.Location_Name, Computers.Computer_Name, Computers.ComputerId
		, Computers.OS_Version, Computers.Machine_Type, Computers.Online
		, Date_Format(CAST(computers.Last_Contact AS DATETIME), ''%m/%d/%Y %k:%i'') AS Last_Contact
		, IFNULL(LEFT(LastReboot.Value, 16), '''') AS Last_Reboot
		, IFNULL(LastMWDate.Value,'''') as Last_MW
		, Computers.Num_Patches_Missing, Computers.AV_Protection_Enabled as Av_On, Computers.Av_Version
	FROM v_Computer_Stats Computers 
	LEFT JOIN extrafielddata LastReboot
		ON (LastReboot.id = Computers.computerid AND LastReboot.ExtraFieldId = (Select ExtraField.id FROM ExtraField WHERE LTGuid=''17f4f54e-96a0-4485-b389-aeaeb45534b1''))
	LEFT JOIN ExtraFieldData LastMWDate 
		ON (LastMWDate.id = Computers.ComputerId and LastMWDate.ExtraFieldId = (Select ExtraField.id FROM ExtraField WHERE LTGuid=''6ee8a005-1184-4331-a3d5-12a1d3f6976b''))
	WHERE 1=1
')

select *
from #tmp
where 1=1
	--and Num_Patches_Missing > 5
	--and Machine_Type = 'server'
	--and os_version like '%xp%'
	order by Machine_Type, Num_Patches_Missing desc,  1,2,3,4


------------------------------------------------------------
-- Endpoints by Client

--SELECT * 
--FROM openquery(WEBW12SRV04, '
--SELECT Client_Name as `Client`, Machine_Type as `Machine Type`, COUNT(Computers.ComputerId) as `Num_Computers`
--	FROM v_Computer_Stats Computers
--	group by Client_Name , Machine_Type
--	order by 1,2
--')


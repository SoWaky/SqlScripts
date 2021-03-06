
---- Get Active Computers from LabTech
IF OBJECT_ID('tempdb..#Computers') IS NOT NULL
	drop table #Computers

SELECT * 
into #Computers
FROM openquery(WSRMM01, '
select Clients.Name AS Client_Name, Locations.Name AS Location_Name
		, computers.computerid, computers.Name as Computer_name, computers.lastcontact
		, coalesce(computers.lastinventory, ''01/01/1900'') as lastinventory
		, CASE WHEN Computers.OS LIKE ''%server%'' THEN ''Server'' WHEN Computers.BiosFlash LIKE ''%portable%'' THEN ''Laptop'' ELSE ''WorkStation'' END AS Agent_Type
	from computers	
	INNER JOIN Clients
		ON Clients.ClientId = computers.ClientId
	INNER JOIN Locations
		ON Locations.LocationId = computers.LocationId')

-- Compare computers in Labtech to the Configs in Connectwise

SELECT LT.*, CW.*
		, CASE WHEN LT.CLient_Name IS NULL
				OR CW.Company_Id IS NULL
				OR CW.Closed_Flag = 1
				THEN 'PROBLEM'
				ELSE '' END AS Valid
	from 
	(
		select * 
			from #Computers 
	) LT
	full outer join 
	(
		select Company_Id, Config_Name, Device_Id, Ip_Address, ConfigStatus, ConfigType, Closed_Flag--, *
			from v_ConfigSearch
			INNER JOIN Company
				ON Company.Company_RecID = v_ConfigSearch.Company_RecID
			WHERE 1=1
				--AND Closed_Flag = 0
				--AND ConfigType IN ('Managed Server', 'Managed Workstation')
	) CW
	on LT.Client_Name = CW.Company_Id
		and LT.Computer_Name = CW.Config_Name
	WHERE LT.Client_Name IS NOT NULL
			OR (CW.Closed_Flag = 0 AND CW.ConfigType IN ('Managed Server', 'Managed Workstation'))
	ORDER BY 15 DESC,1,8,9,4


		--select * 
		--	from #Computers 
		--	where computer_name = 'GAITSCAN-9FE62C'
		--	order by 1,2

		--select Company_Id, Config_Name, Device_Id, Ip_Address, ConfigStatus, ConfigType, Closed_Flag, *
		--	from v_ConfigSearch
		--	INNER JOIN Company
		--		ON Company.Company_RecID = v_ConfigSearch.Company_RecID
		--	WHERE 1=1
		--	and company_id like '%jeff%'

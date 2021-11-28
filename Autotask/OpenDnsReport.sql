---- Check on the client level setup for OpenDNS (Client - Info - Open DNS tab)
IF OBJECT_ID('tempdb..#tmpClients') IS NOT NULL
	drop table #tmpClients

select * 
into #tmpClients
from openquery(WEBW12SRV04, '
SELECT DISTINCT cast(clients.name as char(100)) as `ClientName`
		, CAST(IFNULL(IFNULL(edfAssigned4.Value,edfDefault4.value),''0'') AS char(1)) as `OpenDNS_EnabledClient`		
		, IFNULL(IFNULL(edfAssigned2.Value,edfDefault2.value),'''') as `OpenDNS_Org_ID`
		, IFNULL(IFNULL(edfAssigned3.Value,edfDefault3.value),'''') as `OpenDNS_User_ID`
		, IFNULL(IFNULL(edfAssigned1.Value,edfDefault1.value),'''') as `OpenDNS_Org_Fingerprint`
	FROM Clients 
	LEFT JOIN ExtraFieldData edfAssigned1 ON (edfAssigned1.id=Clients.ClientId and edfAssigned1.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''a93e1af6-1404-11e4-b69e-00505691b09c''))
	LEFT JOIN ExtraFieldData edfDefault1 ON (edfDefault1.id=0 and edfDefault1.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''a93e1af6-1404-11e4-b69e-00505691b09c''))
	LEFT JOIN ExtraFieldData edfAssigned2 ON (edfAssigned2.id=Clients.ClientId and edfAssigned2.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''5c7c1c57-1404-11e4-b69e-00505691b09c''))
	LEFT JOIN ExtraFieldData edfDefault2 ON (edfDefault2.id=0 and edfDefault2.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''5c7c1c57-1404-11e4-b69e-00505691b09c''))
	LEFT JOIN ExtraFieldData edfAssigned3 ON (edfAssigned3.id=Clients.ClientId and edfAssigned3.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''4e246b60-1404-11e4-b69e-00505691b09c''))
	LEFT JOIN ExtraFieldData edfDefault3 ON (edfDefault3.id=0 and edfDefault3.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''4e246b60-1404-11e4-b69e-00505691b09c''))
	LEFT JOIN ExtraFieldData edfAssigned4 ON (edfAssigned4.id=Clients.ClientId and edfAssigned4.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''5bc1ac2e-5df8-11e4-a70b-00505691b09c''))
	LEFT JOIN ExtraFieldData edfDefault4 ON (edfDefault4.id=0 and edfDefault4.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''5bc1ac2e-5df8-11e4-a70b-00505691b09c''))
	ORDER BY 2,1
')


---- Get Active Computers from LabTech
IF OBJECT_ID('tempdb..#Good') IS NOT NULL
	drop table #Good

SELECT * 
into #Good
FROM openquery(WSRMM01, '
	SELECT DISTINCT Client_Name, Location_Name, Computer_Name, ComputerId
			, Machine_Type, OS_Version as `OS`, Online, Last_Contact
		FROM v_Computer_Stats Computers
		WHERE EXISTS (SELECT * FROM Services WHERE Services.ComputerID = Computers.ComputerID AND Services.`Name` LIKE ''%Umbrella_RC%'')
		ORDER BY 1,2,3,4
		')

IF OBJECT_ID('tempdb..#Bad') IS NOT NULL
	drop table #Bad

SELECT * 
into #Bad
FROM openquery(WSRMM01, '
	SELECT DISTINCT Client_Name, Location_Name, Computer_Name, Computers.ComputerId
			, Machine_Type, OS_Version as `OS`, Online, Last_Contact
		FROM v_Computer_Stats Computers
		LEFT JOIN ExtraFieldData edfAssigned5 ON (edfAssigned5.id=Computers.ComputerId and edfAssigned5.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''be0a2503-5876-11e4-a70b-00505691b09c''))
		LEFT JOIN ExtraFieldData edfDefault5 ON (edfDefault5.id=0 and edfDefault5.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''be0a2503-5876-11e4-a70b-00505691b09c''))
		WHERE 1=1
			AND NOT EXISTS (SELECT * FROM Services WHERE Services.ComputerID = Computers.ComputerID AND Services.`Name` LIKE ''%Umbrella_RC%'')
			AND Machine_Type = ''Workstation''
			AND OS_Version LIKE ''%Windows%''
			AND IFNULL(IFNULL(edfAssigned5.Value,edfDefault5.value),''0'') = ''0''
		ORDER BY 1,2,3,4
		')
		

SELECT 'GOOD'
	, (select count(distinct Client_Name) from #Good) AS Num_Clients
	, (select count(distinct Location_Name) from #Good) AS Num_Locations
	, (select count(distinct ComputerId) from #Good) AS Num_Computers

UNION
SELECT 'BAD'
	, (select count(distinct Client_Name) from #Bad) AS Num_Clients
	, (select count(distinct Location_Name) from #Bad) AS Num_Locations
	, (select count(distinct ComputerId) from #Bad) AS Num_Computers

select * from #tmpClients
--select * from #Good

select * from #Bad
	where Client_Name in (select Client_Name from #tmpClients where opendns_enabledclient = '1')
	order by Last_Contact desc, Client_Name
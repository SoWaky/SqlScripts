select * from openquery(WEBW12SRV04, '
SELECT 
   IFNULL(IFNULL(edfAssigned1.Value,edfDefault1.value),''0'') as `Computer - Client - Extra Data Field - Hot Fix - Enable Patching`,
   IFNULL(IFNULL(edfAssigned2.Value,edfDefault2.value),'''') as `Computer - Client - Extra Data Field - Hot Fix - Hot Fix Window`,
   IFNULL(IFNULL(edfAssigned3.Value,edfDefault3.value),'''') as `Computer - Client - Extra Data Field - Hot Fix - MS update time`,
   clients.name as `Client Name`, Clients.ClientId
FROM Clients
LEFT JOIN ExtraFieldData edfAssigned1 ON (edfAssigned1.id=Clients.ClientId and edfAssigned1.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''b6f99959-f9e7-11e0-8c24-a6bdbd7f43d3''))
LEFT JOIN ExtraFieldData edfDefault1 ON (edfDefault1.id=0 and edfDefault1.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''b6f99959-f9e7-11e0-8c24-a6bdbd7f43d3''))
LEFT JOIN ExtraFieldData edfAssigned2 ON (edfAssigned2.id=Clients.ClientId and edfAssigned2.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''b6f9984b-f9e7-11e0-8c24-a6bdbd7f43d3''))
LEFT JOIN ExtraFieldData edfDefault2 ON (edfDefault2.id=0 and edfDefault2.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''b6f9984b-f9e7-11e0-8c24-a6bdbd7f43d3''))
LEFT JOIN ExtraFieldData edfAssigned3 ON (edfAssigned3.id=Clients.ClientId and edfAssigned3.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''1ce7e2f8-fb5b-11e0-b921-c3e32b2c5a42''))
LEFT JOIN ExtraFieldData edfDefault3 ON (edfDefault3.id=0 and edfDefault3.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''1ce7e2f8-fb5b-11e0-b921-c3e32b2c5a42''))
order by 1,2,3
')

 ------------------------------------------------------------------------
 -- Clients\PatchingWindowThursday Search
 
select * from openquery(WEBW12SRV04, '
Select DISTINCT Computers.ComputerID, Clients.Name as `Client Name`, Computers.Name as `Computer Name`, Computers.Domain, Computers.UserName as `Username`
	, v_extradataclients.`clientid` as `v_extradataclients_clientid`, v_extradatacomputers.`No Patch Group` as `v_extradatacomputers_No Patch Group`
From Computers, Clients, v_extradataclients , v_extradatacomputers 
Where Computers.ClientID = Clients.ClientID
 and v_extradataclients.ClientID = Computers.ClientID
 and v_extradatacomputers.ComputerID = Computers.ComputerID
	 and ((v_extradataclients.`clientid` in (21,67,69,70,71,10,77)) 
	 AND (v_extradatacomputers.`No Patch Group` <> 1) 
	 AND (Computers.ComputerID <> 1761))
	 order by 6
	')

------------------------------------------------------------------------
-- Clients\PatchingWindowFriday Search

select * into #Friday from openquery(WEBW12SRV04, '
Select DISTINCT Computers.ComputerID, Clients.Name as `Client Name`, Computers.Name as `Computer Name`, Computers.Domain, Computers.UserName as `Username`, v_extradataclients.`clientid` as `v_extradataclients_clientid`, Computers.OS, v_extradatacomputers.`No Patch Group` as `v_extradatacomputers_No Patch Group`
From Computers, Clients, v_extradataclients , v_extradatacomputers 
Where Computers.ClientID = Clients.ClientID
 and v_extradataclients.ClientID = Computers.ClientID
 and v_extradatacomputers.ComputerID = Computers.ComputerID
 and ((v_extradataclients.`clientid` in (72, 9, 6, 38, 16, 42, 17, 4, 12, 13, 51, 8, 7, 3, 56, 35, 55, 18, 63, 25, 19, 57, 23, 45, 24, 65, 75, 76)) 
 AND (Computers.OS like ''%Windows%'') 
 AND (v_extradatacomputers.`No Patch Group` <> 1))
	  order by 6
	')

select * from #Friday
select distinct [Client Name] from #Friday

 ------------------------------------------------------------------------
 -- Clients\PatchingWindowSaturday Search
 
 select * into #Saturday from openquery(WEBW12SRV04, '
Select DISTINCT Computers.ComputerID, Clients.Name as `Client Name`, Computers.Name as `Computer Name`, Computers.Domain, Computers.UserName as `Username`, v_extradataclients.`clientid` as `v_extradataclients_clientid`, Computers.OS, v_extradatacomputers.`No Patch Group` as `v_extradatacomputers_No Patch Group`
From Computers, Clients, v_extradataclients , v_extradatacomputers 
Where Computers.ClientID = Clients.ClientID
 and v_extradataclients.ClientID = Computers.ClientID
 and v_extradatacomputers.ComputerID = Computers.ComputerID
 and ((v_extradataclients.`clientid` in (64, 53, 15, 54, 73, 68, 78, 76)) 
 AND (Computers.OS like ''%Windows%'') 
 AND (v_extradatacomputers.`No Patch Group` <> 1))
	  order by 6
	')

select * from #Saturday
select distinct [Client Name] from #Saturday



------------------------------------------------------------------------
-- New way to do Search: Clients\PatchingWindowFriday Search

drop table #NewSearch
select * into #NewSearch from openquery(WEBW12SRV04, '
SELECT 
   computers.computerid as `Computer Id`,
   computers.name as `Computer Name`,
   clients.name as `Client Name`,
   computers.domain as `Computer Domain`,
   computers.username as `Computer User`,
   IFNULL(IFNULL(edfAssigned1.Value,edfDefault1.value),''0'') as `Computer - Client - Extra Data Field - Hot Fix - Enable Patching`,
   IFNULL(IFNULL(edfAssigned2.Value,edfDefault2.value),'''') as `Computer - Client - Extra Data Field - Hot Fix - Hot Fix Window`,
   IFNULL(IFNULL(edfAssigned3.Value,edfDefault3.value),''0'') as `Computer - Extra Data Field - Exclusions - No Patch Group`,
   Clients.Name as `Computer.Client.General.Name`
FROM Computers 
LEFT JOIN inv_operatingsystem ON (Computers.ComputerId=inv_operatingsystem.ComputerId)
LEFT JOIN Clients ON (Computers.ClientId=Clients.ClientId)
LEFT JOIN Locations ON (Computers.LocationId=Locations.LocationID)
LEFT JOIN ExtraFieldData edfAssigned1 ON (edfAssigned1.id=Clients.ClientId and edfAssigned1.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''b6f99959-f9e7-11e0-8c24-a6bdbd7f43d3''))
LEFT JOIN ExtraFieldData edfDefault1 ON (edfDefault1.id=0 and edfDefault1.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''b6f99959-f9e7-11e0-8c24-a6bdbd7f43d3''))
LEFT JOIN ExtraFieldData edfAssigned2 ON (edfAssigned2.id=Clients.ClientId and edfAssigned2.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''b6f9984b-f9e7-11e0-8c24-a6bdbd7f43d3''))
LEFT JOIN ExtraFieldData edfDefault2 ON (edfDefault2.id=0 and edfDefault2.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''b6f9984b-f9e7-11e0-8c24-a6bdbd7f43d3''))
LEFT JOIN ExtraFieldData edfAssigned3 ON (edfAssigned3.id=Computers.ComputerId and edfAssigned3.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''f435856b-a55b-11e3-9d2f-00155d0a0300''))
LEFT JOIN ExtraFieldData edfDefault3 ON (edfDefault3.id=0 and edfDefault3.ExtraFieldId =(Select ExtraField.id FROM ExtraField WHERE LTGuid=''f435856b-a55b-11e3-9d2f-00155d0a0300''))
 WHERE 
((((IFNULL(IFNULL(edfAssigned1.Value,edfDefault1.value),''0'')<>0) 
AND (IFNULL(IFNULL(edfAssigned2.Value,edfDefault2.value),'''') = ''Sunday'') 
AND (IFNULL(IFNULL(edfAssigned3.Value,edfDefault3.value),''0'')=0) 
AND (Clients.Name <> ''95 Webit''))))

')

select distinct [client name] from #NewSearch
select * from #NewSearch

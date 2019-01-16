-- Get all computers that are in this MW and still online
select * FROM openquery(WEBW12SRV04, '
SELECT    computers.computerid as `Computer Id`,   computers.name as `Computer Name`,   clients.name as `Client Name`,   location_name,
   computers.domain as `Computer Domain`,   computers.username as `Computer User`,   Num_Patches_missing, Online, OS_Version, AV_Version
FROM Computers 
inner join v_Computer_Stats on v_Computer_Stats.computerid = computers.computerid
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
AND (IFNULL(IFNULL(edfAssigned3.Value,edfDefault3.value),''0'')=0) 
AND (Clients.Name <> ''95 Webit'')
AND (Computers.Name <> ''EXCELMSO-UMQM''))))
AND (IFNULL(IFNULL(edfAssigned2.Value,edfDefault2.value),'''') = ''Friday'') 
and online = 1
order by 7 desc,3,4,5
')
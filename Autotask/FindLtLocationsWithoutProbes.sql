SELECT * FROM openquery(WEBW12SRV04, '
SELECT clients.name as `Client Name`
   , Locations.Name as `Location Name`
   ,(select count(*) 
		from Computers 
		where (Computers.ClientId=Clients.ClientId)
		and Computers.LocationId = Locations.LocationID 
		and (Computers.flags & 128) <> 0
		) as `NumProbes`
FROM Clients 
LEFT JOIN Locations ON (Locations.ClientId = Clients.ClientID)
order by 3,1,2
')

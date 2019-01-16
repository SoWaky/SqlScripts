IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
	drop table #Temp

SELECT *    
	--INTO #Temp
FROM openquery(WSRMM01, '

SELECT clients.Name AS ClientName, locations.Name AS Location, locations.address, h_locationstats.*-- , locations.* 
	FROM h_locationstats 
	LEFT JOIN locations ON locations.LocationId = h_locationstats.LocationId
	LEFT JOIN clients ON clients.ClientId = locations.ClientId
	WHERE StatDate = (SELECT MAX(StatDate) 
				FROM h_locationstats l2
				WHERE l2.locationId = h_locationstats.locationId)
	-- clients.Name LIKE ''%360%''
	ORDER BY ProbeEnabled, 1, 2

')
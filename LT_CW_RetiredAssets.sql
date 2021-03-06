---- Get Retired Assets from LabTech

IF OBJECT_ID('tempdb..#Retired') IS NOT NULL
	DROP TABLE #Retired

SELECT * 
	INTO #Retired
	FROM openquery(WSRMM01, '
	SELECT Clients.Name AS Client_Name, RetiredAssets.Name AS Asset_Name, Locations.Name AS Location_Name, RetiredAssets.ID AS Asset_Id
		, RetiredAssets.LocalAddress, RetiredAssets.RetiredDate
	FROM RetiredAssets
	INNER JOIN Clients
		ON Clients.ClientId = RetiredAssets.ClientId
	INNER JOIN Locations
		ON Locations.LocationId = RetiredAssets.LocationId
		')


--SELECT * FROM #Retired

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

--select * from #Computers order by 1,4

---- Get Active Endpoints from Connectwise that are in the RetiredAssets table but not the active computers table

---- Analysis
--select Company.Company_Id, Company.Company_Name, Config.Config_Name, Config.Device_ID, Config.IP_Address, Config_Status.Description AS CW_Status
--		, Retired.*
--		, Computers.*
--		, Config.*
--	from Config 
--	INNER JOIN Company
--		ON Company.Company_RecID = Config.Company_RecID
--	INNER JOIN Config_Status
--		on Config_Status.Config_Status_RecID = Config.Config_Status_RecID
--	LEFT JOIN #Retired Retired
--		on 1=1
--		AND Retired.Client_Name = Company.Company_Id
--		AND Retired.Asset_Name = Config.Config_Name
--		--AND Retired.Asset_Id = CASE WHEN Config.Device_ID LIKE '%,%' 
--		--					THEN SUBSTRING(Config.Device_ID, charindex(',', Config.Device_ID) + 1, LEN(Config.Device_ID))
--		--					ELSE Config.Device_ID
--		--					END
--	left join #Computers Computers
--		on 1=1
--		AND Computers.Client_Name = Company.Company_Id
--		AND Computers.Computer_name = Config.Config_Name
--	WHERE 1=1
--		AND Retired.RetiredDate IS NOT NULL
--		--AND Config_Status.Description <> 'Inactive'
--	ORDER BY 1,2,3


-- Get distinct list of endpoints to update on CW
IF OBJECT_ID('dbo.tmpConfigsToRetire') IS NOT NULL
	DROP TABLE dbo.tmpConfigsToRetire

select distinct Company.Company_Id, Company.Company_Name, Config.Config_Name, Config.Config_RecID
	INTO dbo.tmpConfigsToRetire
	from Config 
	INNER JOIN Company
		ON Company.Company_RecID = Config.Company_RecID
	INNER JOIN Config_Status
		on Config_Status.Config_Status_RecID = Config.Config_Status_RecID
	LEFT JOIN #Retired Retired
		on 1=1
		AND Retired.Client_Name = Company.Company_Id
		AND Retired.Asset_Name = Config.Config_Name
	left join #Computers Computers
		on 1=1
		AND Computers.Client_Name = Company.Company_Id
		AND Computers.Computer_name = Config.Config_Name
	WHERE 1=1
		AND Retired.RetiredDate IS NOT NULL
		AND Config_Status.Description <> 'Inactive'
		AND Computers.Computer_Name is null
	ORDER BY 1,2,3



-- Update the endpoint configs in Connectwise. Set them to Inactive
IF (SELECT COUNT(*) FROM dbo.tmpConfigsToRetire) > 0
BEGIN
	PRINT 'Updating configs as retired...'

	BEGIN TRAN
		SELECT * FROM dbo.tmpConfigsToRetire

		Update Config
			SET Last_Update = GETDATE(), Updated_By = 'Webit_Job', Config_Status_RecID = '3'	-- Inactive
			WHERE Config_RecID IN (SELECT Config_RecID FROM dbo.tmpConfigsToRetire)
	COMMIT

EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'Reflexion',  
    @recipients = 'techs@webitservices.com;mprice@webitservices.com',  
    @body = 'These Configurations were deactivated in Connectwise.',  
    @subject = 'Deactivated Connectwise Configurations',
	@query = N'SELECT * FROM cwwebapp_webit.dbo.tmpConfigsToRetire',
	@attach_query_result_as_file = 0;

END


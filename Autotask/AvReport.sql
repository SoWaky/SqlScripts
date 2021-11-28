-- select * FROM openquery(WEBW12SRV04, 'select * from VirusScanners where name like ''%sophos%'' order by 2')
-- select * from openquery(WEBW12SRV04, 'select * from v_Computer_Stats where Num_Patches_missing > 5 order by Num_Patches_missing desc')

---- Get Active Computers from LabTech
IF OBJECT_ID('tempdb..#AV') IS NOT NULL
	drop table #AV

SELECT * 
into #AV
FROM openquery(WEBW12SRV04, '
SELECT DISTINCT Client_Name, Location_Name, Computer_Name, Computers.ComputerId as compId
		-- , v_extradataclients.`HIPAA Indicator` AS `HIPAA`
		, (SELECT COUNT(*) FROM Software WHERE Software.ComputerID = Computers.ComputerID AND (Software.`Name` like ''%sophos endpoint%'' or Software.`Name` like ''%sophos anti%'')) `HasSophos`
		, (SELECT COUNT(*) FROM Software WHERE Software.ComputerID = Computers.ComputerID AND (Software.`Name` like ''%ESET%'' or Software.`Name` like ''%NOD32%'')) `HasEset`		
		, case when EXISTS (SELECT * FROM Services WHERE Services.ComputerID = Computers.ComputerID AND Services.`Name` LIKE ''%Umbrella_RC%'') then ''1'' else ''0'' end As `HasOpenDns`
		, Machine_Type, AV_Version AS AvName, AV_Protection_Enabled
		, Computers.OS_Version as `OS`, Online, Last_Contact
		, cast(v_extradatacomputers.`Exclude from Anti-Virus` as char(1)) as `ExcludeAV`
	FROM v_Computer_Stats Computers
	INNER JOIN v_extradatacomputers ON v_extradatacomputers.ComputerID = Computers.ComputerID
	INNER JOIN v_extradataclients on v_extradataclients.ClientId = Computers.ClientId
	ORDER BY 1,2,3,4,5,6;
')

-- TODO:
-- Get list of endpoints for HIPAA clients


select case when (HasSophos = 0 and HasEset = 0) then 'False' else 'True' end as HasHostedAv, Count(*) as NumComp
	from #AV
	group by case when (HasSophos = 0 and HasEset = 0) then 'False' else 'True' end

select AvName, Count(*)
	from #AV
	group by AvName
	order by 1,2

select *
	from #AV 
	where 1=1
	--and lastinventory = '2017-04-04'
	--and clientname in ('10 ExtractorCorp', '10 Medallion', '10 SMC')
	--and Computer_Name not like '%bdr%'
	and HasSophos = 0-- and HasEset = 0
	and ExcludeAV <> '1'
	--and AV_Protection_Enabled = 0
	--and Machine_Type = 'server'
	order by 12 desc, 1,8


select
	 (select count(*)
		from #AV 
		where Machine_Type = 'Workstation'
		AND AV_Protection_Enabled = 'True') AS Wks_Has_Av

	, (select count(*)
		from #AV 
		where Machine_Type = 'Workstation'
		AND AV_Protection_Enabled = 'False') AS Wks_Has_No_Av

	, (select count(*)
		from #AV 
		where Machine_Type = 'Workstation'
		AND HasSophos = '1') AS Wks_Has_Sophos

	, (select count(*)
		from #AV 
		where Machine_Type = 'Workstation'
		AND HasSophos <> '1') AS Wks_No_Sophos

	, (select count(*)
		from #AV 
		where Machine_Type = 'Workstation') AS Total_Wks
--------------------------------------------------
	, (select count(*)
		from #AV 
		where Machine_Type = 'Server'
		AND AV_Protection_Enabled = 'True'
		AND NOT (Computer_Name like '%BDR%' or Computer_Name like '%backup%')		
		) AS Srv_Has_Av
	, (select count(*)
		from #AV 
		where Machine_Type = 'Server'
		AND AV_Protection_Enabled = 'False'
		AND NOT (Computer_Name like '%BDR%' or Computer_Name like '%backup%')		
		) AS Srv_Has_No_Av

	, (select count(*)
		from #AV 
		where Machine_Type = 'Server'
		AND HasSophos = '1'
		AND NOT (Computer_Name like '%BDR%' or Computer_Name like '%backup%')		
		) AS Srv_Has_Sophos

	, (select count(*)
		from #AV 
		where Machine_Type = 'Server'
		AND HasSophos <> '1'
		AND NOT (Computer_Name like '%BDR%' or Computer_Name like '%backup%')
		) AS SRV_No_Sophos

	, (select count(*)
		from #AV 
		where Machine_Type = 'Server'
		AND NOT (Computer_Name like '%BDR%' or Computer_Name like '%backup%')) AS Total_Srv
--------------------------------------------------------
	, (select count(*)
		from #AV 
		where Machine_Type = 'Server'
		AND AV_Protection_Enabled = 'True'
		AND (Computer_Name like '%BDR%' or Computer_Name like '%backup%')
		) AS BDR_Has_Av

	, (select count(*)
		from #AV 
		where Machine_Type = 'Server'
		AND AV_Protection_Enabled = 'False'
		AND (Computer_Name like '%BDR%' or Computer_Name like '%backup%')
		) AS BDR_Has_No_Av

	, (select count(*)
		from #AV 
		where Machine_Type = 'Server'
		AND HasSophos = '1'
		AND (Computer_Name like '%BDR%' or Computer_Name like '%backup%')
		) AS BDR_Has_Sophos

	, (select count(*)
		from #AV 
		where Machine_Type = 'Server'
		AND HasSophos <> '1'
		AND (Computer_Name like '%BDR%' or Computer_Name like '%backup%')
		) AS BDR_No_Sophos

	, (select count(*)
		from #AV 
		where Machine_Type = 'Server'
		AND (Computer_Name like '%BDR%' or Computer_Name like '%backup%')) AS Total_BDR



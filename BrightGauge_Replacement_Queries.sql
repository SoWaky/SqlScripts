-----------------------------------------------------
---- Test

--IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
--	drop table #Temp

--SELECT *    
--FROM openquery(WEBW12SRV04, '
--SELECT *
--	FROM v_Computer_Stats c
--	where online=1
--')

-----------------------------------------------------
-- Get Computer counts from Labtech and Connectwise

SELECT 'Connectwise' AS ConfigSrc
	, (SELECT COUNT(*)
			FROM v_ConfigSearch WITH (NOLOCK)
			WHERE ConfigType = 'Managed Workstation') AS [Workstations]			
	, (SELECT COUNT(*)
			FROM v_ConfigSearch WITH (NOLOCK)
			WHERE ConfigType = 'Managed Server') AS [Servers]
UNION
SELECT ConfigSrc, [Workstations], [Servers]
	FROM openquery(WEBW12SRV04, '
SELECT ''LabTech'' AS ConfigSrc
	, (SELECT COUNT(*) AS Workstations
		FROM computers c
		WHERE LOCATE(''server'',LOWER(c.os)) = 0) AS Workstations
	, (SELECT COUNT(*) AS Servers
		FROM computers c
		WHERE LOCATE(''server'',LOWER(c.os)) > 0) AS Servers
')
ORDER BY 1 DESC


-----------------------------------------------------
-- Get Patch Stats
SELECT *    
FROM openquery(WEBW12SRV04, '
SELECT Machine_Type, Num_Computers, (Num_Unpatched / Num_Computers) as Unpatched_Pct, (Num_Patched / Num_Computers) as Patched_Pct
	FROM (
			SELECT Machine_Type
					, SUM(CASE WHEN Num_Patches_Missing > 0 THEN 1 ELSE 0 END) as Num_Unpatched
					, SUM(CASE WHEN Num_Patches_Missing > 0 THEN 0 ELSE 1 END) as Num_Patched
					, COUNT(*) AS Num_Computers
				FROM v_Computer_Stats		
				where online=1
				GROUP BY Machine_Type
		) Stats
UNION
SELECT ''ALL'' as Machine_Type, Num_Computers, (Num_Unpatched / Num_Computers) as Unpatched_Pct, (Num_Patched / Num_Computers) as Patched_Pct
	FROM (
			SELECT SUM(CASE WHEN Num_Patches_Missing > 0 THEN 1 ELSE 0 END) as Num_Unpatched
					, SUM(CASE WHEN Num_Patches_Missing > 0 THEN 0 ELSE 1 END) as Num_Patched
					, COUNT(*) AS Num_Computers
				FROM v_Computer_Stats
				where online=1
		) Stats
')


-----------------------------------------------------
-- Get AV Installed Stats
SELECT *    
FROM openquery(WEBW12SRV04, '
SELECT Machine_Type, Num_Computers, Num_Missing_AV, (Num_Missing_AV / Num_Computers) AS Missing_AV_Pct, (Num_Has_AV / Num_Computers) AS Has_AV_Pct
	FROM (
			SELECT Machine_Type
					, SUM(CASE WHEN AV_Protection_Enabled = ''False'' THEN 1 ELSE 0 END) AS Num_Missing_AV
					, SUM(CASE WHEN AV_Protection_Enabled = ''False'' THEN 0 ELSE 1 END) AS Num_Has_AV
					, COUNT(*) AS Num_Computers
				FROM v_Computer_Stats
				where online=1
				GROUP BY Machine_Type
		) Stats
UNION
SELECT ''ALL'' as Machine_Type, Num_Computers, Num_Missing_AV, (Num_Missing_AV / Num_Computers) AS Missing_AV_Pct, (Num_Has_AV / Num_Computers) AS Has_AV_Pct
	FROM (
			SELECT SUM(CASE WHEN AV_Protection_Enabled = ''False'' THEN 1 ELSE 0 END) AS Num_Missing_AV
					, SUM(CASE WHEN AV_Protection_Enabled = ''False'' THEN 0 ELSE 1 END) AS Num_Has_AV
					, COUNT(*) AS Num_Computers
				FROM v_Computer_Stats
				where online=1
		) Stats
')


-----------------------------------------------------
-- Get AV Up to Date Stats
SELECT *    
FROM openquery(WEBW12SRV04, '
SELECT Machine_Type, Num_Computers, Num_Out_Of_Date_AV, (Num_Out_Of_Date_AV / Num_Computers) AS Out_Of_Date_AV_Pct, (Num_Up_To_Date_AV / Num_Computers) AS Up_To_Date_AV_Pct
	FROM (
			SELECT Machine_Type
					, SUM(CASE WHEN (AV_Last_Update_Time IS NULL OR AV_Last_Update_Time < DATE_ADD(NOW(), INTERVAL -14 DAY)) THEN 1 ELSE 0 END) AS Num_Out_Of_Date_AV
					, SUM(CASE WHEN (AV_Last_Update_Time IS NULL OR AV_Last_Update_Time < DATE_ADD(NOW(), INTERVAL -14 DAY)) THEN 0 ELSE 1 END) AS Num_Up_To_Date_AV
					, COUNT(*) AS Num_Computers
				FROM v_Computer_Stats
				WHERE AV_Protection_Enabled = ''True''
				and online=1
				GROUP BY Machine_Type
		) Stats
UNION
SELECT ''ALL'' as Machine_Type, Num_Computers, Num_Out_Of_Date_AV, (Num_Out_Of_Date_AV / Num_Computers) AS Out_Of_Date_AV_Pct, (Num_Up_To_Date_AV / Num_Computers) AS Up_To_Date_AV_Pct
	FROM (
			SELECT SUM(CASE WHEN (AV_Last_Update_Time IS NULL OR AV_Last_Update_Time < DATE_ADD(NOW(), INTERVAL -14 DAY)) THEN 1 ELSE 0 END) AS Num_Out_Of_Date_AV
					, SUM(CASE WHEN (AV_Last_Update_Time IS NULL OR AV_Last_Update_Time < DATE_ADD(NOW(), INTERVAL -14 DAY)) THEN 0 ELSE 1 END) AS Num_Up_To_Date_AV
					, COUNT(*) AS Num_Computers
				FROM v_Computer_Stats
				WHERE AV_Protection_Enabled = ''True''
				and online=1
		) Stats
')

-----------------------------
-- Backup Health

SELECT *    
FROM openquery(WEBW12SRV04, '
SELECT Machine_Type
		, SUM(CASE WHEN Backup_Status = ''3. Good'' THEN 1 ELSE 0 END) AS Num_Backups_Good
		, SUM(CASE WHEN Backup_Status <> ''3. Good'' THEN 1 ELSE 0 END) AS Num_Backups_Bad
		, COUNT(*) AS Num_Computers
	FROM 
(
SELECT CONCAT(hc.clientid,hc.computerid) AS id
	,c.name AS Client_Name 
	,hc.ComputerID	
	,comp.name AS Machine_Name
	,l.name AS Location_Name
	,CONCAT(c.name,'' - '',l.name) AS client_and_location
	, Machine_Type
	,CAST(MAX(hc.CheckDate) AS DATETIME) AS  Check_Date	
	,IF(hc.BackupHealth=0,NULL,hc.BackupHealth/100) AS Backup_Health	 
	,hc.BackupResults  AS Backup_Notes
	,CASE WHEN hc.BackupHealth >= 7500 THEN ''3. Good''
			WHEN hc.BackupHealth >= 5000 THEN ''2. Warning''
			WHEN hc.BackupHealth >= 1 THEN ''1. Alert''
			ELSE ''O. No Score''
			END AS Backup_Status
	FROM (SELECT c.ClientID AS ClientID
			,c.ComputerID AS ComputerID
			, IF((LOCATE(''server'',LOWER(c.os)) = 0), ''Workstation'', ''Server'') AS Machine_Type
			,es.EventDate AS CheckDate
			,IF((LENGTH(es.Stat1) < 1),NULL,ROUND((LEFT(es.Stat1,4) * 100),0)) AS BackupHealth
			,REPLACE(es.Stat1,LEFT(es.Stat1,5),'''') AS BackupResults 
		FROM (computers c 
				JOIN (SELECT h.ComputerID AS ComputerID
							,h.Stat1 AS Stat1
							,h.Stat14 AS Stat14
							,h.EventDate AS EventDate 
						FROM h_extrastats h
						LEFT JOIN drives d1 ON d1.computerid = h.computerid
						WHERE d1.size > 0
						GROUP BY h.computerid
					UNION 
					SELECT 
							hd.ComputerID AS ComputerID
							,hd.Stat1 AS Stat1
							,hd.Stat14 AS Stat14
							,hd.EventDate AS EventDate 
						FROM h_extrastatsdaily hd
						LEFT JOIN drives d2 ON d2.computerid = hd.computerid
						WHERE d2.size > 0
						GROUP BY hd.computerid) es 
				ON((c.ComputerID = es.ComputerID))
			) 
		WHERE (es.Stat14 <> ''-1'')
		) hc
	INNER JOIN clients c ON hc.clientid = c.clientid
	INNER JOIN computers comp ON comp.ComputerID = hc.ComputerID
	LEFT JOIN locations l ON l.locationid = comp.locationid
	GROUP BY CONCAT(hc.clientid,hc.computerid)
) Stats
GROUP BY Machine_Type
')

	--where 1=1
	--and [online] = 0
	--and ComputerId  IN (2182,2927,2930,2935,2966,2743,3070,3032,3203,3226,689,1983,2771,587)

-- For Servers Offline gauge, Chad added this filter:  computers.ComputerId NOT IN (2182,2927,2930,2935,2966,2743,3070,3032,3203,3226,689,1983,2771,587)


--SELECT `Disable Alerting`, computerid
--	FROM v_extradatacomputers
--	WHERE `Disable Alerting` = '1'
--	LIMIT 0,100;

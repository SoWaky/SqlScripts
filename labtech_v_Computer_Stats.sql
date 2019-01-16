USE labtech;

DROP VIEW IF EXISTS v_computer_patches_missing;

CREATE VIEW v_computer_patches_missing
AS 
SELECT ComputerID, COUNT(*) AS patches_missing 
	FROM v_hotfixes 
	WHERE Approved = 1 
		AND Installed = 0 
	GROUP BY ComputerID
	;
		    
		    
DROP VIEW IF EXISTS v_Computer_Stats;

CREATE VIEW v_Computer_Stats
AS
SELECT 
		c.ComputerID
		, c.name AS Computer_Name
		, clients.name AS Client_Name
		, locations.name AS Location_Name
		, IF((LOCATE('server',LOWER(c.os)) = 0), 'Workstation', 'Server') AS Machine_Type
		, CASE WHEN c.OS LIKE '%server%' THEN 'Server' 
			WHEN c.BiosFlash LIKE '%portable%' OR c.BiosFlash LIKE '%book%'  THEN 'Laptop' 
			ELSE 'WorkStation' 
			END AS Agent_Type
		, CAST(c.Assetdate AS DATE)  AS Asset_Date
		, CAST(FORMAT(ROUND(c.TotalMemory/512)/2,1) AS DECIMAL(10,1)) AS Total_Memory
		, p.Name AS CPU
		, d.Letter AS Main_Drive
		, d.Free AS Main_Drive_Size_Free
		, d.Size AS Main_Drive_Size_Total
		, c.BiosVer AS Serial_Number
		, ROUND(DATEDIFF(CURDATE(),DATE_FORMAT(c.Assetdate, '%Y-%m-%d'))/365, 2) AS Age_in_Years
		, CAST(c.lastcontact AS DATETIME) AS Last_Checked_In
		, c.LastUsername AS Last_User
		, c.BiosName AS Model
		, c.os AS OS_Version
		, c.BiosMFG AS Manufacturer
		, IF(c.lastcontact > (NOW() - INTERVAL 15 MINUTE), 1, 0) AS Online
		, CASE
			WHEN COALESCE(pm.patches_missing, 0) > 4 THEN '>5 Missing'
			WHEN COALESCE(pm.patches_missing, 0) > 2 THEN '3-4 Missing'
			WHEN COALESCE(pm.patches_missing, 0) > 0 THEN '1-2 Missing'
			ELSE 'Full'
			END AS Patch_Status
		, c.lastcontact AS Last_Contact
		, RTRIM(CAST(TIMEDIFF(NOW(), c.LastContact) AS CHAR(20))) AS HHMMSS_Since_Contact
		, CAST(c.uptime / 60.0 AS DECIMAL(10,2)) AS Uptime_Hours
		, CAST(COALESCE(pm.patches_missing, 0) AS DECIMAL) AS Num_Patches_Missing
		, CASE
			WHEN (c.virusap = 1 AND DATEDIFF(c.lastcontact,c.virusdefs) < 14) THEN 'Up to Date'			
			WHEN (c.virusap = 1 AND DATEDIFF(c.lastcontact,c.virusdefs) >= 14) THEN 'Out of Date'
			WHEN (vs.name <> '') THEN 'Not Enabled'
			ELSE 'Not Installed'
			END AS AV_Status
		, IF(c.virusap,'True','False') AS AV_Protection_Enabled
		, CAST(c.virusdefs AS DATETIME) AS AV_Last_Update_Time
		, vs.name AS AV_Version
		, COALESCE(c.warrantyend, '01/01/1900') AS Warranty_End
		, ex.`Disable Alerting` AS Disable_Alerting
		, clients.ClientID, locations.LocationId
	FROM drives d
	INNER JOIN computers c ON d.computerid = c.computerid
	INNER JOIN clients ON c.clientid = clients.clientid
	LEFT JOIN virusscanners vs ON c.virusscanner = vs.vscanid
	LEFT JOIN locations ON locations.locationid = c.locationid
	LEFT JOIN v_processors p ON p.computerid = c.computerid
	LEFT JOIN v_extradatacomputers ex ON ex.computerid = c.computerid
	LEFT JOIN v_computer_patches_missing pm ON c.computerid = pm.computerid
	WHERE d.size > 0
	GROUP BY d.computerid  
	;
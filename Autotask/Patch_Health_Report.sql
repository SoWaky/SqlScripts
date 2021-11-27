
-- Run these queries in the labtech database on WEBW12SRv04

DROP TABLE IF EXISTS tmpHotFix ;

CREATE TEMPORARY TABLE IF NOT EXISTS tmpHotFix AS (
	SELECT DISTINCT ComputerId, Severity, CategoryName, Approved, KbId, Installed
		, CASE WHEN Severity = 'Critical' OR CategoryName = 'Critical Updates' THEN 'Critical'
			WHEN Severity IN ('Important', 'Moderate') OR CategoryName = 'Security Updates' THEN 'Elevated'
			ELSE 'Standard' END AS Patch_Importance
		FROM HotFix
		INNER JOIN HotFixData ON HotFix.HotFixId = HotFixData.HotFixId);

/*			
DROP TABLE IF EXISTS tmpPatchScores ;
			
CREATE TEMPORARY TABLE IF NOT EXISTS tmpPatchScores AS (
	SELECT clients.Name AS Client_Name, Patch_Importance
		, SUM(HotFix.Installed = 1) AS Num_Installed
		, COUNT(*) AS Num_Patches
		, (SUM(HotFix.Installed = 1) / COUNT(*)) AS Patch_Score
		, ((SUM(HotFix.Installed = 1) / COUNT(*)) * CASE WHEN Patch_Importance = 'Critical' THEN 75
								WHEN Patch_Importance = 'Elevated' THEN 20
								ELSE 5 END) AS  Weighted_Patch_Score
	FROM Computers
	INNER JOIN clients ON computers.clientid = clients.clientid
	INNER JOIN tmpHotFix HotFix ON HotFix.ComputerId = Computers.ComputerId
	WHERE 1=1
		AND HotFix.Approved = 1
	--	AND DATEDIFF(CURRENT_DATE, Computers.LastContact) < 14
	--	AND Clients.Name = '10 Bobdavidsondds'
	GROUP BY clients.Name, Patch_Importance
);


SELECT CAST(SUM(Weighted_Patch_Score) / 100 AS DECIMAL(20,4)) AS Patch_Score
	FROM tmpPatchScores;
	
-- SELECT * FROM tmpPatchScores;


SELECT Client_Name, CAST(SUM(Weighted_Patch_Score) / 100 AS DECIMAL(20,4)) AS Patch_Score
	FROM tmpPatchScores
	GROUP BY Client_Name
	ORDER BY Patch_Score, Client_Name;
	
*/
---------------------------------------------------------------------------

DROP TABLE IF EXISTS tmpComputerPatchScore ;
			
CREATE TEMPORARY TABLE IF NOT EXISTS tmpComputerPatchScore AS (
	SELECT Client_Name AS `Client`, Location_Name AS `Location`, Computer_Name AS `Computer`
		, Computers.Num_Patches_Missing AS `Missing Patches`, LEFT(Last_Contact, 10) AS `Last Contact`
		, Patch_Importance
		, SUM(HotFix.Installed = 1) AS Num_Installed
		, COUNT(*) AS Num_Patches
		, (SUM(HotFix.Installed = 1) / COUNT(*)) AS Patch_Score
		, ((SUM(HotFix.Installed = 1) / COUNT(*)) * CASE WHEN Patch_Importance = 'Critical' THEN 75
								WHEN Patch_Importance = 'Elevated' THEN 20
								ELSE 5 END) AS  Weighted_Patch_Score
	FROM v_Computer_Stats Computers
	INNER JOIN tmpHotFix HotFix ON HotFix.ComputerId = Computers.ComputerId
	WHERE 1=1
		AND HotFix.Approved = 1
	--	AND DATEDIFF(CURRENT_DATE, Computers.LastContact) < 14
	--	AND Clients.Name = '10 Bobdavidsondds'
	GROUP BY Client_Name, Location_Name, Computer_Name
		, Computers.Num_Patches_Missing, LEFT(Last_Contact, 10)
		, Patch_Importance
);

-- SELECT * 
-- 	FROM tmpComputerPatchScore
-- 	where `client` = '10 AdvancedCompressor'
--	ORDER BY 1,2,3;

SELECT `Client`, `Location`, `Computer`, `Missing Patches`, `Last Contact`, CAST(SUM(Weighted_Patch_Score) / 100 AS DECIMAL(20,4)) AS Patch_Score
	FROM tmpComputerPatchScore
	WHERE 1=1
		-- and `CLIENT` = '10 AdvancedCompressor'
	GROUP BY `Client`, `Location`, `Computer`, `Missing Patches`, `Last Contact`
	HAVING CAST(SUM(Weighted_Patch_Score) / 100 AS DECIMAL(20,4)) < 0.90
	ORDER BY Patch_Score, `Client`, `Location`, `Computer`;



SELECT Client_Name, CAST(SUM(Weighted_Patch_Score) / 100 AS DECIMAL(20,4)) AS Patch_Score
	FROM tmpPatchScores
	GROUP BY Client_Name
	ORDER BY Patch_Score, Client_Name;

/*
-----------------------------------------------------------------------------------------
-- All patches for all computers

SELECT Computers.Client_Name	, Computers.Location_Name	, Computers.Computer_Name	, Patch_Importance	, HotFix.*
FROM v_Computer_Stats Computers
INNER JOIN tmpHotFix HotFix ON HotFix.ComputerId = Computers.ComputerId
WHERE 1=1
	AND (HotFix.Approved = 1 OR HotFix.Installed = 1)
--	AND DATEDIFF(CURRENT_DATE, Computers.Last_Checked_In) < 14
	-- AND Client_Name = '10 Bobdavidsondds'
	-- AND computer_name = 'BDDW07BDR01'
ORDER BY 1,2,3,4
;
*/

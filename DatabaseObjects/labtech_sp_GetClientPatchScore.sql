DROP PROCEDURE IF EXISTS `labtech`.`sp_GetClientPatchScore`;

DELIMITER $$

CREATE
    /*[DEFINER = { user | CURRENT_USER }]*/
    PROCEDURE `labtech`.`sp_GetClientPatchScore`()
    /*LANGUAGE SQL
    | [NOT] DETERMINISTIC
    | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
    | SQL SECURITY { DEFINER | INVOKER }
    | COMMENT 'string'*/
	BEGIN

-- DROP TABLE IF EXISTS tmpHotFix ;

CREATE TEMPORARY TABLE IF NOT EXISTS tmpHotFix AS (
	SELECT DISTINCT ComputerId, Severity, CategoryName, Approved, KbId, Installed
		, CASE WHEN Severity = 'Critical' OR CategoryName = 'Critical Updates' THEN 'Critical'
			WHEN Severity IN ('Important', 'Moderate') OR CategoryName = 'Security Updates' THEN 'Elevated'
			ELSE 'Standard' END AS Patch_Importance
		FROM HotFix
		INNER JOIN HotFixData ON HotFix.HotFixId = HotFixData.HotFixId);
			
-- DROP TABLE IF EXISTS tmpPatchScores ;
			
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
		AND DATEDIFF(CURRENT_DATE, Computers.LastContact) < 14
	GROUP BY clients.Name, Patch_Importance
);

SELECT Client_Name, CAST(SUM(Weighted_Patch_Score) / 100 AS DECIMAL(20,4)) AS Patch_Score
	FROM tmpPatchScores
	GROUP BY Client_Name;


	END$$

DELIMITER ;
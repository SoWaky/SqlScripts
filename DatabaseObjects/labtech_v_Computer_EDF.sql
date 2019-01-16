USE labtech;
    
DROP VIEW IF EXISTS v_Computer_EDF;

CREATE VIEW v_Computer_EDF
AS
SELECT DISTINCT Computers.*
		, EDF.`No Patch Group` AS `No_Patch_Group`
		, EDF.`Exclude from Anti-Virus` AS `Exclude_From_AV`
		, EDF.`Windows Update Agent Version` AS `Windows_Update_Agent_Version`
		, REPLACE(EDF.`Last Reboot`, '\\r\\n\\r\\n', '') AS `Last_Reboot`
		, EDF.`Last MW Date` AS `Last_MW_Date`
		, DATEDIFF(CURRENT_DATE, STR_TO_DATE(SUBSTRING(EDF.`Last MW Date`, 6, 10), '%m/%d/%Y')) AS `Num_Days_Since_Last_MW`
	FROM v_Computer_Stats Computers 
	INNER JOIN v_extradatacomputers EDF
		ON EDF.ComputerId = computers.ComputerId
	;
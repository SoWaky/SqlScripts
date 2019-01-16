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
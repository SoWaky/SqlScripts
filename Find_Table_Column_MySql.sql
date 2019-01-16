SELECT Table_Name, Column_Name #, *
FROM `INFORMATION_SCHEMA`.`COLUMNS` 
WHERE `TABLE_SCHEMA`='labtech' 
    AND `TABLE_NAME` LIKE '%group%'
	-- AND column_Name LIKE '%templateid%'
ORDER BY 1,2
    ;
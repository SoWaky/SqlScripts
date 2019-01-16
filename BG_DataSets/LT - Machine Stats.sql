-- LT - Machine Stats
  SELECT
    c.computerid as 'id',
    c.computerid,
    c.name as 'Machine Name',
    clients.name as 'Client Name',
    l.name as 'Location Name',
    IF((locate('server',lower(c.os)) = 0), 'Workstation', 'Server') AS 'Machine Type',
    cast(c.Assetdate as datetime)  AS 'Asset Date',
    CAST(FORMAT(ROUND(c.TotalMemory/512)/2,1) AS DECIMAL(10,1)) AS 'Total Memory',
    p.Name AS 'CPU',
    d.Letter AS 'Main Drive',
    d.Free as 'Main Drive Size Free',
    d.Size AS 'Main Drive Size Total',
    c.BiosVer AS 'Serial Number',
    ROUND(DATEDIFF(CURDATE(),DATE_FORMAT(c.Assetdate, '%Y-%m-%d'))/365, 2) AS 'Age in Years',
    cast(c.lastcontact as datetime) AS 'Last Checked In',
    c.LastUsername AS 'Last User',
    c.BiosName AS 'Model',
    c.os AS 'OS Version',
    c.BiosMFG AS 'Manufacturer',
    IF(c.lastcontact > (NOW() - INTERVAL 15 MINUTE), 1, 0) AS 'Online',
    CASE
        WHEN COALESCE(pm.patches_missing, 0) > 4 THEN '>5 Missing'
        WHEN COALESCE(pm.patches_missing, 0) > 2 THEN '3-4 Missing'
        WHEN COALESCE(pm.patches_missing, 0) > 0 THEN '1-2 Missing'
        ELSE 'Full'
    END AS 'Patch Status',
    cast(c.lastcontact as datetime) AS 'Last Contact',     
    CAST(c.uptime / 60.0 AS DECIMAL(10,2)) AS 'uptime_minutes',
    CAST(COALESCE(pm.patches_missing, 0) AS DECIMAL) AS '# of Patches Missing',
        CASE
        WHEN (c.virusap = 1 AND datediff(now(),c.virusdefs) < 14) THEN 'Up to Date'
        WHEN (datediff(now(),c.virusdefs) < 14) THEN 'Installed'
        WHEN (datediff(now(),c.virusdefs) >= 14) THEN 'Out of Date'
        ELSE 'Not Enabled'
    END AS 'AV Status',
    IF(c.virusap,'True','False') AS 'Protection Enabled',
    cast(c.virusdefs as datetime) AS 'AV Last Update Time',
    vs.name AS 'AV Version',
    c.warrantyend AS 'warranty_end'
FROM
    drives d
    INNER JOIN computers c ON d.computerid = c.computerid
    INNER JOIN clients ON c.clientid = clients.clientid
    LEFT JOIN virusscanners vs ON c.virusscanner = vs.vscanid
    Left Join locations l on l.locationid = c.locationid
    LEFT JOIN v_processors p ON p.computerid = c.computerid
    LEFT JOIN v_extradatacomputers ex ON ex.computerid = c.computerid
    LEFT JOIN (
            SELECT 
                ComputerID, 
                COUNT(*) AS patches_missing 
            FROM 
                v_hotfixes 
            WHERE 
                Approved = 1 
                AND Installed = 0 
            GROUP BY 
                ComputerID
            ) pm ON c.computerid = pm.computerid
WHERE
    d.size > 0
GROUP BY
    d.computerid  


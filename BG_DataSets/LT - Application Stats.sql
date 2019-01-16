-- LT - Application Stats
 SELECT
    CONCAT(CAST(c.ComputerID as CHAR), s.AppID) as 'id',
    c.computerid as 'Machine ID',
    c.name as 'Machine Name',
    clients.name as 'Client Name',
    IF((locate('server',lower(c.os)) = 0), 'Workstation', 'Server') AS 'Machine Type',
    s.name AS 'Application',
    s.version AS 'Version',
    cast(s.dateinstalled as datetime) AS 'Install Date',
    c.LastUsername AS 'Last User',
    c.os AS 'OS Version'
FROM
    (SELECT computerid, AppID, name, MAX(version) as version, dateinstalled 
     FROM software 
     GROUP BY computerid, AppID, name) s
    LEFT JOIN computers c ON c.computerid = s.computerid
    INNER JOIN clients ON c.clientid = clients.clientid
ORDER BY
    s.name ASC, c.name ASC 


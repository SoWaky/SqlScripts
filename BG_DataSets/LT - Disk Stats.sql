-- LT - Disk Stats
  SELECT
    d.driveid as 'id',
    c.computerid as 'computer id',
    c.name as 'Machine Name',
    clients.name as 'Client Name',
 l.name as 'Location Name',
    IF((locate('server',lower(c.os)) = 0), 'Workstation', 'Server') AS 'Machine Type',
    d.letter AS 'Drive',
    d.VolumeName AS 'Volume Name',
    SUBSTRING_INDEX(d.SmartStatus, ':', 1) AS 'Drive Type',
    CASE
        WHEN (100 - (SUM(d.free)/SUM(d.size))*100) >84 THEN 'Warning'
        WHEN (100 - (SUM(d.free)/SUM(d.size))*100) >64 THEN 'Alert'
        ELSE 'Good'
    END AS 'Drive Status',
    CASE
        WHEN (100 - (SUM(d.free)/SUM(d.size))*100) >80 THEN '81-100%'
        WHEN (100 - (SUM(d.free)/SUM(d.size))*100) >60 THEN '61-80%'
        WHEN (100 - (SUM(d.free)/SUM(d.size))*100) >40 THEN '41-60%'
        WHEN (100 - (SUM(d.free)/SUM(d.size))*100) >20 THEN '21-40%'
        ELSE '0-20%'
    END AS 'Range',
    CAST(ROUND(SUM(d.size)/1024,2) AS DECIMAL(10,2)) AS 'Total Space (gb)',
    CAST(ROUND((SUM(d.size)-SUM(d.free))/1024,2) AS DECIMAL(10,2)) AS 'Used Space (gb)',
    CAST(ROUND(SUM(d.free)/1024,2) AS DECIMAL(10,2)) AS 'Remaining Space (gb)',
    ROUND(100 - (SUM(d.free)/SUM(d.size))*100,0) AS 'Percentage Full',
    cast(c.lastcontact as datetime) AS 'Last Contact',   
    c.LastUsername AS 'Last User',
    c.os AS 'OS Version'
FROM
    drives d
    INNER JOIN computers c ON d.computerid = c.computerid
    INNER JOIN clients ON c.clientid = clients.clientid
   Left Join locations l on l.locationid = c.locationid
 WHERE
    d.size > 0
    and d.VolumeName != 'Page File'
    and d.missing = 'False'
GROUP BY
    d.computerid, d.letter  


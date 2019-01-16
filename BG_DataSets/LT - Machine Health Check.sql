--- LT - Machine Health Check

 select concat(hc.clientid,hc.computerid) as id
,c.name as Client_Name 
,hc.ComputerID	
,comp.name as Machine_Name
,l.name as Location_Name
,concat(c.name,' - ',l.name) as client_and_location
,cast(max(hc.CheckDate) as datetime) as  Check_Date	
,if(hc.AVHealth=0,null,hc.AVHealth) as AV_Health	
,hc.AVResults as AV_Notes
,case when hc.avhealth >= 75 then '3. Good'
		when hc.avhealth >= 50 then '2. Warning'
		when hc.avhealth >= 1 then '1. Alert'
		else 'O. No Score'
		end as AV_Status
,if(hc.DiskHealth=0,null,hc.DiskHealth) as Disk_Health
,hc.DiskResults	as Disk_Notes
,case when hc.DiskHealth >= 75 then '3. Good'
		when hc.DiskHealth >= 50 then '2. Warning'
		when hc.DiskHealth >= 1 then '1. Alert'
		else 'O. No Score'
		end as Disk_Status
,if(hc.IntrusionHealth=0,null,hc.IntrusionHealth)	as Intrusion_Health
,hc.IntrusionResults as Intrusion_Notes	
,case when hc.IntrusionHealth >= 75 then '3. Good'
		when hc.IntrusionHealth >= 50 then '2. Warning'
		when hc.IntrusionHealth >= 1 then '1. Alert'
		else 'O. No Score'
		end as Intrusion_Status
,if(hc.UsabilityHealth=0,null,hc.UsabilityHealth)	as Usability_Health
,hc.UsabilityResults as Usability_Notes
,case when hc.UsabilityHealth >= 75 then '3. Good'
		when hc.UsabilityHealth >= 50 then '2. Warning'
		when hc.UsabilityHealth >= 1 then '1. Alert'
		else 'O. No Score'
		end as Usability_Status
,if(hc.ServiceHealth=0,null,hc.ServiceHealth)	 as Service_Health
,hc.ServiceResults	as Service_Notes
,case when hc.ServiceHealth >= 75 then '3. Good'
		when hc.ServiceHealth >= 50 then '2. Warning'
		when hc.ServiceHealth >= 1 then '1. Alert'
		else 'O. No Score'
		end as Service_Status
,if(hc.UpdateHealth=0,null,hc.UpdateHealth) as Update_Health
,hc.UpdateResults as Update_Notes
,case when hc.UpdateHealth >= 75 then '3. Good'
		when hc.UpdateHealth >= 50 then '2. Warning'
		when hc.UpdateHealth >= 1 then '1. Alert'
		else 'O. No Score'
		end as Update_Status
,if(hc.EventHealth=0,null,hc.EventHealth)	as Event_Health
,hc.EventResults as Event_Notes	
,case when hc.EventHealth >= 75 then '3. Good'
		when hc.EventHealth >= 50 then '2. Warning'
		when hc.EventHealth >= 1 then '1. Alert'
		else 'O. No Score'
		end as Event_Status
,if(hc.BackupHealth=0,null,hc.BackupHealth/100) as Backup_Health	 
,hc.BackupResults  as Backup_Notes
,case when hc.BackupHealth >= 7500 then '3. Good'
		when hc.BackupHealth >= 5000 then '2. Warning'
		when hc.BackupHealth >= 1 then '1. Alert'
		else 'O. No Score'
		end as Backup_Status
, cast(((coalesce(hc.AVHealth,0) 
    + coalesce(hc.DiskHealth,0) 
    + coalesce(hc.IntrusionHealth,0) 
    + coalesce(hc.UsabilityHealth,0) 
    + coalesce(hc.ServiceHealth,0) 
    + coalesce(hc.UpdateHealth,0)
    + coalesce(hc.EventHealth,0)
    + coalesce((hc.BackupHealth/100.00),0))
    /
    nullif((if(hc.AVHealth>=1,1,0)
    + if(hc.DiskHealth>=1,1,0)
    + if(hc.IntrusionHealth>=1,1,0)
    + if(hc.UsabilityHealth>=1,1,0)
    + if(hc.ServiceHealth>=1,1,0)
    + if(hc.UpdateHealth>=1,1,0)
    + if(hc.EventHealth>=1,1,0)
    + if((hc.BackupHealth/100.00)>=1,1,0)),0))
    as decimal(18,2))
    as Overall_Health
, case when cast(((coalesce(hc.AVHealth,0) 
    + coalesce(hc.DiskHealth,0) 
    + coalesce(hc.IntrusionHealth,0) 
    + coalesce(hc.UsabilityHealth,0) 
    + coalesce(hc.ServiceHealth,0) 
    + coalesce(hc.UpdateHealth,0)
    + coalesce(hc.EventHealth,0)
    + coalesce((hc.BackupHealth/100.00),0))
    /
    nullif((if(hc.AVHealth>=1,1,0)
    + if(hc.DiskHealth>=1,1,0)
    + if(hc.IntrusionHealth>=1,1,0)
    + if(hc.UsabilityHealth>=1,1,0)
    + if(hc.ServiceHealth>=1,1,0)
    + if(hc.UpdateHealth>=1,1,0)
    + if(hc.EventHealth>=1,1,0)
    + if((hc.BackupHealth/100.00)>=1,1,0)),0))
    as decimal(18,2))  >= 75 then '3. Good'
    when cast(((coalesce(hc.AVHealth,0) 
    + coalesce(hc.DiskHealth,0) 
    + coalesce(hc.IntrusionHealth,0) 
    + coalesce(hc.UsabilityHealth,0) 
    + coalesce(hc.ServiceHealth,0) 
    + coalesce(hc.UpdateHealth,0)
    + coalesce(hc.EventHealth,0)
    + coalesce((hc.BackupHealth/100.00),0))
    /
    nullif((if(hc.AVHealth>=1,1,0)
    + if(hc.DiskHealth>=1,1,0)
    + if(hc.IntrusionHealth>=1,1,0)
    + if(hc.UsabilityHealth>=1,1,0)
    + if(hc.ServiceHealth>=1,1,0)
    + if(hc.UpdateHealth>=1,1,0)
    + if(hc.EventHealth>=1,1,0)
    + if((hc.BackupHealth/100.00)>=1,1,0)),0))
    as decimal(18,2)) >= 50 then '2. Warning'
    when cast(((coalesce(hc.AVHealth,0) 
    + coalesce(hc.DiskHealth,0) 
    + coalesce(hc.IntrusionHealth,0) 
    + coalesce(hc.UsabilityHealth,0) 
    + coalesce(hc.ServiceHealth,0) 
    + coalesce(hc.UpdateHealth,0)
    + coalesce(hc.EventHealth,0)
    + coalesce((hc.BackupHealth/100.00),0))
    /
    nullif((if(hc.AVHealth>=1,1,0)
    + if(hc.DiskHealth>=1,1,0)
    + if(hc.IntrusionHealth>=1,1,0)
    + if(hc.UsabilityHealth>=1,1,0)
    + if(hc.ServiceHealth>=1,1,0)
    + if(hc.UpdateHealth>=1,1,0)
    + if(hc.EventHealth>=1,1,0)
    + if((hc.BackupHealth/100.00)>=1,1,0)),0))
    as decimal(18,2)) >= 1 then '1. Alert'
    else '0. No Score'
    end as Overall_Status
FROM (select c.ClientID AS ClientID
			,c.ComputerID AS ComputerID
			,es.EventDate AS CheckDate
			,if((length(es.Stat15) < 1),NULL,round((left(es.Stat15,4) * 100),0)) AS AVHealth
			,replace(es.Stat15,left(es.Stat15,5),'') AS AVResults
			,if((length(es.Stat16) < 1),NULL,round((left(es.Stat16,4) * 100),0)) AS DiskHealth
			,replace(es.Stat16,left(es.Stat16,5),'') AS DiskResults
			,if((length(es.Stat17) < 1),NULL,round((left(es.Stat17,4) * 100),0)) AS IntrusionHealth
			,replace(es.Stat17,left(es.Stat17,5),'') AS IntrusionResults
			,if((length(es.Stat18) < 1),NULL,round((left(es.Stat18,4) * 100),0)) AS UsabilityHealth
			,replace(es.Stat18,left(es.Stat18,5),'') AS UsabilityResults
			,if((length(es.Stat19) < 1),NULL,round((left(es.Stat19,4) * 100),0)) AS ServiceHealth
			,replace(es.Stat19,left(es.Stat19,5),'') AS ServiceResults
			,if((length(es.Stat20) < 1),NULL,round((left(es.Stat20,4) * 100),0)) AS UpdateHealth
			,replace(es.Stat20,left(es.Stat20,5),'') AS UpdateResults
			,if((length(es.Stat14) < 1),NULL,round((left(es.Stat14,4) * 100),0)) AS EventHealth
			,replace(es.Stat14,left(es.Stat14,5),'') AS EventResults
			,if((length(es.Stat1) < 1),NULL,round((left(es.Stat1,4) * 100),0)) AS BackupHealth
			,replace(es.Stat1,left(es.Stat1,5),'') AS BackupResults 
			from (computers c 
					join (select h.ComputerID AS ComputerID
								,h.Stat1 AS Stat1
								,h.Stat2 AS Stat2
								,h.Stat3 AS Stat3
								,h.Stat4 AS Stat4
								,h.Stat5 AS Stat5
								,h.Stat6 AS Stat6
								,h.Stat7 AS Stat7
								,h.Stat8 AS Stat8
								,h.Stat9 AS Stat9
								,h.Stat10 AS Stat10
								,h.Stat11 AS Stat11
								,h.Stat12 AS Stat12
								,h.Stat13 AS Stat13
								,h.Stat14 AS Stat14
								,h.Stat15 AS Stat15
								,h.Stat16 AS Stat16
								,h.Stat17 AS Stat17
								,h.Stat18 AS Stat18
								,h.Stat19 AS Stat19
								,h.Stat20 AS Stat20
								,h.EventDate AS EventDate 
								from h_extrastats h
								left join drives d1 on d1.computerid = h.computerid
								where d1.size > 0
								group by h.computerid
								union 
								select 
								hd.ComputerID AS ComputerID
								,hd.Stat1 AS Stat1
								,hd.Stat2 AS Stat2
								,hd.Stat3 AS Stat3
								,hd.Stat4 AS Stat4
								,hd.Stat5 AS Stat5
								,hd.Stat6 AS Stat6
								,hd.Stat7 AS Stat7
								,hd.Stat8 AS Stat8
								,hd.Stat9 AS Stat9
								,hd.Stat10 AS Stat10
								,hd.Stat11 AS Stat11
								,hd.Stat12 AS Stat12
								,hd.Stat13 AS Stat13
								,hd.Stat14 AS Stat14
								,hd.Stat15 AS Stat15
								,hd.Stat16 AS Stat16
								,hd.Stat17 AS Stat17
								,hd.Stat18 AS Stat18
								,hd.Stat19 AS Stat19
								,hd.Stat20 AS Stat20
								,hd.EventDate AS EventDate 
								from h_extrastatsdaily hd
								left join drives d2 on d2.computerid = hd.computerid
								where d2.size > 0
								group by hd.computerid) es 
					on((c.ComputerID = es.ComputerID))) 
	where (es.Stat14 <> '-1')) hc
	inner join clients c ON hc.clientid = c.clientid
	inner join computers comp on comp.ComputerID = hc.ComputerID
	Left Join locations l on l.locationid = comp.locationid
	group by concat(hc.clientid,hc.computerid) 

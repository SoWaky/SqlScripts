select sum(Num_Reactive_Tickets_Closed) as Num_Tickets, sum(Num_Reactive_Hours) as Num_Hours, sum(Num_Endpoints) as Num_Endpoints
		, CAST(CASE WHEN sum(Num_Endpoints) > 0 THEN (cast(sum(Num_Reactive_Hours) as decimal(20,2)) / cast(sum(Num_Endpoints) as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS RHEM
	FROM MSP_Dashboard.dbo.vw_CompanyStatsLast30Days t
	WHERE Company_Name not like '%webit%'

	
select Company_Name as company, Num_Reactive_Tickets_Closed, Num_Reactive_Hours, Num_Endpoints
		, CAST(CASE WHEN Num_Endpoints > 0 THEN (cast(Num_Reactive_Hours as decimal(20,2)) / cast(Num_Endpoints as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS RHEM
	FROM MSP_Dashboard.dbo.vw_CompanyStatsLast30Days t
	WHERE Company_Name not like '%webit%'
	order by 5 desc

--print dateadd(dd, -30, getdate()) 
--print GETDATE()

--drop table #hours
--drop table #tickets
--drop table #endpoints

--SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, SUM(SubTime.Hours_Worked) as Num_Reactive_Hours
--into #Hours
--	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
--	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
--		ON Account.account_id = Ticket.account_id
--	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
--		ON Parent.account_id = Account.parent_account_id
--	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
--		ON Board.queue_id = Ticket.ticket_queue_id
--	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_item Time
--		ON Time.task_id = Ticket.task_id
--	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_subitem SubTime 
--		ON SubTime.time_item_id = Time.time_item_id
--	WHERE 1=1
--		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
--		AND SubTime.Date_Worked between dateadd(dd, -30, getdate()) AND GETDATE()
--		AND (Board.queue_name like '01%' OR Board.queue_name like '00%')
--	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)

--SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name,  count(*) as Num_Reactive_Tickets_Closed
--	INTO #tickets
--	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
--	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
--		ON Account.account_id = Ticket.account_id
--	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
--		ON Parent.account_id = Account.parent_account_id
--	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
--		ON Board.queue_id = Ticket.ticket_queue_id
--	WHERE 1=1
--		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
--		AND Ticket.Date_Completed between dateadd(dd, -30, getdate()) AND GETDATE()
--		AND (Board.queue_name like '01%' OR Board.queue_name like '00%')
--		AND Ticket.Total_Worked_Hours > 0
--	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)

--SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, COUNT(*) as Num_Endpoints
--into #endpoints
--					FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
--					LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Account
--						ON Account.account_id = InstalledProduct.account_id
--					LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
--						ON Parent.account_id = Account.parent_account_id
--					WHERE 1=1
--						AND Account.is_active = 1
--						AND InstalledProduct.is_active = 1
--						AND InstalledProduct.aem_device_id is not null
--					GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)

--select sum(t.Num_Reactive_Tickets_Closed) as Num_Tickets, sum(h.Num_Reactive_Hours) as Num_Hours, sum(e.Num_Endpoints) as Num_Endpoints
--		, CAST(CASE WHEN sum(Num_Endpoints) > 0 THEN (cast(sum(Num_Reactive_Hours) as decimal(20,2)) / cast(sum(Num_Endpoints) as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS RHEM
--	from #hours h
--	inner join #endpoints e
--		on h.Company_Name = e.Company_Name
--	inner join #tickets t
--		on t.Company_Name = h.Company_Name
--	WHERE h.Company_Name not like '%webit%'





--select h.Company_Name as company, t.Num_Reactive_Tickets_Closed, h.Num_Reactive_Hours, e.Num_Endpoints
--		, CAST(CASE WHEN Num_Endpoints > 0 THEN (cast(Num_Reactive_Hours as decimal(20,2)) / cast(Num_Endpoints as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS RHEM
--	from #hours h
--	inner join #endpoints e
--		on h.Company_Name = e.Company_Name
--	inner join #tickets t
--		on t.Company_Name = h.Company_Name
--	WHERE h.Company_Name not like '%webit%'
--	order by 5 desc

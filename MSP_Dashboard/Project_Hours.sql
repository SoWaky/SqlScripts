
SELECT COALESCE(Parent.Account_Name, a.Account_Name) AS Company_Name, datepart(mm, p.start_date) as Start_Month
		, sum(p.estimated_hours) as estimated_hours
		, sum(p.actual_worked_hours) as actual_hours
		, (SELECT Num_Seats
				FROM MSP_Dashboard.dbo.CompanyStatsByMonth seats
				WHERE seats.Company_Name = COALESCE(Parent.Account_Name, a.Account_Name)
				and seats.StatsYear = datepart(yy, p.start_date)
				and seats.StatsMonth = datepart(mm, p.start_date)) as Num_Seats
	from Autotask.TF_511394_WH.dbo.wh_project p
	left join Autotask.TF_511394_WH.dbo.wh_project_udf cat
		on cat.project_id = p.project_id
	inner join Autotask.TF_511394_WH.dbo.wh_account a
		on a.account_id = p.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = a.parent_account_id

	where 1=1	
		and cat.Project_Category_stored_value not in ('Client Onboard', 'Client Offboard','Application Development')
		and a.key_account_icon_id = 201	-- in (201, 200, 204)	-- 10, 15, 95 clients
		and p.start_date >= '01/01/2018'
	group by COALESCE(Parent.Account_Name, a.Account_Name), datepart(yy, p.start_date) , datepart(mm, p.start_date)
	order by 1,2,3
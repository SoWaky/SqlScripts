
	SELECT rate_per_hour, period_start_Date, date_worked, hours_worked, hours_billed, approved_date, force_non_billable, show_on_invoice, contract_name, task_number, task_name, CB.*, s.Summary_Notes, *
		from Autotask.TF_511394_WH.dbo.wh_time_item t
		inner join Autotask.TF_511394_WH.dbo.wh_time_subitem s
			on t.time_item_id = s.time_item_id			
		INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract C WITH (NOLOCK)
			ON c.Contract_Id = s.Contract_Id
		left join Autotask.TF_511394_WH.dbo.wh_task task 
			on task.task_id = t.task_id
		left JOIN Autotask.TF_511394_WH.dbo.wh_contract_Block CB WITH (NOLOCK)
				ON CB.contract_id = C.contract_id
		where c.contract_name = 'DEV - SAMA Development Block Hours'
		ORDER by 3

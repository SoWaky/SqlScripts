-- Connectwise - Agreements 

Select 
al.Company_Name 
,al.AGR_Name as agreement_name
,al.AGR_Header_RecID as id
,al.agr_type_desc as agreement_type
,concat('<p><strong>',al.Company_Name,'</strong>',' - ',al.AGR_Name,'</p>') as company_and_agreement_strong
,concat(al.Company_Name,' - ',al.AGR_Name) as company_and_agreement
,al.Valid_flag	
,CAST(al.DateStart AS DATETIME)  AS Date_Start	
,CAST(al.DateEnd AS DATETIME)  AS Date_End
,al.BalAvailable as balance_available	
,al.AGR_Detail_Type_Desc as application_unit
,ah.pp_Amount as application_limit
,ah.PP_Carryover_Flag as application_carryover_allowed
,ah.CarryOver_Days as application_carryover_expires_days
,ah.Overrun_Limit as application_overrun_limit
,al.UnlimitedFlag as application_Unlimited_Flag
,al.Billing_Cycle_Desc as billing_cycle
,al.Nbr_Cycles	as number_of_cycles
,al.Updated_By	
,CAST(ah.Last_Update AS DATETIME) as last_update
,coalesce(al.Billing_Amount,child.billing_amount) as billing_amount
,al.Billing_Amount as parent_billing_amount
,child.Billing_Amount as child_billing_amount
,al.Agreement_Status	
,al.Owner_Level_Name as Location
,al.Billing_Unit_Name as bussiness_group
,ah.AGR_Cancel_Flag	as cancelled_flag
,CAST(ah.AGR_Date_Cancel AS DATETIME) as agreement_Date_Cancel	
,ah.AGR_Reason_Cancel as cancel_reason
,ah.PP_Time_Flag	as agreement_covers_time_flag
,ah.PP_Expenses_Flag as agreement_covers_expenses_flag	
,ah.PP_Products_Flag as agreement_covers_products_flag
,case when ah.PP_Time_Flag = 'True' and ah.PP_Expenses_Flag = 'False' and ah.PP_Products_Flag = 'False' then 'Time'
when ah.PP_Time_Flag = 'True' and ah.PP_Expenses_Flag = 'False' and ah.PP_Products_Flag = 'False' then 'Time'
when ah.PP_Time_Flag = 'True' and ah.PP_Expenses_Flag = 'True' and ah.PP_Products_Flag = 'False' then 'Time & Expenses'
when ah.PP_Time_Flag = 'True' and ah.PP_Expenses_Flag = 'True' and ah.PP_Products_Flag = 'True' then 'Time, Products, & Expenses'
when ah.PP_Time_Flag = 'True' and ah.PP_Expenses_Flag = 'False' and ah.PP_Products_Flag = 'True' then 'Time & Products'
when ah.PP_Time_Flag = 'False' and ah.PP_Expenses_Flag = 'True' and ah.PP_Products_Flag = 'False' then 'Expenses'
when ah.PP_Time_Flag = 'False' and ah.PP_Expenses_Flag = 'True' and ah.PP_Products_Flag = 'True' then 'Products & Expenses'
when ah.PP_Time_Flag = 'False' and ah.PP_Expenses_Flag = 'False' and ah.PP_Products_Flag = 'True' then 'Products'
else null
end as agreement_covers_list
,sla.sla_name
,bt.Description as billing_terms
,coalesce(rev.rev,0) as parent_revenue
,coalesce(child.rev,0) as child_revenue
,coalesce(rev.rev,0) + coalesce(child.rev,0)  as total_agreement_amount_billed
,case when (coalesce(te.hours,0) + coalesce(child.hours,0)) = 0 then null else ((coalesce(rev.rev,0) + coalesce(child.rev,0)) - (coalesce(addi.prod_cost,0) + coalesce(child.prod_cost,0)))/(coalesce(te.hours,0) + coalesce(child.hours,0)) end as total_no_addition_EHR
,case when (coalesce(te.hours,0) + coalesce(child.hours,0)) = 0 then null else ((coalesce(rev.rev,0) + coalesce(child.rev,0)))/(coalesce(te.hours,0) + coalesce(child.hours,0)) end as total_EHR
,case when (coalesce(te.hours,0)) = 0 then null else (coalesce(rev.rev,0))/(coalesce(te.hours,0)) end as parent_EHR
,case when (coalesce(te.hours,0)) = 0 then null else (coalesce(rev.rev,0) - coalesce(addi.prod_cost,0))/(coalesce(te.hours,0)) end as parent_no_addition_EHR
,case when (coalesce(child.hours,0)) = 0 then null else (coalesce(child.rev,0))/(coalesce(child.hours,0)) end as child_EHR
,case when (coalesce(child.hours,0)) = 0 then null else (coalesce(child.rev,0) - coalesce(child.prod_cost,0))/(coalesce(child.hours,0)) end as child_no_addition_EHR
,coalesce(te.hours_actual,0) + coalesce(child.hours_actual,0) as total_agreement_hours
,coalesce(rev.rev,0) + coalesce(child.rev,0)  as total_revenue
,coalesce(te.hours_cost,0) + coalesce(child.hours_cost,0) as total_agreement_hours_cost
,coalesce(te.hours_cost,0) + coalesce(child.hours_cost,0) + coalesce(addi.prod_cost,0) + coalesce(child.prod_cost,0) as total_cost
,(coalesce(rev.rev,0) + coalesce(child.rev,0)) - (coalesce(te.hours_cost,0) + coalesce(child.hours_cost,0) + coalesce(addi.prod_cost,0) + coalesce(child.prod_cost,0)) as total_agreement_margin
,cast(case when child.parent_recid is null then 0 else 1 end as bit) as has_child_agreement
,(coalesce(rev.rev,0) ) - (coalesce(te.hours_cost,0) ) - coalesce(addi.prod_cost,0) as parent_agreement_margin
,(coalesce(child.rev,0) ) - (coalesce(child.hours_cost,0) ) - coalesce(child.prod_cost,0) as child_agreement_margin
,coalesce(child.count,0) as number_of_child_agreements
,CAST(rev.last_inv AS DATETIME) as last_agreement_invoice_date
,addi.prod_cost as parrent_addition_cost
,child.prod_cost as child_addition_cost
,coalesce(addi.prod_cost,0) + coalesce(child.prod_cost,0) as total_addition_cost
,child.child_agreeements
,child.child_agreeement_types
from v_rpt_AgreementList al
left join agr_header as ah on ah.agr_header_recid = al.agr_header_recid
left join sr_sla sla on sla.SR_SLA_RecID = ah.SR_SLA_RecID
left join Billing_Terms bt on bt.Billing_Terms_RecID = ah.Billing_Terms_RecID
left join (select sum((ai.Monthly_Inv_Amt - ai.Monthly_SalesTax_Amt)) as rev, 
                    ai.agr_header_recid, 
                    max(datefromparts(ai.Year_Nbr,ai.month_nbr,01)) as last_inv 
                    from agr_invoice_amt ai
                    inner join billing_log bl on bl.billing_log_recid = ai.billing_log_recid
                    inner join Billing_Status bs on bs.Billing_Status_RecID = bl.Billing_Status_RecID
                    where bs.sent_flag = 'True'
                    group by ai.agr_header_recid) as rev on rev.agr_header_Recid = al.agr_header_recid
left join (select sum(vadi.Extended_Cost_Amount) as prod_cost
                    ,vadi.AGR_Header_RecID
                    from dbo.IV_Product vadi
                    group by vadi.AGR_Header_RecID) as addi on addi.agr_header_Recid = al.agr_header_Recid
left join (select sum(t.Agr_Hours) as hours 
            ,sum(t.Hours_Actual) as hours_actual
            ,sum(t.hours_actual * dbo.udf_EncrDecr (t.Hourly_Cost, 'd')) as hours_cost
            ,t.agr_header_Recid from time_entry t
            group by t.agr_header_recid) as te on te.agr_header_Recid = al.agr_header_recid
left join  (select ah2.parent_recid
                    ,sum(ah2.AGR_Amount) as billing_amount
                    ,sum(rev2.rev) as rev
                    ,sum(te2.hours) as hours
                    ,sum(te2.hours_actual) as hours_actual
                    ,sum(te2.hours_cost) as hours_cost
                    ,count(1) as count
                    ,sum(addi.prod_cost) as prod_cost,
                    substring(
                        (
                            Select ', '+ahc.AGR_Name  AS [text()]
                            From dbo.agr_header ahc
                            Where ahc.parent_recid = ah2.parent_Recid
                            ORDER BY ahc.AGR_Name
                            For XML PATH ('')
                        ), 2, 1000) [child_agreeements]
                    ,substring(
                        (
                            Select ', '+atc.AGR_Type_Desc  AS [text()]
                            From dbo.agr_header ahc2
                            inner join AGR_Type atc on atc.AGR_Type_RecID = ahc2.AGR_Type_RecID
                            Where ahc2.parent_recid = ah2.parent_Recid
                            ORDER BY atc.AGR_Type_Desc
                            For XML PATH ('')
                        ), 2, 1000) [child_agreeement_types]
                    from agr_header ah2
                    left join (select sum((ai2.Monthly_Inv_Amt - ai2.Monthly_SalesTax_Amt)) as rev, 
                                    ai2.agr_header_recid, 
                                    max(datefromparts(ai2.Year_Nbr,ai2.month_nbr,01)) as last_inv 
                                    from agr_invoice_amt ai2
                                    inner join billing_log bl2 on bl2.billing_log_recid = ai2.billing_log_recid
                                    inner join Billing_Status bs2 on bs2.Billing_Status_RecID = bl2.Billing_Status_RecID
                                    where bs2.sent_flag = 'True'
                                    group by ai2.agr_header_recid) as rev2 on rev2.agr_header_Recid = ah2.agr_header_recid
                    left join (select sum(t2.Agr_Hours) as hours 
                                ,sum(t2.Hours_Actual) as hours_actual
                                ,sum(t2.hours_actual * dbo.udf_EncrDecr (t2.Hourly_Cost, 'd')) as hours_cost
                                ,t2.agr_header_Recid from time_entry t2
                                group by t2.agr_header_recid) as te2 on te2.agr_header_Recid = ah2.agr_header_recid
                    left join (select sum(vadi.Extended_Cost_Amount) as prod_cost
                    ,ahp.agr_header_Recid
                    from dbo.AGR_Header ahp
                    inner join dbo.IV_Product vadi on vadi.AGR_Header_RecID = ahp.AGR_Header_RecID
                    group by ahp.agr_header_Recid) as addi on addi.agr_header_Recid = ah2.agr_header_Recid
                    group by ah2.parent_recid) as child on child.parent_recid = al.agr_header_recid 
where ah.parent_recid is null 

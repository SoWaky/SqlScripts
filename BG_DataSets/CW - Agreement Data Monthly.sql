-- CW - Agreement Data Monthly

  SELECT newid() as id
,al.Company_Name 
,al.AGR_Name as agreement_name
,al.agr_type_desc as agreement_type
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
,al.Billing_Amount		
,al.Agreement_Status	
,al.Owner_Level_Name as Location
,al.Billing_Unit_Name as bussiness_group
,ah.AGR_Cancel_Flag	as cancelled_flag
,CAST(ah.AGR_Date_Cancel AS DATETIME) as agreement_Date_Cancel	
,ah.AGR_Reason_Cancel as cancel_reason
,ah.PP_Time_Flag	as agreement_covers_time_flag
,ah.PP_Expenses_Flag as agreement_covers_expenses_flag	
,ah.PP_Products_Flag as agreement_covers_products_flag
,coalesce(bu.Description, '(none)') AS Department
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
, sla.sla_name
, bt.Description as billing_terms
, CASE ah.AGR_NoEnd_Flag
    WHEN 1 THEN 'Yes' ELSE 'No'
    END AS No_End_Flag
, coalesce(ap.Rev,0) + coalesce(child.rev,0) AS total_Revenue
, cast(ap.Agr_Date_inv as datetime) as date_agreement_invoiced
, coalesce(ap.Hours,0) + coalesce(child.hours,0) AS total_Agreement_Hours
, coalesce(ap.labor_Cost,0) + coalesce(child.labor_Cost,0) AS total_Labor_Cost
, coalesce(ap.prod_cost,0) + coalesce(child.prod_cost,0) as total_addition_cost
, child.child_agreeements
, child.child_agreeement_types
, child.count as number_of_child_agreements
, child.rev as child_revenue
, ap.Rev as parent_revenue
, ap.Hours as parent_hours
, child.hours AS child_Hours
, ap.labor_Cost as parent_labor_cost
, child.labor_Cost AS child_labor_cost
, ap.prod_cost as parent_addition_cost
, child.prod_cost as child_addition_cost
, coalesce(ap.labor_Cost,0) + coalesce(child.labor_Cost,0) + coalesce(ap.prod_cost,0) + coalesce(child.prod_cost,0) as total_cost
,case when (coalesce(ap.hours,0) + coalesce(child.hours,0)) = 0 then null else (coalesce(ap.rev,0) + coalesce(child.rev,0))/(coalesce(ap.hours,0) + coalesce(child.hours,0)) end as total_all_EHR
,case when (coalesce(ap.hours,0) + coalesce(child.hours,0)) = 0 then null 
    else ((coalesce(ap.rev,0) + coalesce(child.rev,0)) - (coalesce(ap.prod_cost,0) + coalesce(child.prod_cost,0)) )/(coalesce(ap.hours,0) + coalesce(child.hours,0)) end as total_no_addition_cost_EHR
,case when (coalesce(ap.hours,0)) = 0 then null 
    else (coalesce(ap.rev,0))/(coalesce(ap.hours,0)) end as parent_all_EHR
,case when (coalesce(ap.hours,0)) = 0 then null 
    else (coalesce(ap.rev,0) - coalesce(ap.prod_cost,0))/(coalesce(ap.hours,0)) end as parent_no_addition_cost_EHR
,case when (coalesce(child.hours,0)) = 0 then null 
    else (coalesce(child.rev,0) - coalesce(child.prod_cost,0))/(coalesce(child.hours,0)) end as child_no_addition_cost_EHR
,case when (coalesce(child.hours,0)) = 0 then null else (coalesce(child.rev,0))/(coalesce(child.hours,0)) end as child_all_EHR
,(coalesce(ap.rev,0) + coalesce(child.rev,0))
    - (coalesce(ap.labor_Cost,0) + coalesce(child.labor_Cost,0) + coalesce(ap.prod_cost,0) + coalesce(child.prod_cost,0)) 
    as total_agreement_margin
,case when (coalesce(ap.rev,0) + coalesce(child.rev,0)) = 0 then 0
 else ((coalesce(ap.rev,0) + coalesce(child.rev,0))
        - (coalesce(ap.labor_Cost,0) + coalesce(child.labor_Cost,0) + coalesce(ap.prod_cost,0) + coalesce(child.prod_cost,0))) 
        / ((coalesce(ap.rev,0) + coalesce(child.rev,0)))
    end as total_agreement_margin_percentage
from v_rpt_AgreementList al
inner join AGR_Header AS ah on ah.agr_header_recid = al.agr_header_recid
left join Contact AS ct ON ct.Contact_RecID = ah.Contact_RecID
left join Billing_Terms bt on bt.Billing_Terms_RecID = ah.Billing_Terms_RecID
left join sr_sla sla on sla.SR_SLA_RecID = ah.SR_SLA_RecID
left join Billing_Unit AS bu ON al.Billing_Unit_RecID = bu.Billing_Unit_RecID
left join Owner_Level AS ol ON al.Owner_Level_RecID = ol.Owner_Level_RecID
left join SO_Opportunity AS so ON ah.Opportunity_RecID = so.Opportunity_RecID
inner join (SELECT ar.AGR_Header_RecID
    , ar.Month
    , ar.Year
     ,ar.Agr_Date_inv
    , ar.Rev
    , ac.Hours AS Hours
    , ac.Cost AS labor_Cost
    , addi.prod_cost
    FROM
    (SELECT ah.AGR_Header_RecID
       , ai.Month_Nbr AS 'Month'
       , ai.Year_Nbr AS 'Year'
        ,CONVERT (VARCHAR(8), ai.Year_Nbr, 120) + '-' + RIGHT ('0' + CONVERT (VARCHAR(8), ai.Month_nbr, 120), 2) + '-' + '01' as Agr_Date_inv
       , CAST (SUM (ai.Monthly_Inv_Amt - ai.Monthly_SalesTax_Amt) AS NUMERIC (18, 2)) AS Rev
     FROM
       dbo.AGR_Header AS ah 
       INNER JOIN dbo.AGR_Invoice_Amt AS ai ON ah.AGR_Header_RecID = ai.AGR_Header_RecID
     GROUP BY ah.AGR_Header_RecID
       , ai.Month_Nbr
       , ai.Year_Nbr) AS ar 
    LEFT JOIN (SELECT ah.AGR_Header_RecID
       , DATEPART (MONTH, te.Date_Start) AS Month
       , DATEPART (YEAR, te.Date_Start) AS Year
       , SUM (te.hours_bill) AS Hours
       , CAST (SUM (te.hours_bill * dbo.udf_EncrDecr (te.Hourly_Cost, 'd')) AS NUMERIC (18, 2)) AS Cost
     FROM
       dbo.Time_Entry AS te INNER JOIN
       dbo.AGR_Header AS ah ON te.Agr_Header_RecID = ah.AGR_Header_RecID
     WHERE (te.Agr_Header_RecID IS NOT NULL)
      AND (te.Agr_Hours IS NOT NULL)
     GROUP BY ah.AGR_Header_RecID
       , DATEPART (MONTH, te.Date_Start)
       , DATEPART (YEAR, te.Date_Start)) AS ac ON ar.AGR_Header_RecID = ac.AGR_Header_RecID
                     AND ar.Month = ac.Month
                     AND ar.Year = ac.Year
    left join (select sum(vadi.Extended_Cost_Amount) as prod_cost
                    ,vadi.AGR_Header_RecID
                    ,vadi.agr_month as month
                    ,vadi.agr_year as year
                    from dbo.IV_Product vadi
                    group by vadi.AGR_Header_RecID
                        ,vadi.agr_month
                        ,vadi.agr_year) as addi on addi.AGR_Header_RecID = ar.AGR_Header_RecID and ar.year = addi.year and ar.month = addi.month
    ) AS ap ON ap.AGR_Header_RecID = al.AGR_Header_RecID 
left join
  (SELECT ar.parent_recid
    , ar.Month
    , ar.Year
     ,ar.Agr_Date_inv
    , ar.Rev
    , ac.Hours AS Hours
    , ac.Cost AS labor_Cost
    , ar.child_agreeements
    , ar.count
    , ar.child_agreeement_types
    , addi.prod_cost
    FROM
    (SELECT ah.parent_recid
       , ai.Month_Nbr AS Month
       , ai.Year_Nbr AS Year
        ,CONVERT (VARCHAR(8), ai.Year_Nbr, 120) + '-' + RIGHT ('0' + CONVERT (VARCHAR(8), ai.Month_nbr, 120), 2) + '-' + '01' as Agr_Date_inv
       ,CAST (SUM (ai.Monthly_Inv_Amt - ai.Monthly_SalesTax_Amt) AS NUMERIC (18, 2)) AS rev
       ,substring(
        (
            Select ', '+ahc.AGR_Name  AS [text()]
            From dbo.agr_header ahc
            Where ahc.parent_recid = ah.parent_Recid
            ORDER BY ahc.AGR_Name
            For XML PATH ('')
        ), 2, 1000) [child_agreeements]
        ,substring(
        (
            Select ', '+atc.AGR_Type_Desc  AS [text()]
            From dbo.agr_header ahc2
            inner join AGR_Type atc on atc.AGR_Type_RecID = ahc2.AGR_Type_RecID
            Where ahc2.parent_recid = ah.parent_Recid
            ORDER BY atc.AGR_Type_Desc
            For XML PATH ('')
        ), 2, 1000) [child_agreeement_types]
        ,count(1) as count
     FROM
       dbo.AGR_Header AS ah 
     INNER JOIN dbo.AGR_Invoice_Amt AS ai ON ah.AGR_Header_RecID = ai.AGR_Header_RecID
     GROUP BY ah.parent_Recid
       , ai.Month_Nbr
       , ai.Year_Nbr) AS ar LEFT JOIN
    (SELECT ah.parent_Recid
       , DATEPART (MONTH, te.Date_Start) AS 'Month'
       , DATEPART (YEAR, te.Date_Start) AS 'Year'
       , SUM (te.hours_bill) AS Hours
       , CAST (SUM (te.hours_bill * dbo.udf_EncrDecr (te.Hourly_Cost, 'd')) AS NUMERIC (18, 2)) AS 'Cost'
       
     FROM
       dbo.Time_Entry AS te INNER JOIN
       dbo.AGR_Header AS ah ON te.Agr_Header_RecID = ah.AGR_Header_RecID
     WHERE (te.Agr_Header_RecID IS NOT NULL)
      AND (te.Agr_Hours IS NOT NULL)
     GROUP BY ah.parent_Recid
       , DATEPART (MONTH, te.Date_Start)
       , DATEPART (YEAR, te.Date_Start)) AS ac ON ar.parent_recid = ac.parent_recid
                     AND ar.Month = ac.Month
                     AND ar.Year = ac.Year
    left join (select sum(vadi.Extended_Cost_Amount) as prod_cost
                    ,ahp.parent_Recid
                    ,vadi.agr_month as month
                    ,vadi.agr_year as year
                    from dbo.AGR_Header ahp
                    inner join dbo.IV_Product vadi on vadi.AGR_Header_RecID = ahp.AGR_Header_RecID
                    group by ahp.parent_Recid
                        ,vadi.agr_month
                        ,vadi.agr_year) as addi on addi.parent_Recid = ar.parent_Recid and ar.year = addi.year and ar.month = addi.month) AS child ON child.parent_recid = al.AGR_Header_RecID and child.month = ap.month and child.year = ap.year 
where ah.parent_Recid is null and ap.agr_date_inv > dateadd(mm,-36,current_timestamp)  

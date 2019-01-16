-- SELECT * FROM vw_ProfitLoss order by 2,3,4
-- select * from LineItemCategory

------------------------------------------------------------
-- The vw_ProfitLoss View includes all fields from the ProfitLoss table
--	and includes a Variance to Plan
------------------------------------------------------------

USE MSP_Dashboard
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_ProfitLoss]'))
	DROP VIEW dbo.vw_ProfitLoss
GO

CREATE VIEW dbo.vw_ProfitLoss
AS 
SELECT p.*, (p.ActualAmount - p.PlanAmount) as VarianceAmount
		, CASE WHEN p.LineItemCategoryId IN (1,5,7,8,9) AND (p.ActualAmount - p.PlanAmount) < 0 THEN -1	-- We want Income Variance to be positive
				WHEN p.LineItemCategoryId IN (1,5,7,8,9) AND (p.ActualAmount - p.PlanAmount) > 0 THEN 1
				WHEN p.LineItemCategoryId IN (2,6) AND (p.ActualAmount - p.PlanAmount) < 0 THEN 1	-- We want Expense Variance to be negative
				WHEN p.LineItemCategoryId IN (2,6) AND (p.ActualAmount - p.PlanAmount) > 0 THEN -1
				ELSE 0 END AS VarianceScore
		, l.CategoryDescription
		, CASE WHEN StatsMonth IN (1,2,3) THEN 1
				WHEN StatsMonth IN (4,5,6) THEN 2
				WHEN StatsMonth IN (7,8,9) THEN 3
				WHEN StatsMonth IN (10,11,12) THEN 4
				end AS StatsQuarter
		, CASE WHEN StatsMonth = 1 THEN 'Jan'
				WHEN StatsMonth = 2 THEN 'Feb'
				WHEN StatsMonth = 3 THEN 'Mar'
				WHEN StatsMonth = 4 THEN 'Apr'
				WHEN StatsMonth = 5 THEN 'May'
				WHEN StatsMonth = 6 THEN 'June'
				WHEN StatsMonth = 7 THEN 'July'
				WHEN StatsMonth = 8 THEN 'Aug'
				WHEN StatsMonth = 9 THEN 'Sept'
				WHEN StatsMonth = 10 THEN 'Oct'
				WHEN StatsMonth = 11 THEN 'Nov'
				WHEN StatsMonth = 12 THEN 'Dec'
				end AS MonthAbbrev
		, CASE WHEN StatsMonth = 1 THEN 'Jan-' + CAST(StatsYear AS char(4))
				WHEN StatsMonth = 2 THEN 'Feb-' + CAST(StatsYear AS char(4))
				WHEN StatsMonth = 3 THEN 'Mar-' + CAST(StatsYear AS char(4))
				WHEN StatsMonth = 4 THEN 'Apr-' + CAST(StatsYear AS char(4))
				WHEN StatsMonth = 5 THEN 'May-' + CAST(StatsYear AS char(4))
				WHEN StatsMonth = 6 THEN 'June-' + CAST(StatsYear AS char(4))
				WHEN StatsMonth = 7 THEN 'July-' + CAST(StatsYear AS char(4))
				WHEN StatsMonth = 8 THEN 'Aug-' + CAST(StatsYear AS char(4))
				WHEN StatsMonth = 9 THEN 'Sept-' + CAST(StatsYear AS char(4))
				WHEN StatsMonth = 10 THEN 'Oct-' + CAST(StatsYear AS char(4))
				WHEN StatsMonth = 11 THEN 'Nov-' + CAST(StatsYear AS char(4))
				WHEN StatsMonth = 12 THEN 'Dec-' + CAST(StatsYear AS char(4))
				end AS MonthYear
		, CAST(StatsYear AS char(4)) + '-' + dbo.PadL(StatsMonth, 2, '0') AS YearMonth
	FROM ProfitLoss p WITH (NOLOCK)
	INNER JOIN LineItemCategory l WITH (NOLOCK)
		on p.LineItemCategoryId = l.LineItemCategoryId

GO
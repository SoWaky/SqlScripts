-- SELECT * FROM vw_CompanyStatsLast30Days

------------------------------------------------------------
-- The vw_CompanyStatsLast30Days View includes all fields from the CompanyStatsLast30Days table 
--	and adds calculated fields at the end
--	They roll up to Year + Month + Company_Name
------------------------------------------------------------

USE MSP_Dashboard
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CompanyStatsLast30Days]'))
	DROP VIEW dbo.vw_CompanyStatsLast30Days
GO

CREATE VIEW dbo.vw_CompanyStatsLast30Days
AS 
SELECT ms.*
		, CAST(CASE WHEN Num_Reactive_Tickets_Opened > 0 THEN (cast(Num_Reactive_Tickets_Same_Day_Close as decimal(20,2)) / cast(Num_Reactive_Tickets_Opened as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Tickets_Closed_Same_Day_Pct	-- Same Day Resolution
		, CAST(CASE WHEN Num_Reactive_Tickets_Closed > 0 THEN (cast(Num_Reactive_Hours_On_Closed_Tickets as decimal(20,2)) / cast(Num_Reactive_Tickets_Closed as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Hours_Per_Ticket	-- Time to Resolution
		, CAST(CASE WHEN Num_Reactive_Tickets_Closed > 0 THEN (cast(Num_Reactive_Hours_On_Closed_Tickets as decimal(20,2)) / cast(Num_Reactive_Tickets_Closed as decimal(20,2))) ELSE 0 END * 60 AS decimal(20,2)) AS Avg_Minutes_Per_Ticket	-- Time to Resolution
		, CAST(CASE WHEN Num_Endpoints > 0 THEN (cast(Num_Reactive_Tickets_Opened as decimal(20,2)) / cast(Num_Endpoints as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Tickets_Per_Endpoint	-- RTEM
		, CAST(CASE WHEN Num_Endpoints > 0 THEN (cast(Num_Reactive_Hours as decimal(20,2)) / cast(Num_Endpoints as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Hours_Per_Endpoint	-- RHEM
		, CAST(CASE WHEN Num_Seats > 0 THEN (cast(Num_Reactive_Tickets_Opened as decimal(20,2)) / cast(Num_Seats as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Tickets_Per_Seat	-- RTSM
		, CAST(CASE WHEN Num_Seats > 0 THEN (cast(Num_Reactive_Hours AS decimal(20,2)) / cast(Num_Seats AS decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Hours_Per_Seat	-- RHSM
		, CAST(CASE WHEN Num_Reactive_Hours > 0 THEN (cast(CASE WHEN MRR_Amount > 0 THEN MRR_Amount ELSE ORR_Amount END as decimal(20,2)) / cast(Num_Reactive_Hours as decimal(20,2))) ELSE 0 END as decimal(20,2)) AS Avg_Revenue_Per_Hour	-- MRR_Run_Rate
		, CAST(CASE WHEN Num_Reactive_Tickets_Closed > 0 THEN (cast(Num_Reactive_Tickets_Resolved_On_Time as decimal(20,2)) / cast(Num_Reactive_Tickets_Closed as decimal(20,2))) ELSE 1.00 END AS decimal(20,2)) AS SLA_Met_Pct	-- SLA Met %
		, c.ActiveInd as Company_Is_Active
	FROM MSP_Dashboard.dbo.CompanyStatsLast30Days ms WITH (NOLOCK)
	LEFT JOIN MSP_Dashboard.dbo.Company c
		ON c.Company_Name = ms.Company_Name

GO
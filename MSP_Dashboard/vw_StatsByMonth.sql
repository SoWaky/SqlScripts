-- SELECT * FROM vw_StatsByMonth order by 1,2

------------------------------------------------------------
-- The vw_StatsByMonth View includes all fields from the CompanyStatsByMonth table, except for the Company fields
--	It sums aggregate fields and adds calculated fields at the end
--	They roll up to Year + Month
------------------------------------------------------------

USE MSP_Dashboard
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_StatsByMonth]'))
	DROP VIEW dbo.vw_StatsByMonth
GO

CREATE VIEW dbo.vw_StatsByMonth
AS 
SELECT StatsYear, StatsMonth
		, COUNT(*) AS Num_Clients
		, SUM(Num_Seats) AS Num_Seats
		, SUM(Num_Endpoints) AS Num_Endpoints
		, SUM(Num_Endpoints_Missing_Patches) AS Num_Endpoints_Missing_Patches
		, SUM(MRR_Amount) AS MRR_Amount
		, SUM(ORR_Amount) AS ORR_Amount
		, CASE WHEN SUM(Num_Seats) > 0 THEN (SUM(MRR_Amount) + SUM(ORR_Amount)) / SUM(Num_Seats) ELSE 0 END AS AISP_Amount
		, SUM(Num_Reactive_Tickets_Opened) AS Num_Reactive_Tickets
		, SUM(Num_Reactive_Tickets_Closed) AS Num_Reactive_Tickets_Closed
		, SUM(Num_Reactive_Tickets_Resolved_On_Time) AS Num_Reactive_Tickets_Resolved_On_Time
		, SUM(Num_Reactive_Tickets_Same_Day_Response) AS Num_Reactive_Tickets_Same_Day_Response
		, SUM(Num_Reactive_Tickets_Same_Day_Close) AS Num_Reactive_Tickets_Same_Day_Close
		, SUM(Num_Reactive_Hours) AS Num_Reactive_Hours
		, SUM(Num_Reactive_Hours_On_Closed_Tickets) AS Num_Reactive_Hours_On_Closed_Tickets
		, SUM(Num_CS_Hours) AS Num_CS_Hours
		, SUM(Num_NA_Hours) AS Num_NA_Hours
		, SUM(Num_PS_Hours) AS Num_PS_Hours
		, SUM(Num_vCIO_Hours) AS Num_vCIO_Hours
		, SUM(Num_Scheduled_NA_Visits) AS Num_Scheduled_NA_Visits
		, SUM(Num_Completed_NA_Visits) AS Num_Completed_NA_Visits
		, CAST(CASE WHEN SUM(Num_Reactive_Tickets_Opened) > 0 THEN (cast(SUM(Num_Reactive_Tickets_Same_Day_Close) as decimal(20,2)) / cast(SUM(Num_Reactive_Tickets_Opened) as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Tickets_Closed_Same_Day_Pct	-- Same Day Resolution
		, CAST(CASE WHEN SUM(Num_Reactive_Tickets_Closed) > 0 THEN (cast(SUM(Num_Reactive_Hours_On_Closed_Tickets) as decimal(20,2)) / cast(SUM(Num_Reactive_Tickets_Closed) as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Hours_Per_Ticket	-- Time to Resolution
		, CAST(CASE WHEN SUM(Num_Reactive_Tickets_Closed) > 0 THEN (cast(SUM(Num_Reactive_Hours_On_Closed_Tickets) as decimal(20,2)) / cast(SUM(Num_Reactive_Tickets_Closed) as decimal(20,2))) ELSE 0 END * 60 AS decimal(20,2)) AS Avg_Minutes_Per_Ticket	-- Time to Resolution
		, CAST(CASE WHEN SUM(Num_Endpoints) > 0 THEN (cast(SUM(Num_Reactive_Tickets_Opened) as decimal(20,2)) / cast(SUM(Num_Endpoints) as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Tickets_Per_Endpoint	-- RTEM
		, CAST(CASE WHEN SUM(Num_Endpoints) > 0 THEN (cast(SUM(Num_Reactive_Hours) AS decimal(20,2)) / cast(SUM(Num_Endpoints) AS decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Hours_Per_Endpoint	-- RHEM
		, CAST(CASE WHEN SUM(Num_Seats) > 0 THEN (cast(SUM(Num_Reactive_Tickets_Opened) as decimal(20,2)) / cast(SUM(Num_Seats) as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Tickets_Per_Seat	-- RTSM
		, CAST(CASE WHEN SUM(Num_Seats) > 0 THEN (cast(SUM(Num_Reactive_Hours) AS decimal(20,2)) / cast(SUM(Num_Seats) AS decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Hours_Per_Seat	-- RHSM
		, CAST(CASE WHEN SUM(Num_Reactive_Hours) > 0 THEN ((SUM(MRR_Amount) + SUM(ORR_Amount)) / cast(SUM(Num_Reactive_Hours) as decimal(20,2))) ELSE 0 END as decimal(20,2)) AS Avg_Revenue_Per_Hour	-- MRR_Run_Rate
		, CAST(CASE WHEN SUM(Num_Reactive_Tickets_Closed) > 0 THEN (cast(SUM(Num_Reactive_Tickets_Resolved_On_Time) as decimal(20,2)) / cast(SUM(Num_Reactive_Tickets_Closed) as decimal(20,2))) ELSE 1.00 END AS decimal(20,2)) AS SLA_Met_Pct	-- SLA Met %
		, COUNT(*) AS Num_Companies
	FROM MSP_Dashboard.dbo.CompanyStatsByMonth ms WITH (NOLOCK)
	WHERE Company_Type IN ('10 Client - Managed Services', '15 Client - Modular Services')
	GROUP BY StatsYear, StatsMonth
GO
-- SELECT * FROM vw_CompanyStatsByQuarter

------------------------------------------------------------
-- The vw_QuarterlyStats View includes all fields from the CompanyStatsByMonth table 
--	It sums aggregate fields and adds calculated fields at the end
--	They roll up to Year + Quarter + Company_Name
------------------------------------------------------------

USE MSP_Dashboard
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_CompanyStatsByQuarter]'))
	DROP VIEW dbo.vw_CompanyStatsByQuarter
GO

CREATE VIEW dbo.vw_CompanyStatsByQuarter
AS 
SELECT StatsYear
		, CASE WHEN StatsMonth IN (1,2,3) Then 1
				WHEN StatsMonth IN (4,5,6) Then 2
				WHEN StatsMonth IN (7,8,9) Then 3
				ELSE 4 END AS StatsQuarter
		, Company_Name
		, Company_Type

		-- Get value as it was at the end of the quarter: Use this logic to get a fixed number from the record for the last month in the quarter
		, SUM(CASE WHEN (StatsYear < datepart(year, getdate()) AND StatsMonth IN (3,6,9,12))
						OR (StatsYear = datepart(year, getdate()) AND (datepart(month, getdate()) = 12 AND StatsMonth IN (3,6,9,12)
																		OR datepart(month, getdate()) = 11 AND StatsMonth IN (3,6,9,11)
																		OR datepart(month, getdate()) = 10 AND StatsMonth IN (3,6,9,10)
																		OR datepart(month, getdate()) = 9 AND StatsMonth IN (3,6,9)
																		OR datepart(month, getdate()) = 8 AND StatsMonth IN (3,6,8)
																		OR datepart(month, getdate()) = 7 AND StatsMonth IN (3,6,7)
																		OR datepart(month, getdate()) = 6 AND StatsMonth IN (3,6)
																		OR datepart(month, getdate()) = 5 AND StatsMonth IN (3,5)
																		OR datepart(month, getdate()) = 4 AND StatsMonth IN (3,4)
																		OR datepart(month, getdate()) = 3 AND StatsMonth = 3
																		OR datepart(month, getdate()) = 2 AND StatsMonth = 2
																		OR datepart(month, getdate()) = 1 AND StatsMonth = 1)
							)
						THEN Num_Seats ELSE 0 END) AS Num_Seats
		, SUM(CASE WHEN (StatsYear < datepart(year, getdate()) AND StatsMonth IN (3,6,9,12))
						OR (StatsYear = datepart(year, getdate()) AND (datepart(month, getdate()) = 12 AND StatsMonth IN (3,6,9,12)
																		OR datepart(month, getdate()) = 11 AND StatsMonth IN (3,6,9,11)
																		OR datepart(month, getdate()) = 10 AND StatsMonth IN (3,6,9,10)
																		OR datepart(month, getdate()) = 9 AND StatsMonth IN (3,6,9)
																		OR datepart(month, getdate()) = 8 AND StatsMonth IN (3,6,8)
																		OR datepart(month, getdate()) = 7 AND StatsMonth IN (3,6,7)
																		OR datepart(month, getdate()) = 6 AND StatsMonth IN (3,6)
																		OR datepart(month, getdate()) = 5 AND StatsMonth IN (3,5)
																		OR datepart(month, getdate()) = 4 AND StatsMonth IN (3,4)
																		OR datepart(month, getdate()) = 3 AND StatsMonth = 3
																		OR datepart(month, getdate()) = 2 AND StatsMonth = 2
																		OR datepart(month, getdate()) = 1 AND StatsMonth = 1)
							)
						THEN Num_Endpoints ELSE 0 END) AS Num_Endpoints
		, SUM(CASE WHEN (StatsYear < datepart(year, getdate()) AND StatsMonth IN (3,6,9,12))
						OR (StatsYear = datepart(year, getdate()) AND (datepart(month, getdate()) = 12 AND StatsMonth IN (3,6,9,12)
																		OR datepart(month, getdate()) = 11 AND StatsMonth IN (3,6,9,11)
																		OR datepart(month, getdate()) = 10 AND StatsMonth IN (3,6,9,10)
																		OR datepart(month, getdate()) = 9 AND StatsMonth IN (3,6,9)
																		OR datepart(month, getdate()) = 8 AND StatsMonth IN (3,6,8)
																		OR datepart(month, getdate()) = 7 AND StatsMonth IN (3,6,7)
																		OR datepart(month, getdate()) = 6 AND StatsMonth IN (3,6)
																		OR datepart(month, getdate()) = 5 AND StatsMonth IN (3,5)
																		OR datepart(month, getdate()) = 4 AND StatsMonth IN (3,4)
																		OR datepart(month, getdate()) = 3 AND StatsMonth = 3
																		OR datepart(month, getdate()) = 2 AND StatsMonth = 2
																		OR datepart(month, getdate()) = 1 AND StatsMonth = 1)
							)
						THEN Num_Servers ELSE 0 END) AS Num_Servers
		, SUM(CASE WHEN (StatsYear < datepart(year, getdate()) AND StatsMonth IN (3,6,9,12))
						OR (StatsYear = datepart(year, getdate()) AND (datepart(month, getdate()) = 12 AND StatsMonth IN (3,6,9,12)
																		OR datepart(month, getdate()) = 11 AND StatsMonth IN (3,6,9,11)
																		OR datepart(month, getdate()) = 10 AND StatsMonth IN (3,6,9,10)
																		OR datepart(month, getdate()) = 9 AND StatsMonth IN (3,6,9)
																		OR datepart(month, getdate()) = 8 AND StatsMonth IN (3,6,8)
																		OR datepart(month, getdate()) = 7 AND StatsMonth IN (3,6,7)
																		OR datepart(month, getdate()) = 6 AND StatsMonth IN (3,6)
																		OR datepart(month, getdate()) = 5 AND StatsMonth IN (3,5)
																		OR datepart(month, getdate()) = 4 AND StatsMonth IN (3,4)
																		OR datepart(month, getdate()) = 3 AND StatsMonth = 3
																		OR datepart(month, getdate()) = 2 AND StatsMonth = 2
																		OR datepart(month, getdate()) = 1 AND StatsMonth = 1)
							)
						THEN Num_Workstations ELSE 0 END) AS Num_Workstations
		, SUM(CASE WHEN (StatsYear < datepart(year, getdate()) AND StatsMonth IN (3,6,9,12))
						OR (StatsYear = datepart(year, getdate()) AND (datepart(month, getdate()) = 12 AND StatsMonth IN (3,6,9,12)
																		OR datepart(month, getdate()) = 11 AND StatsMonth IN (3,6,9,11)
																		OR datepart(month, getdate()) = 10 AND StatsMonth IN (3,6,9,10)
																		OR datepart(month, getdate()) = 9 AND StatsMonth IN (3,6,9)
																		OR datepart(month, getdate()) = 8 AND StatsMonth IN (3,6,8)
																		OR datepart(month, getdate()) = 7 AND StatsMonth IN (3,6,7)
																		OR datepart(month, getdate()) = 6 AND StatsMonth IN (3,6)
																		OR datepart(month, getdate()) = 5 AND StatsMonth IN (3,5)
																		OR datepart(month, getdate()) = 4 AND StatsMonth IN (3,4)
																		OR datepart(month, getdate()) = 3 AND StatsMonth = 3
																		OR datepart(month, getdate()) = 2 AND StatsMonth = 2
																		OR datepart(month, getdate()) = 1 AND StatsMonth = 1)
							)
						THEN Num_Other_Devices ELSE 0 END) AS Num_Other_Devices
		, SUM(CASE WHEN (StatsYear < datepart(year, getdate()) AND StatsMonth IN (3,6,9,12))
						OR (StatsYear = datepart(year, getdate()) AND (datepart(month, getdate()) = 12 AND StatsMonth IN (3,6,9,12)
																		OR datepart(month, getdate()) = 11 AND StatsMonth IN (3,6,9,11)
																		OR datepart(month, getdate()) = 10 AND StatsMonth IN (3,6,9,10)
																		OR datepart(month, getdate()) = 9 AND StatsMonth IN (3,6,9)
																		OR datepart(month, getdate()) = 8 AND StatsMonth IN (3,6,8)
																		OR datepart(month, getdate()) = 7 AND StatsMonth IN (3,6,7)
																		OR datepart(month, getdate()) = 6 AND StatsMonth IN (3,6)
																		OR datepart(month, getdate()) = 5 AND StatsMonth IN (3,5)
																		OR datepart(month, getdate()) = 4 AND StatsMonth IN (3,4)
																		OR datepart(month, getdate()) = 3 AND StatsMonth = 3
																		OR datepart(month, getdate()) = 2 AND StatsMonth = 2
																		OR datepart(month, getdate()) = 1 AND StatsMonth = 1)
							)
						THEN Num_Endpoints_Missing_Patches ELSE 0 END) AS Num_Endpoints_Missing_Patches
		, SUM(CASE WHEN (StatsYear < datepart(year, getdate()) AND StatsMonth IN (3,6,9,12))
						OR (StatsYear = datepart(year, getdate()) AND (datepart(month, getdate()) = 12 AND StatsMonth IN (3,6,9,12)
																		OR datepart(month, getdate()) = 11 AND StatsMonth IN (3,6,9,11)
																		OR datepart(month, getdate()) = 10 AND StatsMonth IN (3,6,9,10)
																		OR datepart(month, getdate()) = 9 AND StatsMonth IN (3,6,9)
																		OR datepart(month, getdate()) = 8 AND StatsMonth IN (3,6,8)
																		OR datepart(month, getdate()) = 7 AND StatsMonth IN (3,6,7)
																		OR datepart(month, getdate()) = 6 AND StatsMonth IN (3,6)
																		OR datepart(month, getdate()) = 5 AND StatsMonth IN (3,5)
																		OR datepart(month, getdate()) = 4 AND StatsMonth IN (3,4)
																		OR datepart(month, getdate()) = 3 AND StatsMonth = 3
																		OR datepart(month, getdate()) = 2 AND StatsMonth = 2
																		OR datepart(month, getdate()) = 1 AND StatsMonth = 1)
							)
						THEN MRR_Amount ELSE 0 END) AS MRR_Amount
		, SUM(CASE WHEN (StatsYear < datepart(year, getdate()) AND StatsMonth IN (3,6,9,12))
						OR (StatsYear = datepart(year, getdate()) AND (datepart(month, getdate()) = 12 AND StatsMonth IN (3,6,9,12)
																		OR datepart(month, getdate()) = 11 AND StatsMonth IN (3,6,9,11)
																		OR datepart(month, getdate()) = 10 AND StatsMonth IN (3,6,9,10)
																		OR datepart(month, getdate()) = 9 AND StatsMonth IN (3,6,9)
																		OR datepart(month, getdate()) = 8 AND StatsMonth IN (3,6,8)
																		OR datepart(month, getdate()) = 7 AND StatsMonth IN (3,6,7)
																		OR datepart(month, getdate()) = 6 AND StatsMonth IN (3,6)
																		OR datepart(month, getdate()) = 5 AND StatsMonth IN (3,5)
																		OR datepart(month, getdate()) = 4 AND StatsMonth IN (3,4)
																		OR datepart(month, getdate()) = 3 AND StatsMonth = 3
																		OR datepart(month, getdate()) = 2 AND StatsMonth = 2
																		OR datepart(month, getdate()) = 1 AND StatsMonth = 1)
							)
						THEN NRR_Amount ELSE 0 END) AS NRR_Amount
		, SUM(CASE WHEN (StatsYear < datepart(year, getdate()) AND StatsMonth IN (3,6,9,12))
						OR (StatsYear = datepart(year, getdate()) AND (datepart(month, getdate()) = 12 AND StatsMonth IN (3,6,9,12)
																		OR datepart(month, getdate()) = 11 AND StatsMonth IN (3,6,9,11)
																		OR datepart(month, getdate()) = 10 AND StatsMonth IN (3,6,9,10)
																		OR datepart(month, getdate()) = 9 AND StatsMonth IN (3,6,9)
																		OR datepart(month, getdate()) = 8 AND StatsMonth IN (3,6,8)
																		OR datepart(month, getdate()) = 7 AND StatsMonth IN (3,6,7)
																		OR datepart(month, getdate()) = 6 AND StatsMonth IN (3,6)
																		OR datepart(month, getdate()) = 5 AND StatsMonth IN (3,5)
																		OR datepart(month, getdate()) = 4 AND StatsMonth IN (3,4)
																		OR datepart(month, getdate()) = 3 AND StatsMonth = 3
																		OR datepart(month, getdate()) = 2 AND StatsMonth = 2
																		OR datepart(month, getdate()) = 1 AND StatsMonth = 1)
							)
						THEN ORR_Amount ELSE 0 END) AS ORR_Amount
		, SUM(CASE WHEN (StatsYear < datepart(year, getdate()) AND StatsMonth IN (3,6,9,12))
						OR (StatsYear = datepart(year, getdate()) AND (datepart(month, getdate()) = 12 AND StatsMonth IN (3,6,9,12)
																		OR datepart(month, getdate()) = 11 AND StatsMonth IN (3,6,9,11)
																		OR datepart(month, getdate()) = 10 AND StatsMonth IN (3,6,9,10)
																		OR datepart(month, getdate()) = 9 AND StatsMonth IN (3,6,9)
																		OR datepart(month, getdate()) = 8 AND StatsMonth IN (3,6,8)
																		OR datepart(month, getdate()) = 7 AND StatsMonth IN (3,6,7)
																		OR datepart(month, getdate()) = 6 AND StatsMonth IN (3,6)
																		OR datepart(month, getdate()) = 5 AND StatsMonth IN (3,5)
																		OR datepart(month, getdate()) = 4 AND StatsMonth IN (3,4)
																		OR datepart(month, getdate()) = 3 AND StatsMonth = 3
																		OR datepart(month, getdate()) = 2 AND StatsMonth = 2
																		OR datepart(month, getdate()) = 1 AND StatsMonth = 1)
							)
						THEN AISP_Amount ELSE 0 END) AS AISP_Amount
		, SUM(Num_Reactive_Tickets_Opened) AS Num_Reactive_Tickets_Opened
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
		, CAST(CASE WHEN SUM(Num_Endpoints) > 0 THEN (cast(SUM(Num_Reactive_Hours) as decimal(20,2)) / cast(SUM(Num_Endpoints) as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Hours_Per_Endpoint	-- RHEM
		, CAST(CASE WHEN SUM(Num_Seats) > 0 THEN (cast(SUM(Num_Reactive_Tickets_Opened) as decimal(20,2)) / cast(SUM(Num_Seats) as decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Tickets_Per_Seat	-- RTSM
		, CAST(CASE WHEN SUM(Num_Seats) > 0 THEN (cast(SUM(Num_Reactive_Hours) AS decimal(20,2)) / cast(SUM(Num_Seats) AS decimal(20,2))) ELSE 0 END AS decimal(20,2)) AS Avg_Hours_Per_Seat	-- RHSM
		, CAST(CASE WHEN SUM(Num_Reactive_Hours) > 0 THEN (SUM(CASE WHEN MRR_Amount > 0 THEN MRR_Amount ELSE ORR_Amount END) / cast(SUM(Num_Reactive_Hours) as decimal(20,2))) ELSE 0 END as decimal(20,2)) AS Avg_Revenue_Per_Hour	-- MRR_Run_Rate
		, CAST(CASE WHEN SUM(Num_Reactive_Tickets_Closed) > 0 THEN (cast(SUM(Num_Reactive_Tickets_Resolved_On_Time) as decimal(20,2)) / cast(SUM(Num_Reactive_Tickets_Closed) as decimal(20,2))) ELSE 1.00 END AS decimal(20,2)) AS SLA_Met_Pct	-- SLA Met %
	FROM MSP_Dashboard.dbo.CompanyStatsByMonth ms WITH (NOLOCK)
	GROUP BY StatsYear
		, CASE WHEN StatsMonth IN (1,2,3) Then 1
				WHEN StatsMonth IN (4,5,6) Then 2
				WHEN StatsMonth IN (7,8,9) Then 3
				ELSE 4 END
		, Company_Name, Company_Type
GO
-- SELECT * FROM vw_HoursByWeek

------------------------------------------------------------
-- The vw_StatsByMonth View includes all fields from the CompanyStatsByMonth table, except for the Company fields
--	It sums aggregate fields and adds calculated fields at the end
--	They roll up to Year + Month
------------------------------------------------------------

USE MSP_Dashboard
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_HoursByWeek]'))
	DROP VIEW dbo.vw_HoursByWeek
GO

CREATE VIEW dbo.vw_HoursByWeek
AS 
SELECT *
	FROM HoursByWeek
/*
   Wednesday, July 5, 20171:09:49 PM
   User: MPrice
   Server: WebW12Srv01
   Database: MSP_Dashboard
   Table: CompanyStatsLast30Days 
*/

USE MSP_Dashboard
GO

BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO

------------------------------------------------------------
-- The CompanyStatsLast30Days table tracks all statistics that need to be frozen and reported at a minimum at the month level
--	They roll up to Year + Month + Company_Id
------------------------------------------------------------

-- SELECT * FROM dbo.CompanyStatsLast30Days
-- DROP TABLE dbo.CompanyStatsLast30Days
-- ALTER TABLE CompanyStatsLast30Days ADD  Num_Endpoints_Missing_Patches smallint NULL

CREATE TABLE dbo.CompanyStatsLast30Days
	(
	CompanyStatsLast30Days_ID int NOT NULL IDENTITY (1, 1),
	Company_Type varchar(100) NOT NULL,
	Company_Name varchar(100) NOT NULL,
	Num_Seats decimal(10, 2)  NOT NULL,
	Num_Seats_Agreement decimal(10, 2) NOT NULL,
	Num_Endpoints smallint NOT NULL,
	MRR_Amount money NOT NULL,
	NRR_Amount money NOT NULL,
	ORR_Amount money NOT NULL,
	AISP_Amount money NOT NULL,
	Num_Reactive_Tickets_Opened int NOT NULL,
	Num_Reactive_Tickets_Closed int NOT NULL,
	Num_Reactive_Tickets_Same_Day_Response int NOT NULL,
	Num_Reactive_Tickets_Same_Day_Close int NOT NULL,
	Num_Reactive_Hours decimal(20, 2) NOT NULL,
	Num_CS_Hours decimal(20, 2) NOT NULL,
	Num_NA_Hours decimal(20, 2) NOT NULL,
	Num_PS_Hours decimal(20, 2) NOT NULL,
	Num_vCIO_Hours decimal(20, 2) NOT NULL,
	Num_Scheduled_NA_Visits smallint NOT NULL,
	Num_Completed_NA_Visits smallint NOT NULL,
	Num_Scheduled_vCIO_Meetings smallint NOT NULL,
	Num_Completed_vCIO_Meetings smallint NOT NULL,
	Patch_Score DECIMAL(20,4) NULL,
	Add_Date_Time datetime NOT NULL,
	Update_Date_Time datetime NULL,
	Client_Priority_List_Num int NOT NULL,
	Num_Endpoints_Missing_Patches smallint NULL
	)  ON [PRIMARY]
GO

ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Company_Type DEFAULT ('') FOR Company_Type
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Company_Name DEFAULT ('') FOR Company_Name
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Seats DEFAULT (0) FOR Num_Seats
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Seats_Agreement DEFAULT (0) FOR Num_Seats_Agreement
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Endpoints DEFAULT (0) FOR Num_Endpoints
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_MRR_Amount DEFAULT (0) FOR MRR_Amount
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_NRR_Amount DEFAULT (0) FOR NRR_Amount
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_ORR_Amount DEFAULT (0) FOR ORR_Amount
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_AISP_Amount DEFAULT (0) FOR AISP_Amount
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Reactive_Tickets_Opened DEFAULT (0) FOR Num_Reactive_Tickets_Opened
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Reactive_Tickets_Closed DEFAULT (0) FOR Num_Reactive_Tickets_Closed
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Reactive_Tickets_Same_Day_Response DEFAULT (0) FOR Num_Reactive_Tickets_Same_Day_Response
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Reactive_Tickets_Same_Day_Close DEFAULT (0) FOR Num_Reactive_Tickets_Same_Day_Close
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Reactive_Hours DEFAULT (0) FOR Num_Reactive_Hours
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_CS_Hours DEFAULT (0) FOR Num_CS_Hours
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_NA_Hours DEFAULT (0) FOR Num_NA_Hours
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_PS_Hours DEFAULT (0) FOR Num_PS_Hours
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_vCIO_Hours DEFAULT (0) FOR Num_vCIO_Hours
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Scheduled_NA_Visits DEFAULT (0) FOR Num_Scheduled_NA_Visits
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Completed_NA_Visits DEFAULT (0) FOR Num_Completed_NA_Visits
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Scheduled_vCIO_Meetings DEFAULT (0) FOR Num_Scheduled_vCIO_Meetings
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Num_Completed_vCIO_Meetings DEFAULT (0) FOR Num_Completed_vCIO_Meetings
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Add_Date_Time DEFAULT GETDATE() FOR Add_Date_Time
GO
ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	DF_CompanyStatsLast30Days_Client_Priority_List_Num DEFAULT (0) FOR Client_Priority_List_Num
GO

ALTER TABLE dbo.CompanyStatsLast30Days ADD CONSTRAINT
	PK_CompanyStatsLast30Days PRIMARY KEY CLUSTERED 
	(
	CompanyStatsLast30Days_ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX IX_CompanyStatsLast30Days_CompanyName ON dbo.CompanyStatsLast30Days
	(
	Company_Name
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.CompanyStatsLast30Days SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


---------------------------------------------------------------------
-- Triggers must be run in their own batch, so open the TR_*.sql files for this table and run those as well!



/*
   Wednesday, July 5, 20171:09:49 PM
   User: MPrice
   Server: WebW12Srv01
   Database: MSP_Dashboard
   Table: WeeklyStats 
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
-- The WeeklyStats table tracks all statistics that need to be frozen and reported at a minimum at the week level
--	They roll up to FirstDateOfWeek + Company_Id
------------------------------------------------------------
CREATE TABLE dbo.WeeklyStats
	(
	WeeklyStats_ID int NOT NULL IDENTITY (1, 1),
	FirstDateOfWeek date NOT NULL,
	Company_Name varchar(50) NOT NULL,
	Num_Reactive_Tickets int NOT NULL,
	Num_Reactive_Tickets_Same_Day_Response int NOT NULL,
	Num_Reactive_Tickets_Same_Day_Close int NOT NULL,
	Num_Reactive_Hours decimal(20, 2) NOT NULL,
	Num_CS_Hours decimal(20, 2) NOT NULL,
	Num_NA_Hours decimal(20, 2) NOT NULL,
	Num_PS_Hours decimal(20, 2) NOT NULL,
	Num_vCIO_Hours decimal(20, 2) NOT NULL,
	Add_Date_Time datetime NOT NULL,
	Update_Date_Time datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.WeeklyStats ADD CONSTRAINT
	DF_WeeklyStats_Company_Name DEFAULT ('') FOR Company_Name
GO
ALTER TABLE dbo.WeeklyStats ADD CONSTRAINT
	DF_WeeklyStats_Num_Reactive_Tickets DEFAULT (0) FOR Num_Reactive_Tickets
GO
ALTER TABLE dbo.WeeklyStats ADD CONSTRAINT
	DF_WeeklyStats_Num_Reactive_Tickets_Same_Day_Response DEFAULT (0) FOR Num_Reactive_Tickets_Same_Day_Response
GO
ALTER TABLE dbo.WeeklyStats ADD CONSTRAINT
	DF_WeeklyStats_Num_Reactive_Tickets_Same_Day_Close DEFAULT (0) FOR Num_Reactive_Tickets_Same_Day_Close
GO
ALTER TABLE dbo.WeeklyStats ADD CONSTRAINT
	DF_WeeklyStats_Num_Reactive_Hours DEFAULT (0) FOR Num_Reactive_Hours
GO
ALTER TABLE dbo.WeeklyStats ADD CONSTRAINT
	DF_WeeklyStats_Num_CS_Hours DEFAULT (0) FOR Num_CS_Hours
GO
ALTER TABLE dbo.WeeklyStats ADD CONSTRAINT
	DF_WeeklyStats_Num_NA_Hours DEFAULT (0) FOR Num_NA_Hours
GO
ALTER TABLE dbo.WeeklyStats ADD CONSTRAINT
	DF_WeeklyStats_Num_PS_Hours DEFAULT (0) FOR Num_PS_Hours
GO
ALTER TABLE dbo.WeeklyStats ADD CONSTRAINT
	DF_WeeklyStats_Num_vCIO_Hours DEFAULT (0) FOR Num_vCIO_Hours
GO

ALTER TABLE dbo.WeeklyStats ADD CONSTRAINT
	DF_WeeklyStats_Add_Date_Time DEFAULT GETDATE() FOR Add_Date_Time
GO
ALTER TABLE dbo.WeeklyStats ADD CONSTRAINT
	PK_WeeklyStats PRIMARY KEY CLUSTERED 
	(
	WeeklyStats_ID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX IX_WeeklyStats_FirstDateOfWeek ON dbo.WeeklyStats
	(
	FirstDateOfWeek
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.WeeklyStats SET (LOCK_ESCALATION = TABLE)
GO
COMMIT

---------------------------------------------------------------------------
-- Create Palma's permissions in the Loaves database in Azure

-- Connect to the Master database and run this command:

use master
CREATE LOGIN development WITH PASSWORD ='T@ch$.2012'
GO

-- Connect to each database in Azure and run these commands:
CREATE USER development WITH PASSWORD = 'T@ch$.2012'
alter role db_datareader add member development
alter role db_datawriter add member development
alter role db_owner add member development
GO

---------------------------------------------------------------------------
-- Create a special SQL Role to allow users to execute stored procedures without giving them DB_Owner

CREATE ROLE db_executor
GRANT EXECUTE TO db_executor
alter role db_executor add member development


---------------------------------------------------------------------------
-- Create remote connections from Loaves to Cares and OFC databases

-- Step 1 - Create USR_CROSS_DBMS user. Execute on all databases 

-- Remove existing user
DROP USER IF EXISTS [USR_CROSS_DBMS]
GO

-- Create new user
CREATE USER USR_CROSS_DBMS WITH PASSWORD = 'a;skdfjoij2#$5jwrfj',
  DEFAULT_SCHEMA=[ACTIVE] 
GO

-- Add user to the database owner role
EXEC sp_addrolemember N'db_owner', N'USR_CROSS_DBMS'
GO

-- Step 2 - Create master key on the Loaves database

-- Drop master key
IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
DROP MASTER KEY;


-- Create master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'AsSlkfi#45k*'; 
GO


-- Step 3 - Create Database Credentials for the USR_CROSS_DBMS user

-- Drop db credential
IF EXISTS(SELECT * FROM sys.database_credentials WHERE name = 'CRD_CROSS_DBMS')
DROP DATABASE SCOPED CREDENTIAL CRD_CROSS_DBMS ;  
GO 

-- Create db credential
CREATE DATABASE SCOPED CREDENTIAL CRD_CROSS_DBMS 
WITH IDENTITY = 'USR_CROSS_DBMS', 
SECRET = 'a;skdfjoij2#$5jwrfj';  
GO

-- Step 4 - Create External Datasource on Loaves pointing to the other 2 databases
CREATE EXTERNAL DATA SOURCE OFC  
    WITH (   
        TYPE = RDBMS,  
        LOCATION = 'webitdevops.database.windows.net',  
        DATABASE_NAME = 'OFC',  
        CREDENTIAL = CRD_CROSS_DBMS
    )  
GO

CREATE EXTERNAL DATA SOURCE Cares  
    WITH (   
        TYPE = RDBMS,  
        LOCATION = 'webitdevops.database.windows.net',  
        DATABASE_NAME = 'Cares',  
        CREDENTIAL = CRD_CROSS_DBMS
    )  
GO

-- Step 5 - Create Schemas in Loaves for each of the remote databases.  
--	Storing external tables for each remote database in their own schema will keep track of which table points to which database

CREATE SCHEMA [CARES] AUTHORIZATION [dbo]
GO

CREATE SCHEMA [OFC] AUTHORIZATION [dbo]
GO

-- Step 6 - Create External Tables
-- An External Table must be created inside Loaves for each table in OFC and Cares that need to be JOINed to
-- the table structure of the External table must exactly matche the structure of the real table
--
-- The easiest way found so far, is to go to those databases in SSMS and Tasks - Generate Scripts for all tables
-- Then change the schema, change "CREATE TABLE" to "CREATE EXTERNAL TABLE", remove INDENTITY(1,1), and close the table command with the DATA_SOURCE
-- If the remote table is in the DBO schema and you want to make the local external table in a different schema the command needs to specify the remote schema in the WITH clause
--		with (data_source = Cares, schema_name = N'DBO', object_name = N'AgeGroup')

-- Example:
CREATE EXTERNAL TABLE [dbo].[CaresTableName]
( [ID] [int] NOT NULL,
  [Field1] [varchar](50) NOT NULL,
  [Field2] [varchar](50) NOT NULL)
WITH
( DATA_SOURCE = Cares)

-----------------------------------------------------------------------------------------
-- CARES External Tables

CREATE EXTERNAL TABLE CARES.AgeGroup(
	[ID] [int]  NOT NULL,
	[Age Group] [nvarchar](50) NULL,
	[Low] [int] NULL,
	[High] [int] NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'AgeGroup')
GO

/****** Object:  Table [Cares].[Application]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Application](
	[ID] [int]  NOT NULL,
	[HouseholdID] [int] NULL,
	[ResidentID] [int] NULL,
	[ContactsID] [int] NULL,
	[ApplicationStatus] [nvarchar](51) NULL,
	[ApplicationDate] [datetime2](0) NULL,
	[ApplicationTakenBy] [nvarchar](51) NULL,
	[Request] [nvarchar](51) NULL,
	[FirstCalltoCares] [bit] NULL,
	[ReferredBy] [nvarchar](101) NULL,
	[ApplicantFirstName] [nvarchar](51) NULL,
	[ApplicantMI] [nvarchar](1) NULL,
	[ApplicantLastName] [nvarchar](51) NULL,
	[SSN] [nvarchar](11) NULL,
	[DOB] [datetime2](0) NULL,
	[CityAccountNumber] [nvarchar](51) NULL,
	[ApplicantPhone1] [nvarchar](51) NULL,
	[ApplicantPhone2] [nvarchar](51) NULL,
	[ApplicantWorkPhone] [nvarchar](51) NULL,
	[ApplicantAddress] [nvarchar](101) NULL,
	[ApplicantAddress2] [nvarchar](51) NULL,
	[ApplicantCity] [nvarchar](51) NULL,
	[ApplicantState] [nvarchar](2) NULL,
	[ApplicantZip] [nvarchar](10) NULL,
	[ApplicantCounty] [nvarchar](51) NULL,
	[ApplicantTownship] [nvarchar](51) NULL,
	[HowLongatAddress] [nvarchar](51) NULL,
	[PreviousAddress] [nvarchar](101) NULL,
	[WhyDidYouLeave] [nvarchar](255) NULL,
	[MaritalStatus] [nvarchar](51) NULL,
	[LanguageSpoken] [nvarchar](51) NULL,
	[HighestLevelofEducation] [nvarchar](51) NULL,
	[HeadofHousehold] [bit] NULL,
	[DisabilityIncome] [bit] NULL,
	[CanClimbStairs] [bit] NULL,
	[ApplicantEmploymentStatus] [bit] NULL,
	[ApplicationtDuration] [nvarchar](51) NULL,
	[ApplicantEmployer] [nvarchar](51) NULL,
	[ApplicantEmployerPhone] [nvarchar](51) NULL,
	[ApplicantPosition] [nvarchar](51) NULL,
	[ApplicantHours] [nvarchar](51) NULL,
	[MayContactWork] [bit] NULL,
	[PartnerName] [nvarchar](51) NULL,
	[PartnerEmploymentStatus] [bit] NULL,
	[PartnerDuration] [nvarchar](51) NULL,
	[PartnerEmployer] [nvarchar](51) NULL,
	[PartnerEmployerPhone] [nvarchar](51) NULL,
	[PartnerPosition] [nvarchar](51) NULL,
	[PartnerHours] [nvarchar](51) NULL,
	[LandlordName] [nvarchar](101) NULL,
	[LandlordPayee] [nvarchar](101) NULL,
	[LandlordAddress] [nvarchar](101) NULL,
	[LandlordCityStateZip] [nvarchar](101) NULL,
	[LandlordPhone1] [nvarchar](51) NULL,
	[LandlordPhone2] [nvarchar](51) NULL,
	[FiveDayNoticeReceived] [datetime2](0) NULL,
	[HousingSubsidy] [bit] NULL,
	[HousingCaseManager] [nvarchar](101) NULL,
	[MayContactLL] [bit] NULL,
	[MonthlyBudget] [bit] NULL,
	[StudentLoan] [bit] NULL,
	[SignificantMedicalDebt] [bit] NULL,
	[SignificantCreditCardDebt] [bit] NULL,
	[PastEvications] [bit] NULL,
	[PaydayLoans] [bit] NULL,
	[Bankrupsy] [bit] NULL,
	[AverageMonthlyExpense] [float] NULL,
	[AverageMonthlyIncome] [float] NULL,
	[HowMuchDoYouOwe] [float] NULL,
	[HowMuchCanYouPay] [float] NULL,
	[Circumstances] [nvarchar](255) NULL,
	[WillYouBeOK] [nvarchar](255) NULL,
	[PlaceofWorship] [nvarchar](101) NULL,
	[Veteran] [bit] NULL,
	[ReceivingVeteranServices] [bit] NULL,
	[ContactedforHelp] [nvarchar](255) NULL,
	[DocAppointment] [datetime2](0) NULL,
	[HowMuchMedicalDebt] [nvarchar](101) NULL,
	[HowMuchCreditCardDebt] [nvarchar](101) NULL,
	[HowMuchStudentLoans] [nvarchar](101) NULL,
	[HowMuchPayDayLoans] [nvarchar](101) NULL,
	[LastContact] [datetime2](0) NULL,
	[ClientEmail] [nvarchar](255) NULL,
	[LLEmail] [nvarchar](255) NULL,
	[AssistanceMonth] [nvarchar](50) NULL,
	[TaxAssessorCalled] [bit] NULL,
	[AccessDuPageApp] [bit] NULL,
	[LIHEAPapp] [bit] NULL,
	[Referrals] [nvarchar](255) NULL,
	[AnnualGrossIncome] [float] NULL,
	[LastWorked] [nvarchar](255) NULL,
	[ChildCareSubsidy] [bit] NULL,
	[MonthlyGrossIncome] [float] NULL,
	[ComputerTraining] [bit] NULL,
	[EmotionalSupport] [bit] NULL,
	[ESL] [bit] NULL,
	[JobSearch] [bit] NULL,
	[Legal] [bit] NULL,
	[MoneyManagement] [bit] NULL,
	[Nutrition] [bit] NULL,
	[PublicBenefits] [bit] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Application')
GO
/****** Object:  Table [Cares].[CarOutcome]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[CarOutcome](
	[ID] [int]  NOT NULL,
	[ServiceOutcome] [nvarchar](50) NULL,
	[OutcomeCode] [nvarchar](5) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'CarOutcome')
GO
/****** Object:  Table [Cares].[CarRequests]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[CarRequests](
	[ID] [int]  NOT NULL,
	[HouseholdID] [int] NULL,
	[ContactID] [int] NULL,
	[WaitingList] [datetime2](0) NULL,
	[CarOutcome] [nvarchar](5) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'CarRequests')
GO
/****** Object:  Table [Cares].[Casework]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Casework](
	[ID] [int]  NOT NULL,
	[HouseholdID] [int] NULL,
	[ContactDate] [datetime2](0) NULL,
	[Event] [nvarchar](255) NULL,
	[Complete] [bit] NULL,
	[Notes] [nvarchar](max) NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Casework')
GO
/****** Object:  Table [Cares].[Contacts]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Contacts](
	[ID] [int]  NOT NULL,
	[Service Date] [datetime2](0) NULL,
	[Application Date] [datetime2](0) NULL,
	[Service Code] [nvarchar](255) NULL,
	[Service Outcome] [nvarchar](255) NULL,
	[HouseholdID] [int] NULL,
	[CaseManagement] [bit] NULL,
	[Notes] [nvarchar](max) NULL,
	[Referral] [nvarchar](20) NULL,
	[Requested] [money] NULL,
	[AlternateRequest] [bit] NULL,
	[ResidentID] [int] NOT NULL,
	[DeleteFlag] [bit] NULL,
	[ApplicationID] [int] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Contacts')
GO
/****** Object:  Table [Cares].[Events]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Events](
	[ID] [int]  NOT NULL,
	[Events] [nvarchar](255) NULL,
	[Required] [bit] NULL,
	[Sequence] [int] NULL,
	[Description] [nvarchar](255) NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Events')
GO
/****** Object:  Table [Cares].[Funds]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Funds](
	[ContactID] [int] NULL,
	[id] [int]  NOT NULL,
	[Donor] [nvarchar](50) NULL,
	[Funds] [float] NULL,
	[Service] [nvarchar](50) NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Funds')
GO
/****** Object:  Table [Cares].[Hours]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Hours](
	[ID] [int]  NOT NULL,
	[VolunteerName] [nvarchar](255) NULL,
	[DateWorked] [datetime2](0) NULL,
	[TimeIn] [datetime2](0) NULL,
	[TimeOut] [datetime2](0) NULL,
	[HoursWorked] [float] NULL,
	[VolunteerID] [int] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Hours')
GO
/****** Object:  Table [Cares].[Household]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Household](
	[ID] [int]  NOT NULL,
	[Date entered] [datetime2](0) NULL,
	[Last] [nvarchar](255) NULL,
	[First] [nvarchar](255) NULL,
	[Street] [nvarchar](255) NULL,
	[unit] [nvarchar](51) NULL,
	[City] [nvarchar](255) NULL,
	[Zip] [nvarchar](10) NULL,
	[State] [nvarchar](2) NULL,
	[Phone] [nvarchar](255) NULL,
	[Number of Children] [int] NULL,
	[Number in Household] [int] NULL,
	[Notes] [nvarchar](max) NULL,
	[Monthly Income] [money] NULL,
	[Owner] [bit] NULL,
	[ProjectHope] [bit] NULL,
	[Files Purged] [bit] NULL,
	[Subsidized] [bit] NULL,
	[DeleteFlag] [bit] NULL,
	[Primary Income Source] [nvarchar](255) NULL,
	[County] [nvarchar](10) NULL,
	[Landlord Name] [nvarchar](255) NULL,
	[Landlord Phone] [nvarchar](25) NULL,
	[City Account Number] [nvarchar](15) NULL,
	[Township] [nvarchar](255) NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Household')
GO
/****** Object:  Table [Cares].[IncomeSource]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[IncomeSource](
	[ID] [int]  NOT NULL,
	[IncomeSource] [nvarchar](255) NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'IncomeSource')
GO
/****** Object:  Table [Cares].[Language]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Language](
	[ID] [int]  NOT NULL,
	[Language] [nvarchar](50) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Language')
GO
/****** Object:  Table [Cares].[Leveraged Funds Donors]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Leveraged Funds Donors](
	[ID] [int]  NOT NULL,
	[Donors] [nvarchar](50) NULL,
	[CaresFund] [bit] NULL,
	[PublicFunds] [bit] NULL,
	[HMISMember] [bit] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Leveraged Funds Donors')
GO
/****** Object:  Table [Cares].[MFI]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[MFI](
	[ID] [int]  NOT NULL,
	[Household Size] [int] NULL,
	[Median Family Income] [float] NULL,
	[Federal Poverty Level monthly] [float] NULL,
	[Guideline Year] [int] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'MFI')
GO
/****** Object:  Table [Cares].[MSysCompactError]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[MSysCompactError](
	[ErrorCode] [int] NULL,
	[ErrorDescription] [nvarchar](max) NULL,
	[ErrorRecid] [varbinary](510) NULL,
	[ErrorTable] [nvarchar](255) NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'MSysCompactError')
GO
/****** Object:  Table [Cares].[Paste Errors]    Script Date: 8/15/2018 9:49:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Paste Errors](
	[Field0] [nvarchar](max) NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Paste Errors')
GO
/****** Object:  Table [Cares].[Race]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Race](
	[ID] [int]  NOT NULL,
	[Race] [nvarchar](50) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Race')
GO
/****** Object:  Table [Cares].[Referral]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Referral](
	[Referral] [nvarchar](20) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Referral')
GO
/****** Object:  Table [Cares].[Residents]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[Residents](
	[HouseholdID] [int] NOT NULL,
	[id] [int]  NOT NULL,
	[DOB] [datetime2](0) NULL,
	[Gender] [nvarchar](6) NULL,
	[Last] [nvarchar](50) NULL,
	[First] [nvarchar](50) NULL,
	[Relation] [nvarchar](50) NULL,
	[SSN] [nvarchar](11) NULL,
	[Disabled] [bit] NULL,
	[Employment] [bit] NULL,
	[Racial Identity] [nvarchar](50) NULL,
	[Primary Language] [nvarchar](50) NULL,
	[HeadofHousehold] [bit] NULL,
	[Phone] [nvarchar](20) NULL,
	[DeleteFlag] [bit] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'Residents')
GO
/****** Object:  Table [Cares].[ServiceCode]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[ServiceCode](
	[ID] [int]  NOT NULL,
	[Service] [nvarchar](50) NULL,
	[ServiceCode] [nvarchar](5) NULL,
	[Unused] [bit] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'ServiceCode')
GO
/****** Object:  Table [Cares].[ServiceOutcome]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[ServiceOutcome](
	[ID] [int]  NOT NULL,
	[ServiceOutcome] [nvarchar](50) NULL,
	[OutcomeCode] [nvarchar](5) NULL,
	[NoService] [bit] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'ServiceOutcome')
GO
/****** Object:  Table [Cares].[tblAppAppointment]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppAppointment](
	[ApptDate] [datetime2](0) NOT NULL,
	[ApptTime] [datetime2](0) NULL,
	[ApptSlotStatus] [nvarchar](255) NULL,
	[ApplicationID] [int] NULL,
	[ApptLocation] [nvarchar](255) NULL,
	[ID] [int]  NOT NULL,
	[VolunteerID] [nvarchar](255) NULL,
	[Comments] [nvarchar](255) NULL,
	[Confirmed] [bit] NULL,
	[ApptTopic] [nvarchar](25) NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppAppointment')
GO
/****** Object:  Table [Cares].[tblAppAttendance]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppAttendance](
	[ID] [int]  NOT NULL,
	[HouseholdID] [int] NULL,
	[ResidentID] [int] NULL,
	[ProgramName] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[ReferenceDate] [datetime2](0) NULL,
	[StatusDate] [datetime2](0) NULL,
	[VisitDate] [datetime2](0) NULL,
	[VisitNotes] [nvarchar](255) NULL,
	[Volunteer] [nvarchar](255) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppAttendance')
GO
/****** Object:  Table [Cares].[tblAppCarRepair]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppCarRepair](
	[CarRepairID] [int]  NOT NULL,
	[ApplicationID] [int] NULL,
	[Employed] [bit] NULL,
	[ActivelySeekingEmployment] [bit] NULL,
	[MonthlyIncomeAmt] [float] NULL,
	[CarInsuranceCurrent] [bit] NULL,
	[ProofofOwnership] [bit] NULL,
	[RegistrationCurrent] [bit] NULL,
	[LicenseCurrent] [bit] NULL,
	[AbleToPay] [bit] NULL,
	[MakeandModel] [nvarchar](50) NULL,
	[CarRuns] [bit] NULL,
	[CarLocation] [nvarchar](50) NULL,
	[RepairsNeeded] [nvarchar](255) NULL,
	[Owned] [nvarchar](50) NULL,
	[PurchasePrice] [nvarchar](50) NULL,
	[PurchaseLocation] [nvarchar](50) NULL,
	[Estimate] [nvarchar](50) NULL,
	[AgencyReferral] [nvarchar](255) NULL,
	[AgencyReferralRep] [nvarchar](255) NULL,
	[AgencyReferralPhone] [nvarchar](255) NULL,
	[Odometer] [nvarchar](255) NULL,
	[HowLongNotRunning] [nvarchar](255) NULL,
	[Symptoms] [nvarchar](255) NULL,
	[vin] [nvarchar](255) NULL,
	[ModelYear] [int] NULL,
	[CheckEngine] [bit] NULL,
	[CheckEngineHowLong] [nvarchar](255) NULL,
	[WhenEmissionsTest] [nvarchar](255) NULL,
	[WhenLicenseRenewal] [nvarchar](255) NULL,
	[LastTimeMaintained] [nvarchar](255) NULL,
	[LastServicesPerformed] [nvarchar](255) NULL,
	[UndertheHood] [bit] NULL,
	[UndertheCar] [bit] NULL,
	[NoiseinFront] [bit] NULL,
	[NoiseinRear] [bit] NULL,
	[TurningtheWheel] [bit] NULL,
	[GoingOverBumps] [bit] NULL,
	[OilUndertheCar] [bit] NULL,
	[AntifreezeLeak] [bit] NULL,
	[BreaksLeak] [bit] NULL,
	[TowingNeeded] [bit] NULL,
	[TowingCoverage] [bit] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppCarRepair')
GO
/****** Object:  Table [Cares].[tblAppCarRequest]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppCarRequest](
	[CarRequestID] [int]  NOT NULL,
	[ApplicationID] [int] NULL,
	[Employed] [bit] NULL,
	[ActivelySeekingEmployment] [bit] NULL,
	[INSource] [nvarchar](255) NULL,
	[Over21] [bit] NULL,
	[LicenseCurrent] [bit] NULL,
	[LicenseNumber] [nvarchar](255) NULL,
	[MonthlyIncomeAmt] [float] NULL,
	[IncomeSource] [nvarchar](255) NULL,
	[NoOtherCar] [bit] NULL,
	[NoCarFromCares] [bit] NULL,
	[NapResident] [bit] NULL,
	[AbleToPay] [bit] NULL,
	[LandlordVerified] [bit] NULL,
	[EmployerVerified] [bit] NULL,
	[LicenseExpiration] [datetime2](0) NULL,
	[ReferringAgency] [nvarchar](255) NULL,
	[CarProgramAgreement] [bit] NULL,
	[SSCards] [bit] NULL,
	[ReleaseSigned] [bit] NULL,
	[CurrentLease] [bit] NULL,
	[NapervilleResident] [bit] NULL,
	[NapervilleChurch] [nvarchar](255) NULL,
	[CarNotes] [nvarchar](255) NULL,
	[CanDriveStick] [bit] NULL,
	[ReferenceForm] [bit] NULL,
	[DateOnCarList] [datetime2](0) NULL,
	[AgencyReferral] [nvarchar](255) NULL,
	[BudgetingClass] [bit] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppCarRequest')
GO
/****** Object:  Table [Cares].[tblAppDocument]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppDocument](
	[DocumentID] [int]  NOT NULL,
	[ApplicationID] [int] NULL,
	[DOCItem] [nvarchar](255) NULL,
	[DOCRequested] [datetime2](0) NULL,
	[DOCReceived] [datetime2](0) NULL,
	[DOCNotes] [nvarchar](255) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppDocument')
GO
/****** Object:  Table [Cares].[tblAppExpense]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppExpense](
	[ExpenseID] [int]  NOT NULL,
	[ApplicationID] [int] NULL,
	[EXCategory] [nvarchar](255) NULL,
	[MonthlyExpenseAmt] [float] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppExpense')
GO
/****** Object:  Table [Cares].[tblAppIncome]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppIncome](
	[IncomeID] [int]  NOT NULL,
	[ApplicationID] [int] NULL,
	[INSource] [nvarchar](255) NULL,
	[MonthlyIncomeAmt] [float] NULL,
	[NetPayment] [float] NULL,
	[GrossPayment] [float] NULL,
	[PayDate] [datetime2](0) NULL,
	[PeriodStart] [datetime2](0) NULL,
	[PeriodEnding] [datetime2](0) NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppIncome')
GO
/****** Object:  Table [Cares].[tblAppNeedsInventory]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppNeedsInventory](
	[InventoryID] [int]  NOT NULL,
	[ApplicationID] [int] NULL,
	[Food] [bit] NULL,
	[Housing] [bit] NULL,
	[Utilities] [bit] NULL,
	[Transportation] [bit] NULL,
	[Clothes] [bit] NULL,
	[HouseholdGoods] [bit] NULL,
	[Phone] [bit] NULL,
	[Rent] [bit] NULL,
	[LegalAdvice] [bit] NULL,
	[Taxes] [bit] NULL,
	[GED] [bit] NULL,
	[HealthCare] [bit] NULL,
	[DentalCare] [bit] NULL,
	[Counseling] [bit] NULL,
	[ChildCare] [bit] NULL,
	[Job] [bit] NULL,
	[Computer] [bit] NULL,
	[Budgeting] [bit] NULL,
	[English] [bit] NULL,
	[SeniorServices] [bit] NULL,
	[OtherNeeds] [nvarchar](255) NULL,
	[HealthCoverage] [nvarchar](255) NULL,
	[SNAP] [nvarchar](255) NULL,
	[Unemployment] [nvarchar](255) NULL,
	[DisabilityBenefits] [nvarchar](255) NULL,
	[WIC] [nvarchar](255) NULL,
	[TANF] [nvarchar](255) NULL,
	[VeteransBenefits] [nvarchar](255) NULL,
	[LIHEAP] [nvarchar](255) NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppNeedsInventory')
GO
/****** Object:  Table [Cares].[tblAppointments]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppointments](
	[ID] [int]  NOT NULL,
	[DayofWeek] [nvarchar](10) NULL,
	[ApptTime] [datetime2](0) NULL,
	[ApptLocation] [nvarchar](255) NULL,
	[ApptTopic] [nvarchar](255) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppointments')
GO
/****** Object:  Table [Cares].[tblAppProcess]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppProcess](
	[ProcessID] [int]  NOT NULL,
	[ApplicationID] [int] NULL,
	[Process] [nvarchar](255) NULL,
	[ProcessDate] [datetime2](0) NULL,
	[ProcessNotes] [nvarchar](max) NULL,
	[ProcessCaresContact] [nvarchar](255) NULL,
	[ProcessStatus] [nvarchar](51) NULL,
	[HouseholdID] [int] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppProcess')
GO
/****** Object:  Table [Cares].[tblAppResidents]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppResidents](
	[HouseholdID] [int] NOT NULL,
	[id] [int]  NOT NULL,
	[DOB] [datetime2](0) NULL,
	[Gender] [nvarchar](6) NULL,
	[Last] [nvarchar](50) NULL,
	[First] [nvarchar](50) NULL,
	[Relation] [nvarchar](50) NULL,
	[SSN] [nvarchar](11) NULL,
	[Disabled] [bit] NULL,
	[Employment] [bit] NULL,
	[Racial Identity] [nvarchar](50) NULL,
	[Primary Language] [nvarchar](50) NULL,
	[HeadofHousehold] [bit] NULL,
	[Phone] [nvarchar](20) NULL,
	[DeleteFlag] [bit] NULL,
	[ApplicationID] [int] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppResidents')
GO
/****** Object:  Table [Cares].[tblAppResources]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblAppResources](
	[ResourcesID] [int]  NOT NULL,
	[ApplicationID] [int] NULL,
	[ProgramName] [nvarchar](255) NULL,
	[ReferralDate] [datetime2](0) NULL,
	[Notes] [nvarchar](255) NULL,
	[CompleteDate] [datetime2](0) NULL,
	[ProgramHome] [nvarchar](1) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblAppResources')
GO
/****** Object:  Table [Cares].[tblJobSearch]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblJobSearch](
	[id] [int]  NOT NULL,
	[HouseholdID] [int] NULL,
	[ApplicationID] [int] NULL,
	[ResidentID] [int] NULL,
	[SchoolYrsCompleted] [int] NULL,
	[SchoolName] [nvarchar](255) NULL,
	[Degree] [nvarchar](255) NULL,
	[Major] [nvarchar](255) NULL,
	[Internet] [nvarchar](3) NULL,
	[MSWord] [nvarchar](3) NULL,
	[MSExcel] [nvarchar](3) NULL,
	[OtherComputerExperience] [nvarchar](255) NULL,
	[LimitationsToJobSearch] [nvarchar](255) NULL,
	[WorkPermit] [nvarchar](3) NULL,
	[Resume] [nvarchar](3) NULL,
	[ResumeNeedsReview] [nvarchar](3) NULL,
	[Transportation] [nvarchar](3) NULL,
	[DayCare] [nvarchar](3) NULL,
	[AgeConcerns] [nvarchar](3) NULL,
	[HealthProblems] [nvarchar](3) NULL,
	[HealthProblemsDesc] [nvarchar](255) NULL,
	[SSDI] [nvarchar](3) NULL,
	[FamilyIssues] [nvarchar](3) NULL,
	[FamilyIssuesDesc] [nvarchar](255) NULL,
	[LegalIssues] [nvarchar](3) NULL,
	[ArrestFelony] [nvarchar](3) NULL,
	[DrugsAlcohol] [nvarchar](3) NULL,
	[Unemployment] [nvarchar](3) NULL,
	[UnemploymentEnd] [datetime2](0) NULL,
	[JobClub] [nvarchar](3) NULL,
	[JobClubDesc] [nvarchar](255) NULL,
	[LanguageIssues] [nvarchar](3) NULL,
	[LanguageIssuesDesc] [nvarchar](255) NULL,
	[PrimaryLanguage] [nvarchar](255) NULL,
	[SecondaryLanguage] [nvarchar](255) NULL,
	[OtherLanguage] [nvarchar](255) NULL,
	[AmericanProcess] [nvarchar](3) NULL,
	[AmericanProcessDesc] [nvarchar](255) NULL,
	[EmployedToday] [nvarchar](3) NULL,
	[PreviousEmployment1] [nvarchar](255) NULL,
	[PreviousEmployment2] [nvarchar](255) NULL,
	[PreviousEmployment3] [nvarchar](255) NULL,
	[EmpPreference] [nvarchar](255) NULL,
	[PotentialEmployment1] [nvarchar](255) NULL,
	[PotentialEmployment2] [nvarchar](255) NULL,
	[PotentialEmployment3] [nvarchar](255) NULL,
	[Veteran] [nvarchar](3) NULL,
	[HonorableDischarge] [nvarchar](3) NULL,
	[DischargeDate] [datetime2](0) NULL,
	[JobCoachComments] [nvarchar](255) NULL,
	[ClientMeet] [nvarchar](255) NULL,
	[JobHelpID] [int] NULL,
	[L&FClientID] [int] NULL,
	[DateRecd] [datetime2](0) NULL,
	[JobCoach] [nvarchar](255) NULL,
	[CoverLetter] [bit] NULL,
	[JobSearchInterview] [bit] NULL,
	[PermissionToForward] [bit] NULL,
	[ResumeHelp] [bit] NULL,
	[SSMA_TimeStamp] [timestamp] NOT NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblJobSearch')
GO
/****** Object:  Table [Cares].[tblLFPrograms]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblLFPrograms](
	[id] [int]  NOT NULL,
	[ProgramName] [nvarchar](255) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblLFPrograms')
GO
/****** Object:  Table [Cares].[tblOptions]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblOptions](
	[ID] [int]  NOT NULL,
	[OptionField] [nvarchar](255) NULL,
	[OptionValue] [nvarchar](255) NULL,
	[OptionGroup] [nvarchar](255) NULL,
	[OptionMore] [nvarchar](255) NULL,
	[OptionSequence] [int] NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblOptions')
GO
/****** Object:  Table [Cares].[tblRelation]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblRelation](
	[Relation] [nvarchar](50) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblRelation')
GO
/****** Object:  Table [Cares].[tblResources]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblResources](
	[ResourcesID] [int]  NOT NULL,
	[AgencyName] [nvarchar](255) NULL,
	[Service Category] [nvarchar](255) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblResources')
GO
/****** Object:  Table [Cares].[tblTaxAssessor]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblTaxAssessor](
	[ID] [int]  NOT NULL,
	[Township] [nvarchar](51) NULL,
	[Phone Number] [nvarchar](50) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblTaxAssessor')
GO
/****** Object:  Table [Cares].[tblVolunteers]    Script Date: 8/15/2018 9:49:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [Cares].[tblVolunteers](
	[ID] [int]  NOT NULL,
	[FirstName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NULL)
with (data_source = Cares, schema_name = N'DBO', object_name = N'tblVolunteers')

-----------------------------------------------------------------------------------------
-- OFC External Tables


/****** Object:  Table [ofc].[tactivities]    Script Date: 8/15/2018 10:16:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tactivities](
	[activityNum] [int]  NOT NULL,
	[activityName] [varchar](100) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tallhouseholdsraces]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tallhouseholdsraces](
	[householdNum] [int] NOT NULL,
	[raceNum] [int] NOT NULL,
	[raceShortName] [varchar](25) NULL,
	[raceLongName] [varchar](50) NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tallpersonsages]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tallpersonsages](
	[personNum] [int] NOT NULL,
	[householdNum] [int] NULL,
	[age] [int] NULL,
	[ageText] [varchar](25) NULL,
	[active] [int] NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tappointmentslotdefinitions]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tappointmentslotdefinitions](
	[idx] [int]  NOT NULL,
	[wkDay] [nvarchar](20) NOT NULL,
	[timeOfDay] [nvarchar](20) NOT NULL,
	[numClientsAllowed] [smallint] NOT NULL,
	[slotType] [nvarchar](30) NOT NULL,
	[progID] [int] NULL,
	[supplPrintInfoIdx] [int] NULL,
	[active] [smallint] NOT NULL,
	[comment] [nvarchar](255) NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tappointmentslots]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tappointmentslots](
	[idx] [int]  NOT NULL,
	[apptDate] [date] NOT NULL,
	[wkDay] [nvarchar](20) NOT NULL,
	[timeOfDay] [nvarchar](20) NOT NULL,
	[slotType] [nvarchar](30) NOT NULL,
	[progID] [int] NULL,
	[supplPrintInfoIdx] [int] NULL,
	[userID] [int] NULL,
	[comment] [nvarchar](255) NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tappointmentsupplinfo]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tappointmentsupplinfo](
	[idx] [int]  NOT NULL,
	[supplInfoShort] [nvarchar](75) NOT NULL,
	[supplInfoLong] [nvarchar](max) NULL,
	[intakeDeskInstructions] [nvarchar](max) NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tbabyfood]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tbabyfood](
	[idx] [int]  NOT NULL,
	[personNum] [int] NOT NULL,
	[dateDistributed] [date] NOT NULL,
	[weight] [decimal](10, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tbirthdaykits]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tbirthdaykits](
	[idx] [int]  NOT NULL,
	[personNum] [int] NOT NULL,
	[dateDistributed] [date] NOT NULL,
	[weight] [decimal](10, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tcities]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tcities](
	[cityNum] [int]  NOT NULL,
	[cityName] [nvarchar](45) NOT NULL,
	[active] [smallint] NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tcounties]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tcounties](
	[county] [varchar](75) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tdiapers]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tdiapers](
	[idx] [int]  NOT NULL,
	[personNum] [int] NOT NULL,
	[dateDistributed] [date] NOT NULL,
	[weight] [decimal](10, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tfooddistribution]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tfooddistribution](
	[idx] [int]  NOT NULL,
	[householdNum] [int] NOT NULL,
	[dateDistributed] [date] NOT NULL,
	[weight] [decimal](10, 2) NOT NULL,
	[homeDelivered] [int] NOT NULL,
	[numAdults] [int] NOT NULL,
	[numChildren] [int] NOT NULL,
	[numSeniors] [int] NOT NULL,
	[isActualWeight] [smallint] NOT NULL,
	[proxy] [smallint] NOT NULL,
	[agencyID] [int] NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tfoodweighthistory]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tfoodweighthistory](
	[idx] [int]  NOT NULL,
	[foodIdx] [int] NOT NULL,
	[householdNum] [int] NOT NULL,
	[dateDistributed] [date] NOT NULL,
	[estimatedWeight] [decimal](10, 2) NOT NULL,
	[actualWeight] [decimal](10, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tfoodweights]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tfoodweights](
	[idx] [int]  NOT NULL,
	[residency] [nvarchar](45) NOT NULL,
	[householdSizeCategory] [nvarchar](40) NOT NULL,
	[effectiveDate] [date] NOT NULL,
	[weight] [decimal](10, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tfpl_values]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tfpl_values](
	[pKey] [int] NOT NULL,
	[amount] [decimal](10, 2) NOT NULL,
	[increment] [decimal](10, 2) NOT NULL,
	[effectiveDate] [date] NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[thomedeliveryaddresses]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[thomedeliveryaddresses](
	[idx] [int]  NOT NULL,
	[streetNumber] [nvarchar](100) NOT NULL,
	[cityNum] [int] NOT NULL,
	[active] [smallint] NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[thouseholdproducts]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[thouseholdproducts](
	[idx] [int]  NOT NULL,
	[householdNum] [int] NOT NULL,
	[dateDistributed] [date] NOT NULL,
	[weight] [decimal](10, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[thouseholdpromotions]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[thouseholdpromotions](
	[householdPromoID] [int]  NOT NULL,
	[promoName] [nvarchar](50) NOT NULL,
	[description] [nvarchar](100) NOT NULL,
	[startDate] [date] NOT NULL,
	[endDate] [date] NULL,
	[promoSlotNumber] [int] NULL,
	[restrictToSingleUse] [smallint] NOT NULL,
	[weight] [decimal](10, 2) NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[thouseholdpromotionsusage]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[thouseholdpromotionsusage](
	[idx] [int]  NOT NULL,
	[householdPromoID] [int] NOT NULL,
	[householdNum] [int] NOT NULL,
	[usageDate] [date] NOT NULL,
	[weight] [decimal](10, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[thouseholds]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[thouseholds](
	[householdNum] [int]  NOT NULL,
	[streetNumber] [varchar](100) NULL,
	[apartment] [varchar](50) NULL,
	[cityNum] [int] NULL,
	[state] [varchar](25) NULL,
	[zip] [varchar](25) NULL,
	[county] [varchar](50) NULL,
	[phone] [varchar](50) NULL,
	[aptComplex] [varchar](50) NULL,
	[monthlyIncome] [decimal](11, 2) NULL,
	[disabled] [smallint] NULL,
	[femaleHeadedHousehold] [smallint] NULL,
	[active] [smallint] NULL,
	[intakeAttentionRequired] [varchar](255) NULL,
	[renewalDate] [date] NULL,
	[adminAttentionRequired] [varchar](255) NULL,
	[receiveFoodStamps] [smallint] NULL,
	[haveHealthInsuranceSelf] [smallint] NULL,
	[limitedEnglish] [smallint] NULL,
	[emailAddress] [varchar](100) NULL,
	[housingTypeNum] [int] NULL,
	[unemploymentCompensation] [smallint] NULL,
	[disabilityBenefits] [smallint] NULL,
	[socialSecurity] [smallint] NULL,
	[childSupport] [smallint] NULL,
	[override] [smallint] NULL,
	[longTermNotes] [varchar](max) NULL,
	[homeDeliveryEligible] [smallint] NULL,
	[preferredLanguageNum] [int] NULL,
	[incompleteInformation] [smallint] NULL,
	[allowInfantCare] [smallint] NOT NULL,
	[allowSchoolNutrition] [smallint] NOT NULL,
	[allowBirthdayKit] [smallint] NOT NULL,
	[allowHouseholdProduct] [smallint] NOT NULL,
	[allowPersonalPromotions] [smallint] NOT NULL,
	[allowHouseholdPromotions] [smallint] NOT NULL,
	[allowPromotions] [smallint] NOT NULL,
	[wic] [smallint] NULL,
	[empowermentExcluded] [smallint] NOT NULL,
	[agencyID] [int] NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[thouseholdselfsufficiency]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[thouseholdselfsufficiency](
	[idx] [int]  NOT NULL,
	[householdNum] [int] NOT NULL,
	[selfSufficiencyLevel] [int] NOT NULL,
	[dateApplied] [date] NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[thouseholdsizes]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[thouseholdsizes](
	[numActivePersons] [int] NOT NULL,
	[householdSizeCategory] [nvarchar](30) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[thousingtypes]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[thousingtypes](
	[housingTypeNum] [int]  NOT NULL,
	[housingType] [nvarchar](50) NOT NULL,
	[active] [smallint] NOT NULL,
	[housingTypeSpanish] [nvarchar](50) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tincomelimits]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tincomelimits](
	[idx] [int]  NOT NULL,
	[householdSize] [int] NOT NULL,
	[incomeLimit] [decimal](12, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tinterviewnotes]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tinterviewnotes](
	[householdNum] [int] NOT NULL,
	[dateUpdated] [date] NULL,
	[notes] [varchar](max) NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tlogin_activity_permissions]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tlogin_activity_permissions](
	[idx] [int]  NOT NULL,
	[loginPermissionLevel] [int] NOT NULL,
	[activityNum] [int] NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tloginpermissionlevels]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tloginpermissionlevels](
	[loginPermissionLevel] [int] NOT NULL,
	[loginPermissionLevelText] [varchar](50) NOT NULL,
	[notes] [varchar](255) NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tlongtermprogramevents]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tlongtermprogramevents](
	[idx] [int]  NOT NULL,
	[personNum] [int] NOT NULL,
	[progID] [int] NOT NULL,
	[statusID] [int] NOT NULL,
	[statusDate] [date] NOT NULL,
	[notes] [varchar](max) NULL,
	[referenceDate] [date] NOT NULL,
	[visitDate] [date] NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tlongtermprograms]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tlongtermprograms](
	[progID] [int]  NOT NULL,
	[programName] [nvarchar](50) NOT NULL,
	[active] [smallint] NOT NULL,
	[comments] [nvarchar](100) NULL,
	[email] [nvarchar](255) NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tlongtermprogramstatuses]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tlongtermprogramstatuses](
	[statusID] [int]  NOT NULL,
	[status] [nvarchar](50) NOT NULL,
	[comment] [nvarchar](150) NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tlongtermprogramstatuses2]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tlongtermprogramstatuses2](
	[statusID] [int]  NOT NULL,
	[progID] [int] NOT NULL,
	[active] [smallint] NOT NULL,
	[status] [nvarchar](75) NOT NULL,
	[sortOrder] [int] NOT NULL,
	[comment] [nvarchar](250) NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tmfi_values]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tmfi_values](
	[householdSize] [int] NOT NULL,
	[pct30] [decimal](12, 2) NOT NULL,
	[pct50] [decimal](12, 2) NOT NULL,
	[pct60] [decimal](12, 2) NOT NULL,
	[pct65] [decimal](12, 2) NOT NULL,
	[pct80] [decimal](12, 2) NOT NULL,
	[MFI] [decimal](12, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tmilkandeggs]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tmilkandeggs](
	[idx] [int]  NOT NULL,
	[householdNum] [int] NOT NULL,
	[dateDistributed] [date] NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tmiscweights]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tmiscweights](
	[idx] [int]  NOT NULL,
	[service] [nvarchar](30) NOT NULL,
	[effectiveDate] [date] NOT NULL,
	[weight] [decimal](10, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tpersonalpromotions]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tpersonalpromotions](
	[personalPromoID] [int]  NOT NULL,
	[promoName] [nvarchar](50) NOT NULL,
	[description] [nvarchar](100) NOT NULL,
	[startDate] [date] NOT NULL,
	[endDate] [date] NULL,
	[minAge] [int] NULL,
	[maxAge] [int] NULL,
	[promoSlotNumber] [int] NULL,
	[weight] [decimal](10, 2) NULL,
	[restrictToSingleUse] [smallint] NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tpersonalpromotionsusage]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tpersonalpromotionsusage](
	[idx] [int]  NOT NULL,
	[personalPromoID] [int] NOT NULL,
	[personNum] [int] NOT NULL,
	[usageDate] [date] NOT NULL,
	[weight] [decimal](10, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tpersons]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tpersons](
	[personNum] [int]  NOT NULL,
	[householdNum] [int] NOT NULL,
	[firstName] [varchar](50) NULL,
	[middleName] [varchar](50) NULL,
	[lastName] [varchar](50) NULL,
	[birthdate] [date] NULL,
	[gender] [varchar](10) NULL,
	[active] [smallint] NULL,
	[primaryContact] [smallint] NULL,
	[comment] [varchar](255) NULL,
	[employed] [smallint] NULL,
	[ageVerified] [smallint] NULL,
	[relationship] [varchar](50) NULL,
	[raceNum] [decimal](11, 0) NULL,
	[specialDiaperNeeds] [smallint] NULL,
	[veteran] [smallint] NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tpreferredlanguages]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tpreferredlanguages](
	[preferredLanguageNum] [int]  NOT NULL,
	[preferredLanguage] [nvarchar](40) NOT NULL,
	[sortOrder] [int] NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tprogramreferrals]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tprogramreferrals](
	[idx] [int]  NOT NULL,
	[progID] [int] NOT NULL,
	[householdNum] [int] NOT NULL,
	[dateReferred] [date] NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[traces]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[traces](
	[raceNum] [int]  NOT NULL,
	[raceShortName] [nvarchar](20) NOT NULL,
	[raceLongName] [nvarchar](50) NOT NULL,
	[active] [smallint] NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[treferralagencies]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[treferralagencies](
	[agencyID] [int]  NOT NULL,
	[agencyName] [nvarchar](100) NOT NULL,
	[agencyShortName] [nvarchar](15) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tresidencecategories]    Script Date: 8/15/2018 10:16:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tresidencecategories](
	[residenceCategory] [nvarchar](30) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tschoolnutrition]    Script Date: 8/15/2018 10:16:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tschoolnutrition](
	[idx] [int]  NOT NULL,
	[personNum] [int] NOT NULL,
	[dateDistributed] [date] NOT NULL,
	[weight] [decimal](10, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tselfsufficiencylevels]    Script Date: 8/15/2018 10:16:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tselfsufficiencylevels](
	[selfSufficiencyLevel] [int] NOT NULL,
	[selfSufficiencyLevelDescription] [nvarchar](100) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tsessions]    Script Date: 8/15/2018 10:16:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tsessions](
	[sessionID] [varchar](100) NOT NULL,
	[firstAccessed] [datetime2](0) NOT NULL,
	[lastAccessed] [datetime2](0) NOT NULL,
	[userName] [varchar](100) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tsysglobalvalues]    Script Date: 8/15/2018 10:16:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tsysglobalvalues](
	[pKey] [nvarchar](35) NOT NULL,
	[description] [nvarchar](200) NOT NULL,
	[bool1] [smallint] NULL,
	[string1] [nvarchar](100) NULL,
	[date1] [date] NULL,
	[long1] [int] NULL,
	[integer1] [int] NULL,
	[single1] [decimal](10, 2) NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[ttanf]    Script Date: 8/15/2018 10:16:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[ttanf](
	[idx] [int]  NOT NULL,
	[householdNum] [int] NOT NULL,
	[dateDistributed] [date] NOT NULL,
	[weight] [decimal](10, 2) NOT NULL)
	with (data_source = OFC)
GO
/****** Object:  Table [ofc].[tusers]    Script Date: 8/15/2018 10:16:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE EXTERNAL TABLE [ofc].[tusers](
	[idx] [int]  NOT NULL,
	[userName] [varchar](50) NOT NULL,
	[passwordValue] [varchar](50) NOT NULL,
	[loginPermissionLevel] [int] NOT NULL,
	[active] [smallint] NOT NULL,
	[notes] [varchar](255) NULL)
	with (data_source = OFC)
GO
IF OBJECT_ID('tempdb..##Actions') IS NOT NULL
    drop table ##Actions

IF OBJECT_ID('tempdb..#Contracts1', 'U') IS NOT NULL
	DROP TABLE #Contracts1

IF OBJECT_ID('tempdb..#Contracts2', 'U') IS NOT NULL
	DROP TABLE #Contracts2

IF OBJECT_ID('tempdb..#Contracts', 'U') IS NOT NULL
	DROP TABLE #Contracts

IF OBJECT_ID('tempdb..#Contacts', 'U') IS NOT NULL
	DROP TABLE #Contacts

-- NOTE: since the AT data warehouse is only updated at midnight, the data is all from yesterday
-- so anywhere that is looking at "Today" using GETDATE() needs to subtract 1 to look at yesterday


-- Get all Active Contracts and their Services related to Company Contacts
--If changes have been made to a client's contract, it is not effective until next month, so set the first day of next month as the effective date check here
SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name
		, C.[Contract_Name], C.[Start_Date], C.[End_Date]
		, S.[Service_Name], S.[Unit_Price]--, S.[Service_Description]
		, P.Units, P.Contract_Period_Price
	INTO #Contracts1
	FROM Autotask.TF_511394_WH.dbo.wh_contract C WITH (NOLOCK)
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_service CS WITH (NOLOCK)
		ON CS.contract_id = C.contract_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_service S WITH (NOLOCK)
		ON CS.Service_Id = S.Service_Id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_service_period p WITH (NOLOCK)
		ON CS.Contract_Service_Id = p.Contract_Service_Id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_category category WITH (NOLOCK)
		ON C.contract_category_id = category.contract_category_id	
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account WITH (NOLOCK)
		ON Account.account_id = C.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon WITH (NOLOCK)
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent WITH (NOLOCK)
		ON Parent.account_id = Account.parent_account_id
	WHERE C.is_active = 1

		--AND GETDATE() - 1 BETWEEN C.start_date and C.end_date
		--AND GETDATE() - 1 BETWEEN p.contract_period_date and p.contract_period_end_date

		AND DATEADD(dd, 1, dbo.GetLastDayOfMonth(GETDATE()-1)) BETWEEN C.start_date and C.end_date
		AND DATEADD(dd, 1, dbo.GetLastDayOfMonth(GETDATE()-1)) BETWEEN p.contract_period_date and p.contract_period_end_date
		AND LEFT(category.contract_category_name, 16) in ('Managed Services', 'Other Recurring ')
		AND S.Active = 1
		AND S.[Service_ID] IN (16,19,14,15,21,22)	-- IT Service Agreements~Base Fee, IT Service Agreement - Modular, IT Service Agreements~Full User, IT Service Agreements~Half User, IT Service Agreements~Quarter User, IT Service Agreements~Included User
	ORDER BY 1,2,3,5

-- It is possible that a client's contract terminates at the end of this month and the new one is setup yet.  Pull in those clients by checking for contracts currently effective here
SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name
		, C.[Contract_Name], C.[Start_Date], C.[End_Date]
		, S.[Service_Name], S.[Unit_Price]--, S.[Service_Description]
		, P.Units, P.Contract_Period_Price
	INTO #Contracts2
	FROM Autotask.TF_511394_WH.dbo.wh_contract C WITH (NOLOCK)
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_service CS WITH (NOLOCK)
		ON CS.contract_id = C.contract_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_service S WITH (NOLOCK)
		ON CS.Service_Id = S.Service_Id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_service_period p WITH (NOLOCK)
		ON CS.Contract_Service_Id = p.Contract_Service_Id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_category category WITH (NOLOCK)
		ON C.contract_category_id = category.contract_category_id	
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account WITH (NOLOCK)
		ON Account.account_id = C.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon WITH (NOLOCK)
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent WITH (NOLOCK)
		ON Parent.account_id = Account.parent_account_id
	WHERE C.is_active = 1
		AND GETDATE() - 1 BETWEEN C.start_date and C.end_date
		AND GETDATE() - 1 BETWEEN p.contract_period_date and p.contract_period_end_date
		AND LEFT(category.contract_category_name, 16) in ('Managed Services', 'Other Recurring ')
		AND S.Active = 1
		AND S.[Service_ID] IN (16,19,14,15,21,22)	-- IT Service Agreements~Base Fee, IT Service Agreement - Modular, IT Service Agreements~Full User, IT Service Agreements~Half User, IT Service Agreements~Quarter User, IT Service Agreements~Included User
		AND COALESCE(Parent.Account_Name, Account.Account_Name) NOT IN (SELECT Company_Name FROM #Contracts1)
	ORDER BY 1,2,3,5

select * 
	into #Contracts
	from #Contracts1
union
select * from #Contracts2

select * from #Contracts
select * from #Contracts1
select * from #Contracts2

-- Get Active Contacts from AT
SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name
		, SUM(CASE WHEN ContactUDF.Contact_Type_stored_value IN ('CL - Decision Maker','CL - End User (FT)','CL - POC 1','CL - POC 2','CL - VIP', 'CL - Finance') THEN 1 ELSE 0 END) AS Num_Full_Users
		, SUM(CASE WHEN ContactUDF.Contact_Type_stored_value = 'CL - End User (PT30)' THEN 1 ELSE 0 END) AS Num_Half_Users
		, SUM(CASE WHEN ContactUDF.Contact_Type_stored_value = 'CL - End User (PT15)' THEN 1 ELSE 0 END) AS Num_Quarter_Users
	INTO #Contacts
	FROM Autotask.TF_511394_WH.dbo.wh_account Account
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account_contact Contact
		ON contact.account_id = Account.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_contact_udf ContactUDF
		ON Contact.account_contact_id = ContactUDF.account_contact_id
	WHERE 1=1
			and Account.is_active = 1
			and Contact.is_active = 1
			and Account.key_account_icon_id in (201, 200)	-- 10, 15 clients
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
	ORDER BY 1

-- Compare Contracts against Contacts
SELECT * 
INTO ##Actions
FROM (
	SELECT LEFT(Company_Type, 9) AS Company_Type, ISNULL(PSA.Company_Name, Ctr.Company_Name) AS Company_Name
		, CASE WHEN Ctr.Num_Full_Users = 0	
				THEN 'Add "Included Users" line'
				WHEN (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) < (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25))		-- PSA > Contract
				THEN 'Add ' + cast((PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25)) - (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) as varchar(10)) + ' seats'
				WHEN (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) > (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25))	-- Contract > PSA and Contract = Base
					AND (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) = Ctr.Num_Base_Users
				THEN 'Do Nothing. Already at Base Users.'
				WHEN (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) > (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25))	-- Contract > PSA and PSA >= Base
					AND (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25)) >= Ctr.Num_Base_Users
				THEN 'Subtract ' + cast((Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) - (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25)) as varchar(10)) + ' seats'
				WHEN (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) > (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25))	-- Contract > PSA and PSA < Base
					AND (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25)) < Ctr.Num_Base_Users
				THEN 'Subtract ' + cast((Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) - Ctr.Num_Base_Users as varchar(10)) + ' users. Stopped at Base Users.'
				ELSE 'Do Nothing'
				END AS Actions
		, Ctr.Num_Full_Users as [Contract-FULL], PSA.Num_Full_Users as FT_Contacts
		, Ctr.Num_Half_Users as [Contract-HALF], PSA.Num_Half_Users as PT30_Contacts
		, Ctr.Num_Quarter_Users as [Contract-QUARTER], PSA.Num_Quarter_Users as PT15_Contacts
		--, (PSA.Num_Full_Users - Ctr.Num_Full_Users) as [FT Users Change]
		--, (PSA.Num_Half_Users - Ctr.Num_Half_Users) as [PT30 Users Change]
		--, (PSA.Num_Quarter_Users - Ctr.Num_Quarter_Users) as [PT15 Users Change]
		, (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) as [Ttl Contract Seats]
		, (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25)) as [Ttl PSA Seats]
		, Ctr.Num_Base_Users as [Base Users]		
		, CAST(ROUND(CASE WHEN Ctr.Num_Base_Users > 0 THEN (Ctr.Base_Seat_Price / Ctr.Num_Base_Users) ELSE 0 END, 0) as INT) as [Base Seat Price]
		, CASE WHEN Ctr.Num_Full_Users = 0	
				THEN 0
				WHEN (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) < (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25))		-- PSA > Contract
				THEN ((PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25)) - (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)))
					* CAST(ROUND(CASE WHEN Ctr.Num_Base_Users > 0 THEN (Ctr.Base_Seat_Price / Ctr.Num_Base_Users) ELSE 0 END, 0) as INT) 
				WHEN (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) > (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25))	-- Contract > PSA and Contract = Base
					AND (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) = Ctr.Num_Base_Users
				THEN 0
				WHEN (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) > (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25))	-- Contract > PSA and PSA >= Base
					AND (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25)) >= Ctr.Num_Base_Users
				THEN ((Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) - (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25))) * -1
					* CAST(ROUND(CASE WHEN Ctr.Num_Base_Users > 0 THEN (Ctr.Base_Seat_Price / Ctr.Num_Base_Users) ELSE 0 END, 0) as INT) 
				WHEN (Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) > (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25))	-- Contract > PSA and PSA < Base
					AND (PSA.Num_Full_Users + (PSA.Num_Half_Users * .5) + (PSA.Num_Quarter_Users * .25)) < Ctr.Num_Base_Users
				THEN ((Ctr.Num_Full_Users + (Ctr.Num_Half_Users * .5) + (Ctr.Num_Quarter_Users * .25)) - Ctr.Num_Base_Users) * -1
					* CAST(ROUND(CASE WHEN Ctr.Num_Base_Users > 0 THEN (Ctr.Base_Seat_Price / Ctr.Num_Base_Users) ELSE 0 END, 0) as INT) 
				ELSE 0
				END AS MissingRevenue
	FROM #Contacts PSA
	FULL OUTER JOIN (
					-- Roll up contract services into Full, Half and Quarter Users (Contacts)
					SELECT Company_Type, Company_Name
							, SUM(CASE WHEN [Service_Name] IN ('IT Service Agreements~Full User', 'IT Service Agreements~Included User') THEN Units ELSE 0 END) AS Num_Full_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Half User' THEN Units ELSE 0 END) AS Num_Half_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Quarter User' THEN Units ELSE 0 END) AS Num_Quarter_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Included User' THEN Units ELSE 0 END) AS Num_Base_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Base Fee' THEN Contract_Period_Price 
										WHEN [Service_Name] = 'IT Service Agreement - Modular' THEN Contract_Period_Price
										ELSE 0 END) AS Base_Seat_Price
							--, 8 as Num_Base_Users -- Test to see if stop logic works
						FROM #Contracts
						GROUP BY Company_Type, Company_Name
					) Ctr
		on PSA.Company_Name = Ctr.Company_Name
	WHERE ISNULL(PSA.Company_Name, Ctr.Company_Name) NOT IN ('WEBIT Services', 'Triage Logic Management & Consulting')
) x
	WHERE x.Actions not like 'Do Nothing%'
	ORDER BY 1,2
	
--select * from ##Actions

DECLARE @EmailBody varchar(max)
SET @EmailBody = ''

-- Only send email if actionable clients need updating
IF (SELECT COUNT(*) FROM ##Actions WHERE Company_Name NOT IN ('Excel MSO', 'IL Constructors Corporation')) > 0 
BEGIN

	-- Build table of Actionable clients
	SET @EmailBody = @EmailBody + 'The following Contract Agreements in Autotask need to be updated.<BR/><BR/><table border="0">'
		+ '<tr><td style="font-weight:bold;  border-bottom: thin solid blue;">Type</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Company</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Actions</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Contract FULL</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">FT PSA Contacts</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Contract HALF</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">PT30 PSA Contacts</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Contract QUARTER</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">PT15 PSA Contacts</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Total Contract Seats</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Total PSA Seats</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Contract Base Users</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Base Seat Price</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Missing $</td></tr>'
	
	declare @Company_Type varchar(100), @Company_Name varchar(100), @Actions varchar(500), @ContractFULL varchar(100), @FT_Contacts varchar(100)
		, @ContractHALF varchar(100), @PT30_Contacts varchar(100), @ContractQUARTER varchar(100), @PT15_Contacts varchar(100), @TtlContractSeats varchar(100)
		, @TtlPSASeats varchar(100), @BaseUsers varchar(100), @BaseSeatPrice varchar(100), @MissingRevenue varchar(100)

	declare csrUpdates cursor for
		SELECT * 
			FROM ##Actions
			WHERE Company_Name NOT IN ('Excel MSO', 'IL Constructors Corporation')
			ORDER BY 1,2
	
	open csrUpdates
	fetch next from csrUpdates INTO @Company_Type, @Company_Name, @Actions, @ContractFULL, @FT_Contacts
		, @ContractHALF, @PT30_Contacts, @ContractQUARTER, @PT15_Contacts, @TtlContractSeats
		, @TtlPSASeats, @BaseUsers, @BaseSeatPrice, @MissingRevenue

	while @@Fetch_Status = 0
	begin
		SET @EmailBody = @EmailBody + '<tr><td style="white-space: nowrap;">' 
			+ @Company_Type + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf;">' 
			+ @Company_Name + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf;">' 
			+ @Actions + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @ContractFULL + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @FT_Contacts + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @ContractHALF + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @PT30_Contacts + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @ContractQUARTER + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @PT15_Contacts + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @TtlContractSeats + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @TtlPSASeats + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @BaseUsers + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: right;">' 
			+ '$' + @BaseSeatPrice + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: right;">' 
			+ '$' + @MissingRevenue + '</td></tr>'
		
		fetch next from csrUpdates INTO @Company_Type, @Company_Name, @Actions, @ContractFULL, @FT_Contacts
			, @ContractHALF, @PT30_Contacts, @ContractQUARTER, @PT15_Contacts, @TtlContractSeats
			, @TtlPSASeats, @BaseUsers, @BaseSeatPrice, @MissingRevenue
	end

	SET @EmailBody = @EmailBody + '</table>'

	close csrUpdates
	deallocate csrUpdates

	-- Build table of Postponed clients
	SET @EmailBody = @EmailBody + '<BR/><BR/><BR/>The following clients'' contracts will need updates in the future, but are not a priority at the moment.<BR/><BR/><table border="0">'
		+ '<tr><td style="font-weight:bold;  border-bottom: thin solid blue;">Type</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Company</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Actions</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Contract FULL</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">FT PSA Contacts</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Contract HALF</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">PT30 PSA Contacts</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Contract QUARTER</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">PT15 PSA Contacts</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Total Contract Seats</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Total PSA Seats</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Contract Base Users</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Base Seat Price</td>'
		+ '<td style="font-weight:bold;  border-bottom: thin solid blue;">Missing $</td></tr>'
	
	declare csrUpdates2 cursor for
		SELECT * 
			FROM ##Actions
			WHERE Company_Name IN ('Excel MSO', 'IL Constructors Corporation')
			ORDER BY 1,2
	
	open csrUpdates2
	fetch next from csrUpdates2 INTO @Company_Type, @Company_Name, @Actions, @ContractFULL, @FT_Contacts
		, @ContractHALF, @PT30_Contacts, @ContractQUARTER, @PT15_Contacts, @TtlContractSeats
		, @TtlPSASeats, @BaseUsers, @BaseSeatPrice, @MissingRevenue

	while @@Fetch_Status = 0
	begin
		SET @EmailBody = @EmailBody + '<tr><td style="white-space: nowrap;">' 
			+ @Company_Type + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf;">' 
			+ @Company_Name + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf;">' 
			+ @Actions + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @ContractFULL + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @FT_Contacts + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @ContractHALF + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @PT30_Contacts + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @ContractQUARTER + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @PT15_Contacts + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @TtlContractSeats + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @TtlPSASeats + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: center;">' 
			+ @BaseUsers + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: right;">' 
			+ '$' + @BaseSeatPrice + '</td><td style="white-space: nowrap; border-left: thin solid #bfbfbf; text-align: right;">' 
			+ '$' + @MissingRevenue + '</td></tr>'
		
		fetch next from csrUpdates2 INTO @Company_Type, @Company_Name, @Actions, @ContractFULL, @FT_Contacts
			, @ContractHALF, @PT30_Contacts, @ContractQUARTER, @PT15_Contacts, @TtlContractSeats
			, @TtlPSASeats, @BaseUsers, @BaseSeatPrice, @MissingRevenue
	end

	SET @EmailBody = @EmailBody + '</table>'

	close csrUpdates2
	deallocate csrUpdates2

END
ELSE
BEGIN
	PRINT 'No contract actions needed'
	SET @EmailBody = ''
END

if @EmailBody <> ''
BEGIN
	PRINT @EmailBody

	EXEC msdb.dbo.sp_send_dbmail  
		@profile_name = 'SMTPtoGO'
		, @from_address = 'dev@webitservices.com'
		, @recipients = 'greenteam@webitservices.com'
		, @subject = 'Autotask Contract Audit Report'
		, @body = @EmailBody
		, @body_format = 'HTML'
END

IF OBJECT_ID('tempdb..#CurrentContracts', 'U') IS NOT NULL
	DROP TABLE #CurrentContracts

IF OBJECT_ID('tempdb..#Contacts', 'U') IS NOT NULL
	DROP TABLE #Contacts
		
IF OBJECT_ID('tempdb..#NextMonthContracts', 'U') IS NOT NULL
	DROP TABLE #NextMonthContracts
		

-- NOTE: since the AT data warehouse is only updated at midnight, the data is all from yesterday
-- so anywhere that is looking at "Today" using GETDATE() needs to subtract 1 to look at yesterday


-- Get all Active Contracts and their Services related to Company Contacts
SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name
		, C.[Contract_Name], C.[Start_Date], C.[End_Date], p.contract_period_date, p.contract_period_end_date
		, S.[Service_Name], S.[Unit_Price]--, S.[Service_Description]
		, P.Units, P.Contract_Period_Price
	INTO #CurrentContracts
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
		--and COALESCE(Parent.Account_Name, Account.Account_Name) = 'Whitney Inc'
	ORDER BY 1,3,5

-- Get all Active Contracts and their Services related to Company Contacts for NEXT MONTH
SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name
		, C.[Contract_Name], C.[Start_Date], C.[End_Date], p.contract_period_date, p.contract_period_end_date
		, S.[Service_Name], S.[Unit_Price]--, S.[Service_Description]
		, P.Units, P.Contract_Period_Price
	INTO #NextMonthContracts
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
		AND DATEADD(dd, 1, dbo.GetLastDayOfMonth(GETDATE()-1)) BETWEEN C.start_date and C.end_date
		AND DATEADD(dd, 1, dbo.GetLastDayOfMonth(GETDATE()-1)) BETWEEN p.contract_period_date and p.contract_period_end_date
		AND LEFT(category.contract_category_name, 16) in ('Managed Services', 'Other Recurring ')
		AND S.Active = 1
		AND S.[Service_ID] IN (16,19,14,15,21,22)	-- IT Service Agreements~Base Fee, IT Service Agreement - Modular, IT Service Agreements~Full User, IT Service Agreements~Half User, IT Service Agreements~Quarter User, IT Service Agreements~Included User
		--and COALESCE(Parent.Account_Name, Account.Account_Name) = 'Whitney Inc'
	ORDER BY 1,3,5
	

-- Get Active Contacts from AT
SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name
		, SUM(CASE WHEN ContactUDF.Contact_Type_stored_value IN ('CL - Decision Maker','CL - End User (FT)','CL - POC 1','CL - POC 2','CL - VIP') THEN 1 ELSE 0 END) AS Num_Full_Users
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
SELECT * FROM (

SELECT LEFT(Company_Type, 9) AS Company_Type, ISNULL(PSA.Company_Name, Ctr.Company_Name) AS Company_Name
		, CASE WHEN Ctr.Num_Full_Users = 0	
				THEN 'Add an "Included Users" service line to the contract"'
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
	FROM #Contacts PSA
	FULL OUTER JOIN (
					-- Roll up contract services into Full, Half and Quarter Users (Contacts)
					SELECT Company_Type, Company_Name
							, SUM(CASE WHEN [Service_Name] IN ('IT Service Agreements~Full User', 'IT Service Agreements~Included User') THEN Units ELSE 0 END) AS Num_Full_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Half User' THEN Units ELSE 0 END) AS Num_Half_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Quarter User' THEN Units ELSE 0 END) AS Num_Quarter_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Included User' THEN Units ELSE 0 END) AS Num_Base_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Base Fee' THEN Unit_Price 
										WHEN [Service_Name] = 'IT Service Agreement - Modular' THEN Contract_Period_Price
										ELSE 0 END) AS Base_Seat_Price
							--, 8 as Num_Base_Users -- Test to see if stop logic works
						FROM #CurrentContracts
						GROUP BY Company_Type, Company_Name
					) Ctr
		on PSA.Company_Name = Ctr.Company_Name
	WHERE ISNULL(PSA.Company_Name, Ctr.Company_Name) NOT IN ('WEBIT Services', 'Triage Logic Management & Consulting')
) x
	WHERE x.Actions not like 'Do Nothing%'
	ORDER BY 1,2

SELECT * FROM (

SELECT Company_Type, ISNULL(PSA.Company_Name, Ctr.Company_Name) AS Company_Name
		, CASE WHEN Ctr.Num_Full_Users = 0	
				THEN 'Add an "Included Users" service line to the contract"'
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
	FROM #Contacts PSA
	FULL OUTER JOIN (
					-- Roll up contract services into Full, Half and Quarter Users (Contacts)
					SELECT Company_Name
							, SUM(CASE WHEN [Service_Name] IN ('IT Service Agreements~Full User', 'IT Service Agreements~Included User') THEN Units ELSE 0 END) AS Num_Full_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Half User' THEN Units ELSE 0 END) AS Num_Half_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Quarter User' THEN Units ELSE 0 END) AS Num_Quarter_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Included User' THEN Units ELSE 0 END) AS Num_Base_Users 
							, SUM(CASE WHEN [Service_Name] = 'IT Service Agreements~Base Fee' THEN Unit_Price 
										WHEN [Service_Name] = 'IT Service Agreement - Modular' THEN Contract_Period_Price
										ELSE 0 END) AS Base_Seat_Price
							--, 8 as Num_Base_Users -- Test to see if stop logic works
						FROM #NextMonthContracts
						GROUP BY Company_Name
					) Ctr
		on PSA.Company_Name = Ctr.Company_Name
	WHERE ISNULL(PSA.Company_Name, Ctr.Company_Name) NOT IN ('WEBIT Services', 'Triage Logic Management & Consulting')
) x
	WHERE x.Actions not like 'Do Nothing%'
	ORDER BY 1

-------------------------------------------------------------------

---- Details
SELECT * FROM #CurrentContracts 
	WHERE Company_Name NOT IN ('WEBIT Services', 'Triage Logic Management & Consulting')
	order by 1,3,5

SELECT * FROM #NextMonthContracts 
	WHERE Company_Name NOT IN ('WEBIT Services', 'Triage Logic Management & Consulting')
	order by 1,3,5

--SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name,  ContactUDF.Contact_Type_stored_value, Contact.First_Name, Contact.Last_Name, Contact.Email_Address
--	FROM Autotask.TF_511394_WH.dbo.wh_account Account
--	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
--		ON Parent.account_id = Account.parent_account_id
--	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account_contact Contact
--		ON contact.account_id = Account.account_id
--	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_contact_udf ContactUDF
--		ON Contact.account_contact_id = ContactUDF.account_contact_id
--	WHERE 1=1
--		and Account.is_active = 1
--		and Contact.is_active = 1
--		and Account.key_account_icon_id in (201, 200)	-- 10, 15 clients
--		and COALESCE(Parent.Account_Name, Account.Account_Name) NOT IN ('WEBIT Services', 'Triage Logic Management & Consulting')
--	ORDER BY 1,2,4

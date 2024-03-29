/*
* Autotask Database: TF_511394_WH
*
* key_account_icon_id:
*	201 - 10 Client - Managed Services
*	200 - 15 Client - Modular Service
*	202 - 20 Client - On Demand Service
*	204 - 95 Internal
*	203 - 30 Former Client
*/ 

--------------------------------------------------------------------------------------------
-- All Active Contacts
SELECT account_id, first_name, last_name, email_address, title, phone_number, *
	FROM Autotask.TF_511394_WH.dbo.wh_account_contact Contact
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_contact_udf ContactUDF
		ON Contact.account_contact_id = ContactUDF.account_contact_id
	WHERE Contact.is_active = 1
		--and last_name = 'unknown'
		and create_time > '04/01/2018'
	order by create_time


--------------------------------------------------------------------------------------------
-- All Active Accounts
SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, Account.account_name, Account.phone_number
		, wh_key_account_icon.key_account_icon_name AS Company_Type
		, Account.key_account_icon_id, AccountUDf.*, Account.*
	FROM Autotask.TF_511394_WH.dbo.wh_account Account
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	WHERE 1=1
		 and Account.is_active = 1
		 and LEFT(wh_key_account_icon.key_account_icon_name, 3) IN ('10 ', '15 ', '95 ')
	ORDER BY 4,2


--------------------------------------------------------------------------------------------
-- Seat Counts

SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, SUM(CASE WHEN ContactUDF.Contact_Type_stored_value IN ('CL - Decision Maker','CL - End User (FT)','CL - POC 1','CL - POC 2','CL - VIP') THEN 1.00
						WHEN ContactUDF.Contact_Type_stored_value = 'CL - End User (PT30)' THEN 0.50
						WHEN ContactUDF.Contact_Type_stored_value = 'CL - End User (PT15)' THEN 0.25
						ELSE 0 END) AS Num_Seats
	FROM Autotask.TF_511394_WH.dbo.wh_account Account
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account_contact Contact
		ON contact.account_id = Account.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_contact_udf ContactUDF
		ON Contact.account_contact_id = ContactUDF.account_contact_id
	WHERE 1=1
		 and Account.is_active = 1
		 and Contact.is_active = 1
	GROUP BY wh_key_account_icon.key_account_icon_name 
	ORDER BY 1

SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name--, Account.account_name
		, SUM(CASE WHEN ContactUDF.Contact_Type_stored_value IN ('CL - Decision Maker','CL - End User (FT)','CL - POC 1','CL - POC 2','CL - VIP') THEN 1.00
						WHEN ContactUDF.Contact_Type_stored_value = 'CL - End User (PT30)' THEN 0.50
						WHEN ContactUDF.Contact_Type_stored_value = 'CL - End User (PT15)' THEN 0.25
						ELSE 0 END) AS Num_Seats
	FROM Autotask.TF_511394_WH.dbo.wh_account Account
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account_contact Contact
		ON contact.account_id = Account.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_contact_udf ContactUDF
		ON Contact.account_contact_id = ContactUDF.account_contact_id
	WHERE 1=1
		 and Account.is_active = 1
		 and Contact.is_active = 1
		 and Account.key_account_icon_id in (201, 200)	-- 10 and 15 clients
	GROUP BY wh_key_account_icon.key_account_icon_name, COALESCE(Parent.Account_Name, Account.Account_Name)--, Account.account_name
	ORDER BY 1,2,3

SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, Account.account_name
		, Contact.first_name, Contact.last_name, Contact.email_address, ContactUDF.Contact_Type_stored_value
		, CASE WHEN ContactUDF.Contact_Type_stored_value IN ('CL - Decision Maker','CL - End User (FT)','CL - POC 1','CL - POC 2','CL - VIP') THEN 1.00
						WHEN ContactUDF.Contact_Type_stored_value = 'CL - End User (PT30)' THEN 0.50
						WHEN ContactUDF.Contact_Type_stored_value = 'CL - End User (PT15)' THEN 0.25
						ELSE 0 END AS Num_Seats
	FROM Autotask.TF_511394_WH.dbo.wh_account Account
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account_contact Contact
		ON contact.account_id = Account.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_contact_udf ContactUDF
		ON Contact.account_contact_id = ContactUDF.account_contact_id
	WHERE 1=1
		 and Account.is_active = 1
		 and Contact.is_active = 1
		 and Account.key_account_icon_id in (201, 200)	-- 10 and 15 clients
	ORDER BY 1,2,3,4,5,6

--------------------------------------------------------------------------------------------
-- Endpoint Counts

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, Account.account_name, Product.product_name
		, InstalledProduct.device_audit_hostname, InstalledProduct.device_audit_ip_address, cast(round(device_audit_storage_bytes / 1000000000, 1) as decimal(10,1)) as DiskSpace
		, wh_device_audit_operating_system_name.name as 'OS', InstalledProduct.Device_audit_missing_patch_count, InstalledProduct.device_audit_open_alert_count
		, InstalledProduct.device_audit_last_user, InstalledProduct.device_audit_last_update_time--, InstalledProduct.* 
	FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = InstalledProduct.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_product Product
		ON Product.product_id = InstalledProduct.product_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_device_audit_operating_system_name wh_device_audit_operating_system_name
		ON wh_device_audit_operating_system_name.device_audit_operating_system_name_id = InstalledProduct.device_audit_operating_system_name_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	WHERE 1=1
		AND Account.is_active = 1
		AND InstalledProduct.is_active = 1
		AND InstalledProduct.aem_device_id is not null
		--and InstalledProduct.device_audit_hostname = '360YS-DC01'
	ORDER BY 1,2,3,4

device_audit_storage_bytes	device_audit_memory_bytes
print cast(round(device_audit_storage_bytes / 1000000000, 1) as decimal(10,1))
	
1,073,274,880
print (39.8*2)

SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name
		, CASE WHEN wh_device_audit_operating_system_name.name like '%SERVER%' THEN 'Server' ELSE 'Workstation' END as DeviceType, COUNT(*) as Num_Endpoints
	FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = InstalledProduct.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_product Product
		ON Product.product_id = InstalledProduct.product_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_device_audit_operating_system_name wh_device_audit_operating_system_name
		ON wh_device_audit_operating_system_name.device_audit_operating_system_name_id = InstalledProduct.device_audit_operating_system_name_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	WHERE 1=1
		AND Account.is_active = 1
		AND InstalledProduct.is_active = 1
		AND InstalledProduct.aem_device_id is not null
		--and wh_device_audit_operating_system_name.name like '%server%'
	GROUP BY wh_key_account_icon.key_account_icon_name, COALESCE(Parent.Account_Name, Account.Account_Name), CASE WHEN wh_device_audit_operating_system_name.name like '%SERVER%' THEN 'Server' ELSE 'Workstation' END
	ORDER BY 1,2,3
	
	
SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COUNT(*) as Num_Endpoints
	FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = InstalledProduct.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_product Product
		ON Product.product_id = InstalledProduct.product_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_device_audit_operating_system_name wh_device_audit_operating_system_name
		ON wh_device_audit_operating_system_name.device_audit_operating_system_name_id = InstalledProduct.device_audit_operating_system_name_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	WHERE 1=1
		AND Account.is_active = 1
		AND InstalledProduct.is_active = 1
		AND InstalledProduct.aem_device_id is not null
		--and wh_device_audit_operating_system_name.name like '%server%'
	GROUP BY wh_key_account_icon.key_account_icon_name
	ORDER BY 1
	
--------------------------------------------------------------------------------------------
-- Find Duplicate AEM records for a machine

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, Account.account_name
		, cast(InstalledProduct.device_audit_last_update_time as date) as Last_Update, InstalledProduct.device_audit_hostname, InstalledProduct.device_audit_ip_address
		, InstalledProduct.Serial_Number, wh_device_audit_operating_system_name.name as 'OS', InstalledProduct.device_audit_last_user
	FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = InstalledProduct.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_product Product
		ON Product.product_id = InstalledProduct.product_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_device_audit_operating_system_name wh_device_audit_operating_system_name
		ON wh_device_audit_operating_system_name.device_audit_operating_system_name_id = InstalledProduct.device_audit_operating_system_name_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN (
				SELECT InstalledProduct.aem_device_id
					FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
					INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
						ON Account.account_id = InstalledProduct.account_id
					INNER JOIN  (
								SELECT InstalledProduct.device_audit_hostname, InstalledProduct.Serial_Number, COUNT(*) as nCnt
									FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
									INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
										ON Account.account_id = InstalledProduct.account_id
									WHERE 1=1
										AND Account.is_active = 1
										AND InstalledProduct.is_active = 1
										AND InstalledProduct.aem_device_id is not null
									GROUP BY InstalledProduct.device_audit_hostname, InstalledProduct.Serial_Number
									HAVING COUNT(*) > 1
								) Dupes
						ON Dupes.device_audit_hostname = InstalledProduct.device_audit_hostname
					WHERE 1=1
						AND Account.is_active = 1
						AND InstalledProduct.is_active = 1
						AND InstalledProduct.aem_device_id is not null
			) DupeID
		ON DupeId.aem_device_id = InstalledProduct.aem_device_id
	WHERE 1=1
		AND Account.is_active = 1
		AND InstalledProduct.is_active = 1
		AND InstalledProduct.aem_device_id is not null
	ORDER BY 4,5,2




--------------------------------------------------------------------------------------------
-- All Devices Missing Patches
SELECT AccountUDf.CW_CompanyType, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, Account.account_name, Product.product_name
		, InstalledProduct.device_audit_hostname, InstalledProduct.device_audit_ip_address
		, wh_device_audit_operating_system_name.name as 'OS', InstalledProduct.Device_audit_missing_patch_count, InstalledProduct.device_audit_open_alert_count
		, InstalledProduct.device_audit_last_user, InstalledProduct.device_audit_last_update_time--, InstalledProduct.* 
	FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = InstalledProduct.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_product Product
		ON Product.product_id = InstalledProduct.product_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_device_audit_operating_system_name wh_device_audit_operating_system_name
		ON wh_device_audit_operating_system_name.device_audit_operating_system_name_id = InstalledProduct.device_audit_operating_system_name_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	WHERE 1=1
		AND Account.is_active = 1
		AND InstalledProduct.is_active = 1
		AND InstalledProduct.device_audit_missing_patch_count > 0
	ORDER BY 1,2,3,4

-- Patching Percentages by Company
SELECT AllCompanies.Company_Name, AllCompanies.Total_Endpoints, COALESCE(MissingPatches.Endpoints_Missing_Patches, 0) AS Endpoints_Missing_Patches
		, 1 - (cast(COALESCE(MissingPatches.Endpoints_Missing_Patches, 0) as decimal(12, 4)) / cast(AllCompanies.Total_Endpoints as decimal(12, 4))) AS Patched_Pct
	FROM (
SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, COUNT(*) as Total_Endpoints
	FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = InstalledProduct.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_product Product
		ON Product.product_id = InstalledProduct.product_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_device_audit_operating_system_name wh_device_audit_operating_system_name
		ON wh_device_audit_operating_system_name.device_audit_operating_system_name_id = InstalledProduct.device_audit_operating_system_name_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	WHERE 1=1
		AND Account.is_active = 1
		AND InstalledProduct.is_active = 1
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
	) AllCompanies
	LEFT JOIN (
SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, COUNT(*) as Endpoints_Missing_Patches
	FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = InstalledProduct.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_product Product
		ON Product.product_id = InstalledProduct.product_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_device_audit_operating_system_name wh_device_audit_operating_system_name
		ON wh_device_audit_operating_system_name.device_audit_operating_system_name_id = InstalledProduct.device_audit_operating_system_name_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	WHERE 1=1
		AND Account.is_active = 1
		AND InstalledProduct.is_active = 1
		AND InstalledProduct.device_audit_missing_patch_count > 0
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
	) MissingPatches
		ON AllCompanies.Company_Name = MissingPatches.Company_Name
	ORDER BY 4, 1



-- Patching Percentages by Company
SELECT SUM(AllCompanies.Total_Endpoints) as Total_Endpoints, COALESCE(SUM(MissingPatches.Endpoints_Missing_Patches), 0) AS Endpoints_Missing_Patches
		, 1 - (cast(COALESCE(SUM(MissingPatches.Endpoints_Missing_Patches), 0) as decimal(12, 4)) / cast(SUM(AllCompanies.Total_Endpoints) as decimal(12, 4))) AS Patched_Pct
	FROM (
SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, COUNT(*) as Total_Endpoints
	FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = InstalledProduct.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_product Product
		ON Product.product_id = InstalledProduct.product_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_device_audit_operating_system_name wh_device_audit_operating_system_name
		ON wh_device_audit_operating_system_name.device_audit_operating_system_name_id = InstalledProduct.device_audit_operating_system_name_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	WHERE 1=1
		AND Account.is_active = 1
		AND InstalledProduct.is_active = 1
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
	) AllCompanies
	LEFT JOIN (
SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, COUNT(*) as Endpoints_Missing_Patches
	FROM Autotask.TF_511394_WH.dbo.wh_installed_product InstalledProduct
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = InstalledProduct.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_product Product
		ON Product.product_id = InstalledProduct.product_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_device_audit_operating_system_name wh_device_audit_operating_system_name
		ON wh_device_audit_operating_system_name.device_audit_operating_system_name_id = InstalledProduct.device_audit_operating_system_name_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account_udf AccountUDf
		ON Account.account_id = AccountUDf.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	WHERE 1=1
		AND Account.is_active = 1
		AND InstalledProduct.is_active = 1
		AND InstalledProduct.device_audit_missing_patch_count > 0
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name)
	) MissingPatches
		ON AllCompanies.Company_Name = MissingPatches.Company_Name
	ORDER BY 4, 1



--------------------------------------------------------------------------------------------
-- MMR, ORR Contracts

SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name
		, category.contract_category_name as 'Category', contract.contract_name, contract.contract_id, contract.start_date, contract.end_date, contract.estimated_revenue as Est_Annual_Revenue
		, COALESCE((SELECT SUM(Unit_Price * CASE WHEN Units = 0 THEN 1 ELSE Units END)
						FROM Autotask.TF_511394_WH.dbo.wh_contract_service CS WITH (NOLOCK)
						WHERE CS.contract_id = contract.contract_id
					), 0) AS Contract_Price_Monthly
	FROM Autotask.TF_511394_WH.dbo.wh_contract [contract] WITH (NOLOCK)
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_category category WITH (NOLOCK)
		ON contract.contract_category_id = category.contract_category_id	
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account WITH (NOLOCK)
		ON Account.account_id = contract.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon WITH (NOLOCK)
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent WITH (NOLOCK)
		ON Parent.account_id = Account.parent_account_id
	WHERE contract.is_active = 1
		AND GETDATE() BETWEEN contract.start_date and contract.end_date
		AND LEFT(category.contract_category_name, 16) in ('Managed Services', 'Other Recurring ')
	ORDER BY 1,2,3,4,5

SELECT Company_Type, SUM(Num_Agreements) AS Num_Agreements, SUM(Contract_Price_Monthly) AS Contract_Price_Monthly
	FROM (
			SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COUNT(*) as Num_Agreements
					, COALESCE((SELECT SUM(Unit_Price * CASE WHEN Units = 0 THEN 1 ELSE Units END)
									FROM Autotask.TF_511394_WH.dbo.wh_contract_service CS WITH (NOLOCK)
									WHERE CS.contract_id = contract.contract_id
								), 0) AS Contract_Price_Monthly
				FROM Autotask.TF_511394_WH.dbo.wh_contract [contract] WITH (NOLOCK)
				INNER JOIN Autotask.TF_511394_WH.dbo.wh_contract_category category WITH (NOLOCK)
					ON contract.contract_category_id = category.contract_category_id	
				INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account WITH (NOLOCK)
					ON Account.account_id = contract.account_id
				INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon WITH (NOLOCK)
					ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
				LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent WITH (NOLOCK)
					ON Parent.account_id = Account.parent_account_id
				WHERE contract.is_active = 1
					AND GETDATE() BETWEEN contract.start_date and contract.end_date
					AND LEFT(category.contract_category_name, 16) in ('Managed Services', 'Other Recurring ')
				GROUP BY wh_key_account_icon.key_account_icon_name, contract.contract_id
			) x
		GROUP BY Company_Type
	ORDER BY 1


--------------------------------------------------------------------------------------------
-- Tickets


SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, Account.account_name
		, Ticket.task_number, Ticket.task_name, convert(char(7), Ticket.Create_Time, 111) AS Create_Month, Ticket.Create_Time, Ticket.Date_Completed, TStat.task_status_name AS 'Status'
		--, Ticket.Total_Worked_Hours, Ticket.Total_Billed_Hours, Board.queue_name as Board, AssignedTo.Full_Name as Assigned_To
		, IssueType.issue_type_name, SubIssueType.subissue_type_name, TContract.contract_name, TContract.end_date as Contract_End_Date, TContract.Is_Active, Ticket.Task_Description
		, Ticket.*
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_task_status TStat
		on TStat.task_status_id = Ticket.task_status_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_resource AssignedTo
		ON AssignedTo.resource_id = Ticket.assigned_resource_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_issue_type IssueType
		ON IssueType.issue_type_id = Ticket.issue_type_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_subissue_type SubIssueType
		ON SubIssueType.subissue_type_id = Ticket.subissue_type_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_contract TContract
		ON TContract.contract_id = Ticket.contract_id
	WHERE 1=1
--		and Ticket.Date_Completed is null
		and Ticket.Date_Completed >= dateadd(dd, -7, GETDATE())
		--and TContract.Is_Active = 0
		--AND TStat.service_level_agreement_event_type_code <> 'RESOLUTION'	-- Completed
		AND Board.queue_name like '01%'
		--AND COALESCE(Parent.Account_Name, Account.Account_Name) = 'Grand Dental Group'

		and task_name not like 'AEM Monitor Alert%'
		and (task_description = ''
			or assigned_resource_id is null
			or total_worked_hours = 0
			or issue_type_id is null
			or subissue_type_id is null
			or Resolution = ''
			or last_customer_notification_time is null
			)
	ORDER BY 1,2,3,4


SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, Ticket.task_number, Ticket.Create_Time, Ticket.Total_Worked_Hours, Board.queue_name as Board
		, SLA.first_response_elapsed_hours, SLA.resolution_elapsed_hours, Ticket.*
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_service_level_agreement_event_dates SLA
		ON SLA.task_id = Ticket.task_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND Ticket.Create_Time between '11/01/2017' AND '11/30/2017'
		AND Board.queue_name like '01%'
		AND DATEPART(dw, Ticket.Create_Time) BETWEEN 2 AND 6	-- Only count weekdays
		AND SLA.resolution_elapsed_hours > 12
	ORDER BY 1,2,3,4

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, Ticket.task_number, Ticket.Create_Time, Ticket.Total_Worked_Hours, Board.queue_name as Board, Subtime.*
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_item Time
		ON Time.task_id = Ticket.task_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_time_subitem SubTime 
		ON SubTime.time_item_id = Time.time_item_id
	WHERE 1=1
		AND Ticket.assigned_resource_id <> 29682923				-- Don't include Onsite Techs
		AND SubTime.Date_Worked between '11/01/2017' AND '11/30/2017'
		AND Board.queue_name like '01%'
	ORDER BY 1,2,3,4



--------------------------------------------------------------------------------------------
--  Get Top 10 Issues/SubIssues By clients for last 60 days

SELECT COALESCE(Parent.Account_Name, Account.Account_Name)
		, COALESCE(Parent.Account_Name, Account.Account_Name) + ' - ' + coalesce(IssueType.issue_type_name, '') + ' - ' + coalesce(SubIssueType.subissue_type_name, '') as 'Company_Issue_SubIssue', COUNT(*) as NumTickets
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_issue_type IssueType
		ON IssueType.issue_type_id = Ticket.issue_type_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_subissue_type SubIssueType
		ON SubIssueType.subissue_type_id = Ticket.subissue_type_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	WHERE 1=1
		and Ticket.Create_Time >= dateadd(dd, -60, GETDATE())
		AND Board.queue_name like '01%'
		and ticket.device_monitor_type_id is null	-- NOT NULL means ticket is an AEM Alert
	GROUP BY COALESCE(Parent.Account_Name, Account.Account_Name), IssueType.issue_type_name, SubIssueType.subissue_type_name 
	ORDER BY 1, 3 DESC


SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, Account.account_name
		, IssueType.issue_type_name AS 'Issue', SubIssueType.subissue_type_name as 'SubIssue', COALESCE(Product.Reference_Title, '') as 'Configuration'
		, Ticket.task_name, Ticket.Task_Description
		, Ticket.Total_Worked_Hours, Board.queue_name as Board, COALESCE(AssignedTo.Full_Name, '') as Assigned_To		
		, convert(char(7), Ticket.Create_Time, 111) AS Create_Month, Ticket.Create_Time, Ticket.task_number
		, COALESCE(Parent.Account_Name, Account.Account_Name) + ' - ' + coalesce(IssueType.issue_type_name, '') + ' - ' + coalesce(SubIssueType.subissue_type_name, '') as 'Company_Issue_SubIssue'
		--, Ticket.*
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_task_status TStat
		on TStat.task_status_id = Ticket.task_status_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_resource AssignedTo
		ON AssignedTo.resource_id = Ticket.assigned_resource_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_issue_type IssueType
		ON IssueType.issue_type_id = Ticket.issue_type_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_subissue_type SubIssueType
		ON SubIssueType.subissue_type_id = Ticket.subissue_type_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_installed_product Product
		ON Product.installed_product_id = Ticket.installed_product_id	
	WHERE 1=1
		and Ticket.Create_Time >= dateadd(dd, -60, GETDATE())
		AND Board.queue_name like '01%'
		and ticket.device_monitor_type_id is null	-- NOT NULL means ticket is an AEM Alert
		AND  wh_key_account_icon.key_account_icon_name = '10 Client - Managed Services'
		AND COALESCE(Parent.Account_Name, Account.Account_Name) + ' - ' + coalesce(IssueType.issue_type_name, '') + ' - ' + coalesce(SubIssueType.subissue_type_name, '')
				 IN (SELECT Company_Issue_SubIssue FROM 
						(SELECT TOP 10 COALESCE(Parent2.Account_Name, Account2.Account_Name) + ' - ' + coalesce(IssueType2.issue_type_name, '') + ' - ' + coalesce(SubIssueType2.subissue_type_name, '') as 'Company_Issue_SubIssue', COUNT(*) as NumTickets
							FROM Autotask.TF_511394_WH.dbo.wh_task Ticket2
							INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board2
								ON Board2.queue_id = Ticket2.ticket_queue_id
							LEFT JOIN Autotask.TF_511394_WH.dbo.wh_issue_type IssueType2
								ON IssueType2.issue_type_id = Ticket2.issue_type_id
							LEFT JOIN Autotask.TF_511394_WH.dbo.wh_subissue_type SubIssueType2
								ON SubIssueType2.subissue_type_id = Ticket2.subissue_type_id
							INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account2
								ON Account2.account_id = Ticket2.account_id
							LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent2
								ON Parent2.account_id = Account2.parent_account_id
							WHERE 1=1
								and Ticket2.Create_Time >= dateadd(dd, -60, GETDATE())
								AND Board2.queue_name like '01%'
								and ticket2.device_monitor_type_id is null	-- NOT NULL means ticket is an AEM Alert
								and COALESCE(Parent2.Account_Name, Account2.Account_Name) = COALESCE(Parent.Account_Name, Account.Account_Name)
							GROUP BY COALESCE(Parent2.Account_Name, Account2.Account_Name), IssueType2.issue_type_name, SubIssueType2.subissue_type_name 
							ORDER BY 2 DESC) x
						)
	ORDER BY 1,2,3,4,5,6



--------------------------------------------------------------------------------------------
--  Get Top 10 Issues/SubIssues across all clients for last 60 days

SELECT TOP 10 IssueType.issue_type_name AS 'Issue', SubIssueType.subissue_type_name as 'SubIssue', COUNT(*) as NumTickets
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_issue_type IssueType
		ON IssueType.issue_type_id = Ticket.issue_type_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_subissue_type SubIssueType
		ON SubIssueType.subissue_type_id = Ticket.subissue_type_id
	WHERE 1=1
		--and Ticket.Create_Time >= dateadd(dd, -60, GETDATE())
		--and Ticket.Create_Time >= dateadd(month, -6, GETDATE())
		and Ticket.Create_Time >= dateadd(month, -12, GETDATE())

		AND Board.queue_name like '01%'
		and ticket.device_monitor_type_id is null	-- NOT NULL means ticket is an AEM Alert
	GROUP BY IssueType.issue_type_name, SubIssueType.subissue_type_name 
	ORDER BY 3 DESC


SELECT wh_key_account_icon.key_account_icon_name AS Company_Type, COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, Account.account_name
		, IssueType.issue_type_name AS 'Issue', SubIssueType.subissue_type_name as 'SubIssue', COALESCE(Product.Reference_Title, '') as 'Configuration'
		, Ticket.task_name, Ticket.Task_Description
		, Ticket.Total_Worked_Hours, Board.queue_name as Board, COALESCE(AssignedTo.Full_Name, '') as Assigned_To		
		, convert(char(7), Ticket.Create_Time, 111) AS Create_Month, Ticket.Create_Time, Ticket.task_number
		, IssueType.issue_type_name + ' - ' + SubIssueType.subissue_type_name as 'Issue_SubIssue'
		--, Ticket.*
	FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_task_status TStat
		on TStat.task_status_id = Ticket.task_status_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_account Account
		ON Account.account_id = Ticket.account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_key_account_icon wh_key_account_icon
		ON wh_key_account_icon.key_account_icon_id = Account.key_account_icon_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_account Parent
		ON Parent.account_id = Account.parent_account_id
	INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
		ON Board.queue_id = Ticket.ticket_queue_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_resource AssignedTo
		ON AssignedTo.resource_id = Ticket.assigned_resource_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_issue_type IssueType
		ON IssueType.issue_type_id = Ticket.issue_type_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_subissue_type SubIssueType
		ON SubIssueType.subissue_type_id = Ticket.subissue_type_id
	LEFT JOIN Autotask.TF_511394_WH.dbo.wh_installed_product Product
		ON Product.installed_product_id = Ticket.installed_product_id	
	INNER JOIN (
			-- Get Top 10 Issues/SubIssues across all clients for last 60 days
			SELECT TOP 10 IssueType.issue_type_name AS 'Issue', SubIssueType.subissue_type_name as 'SubIssue', COUNT(*) as NumTickets
				FROM Autotask.TF_511394_WH.dbo.wh_task Ticket
				INNER JOIN Autotask.TF_511394_WH.dbo.wh_queue Board
					ON Board.queue_id = Ticket.ticket_queue_id
				LEFT JOIN Autotask.TF_511394_WH.dbo.wh_issue_type IssueType
					ON IssueType.issue_type_id = Ticket.issue_type_id
				LEFT JOIN Autotask.TF_511394_WH.dbo.wh_subissue_type SubIssueType
					ON SubIssueType.subissue_type_id = Ticket.subissue_type_id
				WHERE 1=1
					--and Ticket.Create_Time >= dateadd(dd, -60, GETDATE())
					and Ticket.Create_Time >= dateadd(month, -6, GETDATE())
					--and Ticket.Create_Time >= dateadd(month, -12, GETDATE())

					AND Board.queue_name like '01%'
					and ticket.device_monitor_type_id is null	-- NOT NULL means ticket is an AEM Alert
				GROUP BY IssueType.issue_type_name, SubIssueType.subissue_type_name 
				ORDER BY 3 DESC
				) TopIssues
		ON coalesce(IssueType.issue_type_name, '') + ' - ' + coalesce(SubIssueType.subissue_type_name, '') = coalesce(TopIssues.Issue, '') + ' - ' + coalesce(TopIssues.SubIssue, '')
	WHERE 1=1
					--and Ticket.Create_Time >= dateadd(dd, -60, GETDATE())
					and Ticket.Create_Time >= dateadd(month, -6, GETDATE())
					--and Ticket.Create_Time >= dateadd(month, -12, GETDATE())
		AND Board.queue_name like '01%'
		and ticket.device_monitor_type_id is null	-- NOT NULL means ticket is an AEM Alert
	ORDER BY 1,2,3,4,5,6

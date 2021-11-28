--------------------------------------------------------------------------------------------
-- Find Duplicate AEM records for a machine

SELECT COALESCE(Parent.Account_Name, Account.Account_Name) AS Company_Name, Account.account_name
		, cast(InstalledProduct.device_audit_last_update_time as date) as Last_Update, InstalledProduct.device_audit_hostname, InstalledProduct.device_audit_ip_address
		, InstalledProduct.Serial_Number, wh_device_audit_operating_system_name.name as 'OS', InstalledProduct.device_audit_last_user, InstalledProduct.Reference_Number
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
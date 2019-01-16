CREATE INDEX IDX_SR_Service_RecType_LastUpdateUTC_INCLUDE_SRServiceRecID_CompanyRecID_srbillingmethodid_OverrideFlag
	ON [cwwebapp_webit].[dbo].[SR_Service] ([Rec_Type],[Last_Update_UTC]) 
		INCLUDE ([SR_Service_RecID], [Company_RecID], [sr_billing_method_id], [Override_Flag])
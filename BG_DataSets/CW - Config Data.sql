-- CW - Config Data
  SELECT 
DISTINCT vc.Config_RecID as 'id',
vc.Config_Type,	
vc.Config_Name,	
vc.Manufacturer,	
vc.Serial_Number,	
vc.Model_Number,	
vc.Tag_Number,	
CAST(vc.Date_Purchased AS DATETIME) AS 'Date_Purchased',	
CAST(vc.Date_Installed AS DATETIME) AS 'Date_Installed',	
CAST(vc.Date_Expiration AS DATETIME) AS 'Date_Expiration',	
vc.InstalledBy,		
vc.Company_Name,	
vc.Contact_Name,	
vc.Address_line1,	
vc.Address_line2,	
vc.City,	
vc.State,	
vc.PostalCode,	
vc.Location,	
vc.DeviceID,	
vc.MgmtLink,	
vc.LastLogin,	
vc.ConfigStatus,	
vc.Updated_By,	
CAST(vc.Last_Update AS DATETIME) AS 'Last_Update' 

FROM v_rpt_configuration vc  


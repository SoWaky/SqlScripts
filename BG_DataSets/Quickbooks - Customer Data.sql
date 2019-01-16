-- Quickbooks - Customer Data
   select c.ListID	 as id
,cast(DATE_ADD( DATE_FORMAT(str_to_date(c.timecreated, '%c/%e/%Y %r'), '%Y-%m-%d %T'), INTERVAL TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) HOUR) as datetime) as Created	
,cast(DATE_ADD( DATE_FORMAT(str_to_date(c.timemodified, '%c/%e/%Y %r'), '%Y-%m-%d %T'), INTERVAL TIMESTAMPDIFF(HOUR,CURRENT_TIMESTAMP, UTC_TIMESTAMP) HOUR) as datetime) as last_updated
,c.Name	
,c.FullName	
,c.IsActive	
,c.ClassRef_ListID
,c.ParentRef_ListID	
,c.ParentRef_FullName	
,c.Sublevel	
,c.CompanyName
,c.BillAddress_Addr1	
,c.BillAddress_Addr2	
,c.BillAddress_Addr3	
,c.BillAddress_Addr4	
,c.BillAddress_Addr5	
,c.BillAddress_City	
,c.BillAddress_State	
,concat(c.BillAddress_City,', ',c.BillAddress_State) as bill_city_and_state
,c.BillAddress_PostalCode	
,c.BillAddress_Country	
,c.BillAddress_Note	
,c.ShipAddress_Addr1	
,c.ShipAddress_Addr2	
,c.ShipAddress_Addr3	
,c.ShipAddress_Addr4	
,c.ShipAddress_Addr5	
,c.ShipAddress_City	
,c.ShipAddress_State	
,concat(c.ShipAddress_City,', ',c.ShipAddress_State) as ship_city_and_state
,c.ShipAddress_PostalCode	
,c.ShipAddress_Country	
,c.ShipAddress_Note
,c.Phone as contact_phone	
,c.Mobile	as contact_mobile
,c.Pager	as contact_pager
,c.AltPhone	as altcontact_phone
,c.Fax	as contact_fax
,c.Email	as contact_email
,c.Contact	
,c.AltContact
,c.CustomerTypeRef_FullName	as customer_type
,c.TermsRef_FullName	as terms
,c.SalesRepRef_FullName	as sales_rep
,c.Balance	
,c.TotalBalance	
,c.SalesTaxCodeRef_FullName	
,c.ItemSalesTaxRef_FullName	
,c.SalesTaxCountry	
,c.ResaleNumber	
,c.AccountNumber	
,c.CreditLimit	
,c.PreferredPaymentMethodRef_FullName	
,c.JobStatus	
,c.JobStartDate	
,c.JobProjectedEndDate	
,c.JobEndDate	
,c.JobDesc
,c.JobTypeRef_FullName	
,c.Notes		
,c.PriceLevelRef_FullName	
,c.TaxRegistrationNumber	
,c.CurrencyRef_FullName	
,c.IsStatementWithParent	
,c.PreferredDeliveryMethod	
,c.Status
 FROM customer c   


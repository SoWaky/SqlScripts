-- WARNING:  Set all Agents to Maintenance Mode for about 10 minutes before running this script!
-- The first time the DELETE statement was run, it reset Labtech services and alerts started firing.

SELECT * 
-- DELETE 
	FROM contacts
	WHERE `email` NOT LIKE '%webitservices%'
	AND NOT EXISTS (SELECT * FROM agents a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM alerttemplates a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM computers a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM contactcomputers  a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM contactpwtoken a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM groupagents    a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM groupdagents   a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM locations a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM mobiledevices  a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM networkdevices a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM outgoingsms    a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM pluginalerts   a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM plugin_ad_users   a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM plugin_cw_contactmapping    a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM probeconfig    a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM reportscheduler   a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM searches  a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM subgroupscontacts a WHERE a.ContactID = contacts.ContactID)   
	AND NOT EXISTS (SELECT * FROM subgroupwchildrencontacts    a WHERE a.ContactID = contacts.ContactID)   
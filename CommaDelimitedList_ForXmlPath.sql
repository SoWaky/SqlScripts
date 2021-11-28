-- Use FOR XML Path to created comma-delimited list from a child table

-- Space after comma
select h.PRCID
		, STUFF((SELECT ', ' + i.FirstName 
					FROM Individual i
					WHERE i.HouseholdId = h.HouseholdId
					FOR XML PATH(''))
				, 1, 2, '') AS NameList
	from household h 
	WHERE h.PRCID = '97137'

-- NO Space after comma
select h.PRCID
		, STUFF((SELECT ',' + i.FirstName 
					FROM Individual i
					WHERE i.HouseholdId = h.HouseholdId
					FOR XML PATH(''))
				, 1, 1, '') AS NameList
	from household h 
	WHERE h.PRCID = '97137'
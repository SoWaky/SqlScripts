DECLARE @Yr int, @Mo int, @SortOrder int
set @Yr = 2018
SET @Mo = 4
set @SortOrder = 1
BEGIN TRAN
-- COMMIT
-- ROLLBACK
-- SELECT * FROM vw_ProfitLoss order by 2 ,3 desc,4 desc
-- select * from LineItemCategory

--------------------------------------------------------------------------------------


-- ALSO remove the ' - nn Mo Remaining' text from the KPIs

--------------------------------------------------------------------------------------
update profitloss set LineItemDescription = ltrim(rtrim(LineItemDescription))
update profitloss set LineItemDescription = replace(LineItemDescription, char(13), '')
update profitloss set LineItemDescription = replace(LineItemDescription, char(10), '')
update profitloss set LineItemDescription = replace(LineItemDescription, char(9), '')

-- ALSO remove the ' - nn Mo Remaining' text from the KPIs

	update profitloss
		set SortOrder = cast(left(lineitemdescription, 4) as int)
		where left(lineitemdescription,1) in ('1','2','3','4','5','6','7','8','9')
			
	update profitloss
		set SortOrder = 10000
		where LineItemDescription like 'Cash%'
			
	update profitloss
		set SortOrder = 10000
		where LineItemDescription like 'Cash%'
			
	update profitloss
		set SortOrder = 10100
		where LineItemDescription like 'AR'
			
	update profitloss
		set SortOrder = 10200
		where LineItemDescription like 'AP'
			
	update profitloss
		set SortOrder = 10300
		where LineItemDescription like 'Short Term Debt%'
			
	update profitloss
		set SortOrder = 10400
		where LineItemDescription like 'Term Note%'
			
	update profitloss
		set SortOrder = 10500
		where LineItemDescription like 'Term Note (48 Mo)'

	update profitloss
		set LineItemCategoryId = 1
		where left(lineitemdescription,1) in ('4')
			
	update profitloss
		set LineItemCategoryId = 2
		where left(lineitemdescription,1) in ('5','6')
			
	update profitloss
		set LineItemCategoryId = 5, SortOrder = 4990
		where LineItemDescription = 'Gross Revenues $ Amount'
			
	update profitloss
		set LineItemCategoryId = 2, SortOrder = 4991
		where LineItemDescription = '5030 · Merchandise COGS'
			
	update profitloss
		set LineItemCategoryId = 9, SortOrder = 4992
		where LineItemDescription = 'Gross Profit $ Amount'
			
	update profitloss
		set LineItemCategoryId = 6, SortOrder = 7000
		where LineItemDescription = 'Operating Expense'
			
	update profitloss
		set LineItemCategoryId = 7, SortOrder = 7100
		where LineItemDescription = 'Net Income $ Amount'
			
	update profitloss
		set LineItemCategoryId = 8, SortOrder = 7200
		where LineItemDescription = 'Net Income %'

		
	update profitloss
		set LineItemDescription = '6350 · Genl Svs & Admin'
		where LineItemDescription = '6350 · General Svs & Admin'

select SortOrder, LineItemCategoryId, LineItemDescription, count(*)
	from profitloss
	group by SortOrder, LineItemCategoryId, LineItemDescription
	order by 1,3

--commit
----------------------------------------------------------


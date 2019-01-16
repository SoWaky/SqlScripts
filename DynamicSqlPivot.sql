declare @Sql nvarchar(1000), @FieldList nvarchar(1000), @DueDate datetime

declare csrUpdates cursor for
	SELECT DISTINCT DueDate
		FROM poheader WITH (NOLOCK)
		WHERE poheader.openorder = 1
	
open csrUpdates
fetch next from csrUpdates INTO @DueDate

SET @FieldList = ''

while @@Fetch_Status = 0
begin
	SET @FieldList = @FieldList + ',[' + convert(char(10), @DueDate, 111) + ']'

	fetch next from csrUpdates INTO @DueDate
end

close csrUpdates
deallocate csrUpdates


SET @Sql = '
SELECT DueDate' + @FieldList + '
FROM
(
SELECT porel.DueDate, SUM(OrderQty) AS OrderQty
	FROM poheader  WITH (NOLOCK)
	WHERE poheader.openorder = 1 
	GROUP BY poheader.DueDate
) AS SourceTable
PIVOT
(
	SUM(OrderQty)
	FOR DueDate IN (' + substring(@FieldList, 2, 1000) + ')
) AS pvt
'
print @Sql
exec sp_executesql @Sql

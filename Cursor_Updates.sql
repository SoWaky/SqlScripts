
declare @From varchar(100), @To varchar(100)

declare csrUpdates cursor for
	select * from #Updates
	
open csrUpdates
fetch next from csrUpdates INTO @From, @To

while @@Fetch_Status = 0
begin
	SELECT *
		FROM BinWhse
		WHERE binnum = @To 

	fetch next from csrUpdates INTO @From, @To
end

close csrUpdates
deallocate csrUpdates

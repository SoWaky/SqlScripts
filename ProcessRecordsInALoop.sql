-- SELECT records into the #tmp table that you want to process in a loop

drop table #tmp

select [Some Fields]
		into #tmp
		from [Some Table]
		where 1=1

while exists (select * from #tmp)
begin
	INSERT INTO [Some Other Table]
		select top 10 *
			from #tmp

	delete top (10) from #tmp
end
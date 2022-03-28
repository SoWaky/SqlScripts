IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[dbo].[GetDaylightSavingsTimeEnd]')
                  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [dbo].[GetDaylightSavingsTimeEnd]

GO 

CREATE function [dbo].[GetDaylightSavingsTimeEnd] 
(@DateTime datetime)
RETURNS smalldatetime
as
begin
   declare @DTSEndWeek smalldatetime
   set @DTSEndWeek = '11/01/' + convert(varchar,DATEPART(year, @DateTime))
   return case datepart(dw,dateadd(week,1,@DTSEndWeek))
     when 1 then dateadd(hour,2,@DTSEndWeek)
     when 2 then dateadd(hour,146,@DTSEndWeek)
     when 3 then dateadd(hour,122,@DTSEndWeek)
     when 4 then dateadd(hour,98,@DTSEndWeek)
     when 5 then dateadd(hour,74,@DTSEndWeek)
     when 6 then dateadd(hour,50,@DTSEndWeek)
     when 7 then dateadd(hour,26,@DTSEndWeek)
   end
end

GO

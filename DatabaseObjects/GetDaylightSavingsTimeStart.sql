IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[dbo].[GetDaylightSavingsTimeStart]')
                  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [dbo].[GetDaylightSavingsTimeStart]

GO 


CREATE function [dbo].[GetDaylightSavingsTimeStart] 
(@DateTime datetime)
RETURNS smalldatetime
as
begin
   declare @DTSStartWeek smalldatetime, @DTSEndWeek smalldatetime
   set @DTSStartWeek = '03/01/' + convert(varchar,DATEPART(year, @DateTime))
   return case datepart(dw,@DTSStartWeek)
     when 1 then dateadd(hour,170,@DTSStartWeek)
     when 2 then dateadd(hour,314,@DTSStartWeek)
     when 3 then dateadd(hour,290,@DTSStartWeek)
     when 4 then dateadd(hour,266,@DTSStartWeek)
     when 5 then dateadd(hour,242,@DTSStartWeek)
     when 6 then dateadd(hour,218,@DTSStartWeek)
     when 7 then dateadd(hour,194,@DTSStartWeek)
   end
end

GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetFirstDayOfWeek]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.GetFirstDayOfWeek
GO

CREATE  FUNCTION [dbo].[GetFirstDayOfWeek]
( @tdDate DATETIME
)
RETURNS DATETIME
AS
BEGIN
	RETURN DATEADD(week, DATEDIFF(week, -1, @tdDate), -1)
END
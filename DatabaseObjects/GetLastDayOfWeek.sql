IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetLastDayOfWeek]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.GetLastDayOfWeek
GO

CREATE  FUNCTION [dbo].[GetLastDayOfWeek]
( @tdDate DATETIME
)
RETURNS DATETIME
AS
BEGIN
	RETURN DATEADD(day, 7, @tdDate - DATEPART(dw, @tdDate))
END
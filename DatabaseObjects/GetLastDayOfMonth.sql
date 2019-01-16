IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetLastDayOfMonth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.GetLastDayOfMonth
GO

CREATE  FUNCTION [dbo].[GetLastDayOfMonth]
( @tdDate DATETIME
)
RETURNS DATETIME
AS
BEGIN
	RETURN DATEADD(m, DATEDIFF(m, 0, DATEADD(m, 1, @tdDate)), -1)
END

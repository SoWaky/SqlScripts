IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetFirstDayOfMonth]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.GetFirstDayOfMonth
GO

CREATE  FUNCTION [dbo].[GetFirstDayOfMonth]
( @tdDate DATETIME
)
RETURNS DATETIME
AS
BEGIN
	RETURN DATEADD(m, DATEDIFF(m, 0, @tdDate), 0)
END
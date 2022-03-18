IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EndOfDay]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.EndOfDay
GO

CREATE  FUNCTION [dbo].[EndOfDay]
( @tdDate DATETIME
)
RETURNS DATETIME
AS
BEGIN
	RETURN DATEADD(second, -1, datediff(dd, 0, @tdDate) + 1)
END
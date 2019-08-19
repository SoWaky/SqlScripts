IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetFirstDayOfFiscalYear]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.GetFirstDayOfFiscalYear
GO

CREATE  FUNCTION [dbo].[GetFirstDayOfFiscalYear]
( @YearsToAdd int = 0
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @FYStart DATETIME
	IF (DATEPART(mm, GETDATE()) < 7)
		SET @FYStart = CAST('07/01/' + CAST(DATEPART(yy, GETDATE()) - 1 + @YearsToAdd AS CHAR(4)) AS DATETIME)
	ELSE
		SET @FYStart = CAST('07/01/' + CAST(DATEPART(yy, GETDATE()) + @YearsToAdd AS CHAR(4)) AS DATETIME)

	RETURN @FYStart
END
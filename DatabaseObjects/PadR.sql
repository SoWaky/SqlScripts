-- print dbo.PadR(3, 10, '0')
-- print REPLACE(STR(5, 10), SPACE(1), '0') 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PadR]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.PadR
GO

CREATE  FUNCTION [dbo].[PadR]
( 
@Number int
, @NumChars int
, @PadChar char(1)
)
RETURNS varchar(max)
AS
BEGIN
	RETURN REPLACE(LEFT(RTRIM(LTRIM(STR(@Number))) + space(@NumChars), @NumChars), SPACE(1), @PadChar)
END

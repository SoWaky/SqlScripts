-- print dbo.PadL(3, 10, '0')
-- print REPLACE(STR(5, 10), SPACE(1), '0') 

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PadL]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.PadL
GO

CREATE  FUNCTION [dbo].[PadL]
( 
@Number int
, @NumChars int
, @PadChar char(1)
)
RETURNS varchar(max)
AS
BEGIN
	RETURN REPLACE(STR(@Number, @NumChars), SPACE(1), @PadChar) 
END

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Occurs]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.Occurs
GO

CREATE  FUNCTION [dbo].[Occurs]
( 
@StringSearched varchar(4000)
, @SearchExpression varchar(4000)
)
RETURNS BIT
AS
BEGIN
	RETURN (LEN(@StringSearched) - LEN(REPLACE(@StringSearched, @SearchExpression, '')))
END

CREATE FUNCTION [dbo].[GetFirstWord] (@value varchar(max))
RETURNS varchar(max)
AS
BEGIN
	SET @value = LTRIM(RTRIM(@value))

    RETURN CASE CHARINDEX(' ', @value, 1)
        WHEN 0 THEN @value
        ELSE SUBSTRING(@value, 1, CHARINDEX(' ', @value, 1) - 1) END
END

CREATE FUNCTION [dbo].[GetSecondWord] (@value varchar(max))
RETURNS varchar(max)
AS
BEGIN
	SET @value = LTRIM(RTRIM(@value))

    RETURN LTRIM(SUBSTRING(@value,CHARINDEX(' ',@value), CHARINDEX(' ',LTRIM(SUBSTRING(@value,CHARINDEX(' ',@value),LEN(@value)-CHARINDEX(' ',@value)))) ))
END



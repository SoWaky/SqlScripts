-- drop FUNCTION [dbo].[GetFirstWord]

CREATE FUNCTION [dbo].[GetFirstWord] (@value varchar(max))
RETURNS varchar(max)
AS
BEGIN
	SET @value = LTRIM(RTRIM(@value))

    RETURN CASE CHARINDEX(' ', @value, 1)
        WHEN 0 THEN @value
        ELSE SUBSTRING(@value, 1, CHARINDEX(' ', @value, 1) - 1) END
END
go

-- drop FUNCTION [dbo].[GetSecondWord]

CREATE FUNCTION [dbo].[GetSecondWord] (@value varchar(max))
RETURNS varchar(max)
AS
BEGIN
	SET @value = LTRIM(RTRIM(@value))

	declare @Length int
	SET @Length = CHARINDEX(' ', LTRIM(SUBSTRING(@value,CHARINDEX(' ',@value), LEN(@value)-CHARINDEX(' ',@value))))
	IF @Length = 0
		SET @Length = LEN(@Value)

    RETURN LTRIM(SUBSTRING(@value, CHARINDEX(' ', @value), @Length))
END
go
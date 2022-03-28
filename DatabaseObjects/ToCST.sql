IF EXISTS (SELECT *
           FROM   sys.objects
           WHERE  object_id = OBJECT_ID(N'[dbo].[ToCST]')
                  AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
  DROP FUNCTION [dbo].[ToCST]

GO 

CREATE FUNCTION dbo.ToCST
(@DateTime datetime)
RETURNS datetime
AS
BEGIN

	DECLARE @DstStart datetime, @DstEnd datetime, @hours int
	SET @DstStart = dbo.GetDaylightSavingsTimeStart(@DateTime)
	SET @DstEnd = dbo.GetDaylightSavingsTimeEnd(@DateTime)

	IF @DateTime BETWEEN @DstStart AND @DstEnd
		SET @hours = -5
	ELSE
		SET @hours = -6	

	RETURN DATEADD(hh, @hours, @DateTime)
END

GO
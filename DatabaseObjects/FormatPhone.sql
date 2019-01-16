CREATE FUNCTION dbo.FormatPhone
(@PhoneNumber VARCHAR(256))
RETURNS VARCHAR(256)
AS
BEGIN

-- Formats phone number like 000-000-0000 x000
-- Leaves numbers less than 7 digits alone

SET @PhoneNumber = dbo.GetNumeric(@PhoneNumber)

SET @PhoneNumber = case when len(@PhoneNumber) < 7 then @PhoneNumber
						when len(@PhoneNumber) = 7 then left(@PhoneNumber,3) + '-' + SUBSTRING(@PhoneNumber, 4, 4)
						when len(@PhoneNumber) between 8 and 10 then left(@PhoneNumber,3) + '-' + SUBSTRING(@PhoneNumber, 4, 3) + '-' + SUBSTRING(@PhoneNumber, 7, 4)
						else left(@PhoneNumber,3) + '-' + SUBSTRING(@PhoneNumber, 4, 3) + '-' + SUBSTRING(@PhoneNumber, 7, 4) + ' x' + substring(@PhoneNumber, 11, 10) 
						end

RETURN @PhoneNumber
END
GO
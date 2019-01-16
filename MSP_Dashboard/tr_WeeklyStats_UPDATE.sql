USE MSP_Dashboard
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Matthew Price
-- Create date: July 5, 2017
-- Description:	Force Update_Date_Time to be populated when records are updated
-- =============================================
CREATE TRIGGER dbo.tr_WeeklyStats_UPDATE 
   ON  dbo.WeeklyStats 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	UPDATE WeeklyStats 
        SET Update_Date_Time = GETDATE()
        FROM WeeklyStats S 
		INNER JOIN Inserted I 
        ON S.WeeklyStats_ID = I.WeeklyStats_ID
END
GO

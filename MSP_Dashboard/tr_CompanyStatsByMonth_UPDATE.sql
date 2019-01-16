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
CREATE TRIGGER [dbo].[tr_CompanyStatsByMonth_UPDATE] 
   ON  [dbo].[CompanyStatsByMonth] 
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF NOT UPDATE(Update_Date_Time)
		-- Insert statements for trigger here
		UPDATE CompanyStatsByMonth 
			SET Update_Date_Time = GETDATE()
			FROM CompanyStatsByMonth S 
			INNER JOIN Inserted I 
			ON S.CompanyStatsByMonth_ID = I.CompanyStatsByMonth_ID
END
GO

ALTER TABLE [dbo].[CompanyStatsByMonth] ENABLE TRIGGER [tr_CompanyStatsByMonth_UPDATE]
GO

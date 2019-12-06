USE [master]
GO

-- Create new Login at the server level named Remote
CREATE LOGIN [Remote] WITH PASSWORD=N'L1nksRG00d#', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO

-- Loop through every database that isn't built into SQL Server
--	and create a user account linked to the Login created at the server level

DECLARE @dbname VARCHAR(50)   
DECLARE @statement NVARCHAR(max)

DECLARE db_cursor CURSOR 
	LOCAL FAST_FORWARD
	FOR  
	SELECT name
		FROM MASTER.dbo.sysdatabases
		WHERE name NOT IN ('master','model','msdb','tempdb','distribution')  

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @dbname  
WHILE @@FETCH_STATUS = 0  
BEGIN  

	-- Add more roles to the SQL Statement, if needed
	SELECT @statement = 'USE '+ @dbname +';
		CREATE USER [Remote] FOR LOGIN [Remote]; 
		EXEC sp_addrolemember N''db_datareader'', [Remote];'

	PRINT @statement

	BEGIN TRY
		EXEC sp_executesql @statement
	END TRY	
    BEGIN CATCH
        SELECT  
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;  
    END CATCH

	FETCH NEXT FROM db_cursor INTO @dbname  
END  
CLOSE db_cursor  
DEALLOCATE db_cursor 
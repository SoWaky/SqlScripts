EXEC master.dbo.sp_addlinkedserver
 @server = N'LoavesTest', 
 @srvproduct=N'',
  @provider=N'SQLNCLI',
   @datasrc=N'servicetrackerlf.database.windows.net',
    @catalog=N'LoavesTest'
 /* For security reasons, the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin
 @rmtsrvname=N'LoavesTest',
 @useself=N'False',
 @locallogin=NULL,
 @rmtuser=N'development',@rmtpassword='T@ch$.2012'
GO
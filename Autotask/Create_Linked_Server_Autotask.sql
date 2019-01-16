USE [master]
GO

/****** Object:  LinkedServer [Autotask]    Script Date: 12/4/2017 10:36:05 AM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'Autotask', @srvproduct=N'SQL', @provider=N'SQLNCLI', @datasrc=N'reports15.autotask.net'

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'Autotask',@useself=N'False',@locallogin=NULL,@rmtuser=N'webitservices',@rmtpassword='Falcon299Ferret'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'Autotask', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO



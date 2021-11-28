/* Re-sizing TempDB */
USE [master]; 
GO 
ALTER DATABASE tempdb MODIFY FILE (NAME='tempdev', SIZE=2GB, FILEGROWTH = 100);
GO
/* Adding three additional files */
USE [master];
GO

ALTER DATABASE [tempdb] ADD FILE 
	(NAME = N'tempdev2', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.INTRANETDEV01\MSSQL\DATA\tempdb2.ndf' , SIZE = 2GB , FILEGROWTH = 100);
ALTER DATABASE [tempdb] ADD FILE 
	(NAME = N'tempdev3', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.INTRANETDEV01\MSSQL\DATA\tempdb3.ndf' , SIZE = 2GB , FILEGROWTH = 100);
ALTER DATABASE [tempdb] ADD FILE 
	(NAME = N'tempdev4', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.INTRANETDEV01\MSSQL\DATA\tempdb4.ndf' , SIZE = 2GB , FILEGROWTH = 100);
ALTER DATABASE [tempdb] ADD FILE 
	(NAME = N'tempdev5', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.INTRANETDEV01\MSSQL\DATA\tempdb5.ndf' , SIZE = 2GB , FILEGROWTH = 100);
ALTER DATABASE [tempdb] ADD FILE 
	(NAME = N'tempdev6', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.INTRANETDEV01\MSSQL\DATA\tempdb6.ndf' , SIZE = 2GB , FILEGROWTH = 100);
ALTER DATABASE [tempdb] ADD FILE 
	(NAME = N'tempdev7', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.INTRANETDEV01\MSSQL\DATA\tempdb7.ndf' , SIZE = 2GB , FILEGROWTH = 100);
ALTER DATABASE [tempdb] ADD FILE 
	(NAME = N'tempdev8', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL11.INTRANETDEV01\MSSQL\DATA\tempdb8.ndf' , SIZE = 2GB , FILEGROWTH = 100);
GO
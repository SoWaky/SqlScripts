-- You don't need a SQL script to copy SQL jobs from one server to another
-- You can do it using SSMS

--Instructions

--Open SSMS
--Open Object Explorer Details of SSMS with F7 (This is not the same as Object Explorer) 
--Drill down to SQL Server Agent - Jobs
--Select all Jobs in the list
--Right-click > Script Job as > Create to: File
--Copy the file to the other server and run it there to create the jobs there
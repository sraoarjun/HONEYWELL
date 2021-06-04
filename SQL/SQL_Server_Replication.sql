USE master 
exec sp_changedistpublisher
	@Publisher = 'HMECL003459\MSSQLSERVER01',
    @property = N'working_directory', 
    @value = 'C:\ARJUN\WORK\SQL\ReplData';
GO




USE PublishedDatabase
GO
EXEC sp_changedbowner 'sa'
GO


sp_helptext 'sp_changedbowner'


select * from sys.a


SELECT IS_MEMBER('db_securityadmin');  



use [master]
exec sp_helpreplicationdboption @dbname = N'Test'
go




drop table if exists dbo.Test
GO
create table dbo.Test(ID int identity(1,1) primary key , Full_Name varchar(100))
GO

insert into dbo.Test(Full_Name)
values
('Arjun BS'),
('Nithash R'),
('Panna Arjun')


select * from dbo.Test
go




--- Connect Subscriber
--:connect TestSubSQL1
use [master]
exec sp_helpreplicationdboption @dbname = N'Test'
go

use [TEST]
exec sp_subscription_cleanup @publisher = N'HMECL003459\MSSQLSERVER01', @publisher_db = N'Test', 
@publication = N'PubTest'
go





-- Drop Subscription
use [TEST]
exec sp_dropsubscription @publication = N'PubTest', @subscriber = N'all', 
@destination_db = N'TEST', @article = N'all'
go
-- Drop publication
exec sp_droppublication @publication = N'PubTest'
-- Disable replication db option
exec sp_replicationdboption @dbname = N'TEST', @optname = N'publish', @value = N'false'
GO
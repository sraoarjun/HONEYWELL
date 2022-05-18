
declare @S nvarchar(max) = 'select @purge_status_in = 1'

declare @xx int
set @xx = 0

exec sp_executesql @S, N'@purge_status_in int out', @xx out

select @xx
---------------------


drop table if exists dbo.Staging_IDs
go
create table dbo.Staging_IDs (id int)

insert into dbo.Staging_IDs
select 1 
union 
select 2
union 
select 3 
union 
select 4 

select count(1) from dbo.Staging_IDs with (nolock)

truncate table dbo.Staging_IDs -- truncating this and running the below  will give @purge_status = 1

declare @schemaname varchar(100) = 'dbo'
declare @int int = 0
declare @sql nvarchar(max)=''
declare @purge_status bit = 0

set @sql = 'IF (SELECT COUNT(1) AS cnt FROM '+@schemaname +'.' + ' Staging_IDs) = 0
								BEGIN 
									SET @purge_status_in = 1 
								END'

exec sp_executesql @sql, N'@purge_status_in bit out', @purge_status out

select @purge_status as purge_status



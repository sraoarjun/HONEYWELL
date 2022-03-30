SET NOCOUNT ON 
DECLARE @database_name VARCHAR(100)= 'Honeywell.MES.Operations.DataModel.OperationsDB',
@storage_option_type VARCHAR(100) = 'Quarterly', -- Yearly,Half-Yearly,Quarterly,Monthly
@db_suffix varchar(100),
@dt DATETIME = '4/1/2022',
@sql VARCHAR(MAX) =''

--select DATEDIFF(DAY,@dt,getdate()) as dt_time

if @storage_option_type = 'Yearly'
begin
	 set @db_suffix = CAST(YEAR(@dt) AS VARCHAR(4))
end 
else if @storage_option_type = 'Half-Yearly'
begin
	set @db_suffix = ''
end 
else if @storage_option_type = 'Quarterly'
begin
	 set @db_suffix = CAST(YEAR(@dt) AS VARCHAR(4)) + 
											case 
												when CAST(MONTH(@dt) AS VARCHAR(2)) < 4 then 'Q1'
												when CAST(MONTH(@dt) AS VARCHAR(2)) > 3 and CAST(MONTH(@dt) AS VARCHAR(2)) < 7 then 'Q2'
												when CAST(MONTH(@dt) AS VARCHAR(2)) > 6 and CAST(MONTH(@dt) AS VARCHAR(2)) < 10 then 'Q3'
												--when CAST(MONTH(@dt) AS VARCHAR(2)) > 3 and CAST(MONTH(@dt) AS VARCHAR(2)) < 7 then 'Q4'
												else 'Q4'
											end
end 
else if @storage_option_type = 'Monthly'
begin
	set @db_suffix = CAST(YEAR(@dt) AS VARCHAR(4)) + 
											case 
												when CAST(MONTH(@dt) AS VARCHAR(2)) < 10 then '0'+CAST(MONTH(@dt) AS VARCHAR(1))
												else CAST(MONTH(@dt) AS VARCHAR(2))
											end
	

end 

select  @db_suffix 


SET @sql = 'CREATE DATABASE ['+ @database_name + '_'+ @db_suffix +']'
PRINT @sql
--EXEC (@sql)


--drop database hwlassets_epm_2022

--select * from sys.master_files m join sys.databases d 
--on m.database_id = d.database_id
--where d.name = 'hwlassets_epm_2022'

--drop database hwlassets_epm_2022
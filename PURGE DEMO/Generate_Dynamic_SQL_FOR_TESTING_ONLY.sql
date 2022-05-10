USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO
/*

begin tran

EXEC dbo.Generate_Dynamic_SQL 42

rollback tran


*/

DROP PROCEDURE IF EXISTS dbo.Generate_Dynamic_SQL
GO
CREATE PROCEDURE dbo.Generate_Dynamic_SQL (@archival_config_id_input int)
AS
BEGIN
declare @source_database_name varchar(200)
declare @destination_database_name varchar(200)
declare @tablename varchar(500)  
declare @schemaname varchar(100)
declare @batch_size int 
declare @archival_config_id int 
declare @tablename_suffix varchar(100)= ''
declare @purgeOnly bit
declare @filters varchar(1000)
declare @predicate_sql varchar(1000)
declare @sql varchar(5000)
declare @sqlstmt nvarchar(4000)
declare @idname varchar(50)
declare @tablearchive varchar(500)
declare @column_list varchar(8000)=''
declare @insert_sql varchar(8000)=''
declare @delete_sql varchar(8000)=''
declare @pk_columnname varchar(100)=''
declare @ExistsCount int = 0
declare @PK_column_dataType varchar(100)
declare @numOfRowsAffected int = 0
declare @history_data_retention_days int 
declare @history_data_retention_cut_off_date_string varchar(100)
declare @purgeOperation_ON_OFF char(5)
declare @lookupName varchar(250)
declare @error_msg varchar(max)
declare @total_number_of_records_affected int = 0 

SET NOCOUNT ON 


set @purgeOperation_ON_OFF = (select [Value] from dbo.Lookups where name = 'Enable_Purge_Operation')

IF @purgeOperation_ON_OFF <> 'True'
BEGIN
	PRINT 'Purge Operation has been set to OFF'
	RETURN ;
END 


SET @batch_size = (SELECT setting_value FROM dbo.Archival_Settings_Config WHERE setting_name = 'purge_batch_size')

CREATE TABLE 
#temp_Archival_Execution_Log
(	id int identity(1,1) primary key ,
	schemaname varchar(100),
	tablename varchar(500),
	filters varchar(1000)
)



declare tableCursor cursor FAST_FORWARD FOR

SELECT  
	archival_config_id , table_schema,table_name,
		filters,LookupName 
FROM 
	dbo.Archival_Config
where 
	--is_enabled =  1 and 
	archival_config_id = @archival_config_id_input
order by 
	archival_config_id asc;

OPEN tableCursor
FETCH NEXT FROM 
			tableCursor 
	INTO  @archival_config_id,@schemaname,@tablename,@filters,@lookupName 

WHILE @@FETCH_STATUS = 0
          BEGIN




set @pk_columnname = (select distinct C.COLUMN_NAME FROM  
												INFORMATION_SCHEMA.TABLE_CONSTRAINTS T  
												JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE C  
												ON C.CONSTRAINT_NAME=T.CONSTRAINT_NAME  
												WHERE  
												C.TABLE_NAME=@tablename  
												and T.CONSTRAINT_TYPE='PRIMARY KEY' 
												and C.TABLE_SCHEMA = @schemaname
												)

					 Select @column_list =  SUBSTRING( 
									( 
										 SELECT ',' + Column_Name AS 'data()'
											 FROM INFORMATION_SCHEMA.COLUMNS where  TABLE_SCHEMA = @schemaname  AND TABLE_NAME = @tablename FOR XML PATH('') 
									), 2 , 9999) 

                   SET @tablearchive =  CASE WHEN ISNULL(@tablename_suffix,'') <> '' THEN @tablename + '_'+ @tablename_suffix
				   ELSE @tablename END 
				

				SELECT  @PK_column_dataType =   
							ic.DATA_TYPE
						FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS TC 
						INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KU
						INNER JOIN INFORMATION_SCHEMA.COLUMNS ic on ku.COLUMN_NAME = ic.COLUMN_NAME
							ON TC.CONSTRAINT_TYPE = 'PRIMARY KEY' 
							AND TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME 
							AND KU.table_name=@tablename
							and ic.TABLE_NAME = @tablename
						ORDER BY 
								KU.TABLE_NAME
							,KU.ORDINAL_POSITION
									
				--print 'pk_columnname is ' + cast(@pk_columnname as varchar(100))
						
				-- If the PK is an INTEGER Column
				--IF @PK_column_dataType = 'int' -- IF PK  is of Integer Data Type
				--BEGIN
				------ Create a staging table to Hold candidate ids
				--		PRINT 'PK is of integer data type'
				--END
				---- if the PK is a UNIQUEIDENTIFIER
				--ELSE  
				--	BEGIN
				--		PRINT 'PK is of Uniqueidentifier data type'
				--END


				--section get all the lookup / configuration values  -- STARTS 
				--SET @history_data_retention_days = (select Value from dbo.Lookups where Name = @lookupName)
				SET @history_data_retention_days = (select [Value] from dbo.Lookups where Name = @lookupName)
				SET @history_data_retention_cut_off_date_string = cast(DATEADD(DAY,-@history_data_retention_days,getdate()) as varchar)
				--section get all the lookup / configuration values  -- ENDS


				SET @insert_sql = 'select top ('+cast(@batch_size as varchar)+') '+@pk_columnname + ' from '+ @schemaname+ '.' + @tablename 
				SET @predicate_sql = case when @filters is null then ' where 1=1'
									else ' ' +replace(@filters,'{Date_Parameter}',''''+@history_data_retention_cut_off_date_string+'''') end 

				SET @insert_sql = @insert_sql + @predicate_sql
				
				PRINT @insert_sql 

				
			--- Execution logging ENDS--
		FETCH NEXT FROM 
				tableCursor 
			INTO 					
			@archival_config_id,@schemaname,@tablename,@filters,@lookupName 

			
END-- Cursor Loop End
DROP TABLE #temp_Archival_Execution_Log -- Drop the temp table 
CLOSE tableCursor
DEALLOCATE tableCursor				
							
END 






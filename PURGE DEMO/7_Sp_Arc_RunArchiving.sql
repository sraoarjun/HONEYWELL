/*

begin tran
exec dbo.Sp_Arc_RunArchiving

rollback tran


*/

DROP PROCEDURE IF EXISTS dbo.Sp_Arc_RunArchiving
GO
CREATE PROCEDURE dbo.Sp_Arc_RunArchiving
AS
BEGIN


declare @source_database_name varchar(200)
declare @destination_database_name varchar(200)
declare @tablename varchar(500)  
declare @schemaname varchar(100)
declare @batchsize int 
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

set nocount on 

declare tableCursor cursor FAST_FORWARD FOR

SELECT  
	archival_config_id , table_schema,table_name,batch_size,PurgeOnly,filters,source_database_name,destination_database_name 
FROM 
	dbo.Archival_Config
where 
	is_enabled =  1
order by 
	archival_config_id asc;

OPEN tableCursor
FETCH NEXT FROM tableCursor INTO  @archival_config_id,@schemaname,@tablename,@batchsize,@PurgeOnly,@filters,@source_database_name ,@destination_database_name 

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
				   	
				   
					IF OBJECT_ID(N'tempdb..Staging_IDs', N'U') IS NOT NULL  
					   DROP TABLE tempdb..Staging_IDs;
					   				 

					  select  @PK_column_dataType =   
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
									
						
						
						-- If the PK is an INTEGER Column
						IF @PK_column_dataType = 'int' -- IF PK  is of Integer Data Type
						BEGIN
								---- Create a staging table to Hold candidate ids
								CREATE TABLE tempdb..Staging_IDs(ID int PRIMARY KEY)
						END
							ELSE  -- if the PK is a UNIQUEIDENTIFIER
							BEGIN
								CREATE TABLE tempdb..Staging_IDs (ID uniqueidentifier PRIMARY KEY);
							END


							---- Process the records  (Archiving of the records starts here)
					WHILE (1=1)
						BEGIN
							TRUNCATE TABLE tempdb..Staging_IDs

							SET @insert_sql = 'insert into tempdb..Staging_IDs'+
										' select top ('+cast(@batchsize as varchar)+') '+@pk_columnname + ' from '+ @schemaname+ '.' + @tablename 
									
							set @predicate_sql = case when @filters is null then ' where CreatedTime >= (select isnull(max (CreatedTime),''1900-01-01'') from ' +@destination_database_name +'.'++@schemaname+ '.' + @tablearchive + ')'+' order by CreatedTime' 
									--else ' where ' + @filters end 
									else ' ' + @filters end 

							set @insert_sql = @insert_sql + @predicate_sql

								--print @insert_sql
								exec (@insert_sql);

								if (select count(1) as cnt from tempdb..Staging_IDs) = 0
								begin 
									break ;
								end 
								
							BEGIN TRY
								--BEGIN TRAN
								if @purgeOnly = 0 
								BEGIN
									EXEC dbo.Sp_Arc_Insert_Into_Archive @schemaname,@tablename,@destination_database_name,@filters,@pk_columnname
								END
								EXEC dbo.sp_Arc_Delete_from_source @schemaname,@tablename,@filters,@pk_columnname
								set @numOfRowsAffected = (select count(1) as cnt from tempdb..Staging_IDs)-- Get the number of rows affected
								--COMMIT TRAN
							END TRY 
							BEGIN CATCH 
							declare @error_msg varchar(max)
								SET @error_msg = 'Error Procedure - ' + ERROR_PROCEDURE() + ' '+ 'Error Line - ' + cast(ERROR_LINE() as varchar) + ' ' + 'Error Message - ' + ERROR_MESSAGE()
								--ROLLBACK TRAN
								INSERT INTO dbo.Archival_Error_Log(archival_config_id,error_description,error_date)
								SELECT @archival_config_id, @error_msg , GETDATE()

							END CATCH 

							PRINT 'Number of rows affected - ' + cast(@numOfRowsAffected as varchar(10))

						END -- While Loop End
					
			 FETCH NEXT FROM tableCursor INTO @archival_config_id,@schemaname,@tablename,@batchsize,@purgeOnly,@filters,@source_database_name ,@destination_database_name 
END-- Cursor Loop End
CLOSE tableCursor
DEALLOCATE tableCursor				
							
END 
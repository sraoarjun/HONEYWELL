DROP PROCEDURE IF EXISTS [dbo].[Arc_Chk_TableCreation]
GO
/*
	EXEC [dbo].[Arc_Chk_TableCreation]
*/
CREATE PROCEDURE [dbo].[Arc_Chk_TableCreation]
AS  
BEGIN  
SET NOCOUNT ON   
BEGIN TRY  

if object_id('tempdb..#TMPPARENT') is not null  
drop table #TMPPARENT;  
create table  #TMPPARENT  (ID INT IDENTITY(1,1),tablename varchar(256),Linked_Server_Name varchar(100),ARCHIVE_DATABASE_NAME varchar(100));
  INSERT INTO #TMPPARENT SELECT  DISTINCT  table_name ,null ,destination_database_name from dbo.Archival_Config  where is_enabled = 1 
--and  archival_config_id = 3
if object_id('tempdb..#tmp') is not null  
drop table #tmp;  
--create table  #tmp  (id int IDENTITY(1,1), tablename varchar(256), lvl int, ParentTable varchar(256));  
create table  #tmp  (id int,tablename varchar(256),lvl int,ParentTable varchar(256));  
  
DECLARE @MAXCOUNT INT, @COUNTS INT , @formatted_Linked_Server_Name varchar(200)
Declare @NAMEOFTBL NVARCHAR(1000), @sqlstmt NVARCHAR (max),@chktable_Name NVARCHAR(1000),@full_table_Name NVARCHAR(1000)
Declare @tablescript VARCHAR(max),@linked_server_name NVARCHAR(100),@DESTINATIONDB NVARCHAR(100),@Count int, @Error_Description varchar(max)
  
DECLARE @EXISTSCOUNT INT=0  
  
SET @Counts = 1  
SELECT @MAXCOUNT = COUNT(*) FROM #TMPPARENT  
  
WHILE (@COUNTS <= @MAXCOUNT)  
BEGIN  
SET @NAMEOFTBL='';  
SELECT @NAMEOFTBL = TABLENAME, @Linked_Server_Name = Linked_Server_Name , @DESTINATIONDB =ARCHIVE_DATABASE_NAME FROM  #TMPPARENT  WHERE ID = @COUNTS  
set @formatted_Linked_Server_Name = (Select case when @linked_server_name IS NOT NULL AND LEN(@linked_server_name)> 1 THEN '['+@linked_server_name +']'+'.' ELSE NULL END)  
TRUNCATE TABLE #tmp  
  
INSERT INTO #tmp   
EXEC dbo.SP_SEARCH_FK @table=@NAMEOFTBL, @debug=0;  

  
DECLARE @MAXID INT, @Counter INT  
  
SET @COUNTER = 1  
SELECT @MAXID = COUNT(*) FROM #tmp  
  
WHILE (@COUNTER <= @MAXID)  
BEGIN  
--    --DO THE PROCESSING HERE   
set @chktable_Name=''  


SELECT @chktable_Name =	PARSENAME(TEMP.tablename,1) , @full_table_Name = TEMP.tablename	FROM 
#tmp AS TEMP WHERE ID = @COUNTER

SET @sqlstmt='SELECT @CNT=COUNT(1) FROM ' + coalesce(@formatted_Linked_Server_Name,'')+@DESTINATIONDB +'.sys.objects WHERE Name = ''' +@chktable_Name +''' AND type in (N''U'')'  




EXECUTE sp_executesql @sqlstmt  ,N'@cnt INT OUTPUT'  ,@cnt = @EXISTSCOUNT OUTPUT  
IF  @EXISTSCOUNT=0   -- If the table does not exists in Archive DB then create it 
BEGIN  
  
SET @tablescript = ''  
EXEC [dbo].[Arc_Generate_Dynamic_Table]  @full_table_Name,@DESTINATIONDB, 1, @tablescript output   


IF @linked_server_name<>''   
BEGIN   
	SET   @tablescript = 'Exec (''' + @tablescript +  CASE when @linked_server_name is null then ''')' else ''') at ' + '['+ @linked_server_name + ']'  end   
END  
ELSE
BEGIN
	SET   @tablescript = 'Exec (''' + @tablescript +''')' 
END
--PRINT  @tablescript
EXEC(@tablescript);    
END
	
	--EXEC dbo.QC_EGMS_SYNC_ARCHIVING_DB_SCHEMA_CHANGES @full_table_Name, @DESTINATIONDB , @linked_server_name
	 


SET @COUNTER = @COUNTER + 1  
END  
  
SET @COUNTS = @COUNTS + 1  

END  

END TRY  
BEGIN CATCH  


	select ERROR_MESSAGE() 



END CATCH  
END  




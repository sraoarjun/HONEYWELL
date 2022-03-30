USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO
/*
Exec dbo.Sp_Arc_Insert_Into_Archive 'dbo','StandingOrdersHistory','Archival_DB','ActualStartTime < DATEADD(Year,-5,GETDATE())','StandingOrder_PK_ID'

Exec dbo.Sp_Arc_Insert_Into_Archive 'dbo','Activities','Archival_DB','StartTime < DATEADD(Year,-5,GETDATE())','Activity_PK_ID'
*/
DROP PROCEDURE dbo.Sp_Arc_Insert_Into_Archive
GO
CREATE PROCEDURE dbo.Sp_Arc_Insert_Into_Archive
(
	@schemaName varchar(100),
	@tableName varchar (100),
	@archival_database varchar(250),
	@filters varchar(4000),
	@pk_column_name varchar(250)
)
AS
BEGIN

-- the following is an example to show what code can be generated to do the table deletionset nocount on;
SET NOCOUNT ON;
if object_id('tempdb..#tmp') is not null
	drop table #tmp;
create table  #tmp  (id int, tablename varchar(256), lvl int, ParentTable varchar(256));

declare @tbl varchar(250) = @schemaName +'.'+ @tableName

insert into #tmp 
exec dbo.sp_Search_Fk @table=@tbl, @debug=0;

--select * from #tmp
declare @where varchar(max) =null -- if @where clause is null or empty, it will delete tables as a whole with the right order
--declare @where varchar(max) ='where Year(CreatedDate) = 2020' -- if @where clause is null or empty, it will delete tables as a whole with the right order
set @where = @filters


declare @curFK cursor, @fk_object_id int;
declare @sqlcmd varchar(max)='', @crlf char(2)=char(0x0d)+char(0x0a);
declare @child varchar(256), @parent varchar(256), @lvl int, @id int;
declare @i int;
declare @t table (tablename varchar(128));
declare @curT cursor;
if isnull(@where, '')= ''
begin
	set @curT = cursor for select tablename, lvl from #tmp order by lvl desc
	open @curT;
	fetch next from @curT into @child, @lvl;
	while @@fetch_status = 0
	begin -- loop @curT
		if not exists (select 1 from @t where tablename=@child)
			insert into @t (tablename) values (@child);
		fetch next from @curT into @child, @lvl;
	end -- loop @curT
	close @curT;
	deallocate @curT;

	select  @sqlcmd = @sqlcmd + 'insert into '+@archival_database+'.'+tablename +  @crlf +
	'select '+tablename+'.* from '+tablename + ' where ' + tablename +'.'+ @pk_column_name + ' in (' + 'select ID from tempdb..Staging_IDs)' +
	@crlf from @t ;
	print @sqlcmd;
end
else
begin 
	declare curT cursor for
	select  lvl, id
	from #tmp
	order by lvl asc;

	open curT;
	fetch next from curT into  @lvl, @id;
	while @@FETCH_STATUS =0
	begin
		set @i=0;
		if @lvl =0
		
		begin -- this is the root level
			select @sqlcmd = 'insert into '+@archival_database+'.'+tablename +  @crlf +
			'select ' + tablename + '.* from ' + tablename from #tmp where id = @id;
		end -- this is the root level
						

		while @i < @lvl
		begin -- while

			select top 1 @child=TableName, @parent=ParentTable from #tmp where id <= @id-@i and lvl <= @lvl-@i order by lvl desc, id desc;
			set @curFK = cursor for
			select object_id from sys.foreign_keys 
			where parent_object_id = object_id(@child)
			and referenced_object_id = object_id(@parent)

			open @curFK;
			fetch next from @curFk into @fk_object_id
			while @@fetch_status =0
			begin -- @curFK

				if @i=0
					set @sqlcmd = 'insert into '+@archival_database+'. '+ @child + @crlf +
					'select '  + @child + '.* from ' + @child + @crlf + 'inner join ' + @parent  ;
				else
					set @sqlcmd = @sqlcmd + @crlf + 'inner join ' + @parent ;

				;with c as 
				(
					select child = object_schema_name(fc.parent_object_id)+'.' + object_name(fc.parent_object_id), child_col=c.name
					, parent = object_schema_name(fc.referenced_object_id)+'.' + object_name(fc.referenced_object_id), parent_col=c2.name
					, rnk = row_number() over (order by (select null))
					from sys.foreign_key_columns fc
					inner join sys.columns c
					on fc.parent_column_id = c.column_id
					and fc.parent_object_id = c.object_id
					inner join sys.columns c2
					on fc.referenced_column_id = c2.column_id
					and fc.referenced_object_id = c2.object_id
					where fc.constraint_object_id=@fk_object_id
				)
					select @sqlcmd =@sqlcmd +  case rnk when 1 then ' on '  else ' and ' end 
					+ @child +'.'+ child_col +'='  +  @parent   +'.' + parent_col
					from c;
					fetch next from @curFK into @fk_object_id;
			end --@curFK
			close @curFK;
			deallocate @curFK;
			set @i = @i +1;
		end --while
		--print @sqlcmd + @crlf + @where + ';';
		--set @sqlcmd = @sqlcmd + @crlf + @where + ';';
		set @sqlcmd = @sqlcmd + @crlf + ' where ' + @tableName +'.'+ @pk_column_name + ' in (' + 'select ID from tempdb..Staging_IDs)' + @crlf 
		print @sqlcmd
		--exec (@sqlcmd)
		print '';
		fetch next from curT into  @lvl, @id;
	end
	close curT;
	deallocate curT;
end
END

/*
The procedure returns the list of the tables ,their corresponding levels and the parent table for each of the table regardless of the nesting levels

Parameters : @table - The name of the parent table
           			
returns : None 
*/

CREATE PROCEDURE dbo.sp_Search_Fk 
  @table varchar(256) -- use two part name convention
, @lvl int=0 -- do not change
, @ParentTable varchar(256)='' -- do not change
, @debug bit = 1
as
begin
	set nocount on;
	declare @dbg bit;
	set @dbg=@debug;
	if object_id('tempdb..#tbl', 'U') is null
		create table  #tbl  (id int identity(1,1), tablename varchar(256), lvl int, ParentTable varchar(256));
	declare @curS cursor;
	if @lvl = 0
		insert into #tbl (tablename, lvl, ParentTable)
		select @table, @lvl, Null;
	else
		insert into #tbl (tablename, lvl, ParentTable)
		select @table, @lvl,@ParentTable;
	if @dbg=1	
		print replicate('----', @lvl) + 'lvl ' + cast(@lvl as varchar(10)) + ' = ' + @table;
	
	--if not exists (select * from sys.foreign_keys where referenced_object_id = object_id(@table))
	--	return;
		
	--else
	--begin -- else
		set @ParentTable = @table;
		set @curS = cursor for
		select tablename=object_schema_name(parent_object_id)+'.'+object_name(parent_object_id)
		from sys.foreign_keys 
		where referenced_object_id = object_id(@table)
		and parent_object_id <> referenced_object_id; -- add this to prevent self-referencing which can create a indefinitive loop;

		open @curS;
		fetch next from @curS into @table;

		while @@fetch_status = 0
		begin --while
			set @lvl = @lvl+1;
			-- recursive call
			exec dbo.SP_SEARCH_FK @table, @lvl, @ParentTable, @dbg;
			set @lvl = @lvl-1;
			fetch next from @curS into @table;
		end --while
		close @curS;
		deallocate @curS;
	--end -- else
	
	if not exists (select 1 from #tbl)
		begin
			insert into #tbl (tablename, lvl, ParentTable)
			values(@table, @lvl, Null)
		end
	if @lvl = 0
		--select distinct * from #tbl;
			select distinct  id , tablename, lvl, ParentTable from #tbl;
		
	return;
end






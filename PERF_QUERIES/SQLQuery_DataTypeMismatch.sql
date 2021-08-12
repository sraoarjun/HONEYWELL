drop table if exists #temp 
go 
select PARSENAME([table],1) as FK_Table,column_name as fk_column_name ,PARSENAME(primary_table,1) as PK_Table, pk_column_name 
into #temp

from
 
		(
				select schema_name(tab.schema_id) + '.' + tab.name as [table],
					col.column_id,
					col.name as column_name,
					case when fk.object_id is not null then '>-' else null end as rel,
					schema_name(pk_tab.schema_id) + '.' + pk_tab.name as primary_table,
					pk_col.name as pk_column_name,
					fk_cols.constraint_column_id as no,
					fk.name as fk_constraint_name
				from sys.tables tab
					inner join sys.columns col 
						on col.object_id = tab.object_id
					left outer join sys.foreign_key_columns fk_cols
						on fk_cols.parent_object_id = tab.object_id
						and fk_cols.parent_column_id = col.column_id
					left outer join sys.foreign_keys fk
						on fk.object_id = fk_cols.constraint_object_id
					left outer join sys.tables pk_tab
						on pk_tab.object_id = fk_cols.referenced_object_id
					left outer join sys.columns pk_col
						on pk_col.column_id = fk_cols.referenced_column_id
						and pk_col.object_id = fk_cols.referenced_object_id
						where  schema_name(pk_tab.schema_id) + '.' + pk_tab.name is not null

			)A
GO

select * from #temp
 
select t.* ,fk.DATA_TYPE as fk_Data_Type ,pk.DATA_TYPE as pk_Data_type from #temp t 

cross apply (select * from INFORMATION_SCHEMA.COLUMNS ic where t.FK_Table = ic.TABLE_NAME
and t.fk_column_name = ic.COLUMN_NAME )fk 

cross apply (select * from INFORMATION_SCHEMA.COLUMNS ic1 where t.PK_Table = ic1.TABLE_NAME 
and t.pk_column_name= ic1.COLUMN_NAME) pk 
 where fk.DATA_TYPE <> pk.DATA_TYPE

--where FK_Table IN('HealthMonSuspensions','ShiftSummaryDisplays')

select * into #tempAssignedNotes
from 
(
	
	select NoteHistory_PK_ID from dbo.NotesHistory nh where exists 
	(select 1 from dbo.TagMonitoringStatusHistories b where nh.NoteHistory_PK_ID = b.Note_PK_ID)
	
	union 
		
	select NoteHistory_PK_ID from dbo.NotesHistory nh where exists 
	(select 1 from dbo.TagMonitoringStatusHistories b where nh.NoteHistory_PK_ID = b.RevokeNote_PK_ID)
	
	union 
	
	select NoteHistory_PK_ID from dbo.NotesHistory nh where exists 
	(select 1 from dbo.ActivityReasonHistory b where nh.NoteHistory_PK_ID = b.Note_PK_ID)

	union 
	
	select NoteHistory_PK_ID from dbo.NotesHistory nh where exists 
	(select 1 from dbo.ActivityRemarksHistory b where nh.NoteHistory_PK_ID = b.NoteHistory_PK_ID)

	union 

	select NoteHistory_PK_ID from dbo.NotesHistory nh where exists 
	(select 1 from dbo.SplitActivityReasonsHistory b where nh.NoteHistory_PK_ID = b.Note_PK_ID)

	union 

	select NoteHistory_PK_ID from dbo.NotesHistory nh where exists 
	(select 1 from dbo.SplitActivityRemarksHistory b where nh.NoteHistory_PK_ID = b.NoteHistory_PK_ID)

)A

-- Get all unassigned history notes
Select nh.NoteHistory_PK_ID into #tempNotesToBeDeleted from NotesHistory nh where not exists 
(select  1 from #tempAssignedNotes b where nh.NoteHistory_PK_ID = b.NoteHistory_PK_ID)

declare @batch_size int = (select cast(setting_value as int) from dbo.Purge_Settings_Config where setting_name = 'Purge_Batch_Size')

DECLARE @deleted_rows INT = 1 
WHILE (@deleted_rows > 0 )
BEGIN
	begin try
	begin tran
		DELETE top (@batch_size) n
		FROM dbo.NotesHistory n join #tempNotesToBeDeleted rn on n.NoteHistory_PK_ID = rn.NoteHistory_PK_ID
		SET @deleted_rows = @@ROWCOUNT ;
	commit tran
	end try 
	begin catch 
	rollback tran
		 print 'error occured - ' + error_message()
	end catch 
	PRINT 'rows deleted -' + cast(@deleted_rows AS VARCHAR(100))
END 
GO

DROP TABLE #tempAssignedNotes
DROP TABLE #tempNotesToBeDeleted
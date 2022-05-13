USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO

-- NO data present for InstructionAttachmentsHistory

--Purge config  id - 10 ENDS


/*
Very less data present for 
	1)	MeetingNotesAssociationsHistory_PK_ID 
	2)	MeetingsHistory
	3)	MeetingAttributesHistory
	4)	MeetingTasksAssociationsHistory


Need to verify , after adding suggested index , the IO is going higher 
--DROP  INDEX  [IX_TaskActionHistoriesHistory_Task_Task_PK_Id_Purge] ON [dbo].[TaskActionHistoriesHistory]
GO
CREATE NONCLUSTERED INDEX [IX_TaskActionHistoriesHistory_Task_Task_PK_Id_Purge]
ON [dbo].[TaskActionHistoriesHistory] ([Task_Task_PK_Id])


--39
--TableSnippetDataHistories (There are no records)
--39

--40
--This Criteria is doing lot of logical reads , however no useful indexes can be added
--40

*/



 


--DROP  INDEX [IX_StandingOrdersHistory_ActualEndTime_Purge] on [dbo].[StandingOrdersHistory]
GO

CREATE NONCLUSTERED INDEX [IX_StandingOrdersHistory_ActualEndTime_Purge]
ON [dbo].[StandingOrdersHistory] ([ActualEndTime])
INCLUDE ([StandingOrder_PK_ID])
GO




--DROP  INDEX  [IX_StandingOrdersHistory_StandingOrder_PK_ID_ActualEndTime_Purge] ON [dbo].[StandingOrdersHistory]
GO
CREATE NONCLUSTERED INDEX [IX_StandingOrdersHistory_StandingOrder_PK_ID_ActualEndTime_Purge]
ON [dbo].[StandingOrdersHistory] ([StandingOrder_PK_ID],[ActualEndTime])
GO



--DROP  INDEX [IX_StandingOrderCommentsHistory_FK_StandingOrder_StandingOrder_PK_ID_Purge] on [dbo].[StandingOrderCommentsHistory]
GO
CREATE NONCLUSTERED INDEX [IX_StandingOrderCommentsHistory_FK_StandingOrder_StandingOrder_PK_ID_Purge]
ON [dbo].[StandingOrderCommentsHistory] ([StandingOrder_StandingOrder_PK_ID])
GO

--DROP  INDEX  [IX_StandingOrdersActionHistoryHistory_FK_StandingOrder_StandingOrder_PK_ID_Purge]
--ON [dbo].[StandingOrdersActionHistoryHistory] 
--GO 
CREATE NONCLUSTERED INDEX [IX_StandingOrdersActionHistoryHistory_FK_StandingOrder_StandingOrder_PK_ID_Purge]
ON [dbo].[StandingOrdersActionHistoryHistory] ([StandingOrder_StandingOrder_PK_ID])
INCLUDE ([StandingOrdersActionHistoryHistory_PK_ID])
GO


--DROP  INDEX  [IX_AssetCommentHistory_EndTime_Purge] ON [dbo].[AssetCommentHistory]
GO
CREATE NONCLUSTERED INDEX [IX_AssetCommentHistory_EndTime_Purge] ON [dbo].[AssetCommentHistory]
(
	[Shift_EndTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

--DROP  INDEX  [IX_TagMonitoringStatusHistories_DownTimeEndDownTimeEndDownTimeEnd_Purge] ON [dbo].[TagMonitoringStatusHistories]
GO
CREATE NONCLUSTERED INDEX [IX_TagMonitoringStatusHistories_DownTimeEndDownTimeEndDownTimeEnd_Purge]
ON [dbo].[TagMonitoringStatusHistories] ([DownTimeEnd])
INCLUDE ([TagMonitoringStatusHistory_PK_ID])


--DROP  INDEX  [IX_InstructionsHistory_ActualEndTime_Purge] on [dbo].[InstructionsHistory]
GO
CREATE NONCLUSTERED INDEX [IX_InstructionsHistory_ActualEndTime_Purge]
ON [dbo].[InstructionsHistory] ([ActualEndTime])
INCLUDE ([InstructionId],[State_StateId])

--DROP  INDEX  [IX_LimitInstructionDetailsHistory_Instruction_InstructionId_Purge] ON [dbo].[LimitInstructionDetailsHistory]
GO
CREATE NONCLUSTERED INDEX [IX_LimitInstructionDetailsHistory_Instruction_InstructionId_Purge]
ON [dbo].[LimitInstructionDetailsHistory] ([Instruction_InstructionId])
INCLUDE ([LimitInstructionDetailsHistory_PK_ID])
GO

--DROP  INDEX  [IX_InstructionsActionHistoryHistory_Instructions_InstructionID_Purge] ON [dbo].[InstructionsActionHistoryHistory]
GO
CREATE NONCLUSTERED INDEX [IX_InstructionsActionHistoryHistory_Instructions_InstructionID_Purge]
ON [dbo].[InstructionsActionHistoryHistory] ([Instructions_InstructionID])
GO

--DROP  INDEX  [IX_InstructionCommentsHistory_Instruction_InstructionId_Purge] ON [dbo].[InstructionCommentsHistory]
GO

CREATE NONCLUSTERED INDEX [IX_InstructionCommentsHistory_Instruction_InstructionId_Purge]
ON [dbo].[InstructionCommentsHistory] ([Instruction_InstructionId])
GO

--DROP  INDEX [IX_TaskNotesHistory_TaskNote_PK_ID_Purge] on [dbo].[TaskNotesHistory]
GO
CREATE NONCLUSTERED INDEX [IX_TaskNotesHistory_TaskNote_PK_ID_Purge]
ON [dbo].[TaskNotesHistory] ([TaskNote_PK_ID])
GO

--DROP  INDEX [IX_TasksHistory_ActualEndTime_Purge] on [dbo].[TasksHistory]
GO
CREATE NONCLUSTERED INDEX [IX_TasksHistory_ActualEndTime_Purge]
ON [dbo].[TasksHistory] ([ActualEndTime])
INCLUDE ([Task_PK_Id])
GO


--DROP  INDEX   [IX_TaskAssigneesHistory_Task_Task_PK_Id_Purge] on [dbo].[TaskAssigneesHistory]
GO
CREATE NONCLUSTERED INDEX [IX_TaskAssigneesHistory_Task_Task_PK_Id_Purge]
ON [dbo].[TaskAssigneesHistory] ([Task_Task_PK_Id])
GO


--DROP  INDEX  [IX_TaskNoteAssociationsHistory_Task_Task_PK_Id_Purge] ON [dbo].[TaskNoteAssociationsHistory]
GO
CREATE NONCLUSTERED INDEX [IX_TaskNoteAssociationsHistory_Task_Task_PK_Id_Purge]
ON [dbo].[TaskNoteAssociationsHistory] ([Task_Task_PK_Id])
GO

--DROP  INDEX  [IX_TasksHistory_Task_PK_Id_Purge] ON [dbo].[TasksHistory]
GO
CREATE NONCLUSTERED INDEX [IX_TasksHistory_Task_PK_Id_Purge]
ON [dbo].[TasksHistory] ([Task_PK_Id])
GO

--DROP  INDEX  [IX_ShiftSummaryDisplayDataHistory_Shift_EndTime_Purge] ON [dbo].[IX_ShiftSummaryDisplayDataHistory_Shift_EndTime_Purge]
GO
CREATE NONCLUSTERED INDEX [IX_ShiftSummaryDisplayDataHistory_Shift_EndTime_Purge]
ON [dbo].[ShiftSummaryDisplayDataHistory] ([Shift_EndTime])
GO

--DROP  INDEX  [IX_TasksHistory_SourceType_ActualEndTime_Purge] on [dbo].[TasksHistory]
GO
CREATE NONCLUSTERED INDEX [IX_TasksHistory_SourceType_ActualEndTime_Purge]
ON [dbo].[TasksHistory] ([SourceType],[ActualEndTime])
INCLUDE ([Task_PK_Id])
GO

--DROP  INDEX  [IX_TaskActionHistoriesHistory_Task_Task_PK_Id_Purge] ON [dbo].[TaskActionHistoriesHistory]
GO
CREATE NONCLUSTERED INDEX [IX_TaskActionHistoriesHistory_Task_Task_PK_Id_Purge]
ON [dbo].[TaskActionHistoriesHistory] ([Task_Task_PK_Id])
GO

--DROP  INDEX  [IX_ShiftSummaryCommentHistory_Shift_EndTime_Purge] ON [dbo].ShiftSummaryCommentHistory
GO
CREATE NONCLUSTERED INDEX [IX_ShiftSummaryCommentHistory_Shift_EndTime_Purge]
ON [dbo].[ShiftSummaryCommentHistory] ([Shift_EndTime])
GO


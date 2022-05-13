
 
CREATE NONCLUSTERED INDEX [IX_InstructionCommentsHistory_Instruction_InstructionId_Purge] ON [dbo].[InstructionCommentsHistory](Instruction_InstructionId ASC) 
 
CREATE NONCLUSTERED INDEX [IX_InstructionsActionHistoryHistory_Instructions_InstructionID_Purge] ON [dbo].[InstructionsActionHistoryHistory](Instructions_InstructionID ASC) 
 
CREATE NONCLUSTERED INDEX [IX_InstructionsHistory_ActualEndTime_Purge] ON [dbo].[InstructionsHistory](ActualEndTime ASC) 
 
CREATE NONCLUSTERED INDEX [IX_LimitInstructionDetailsHistory_Instruction_InstructionId_Purge] ON [dbo].[LimitInstructionDetailsHistory](Instruction_InstructionId ASC) 
 
CREATE NONCLUSTERED INDEX [IX_ShiftSummaryCommentHistory_Shift_EndTime_Purge] ON [dbo].[ShiftSummaryCommentHistory](Shift_EndTime ASC) 
 
CREATE NONCLUSTERED INDEX [IX_ShiftSummaryDisplayDataHistory_Shift_EndTime_Purge] ON [dbo].[ShiftSummaryDisplayDataHistory](Shift_EndTime ASC) 
 
CREATE NONCLUSTERED INDEX [IX_StandingOrderCommentsHistory_FK_StandingOrder_StandingOrder_PK_ID_Purge] ON [dbo].[StandingOrderCommentsHistory](StandingOrder_StandingOrder_PK_ID ASC) 
 
CREATE NONCLUSTERED INDEX [IX_StandingOrdersActionHistoryHistory_FK_StandingOrder_StandingOrder_PK_ID_Purge] ON [dbo].[StandingOrdersActionHistoryHistory](StandingOrder_StandingOrder_PK_ID ASC) 
 
CREATE NONCLUSTERED INDEX [IX_StandingOrdersHistory_ActualEndTime_Purge] ON [dbo].[StandingOrdersHistory](ActualEndTime ASC) 
 
CREATE NONCLUSTERED INDEX [IX_StandingOrdersHistory_StandingOrder_PK_ID_ActualEndTime_Purge] ON [dbo].[StandingOrdersHistory](StandingOrder_PK_ID ASC, ActualEndTime ASC) 
 
CREATE NONCLUSTERED INDEX [IX_TagMonitoringStatusHistories_DownTimeEndDownTimeEndDownTimeEnd_Purge] ON [dbo].[TagMonitoringStatusHistories](DownTimeEnd ASC) 
 
CREATE NONCLUSTERED INDEX [IX_TaskActionHistoriesHistory_Task_Task_PK_Id_Purge] ON [dbo].[TaskActionHistoriesHistory](Task_Task_PK_Id ASC) 
 
CREATE NONCLUSTERED INDEX [IX_TaskAssigneesHistory_Task_Task_PK_Id_Purge] ON [dbo].[TaskAssigneesHistory](Task_Task_PK_Id ASC) 
 
CREATE NONCLUSTERED INDEX [IX_TaskNoteAssociationsHistory_Task_Task_PK_Id_Purge] ON [dbo].[TaskNoteAssociationsHistory](Task_Task_PK_Id ASC) 
 
CREATE NONCLUSTERED INDEX [IX_TaskNotesHistory_TaskNote_PK_ID_Purge] ON [dbo].[TaskNotesHistory](TaskNote_PK_ID ASC) 
 
CREATE NONCLUSTERED INDEX [IX_TasksHistory_ActualEndTime_Purge] ON [dbo].[TasksHistory](ActualEndTime ASC) 
 
CREATE NONCLUSTERED INDEX [IX_TasksHistory_SourceType_ActualEndTime_Purge] ON [dbo].[TasksHistory](SourceType ASC, ActualEndTime ASC) 
 
CREATE NONCLUSTERED INDEX [IX_TasksHistory_Task_PK_Id_Purge] ON [dbo].[TasksHistory](Task_PK_Id ASC) 
 


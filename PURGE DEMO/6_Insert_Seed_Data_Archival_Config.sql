USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO
SET IDENTITY_INSERT [dbo].[Archival_Config] ON 
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (1, N'Purging the ActivityHistory table', N'dbo', N'ActivityHistory', N' where StartTime <= {Date_Parameter}', N'ActivityHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (2, N'Purging the AssetCommentHistory table', N'dbo', N'AssetCommentHistory', N' where Shift_EndTime <= {Date_Parameter}', N'CommentHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (3, N'Purging the TagMonitoringStatusHistories table', N'dbo', N'TagMonitoringStatusHistories', N' where TagMonitoringStatusHistories.DownTimeEnd <= {Date_Parameter}', N'TagMonitoringHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (4, N'Purging the CrossShiftReportGeneratedLinksHistory table', N'dbo', N'CrossShiftReportGeneratedLinksHistory', N' where CrossShiftReportGeneratedLinksHistory.GeneratedDateTime <= {Date_Parameter}', N'CrossShiftReportGeneratedLinksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (5, N'Purging the Instructions_LimiInstructionHistory table', N'dbo', N'Instructions_LimiInstructionHistory', N'INNER JOIN dbo.InstructionsHistory  ON Instructions_LimiInstructionHistory.InstructionId=InstructionsHistory.InstructionId 
INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId inner join ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter} AND States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (6, N'Purging the Instructions_TextInstructionHistory table', N'dbo', N'Instructions_TextInstructionHistory', N'INNER JOIN dbo.InstructionsHistory  ON Instructions_TextInstructionHistory.InstructionId = InstructionsHistory.InstructionId INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter} AND States.Name=''Completed''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (7, N'Purging the LimitInstructionDetailsHistory table', N'dbo', N'LimitInstructionDetailsHistory', N'INNER JOIN dbo.InstructionsHistory  ON LimitInstructionDetailsHistory.Instruction_InstructionId=InstructionsHistory.InstructionId 
	INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId 
	INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId  WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter} AND States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (8, N'Purging the InstructionsActionHistoryHistory table', N'dbo', N'InstructionsActionHistoryHistory', N'INNER JOIN dbo.InstructionsHistory  ON InstructionsActionHistoryHistory.Instructions_InstructionID=InstructionsHistory.InstructionId 
	INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId 	INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId 	WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter} AND States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (9, N'Purging the InstructionCommentsHistory table', N'dbo', N'InstructionCommentsHistory', N'INNER JOIN DBO.InstructionsHistory  ON InstructionCommentsHistory.Instruction_InstructionId=InstructionsHistory.InstructionId 
	INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId 
	INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId 
	WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter} AND  States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (10, N'Purging the InstructionAttachmentsHistory table', N'dbo', N'InstructionAttachmentsHistory', N'INNER JOIN dbo.InstructionsHistory  ON InstructionAttachmentsHistory.Instruction_InstructionId=InstructionsHistory.InstructionId INNER JOIN States  
ON InstructionsHistory.State_StateId=States.StateId INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId 
WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter}  AND States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (11, N'Purging the InstructionAssigneesHistory table', N'dbo', N'InstructionAssigneesHistory', N'INNER JOIN dbo.InstructionsHistory  ON InstructionAssigneesHistory.Instruction_InstructionId=InstructionsHistory.InstructionId INNER JOIN States  
ON InstructionsHistory.State_StateId=States.StateId INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId 
WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter}  AND States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (12, N'Purging the InstructionsHistory table', N'dbo', N'InstructionsHistory', N'INNER JOIN States  ON InstructionsHistory.State_StateId=States.StateId 
	INNER JOIN ProcessTypes  on ProcessTypes.ProcessTypeId =States.ProcessType_ProcessTypeId 
	WHERE InstructionsHistory.ActualEndTime <= {Date_Parameter}  AND  States.Name=''Completed'' and ProcessTypes.ProcessTypeName =''Instruction''', N'InstructionsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (13, N'Purging the MeetingNotesAssociationsHistory table', N'dbo', N'MeetingNotesAssociationsHistory', N'INNER JOIN dbo.MeetingsHistory on dbo.MeetingNotesAssociationsHistory.Meeting_Meeting_PK_ID = dbo.MeetingsHistory.Meeting_PK_ID
WHERE dbo.MeetingsHistory.StartTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (14, N'Purging the TaskNotesHistory table', N'dbo', N'TaskNotesHistory', N'INNER JOIN dbo.MeetingNotesAssociationsHistory ON dbo.MeetingNotesAssociationsHistory.TaskNoteTaskNote_PK_ID = dbo.TaskNotesHistory.TaskNote_PK_ID
INNER JOIN dbo.MeetingsHistory ON dbo.MeetingNotesAssociationsHistory.Meeting_Meeting_PK_ID = dbo.MeetingsHistory.Meeting_PK_ID
WHERE dbo.MeetingsHistory.StartTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (15, N'Purging the MeetingParticipantsHistory table', N'dbo', N'MeetingParticipantsHistory', N'INNER JOIN dbo.MeetingsHistory ON dbo.MeetingParticipantsHistory.Meeting_Meeting_PK_ID = dbo.MeetingsHistory.Meeting_PK_ID 
	WHERE dbo.MeetingsHistory.StartTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (16, N'Purging the MeetingAttributesHistory table', N'dbo', N'MeetingAttributesHistory', N'INNER JOIN dbo.MeetingsHistory ON dbo.MeetingAttributesHistory.Meeting_Meeting_PK_ID = dbo.MeetingsHistory.Meeting_PK_ID
WHERE dbo.MeetingsHistory.StartTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (17, N'Purging the MeetingTasksAssociationsHistory table', N'dbo', N'MeetingTasksAssociationsHistory', N'INNER JOIN dbo.MeetingsHistory ON dbo.MeetingTasksAssociationsHistory .MeetingMeeting_PK_ID = dbo.MeetingsHistory.Meeting_PK_ID
WHERE dbo.MeetingsHistory.StartTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (18, N'Purging the MeetingsHistory table', N'dbo', N'MeetingsHistory', N' WHERE StartTime  <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (19, N'Purging the TaskAssigneesHistory table', N'dbo', N'TaskAssigneesHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskAssigneesHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
	WHERE dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (20, N'Purging the TaskNoteAssociationsHistory table', N'dbo', N'TaskNoteAssociationsHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskNoteAssociationsHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
WHERE dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (21, N'Purging the TaskActionHistoriesHistory table', N'dbo', N'TaskActionHistoriesHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskActionHistoriesHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
WHERE dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (22, N'Purging the TaskNotesHistory table', N'dbo', N'TaskNotesHistory', N'INNER JOIN dbo.TaskNoteAssociationsHistory ON dbo.TaskNoteAssociationsHistory.TaskNote_TaskNotes_PK_ID = dbo.TaskNotesHistory.TaskNote_PK_ID
INNER JOIN dbo.TasksHistory ON dbo.TaskNoteAssociationsHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
WHERE dbo.TasksHistory.ActualEndTime <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (23, N'Purging the TasksHistory table', N'dbo', N'TasksHistory', N' WHERE  ActualEndTime  <= {Date_Parameter}', N'MeetingsHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (24, N'Purging the ShiftSummaryDisplayDataHistory table', N'dbo', N'ShiftSummaryDisplayDataHistory', N' where Shift_EndTime <= {Date_Parameter}', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (25, N'Purging the StandingOrderAssigneesHistory table', N'dbo', N'StandingOrderAssigneesHistory', N'INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrderAssigneesHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID  
			WHERE dbo.StandingOrdersHistory.ActualEndTime  <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (26, N'Purging the StandingOrderAttachmentsHistory table', N'dbo', N'StandingOrderAttachmentsHistory', N'INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrderAttachmentsHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID WHERE dbo.StandingOrdersHistory.ActualEndTime  <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (27, N'Purging the StandingOrderCommentsHistory table', N'dbo', N'StandingOrderCommentsHistory', N'INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrderCommentsHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID WHERE dbo.StandingOrdersHistory.ActualEndTime  <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (28, N'Purging the StandingOrderLinksHistory table', N'dbo', N'StandingOrderLinksHistory', N'INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrderLinksHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID       
WHERE dbo.StandingOrdersHistory.ActualEndTime  <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (29, N'Purging the StandingOrdersActionHistoryHistory table', N'dbo', N'StandingOrdersActionHistoryHistory', N'INNER JOIN dbo.StandingOrdersHistory ON dbo.StandingOrdersActionHistoryHistory.StandingOrder_StandingOrder_PK_ID=dbo.StandingOrdersHistory.StandingOrder_PK_ID  
WHERE dbo.StandingOrdersHistory.ActualEndTime  <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (30, N'Purging the StandingOrdersHistory table', N'dbo', N'StandingOrdersHistory', N' WHERE ActualEndTime <= {Date_Parameter}', N'StandingOrdersHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (31, N'Purging the TaskLinksHistory table', N'dbo', N'TaskLinksHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskLinksHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
	WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (32, N'Purging the TaskAssigneesHistory table', N'dbo', N'TaskAssigneesHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskAssigneesHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
	WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (33, N'Purging the TaskActionHistoriesHistory table', N'dbo', N'TaskActionHistoriesHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskActionHistoriesHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (34, N'Purging the TaskAttachmentsHistory table', N'dbo', N'TaskAttachmentsHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskAttachmentsHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id
	WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND  dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (35, N'Purging the TaskNoteAssociationsHistory table', N'dbo', N'TaskNoteAssociationsHistory', N'INNER JOIN dbo.TasksHistory ON dbo.TaskNoteAssociationsHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND  dbo.TasksHistory.ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (36, N'Purging the TaskNotesHistory table', N'dbo', N'TaskNotesHistory', N'INNER JOIN dbo.TaskNoteAssociationsHistory ON dbo.TaskNoteAssociationsHistory.TaskNote_TaskNotes_PK_ID = dbo.TaskNotesHistory.TaskNote_PK_ID INNER JOIN dbo.TasksHistory ON dbo.TaskNoteAssociationsHistory.Task_Task_PK_Id = dbo.TasksHistory.Task_PK_Id WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND dbo.TasksHistory.ActualEndTime <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (37, N'Purging the TasksHistory table', N'dbo', N'TasksHistory', N' WHERE dbo.TasksHistory.SourceType != ''Meetings'' AND ActualEndTime  <= {Date_Parameter}', N'TasksHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (38, N'Purging the ShiftSummaryCommentHistory table', N'dbo', N'ShiftSummaryCommentHistory', N' WHERE Shift_EndTime <= {Date_Parameter}', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (39, N'Purging the TableSnippetDataHistories table', N'dbo', N'TableSnippetDataHistories', N'INNER JOIN dbo.ShiftSummaryDisplayHistory ON  dbo.ShiftSummaryDisplayHistory.ShiftSummaryDisplayHistory_PK_ID =dbo.TableSnippetDataHistories.ShiftSummaryDisplayHistory_PK_ID
INNER JOIN dbo.ShiftSummaryHistory ON dbo.ShiftSummaryDisplayHistory.ShiftSummary_PK_ID = dbo.ShiftSummaryHistory.ShiftSummaryHistory_PK_ID
WHERE dbo.ShiftSummaryHistory.Shift_EndTime <= {Date_Parameter}', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (40, N'Purging the ShiftSummaryDisplayTagGroupDataHistory table', N'dbo', N'ShiftSummaryDisplayTagGroupDataHistory', N'INNER JOIN dbo.ShiftSummaryDisplayHistory ON  dbo.ShiftSummaryDisplayTagGroupDataHistory.ShiftSummaryDisplayHistory_PK_ID = dbo.ShiftSummaryDisplayHistory.ShiftSummaryDisplayHistory_PK_ID
INNER JOIN dbo.ShiftSummaryHistory ON dbo.ShiftSummaryDisplayHistory.ShiftSummary_PK_ID = dbo.ShiftSummaryHistory.ShiftSummaryHistory_PK_ID
WHERE dbo.ShiftSummaryHistory.Shift_EndTime <= {Date_Parameter}', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (41, N'Purging the ShiftSummaryDisplayHistory table', N'dbo', N'ShiftSummaryDisplayHistory', N'INNER JOIN dbo.ShiftSummaryHistory on dbo.ShiftSummaryDisplayHistory.ShiftSummary_PK_ID =dbo.ShiftSummaryHistory.ShiftSummaryHistory_PK_ID WHERE dbo.ShiftSummaryHistory.Shift_EndTime <= {Date_Parameter}
', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [filters], [lookupName], [purge_status], [db_datetime_last_updated]) VALUES (42, N'Purging the ShiftSummaryHistory table', N'dbo', N'ShiftSummaryHistory', N' where Shift_EndTime <= {Date_Parameter}', N'ShiftSummaryHistory_Data_Retention_Days', 1, CAST(N'2022-04-21T19:16:53.093' AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Archival_Config] OFF
GO

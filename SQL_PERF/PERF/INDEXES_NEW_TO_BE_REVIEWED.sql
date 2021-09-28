/*
	Indexes that need to be dropped 
*/

IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_FK_AssetInstructionTemplateTemplateID' AND object_id = OBJECT_ID('Instructions'))
    BEGIN
        DROP INDEX [IX_FK_AssetInstructionTemplateTemplateID] ON [dbo].[Instructions]
    END
GO


--CREATE NONCLUSTERED INDEX [IX_FK_AssetInstructionTemplateTemplateID] ON [dbo].[Instructions]
--(
--	[Product_ProductId] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--GO




IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_AssetCommentHistory_StartTime_EndTime' AND object_id = OBJECT_ID('AssetCommentHistory'))
    BEGIN
        DROP INDEX [IX_AssetCommentHistory_StartTime_EndTime] ON [dbo].[AssetCommentHistory]
    END
GO


--CREATE NONCLUSTERED INDEX [IX_AssetCommentHistory_StartTime_EndTime] ON [dbo].[AssetCommentHistory]
--(
--	[Shift_StartTime] ASC,
--	[Shift_EndTime] ASC
--)
--INCLUDE ([LinkId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--GO





-------------------------------------------------------------------------------------------
drop index [TagMonitoring_PK_ID_EndTime] on [dbo].[TargetProcessingHistory]
drop index [TagMonitoring_PK_ID_EndTime_StartTime] on [dbo].[TargetProcessingHistory]
drop index [TagMonitoring_PK_ID_EndTime_Includes] on [dbo].[TargetProcessingHistory]


CREATE INDEX [TagMonitoring_PK_ID_EndTime_Includes] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TargetProcessingHistory] ([TagMonitoring_PK_ID], [EndTime])  INCLUDE ([StartTime])
CREATE INDEX [TagMonitoring_PK_ID_EndTime] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TargetProcessingHistory] ([TagMonitoring_PK_ID], [EndTime]) ;
CREATE INDEX [TagMonitoring_PK_ID_EndTime_StartTime] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TargetProcessingHistory] ([TagMonitoring_PK_ID], [EndTime], [StartTime]);



[StandingOrder_StandingOrder_PK_ID_CreatedTime]
[Note_PK_ID]
[State_StateId_Includes]
[IsSplit_Includes]
[StandingOrder_StandingOrder_PK_ID_ActionTime_Includes]
[StandingOrder_StandingOrder_PK_ID_Includes]
[StandingOrder_StandingOrder_PK_ID_Includes]
[EndTime_Includes]
[EndTime_Includes]


CREATE INDEX [StandingOrder_StandingOrder_PK_ID_CreatedTime] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[StandingOrderCommentsHistory] ([StandingOrder_StandingOrder_PK_ID], [CreatedTime])  

CREATE INDEX [Note_PK_ID] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitoringStatusHistories] ([Note_PK_ID])

CREATE INDEX [State_StateId_Includes] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Tasks] ([State_StateId])  INCLUDE ([Task_PK_Id], [StartTime], [ModifiedEndTime], [Asset_Asset_PK_ID]) 

CREATE INDEX [IsSplit_Includes] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Activities] ([IsSplit])  INCLUDE ([StartTime], [Activity_PK_ID], [TagMonitoring_PK_ID], [SplitShiftName], [ExpectedSplitShiftEndTime]) 


CREATE INDEX [StandingOrder_StandingOrder_PK_ID_ActionTime_Includes] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[StandingOrdersActionHistory] ([StandingOrder_StandingOrder_PK_ID], [ActionTime])  INCLUDE ([ActionType_ActionTypeID]) 

CREATE INDEX [StandingOrder_StandingOrder_PK_ID_Includes] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[StandingOrdersActionHistory] ([StandingOrder_StandingOrder_PK_ID])  INCLUDE ([ActionType_ActionTypeID], [ActionTime]) 

CREATE INDEX [StandingOrder_StandingOrder_PK_ID_Includes] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[StandingOrdersActionHistory] ([StandingOrder_StandingOrder_PK_ID])  INCLUDE ([ActionType_ActionTypeID]) 


CREATE INDEX [EndTime_Includes] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[SplitActivities] ([EndTime])  INCLUDE ([SplitActivity_PK_ID], [Activity_PK_ID], [TagMonitoring_PK_ID])


CREATE INDEX [EndTime_Includes] ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Activities] ([EndTime])  INCLUDE ([Activity_PK_ID], [TagMonitoring_PK_ID])



-------------------------------------------------------------------------------------------------

IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_DeviationSamples_FK_Activity_PK_ID' AND object_id = OBJECT_ID('DeviationSamples'))
    BEGIN
        DROP INDEX [IX_DeviationSamples_FK_Activity_PK_ID] ON [dbo].[DeviationSamples]
    END
GO

CREATE NONCLUSTERED INDEX [IX_DeviationSamples_FK_Activity_PK_ID]
ON [dbo].[DeviationSamples] ([Activity_PK_ID])
GO



IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_test' AND object_id = OBJECT_ID('AssetCommentHistory'))
    BEGIN
        DROP INDEX [IX_test] ON [dbo].[AssetCommentHistory]
    END
GO

CREATE NONCLUSTERED INDEX [IX_test] ON [dbo].[AssetCommentHistory]
(
	[LinkId] ASC
)
INCLUDE ([AssetCommentHistory_PK_ID],
	[Asset_PK_ID],
	[CommentType_PK_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



---- Already Dropped in Perf Machine 
DROP INDEX [IX_ActivityReasonIndex1] ON [dbo].[ActivityReasons]
GO

/****** Object:  Index [IX_ActivityReasonIndex1]    Script Date: 9/7/2021 10:44:38 AM ******/
CREATE NONCLUSTERED INDEX [IX_ActivityReasonIndex1] ON [dbo].[ActivityReasons]
(
	[Reason] ASC,
	[ReasonGroup] ASC,
	[Asset] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_TargetProcessingHistory_FK_TagMonitoring_PK_ID_StartTime' AND object_id = OBJECT_ID('TargetProcessingHistory'))
    BEGIN
        DROP INDEX [IX_TargetProcessingHistory_FK_TagMonitoring_PK_ID_StartTime] ON [dbo].[TargetProcessingHistory]
    END
GO

CREATE NONCLUSTERED INDEX [IX_TargetProcessingHistory_FK_TagMonitoring_PK_ID_StartTime]
ON [dbo].[TargetProcessingHistory] ([TagMonitoring_PK_ID],[StartTime])

GO



IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_StandingOrdersActionHistory_FK_StandingOrderComment_StandingOrderComment_PK_ID' AND object_id = OBJECT_ID('StandingOrdersActionHistory'))
    BEGIN
        DROP INDEX [IX_StandingOrdersActionHistory_FK_StandingOrderComment_StandingOrderComment_PK_ID] ON [dbo].[StandingOrdersActionHistory]
    END
GO
CREATE NONCLUSTERED INDEX [IX_StandingOrdersActionHistory_FK_StandingOrderComment_StandingOrderComment_PK_ID]
ON [dbo].[StandingOrdersActionHistory] ([StandingOrderComment_StandingOrderComment_PK_ID])

GO


IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_StandingOrderHistory_ActualStartTime_ActualEndTime' AND object_id = OBJECT_ID('StandingOrdersHistory'))
    BEGIN
        DROP INDEX [IX_StandingOrderHistory_ActualStartTime_ActualEndTime] ON [dbo].[StandingOrdersHistory]
    END
GO


CREATE NONCLUSTERED INDEX [IX_StandingOrderHistory_ActualStartTime_ActualEndTime] ON [dbo].[StandingOrdersHistory]
(
	[ActualStartTime] ASC,
	[ActualEndTime] ASC
)
GO

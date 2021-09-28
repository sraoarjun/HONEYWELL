IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_ActivityIndex1' AND object_id = OBJECT_ID('Activities'))
    BEGIN
        DROP INDEX [IX_ActivityIndex1] ON [dbo].[Activities]
    END
GO


IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_FK_AssetInstructionTemplateTemplateID' AND object_id = OBJECT_ID('Instructions'))
    BEGIN
        DROP INDEX [IX_FK_AssetInstructionTemplateTemplateID] ON [dbo].[Instructions]
    END
GO



IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_AssetCommentHistory_StartTime_EndTime' AND object_id = OBJECT_ID('AssetCommentHistory'))
    BEGIN
        DROP INDEX [IX_AssetCommentHistory_StartTime_EndTime] ON [dbo].[AssetCommentHistory]
    END
GO



IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_DeviationSamples_FK_Activity_PK_ID' AND object_id = OBJECT_ID('DeviationSamples'))
    BEGIN
        DROP INDEX [IX_DeviationSamples_FK_Activity_PK_ID] ON [dbo].[DeviationSamples]
    END
GO

CREATE NONCLUSTERED INDEX [IX_DeviationSamples_FK_Activity_PK_ID]
ON [dbo].[DeviationSamples] ([Activity_PK_ID])
GO



IF  EXISTS(SELECT * FROM sys.indexes WHERE name = 'IX_Activities_FK_TagMonitoring_PK_ID' AND object_id = OBJECT_ID('Activities'))
    BEGIN
        DROP INDEX [IX_Activities_FK_TagMonitoring_PK_ID] ON [dbo].[Activities]
    END
GO

CREATE NONCLUSTERED INDEX [IX_Activities_FK_TagMonitoring_PK_ID] ON [dbo].[Activities]
(
	[TagMonitoring_PK_ID] ASC
)
GO

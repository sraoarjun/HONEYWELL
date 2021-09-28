DROP INDEX IF EXISTS [IX_CommentCategoryHistory_FK_AssetCommentHistory_PK_ID] on dbo.CommentCategoryHistory
GO
-------------------------------------------------------------------------------------------------------------------------------
DROP INDEX IF EXISTS [IX_AssetCommentHistory_StartTime_EndTime] ON [dbo].[AssetCommentHistory]
GO

CREATE NONCLUSTERED INDEX [IX_AssetCommentHistory_StartTime_EndTime] ON [dbo].[AssetCommentHistory]
(
	[Shift_StartTime] ASC,
	[Shift_EndTime] ASC
)
INCLUDE ([LinkId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-------------------------------------------------------------------------------------------------------------------------------



DROP INDEX IF EXISTS [IX_AssetCommentHistory_LinkID] ON [dbo].[AssetCommentHistory]
GO

CREATE NONCLUSTERED INDEX [IX_AssetCommentHistory_LinkID] ON [dbo].[AssetCommentHistory]
(	
	[LinkId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-------------------------------------------------------------------------------------------------------------------------------
DROP INDEX IF EXISTS [IX_CommentIndexHist] ON [dbo].[AssetCommentHistory]

CREATE NONCLUSTERED INDEX [IX_CommentIndexHist] ON [dbo].[AssetCommentHistory]
(
	[Shift_StartTime] ASC,
	[Shift_EndTime] ASC
)
INCLUDE ([LinkId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


---------

DROP INDEX [IX_AssetCommentHistory_Response_LinkID] ON [dbo].[AssetCommentHistory]
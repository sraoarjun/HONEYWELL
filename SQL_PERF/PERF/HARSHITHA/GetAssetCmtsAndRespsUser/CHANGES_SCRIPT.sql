--- Dropped the below index .. Add  back if required 
DROP INDEX [IX_AssetCommentHistory_StartTime_EndTime] ON [dbo].[AssetCommentHistory]
GO

--CREATE NONCLUSTERED INDEX [IX_AssetCommentHistory_StartTime_EndTime] ON [dbo].[AssetCommentHistory]
--(
--	[Shift_StartTime] ASC,
--	[Shift_EndTime] ASC
--)
--INCLUDE ( 	[LinkId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--GO



------- New Index identified (not yet part of the release , drop after testing)

DROP INDEX IF EXISTS [IX_CommentCategoryHistory_FK_AssetCommentHistory_PK_ID] on dbo.CommentCategoryHistory
GO

CREATE NONCLUSTERED INDEX [IX_CommentCategoryHistory_FK_AssetCommentHistory_PK_ID]
ON [dbo].[CommentCategoryHistory] ([AssetCommentHistory_PK_ID])
INCLUDE ([Category],[Value])
GO

------- Response column added to the index definition (drop after testing)
DROP INDEX [IX_AssetCommentHistory_LinkID] ON [dbo].[AssetCOmmentHistory]
GO
CREATE NONCLUSTERED INDEX [IX_AssetCommentHistory_LinkID] ON [dbo].[AssetCommentHistory]
(
	[LinkId] ASC,
	[Response] ASC
)
INCLUDE ([Asset_PK_ID],[CommentType_PK_ID])
-------------------------------------------------------------------------------------------------------

CREATE NONCLUSTERED INDEX [IX_AssetCommentHistory_Response_LinkID] ON [dbo].[AssetCommentHistory]
(
	[Response] ASC,
	[LinkId] ASC
)

-------------------------------------------------------------------------------------------------------

DROP INDEX [IX_Activities_EndTime] ON [dbo].[Activities]
GO

CREATE NONCLUSTERED INDEX [IX_Activities_EndTime] ON [dbo].[Activities]
(
	[EndTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



DROP INDEX [IX_Activities_HasDeviation_Incl] ON [dbo].[Activities]
GO

CREATE NONCLUSTERED INDEX [IX_Activities_HasDeviation_Incl] ON [dbo].[Activities]
(
	[HasDeviationSamples] ASC,
	[LastImpactProcessedTime] ASC
)
INCLUDE ([EndTime],
	[Activity_PK_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO





DROP INDEX [IX_SplitActivities_StartTime] ON [dbo].[SplitActivities]
GO


CREATE NONCLUSTERED INDEX [IX_SplitActivities_StartTime] ON [dbo].[SplitActivities]
(
	[StartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



DROP INDEX [IX_SplitActivities_EndTime] ON [dbo].[SplitActivities]
GO


CREATE NONCLUSTERED INDEX [IX_SplitActivities_EndTime] ON [dbo].[SplitActivities]
(
	[EndTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



-------------INDEXES TO BE DROPPED ------


USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO


DROP INDEX [IX_Comments_Asset_PK_ID] ON [dbo].[Comments]
GO

--/****** Object:  Index [IX_Comments_Asset_PK_ID]    Script Date: 9/7/2021 5:11:58 PM ******/
--CREATE NONCLUSTERED INDEX [IX_Comments_Asset_PK_ID] ON [dbo].[Comments]
--(
--	[Asset_PK_ID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--GO


USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO

/****** Object:  Index [IX_Comments_CommentType_PK_ID]    Script Date: 9/7/2021 5:12:22 PM ******/
DROP INDEX [IX_Comments_CommentType_PK_ID] ON [dbo].[Comments]
GO


--CREATE NONCLUSTERED INDEX [IX_Comments_CommentType_PK_ID] ON [dbo].[Comments]
--(
--	[CommentType_PK_ID] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
--GO




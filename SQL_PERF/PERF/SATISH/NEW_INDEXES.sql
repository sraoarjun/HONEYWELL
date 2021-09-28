USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO


--- New index identified

CREATE NONCLUSTERED INDEX [IX_SplitActivities_FK_TagMonitoring_PK_ID] ON [dbo].[SplitActivities]
(
	[TagMonitoring_PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


-- Added the extra column TagMOnitoring_pk_id 
DROP INDEX [IX_Activities_IsSplit_Inc_StartTime_EndTime] ON [dbo].[Activities]
GO
CREATE NONCLUSTERED INDEX [IX_Activities_IsSplit_Inc_StartTime_EndTime] ON [dbo].[Activities]
(
	[IsSplit] ASC
)
INCLUDE ([StartTime],
	[EndTime],
	[TagMonitoring_PK_ID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO





-- New index identified -- But needs testing since it is causing issue else where
CREATE NONCLUSTERED INDEX [IX_Activities_FK_TagMonitorings_PK_ID] ON [dbo].[Activities]
(
	[TagMonitoring_PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


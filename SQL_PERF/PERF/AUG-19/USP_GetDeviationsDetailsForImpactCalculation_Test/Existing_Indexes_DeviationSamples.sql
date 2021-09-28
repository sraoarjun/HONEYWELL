USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO

/****** Object:  Index [PK_DeviationSamples]    Script Date: 8/24/2021 11:31:56 PM ******/
ALTER TABLE [dbo].[DeviationSamples] DROP CONSTRAINT [PK_DeviationSamples]
GO

/****** Object:  Index [PK_DeviationSamples]    Script Date: 8/24/2021 11:31:56 PM ******/
ALTER TABLE [dbo].[DeviationSamples] ADD  CONSTRAINT [PK_DeviationSamples] PRIMARY KEY CLUSTERED 
(
	[DeviationSample_PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO

/****** Object:  Index [IX_DeviationSamples_SampleTime_Test]    Script Date: 8/24/2021 11:32:20 PM ******/
DROP INDEX [IX_DeviationSamples_SampleTime_Test] ON [dbo].[DeviationSamples]
GO

/****** Object:  Index [IX_DeviationSamples_SampleTime_Test]    Script Date: 8/24/2021 11:32:20 PM ******/
CREATE NONCLUSTERED INDEX [IX_DeviationSamples_SampleTime_Test] ON [dbo].[DeviationSamples]
(
	[Activity_PK_ID] ASC,
	[SampleTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO

/****** Object:  Index [IX_DeviationSamples_FK_TagMonitoring_PK_ID_Test]    Script Date: 8/24/2021 11:32:32 PM ******/
DROP INDEX [IX_DeviationSamples_FK_TagMonitoring_PK_ID_Test] ON [dbo].[DeviationSamples]
GO

/****** Object:  Index [IX_DeviationSamples_FK_TagMonitoring_PK_ID_Test]    Script Date: 8/24/2021 11:32:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_DeviationSamples_FK_TagMonitoring_PK_ID_Test] ON [dbo].[DeviationSamples]
(
	[TagMonitoring_PK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


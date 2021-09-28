EXEC dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB', @SchemaName='dbo', @TableName='StandingOrderCommentsHistory';
EXEC dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB', @SchemaName='dbo', @TableName='Activities';
EXEC dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB', @SchemaName='dbo', @TableName='Activities';
EXEC dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB', @SchemaName='dbo', @TableName='TagMonitoringStatusHistories';
EXEC dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB', @SchemaName='dbo', @TableName='ArchivalHistories';
EXEC dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB', @SchemaName='dbo', @TableName='CommentCategories';
EXEC dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB', @SchemaName='dbo', @TableName='TagMonitorings';


EXEC dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB', @SchemaName='dbo', @TableName='Activities';

EXEC dbo.sp_BlitzIndex @DatabaseName='Honeywell.MES.Operations.DataModel.OperationsDB', @SchemaName='dbo', @TableName='Activities';









CREATE INDEX missing_index_1512 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[StandingOrderCommentsHistory] ([StandingOrder_StandingOrder_PK_ID], [CreatedTime])	



CREATE INDEX missing_index_84841 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Activities] ([IsSplit]) INCLUDE ([StartTime], [EndTime], [Duration], [TagMonitoring_PK_ID])	

CREATE INDEX missing_index_84781 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Activities] ([IsSplit]) INCLUDE ([StartTime], [Activity_PK_ID], [TagMonitoring_PK_ID], [SplitShiftName], [ExpectedSplitShiftEndTime])	

CREATE INDEX missing_index_84783 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Activities] ([IsSplit]) INCLUDE ([StartTime], [EndTime], [Activity_PK_ID], [TagMonitoring_PK_ID])	

CREATE INDEX missing_index_85310 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Activities] ([IsSplit]) INCLUDE ([LimitName], [StartTime], [EndTime], [LimitType], [Duration], [TagMonitoring_PK_ID])	


CREATE INDEX missing_index_138377 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Activities] ([EndTime]) INCLUDE ([Activity_PK_ID], [TagMonitoring_PK_ID])	




CREATE INDEX missing_index_84708 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitoringStatusHistories] ([Note_PK_ID])	
CREATE INDEX missing_index_1187 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[ArchivalHistories] ([GroupName], [RunStatus]) INCLUDE ([ArchivedTillDate])	
CREATE INDEX missing_index_84874 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[CommentCategories] ([Comment_PK_ID]) INCLUDE ([Category], [Value])	
CREATE INDEX missing_index_84838 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitorings] ([Active], [EffectiveFromTime]) INCLUDE ([Name], [TagWeightage], [LastProcessedTime], [ImpactUnit], [TagType], [TagMonitoring_PK_ID], [PrimaryAsset_PK_ID], [ImpactPrecision])	

CREATE INDEX missing_index_86256 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Comments] ([Asset_PK_ID], [Shift_StartTime], [Shift_EndTime], [LinkId])	
CREATE INDEX missing_index_84710 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitorings] ([Active], [LastProcessedTime])	
CREATE INDEX missing_index_84690 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[SplitActivities] ([EndTime]) INCLUDE ([SplitActivity_PK_ID], [Activity_PK_ID], [TagMonitoring_PK_ID])	


CREATE INDEX missing_index_8586 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[StandingOrderCommentsHistory] ([StandingOrder_StandingOrder_PK_ID], [StandingOrderCommentType_StandingOrderCommentTypeId], [CreatedTime])	
CREATE INDEX missing_index_84849 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitorings] ([EffectiveFromTime], [LastProcessedTime]) INCLUDE ([Name], [SampleFrequency], [MinimumDeviationTime], [TagType], [TagMonitoring_PK_ID])	
CREATE INDEX missing_index_84698 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitorings] ([TagType]) INCLUDE ([TagMonitoring_PK_ID])	
CREATE INDEX missing_index_84700 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[LimitInfo] ([IsInDeviation]) INCLUDE ([OpenActivityID], [LimitInfo_PK_ID], [TagMonitoring_PK_ID])	
CREATE INDEX missing_index_84719 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitorings] ([TagType], [DownTimeMonitoring], [HealthMonitoring_PK_ID]) INCLUDE ([Name], [SampleFrequency], [MinimumDeviationTime], [Active], [EffectiveFromTime], [LastProcessedTime], [IsInProcess], [OPCAggregationName], [TagMonitoring_PK_ID])	
CREATE INDEX missing_index_84715 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitorings] ([TagType], [EffectiveFromTime], [LastProcessedTime])	
CREATE INDEX missing_index_84713 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitorings] ([TagType], [LastProcessedTime])	
CREATE INDEX missing_index_84717 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitorings] ([TagType], [OPCAggregationName]) INCLUDE ([Name], [SampleFrequency], [MinimumDeviationTime], [Active], [EffectiveFromTime], [LastProcessedTime], [IsInProcess], [TagMonitoring_PK_ID], [DownTimeMonitoring], [HealthMonitoring_PK_ID])	
CREATE INDEX missing_index_84721 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitorings] ([TagType], [DownTimeMonitoring], [OPCAggregationName], [HealthMonitoring_PK_ID]) INCLUDE ([Name], [SampleFrequency], [MinimumDeviationTime], [Active], [EffectiveFromTime], [LastProcessedTime], [IsInProcess], [TagMonitoring_PK_ID])	
CREATE INDEX missing_index_1492 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[PersonDetails] ([UserPrincipal]) INCLUDE ([PersonDetail_Pk_Id], [Name], [DisplayName], [EmailID])	
CREATE INDEX missing_index_85690 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[AssetCommentHistory] ([Asset_PK_ID], [Shift_StartTime], [Shift_EndTime], [LinkId])	
CREATE INDEX missing_index_84847 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[TagMonitorings] ([Active])	
CREATE INDEX missing_index_85692 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[AssetCommentHistory] ([Shift_StartTime], [Shift_EndTime], [LinkId]) INCLUDE ([Asset_PK_ID])	
CREATE INDEX missing_index_84946 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[StandingOrders] ([Asset_Asset_PK_ID], [ActualStartTime]) INCLUDE ([StandingOrder_PK_ID], [Name], [StandingOrderCategory_StandingOrderCategory_PK_ID], [State_StateId], [AssignToChildAssets])	
CREATE INDEX missing_index_84948 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[StandingOrders] ([ActualStartTime]) INCLUDE ([StandingOrder_PK_ID], [Name], [StandingOrderCategory_StandingOrderCategory_PK_ID], [State_StateId], [Asset_Asset_PK_ID], [AssignToChildAssets])	
CREATE INDEX missing_index_84919 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Tasks] ([State_StateId]) INCLUDE ([Task_PK_Id], [StartTime], [ModifiedEndTime], [Asset_Asset_PK_ID])	
CREATE INDEX missing_index_85694 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[AssetCommentHistory] ([LinkId]) INCLUDE ([AssetCommentHistory_PK_ID], [Asset_PK_ID])	
CREATE INDEX missing_index_84895 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[ShiftSummaries] ([Shift_StartTime], [Shift_EndTime]) INCLUDE ([ShiftSummary_PK_ID], [Asset_PK_ID], [ShiftSummaryStatus_PK_ID])	
CREATE INDEX missing_index_84913 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[StandingOrdersActionHistory] ([StandingOrder_StandingOrder_PK_ID], [ActionTime]) INCLUDE ([ActionType_ActionTypeID])	
CREATE INDEX missing_index_84915 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[StandingOrdersActionHistory] ([StandingOrder_StandingOrder_PK_ID]) INCLUDE ([ActionType_ActionTypeID], [ActionTime])	
CREATE INDEX missing_index_84921 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[StandingOrdersActionHistory] ([StandingOrder_StandingOrder_PK_ID]) INCLUDE ([ActionType_ActionTypeID])	
CREATE INDEX missing_index_1499 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[PersonDetails] ([UserPrincipal]) INCLUDE ([PersonDetail_Pk_Id], [Name], [DisplayName])	
CREATE INDEX missing_index_130130 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Comments] ([CommentType_PK_ID], [ShiftSummary_PK_ID], [Shift_StartTime], [Shift_EndTime]) INCLUDE ([LinkId], [Comment_PK_ID], [Asset_PK_ID])	
CREATE INDEX missing_index_86273 ON [Honeywell.MES.Operations.DataModel.OperationsDB].[dbo].[Assets] ([EquipID])	

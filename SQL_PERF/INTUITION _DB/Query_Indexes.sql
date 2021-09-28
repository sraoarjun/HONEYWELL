DROP INDEX  [IsInProcess_Includes] ON [EventProcessorModel].[Events]
GO
CREATE INDEX [IsInProcess_Includes] ON [EventProcessorModel].[Events] ([IsInProcess])  INCLUDE ([EventTime], [EventData], [KeyContextName], [KeyContextValue], [ID], [DirectSubscriptionID], [Event_PK_ID], [EventType_PK_ID]);


DROP INDEX [IsInProcess_EventType_PK_ID_Includes] ON [EventProcessorModel].[Events]
GO
CREATE INDEX [IsInProcess_EventType_PK_ID_Includes] ON [EventProcessorModel].[Events] ([IsInProcess], [EventType_PK_ID])  INCLUDE ([EventTime], [EventData], [KeyContextName], [KeyContextValue], [ID], [DirectSubscriptionID], [Event_PK_ID]) ;




DROP INDEX [IsInProcess_EventType_PK_ID_Includes] ON [EventProcessorModel].[Events]
GO
CREATE INDEX [IsInProcess_EventType_PK_ID_Includes] ON [EventProcessorModel].[Events] ([IsInProcess], [EventType_PK_ID])  INCLUDE ([EventTime], [KeyContextName], [KeyContextValue], [ID], [DirectSubscriptionID], [Event_PK_ID]) ;


DROP INDEX [TaskID_Includes] ON[dbo].[AzMan_Task_To_Operation_Link]
CREATE INDEX [TaskID_Includes] ON [dbo].[AzMan_Task_To_Operation_Link] ([TaskID])INCLUDE ([OperationID]);



set statistics io on
select * from [AzMan_Task_To_Operation_Link] where TaskID = 2 
set statistics io off

exec sp_sqlskills_helpindex 'dbo.AzMan_Task_To_Operation_Link'

exec sp_sqlskills_helpindex 'EventProcessorModel.Events'
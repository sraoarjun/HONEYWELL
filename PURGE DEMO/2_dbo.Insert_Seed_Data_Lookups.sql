USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO

--SET IDENTITY_INSERT [dbo].[Archival_Config] ON 

--INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [source_database_name], [destination_database_name], [override_batch_size], [override_history_data_retention_days],[PurgeOnly],[filters],[LookupName], [archival_status], [is_enabled], [archival_storage_options_id], [job_start_time], [job_end_time], [schedule_frequency_in_days], [db_datetime_last_updated]) VALUES (1, N'Archiving the ShiftSummaryHistory table', N'dbo', N'ShiftSummaryHistory', N'Operations_DB', N'Archival_DB', 1000,1940,1, N' where Shift_EndTime < {Date_Parameter}', 'ShiftSummaryHistory_Data_Retention_Days',NULL, 1, 1, NULL, NULL, NULL, CAST(N'2022-04-21T19:16:53.093' AS DateTime))

--SET IDENTITY_INSERT [dbo].[Archival_Config] OFF

--GO


/*
SET IDENTITY_INSERT [dbo].[Archival_Config] ON 

INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [source_database_name], [destination_database_name], [override_batch_size], [override_history_data_retention_days],[PurgeOnly],[filters],[LookupName], [archival_status], [is_enabled], [archival_storage_options_id], [job_start_time], [job_end_time], [schedule_frequency_in_days], [db_datetime_last_updated]) VALUES (2, N'Archiving the ShiftSummaryDisplayHistory table', N'dbo', N'ShiftSummaryDisplayHistory', N'Operations_DB', N'Archival_DB', 1000,null,1, N' LEFT JOIN ShiftSummaryHistory  ON ShiftSummaryDisplayHistory.ShiftSummaryDisplayHistory_PK_ID = ShiftSummaryHistory.ShiftSummaryHistory_PK_ID
LEFT JOIN ShiftSummaryStatus ON  ShiftSummaryHistory.ShiftSummaryStatus_PK_ID = ShiftSummaryStatus.ShiftSummaryStatus_PK_ID
and ShiftSummaryHistory.ArchiveFileName is not null','ShiftSummaryHistory_Data_Retention_Days', NULL, 1, 1, NULL, NULL, NULL, CAST(N'2022-04-21T19:16:53.093' AS DateTime))

SET IDENTITY_INSERT [dbo].[Archival_Config] OFF

GO



--- For different schema - Site1
SET IDENTITY_INSERT [dbo].[Archival_Config] ON 

INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [source_database_name], [destination_database_name], [override_batch_size], [PurgeOnly],[filters],[LookupName], [archival_status], [is_enabled], [archival_storage_options_id], [job_start_time], [job_end_time], [schedule_frequency_in_days], [db_datetime_last_updated]) VALUES (3 N'Archiving the ShiftSummaryDisplayHistory table', N'Site1', N'ShiftSummaryDisplayHistory', N'Operations_DB', N'Archival_DB', 1000,1, N' LEFT JOIN ShiftSummaryHistory  ON ShiftSummaryDisplayHistory.ShiftSummaryDisplayHistory_PK_ID = ShiftSummaryHistory.ShiftSummaryHistory_PK_ID
LEFT JOIN ShiftSummaryStatus ON  ShiftSummaryHistory.ShiftSummaryStatus_PK_ID = ShiftSummaryStatus.ShiftSummaryStatus_PK_ID
and ShiftSummaryHistory.ArchiveFileName is not null','ShiftSummaryHistory_Data_Retention_Days', NULL, 1, 1, NULL, NULL, NULL, CAST(N'2022-04-21T19:16:53.093' AS DateTime))

SET IDENTITY_INSERT [dbo].[Archival_Config] OFF

GO


--TRUNCATE TABLE Archival_Settings_Config

*/

INSERT INTO dbo.Archival_Settings_Config 
(	
	setting_name,
	setting_value,
	description_text,
	date_created
)

SELECT 
	 'Purge_Batch_Size',
	 '5000',
	 'batch size of the records being purged. This setting signifies the number of records that are purged at a time',
	 getdate()

INSERT INTO dbo.Archival_Settings_Config 
(	
	setting_name,
	setting_value,
	description_text,
	date_created
)

SELECT 
	 'Purge_Duration',
	 '02:00',
	 'The duration of the job in {HH:MM},beyond which it should terminate gracefully. The default is 2 hours {02:00}',
	 getdate()

	 
	
--LookupType Settings
--select * from dbo.LookupTypes where name = 'History Purging Parameters'
--delete from dbo.LookupTypes where name = 'History Purging Parameters'

Insert into dbo.LookupTypes (Name,Description,Owner,LookupType_PK_ID)
Select 
	'History Purging Parameters','The parameters that are used by the history tables purging process.','System',NEWID()
GO


--select * from dbo.Lookups where LookupType_PK_ID = (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters')
--and Name <> 'Deviation Samples Retention Days'
--delete from dbo.Lookups where LookupType_PK_ID = (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters')
--and Name <> 'Deviation Samples Retention Days'


--- Lookup Settings
--Whether the purge operqtion is enabled or not (ON/OFF)

INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)

SELECT


       'Enable_Purge_Operation',

       'Set to True,to enable Purge,otherwise set to False.',

       'True',

       'Enable_Purge_Operation',

       'ALL',

       null ,

       NEWID(),

       (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters'),

       null,

       'ALL'

 

GO

 

 

 

--Batch Size

--INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)

--SELECT

 

--       'Batch_Size',

--       'The batch size for the purge operation',

--       '5000',

--       'Batch_Size',

--       'ALL',

--       null ,

--       NEWID(),

--       (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters'),

--       null,

--       'ALL'

--GO

 

 

-- ShiftSummaryHistory Purge setting

INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)

SELECT

 

       'ShiftSummaryHistory_Data_Retention_Days',

       'The number of days for which the shift summary histtory related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.',

       '1825',

       'ShiftSummaryHistory_Data_Retention_Days',

       'Logbook',

       null ,

       NEWID(),

       (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters'),

       null,

       'Logbook'

 

GO

 

 

-- Activity History setting

INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)

SELECT

 

       'ActivityHistory_Data_Retention_Days',

       'The number of days for which the Activity history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.',

       '1825',

       'ActivityHistory_Data_Retention_Days',

       'Logbook',

       null ,

       NEWID(),

       (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters'),

       null,

       'Logbook'

 

GO

 

 

 

INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)

SELECT

 

       'CommentHistory_Data_Retention_Days',

       'The number of days for which the Comments history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.',

       '1825',

       'CommentHistory_Data_Retention_Days',

       'Logbook',

       null ,

       NEWID(),

       (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters'),

       null,

       'Logbook'

 

GO

 

 

 

INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)

SELECT

 

       'TagMonitoringHistory_Data_Retention_Days',

       'The number of days for which the Monitoring history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.',

       '1825',

       'TagMonitoringHistory_Data_Retention_Days',

       'Logbook',

       null ,

       NEWID(),

       (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters'),

       null,

       'Logbook'

 

GO

 

 

 

 

 

INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)

SELECT

 

       'CrossShiftReportGeneratedLinksHistory_Data_Retention_Days',

       'The number of days for which the CrossShiftReport history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.',

       '1825',

       'CrossShiftReportGeneratedLinksHistory_Data_Retention_Days',

       'Logbook',

       null ,

       NEWID(),

       (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters'),

       null,

       'Logbook'

 

GO

 

 

 

INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)

SELECT

 

       'InstructionsHistory_Data_Retention_Days',

       'The number of days for which the Instructions history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.',

       '1825',

       'InstructionsHistory_Data_Retention_Days',

       'Logbook',

       null ,

       NEWID(),

       (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters'),

       null,

       'Logbook'

 

GO

 

 


 

INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)

SELECT

 

       'MeetingsHistory_Data_Retention_Days',

       'The number of days for which the Meeting history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.',

       '1825',

       'MeetingsHistoryHistory_Data_Retention_Days',

       'Logbook',

       null ,

       NEWID(),

       (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters'),

       null,

       'Logbook'

 

GO

 

INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)

SELECT

 

       'StandingOrdersHistory_Data_Retention_Days',

       'The number of days for which the StandingOrders history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.',

       '1825',

       'StandingOrdersHistory_Data_Retention_Days',

       'Logbook',

       null ,

       NEWID(),

       (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters'),

       null,

       'Logbook'

 

GO

 

INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)

SELECT

 

       'TasksHistory_Data_Retention_Days',

       'The number of days for which the Task history related data is retained in the table. The default value is 1825 (5 years). The older data is delete from the history table.',

       '1825',

       'TasksHistory_Data_Retention_Days',

       'Logbook',

       null ,

       NEWID(),

       (select LookupType_PK_ID from dbo.LookupTypes where name ='History Purging Parameters'),

       null,

       'Logbook'

 

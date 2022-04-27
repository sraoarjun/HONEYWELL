
INSERT INTO dbo.Archival_Storage_Options 
	(
		Storage_Type,
		Description
	)
VALUES 
	(
		'Yearly',
		'Yearly storage - Creates a new database for every year based on the data partition field'
	)
	,

	(
		'Half-Yearly',
		'Half-Yearly storage - Creates a new database for every half-year based on the data partition field'
	),

	(
		'Quarterly',
		'Quarterly storage - Creates a new database for every quarter based on the data partition field'
	),
	
	(
		'Monthly',
		'Monthly storage - Creates a new database for every month based on the data partition field'
	)

GO


SET IDENTITY_INSERT [dbo].[Archival_Config] ON 

INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [source_database_name], [destination_database_name], [batch_size], [PurgeOnly],[filters], [archival_status], [is_enabled], [archival_storage_options_id], [job_start_time], [job_end_time], [schedule_frequency_in_days], [db_datetime_last_updated]) VALUES (4, N'Archiving the ShiftSummaryDisplayHistory table', N'dbo', N'ShiftSummaryDisplayHistory', N'Operations_DB', N'Archival_DB', 1000,1, N' LEFT JOIN ShiftSummaryHistory  ON ShiftSummaryDisplayHistory.ShiftSummaryDisplayHistory_PK_ID = ShiftSummaryHistory.ShiftSummaryHistory_PK_ID
LEFT JOIN ShiftSummaryStatus ON  ShiftSummaryHistory.ShiftSummaryStatus_PK_ID = ShiftSummaryStatus.ShiftSummaryStatus_PK_ID
and ShiftSummaryHistory.ArchiveFileName is not null', NULL, 1, 1, NULL, NULL, NULL, CAST(N'2022-04-21T19:16:53.093' AS DateTime))

SET IDENTITY_INSERT [dbo].[Archival_Config] OFF

GO



--- For different schema - Site1
SET IDENTITY_INSERT [dbo].[Archival_Config] ON 

INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [source_database_name], [destination_database_name], [batch_size], [PurgeOnly],[filters], [archival_status], [is_enabled], [archival_storage_options_id], [job_start_time], [job_end_time], [schedule_frequency_in_days], [db_datetime_last_updated]) VALUES (5, N'Archiving the ShiftSummaryDisplayHistory table', N'Site1', N'ShiftSummaryDisplayHistory', N'Operations_DB', N'Archival_DB', 1000,1, N' LEFT JOIN ShiftSummaryHistory  ON ShiftSummaryDisplayHistory.ShiftSummaryDisplayHistory_PK_ID = ShiftSummaryHistory.ShiftSummaryHistory_PK_ID
LEFT JOIN ShiftSummaryStatus ON  ShiftSummaryHistory.ShiftSummaryStatus_PK_ID = ShiftSummaryStatus.ShiftSummaryStatus_PK_ID
and ShiftSummaryHistory.ArchiveFileName is not null', NULL, 1, 1, NULL, NULL, NULL, CAST(N'2022-04-21T19:16:53.093' AS DateTime))

SET IDENTITY_INSERT [dbo].[Archival_Config] OFF

GO





SET IDENTITY_INSERT [dbo].[Archival_Config] ON 

INSERT [dbo].[Archival_Config] ([archival_config_id], [description_text], [table_schema], [table_name], [source_database_name], [destination_database_name], [batch_size], [PurgeOnly],[filters], [archival_status], [is_enabled], [archival_storage_options_id], [job_start_time], [job_end_time], [schedule_frequency_in_days], [db_datetime_last_updated]) VALUES (6, N'Archiving the ShiftSummaryHistory table', N'dbo', N'ShiftSummaryHistory', N'Operations_DB', N'Archival_DB', 1000,1, N' where Shift_EndTime < {Date_Parameter}', NULL, 1, 1, NULL, NULL, NULL, CAST(N'2022-04-21T19:16:53.093' AS DateTime))

SET IDENTITY_INSERT [dbo].[Archival_Config] OFF

GO


--- Lookup Settings 


--Whether the purge operqtion is enabled or not (ON/OFF)
INSERT INTO dbo.Lookups(Name,Description,Value,DisplayName,Application,Asset,Lookup_PK_ID,LookupType_PK_ID,LookupValueDataType,ApplicationDisplayName)
SELECT 

	'PurgeOperation_ON_OFF',
	'Whether the Purge is enabled or not',
	'ON',
	'PurgeOperation_ON_OFF',
	'ALL',
	null ,
	NEWID(),
	'C77C866E-B81D-4A2C-BFC8-BB253E7CEDFD',
	null,
	'ALL'

GO

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
	'C77C866E-B81D-4A2C-BFC8-BB253E7CEDFD',
	null,
	'Logbook'

GO

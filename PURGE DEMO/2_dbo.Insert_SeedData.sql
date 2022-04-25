
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
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


---================================================================================================================================================


insert into 
	dbo.Archival_Config
	(
		description_text,
		table_schema,
		table_name,
		source_database_name,
		destination_database_name,
		batch_size,
		filters,
		archival_status,
		is_enabled,
		archival_storage_options_id,
		db_datetime_last_updated
	)
select 
	'Archiving the StandingOrdersHistory table',
	'dbo',
	'StandingOrdersHistory',
	'Operations_DB',
	'Archival_DB',
	225000,
	'ActualStartTime < DATEADD(Year,-5,GETDATE())',
	null,
	1,
	1,
	getdate()

GO



insert into 
	dbo.Archival_Config
	(
		description_text,
		table_schema,
		table_name,
		source_database_name,
		destination_database_name,
		batch_size,
		filters,
		archival_status,
		is_enabled,
		archival_storage_options_id,
		db_datetime_last_updated
	)
select 
	'Archiving the InstructionsHistory table',
	'dbo',
	'InstructionsHistory',
	'Operations_DB',
	'Archival_DB',
	100000,
	null,
	null,
	1,
	1,
	getdate()

GO



insert into 
	dbo.Archival_Config
	(
		description_text,
		table_schema,
		table_name,
		source_database_name,
		destination_database_name,
		batch_size,
		filters,
		archival_status,
		is_enabled,
		archival_storage_options_id,
		db_datetime_last_updated
	)
select 
	'Archiving the ActivityHistory table',
	'dbo',
	'ActivityHistory',
	'Operations_DB',
	'Archival_DB',
	100000,
	'StartTime < dateadd(year,-5,getdate())',
	null,
	1,
	2,
	getdate()

GO

--- Testing only 
insert into 
	dbo.Archival_Config
	(
		description_text,
		table_schema,
		table_name,
		source_database_name,
		destination_database_name,
		batch_size,
		filters,
		archival_status,
		is_enabled,
		db_datetime_last_updated
	)
select 
	'Archiving the Equipments table',
	'dbo',
	'Equipments',
	'HwlAssets_EPM',
	'Archival_DB',
	10,
	'Year(CreatedDate) = 2020',
	null,
	1,
	getdate()

GO

USE [HwlAssets_EPM]
GO
SET IDENTITY_INSERT [dbo].[Archival_Error_Log] ON 

INSERT [dbo].[Archival_Error_Log] ([archival_error_log_id], [archival_config_id], [error_description], [error_date]) VALUES (1, 1, N'Invalid object name ''dbo.RegUsers'' ', CAST(N'2022-03-27T15:39:08.947' AS DateTime))
INSERT [dbo].[Archival_Error_Log] ([archival_error_log_id], [archival_config_id], [error_description], [error_date]) VALUES (2, 1, N'[Error msg] - string or binary data would be truncated,[Errror procedure] -sp_insertArchival_Data, [Error Line] - 40', CAST(N'2022-03-28T15:39:08.947' AS DateTime))
SET IDENTITY_INSERT [dbo].[Archival_Error_Log] OFF
GO


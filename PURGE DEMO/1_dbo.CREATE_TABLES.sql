DROP TABLE IF EXISTS dbo.Archival_Error_Log
GO
DROP TABLE IF EXISTS dbo.Archival_Schedule_Config
GO
DROP TABLE IF EXISTS dbo.Archival_Config 
GO
DROP TABLE IF EXISTS dbo.Archival_Storage_Options
GO
DROP TABLE IF EXISTS dbo.Archival_Execution_Log
GO

CREATE TABLE dbo.Archival_Execution_Log(id int identity(1,1) constraint pk_archival_execution_log primary key ,description_text varchar(4000),date_created datetime)


DROP TABLE IF EXISTS dbo.Archival_Storage_Options
GO
CREATE TABLE dbo.Archival_Storage_Options
	(
		archival_storage_options_id tinyint IDENTITY(1,1), 
		storage_Type Varchar(100),description Varchar(250),
		CONSTRAINT PK_Archival_Storage_Options PRIMARY KEY (archival_storage_options_id)
	)
GO


DROP TABLE IF EXISTS dbo.Archival_Config 
GO
CREATE TABLE dbo.Archival_Config 
(
	archival_config_id int identity(1,1) constraint pk_archival_config primary key,
	description_text varchar(8000),
	table_schema varchar(100),
	table_name varchar(100),
	source_database_name varchar(200),
	destination_database_name varchar(100),
	override_batch_size int ,
	override_history_data_retention_days int,
	PurgeOnly bit,
	filters varchar(4000),
	LookupName varchar(200),
	archival_status tinyint,
	is_enabled bit,
	archival_storage_options_id tinyint,
	job_start_time time(7) NULL,
	job_end_time time(7) NULL,
	schedule_frequency_in_days int NULL,
	db_datetime_last_updated datetime,
)
GO

-- Add foreign key to Archival config (archival_storage_options_id)
ALTER TABLE dbo.Archival_Config
ADD CONSTRAINT FK_Archival_Config_Archival_Storage_Options FOREIGN KEY (archival_storage_options_id)
REFERENCES dbo.Archival_Storage_Options (archival_storage_options_id)
GO


DROP TABLE IF EXISTS dbo.Archival_Schedule_Config
GO
CREATE TABLE dbo.Archival_Schedule_Config
(
archival_schedule_config_id INT IDENTITY(1,1),
archival_config_id INT,
last_execution_date DATE ,
next_execution_date DATE,
CONSTRAINT PK_Archival_Schedule_Config PRIMARY KEY (archival_schedule_config_id)
)


-- Add foreign key to Archival_Schedule_Config  (archival_config_id)
ALTER TABLE dbo.Archival_Schedule_Config
ADD CONSTRAINT FK_Archival_Schedule_Config_Archival_Config FOREIGN KEY (archival_config_id)
REFERENCES dbo.Archival_Config (archival_config_id)
GO

DROP TABLE IF EXISTS [dbo].[Archival_Error_Log]
GO
CREATE TABLE [dbo].[Archival_Error_Log](
	[archival_error_log_id] [int] IDENTITY(1,1) NOT NULL,
	[archival_config_id] [int] NULL,
	[error_description] [varchar](max) NULL,
	[error_date] [datetime] NULL,
CONSTRAINT PK_Archival_Error_Log PRIMARY KEY (archival_error_log_id)

) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- Add foreign key to Archival_Schedule_Config  (archival_config_id)
ALTER TABLE dbo.Archival_Error_Log
ADD CONSTRAINT FK_Archival_Error_Log_Archival_Config FOREIGN KEY (archival_config_id)
REFERENCES dbo.Archival_Config (archival_config_id)
GO
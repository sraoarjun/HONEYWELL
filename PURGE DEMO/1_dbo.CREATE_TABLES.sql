USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO
DROP TABLE IF EXISTS dbo.Archival_Error_Log
GO
DROP TABLE IF EXISTS dbo.Archival_Execution_Log
GO
DROP TABLE IF EXISTS dbo.Archival_Config 
GO
DROP TABLE IF EXISTS dbo.Archival_Settings_Config 
GO


CREATE TABLE dbo.Archival_Settings_Config 
(
	id int identity(1,1) constraint pk_archival_settings_config primary key,
	setting_name varchar(100),
	setting_value varchar(100),
	description_text varchar(4000),
	date_created datetime
)
GO


-- Archival Execution Log 
CREATE TABLE dbo.Archival_Execution_Log
(
	id int identity(1,1) constraint pk_archival_execution_log primary key ,
	description_text varchar(4000),
	date_created datetime
)
GO

-- Archival Config 
CREATE TABLE dbo.Archival_Config 
(
	archival_config_id int identity(1,1) constraint pk_archival_config primary key,
	description_text varchar(8000),
	table_schema varchar(100),
	table_name varchar(100),
	filters varchar(4000),
	lookupName varchar(200),
	purge_status tinyint,
	db_datetime_last_updated datetime,
)
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

-- Add foreign key to Archival_Error_Log  (archival_config_id)
ALTER TABLE dbo.Archival_Error_Log
ADD CONSTRAINT FK_Archival_Error_Log_Archival_Config FOREIGN KEY (archival_config_id)
REFERENCES dbo.Archival_Config (archival_config_id)
GO


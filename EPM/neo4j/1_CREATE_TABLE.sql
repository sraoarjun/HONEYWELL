USE [HwlAssets_EPM]
GO

DROP TABLE IF EXISTS [dbo].[Application_Type]
GO
CREATE TABLE [dbo].[Application_Type](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Application_Type] [varchar](50) NULL,
	[Application_Type_Full_Name] [varchar](250) NULL,
	[Version_Number] [varchar](50) NULL,
CONSTRAINT [PK_Application_Type] PRIMARY KEY CLUSTERED 
( 
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO




DROP TABLE IF EXISTS [dbo].[Application_Instance]
GO
CREATE TABLE [dbo].[Application_Instance](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationType_Id] INT NOT NULL,
	[Application_Instance_Name] [nvarchar](100) NULL,
CONSTRAINT [PK_Application_Instance] PRIMARY KEY CLUSTERED 
( 
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Application_Instance]  WITH CHECK ADD CONSTRAINT FK_Application_Instance_Application_Type_Id FOREIGN KEY([ApplicationType_Id])
REFERENCES [dbo].[Application_Type] ([Id])
GO



DROP TABLE IF EXISTS [dbo].[Equipments_Node_Csv]
GO
CREATE TABLE [dbo].[Equipments_Node_Csv](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Equipment_PK_ID] [uniqueidentifier] NOT NULL, 
	[HierarchyNode_PK_ID] [uniqueidentifier] NOT NULL,
	[Parent_PK_ID] [uniqueidentifier] NOT NULL, 
	[SourceAssetName] [nvarchar](100) NULL,
	[SourceAssetType] [nvarchar](100) NULL,
	[Application_Instance_Id] [int] NULL,
CONSTRAINT [PK_Equipments_Node_Csv] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Equipments_Node_Csv]  WITH CHECK ADD CONSTRAINT FK_Equipments_Node_Csv_Application_Instance_Id FOREIGN KEY([Application_Instance_Id])
REFERENCES [dbo].[Application_Instance] ([Id])
GO


DROP TABLE IF EXISTS [dbo].[Equipments_MasterNode_Csv]
GO
CREATE TABLE [dbo].[Equipments_MasterNode_Csv](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[MasterAssetName] [nvarchar](100) NULL,
	[AssetType] [nvarchar](100) NULL,
CONSTRAINT [PK_Equipments_MasterNode_Csv] PRIMARY KEY CLUSTERED 
( 
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

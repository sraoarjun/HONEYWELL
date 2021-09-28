USE [Honeywell.MES.LimitRepository.DataModel.LRModel]
GO

/****** Object:  Table [dbo].[Equipment_Variables_Association]    Script Date: 9/23/2021 4:28:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Equipment_Variables_Association_1](
	[ID] int identity (1,1),
	[Variable_PK_ID] [uniqueidentifier] NOT NULL,
	[Equipment_PK_ID] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Equipment_Variables_Association_1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
	
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Equipment_Variables_Association_1]  WITH CHECK ADD FOREIGN KEY([Equipment_PK_ID])
REFERENCES [dbo].[Equipment] ([Equipment_PK_ID])
GO

ALTER TABLE [dbo].[Equipment_Variables_Association_1]  WITH CHECK ADD FOREIGN KEY([Variable_PK_ID])
REFERENCES [dbo].[Variables] ([Variable_PK_ID])
GO


insert into dbo.Equipment_Variables_Association_1


select * from dbo.Equipment_Variables_Association_1
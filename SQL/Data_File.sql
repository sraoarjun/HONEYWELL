USE [AdventureWorks2016]
GO
/****** Object:  Table [dbo].[Variable]    Script Date: 2/11/2021 10:34:50 PM ******/
DROP TABLE [dbo].[Variable]
GO
/****** Object:  Table [dbo].[mode]    Script Date: 2/11/2021 10:34:50 PM ******/
DROP TABLE [dbo].[mode]
GO
/****** Object:  Table [dbo].[mode]    Script Date: 2/11/2021 10:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[mode](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[mode_id] [varchar](10) NULL,
	[mode_val] [varchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Variable]    Script Date: 2/11/2021 10:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Variable](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[variable] [varchar](10) NULL,
	[mode_id] [varchar](10) NULL,
	[mode_val] [varchar](50) NULL
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[mode] ON 

INSERT [dbo].[mode] ([id], [mode_id], [mode_val]) VALUES (1, N'Base', N'Base_value')
INSERT [dbo].[mode] ([id], [mode_id], [mode_val]) VALUES (2, N'M1', N'M1_value')
INSERT [dbo].[mode] ([id], [mode_id], [mode_val]) VALUES (3, N'M2', N'M2_value')
SET IDENTITY_INSERT [dbo].[mode] OFF
SET IDENTITY_INSERT [dbo].[Variable] ON 

INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (1, N'v1', N'Base', NULL)
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (2, N'v2', N'Base', NULL)
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (3, N'v3', N'Base', NULL)
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (4, N'v4', N'Base', NULL)
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (5, N'v5', N'Base', NULL)
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (6, N'v6', N'Base', NULL)
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (7, N'v7', N'Base', NULL)
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (8, N'v8', N'Base', NULL)
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (9, N'v9', N'Base', NULL)
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (10, N'v10', N'Base', NULL)
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (11, N'v2', N'M1', N'abc value')
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (12, N'v7', N'M2', N'xyz value')
INSERT [dbo].[Variable] ([id], [variable], [mode_id], [mode_val]) VALUES (12, N'v9', N'M1', N'v9 overriden value')
SET IDENTITY_INSERT [dbo].[Variable] OFF




---- Test the data being populated------

select * from dbo.mode
select * from dbo.Variable

-------Query to get the records as descibed by honeywell interview question 



select variable,mode_id,mode_val from 
(
select *, rownumber = row_number() over(partition by variable,mode_id order by case when charindex (mode_id,mode_val) = 0 then 1 else 2 end)  
	from 
	(
	select 
		v.id,v.variable,case when m.mode_id <> v.mode_id then m.mode_id else v.mode_id end as [mode_id],
		case when v.mode_val is null then m.mode_val else v.mode_val end as [mode_val] 
	from 
		dbo.mode m , dbo.Variable v 
	where v.mode_val is null 

	union 

	select v.id,v.variable,case when m.mode_id <> v.mode_id then m.mode_id else v.mode_id end as [mode_id],
			case when v.mode_val is null then m.mode_val else v.mode_val end as [mode_val]  
			from dbo.mode m join dbo.Variable v on m.mode_id = v.mode_id where 
	v.mode_val is not null 

	)A
)X 
where rownumber = 1 
go
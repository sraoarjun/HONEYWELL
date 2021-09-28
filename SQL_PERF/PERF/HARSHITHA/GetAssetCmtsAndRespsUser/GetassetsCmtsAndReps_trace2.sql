declare @p1 dbo.t_Asset
insert into @p1 values(N'41B-122 RACK R000006')
insert into @p1 values(N'41B-122 RACK R000021')
insert into @p1 values(N'41B-122 RACK R000036')
insert into @p1 values(N'41B-122 RACK R000051')
insert into @p1 values(N'41B-122 RACK R000066')
insert into @p1 values(N'41B-122 RACK R000081')
insert into @p1 values(N'41B-122 RACK R000096')
insert into @p1 values(N'41B-122 RACK R000111')
insert into @p1 values(N'41B-122 RACK R000126')
insert into @p1 values(N'41B-122 RACK R000141')
insert into @p1 values(N'41B-122 RACK R000156')
insert into @p1 values(N'41B-122 RACK R000171')
insert into @p1 values(N'41B-122 RACK R000186')
insert into @p1 values(N'41B-122 RACK R000201')
insert into @p1 values(N'41B-122 RACK R000216')
insert into @p1 values(N'41B-122 RACK R000231')
insert into @p1 values(N'41B-122 RACK R000246')
insert into @p1 values(N'41B-122 RACK R000261')
insert into @p1 values(N'41B-122 RACK R000276')
insert into @p1 values(N'41B-122 RACK R000291')
insert into @p1 values(N'41B-122 RACK R000306')

declare @p5 dbo.t_CommentType

declare @p6 dbo.t_CmtCategoryValuePair

exec sp_GetAssetCmtsAndRespsForUser @AssetList=@p1,@ShStartDate='2021-08-09 10:30:00',@ShEndDate='2021-08-09 14:30:00',@SearchText=default,@CmtTypeList=@p5,@CmtCatValueList=@p6,@PageNumber=1,@PageSize=10,@ParentCmtsOrderBy=N'desc'
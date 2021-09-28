declare @p1 dbo.t_Asset
insert into @p1 values(N'BayA')
insert into @p1 values(N'BayB')
insert into @p1 values(N'Plant')
insert into @p1 values(N'SiteA')
insert into @p1 values(N'SiteB')

declare @p5 dbo.t_CommentType

declare @p6 dbo.t_CmtCategoryValuePair

set statistics io,time on

exec sp_GetAssetCmtsAndRespsForUser @AssetList=@p1,@ShStartDate='2020-11-06 00:00:00',@ShEndDate='2021-02-06 00:00:00',@SearchText=default,@CmtTypeList=@p5,@CmtCatValueList=@p6,@PageNumber=1,@PageSize=10,@ParentCmtsOrderBy=N'desc'

set statistics io,time off


select Min(Shift_StartTime), max(Shift_StartTime), min(Shift_EndTime),max(Shift_EndTime) from dbo.AssetCommentHistory 



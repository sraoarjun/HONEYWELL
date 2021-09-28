
select * from   dbo.Assets where Name = 'ME-RF413-S03E'

select a.*, b.* from 
(select AssetName ,AssetDisplayName, count(1) as cnt from dbo.ShiftSummaryDisplayData group by AssetName,AssetDisplayName)A
join 
(select Asset_PK_ID,Name,DisplayName from dbo.Assets)B
on A.AssetName = B.Name and A.AssetDisplayName = B.DisplayName
where a.AssetName = 'ME-RF413-S03E'




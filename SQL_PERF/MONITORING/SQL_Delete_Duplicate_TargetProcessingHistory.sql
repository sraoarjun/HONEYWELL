USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO
select 
TagMonitoring_PK_ID
--,Limitinfo_Pk_ID
,StartTime
,EndTime
,TargetType
, count(1) as cnt 
from dbo.TargetProcessingHistory group by 
TagMonitoring_PK_ID
--,Limitinfo_Pk_ID
,StartTime
,EndTime
,TargetType
having count(1) > 1
 order by cnt desc


;WITH CTE

(
TagMonitoring_PK_ID
,StartTime
,EndTime
,TargetType  
,duplicatecount)
AS (SELECT 

TagMonitoring_PK_ID
,StartTime
,EndTime
,TargetType 
,ROW_NUMBER() OVER(PARTITION BY TagMonitoring_PK_ID
,StartTime
,EndTime
,TargetType 

           ORDER BY TagMonitoring_PK_ID) AS DuplicateCount
    FROM [dbo].TargetProcessingHistory)


DELETE FROM CTE
WHERE DuplicateCount > 1;
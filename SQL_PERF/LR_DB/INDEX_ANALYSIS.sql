set statistics io , time on

declare 
		@lookBackDateTime DATETIME = '2021-09-21 12:04:00.000'
		,@bgCreationDateTime DATETIME = '2021-09-24 12:04:00.000'
		
SELECT NEWID()
	,t2.Value
	,t2.EffectiveTime
	,t3.LowWriteTagDataSrcName
	,t3.LowWriteTagName
	,GETUTCDATE()
	,'0'
FROM OperatingLimitLowValues_tracking t1
JOIN OperatingLimitLowValues t2 ON t2.OperatingLimitLowValue_PK_ID = t1.OperatingLimitLowValue_PK_ID
JOIN OperatingLimits t3 ON t3.OperatingLimit_PK_ID = t2.OperatingLimit_PK_ID
WHERE t1.last_change_datetime > @lookBackDateTime
	AND t1.last_change_datetime <= @bgCreationDateTime
	AND t3.LowWriteTagDataSrcName IS NOT NULL
	AND t3.LowWriteTagName IS NOT NULL
	AND t2.Value IS NOT NULL

	set statistics io , time off


	select count(1) as cnt , count (case when LowWriteTagDataSrcName
	is not null and LowWriteTagName is not null then 1 end )  as actualCnt  from dbo.operatingLimits 

drop index fIX_SalesOrderDetail_UnitPrice on dbo.operatingLimits

CREATE NONCLUSTERED INDEX fIX_SalesOrderDetail_UnitPrice
ON dbo.operatingLimits(OperatingLimit_PK_ID)
WHERE LowWriteTagDataSrcName is not null and LowWriteTagName is not null
GO



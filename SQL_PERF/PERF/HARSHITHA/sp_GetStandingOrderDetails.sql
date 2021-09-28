DECLARE @StartTime DATETIME,@EndTime DATETIME
SELECT @StartTime = GETDATE()

SET STATISTICS IO ON


declare @standingorderpk_id_string nvarchar (100) = '3fca1f5f-3ba5-4687-83d4-c664d477f959'
exec sp_GetStandingOrderDetails @StandingOrder_PK_ID=@standingorderpk_id_string,@dolockBy=N'L4-DC\mesuser1',@queriedBy=N'L4-DC\mesuser1'


--exec [sp_GetStandingOrderDetails_Test] @StandingOrder_PK_ID=N'3fca1f5f-3ba5-4687-83d4-c664d477f959',@dolockBy=N'L4-DC\mesuser1',@queriedBy=N'L4-DC\mesuser1'


SET STATISTICS IO OFF

SELECT @EndTime = GETDATE()
SELECT CONVERT(VARCHAR(12), @EndTime - @StartTime, 114) as Total_Elapsed_Time
GO

/*
Missing Index Details from SQLQuery25.sql - WIN16DBRIL\MES.Honeywell.MES.Operations.DataModel.OperationsDB (L4-DC\mesuser1 (67))
The Query Processor estimates that implementing the following index could improve the query cost by 98.8202%.
*/

/*
USE [Honeywell.MES.Operations.DataModel.OperationsDB]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [dbo].[StandingOrdersHistory] ([ActualEndTime])
INCLUDE ([StandingOrder_PK_ID])
GO
*/

DROP  INDEX [IX_StandingOrdersHistory_ActualEndTime_Arc_PI] on [dbo].[StandingOrdersHistory]
GO
CREATE NONCLUSTERED INDEX [IX_StandingOrdersHistory_ActualEndTime_Arc_PI]
ON [dbo].[StandingOrdersHistory] ([ActualEndTime])
INCLUDE ([StandingOrder_PK_ID])
GO
--------------------
DROP  INDEX [IX_StandingOrderCommentsHistory_FK_StandingOrder_StandingOrder_PK_ID_Arc_PI] on [dbo].[StandingOrderCommentsHistory]
GO
CREATE NONCLUSTERED INDEX [IX_StandingOrderCommentsHistory_FK_StandingOrder_StandingOrder_PK_ID_Arc_PI]
ON [dbo].[StandingOrderCommentsHistory] ([StandingOrder_StandingOrder_PK_ID])
GO
-----------------
DROP INDEX [IX_StandingOrdersActionHistoryHistory_FK_StandingOrder_StandingOrder_PK_ID_Arc_PI]
ON [dbo].[StandingOrdersActionHistoryHistory] 
GO 
CREATE NONCLUSTERED INDEX [IX_StandingOrdersActionHistoryHistory_FK_StandingOrder_StandingOrder_PK_ID_Arc_PI]
ON [dbo].[StandingOrdersActionHistoryHistory] ([StandingOrder_StandingOrder_PK_ID])
INCLUDE ([StandingOrdersActionHistoryHistory_PK_ID])
GO
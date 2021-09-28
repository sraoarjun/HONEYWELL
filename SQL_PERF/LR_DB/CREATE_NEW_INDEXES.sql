/*
	Upon creation of the below index , it didn't yeild much improvements , so needs to be evaluated before 
	executing 
*/
DROP INDEX [last_change_datetime_Includes] ON [dbo].[OperatingLimitHighValues_tracking] 
GO
CREATE INDEX [last_change_datetime_Includes] ON [dbo].[OperatingLimitHighValues_tracking] ([last_change_datetime])  INCLUDE ([OperatingLimitHighValue_PK_ID]) ;
GO

--=================================================================================================================

/*
Addding Filtered indexes helps . Evaluate and Check before adding 
*/

DROP INDEX [last_change_datetime_Includes] ON [dbo].[OperatingLimitLowValues_tracking] 
GO

CREATE INDEX [last_change_datetime_Includes] ON [dbo].[OperatingLimitLowValues_tracking] ([last_change_datetime])  INCLUDE ([OperatingLimitLowValue_PK_ID]);
GO

/*
There is good improvement from adding the below index in terms of bringing down the logical reads significantly
-- Already checked in the code build
*/

DROP INDEX [Equipment_PK_ID_Includes] ON [dbo].[Equipment_Variables_Association]
GO
CREATE INDEX [Equipment_PK_ID_Includes] ON [dbo].[Equipment_Variables_Association] ([Equipment_PK_ID])  INCLUDE ([Variable_PK_ID]) 
GO


--=================================================================================================================
DROP INDEX IF EXISTS [last_change_datetime_Includes] ON [dbo].[BoundaryHighValues_tracking]
GO
CREATE INDEX [last_change_datetime_Includes] ON [dbo].[BoundaryHighValues_tracking] ([last_change_datetime])  INCLUDE ([BoundaryHighValue_PK_ID]) 
GO
--=================================================================================================================

DROP INDEX IF EXISTS  [last_change_datetime_Includes] ON [dbo].[BoundaryLowValues_tracking]
GO
CREATE INDEX [last_change_datetime_Includes] ON [dbo].[BoundaryLowValues_tracking] ([last_change_datetime])  INCLUDE ([BoundaryLowValue_PK_ID]) 
GO

--=================================================================================================================

DROP INDEX IF EXISTS ix_last_change_datetime_Includes on [dbo].[OperatingLimitAimValues_tracking]
GO

CREATE NONCLUSTERED INDEX ix_last_change_datetime_Includes
 ON [dbo].[OperatingLimitAimValues_tracking] ([last_change_datetime])
INCLUDE ([OperatingLimitAimValue_PK_ID]) ;
GO
--=================================================================================================================

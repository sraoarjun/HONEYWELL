set statistics io , time on

				DECLARE @StandingOrderLockingTimeout int=0;
				DECLARE @ReleaseTime DATETIME;
				SELECT @StandingOrderLockingTimeout = CAST(LU.[Value] AS INT) From Lookups LU
				INNER JOIN LookupTypes LUT ON LUT.LookupType_PK_ID = LU.LookupType_PK_ID
				WHERE LTRIM(UPPER(LU.Name)) = 'STANDINGORDERLOCKINGTIMEOUT' AND LTRIM(LUT.Name) = 'Standing Order Time Parameters' ;
				--select @StandingOrderLockingTimeout as standingOrderLockingTimeout
				UPDATE standingOrders 
				SET LockedBy = NULL, LockedTime = NULL 
				WHERE (DATEADD(mi, @StandingOrderLockingTimeout,LockedTime)  <= GETUTCDATE());
				GO

				/*
					8:24 PM <= 8:02 (False)
					8:24 <= 8:15 (False)
					8:24 <= 8:20 (False)
					8:24 <= 8:30 (True) -- sets the Values to null 
				*/

set statistics io , time off

				set statistics io , time on

				DECLARE @StandingOrderLockingTimeout int=0;
				DECLARE @ReleaseTime DATETIME;
				SELECT @StandingOrderLockingTimeout = CAST(LU.[Value] AS INT) From Lookups LU
				INNER JOIN LookupTypes LUT ON LUT.LookupType_PK_ID = LU.LookupType_PK_ID
				WHERE LTRIM(UPPER(LU.Name)) = 'STANDINGORDERLOCKINGTIMEOUT' AND LTRIM(LUT.Name) = 'Standing Order Time Parameters' ;
				--select @StandingOrderLockingTimeout as standingOrderLockingTimeout
				UPDATE standingOrders 
				SET LockedBy = NULL, LockedTime = NULL 
				--WHERE (DATEADD(mi, @StandingOrderLockingTimeout,LockedTime)  <= GETUTCDATE());
				WHERE LockedTime <= DATEADD(mi,-@StandingOrderLockingTimeout,GETUTCDATE());
				
				/*
					8:00 <= 8:02-24 ===>	7:38	(False)
					8:00 <= 8:15 -24 ===>	7:51	(False)
					8:00 <= 8:20 - 24 ===>	7:56	(False)
					8:00 <= 8:30 -24  ===>  8:06	(True) -- sets the Values to null 
				*/

				set statistics io , time off
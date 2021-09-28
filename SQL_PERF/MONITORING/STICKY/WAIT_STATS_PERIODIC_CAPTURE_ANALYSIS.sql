USE [DBATools]
GO


SELECT * FROM   
(
    SELECT 
	Wait_S,
	collection_id,
	WaitType
         FROM 
        dbo.WaitStats p
        
) t 
PIVOT(
    MIN(Wait_S) 
    FOR WaitType IN (
	
			[ASYNC_NETWORK_IO],
			[CXPACKET],
			[IO_COMPLETION],
			[PAGELATCH_EX],
			[WRITELOG]

        )
) AS pivot_table;
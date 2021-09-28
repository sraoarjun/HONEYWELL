set statistics io , time on
	exec [dbo].[ChangeNotes_selectchanges] 50566320,3,0,1
set statistics io , time off
GO



ALTER PROCEDURE [dbo].[ChangeNotes_selectchanges] @sync_min_timestamp BIGINT
	,@sync_scope_local_id INT
	,@sync_scope_restore_count INT
	,@sync_update_peer_key INT
AS
BEGIN
	DECLARE @LRsToSync AS TABLE (SyncLRID UNIQUEIDENTIFIER)

	--if mutual exclusion codition is recorded than this query is executing in primary LR
	IF EXISTS (
			SELECT 1
			FROM LRs
			WHERE [IsSynchronizing] = 1
			)
	BEGIN
		-- Select primary LR and Secondary LR which is currently invoking sync
		INSERT INTO @LRsToSync
		SELECT LR_PK_ID
		FROM LRs
		WHERE [IsSynchronizing] = 1
			OR [Primary] = 1
	END
	ELSE
	BEGIN
		-- Primary LR is invoking sync, select primary LR and This secondary LR
		INSERT INTO @LRsToSync
		SELECT LR_PK_ID
		FROM LRs
		WHERE [Primary] = 1
			OR LR_PK_ID IN (
				SELECT LR_PK_ID
				FROM ThisLR
				)
	END

	CREATE TABLE #MasterChangeNote (
		ChangeNote_PK_ID UNIQUEIDENTIFIER
		,LR_PK_ID UNIQUEIDENTIFIER
		)

	INSERT INTO #MasterChangeNote (
		ChangeNote_PK_ID
		,LR_PK_ID
		)
	SELECT ChangeNote_PK_ID
		,LR_PK_ID
	FROM dbo.OperatingLimitHighValues
	
	UNION
	
	SELECT ChangeNote_PK_ID
		,LR_PK_ID
	FROM OperatingLimitLowValues
	
	UNION
	
	SELECT ChangeNote_PK_ID
		,LR_PK_ID
	FROM OperatingLimitAimValues
	
	UNION
	
	SELECT changenote_PK_ID
		,LR_PK_ID
	FROM BoundaryHighValues
	
	UNION
	
	SELECT ChangeNote_PK_ID
		,LR_PK_ID
	FROM BoundaryLowValues
	
	UNION
	
	SELECT ChangeNote_PK_ID
		,LR_PK_ID
	FROM ConstraintHighValues
	
	UNION
	
	SELECT ChangeNote_PK_ID
		,LR_PK_ID
	FROM constraintLowValues

	SELECT [side].[ChangeNote_PK_ID]
		,[base].[AppRef]
		,[base].[MOCRef]
		,[base].[URL]
		,[base].[Note]
		,[base].[ChangeDate]
		,[base].[ChangedBy]
		,[base].[Mode_PK_ID]
		,[side].[sync_row_is_tombstone]
		,[side].[local_update_peer_timestamp] AS sync_row_timestamp
		,CASE 
			WHEN (
					[side].[update_scope_local_id] IS NULL
					OR [side].[update_scope_local_id] <> @sync_scope_local_id
					)
				THEN COALESCE([side].[restore_timestamp], [side].[local_update_peer_timestamp])
			ELSE [side].[scope_update_peer_timestamp]
			END AS sync_update_peer_time_stamp
		,CASE 
			WHEN (
					[side].[update_scope_local_id] IS NULL
					OR [side].[update_scope_local_id] <> @sync_scope_local_id
					)
				THEN CASE 
						WHEN ([side].[local_update_peer_key] > @sync_scope_restore_count)
							THEN @sync_scope_restore_count
						ELSE [side].[local_update_peer_key]
						END
			ELSE [side].[scope_update_peer_key]
			END AS sync_update_peer_key
		,CASE 
			WHEN (
					[side].[create_scope_local_id] IS NULL
					OR [side].[create_scope_local_id] <> @sync_scope_local_id
					)
				THEN [side].[local_create_peer_timestamp]
			ELSE [side].[scope_create_peer_timestamp]
			END AS sync_create_peer_timestamp
		,CASE 
			WHEN (
					[side].[create_scope_local_id] IS NULL
					OR [side].[create_scope_local_id] <> @sync_scope_local_id
					)
				THEN CASE 
						WHEN ([side].[local_create_peer_key] > @sync_scope_restore_count)
							THEN @sync_scope_restore_count
						ELSE [side].[local_create_peer_key]
						END
			ELSE [side].[scope_create_peer_key]
			END AS sync_create_peer_key
	FROM [ChangeNotes] [base]
	RIGHT JOIN [ChangeNotes_tracking] [side] ON [base].[ChangeNote_PK_ID] = [side].[ChangeNote_PK_ID]
	LEFT OUTER JOIN #MasterChangeNote m ON m.ChangeNote_PK_ID = [side].[ChangeNote_PK_ID]
	WHERE (
			[side].[update_scope_local_id] IS NULL
			OR [side].[update_scope_local_id] <> @sync_scope_local_id
			OR (
				[side].[update_scope_local_id] = @sync_scope_local_id
				AND [side].[scope_update_peer_key] <> @sync_update_peer_key
				)
			)
		--AND [side].[local_update_peer_timestamp] > @sync_min_timestamp
		AND [side].[local_update_peer_timestamp] > CAST(@sync_min_timestamp as timestamp)
		AND (
			m.LR_PK_ID IS NULL
			OR m.LR_PK_ID IN (
				SELECT SyncLRID
				FROM @LRsToSync
				)
			)
END

DROP TABLE #MasterChangeNote

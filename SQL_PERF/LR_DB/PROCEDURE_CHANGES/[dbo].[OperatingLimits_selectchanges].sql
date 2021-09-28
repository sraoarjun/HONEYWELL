set statistics io, time on
	--exec [dbo].[OperatingLimits_selectchanges] 50545868,3,0,1
	exec [dbo].[OperatingLimits_selectchanges] 50570036,3,0,1
set statistics io, time off


ALTER PROCEDURE [dbo].[OperatingLimits_selectchanges] @sync_min_timestamp BIGINT
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

	SELECT [side].[OperatingLimit_PK_ID]
		,[base].[HighValue]
		,[base].[AimValue]
		,[base].[LowValue]
		,[base].[IsHighConsistent]
		,[base].[IsAimConsistent]
		,[base].[IsLowConsistent]
		,[base].[Comment]
		,[base].[HighEffectiveTime]
		,[base].[AimEffectiveTime]
		,[base].[LowEffectiveTime]
		,[base].[HighStatus]
		,[base].[AimStatus]
		,[base].[LowStatus]
		,[base].[HighReason]
		,[base].[AimReason]
		,[base].[LowReason]
		,[base].[HighConsequence]
		,[base].[AimConsequence]
		,[base].[LowConsequence]
		,[base].[HighAction]
		,[base].[AimAction]
		,[base].[LowAction]
		,[base].[Application_PK_ID]
		,[base].[BoundaryType_PK_ID]
		,[base].[AimChangeNote_PK_ID]
		,[base].[HighChangeNote_PK_ID]
		,[base].[LowChangeNote_PK_ID]
		,[base].[Type_PK_ID]
		,[base].[Variable_PK_ID]
		,[base].[HighUOM]
		,[base].[AimUOM]
		,[base].[LowUOM]
		,[base].[HighOutsideAction]
		,[base].[AimOutsideAction]
		,[base].[LowOutsideAction]
		,[base].[HighWriteTagName]
		,[base].[HighWriteTagDataSrcName]
		,[base].[LowWriteTagName]
		,[base].[LowWriteTagDataSrcName]
		,[base].[AimWriteTagName]
		,[base].[AimWriteTagDataSrcName]
		,[base].[UseDefaultBoundary]
		,[base].[LR_PK_ID]
		,[base].[IsHighConfigured]
		,[base].[IsAimConfigured]
		,[base].[IsLowConfigured]
		,[side].[sync_row_is_tombstone]
		,[side].[local_update_peer_timestamp] AS sync_row_timestamp
		,CASE 
			WHEN (
					[side].[update_scope_local_id] IS NULL
					OR [side].[update_scope_local_id] <> @sync_scope_local_id
					)
				THEN COALESCE([side].[restore_timestamp], [side].[local_update_peer_timestamp])
			ELSE [side].[scope_update_peer_timestamp]
			END AS sync_update_peer_timestamp
		,CASE 
			WHEN (
					[side].[update_scope_local_id] IS NULL
					OR [side].[update_scope_local_id] <> @sync_scope_local_id
					)
				THEN CASE 
						WHEN ([side].[local_update_peer_key] > @sync_scope_restore_count)
							THEN @sync_scope_restore_count
						ELSE [side].[local_update_peer_key]
						END else [side].[scope_update_peer_key]
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
	FROM [OperatingLimits] [base]
	RIGHT JOIN [OperatingLimits_tracking] [side] ON [base].[OperatingLimit_PK_ID] = [side].[OperatingLimit_PK_ID]
	WHERE (
			[side].[update_scope_local_id] IS NULL
			OR [side].[update_scope_local_id] <> @sync_scope_local_id
			OR (
				[side].[update_scope_local_id] = @sync_scope_local_id
				AND [side].[scope_update_peer_key] <> @sync_update_peer_key
				)
			)
		AND [side].[local_update_peer_timestamp] > @sync_min_timestamp
		--AND [side].[local_update_peer_timestamp] > cast(@sync_min_timestamp as timestamp)
		
		AND (
			[base].LR_PK_ID IS NULL
			OR [base].LR_PK_ID IN (
				SELECT SyncLRID
				FROM @LRsToSync
				)
			)
END
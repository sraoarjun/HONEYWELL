CREATE PROCEDURE [dbo].[sp_GetStandingOrderDetails] @StandingOrder_PK_ID NVARCHAR(100) = NULL
	,@dolockBy NVARCHAR(250) = NULL,@queriedBy NVARCHAR(250) = NULL
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;
	
	DECLARE @StandingOrder_PK_ID_UID Uniqueidentifier =  @StandingOrder_PK_ID

	DECLARE @ProcessID UNIQUEIDENTIFIER;
	SET @ProcessID = (SELECT [ProcessTypeId] FROM [ProcessTypes]	WHERE LOWER(LTRIM(ProcessTypeName)) = 'standingorder'	)
	IF EXISTS(SELECT StandingOrder_PK_ID FROM StandingOrders WHERE StandingOrder_PK_ID=@StandingOrder_PK_ID_UID)
	BEGIN
	IF EXISTS (
			SELECT st.NAME
			FROM StandingOrders I
			INNER JOIN States St ON I.State_StateId = St.StateId
			WHERE StandingOrder_PK_ID  = @StandingOrder_PK_ID_UID 
				AND (
					st.NAME = 'DRAFT'
					AND st.ProcessType_ProcessTypeId = @ProcessID
					)
			)
	BEGIN
		-- Implementation for lock
		DECLARE @LockedBy NVARCHAR(250);
		DECLARE @LockedTime DATETIME;
		SELECT @LockedBy = StandingOrders.LockedBy
			,@LockedTime = LockedTime
		FROM StandingOrders
		WHERE StandingOrder_PK_ID  = @StandingOrder_PK_ID_UID 
		IF (
				@dolockBy IS NOT NULL
				OR @dolockBy != ''
				)
		BEGIN
			---Nothing to do
			--SELECT 1
			IF (
					@LockedBy IS NULL
					OR @LockedBy = ''
					)
			BEGIN
				UPDATE StandingOrders
				SET LockedBy = @dolockBy
					,LockedTime = GETUTCDATE()
				WHERE StandingOrder_PK_ID  = @StandingOrder_PK_ID_UID 
			END
			ELSE
			BEGIN
				-- Need to do the logic for release or extend
				IF (@dolockBy != @LockedBy)
				BEGIN
					DECLARE @StandingOrderLockingTimeout INT = 0;
					DECLARE @ReleaseTime DATETIME;
					SELECT @StandingOrderLockingTimeout = CAST(LU.[Value] AS INT)
					FROM Lookups LU
					INNER JOIN LookupTypes LUT ON LUT.LookupType_PK_ID = LU.LookupType_PK_ID
					WHERE LU.NAME = 'STANDINGORDERLOCKINGTIMEOUT'
					AND LUT.NAME  = 'Standing Order Time Parameters';
					SET @ReleaseTime = DATEADD(mi, @StandingOrderLockingTimeout, @LockedTime);
					
					IF (@ReleaseTime <= GETUTCDATE())
					BEGIN
						UPDATE StandingOrders
						SET LockedBy = @dolockBy
							,LockedTime = GETUTCDATE()
						WHERE StandingOrder_PK_ID = @StandingOrder_PK_ID_UID 

					END
				END
			END
		END
		SELECT @LockedBy = StandingOrders.LockedBy
			,@LockedTime = LockedTime
		FROM StandingOrders
		WHERE StandingOrder_PK_ID = @StandingOrder_PK_ID_UID 
	END
	---end Implementation for lock
	SELECT DISTINCT I.StandingOrder_PK_ID
		,I.NAME
		,I.TemplateName
		,I.Description
		,I.PlanStartTime AS PlanStartTime
		,I.PlanEndTime AS PlanEndTime
		,I.CreatedBy
		,I.CreatedTime
		,I.IsAuthorizationNeeded
		,I.LastmodifiedBy
		,I.LastmodifiedTime
		,I.PlanNote
		,I.PlanNoteWithoutHTML
		,I.ScheduledStartTime
		,I.ScheduledEndTime
		,I.ActualStartTime
		,I.ActualEndTime
		,A.NAME AS Asset
		,A.Description AS AssetDescription
		,A.EquipID as AssetID
		,icat.NAME AS Category
		,st.NAME AS STATUS
		,st.DisplayName AS StatusDisplayName
		,icat.DisplayName AS CategoryDisplayName
		,(SELECT P.ProductName	FROM StandingOrderProducts P	WHERE P.Product_PK_ID = I.StandingOrderProducts_Product_PK_ID	) AS ProductName
		,(SELECT P.DisplayName	FROM StandingOrderProducts P	WHERE P.Product_PK_ID = I.StandingOrderProducts_Product_PK_ID	) AS ProductDisplayName
		,CASE 
			WHEN I.lockedBy = @dolockBy	THEN NULL
			ELSE I.LockedBy
			END AS LockedBy
		,I.LockedTime AS LockedTime
		,I.IsScheduleEnabled 
		,I.IsImmediateActivationEnabled 
		,I.Process_ProcessId as ProcessID
		,I.State_StateId   as StateID
		,A.DisplayName AS AssetDisplayName
		, (select count(1) from StandingOrderComments IComm,StandingOrderCommentTypes ICType where IComm.StandingOrder_StandingOrder_PK_ID = I.StandingOrder_PK_ID and ICType.Name='Acknowledge' and ICType.StandingOrderCommentType_PK_ID = IComm.StandingOrderCommentType_StandingOrderCommentType_PK_ID and (I.ActualStartTime is not null and IComm.CreatedTime >I.ActualStartTime)) AS ActiveAckCount
		, (select count(1) from StandingOrderComments IComm,StandingOrderCommentTypes ICType where IComm.StandingOrder_StandingOrder_PK_ID = I.StandingOrder_PK_ID and ICType.Name='Acknowledge' and ICType.StandingOrderCommentType_PK_ID = IComm.StandingOrderCommentType_StandingOrderCommentType_PK_ID and (I.ActualStartTime is not null and IComm.CreatedTime >I.ActualStartTime and IComm.CreatedBy=@queriedBy)) AS UserActiveAck
		,I.AssignToChildAssets
	FROM StandingOrders I
	INNER JOIN Assets A ON I.Asset_Asset_PK_ID = A.Asset_PK_ID
	INNER JOIN StandingOrderCategories Icat ON I.StandingOrderCategory_StandingOrderCategory_PK_ID = icat.StandingOrderCategory_PK_ID
	INNER JOIN States St ON (I.State_StateId = St.StateId AND St.ProcessType_ProcessTypeId = @ProcessID	)
	WHERE StandingOrder_PK_ID = @StandingOrder_PK_ID_UID 
	
	SELECT Comment
		,CT.NAME AS CommentType
	FROM StandingOrderComments C
	JOIN StandingOrders I ON C.StandingOrder_StandingOrder_PK_ID = I.StandingOrder_PK_ID
	JOIN StandingOrderCommentTypes CT ON CT.StandingOrderCommentType_PK_ID = C.StandingOrderCommentType_StandingOrderCommentType_PK_ID
	WHERE C.StandingOrder_StandingOrder_PK_ID = @StandingOrder_PK_ID_UID 
	SELECT [FileName]
		,DisplayName
	FROM standingOrderAttachments AT
	JOIN StandingOrders I ON AT.StandingOrder_StandingOrder_PK_ID = I.StandingOrder_PK_ID
	WHERE AT.StandingOrder_StandingOrder_PK_ID = @StandingOrder_PK_ID_UID 
	SELECT Link
		,DisplayName
	FROM StandingOrderLinks IL
	JOIN StandingOrders I ON IL.StandingOrder_StandingOrder_PK_ID = I.StandingOrder_PK_ID
	WHERE IL.StandingOrder_StandingOrder_PK_ID = @StandingOrder_PK_ID_UID 
	SELECT 
		P.UserPrincipal,
		P.DisplayName,
		P.EmailID,
		P.Name
	FROM PersonDetails P
	INNER JOIN StandingOrderAssignees IA ON IA.PersonDetail_PersonDetail_Pk_Id = P.PersonDetail_Pk_Id 
	AND IA.StandingOrder_StandingOrder_PK_ID = @StandingOrder_PK_ID_UID 
	--Fetch and return the Group Assignees for this StandingOrder
	SELECT
		G.Name,
		G.ScopeName
	FROM GroupDetails G
	INNER JOIN StandingOrderAssignees IA ON IA.GroupDetail_GroupDetail_PK_Id = G.GroupDetail_PK_Id
	AND IA.StandingOrder_StandingOrder_PK_ID  = @StandingOrder_PK_ID_UID
	END
	ELSE 
		BEGIN
		SELECT DISTINCT I.StandingOrder_PK_ID
		,I.NAME
		,I.TemplateName
		,I.Description
		,I.PlanStartTime AS PlanStartTime
		,I.PlanEndTime AS PlanEndTime
		,I.CreatedBy
		,I.CreatedTime
		,I.IsAuthorizationNeeded
		,I.LastmodifiedBy
		,I.LastmodifiedTime
		,I.PlanNote
		,I.PlanNoteWithoutHTML
		,I.ScheduledStartTime
		,I.ScheduledEndTime
		,I.ActualStartTime
		,I.ActualEndTime
		,A.NAME AS Asset
		,A.Description AS AssetDescription
		,A.EquipID as AssetID
		,icat.NAME AS Category
		,st.NAME AS STATUS
		,st.DisplayName AS StatusDisplayName
		,icat.DisplayName AS CategoryDisplayName
		,(SELECT P.ProductName	FROM StandingOrderProducts P	WHERE P.Product_PK_ID = I.StandingOrderProducts_Product_PK_ID	) AS ProductName
		,(SELECT P.DisplayName	FROM StandingOrderProducts P	WHERE P.Product_PK_ID = I.StandingOrderProducts_Product_PK_ID	) AS ProductDisplayName
		,CASE 
			WHEN I.lockedBy = @dolockBy
				THEN NULL
			ELSE I.LockedBy
			END AS LockedBy
		,I.LockedTime AS LockedTime
		,I.IsScheduleEnabled 
		,I.IsImmediateActivationEnabled 
		,A.DisplayName AS AssetDisplayName
		,I.Process_ProcessId as ProcessID
		,I.State_StateId   as StateID
		,I.AssignToChildAssets
	FROM StandingOrdersHistory I
	INNER JOIN Assets A ON I.Asset_Asset_PK_ID = A.Asset_PK_ID
	INNER JOIN StandingOrderCategories Icat ON I.StandingOrderCategory_StandingOrderCategory_PK_ID = icat.StandingOrderCategory_PK_ID
	INNER JOIN States St ON (I.State_StateId = St.StateId	AND St.ProcessType_ProcessTypeId = @ProcessID	)
	WHERE StandingOrder_PK_ID =@StandingOrder_PK_ID_UID 
		
	SELECT Comment
		,CT.NAME AS CommentType
	FROM StandingOrderCommentsHistory C
	JOIN StandingOrdersHistory I ON C.StandingOrder_StandingOrder_PK_ID = I.StandingOrder_PK_ID
	JOIN StandingOrderCommentTypes CT ON CT.StandingOrderCommentType_PK_ID = C.StandingOrderCommentType_StandingOrderCommentTypeId
	WHERE C.StandingOrder_StandingOrder_PK_ID = @StandingOrder_PK_ID_UID
	SELECT [FileName]
		,DisplayName
	FROM StandingOrderAttachmentsHistory AT
	JOIN StandingOrdersHistory I ON AT.StandingOrder_StandingOrder_PK_ID = I.StandingOrder_PK_ID
	WHERE AT.StandingOrder_StandingOrder_PK_ID = @StandingOrder_PK_ID_UID
	SELECT Link
		,DisplayName
	FROM StandingOrderLinksHistory IL
	JOIN StandingOrdersHistory I ON IL.StandingOrder_StandingOrder_PK_ID = I.StandingOrder_PK_ID
	WHERE IL.StandingOrder_StandingOrder_PK_ID = @StandingOrder_PK_ID_UID
	SELECT 
		P.UserPrincipal,
		P.DisplayName,
		P.EmailID,
		P.Name
	FROM PersonDetails P
	INNER JOIN StandingOrderAssigneesHistory IA ON IA.PersonDetail_PersonDetail_Pk_Id = P.PersonDetail_Pk_Id 
	AND IA.StandingOrder_StandingOrder_PK_ID = @StandingOrder_PK_ID_UID 
	--Fetch and return the Group Assignees for this instruction
	SELECT
		G.Name,
		G.ScopeName
	FROM GroupDetails G
	INNER JOIN StandingOrderAssigneesHistory IA ON IA.GroupDetail_GroupDetail_PK_Id = G.GroupDetail_PK_Id
	AND IA.StandingOrder_StandingOrder_PK_ID  = @StandingOrder_PK_ID_UID 
		END
	--Fetch and return the Person Assignees for this instruction	
END



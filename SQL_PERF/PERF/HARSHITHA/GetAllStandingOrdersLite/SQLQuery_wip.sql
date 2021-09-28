ALTER PROCEDURE [dbo].[sp_GetAllStandingOrdersLite]
  @tblStandingOrderAssets				TypeStandingOrderAssets READONLY,
  @tblStandingOrderParentAssets			TypeStandingOrderAssets READONLY,
  @tblStandingOrderAssetsWithHigherPerm	TypeStandingOrderAssets READONLY,  
  @tblStandingOrderCategories				TypeStandingOrderCategories READONLY,
  @tblStandingOrderStatus					TypeStandingOrderStatus READONLY,
  @tblStandingOrderProduct				TypeStandingOrderProducts READONLY,
  @tblUserGroup							TypeGroupAssigneesSO READONLY,
  @StartTime nvarchar(50) = NULL,
  @EndTime   nvarchar(50)  = NULL,  
  @PageNumber INT = Null,
  @PageSize INT = Null,
  @CalledUser nvarchar(250) = null,
  @isFilterOverDue BIT = 0,
  @NameFilter nvarchar(300) = null,
  @NoOfComments int,
  @SortTimeOfActivity varchar(100)=null	
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	SET NOCOUNT ON;
		
	
	DECLARE @assetCount as INT
	DECLARE @categoryCount as INT
	DECLARE @statusCount as INT
	DECLARE @ProductCount as INT
	DECLARE @PageVariable INT
	DECLARE @insertIntoTempSOLiteFinalListQry NVARCHAR(MAX);
	DECLARE @ProcessID UNIQUEIDENTIFIER;
	Declare @IsNameFilterDefined bit 
	if @SortTimeOfActivity is null
		set @SortTimeOfActivity = 'TimeOfActivity desc';
	Else if @SortTimeOfActivity = 'desc'
		set @SortTimeOfActivity = 'TimeOfActivity desc';
	Else 
		set @SortTimeOfActivity = 'TimeOfActivity asc';
	--Check Name filter is defined or not
	IF ((@NameFilter is Null) OR (@NameFilter is not Null and @NameFilter = '' ))	
	   set @IsNameFilterDefined = 0
	Else
		set @IsNameFilterDefined = 1
	 
  
	SET @assetCount = (SELECT COUNT(1) FROM @tblStandingOrderAssets)   
	SET @categoryCount = (SELECT COUNT(1) FROM @tblStandingOrderCategories)
	SET @statusCount = (SELECT COUNT(1) FROM @tblStandingOrderStatus)
	SET @ProductCount = (SELECT COUNT(1) FROM @tblStandingOrderProduct)    
	
	SET @ProcessID = (SELECT [ProcessTypeId] FROM [ProcessTypes] WHERE LOWER(LTRIM(ProcessTypeName)) = 'standingorder')
	-- invalid argument handling setting defaults
	if  @NoOfComments < 0
	Begin 
		set @NoOfComments = 5
	End
	if  @PageNumber <= 0
	Begin 
		set @PageNumber = 1
	End
	if  @PageSize <= 0
	Begin 
		set @PageSize = 5
	End
	IF( @assetCount > 0)
		BEGIN
			DECLARE @StatusDateApply TABLE
				(
				SNo INT IDENTITY(1,1),  
				StatusName  nvarchar(100),
				StatusID varchar(40),    --  StatusID UNIQUEIDENTIFIER,
				Qry nvarchar(max)
				);
			DECLARE @StateID varchar(40);
			DECLARE @MultiStateWhere nvarchar(max);
			DECLARE @LookAheadTime int=0;
			DECLARE @LookBackTime int=0;
			DECLARE @CalculatedPlanEndTime varchar(50);
			DECLARE @CalculatedPlanStartTime varchar(50);
			CREATE TABLE #TempSOLiteList (
			    [StandingOrder_PK_ID] [uniqueidentifier] NOT NULL,
				[Name] [nvarchar](max) Not NULL,
				[PlanStartTime] [datetime] not NULL,
				[PlanEndTime] [datetime] NULL,
				[IsAuthorizationNeeded] [bit] not null,
				[LastmodifiedBy] [nvarchar](max) Not NULL,
				[PlanNote] [nvarchar](max) NULL,
				[ActualStartTime] [datetime] NULL,
				[ActualEndTime] [datetime] NULL,
				[Asset] [nvarchar](max) NULL,
				[AssetDisplayName] [nvarchar](max) NULL,
				[Category] [nvarchar](max) NULL,
				[CategoryDisplayName] [nvarchar](max) NULL,
				[Status] [nvarchar](max) NULL,
				[StatusDisplayName] [nvarchar](max) NULL,
				[LockedBy] [nvarchar](max) NULL,				
				[TotalRowCount] [int] not NULL,	
				[State_StateId] [uniqueidentifier] not NULL,
				[Process_ProcessId] [uniqueidentifier] not NULL,
				[AssignToChildAssets] [bit] not Null,
				[IsHistory] Bit not null
				
			)	
			
			CREATE TABLE #TempLiteGroupDetails
			(
				[StandingOrder_PK_ID] [uniqueidentifier] Not Null,
				[Name] [nvarchar](max)  NULL,
				[ScopeName] [nvarchar](max)  NULL
			)			
			CREATE TABLE #TempLitePersonDetails
			(				
				[StandingOrder_PK_ID] [uniqueidentifier] Not Null,
				[Name] [nvarchar](max) NULL,
				[DisplayName] [nvarchar](max)  NULL,
				[EmailID] [nvarchar](max) NULL,				
				[UserPrincipal] [nvarchar](max) NULL
			)
			CREATE TABLE #TemptblStatusLite
			(
				SNo INT IDENTITY(1,1),  
				StatusName  nvarchar(100),
			);
			CREATE TABLE #TempLiteSOComments
			(				
				[StandingOrder_PK_ID] [uniqueidentifier] Not Null,
				[StandingOrderComment_PK_ID] [uniqueidentifier] Not Null,
				[Comment] [nvarchar](max) NULL,
				[CreatedBy] [nvarchar](max)  NULL,
				[ActionTime] DateTime ,				
				[ActionName] [nvarchar](max) NULL
			)
			declare @AckCommentTypeID [uniqueidentifier]
			declare @NonWorkFlowCommentTypeId  [uniqueidentifier]
			select @AckCommentTypeID = ICType.StandingOrderCommentType_PK_ID
			From StandingOrderCommentTypes ICType
			where ICType.Name='Acknowledge'
			select @NonWorkFlowCommentTypeId = ICType.StandingOrderCommentType_PK_ID
			From StandingOrderCommentTypes ICType
			where ICType.Name='UserComment'
			SELECT [StandingOrder_PK_ID],
					[PlanStartTime],
					[PlanEndTime],
					[IsAuthorizationNeeded], 
					[LastmodifiedBy],
					[PlanNote],
					[Name],
					[ActualStartTime],
					[ActualEndTime],
					[StandingOrderCategory_StandingOrderCategory_PK_ID],
					[State_StateId],
					[Process_ProcessId],
					[Asset_Asset_PK_ID],
					[StandingOrderProducts_Product_PK_ID],
					[LockedBy],
					[AssignToChildAssets],
					0 as IsHistory,
					[PlanStartTime] as [TimeOfActivity]
					into #TempStandingOrdersLite 
			FROM  [dbo].[StandingOrders] 
			WHERE 1=2
			
			SELECT * into #TemptbAssetsLite   FROM  @tblStandingOrderAssets
			SELECT * into #TemptblParentAssetsLite    FROM  @tblStandingOrderParentAssets
			SELECT * INTO #TemptblAssetsWithHigherPermLite    FROM @tblStandingOrderAssetsWithHigherPerm
			
				CREATE NONCLUSTERED INDEX [IX_#TemptblAssetsWithHigherPermLite]
				ON #TemptblAssetsWithHigherPermLite ([AssetName])
   
			SELECT * into #TemptblCategoryLite   FROM  @tblStandingOrderCategories
			SELECT * into #TemptblProductLite   FROM @tblStandingOrderProduct where 1=2
			SELECT * INTO #TemptblUserGroupsLite   FROM @tblUserGroup
     
	    
			IF(@statusCount <> 0)
				INSERT INTO #TemptblStatusLite SELECT A.StatusName FROM @tblStandingOrderStatus A INNER JOIN States B WITH(NOLOCK) ON B.ProcessType_ProcessTypeId = @ProcessID AND A.StatusName = B.Name
			ELSE
				INSERT INTO #TemptblStatusLite SELECT Name FROM States WITH(NOLOCK) WHERE ProcessType_ProcessTypeId = @ProcessID
			
			IF (@ProductCount <> 0)
				INSERT INTO #TemptblProductLite SELECT ProductName FROM @tblStandingOrderProduct
			ELSE
				INSERT INTO #TemptblProductLite SELECT ProductName FROM StandingOrderProducts 
 
    
			SELECT @LookAheadTime = CAST(LU.[Value] AS INT) From Lookups LU WITH(NOLOCK)
			INNER JOIN LookupTypes LUT WITH(NOLOCK) ON LUT.LookupType_PK_ID = LU.LookupType_PK_ID
			WHERE LTRIM(UPPER(LU.Name)) = 'LOOKAHEADTIME' AND LTRIM(LUT.Name) = 'Standing Order Time Parameters' ;
			
			SELECT @LookBackTime = CAST(LU.[Value] AS INT) From Lookups LU WITH(NOLOCK)
			INNER JOIN LookupTypes LUT WITH(NOLOCK) ON LUT.LookupType_PK_ID = LU.LookupType_PK_ID
			WHERE LTRIM(UPPER(LU.Name)) = 'LOOKBACKTIME' AND LTRIM(LUT.Name) = 'Standing Order Time Parameters' ;
			
			IF ISNULL(@LookAheadTime,1) = 1
				SET @LookAheadTime =0;
			IF ISNULL(@LookBackTime,1) = 1
				SET @LookAheadTime =0;
			SET @CalculatedPlanStartTime = DATEADD(hh,-@LookBackTime,@StartTime);
			SET @CalculatedPlanEndTime = DATEADD(hh, @LookAheadTime,@EndTime);
					
			
			SET @StateID= (SELECT StateID FROM States st WITH(NOLOCK) WHERE st.Name = 'DRAFT' AND st.ProcessType_ProcessTypeId = @ProcessID);
			SET @MultiStateWhere = ' 
			((CAST( I.State_StateID AS varchar(100))  =  CAST('''+ @StateID +''' AS varchar(100)) 
			) AND  ((CAST(I.PlanStartTime AS DateTime) <= CAST('''+ @CalculatedPlanEndTime +''' AS DateTime)) 
			AND  (ISNULL(I.PlanEndTime,1) = 1 OR CAST(I.PlanEndTime AS DateTime) >= CAST('''+ @CalculatedPlanStartTime +''' AS DateTime)))
			)'
			INSERT INTO @StatusDateApply VALUES('DRAFT', @StateID , @MultiStateWhere)
 
			SET @StateID= (SELECT StateID FROM States st WITH(NOLOCK) WHERE st.Name = 'PLANNED' AND st.ProcessType_ProcessTypeId = @ProcessID);
			SET @MultiStateWhere = ' 
			((CAST( I.State_StateID AS varchar(100))  =  CAST('''+ @StateID +''' AS varchar(100)) 
			) AND  ((CAST(I.PlanStartTime AS DateTime) <= CAST('''+ @CalculatedPlanEndTime +''' AS DateTime)) 
			AND  (ISNULL(I.PlanEndTime,1) = 1 OR CAST(I.PlanEndTime AS DateTime) >= CAST('''+ @CalculatedPlanStartTime +''' AS DateTime)))
			)'
			INSERT INTO @StatusDateApply VALUES('PLANNED', @StateID , @MultiStateWhere)
					   
			SET @StateID= (SELECT StateID FROM States st WITH(NOLOCK) WHERE st.Name = 'APPROVED' AND st.ProcessType_ProcessTypeId = @ProcessID);
			SET @MultiStateWhere = ' 
			((CAST( I.State_StateID AS varchar(100))  =  CAST('''+ @StateID +''' AS varchar(100)) 
			) AND  ((CAST(I.PlanStartTime AS DateTime) <= CAST('''+ @CalculatedPlanEndTime +''' AS DateTime)) 
			AND  (ISNULL(I.PlanEndTime,1) = 1 OR CAST(I.PlanEndTime AS DateTime) >= CAST('''+ @CalculatedPlanStartTime +''' AS DateTime)))
			)'
			INSERT INTO @StatusDateApply VALUES('APPROVED', @StateID , @MultiStateWhere)
			SET @StateID= (SELECT StateID FROM States st WITH(NOLOCK) WHERE st.Name = 'REJECTED' AND st.ProcessType_ProcessTypeId = @ProcessID);
			SET @MultiStateWhere = ' 
			((CAST( I.State_StateID AS varchar(100))  =  CAST('''+ @StateID +''' AS varchar(100)) 
			) AND  ((CAST(I.PlanStartTime AS DateTime) <= CAST('''+ @CalculatedPlanEndTime +''' AS DateTime)) 
			AND  (ISNULL(I.PlanEndTime,1) = 1 OR CAST(I.PlanEndTime AS DateTime) >= CAST('''+ @CalculatedPlanStartTime +''' AS DateTime)))
			)'
			INSERT INTO @StatusDateApply VALUES('REJECTED', @StateID , @MultiStateWhere)
			
			SET @StateID= (SELECT StateID FROM States st WITH(NOLOCK) WHERE st.Name = 'ACTIVATED' AND st.ProcessType_ProcessTypeId = @ProcessID);
			INSERT INTO @StatusDateApply VALUES('ACTIVATED', @StateID ,  '
			(CAST( I.State_StateID AS varchar(100))  =  CAST('''+ @StateID +''' AS varchar(100)) 
			AND (CAST(I.ActualStartTime AS DateTime)<= CAST('''+ @EndTime +''' AS DateTime))) ');
 
 
			SET @StateID= (SELECT StateID FROM States st WITH(NOLOCK) WHERE st.Name = 'COMPLETED' AND st.ProcessType_ProcessTypeId = @ProcessID);
			INSERT INTO @StatusDateApply VALUES('COMPLETED', @StateID ,  '
			(CAST( I.State_StateID AS varchar(100))  =  CAST('''+ @StateID +''' AS varchar(100)) 
			AND ((ISNULL(I.ActualEndTime,1) = 1 OR  CAST(I.ActualEndTime AS DateTime) >= CAST('''+ @StartTime +''' AS DateTime)) AND CAST(I.ActualStartTime AS DateTime) <= CAST('''+ @EndTime +''' AS DateTime)   )) ');
			DECLARE @WHERECondition varchar(max);
			SET @WHERECondition = '';
			
			DECLARE @StartRecord INT;
			SET @StartRecord = 1;
			SELECT @statusCount = COUNT(StatusName) FROM #TemptblStatusLite
			WHILE @StartRecord <= @statusCount 
				BEGIN
					DECLARE @statusname varchar(10);
					SELECT @statusname = UPPER(LTRIM(StatusName)) FROM #TemptblStatusLite WHERE SNo = @StartRecord;
					--SELECT @statusname AS StatusName
					IF @statusname  <> ''
						BEGIN
							DECLARE @Qry nvarchar(max)
							SELECT @Qry = Qry FROM @StatusDateApply WHERE UPPER(StatusName) =RTRIM(LTRIM(@statusname));--RTRIM(LTRIM(@statusname))
												
							IF @WHERECondition = ''
								BEGIN     
									SET   @WHERECondition = ' WHERE (' + @Qry
								END
							ELSE
								BEGIN
									SET    @WHERECondition = @WHERECondition + ' OR ' + @Qry
								END
						END
					SET @StartRecord = @StartRecord + 1
				END
			IF (@WHERECondition <> '' )
				SET @WHERECondition = @WHERECondition + ')';
			
   
			--filter instruction record by PlanStartTime and PlanEndTime
			DECLARE @insertIntoTempSOLiteQry varchar(max);
			set @insertIntoTempSOLiteQry = ''
			DECLARE @StandingOrderHistory varchar(max);
			SET @insertIntoTempSOLiteQry = 'SELECT [StandingOrder_PK_ID],
									[PlanStartTime],
									[PlanEndTime],
									[IsAuthorizationNeeded],
									I.[LastmodifiedBy],   
									[PlanNote],
									I.[Name],
									[ActualStartTime],
									[ActualEndTime],
									[StandingOrderCategory_StandingOrderCategory_PK_ID],
									[State_StateId],
									[Process_ProcessId],
									[Asset_Asset_PK_ID],
									[StandingOrderProducts_Product_PK_ID],
									[LockedBy],
									[AssignToChildAssets],
									0 as [IsHistory],
									CASE 
										WHEN St1.Name = ''Draft'' THEN  I.PlanStartTime 
										WHEN St1.Name = ''Planned'' THEN  I.PlanStartTime 
										WHEN St1.Name = ''Approved'' THEN  I.PlanStartTime 
										WHEN St1.Name = ''Rejected'' THEN  I.PlanStartTime 
										WHEN St1.Name = ''Activated'' THEN  I.ActualStartTime 
										WHEN St1.Name = ''Completed'' THEN  I.ActualStartTime 
									Else I.PlanStartTime
									END as TimeOfActivity
							FROM StandingOrders I WITH(NOLOCK) 
							INNER JOIN States St1 WITH(NOLOCK) 
							ON (I.State_StateId = St1.StateId AND St1.ProcessType_ProcessTypeId = ''' + CAST(@ProcessID AS varchar(100)) + ''')     ' 
							
			IF (@IsNameFilterDefined = 1)
				Begin
					IF @WHERECondition = ''
							BEGIN     
								SET   @WHERECondition = ' WHERE (I.[Name] like ''%'+@NameFilter+'%'')'
							END
						ELSE
							BEGIN
								SET    @WHERECondition = @WHERECondition + 'And (I.[Name] like ''%'+@NameFilter+'%'')'
							END
				End 
  
			IF (@WHERECondition <> '' )
				BEGIN
					SET @insertIntoTempSOLiteQry = @insertIntoTempSOLiteQry +   @WHERECondition    
				END			
			
			set @StandingOrderHistory='SELECT [StandingOrder_PK_ID],
												[PlanStartTime],
												[PlanEndTime],
												[IsAuthorizationNeeded],  
												I.[LastmodifiedBy],   
												[PlanNote],
												I.[Name],
												[ActualStartTime],
												[ActualEndTime],
												[StandingOrderCategory_StandingOrderCategory_PK_ID],
												[State_StateId],
												[Process_ProcessId],
												[Asset_Asset_PK_ID],
												[StandingOrderProducts_Product_PK_ID],
												[LockedBy],
												[AssignToChildAssets],
												1 as [IsHistory],
												CASE 
													WHEN St1.Name = ''Draft'' THEN  I.PlanStartTime 
													WHEN St1.Name = ''Planned'' THEN  I.PlanStartTime 
													WHEN St1.Name = ''Approved'' THEN  I.PlanStartTime 
													WHEN St1.Name = ''Rejected'' THEN  I.PlanStartTime 
													WHEN St1.Name = ''Activated'' THEN  I.ActualStartTime 
													WHEN St1.Name = ''Completed'' THEN  I.ActualStartTime 
												Else I.PlanStartTime
												END as TimeOfActivity
										FROM [dbo].[StandingOrdersHistory] I WITH(NOLOCK)
										INNER JOIN States St1 WITH(NOLOCK)
										ON (I.State_StateId = St1.StateId AND St1.ProcessType_ProcessTypeId = ''' + CAST(@ProcessID AS varchar(100)) + ''')      
										WHERE ((ISNULL(I.ActualEndTime,1) = 1 OR CAST(I.ActualEndTime AS DateTime) >= CAST('''+ @StartTime +''' AS DateTime)) AND CAST(I.ActualStartTime AS DateTime) <= CAST('''+ @EndTime +''' AS DateTime))';
			
			IF (@IsNameFilterDefined = 1)
				Begin	
					SET    @StandingOrderHistory =@StandingOrderHistory + 'And (I.[Name] like ''%'+@NameFilter+'%'')'							
				End 
			
			
			SET @insertIntoTempSOLiteQry=  'INSERT  INTO #TempStandingOrdersLite
				            '+@insertIntoTempSOLiteQry + ' UNION ' + @StandingOrderHistory;
			
			

			exec (@insertIntoTempSOLiteQry)
 		
	
			SET @CalledUser = '''' +  UPPER(LTRIM(@CalledUser)) + '''';
	  
			IF (@CalledUser IS NOT NULL OR @CalledUser != '')
			BEGIN
				-- Need to do the logic for release 	   
				DECLARE @StandingOrderLockingTimeout int=0;
				DECLARE @ReleaseTime DATETIME;
				SELECT @StandingOrderLockingTimeout = CAST(LU.[Value] AS INT) From Lookups LU WITH(NOLOCK)
				INNER JOIN LookupTypes LUT WITH(NOLOCK) ON LUT.LookupType_PK_ID = LU.LookupType_PK_ID
				WHERE LTRIM(UPPER(LU.Name)) = 'STANDINGORDERLOCKINGTIMEOUT' AND LTRIM(LUT.Name) = 'Standing Order Time Parameters' ;
				UPDATE standingOrders 
				SET LockedBy = NULL, LockedTime = NULL 
				WHERE LockedTime <= DATEADD(mi,-@StandingOrderLockingTimeout,GETUTCDATE());
			
			END
				
	  
												  
			SET @insertIntoTempSOLiteFinalListQry =     '	
				    with main_cte as (	
						SELECT  I.StandingOrder_PK_ID,
								I.Name,
								I.PlanStartTime,
								I.PlanEndTime,
								I.IsAuthorizationNeeded,
								I.LastmodifiedBy,
								I.PlanNote,
								I.ActualStartTime,
								I.ActualEndTime,													  
							    A.Name as Asset,
								A.DisplayName as AssetDisplayName, 
								icat.Name as Category,
								icat.DisplayName AS CategoryDisplayName,
								st.Name as Status,
								st.DisplayName AS StatusDisplayName,																			
							    CASE WHEN UPPER(LTRIM(I.lockedBy)) = N' +  @CalledUser  + ' THEN NULL ELSE I.LockedBy END  AS LockedBy,
								ROW_NUMBER() OVER (ORDER BY I.'+@SortTimeOfActivity+' ) AS Seq,
								I.TimeOfActivity,
								I.State_StateId,
								I.Process_ProcessId,
								I.[AssignToChildAssets],
								I.[IsHistory]
											From #TempStandingOrdersLite I
											INNER JOIN Assets A WITH(NOLOCK) ON I.Asset_Asset_PK_ID = A.Asset_PK_ID                                                         
											INNER JOIN StandingOrderCategories Icat  WITH(NOLOCK)
												ON I.StandingOrderCategory_StandingOrderCategory_PK_ID = icat.StandingOrderCategory_PK_ID
											INNER JOIN States St WITH(NOLOCK)
												ON (I.State_StateId = St.StateId AND St.ProcessType_ProcessTypeId = ''' + CAST(@ProcessID AS varchar(100)) + ''')                                                                
											LEFT OUTER JOIN StandingOrderProducts pd WITH(NOLOCK)   
												ON pd.Product_PK_ID = I.StandingOrderProducts_Product_PK_ID'
											  
           															
			SET @insertIntoTempSOLiteFinalListQry = @insertIntoTempSOLiteFinalListQry +       '  INNER JOIN  #TemptbAssetsLite  TA ON A.Name = TA.AssetName'
	  
			IF(@categoryCount > 0 )
				BEGIN
				-- PRINT 'Cat'
						SET @insertIntoTempSOLiteFinalListQry = @insertIntoTempSOLiteFinalListQry +    ' INNER JOIN  #TemptblCategoryLite  TC ON icat.Name = TC.CategoryName '
			END 
			IF(@ProductCount > 0)
			BEGIN
				SET @insertIntoTempSOLiteFinalListQry = @insertIntoTempSOLiteFinalListQry + ' INNER JOIN #TemptblProductLite tpd ON tpd.ProductName = pd.ProductName '
			END
			
			SET @insertIntoTempSOLiteFinalListQry=@insertIntoTempSOLiteFinalListQry+ ' where (  EXISTS (SELECT TOP 1* FROM #TemptblAssetsWithHigherPermLite ia WHERE ia.AssetName=A.Name) 
																							  OR
																								(
																								  I.[AssignToChildAssets] = 1
																								  AND	st.Name <> ''DRAFT''
																								  And a.name  in (select AssetName from #TemptblParentAssetsLite)
																								) 
																							 OR	
																								(I.[IsHistory] = 0
																								 And EXISTS (SELECT TOP 1* 
																											    FROM #TemptblUserGroupsLite ug
																												INNER JOIN dbo.GroupDetails gd WITH(NOLOCK) 
																													ON ug.GroupName=gd.Name AND ug.ScopeName=gd.ScopeName
																												INNER JOIN dbo.StandingOrderAssignees iasg WITH(NOLOCK) 
																													ON gd.[GroupDetail_PK_Id]=iasg.[GroupDetail_GroupDetail_PK_Id]
																														AND iasg.[StandingOrder_StandingOrder_PK_ID]=I.StandingOrder_PK_ID 
																														AND st.Name <> ''DRAFT''
																										) 
																								)
																							 OR	
																								(I.[IsHistory] = 1
																								 And EXISTS (SELECT TOP 1* 
																											    FROM #TemptblUserGroupsLite ug
																												INNER JOIN dbo.GroupDetails gd WITH(NOLOCK) 
																													ON ug.GroupName=gd.Name AND ug.ScopeName=gd.ScopeName
																												INNER JOIN dbo.StandingOrderAssigneesHistory iasg WITH(NOLOCK) 
																													ON gd.[GroupDetail_PK_Id]=iasg.[GroupDetail_GroupDetail_PK_Id]
																														AND iasg.[StandingOrder_StandingOrder_PK_ID]=I.StandingOrder_PK_ID 
																														AND st.Name <> ''DRAFT''
																										) 
																								)
																							  OR
																								(  
																									st.Name <> ''DRAFT'' 
																									And a.name not in (select AssetName from #TemptblParentAssetsLite)
																								)																							 
																							)),

			  count_cte as (select count(1) as cnt from main_cte) '

				declare @insertIntoTempSOLiteFinalListQry_1 nvarchar(max) = @insertIntoTempSOLiteFinalListQry	 
			---- Logic isOverDue Filter start
			IF(@isFilterOverDue = 1)
			BEGIN
				DECLARE @CurrentDate DATETIME;
				SET @CurrentDate = GETUTCDATE()
				SET @insertIntoTempSOLiteFinalListQry = @insertIntoTempSOLiteFinalListQry + ' AND CAST(''' + CAST(@CurrentDate AS varchar(50)) + ''' AS DATETIME) > (
				CASE WHEN st.Name = ''Draft'' THEN  I.PlanStartTime 
				WHEN st.Name = ''Planned'' THEN  I.PlanStartTime 
				WHEN st.Name = ''Approved'' THEN  I.PlanStartTime 
				WHEN st.Name = ''Rejected'' THEN  I.PlanStartTime END) '
			END

			
			--  Logic isOverDue Filter end
			
			
			SET @PageVariable = (((@PageNumber - 1) * @PageSize) + 1) 
			SET	@insertIntoTempSOLiteFinalListQry = @insertIntoTempSOLiteFinalListQry + ' INSERT  INTO #TempSOLiteList
							SELECT 
								[StandingOrder_PK_ID],
								[Name],
								[PlanStartTime] ,
								[PlanEndTime] ,
								[IsAuthorizationNeeded],
								[LastmodifiedBy],
								[PlanNote] ,
								[ActualStartTime] ,
								[ActualEndTime],
								[Asset] ,
								[AssetDisplayName],
								[Category] ,
								[CategoryDisplayName] ,
								[Status],
								[StatusDisplayName] ,
								[LockedBy] ,				
								Count_cte.cnt as [TotalRowCount] ,
								[State_StateId],
								[Process_ProcessId],
								[AssignToChildAssets],
								[IsHistory]
						FROM Main_cte,Count_cte 
							WHERE '+
							'Seq BETWEEN ' + CAST (@PageVariable AS Varchar(100))  + ' AND ' +  CAST(@PageNumber  *  @PageSize AS VARCHAR(100)) + ' ORDER BY '+@SortTimeOfActivity
			
						                           
			exec sp_executesql @insertIntoTempSOLiteFinalListQry
			


			select  
					[StandingOrder_PK_ID],
					[Name],
					[PlanStartTime] ,
					[PlanEndTime] ,
					[IsAuthorizationNeeded],
					[LastmodifiedBy],
					[PlanNote] ,
					[ActualStartTime] ,
					[ActualEndTime],
					[Asset] ,
					[AssetDisplayName],
					[Category] ,
					[CategoryDisplayName] ,
					[Status],
					[StatusDisplayName] ,
					[LockedBy] ,				
					[TotalRowCount] ,
					[State_StateId],
					[Process_ProcessId],
					[AssignToChildAssets],
					
					CASE 
						WHEN [IsHistory] = 0  THEN
							 (select count(IComm.StandingOrder_StandingOrder_PK_ID) from StandingOrderComments IComm WITH(NOLOCK) where IComm.StandingOrder_StandingOrder_PK_ID = [StandingOrder_PK_ID] and  @AckCommentTypeID = IComm.StandingOrderCommentType_StandingOrderCommentType_PK_ID and (ActualStartTime is not null and IComm.CreatedTime >ActualStartTime))
						ELSE 
							(select count(IComm.StandingOrder_StandingOrder_PK_ID) from StandingOrderCommentsHistory IComm WITH(NOLOCK) where IComm.StandingOrder_StandingOrder_PK_ID = [StandingOrder_PK_ID] and  @AckCommentTypeID = IComm.StandingOrderCommentType_StandingOrderCommentTypeId 
and (ActualStartTime is not null and IComm.CreatedTime >ActualStartTime))  
					END  AS  [ActiveAckCount],
					CASE 
						WHEN [IsHistory] = 0  THEN
							 (select count(SOAttach.StandingOrder_StandingOrder_PK_ID) from StandingOrderAttachments SOAttach WITH(NOLOCK) where SOAttach.StandingOrder_StandingOrder_PK_ID = [StandingOrder_PK_ID])
						ELSE 
							 (select count(SOAttach.StandingOrder_StandingOrder_PK_ID) from StandingOrderAttachmentsHistory SOAttach WITH(NOLOCK) where SOAttach.StandingOrder_StandingOrder_PK_ID = [StandingOrder_PK_ID])
						END  AS  [AttachmentsCount],
					CASE 
						WHEN [IsHistory] = 0  THEN
							 (select count(SOLinks.StandingOrder_StandingOrder_PK_ID) from StandingOrderLinks SOLinks WITH(NOLOCK) where SOLinks.StandingOrder_StandingOrder_PK_ID = [StandingOrder_PK_ID])
						ELSE 
							 (select count(SOLinks.StandingOrder_StandingOrder_PK_ID) from StandingOrderLinksHistory SOLinks WITH(NOLOCK) where SOLinks.StandingOrder_StandingOrder_PK_ID = [StandingOrder_PK_ID])
						END  AS  [LinksCount]
					from #TempSOLiteList
			declare @HasNonHistorySO Bit
			declare @HasHistorySO Bit
			if exists(select 1 from #TempSOLiteList where IsHistory= 0)
				set  @HasNonHistorySO = 1
			Else 
				set  @HasNonHistorySO = 0
			if exists(select 1 from #TempSOLiteList where IsHistory= 1)
				set  @HasHistorySO = 1
			Else 
				set  @HasHistorySO = 0
			if @HasNonHistorySO = 1
			Begin
				insert into #TempLitePersonDetails
				(
					[StandingOrder_PK_ID],
					[Name] ,
					[DisplayName] ,
					[EmailID] ,				
					[UserPrincipal]
				)
				SELECT 
					SOList.StandingOrder_PK_ID,
					P.Name,
					P.DisplayName,
					P.EmailID,
					P.UserPrincipal
				FROM #TempSOLiteList SOList
				Inner Join StandingOrderAssignees SOAssignee WITH(NOLOCK)
					on (SOList.IsHistory = 0
						And SOList.StandingOrder_PK_ID = SOAssignee.StandingOrder_StandingOrder_PK_ID
						and SOAssignee.PersonDetail_PersonDetail_Pk_Id is not Null)
				Inner join PersonDetails P WITH(NOLOCK)
				ON SOAssignee.PersonDetail_PersonDetail_Pk_Id = P.PersonDetail_Pk_Id
			End 
			if @HasHistorySO = 1
			Begin
				insert into #TempLitePersonDetails
				(
					[StandingOrder_PK_ID],
					[Name] ,
					[DisplayName] ,
					[EmailID] ,				
					[UserPrincipal]
				)
				SELECT 
					SOList.StandingOrder_PK_ID,
					P.Name,
					P.DisplayName,
					P.EmailID,
					P.UserPrincipal
				FROM #TempSOLiteList SOList
				Inner Join StandingOrderAssigneesHistory SOAssignee WITH(NOLOCK)
					on (SOList.IsHistory = 1
						And SOList.StandingOrder_PK_ID = SOAssignee.StandingOrder_StandingOrder_PK_ID
						and SOAssignee.PersonDetail_PersonDetail_Pk_Id is not Null)
				Inner join PersonDetails P WITH(NOLOCK)
				ON SOAssignee.PersonDetail_PersonDetail_Pk_Id = P.PersonDetail_Pk_Id
			End 
			select * from #TempLitePersonDetails
			if @HasNonHistorySO = 1
			Begin
				insert into #TempLiteGroupDetails
				(
					[StandingOrder_PK_ID],
					[Name],
					[ScopeName]
				)	
				SELECT
					SOList.StandingOrder_PK_ID,
					G.Name,
					G.ScopeName
				FROM #TempSOLiteList SOList
				Inner Join StandingOrderAssignees SOAssignee WITH(NOLOCK)
					on (SOList.IsHistory = 0
						And SOList.StandingOrder_PK_ID = SOAssignee.StandingOrder_StandingOrder_PK_ID
						and SOAssignee.GroupDetail_GroupDetail_PK_Id is not Null)
				Inner join GroupDetails G
				ON SOAssignee.GroupDetail_GroupDetail_PK_Id = G.GroupDetail_PK_Id
			End
			if @HasHistorySO = 1
			Begin
				insert into #TempLiteGroupDetails
				(
					[StandingOrder_PK_ID],
					[Name],
					[ScopeName]
				)	
				SELECT
					SOList.StandingOrder_PK_ID,
					G.Name,
					G.ScopeName
				FROM #TempSOLiteList SOList
				Inner Join StandingOrderAssigneesHistory SOAssignee WITH(NOLOCK)
					on (SOList.IsHistory = 1
						And SOList.StandingOrder_PK_ID = SOAssignee.StandingOrder_StandingOrder_PK_ID
						and SOAssignee.GroupDetail_GroupDetail_PK_Id is not Null)
				Inner join GroupDetails G WITH(NOLOCK)
				ON SOAssignee.GroupDetail_GroupDetail_PK_Id = G.GroupDetail_PK_Id
			End
			select * from #TempLiteGroupDetails
			
			if @HasNonHistorySO = 1
			Begin
				insert into #TempLiteSOComments
				(				
					[StandingOrder_PK_ID],
					[StandingOrderComment_PK_ID] ,
					[Comment],
					[CreatedBy],
					[ActionTime] ,				
					[ActionName]
				)
				SELECT 
				   SOList.StandingOrder_PK_ID,
				   IC.StandingOrderComment_PK_ID,				   
				   IC.[Comment],
				   IC.[CreatedBy],
				   IC.CreatedTime AS [ActionTime],				    
				   AT.DisplayName AS [ActionName]				 
			   FROM #TempSOLiteList SOList
			   Join [dbo].[StandingOrderComments] IC WITH(NOLOCK)
					ON (SOList.IsHistory = 0 
					   and SOList.StandingOrder_PK_ID = IC.StandingOrder_StandingOrder_PK_ID 
					and IC.StandingOrderCommentType_StandingOrderCommentType_PK_ID in (@AckCommentTypeID,@NonWorkFlowCommentTypeId)
					   )
			   LEFT JOIN  [dbo].[StandingOrdersActionHistory] IAH WITH(NOLOCK) 
					ON IC.StandingOrderComment_PK_ID = IAH.[StandingOrderComment_StandingOrderComment_PK_ID]
			   LEFT JOIN  [dbo].[ActionTypes] AT WITH(NOLOCK) ON AT.[ActionTypeId] = IAH.[ActionType_ActionTypeID]   
			   
			   
		   End 
		   if @HasHistorySO = 1
			Begin
				insert into #TempLiteSOComments
				(				
					[StandingOrder_PK_ID],
					[StandingOrderComment_PK_ID] ,
					[Comment],
					[CreatedBy],
					[ActionTime] ,				
					[ActionName]
				)
				SELECT 
				   SOList.StandingOrder_PK_ID,
				   IC.StandingOrderComment_PK_ID,				   
				   IC.[Comment],
				   IC.[CreatedBy],
				   IC.CreatedTime AS [ActionTime],				    
				   AT.DisplayName AS [ActionName]				 
			   FROM #TempSOLiteList SOList
			   Join [dbo].[StandingOrderCommentsHistory] IC WITH(NOLOCK)
					ON (SOList.IsHistory = 1 
					   and SOList.StandingOrder_PK_ID = IC.StandingOrder_StandingOrder_PK_ID 
					and IC.StandingOrderCommentType_StandingOrderCommentTypeId in (@AckCommentTypeID,@NonWorkFlowCommentTypeId)
					   )
			   LEFT JOIN  [dbo].[StandingOrdersActionHistoryHistory] IAH WITH(NOLOCK) 
					ON IC.StandingOrderComment_PK_ID = IAH.[StandingOrderComment_StandingOrderComment_PK_ID]
			   LEFT JOIN  [dbo].[ActionTypes] AT WITH(NOLOCK) ON AT.[ActionTypeId] = IAH.[ActionType_ActionTypeID]   
			   
			   
		   End 
		   
			Select 					
					[StandingOrderComment_PK_ID] ,
					[StandingOrder_PK_ID] as [StandingOrder_StandingOrder_PK_ID],
					[Comment],
					[CreatedBy],
					[ActionTime] ,				
					[ActionName]				
					From (select *, 
				         row_number() over (partition by [StandingOrder_PK_ID] order by [ActionTime] desc) Row_rank 
			          from #TempLiteSOComments) tempLiteSOComms
			where tempLiteSOComms.Row_rank <= @NoOfComments
		   
		    Drop Table #TempLiteSOComments
			Drop Table #TempLiteGroupDetails
			Drop Table #TempLitePersonDetails
			DROP table #TemptbAssetsLite
			DROP table #TemptblParentAssetsLite
			DROP table #TemptblAssetsWithHigherPermLite	   
			DROP table #TemptblCategoryLite
			DROP table #TemptblStatusLite       
			DROP TABLE #TempStandingOrdersLite			       
			DROP TABLE #TemptblUserGroupsLite
			DROP table #TemptblProductLite
			DROP table #TempSOLiteList
		End
END


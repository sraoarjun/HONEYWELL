ALTER proc [dbo].[sp_GetAssetCmtsAndRespsForUser_Test]
    @AssetList [dbo].[t_Asset] READONLY,
	@ShStartDate DateTime = NULL,
	@ShEndDate DateTime = NULL,
	@SearchText nvarchar(max) = NULL,
	@CmtTypeList [dbo].[t_CommentType] READONLY,
	@CmtCatValueList [dbo].[t_CmtCategoryValuePair] READONLY,
	@PageNumber int,
	@PageSize   int,
	@ParentCmtsOrderBy varchar(100)=null	
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @lastArchivedDate AS DATETIME
	DECLARE @FetchFrom AS NVARCHAR(10)
	Declare @CountOfCmtTypes int
	Declare @CountOfCmtCategories int
	Declare @SearchCmd As Nvarchar(50)
	
	CREATE TABLE #ASSETListGetCmtResp(
	[Name] [nvarchar](100) NOT NULL
	)
	CREATE TABLE #TemptblAssetCmtAndResp (
		AssetId UNIQUEIDENTIFIER,
		[EquipID] UNIQUEIDENTIFIER,
		AssetName NVARCHAR(100)
	);
	CREATE TABLE #CmtTypeListGetCmtResp(
	[Name] [nvarchar](100) NOT NULL
	)
	CREATE TABLE #CmtCatValueListGetCmtResp(
	[Category] [nvarchar](100) NOT NULL,
	[Value] [nvarchar](100) NOT NULL
	)
	CREATE TABLE #FilteredParentChildCmts (
		[Comment_PK_ID] [uniqueidentifier] NOT NULL,
		[LinkId] [uniqueidentifier] NOT NULL
		--[LinkId] [nvarchar](100) NULL
	)
	CREATE TABLE #ParentCmtsCR (
		[Note] [nvarchar](max) NULL,
		[FormattedNote] [nvarchar](max) NULL,
		[CreatedUser] [nvarchar](100) NULL,
		[CreatedDateTime] [datetime] NULL,
		[ModifiedUser] [nvarchar](100) NULL,
		[ModifiedDateTime] [datetime] NULL,		
		[Shift_StartTime] [datetime] NULL,
		[Shift_EndTime] [datetime] NULL,
		[LinkId] [uniqueidentifier] NULL,
		--[LinkId] [nvarchar](100) NULL,
		[Response] [bit] NULL,
		[Comment_PK_ID] [uniqueidentifier] NOT NULL,
		[CommentType] [nvarchar](100) NOT NULL,
		[Asset] nvarchar(100) NOT NULL,
		[AssetDisplayName] nvarchar(100) NOT NULL,
		[ShiftName] [nvarchar](max) NULL,
		[LockByDateTime] [datetime] NULL,
		[TotalCount] [int] NULL,
		[HasResponse] [bit] default 0
	)
	CREATE TABLE #ChildCmtsCR(
		Note [nvarchar](max) NULL,
		[FormattedNote] [nvarchar](max) NULL,
		[CreatedUser] [nvarchar](100) NULL,
		[CreatedDateTime] [datetime] NULL,
		[ModifiedUser] [nvarchar](100) NULL,
		[ModifiedDateTime] [datetime] NULL,
		[Shift_StartTime] [datetime] NULL,
		[Shift_EndTime] [datetime] NULL,
		[LinkId] [uniqueidentifier] NULL,
		[Response] [bit] NULL,
		[Comment_PK_ID] [uniqueidentifier] NOT NULL,
		[CommentType] [nvarchar](100) NOT NULL,
		[Asset] nvarchar(100) NOT NULL,
		[AssetDisplayName] nvarchar(100) NOT NULL,
		[ShiftName] [nvarchar](max) NULL,
		[LockByDateTime] [datetime] NULL
	)
	CREATE TABLE #CmtsRespsCats(
		[Category] [nvarchar](100) NULL,
		[Value] [nvarchar](100) NULL,		
		[Comment_PK_ID] [uniqueidentifier] NOT NULL
	) 
	select @CountOfCmtTypes = count(*) from @CmtTypeList;
	select @CountOfCmtCategories = count(*) from @CmtCatValueList;
	
	INSERT INTO #ASSETListGetCmtResp([Name])
			SELECT distinct [Name] from @AssetList
	
	INSERT INTO #TemptblAssetCmtAndResp
		SELECT A.[Asset_PK_ID],A.[EquipID],A.[Name]
		FROM [dbo].[Assets] A
		INNER JOIN #ASSETListGetCmtResp AL ON A.NAME = AL.NAME
	IF @CountOfCmtTypes > 0
	Begin
		INSERT INTO #CmtTypeListGetCmtResp([Name])
				SELECT distinct [Name] from @CmtTypeList
	End
	IF @CountOfCmtCategories > 0
	Begin
		INSERT INTO #CmtCatValueListGetCmtResp([Category],[Value])
				SELECT distinct [Category],[Value] from @CmtCatValueList
	End
	if @PageNumber <= 0 
		Begin
			set @PageNumber =1
		End
	if @PageSize <= 0 
		Begin
			set @PageSize =1
		End
	if @ParentCmtsOrderBy is null
		set @ParentCmtsOrderBy = '[Shift_StartTime] Asc,[ModifiedDateTime] Asc';
	Else if @ParentCmtsOrderBy = 'desc'
		set @ParentCmtsOrderBy = '[Shift_StartTime] Desc,[ModifiedDateTime] Desc';
	Else 
		set @ParentCmtsOrderBy = '[Shift_StartTime] Asc,[ModifiedDateTime] Asc';
	
	if @SearchText is Not Null
		set @SearchCmd = ' And Cmts.[Note] like ''%'+@SearchText+'%'' ';
	--GET LAST ARCHIVED DATE
	SELECT @lastArchivedDate=MAX(AH.ArchivedTillDate)
	FROM ArchivalHistories AH
	WHERE AH.GroupName = 'LB_ASSETCOMMENTS'
		AND AH.RunStatus = 'Archived and Purged'
	
	--IF @ShEndDate IS NULL THEN INITIATILZE TO CURRENT DATE
	IF @ShEndDate IS NULL
	BEGIN
		SET @ShEndDate = GETUTCDATE()
	END
	
	--IF @@ShStartDate IS NULL THEN INITIATILZE TO LAST ARCHIVED DATE
	IF @ShStartDate IS NULL
	BEGIN
		SET @ShStartDate = @lastArchivedDate
	END
	
	IF @lastArchivedDate IS NOT NULL AND @lastArchivedDate >= @ShEndDate
		BEGIN
			SET @FetchFrom ='ARCHIVE'
		End
		--FETCH FROM BOTH TABLE
	ELSE IF (@lastArchivedDate IS NOT NULL) AND (@lastArchivedDate > @ShStartDate AND @lastArchivedDate < @ShEndDate) 
		BEGIN
			SET @FetchFrom ='BOTH'
		End
	ELSE 
		BEGIN
				SET @FetchFrom ='CURRENT'
		End 		
	
	Begin -- Get filtered Comment id into #FilteredParentChildCmts based on filters
		Declare @FilterCmtsStr nvarchar(max),@FilterHistCmtsStr nvarchar(max),@FilterCurCmtsStr nvarchar(max);
		Set @FilterCmtsStr = '
							 Insert into #FilteredParentChildCmts 
							 ([Comment_PK_ID]
							  ,[LinkId])
							 (
							 ';
		set @FilterHistCmtsStr = ''
		set @FilterCurCmtsStr = ''
		IF @FetchFrom='ARCHIVE' OR @FetchFrom='BOTH'
			BEGIN
			  -- Modified to get parent and child comments based on link id
			  set @FilterHistCmtsStr = 'SELECT '+ CASE WHEN @CountOfCmtCategories = 0  THEN ' ' ELSE ' Distinct ' END +' 
											 Cmts.AssetCommentHistory_PK_ID as [Comment_PK_ID]
											,Cmts.[LinkId] as [LinkId]							 
											FROM [dbo].AssetCommentHistory Cmts
											JOIN #TemptblAssetCmtAndResp A ON Cmts.Asset_PK_ID=A.AssetId and	 LinkId is not Null  																										
											JOIN (SELECT DISTINCT LinkId from AssetCommentHistory 
												JOIN #TemptblAssetCmtAndResp A1 ON AssetCommentHistory.Asset_PK_ID=A1.AssetId 
												and Shift_StartTime<= '''+ CONVERT(varchar(100),@ShEndDate,120) +''' AND Shift_EndTime>= '''+ CONVERT(varchar(100),@ShStartDate,120) +''' And LinkId is not Null ) chatIdTbl 
											ON (((chatIdTbl.LinkId = Cmts.LinkId)) '+ coalesce(@Searchcmd,' ')+ ' )
											
											';				
			
			if @CountOfCmtTypes > 0 
				Begin
					set @FilterHistCmtsStr = @FilterHistCmtsStr 
											+'JOIN [dbo].[CommentTypes] CmtTypes ON CmtTypes.CommentType_PK_ID=Cmts.CommentType_PK_ID
											  JOIN #CmtTypeListGetCmtResp CmtTypeList ON CmtTypeList.Name = CmtTypes.Name
											  ';
				End 
			
			if @CountOfCmtCategories > 0 
				Begin
					set @FilterHistCmtsStr = @FilterHistCmtsStr 
											+'JOIN [dbo].CommentCategoryHistory CmtCatgs ON CmtCatgs.AssetCommentHistory_PK_ID=Cmts.AssetCommentHistory_PK_ID
											  JOIN #CmtCatValueListGetCmtResp CmtCatgList ON ( CmtCatgList.[Category] = CmtCatgs.[Category] and CmtCatgList.[Value] = CmtCatgs.[Value] )
											  ';
				End 
			
			END
		IF @FetchFrom='CURRENT' OR @FetchFrom='BOTH'
			BEGIN
				-- Modified to get parent and child comments based on link id
				set @FilterCurCmtsStr = 'SELECT '+ CASE WHEN @CountOfCmtCategories = 0  THEN ' ' ELSE ' Distinct ' END +' 
											Cmts.[Comment_PK_ID] as [Comment_PK_ID]
											,Cmts.[LinkId] as [LinkId]							 
											FROM [dbo].Comments Cmts
											JOIN #TemptblAssetCmtAndResp A ON Cmts.Asset_PK_ID=A.AssetId and	 LinkId is not Null  										
											JOIN (SELECT DISTINCT LinkId from Comments 
												JOIN #TemptblAssetCmtAndResp A1 ON Comments.Asset_PK_ID=A1.AssetId 
												and Shift_StartTime<= '''+ CONVERT(varchar(100),@ShEndDate,120) +''' AND Shift_EndTime>= '''+ CONVERT(varchar(100),@ShStartDate,120) +''' And LinkId is not Null ) chatIdTbl 
											ON ((chatIdTbl.LinkId = Cmts.LinkId) '+ coalesce(@Searchcmd,' ')+ ' )											
											';
				if @CountOfCmtTypes > 0 
					Begin
						set @FilterCurCmtsStr = @FilterCurCmtsStr 
												+'JOIN [dbo].[CommentTypes] CmtTypes ON CmtTypes.CommentType_PK_ID=Cmts.CommentType_PK_ID
												  JOIN #CmtTypeListGetCmtResp CmtTypeList ON CmtTypeList.Name = CmtTypes.Name
												  ';
					End 
			
				if @CountOfCmtCategories > 0 
					Begin
						set @FilterCurCmtsStr = @FilterCurCmtsStr 
												+'JOIN [dbo].[CommentCategories] CmtCatgs ON CmtCatgs.Comment_PK_ID=Cmts.Comment_PK_ID
												  JOIN #CmtCatValueListGetCmtResp CmtCatgList ON ( CmtCatgList.[Category] = CmtCatgs.[Category] and CmtCatgList.[Value] = CmtCatgs.[Value] )
												  ';
					End 
			END		
		Set @FilterCmtsStr = @FilterCmtsStr+ @FilterHistCmtsStr;
		if @FetchFrom='BOTH'
			Begin
				Set @FilterCmtsStr = @FilterCmtsStr+ 'UNION All
													';
			End
		Set @FilterCmtsStr = @FilterCmtsStr+ @FilterCurCmtsStr;
		Set @FilterCmtsStr = @FilterCmtsStr+ ')';
		
		exec sp_executesql @FilterCmtsStr
	End
	Begin -- Get Parent Comment into #ParentCmtsCR 
		Declare @parentCmtsStr nvarchar(max),@parentHistCmtsStr nvarchar(max),@parentCurCmtsStr nvarchar(max);
		Set @parentCmtsStr = '
							 Insert into #ParentCmtsCR 
								(
								[Note],
								[FormattedNote],
								[CreatedUser],
								[CreatedDateTime],
								[ModifiedUser],
								[ModifiedDateTime],		
								[Shift_StartTime],
								[Shift_EndTime],
								[LinkId],
								[Response],
								[Comment_PK_ID],
								[CommentType],
								[Asset],
								[AssetDisplayName],
								[ShiftName],
								[LockByDateTime],
								[TotalCount])
								(Select
								[Note]
								,[FormattedNote]
								,[CreatedUser] 
								,[CreatedDateTime]
								,[ModifiedUser]
								,[ModifiedDateTime]		
								,[Shift_StartTime]
								,[Shift_EndTime]
								,[LinkId]
								,[Response]
								,[Comment_PK_ID]
								,[CommentType]
								,[Asset]
								,[AssetDisplayName]
								,ShiftName
								,LockByDateTime		
								,[TotalCount]
								From
								(
								select 
								null as [Note]
								,null as [FormattedNote]
								,[CreatedUser] 
								,[CreatedDateTime]
								,[ModifiedUser]
								,[ModifiedDateTime]		
								,[Shift_StartTime]
								,[Shift_EndTime]
								,[LinkId]
								,[Response]
								,[Comment_PK_ID]
								,CmtTypes.Name as [CommentType]
								,Asset.[Name] as [Asset]
								,Asset.[DisplayName] as [AssetDisplayName]
								,ShiftName
								,LockByDateTime
								,[RowID] = ROW_NUMBER() OVER (ORDER BY '+@ParentCmtsOrderBy+' )
								,[TotalCount]=Count([Comment_PK_ID]) OVER()
								From 
								( 
							    ';
		set @parentHistCmtsStr = ''
		set @parentCurCmtsStr = ''
		IF @FetchFrom='ARCHIVE' OR @FetchFrom='BOTH'
			BEGIN
				  set @parentHistCmtsStr = 'SELECT null as [Note]
												, null as [FormattedNote]
												, Cmts.[CreatedUser] 
												, Cmts.[CreatedDateTime]
												, Cmts.[ModifiedUser]
												, Cmts.[ModifiedDateTime]		
												, Cmts.[Shift_StartTime]
												, Cmts.[Shift_EndTime]
												, Cmts.[LinkId]
												, Cmts.[Response]
												, Cmts.AssetCommentHistory_PK_ID as [Comment_PK_ID]
												, Cmts.Asset_PK_ID
												, Cmts.CommentType_PK_ID		
												,Cmts.ShiftName As ShiftName
												,Cmts.LockByDateTime As LockByDateTime		
												FROM AssetCommentHistory Cmts
												Join (select distinct LinkId from #FilteredParentChildCmts where LinkId is not Null) As ChatIDTbl On ( Cmts.AssetCommentHistory_PK_ID = Cmts.LinkId And ChatIDTbl.LinkId = Cmts.AssetCommentHistory_PK_ID)
												';				
			END
		IF @FetchFrom='CURRENT' OR @FetchFrom='BOTH'
			BEGIN
				set @parentCurCmtsStr = 'SELECT null as [Note]
											, null as [FormattedNote]
											, Cmts.[CreatedUser] 
											, Cmts.[CreatedDateTime]
											, Cmts.[ModifiedUser]
											, Cmts.[ModifiedDateTime]		
											, Cmts.[Shift_StartTime]
											, Cmts.[Shift_EndTime]
											--,cast(Cmts.[LinkId] as nvarchar(200))
											,cast(Cmts.[LinkId] as nvarchar(200))
											, Cmts.[Response]
											, Cmts.[Comment_PK_ID]
											, Cmts.Asset_PK_ID
											, Cmts.CommentType_PK_ID		
											, Cmts.ShiftName As ShiftName
											,Cmts.LockByDateTime As LockByDateTime		
											FROM Comments Cmts
											Join (select distinct LinkId from #FilteredParentChildCmts where LinkId is not Null) As ChatIDTbl On ( Cmts.Comment_PK_ID = Cmts.LinkId And ChatIDTbl.LinkId = Cmts.Comment_PK_ID)
											';
			End
		Set @parentCmtsStr = @parentCmtsStr+ @parentHistCmtsStr;
		if @FetchFrom='BOTH'
			Begin
				Set @parentCmtsStr = @parentCmtsStr+ 'UNION All
													';
			End
		Set @parentCmtsStr = @parentCmtsStr+ @parentCurCmtsStr;
		Set @parentCmtsStr = @parentCmtsStr+ '	) As parentCmts
												JOIN dbo.CommentTypes CmtTypes ON CmtTypes.CommentType_PK_ID=parentCmts.CommentType_PK_ID
												JOIN dbo.Assets Asset ON parentCmts.Asset_PK_ID=Asset.Asset_PK_ID			
												) As OrederedParentCmts
												WHERE OrederedParentCmts.RowID > (( '+CAST(@PageNumber AS VARCHAR(5))+' -1) * '+ CAST(@PageSize AS VARCHAR(5))+' ) 
												And OrederedParentCmts.RowID <= ( '+CAST(@PageNumber AS VARCHAR(5))+' * '+ CAST(@PageSize AS VARCHAR(5))+') 
												)';
		
		exec sp_executesql @parentCmtsStr
	End
	-- Update ParentComment has response or not
	IF @FetchFrom='ARCHIVE' OR @FetchFrom='BOTH'
	Begin
		update #ParentCmtsCR 
	set HasResponse = 1
	From #ParentCmtsCR As ParentCmts
	join (select 
	#ParentCmtsCR.LinkId As LinkId	
	from #ParentCmtsCR 
	join AssetCommentHistory cmts
	on cmts.LinkId is not Null And cmts.LinkId = #ParentCmtsCR.LinkId And cmts.Response = 1
	group by #ParentCmtsCR.LinkId) As LinkRespTbl
	on ParentCmts.Comment_PK_ID =  LinkRespTbl.LinkId
	End
	IF @FetchFrom='CURRENT' OR @FetchFrom='BOTH'
	Begin
		update #ParentCmtsCR 
		set HasResponse = 1
		From #ParentCmtsCR As ParentCmts
		join (select 
		#ParentCmtsCR.LinkId As LinkId	
		from #ParentCmtsCR 
		join Comments cmts
		on cmts.LinkId is not Null And cmts.LinkId = #ParentCmtsCR.LinkId And cmts.Response = 1
		group by #ParentCmtsCR.LinkId) As LinkRespTbl
		on ParentCmts.Comment_PK_ID =  LinkRespTbl.LinkId	
		
	End
	Begin -- Get Child Comment into #ChildCmtsCR 
		Declare @childCmtsStr nvarchar(max),@childHistCmtsStr nvarchar(max),@childCurCmtsStr nvarchar(max);
		Set @childCmtsStr = '
							 Insert into #ChildCmtsCR 
							(
							[Note],
							[FormattedNote],
							[CreatedUser],
							[CreatedDateTime],
							[ModifiedUser],
							[ModifiedDateTime],		
							[Shift_StartTime],
							[Shift_EndTime],
							[LinkId],
							[Response],
							[Comment_PK_ID],
							[CommentType],
							[Asset],
							[AssetDisplayName],
							[ShiftName],
							[LockByDateTime]
							)
							(
							select 
							[Note]
							,[FormattedNote]
							,[CreatedUser] 
							,[CreatedDateTime]
							,[ModifiedUser]
							,[ModifiedDateTime]		
							,[Shift_StartTime]
							,[Shift_EndTime]
							,[LinkId]
							,[Response]
							,[Comment_PK_ID]
							,CmtTypes.Name as [CommentType]
							,Asset.[Name] as [Asset]
							,Asset.[DisplayName] as [AssetDisplayName]
							,ShiftName
							,LockByDateTime		
							From 
							(
							 ';
		set @childHistCmtsStr = ''
		set @childCurCmtsStr = ''
		IF @FetchFrom='ARCHIVE' OR @FetchFrom='BOTH'
			BEGIN
				  set @childHistCmtsStr = ' SELECT Cmts.[Note]
											, Cmts.[FormattedNote]
											, Cmts.[CreatedUser] 
											, Cmts.[CreatedDateTime]
											, Cmts.[ModifiedUser]
											, Cmts.[ModifiedDateTime]		
											, Cmts.[Shift_StartTime]
											, Cmts.[Shift_EndTime]
											, Cmts.[LinkId]
											, Cmts.[Response]
											, Cmts.AssetCommentHistory_PK_ID as [Comment_PK_ID]
											, Cmts.Asset_PK_ID
											, Cmts.CommentType_PK_ID		
											,Cmts.ShiftName As ShiftName
											,Cmts.LockByDateTime As LockByDateTime	
											FROM #ParentCmtsCR parentCmts
											Join #FilteredParentChildCmts filteredParentcmts On ( filteredParentcmts.Comment_PK_ID != filteredParentcmts.LinkId And filteredParentcmts.LinkId = parentCmts.LinkId)
											join AssetCommentHistory Cmts on Cmts.AssetCommentHistory_PK_ID = filteredParentcmts.Comment_PK_ID	
											and  Cmts.[Response] = 1
											';				
			END
		IF @FetchFrom='CURRENT' OR @FetchFrom='BOTH'
			BEGIN
				set @childCurCmtsStr = 'SELECT Cmts.[Note]
										, Cmts.[FormattedNote]
										, Cmts.[CreatedUser] 
										, Cmts.[CreatedDateTime]
										, Cmts.[ModifiedUser]
										, Cmts.[ModifiedDateTime]		
										, Cmts.[Shift_StartTime]
										, Cmts.[Shift_EndTime]
										, Cmts.[LinkId]
										, Cmts.[Response]
										, Cmts.[Comment_PK_ID]
										, Cmts.Asset_PK_ID
										, Cmts.CommentType_PK_ID		
										, Cmts.ShiftName As ShiftName
										,Cmts.LockByDateTime As LockByDateTime		
										FROM #ParentCmtsCR parentCmts
										Join #FilteredParentChildCmts filteredParentcmts On ( filteredParentcmts.Comment_PK_ID != filteredParentcmts.LinkId And filteredParentcmts.LinkId = parentCmts.LinkId)
										Join Comments Cmts on Cmts.Comment_PK_ID = filteredParentcmts.Comment_PK_ID
										and  Cmts.[Response] = 1
										';
			End
		Set @childCmtsStr = @childCmtsStr+ @childHistCmtsStr;
		if @FetchFrom='BOTH'
			Begin
				Set @childCmtsStr = @childCmtsStr+ 'UNION All
													';
			End
		Set @childCmtsStr = @childCmtsStr+ @childCurCmtsStr;
		Set @childCmtsStr = @childCmtsStr+ ') As childCmts
											JOIN dbo.CommentTypes CmtTypes ON CmtTypes.CommentType_PK_ID=childCmts.CommentType_PK_ID
											JOIN dbo.Assets Asset ON childCmts.Asset_PK_ID=Asset.Asset_PK_ID				  
		  
											)order by childCmts.Shift_StartTime Asc,childCmts.ModifiedDateTime Asc';
		
		exec sp_executesql @childCmtsStr
	End
 				
	Begin -- Get parent and child Comment categories
		Declare @CmtCatsStr nvarchar(max),@CmtCatsHistStr nvarchar(max),@CmtCatsCur nvarchar(max);
		Set @CmtCatsStr = '
							INSERT INTO #CmtsRespsCats
							 SELECT 
							 [Category],
							 [Value],
							 [Comment_PK_ID]
							From		
							(							
							 ';
		set @CmtCatsHistStr = ''
		set @CmtCatsCur = ''
		IF @FetchFrom='ARCHIVE' OR @FetchFrom='BOTH'
			BEGIN
				  set @CmtCatsHistStr = ' SELECT CC.[Category],
											CC.[Value],		
											CC.AssetCommentHistory_PK_ID as [Comment_PK_ID] 
											FROM dbo.CommentCategoryHistory CC
											join 
											(select 
											Comment_PK_ID
											From
											(SELECT Comment_PK_ID FROM #ParentCmtsCR
											UNION All
											SELECT Comment_PK_ID FROM #ChildCmtsCR) As ParentChildCmts) As ParentChildCmtsIDTbl
											on cc.AssetCommentHistory_PK_ID = ParentChildCmtsIDTbl.Comment_PK_ID
											';				
			END
		IF @FetchFrom='CURRENT' OR @FetchFrom='BOTH'
			BEGIN
				set @CmtCatsCur = 'SELECT CC.[Category],
									CC.[Value],		
									CC.[Comment_PK_ID] 
									FROM dbo.CommentCategories CC
									join 
									(select 
									Comment_PK_ID
									From
									(SELECT Comment_PK_ID FROM #ParentCmtsCR
									UNION All
									SELECT Comment_PK_ID FROM #ChildCmtsCR) As ParentChildCmts) As ParentChildCmtsIDTbl
									on cc.Comment_PK_ID = ParentChildCmtsIDTbl.Comment_PK_ID
									';
			End
		Set @CmtCatsStr = @CmtCatsStr+ @CmtCatsHistStr;
		if @FetchFrom='BOTH'
			Begin
				Set @CmtCatsStr = @CmtCatsStr+ 'UNION All
													';
			End
		Set @CmtCatsCur = @CmtCatsStr+ @CmtCatsCur;
		Set @CmtCatsCur = @CmtCatsCur+ ')As FinalCmtsCategoryTbl order by FinalCmtsCategoryTbl.[Category],FinalCmtsCategoryTbl.[Value]';
		
		exec sp_executesql @CmtCatsCur
	End
 
	SELECT * FROM #ParentCmtsCR 
	SELECT * FROM #ChildCmtsCR
	SELECT * FROM #CmtsRespsCats
	--Delete Temp table
	Drop Table #ASSETListGetCmtResp
	Drop Table #CmtTypeListGetCmtResp
	Drop Table #FilteredParentChildCmts
	Drop Table #CmtCatValueListGetCmtResp
	DROP TABLE #ParentCmtsCR
    DROP TABLE #ChildCmtsCR
    DROP TABLE #CmtsRespsCats
	Drop table #TemptblAssetCmtAndResp
End


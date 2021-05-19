USE [EPM]
GO
DROP TABLE IF EXISTS #temp
GO
SELECT * into #temp FROM (
	SELECT eq.SourceAssetName as AssetName, 
			eqm.MasterAssetName ,
			eq.SourceAssetName + '->'+ STRING_AGG(eq2.SourceAssetName, '->') WITHIN GROUP (GRAPH PATH) as [Path], 
			LAST_VALUE(eq2.SourceAssetName) WITHIN GROUP (GRAPH PATH) as LastNode
	FROM Equipments_Node as eq, 
	PARENT_EDGE FOR PATH as edg, 
	Equipments_Node FOR PATH as eq2,
	Equipments_MasterNode eqm,
	MAPS_TO_EDGE mps
	WHERE MATCH(SHORTEST_PATH(eq(-(edg)->eq2)+) AND eq-(mps)->eqm) 
	AND eq.Application_instance_id = 1
	
)as temp 
	WHERE temp.LastNode = 'Enterprise' --SampleSite3,Plant3,Area3,Unit3,Eq3
		
and assetName = 'Area1'


go

ALTER FUNCTION [dbo].[fn_split_string_to_column] (
    @string NVARCHAR(MAX),
    @delimiter CHAR(2)
    )
RETURNS @out_put TABLE (
    [column_id] INT IDENTITY(1, 1) NOT NULL,
    [value] NVARCHAR(MAX)
    )
AS
BEGIN
    DECLARE @value NVARCHAR(MAX),
        @pos INT = 0,
        @len INT = 0

    SET @string = CASE 
            WHEN RIGHT(@string, 1) != @delimiter
                THEN @string + @delimiter
            ELSE @string
            END

    WHILE CHARINDEX(@delimiter, @string, @pos + 1) > 0
    BEGIN
        SET @len = CHARINDEX(@delimiter, @string, @pos + 1) - @pos
        SET @value = SUBSTRING(@string, @pos, @len)

        INSERT INTO @out_put ([value])
        SELECT LTRIM(RTRIM(@value)) AS [column]

        SET @pos = CHARINDEX(@delimiter, @string, @pos + @len) + 2
    END

    RETURN
END
GO




select * from #temp



SELECT * FROM (
	SELECT eq.SourceAssetName as AssetName, 
			eq.SourceAssetName + '->'+ STRING_AGG(eq2.SourceAssetName, '->') WITHIN GROUP (GRAPH PATH) as [Path], 
			LAST_VALUE(eq2.SourceAssetName) WITHIN GROUP (GRAPH PATH) as LastNode
	FROM Equipments_Node as eq, 
	PARENT_EDGE FOR PATH as edg, 
	Equipments_Node FOR PATH as eq2
	WHERE MATCH(SHORTEST_PATH(eq(-(edg)->eq2)+))
	AND eq.Application_instance_id = 1
	
)as temp 
	WHERE temp.LastNode = 'Enterprise' --SampleSite3,Plant3,Area3,Unit3,Eq3
		
GO




SELECT AssetName, MasterAssetName, value  
FROM #temp
    CROSS APPLY [dbo].[fn_split_string_to_column](Path, '->');  
GO

select distinct A.value,B.ParentAssetName,B.ParentAssetType 
from 
(
	SELECT AssetName, MasterAssetName, value  
	FROM #temp
		CROSS APPLY [dbo].[fn_split_string_to_column](Path, '->')
)A
 JOIN 
 (

	SELECT Eq_Child.SourceAssetName , Eq_Child.SourceAssetType,Eq_Parent.SourceAssetName as ParentAssetName, Eq_Parent.SourceAssetType as ParentAssetType
	FROM Equipments_Node Eq_Child, PARENT_EDGE PARENT, Equipments_Node Eq_Parent
	WHERE MATCH(Eq_Child-(PARENT)->Eq_Parent)
)B 
ON 
A.[value] = B.SourceAssetName

GO

select distinct A.SourceAssetName , A.ParentAssetName , B.MasterAssetName,C.MasterAssetName, B.AssetType from 
(
SELECT Eq_Child.SourceAssetName , Eq_Child.SourceAssetType,Eq_Parent.SourceAssetName as ParentAssetName, Eq_Parent.SourceAssetType as ParentAssetType
FROM Equipments_Node Eq_Child, PARENT_EDGE PARENT, Equipments_Node Eq_Parent
WHERE MATCH(Eq_Child-(PARENT)->Eq_Parent)
)A
JOIN 
(
SELECT EqSrc.SourceAssetName , EqSrc.SourceAssetType,'----->' AS MAPS_TO ,EqMaster.MasterAssetName, EqMaster.AssetType
FROM Equipments_Node EqSrc, MAPS_TO_EDGE MAPS_TO , Equipments_MasterNode EqMaster
WHERE MATCH(EqSrc-(MAPS_TO)->EqMaster)

)B 
 ON A.SourceAssetName = B.SourceAssetName
 JOIN 
(
SELECT EqSrc.SourceAssetName , EqSrc.SourceAssetType,'----->' AS MAPS_TO ,EqMaster.MasterAssetName, EqMaster.AssetType
FROM Equipments_Node EqSrc, MAPS_TO_EDGE MAPS_TO , Equipments_MasterNode EqMaster
WHERE MATCH(EqSrc-(MAPS_TO)->EqMaster)

)C
ON A.ParentAssetName = C.SourceAssetName
JOIN (SELECT AssetName, MasterAssetName, value  
FROM #temp
    CROSS APPLY [dbo].[fn_split_string_to_column](Path, '->'))t   on t.value = A.SourceAssetName

	 
GO





select distinct  A.ChildAssetName,A.ParentAssetName,B.EPMAssetName,B.EPMAssetType from 
(
SELECT 
	Eq_Child.SourceAssetName	as	ChildAssetName, 
	Eq_Child.SourceAssetType	as	ChildAssetType,
	Eq_Parent.SourceAssetName	as	ParentAssetName, 
	Eq_Parent.SourceAssetType	as	ParentAssetType
FROM 
	Equipments_Node Eq_Child, PARENT_EDGE PARENT, Equipments_Node Eq_Parent
WHERE MATCH(Eq_Child-(PARENT)->Eq_Parent)
--AND 
	--Eq_Child.SourceAssetName = 'Eq2'
)A
JOIN 
(

SELECT 
	EqSrc.SourceAssetName		as	SourceAssetName , 
	EqSrc.SourceAssetType		as	SourceAssetType,
	EqMaster.MasterAssetName	as	EPMAssetName, 
	EqMaster.AssetType			as	EPMAssetType
FROM 
	Equipments_Node EqSrc, MAPS_TO_EDGE MAPS_TO , Equipments_MasterNode EqMaster
WHERE MATCH(EqSrc-(MAPS_TO)->EqMaster)
--AND 
	--EqSrc.SourceAssetName = 'Eq2'

)B 
ON 
	 A.ChildAssetName = B.SourceAssetName


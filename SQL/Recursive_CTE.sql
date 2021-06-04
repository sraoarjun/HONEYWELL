SELECT *
FROM Sales.SalesOrderDetail;
---Query-2 ---
 
SELECT SalesOrderId , CarrierTrackingNumber
FROM Sales.SalesOrderDetail;

declare @out int 
exec [dbo].[Fact] 4 , @RetVal =@Out OUTPUT

ALTER PROCEDURE [dbo].[Fact]
(
@Number Integer,
@RetVal Integer OUTPUT
)
AS
DECLARE @In Integer
DECLARE @Out Integer
IF @Number != 1
BEGIN
SELECT @In = @Number - 1
EXEC dbo.Fact @In, @Out OUTPUT -- Same stored procedure has been called again(Recursively)
print 'The value of @Number is ' + cast(@Number as varchar(10)) + ' and the value of @out is ' + cast(@out as varchar(10))
SELECT @RetVal = @Number * @Out
print 'i am being called now and the value is ' + cast(@Retval as varchar(10))
END
ELSE
BEGIN
SELECT @RetVal = 1
END
RETURN
GO




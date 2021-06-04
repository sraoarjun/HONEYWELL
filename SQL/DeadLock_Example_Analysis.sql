drop table if exists dbo.TableA
go
Create table dbo.TableA
(
    Id int identity primary key,
    Name nvarchar(50)
)
Go

Insert into TableA values ('Mark')
Insert into TableA values ('Ben')
Insert into TableA values ('Todd')
Insert into TableA values ('Pam')
Insert into TableA values ('Sara')
Go

drop table if exists dbo.TableB
go
Create table dbo.TableB
(
    Id int identity primary key,
    Name nvarchar(50)
)
Go

Insert into TableB values ('Mary')
Go


select * from dbo.TableA 
select * from dbo.TableB



/*
exec [dbo].[spTransaction1]
*/
Create or alter procedure [dbo].[spTransaction1]
as
Begin
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	
    Begin Tran
    Update TableA Set Name = 'Mark Transaction 1' where Id = 1
    Waitfor delay '00:00:05'
    Update TableB Set Name = 'Mary Transaction 1' where Id = 1
    Commit Transaction
End
GO


/*
exec [dbo].[spTransaction1]
*/
Create or alter procedure [dbo].[spTransaction1]
as 
Begin 
    Begin Tran
    Begin Try 
         Update TableA Set Name = 'Mark Transaction 1' where Id = 1 
         Waitfor delay '00:00:05' 
         Update TableB Set Name = 'Mary Transaction 1' where Id = 1 
         -- If both the update statements succeeded.
         -- No Deadlock occurred. So commit the transaction.
         Commit Transaction
         Select 'Transaction Successful'   
    End Try
    Begin Catch
         -- Check if the error is deadlock error
         If(ERROR_NUMBER() = 1205)
         Begin
             Select		'Deadlock. Transaction failed. Please retry',
						ERROR_MESSAGE() as error_message,
						ERROR_NUMBER() as error_number,
						ERROR_LINE() as error_line_no,
						ERROR_SEVERITY() as error_severity_,
						ERROR_STATE() as error_state_
         End
         -- Rollback the transaction
         Rollback
    End Catch   
End

/*
exec [dbo].[spTransaction2]
*/
Create or alter procedure [dbo].[spTransaction2]
as
Begin
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	
    Begin Tran
    Update TableB Set Name = 'Mark Transaction 2' where Id = 1
    Waitfor delay '00:00:05'
    Update TableA Set Name = 'Mary Transaction 2' where Id = 1
    Commit Transaction
End
GO



/*
exec [dbo].[spTransaction2]
*/
Create or alter procedure [dbo].[spTransaction2]
as 
Begin 
    Begin Tran
    Begin Try
         Update TableB Set Name = 'Mary Transaction 2' where Id = 1
         Waitfor delay '00:00:05'
         Update TableA Set Name = 'Mark Transaction 2' where Id = 1
         Commit Transaction
         Select 'Transaction Successful'   
    End Try
    Begin Catch
         If(ERROR_NUMBER() = 1205)
         Begin
             Select		'Deadlock. Transaction failed. Please retry',
						ERROR_MESSAGE() as error_message,
						ERROR_NUMBER() as error_number,
						ERROR_LINE() as error_line_no,
						ERROR_SEVERITY() as error_severity_,
						ERROR_STATE() as error_state_

        End
         Rollback
    End Catch   
End





dbcc traceon(1222,-1)
dbcc tracestatus(1222,-1)
dbcc traceoff(1222,-1)

exec sp_readerrorlog 


/*
	Troubleshoot the error by using the below queries whenever there is a contention on the database for a KEY
*/

SELECT 
    name 
FROM sys.databases 
WHERE database_id=27;
GO


SELECT 
    sc.name as schema_name, 
    so.name as object_name, 
    si.name as index_name
FROM sys.partitions AS p
JOIN sys.objects as so on 
    p.object_id=so.object_id
JOIN sys.indexes as si on 
    p.index_id=si.index_id and 
    p.object_id=si.object_id
JOIN sys.schemas AS sc on 
    so.schema_id=sc.schema_id
WHERE hobt_id = 72057594048675840;


SELECT
    *
FROM dbo.TableA (NOLOCK)
WHERE %%lockres%% = '(8194443284a0)';
GO


SELECT DB_NAME(database_id), 
    is_read_committed_snapshot_on,
    snapshot_isolation_state_desc 
    
FROM sys.databases
WHERE database_id = DB_ID();


ALTER DATABASE [TEST] SET READ_COMMITTED_SNAPSHOT ON;
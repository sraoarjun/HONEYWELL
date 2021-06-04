DROP TABLE IF EXISTS dbo.Books
GO
CREATE TABLE dbo.Books
(
  BookID int NOT NULL PRIMARY KEY,
  BookTitle nvarchar(50) NOT NULL,
  ModifiedDate datetime NOT NULL
);
GO


declare @InsertOutput2 table
(
  BookID int
 ); 
 
-- insert new row into Books table
INSERT INTO Books
OUTPUT 
    INSERTED.BookID
INTO @InsertOutput2
VALUES(102, 'Pride and Prejudice', GETDATE());
 
-- view inserted row in Books table
--SELECT * FROM Books;
 
---- view output row in @InsertOutput2 variable
--SELECT * FROM @InsertOutput2;


Update dbo.Books set BookTitle = BookTitle + '_Test' where BookID = (select BookID from @InsertOutput2);


Set statistics time , io on

declare @BookID int ;

INSERT INTO dbo.Books
VALUES(102, 'Pride and Prejudice', GETDATE());

set @BookID = (select top 1 BookID from dbo.Books order by 1 desc );

Update dbo.Books set BookTitle = BookTitle + '_Test' where BookID = @BookID
GO


declare @InsertOutput2 table
(
  BookID int
 ); 

INSERT INTO Books
OUTPUT 
    INSERTED.BookID
INTO @InsertOutput2
VALUES(103, 'Lion King', GETDATE());

Update dbo.Books set BookTitle = BookTitle + '_Test' where BookID = (select BookID from @InsertOutput2);
GO


Set statistics time , io off
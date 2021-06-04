
-- Create an empty table having the same structure as the Sales.Customer but in [dbo] schema
select * into dbo.customer_in from [AdventureWorks2016].[Sales].[Customer] where (1=0)

--truncate table dbo.customer_in

-- This command outputs the data from the source Sales.Customer table to a flat file as comma seperated
EXEC master..xp_cmdshell 'BCP [AdventureWorks2016].[Sales].[Customer] out C:\ARJUN\TEST\SalesCustomer.txt -S HMECL003459\MSSQLSERVER01 -T -c'

-- This command ingests / Imports data from a text file which is comma seperated into the table created above in the [dbo] schema
EXEC master..xp_cmdshell 'BCP [AdventureWorks2016].[dbo].[Customer_in] in C:\ARJUN\TEST\SalesCustomer.txt -S HMECL003459\MSSQLSERVER01 -T -c'


 --This command outputs the data from the source Sales.Customer table to a flat file as comma seperated (This needs to be run from command line)
BCP [AdventureWorks2016].[Sales].[Customer] out C:\ARJUN\TEST\SalesCustomer.txt -S HMECL003459\MSSQLSERVER01 -T -c –b1000 –t,

-- This command ingests / Imports data from a text file which is comma seperated into the table created above in the [dbo] schema 
--(This needs to be run from command line)
BCP [AdventureWorks2016].dbo.[customer_in] in C:\ARJUN\TEST\SalesCustomer.txt -S HMECL003459\MSSQLSERVER01 -T -c –b1000 –t,



--select * from dbo.customer_in
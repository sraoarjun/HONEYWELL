--select * from dbo.DimSalesTerritory


set statistics io on

select ProductKey, OrderDateKey, DueDateKey, ShipDateKey, CustomerKey, PromotionKey, CurrencyKey, fis.SalesTerritoryKey, SalesOrderNumber, SalesOrderLineNumber, RevisionNumber, OrderQuantity, UnitPrice, ExtendedAmount, UnitPriceDiscountPct, DiscountAmount, ProductStandardCost, TotalProductCost, SalesAmount, TaxAmt, Freight, CarrierTrackingNumber, CustomerPONumber, OrderDate, DueDate, ShipDate from dbo.FactInternetSales fis join dbo.DimSalesTerritory st on fis.SalesTerritoryKey=st.SalesTerritoryKey where st.SalesTerritoryCountry = N'Canada' 
GO

select ProductKey, OrderDateKey, DueDateKey, ShipDateKey, CustomerKey, PromotionKey, CurrencyKey, fis.SalesTerritoryKey, SalesOrderNumber, SalesOrderLineNumber, RevisionNumber, OrderQuantity, UnitPrice, ExtendedAmount, UnitPriceDiscountPct, DiscountAmount, ProductStandardCost, TotalProductCost, SalesAmount, TaxAmt, Freight, CarrierTrackingNumber, CustomerPONumber, OrderDate, DueDate, ShipDate from dbo.FactInternetSales fis  with (index(IX_FactInternetSales_SalesTerritoryKey)) join dbo.DimSalesTerritory st on fis.SalesTerritoryKey=st.SalesTerritoryKey where st.SalesTerritoryKey = 6; 
GO

set statistics io off


exec sp_helpstats 'DimSalesTerritory', 'ALL'

DBCC SHOW_STATISTICS ('DimSalesTerritory','_WA_Sys_00000004_21B6055D')

exec sp_helpstats 'FactInternetSales', 'ALL'

DBCC SHOW_STATISTICS ('FactInternetSales','IX_FactInternetSales_SalesTerritoryKey')
DBCC SHOW_STATISTICS ('FactInternetSales','_WA_Sys_00000008_276EDEB3')

GO

SELECT *
FROM sys.dm_db_partition_stats s
WHERE OBJECT_NAME(s.object_id) IN ('FactInternetSales')
AND index_id > 1;


SELECT *
FROM sys.dm_db_partition_stats s
WHERE OBJECT_NAME(s.object_id) IN ('DimSalesTerritory')
AND index_id > 1;


SELECT INDEXPROPERTY ( object_ID('FactInternetSales'), 'IX_FactInternetSales_SalesTerritoryKey' , 'IndexDepth');
SELECT INDEXPROPERTY ( object_ID('FactInternetSales'), 'PK_FactInternetSales_SalesOrderNumber_SalesOrderLineNumber' , 'IndexDepth');
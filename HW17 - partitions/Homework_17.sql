-- =============================================
-- Author:		Chernyak Andrey
-- Create date: 2020-06-30
-- Alter date: 	
-- Description:	Partitions
-- =============================================

/*
Секционирование таблицы
Выбираем в своем проекте таблицу-кандидат для секционирования и добавляем партиционирование.
Если в проекте нет такой таблицы, то делаем анализ базы данных из WWI, выбираем таблицу и делаем ее секционирование,
с переносом данных по секциям (партициям) - исходя из того, что таблица большая, пишем скрипты миграции в секционированную таблицу
*/

USE WideWorldImporters;
GO

-- orderlines

--создадим файловую группу
ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [YearData]
GO

--добавляем файл БД
ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'Years', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Yeardata.ndf' , 
SIZE = 2097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO


--создаем функцию партиционирования - по умолчанию left!!
CREATE PARTITION FUNCTION [fnYearPartition](DATE) AS RANGE RIGHT FOR VALUES
('20140101','20150101','20160101');																																																									
GO

CREATE PARTITION SCHEME [schmYearPartition] AS PARTITION [fnYearPartition] 
ALL TO ([YearData])
GO

CREATE TABLE [Sales].[OrderLinesYears](
	[OrderLineID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[OrderDate] [date] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[PickedQuantity] [int] NOT NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
) ON [schmYearPartition]([OrderDate])
GO


-- перенос данных
INSERT INTO Sales.OrderLinesYears
SELECT sol.OrderLineID
	, sol.OrderID
	, so.OrderDate
	, sol.StockItemID
	, sol.Description
	, sol.PackageTypeID
	, sol.Quantity
	, sol.UnitPrice
	, sol.TaxRate
	, sol.PickedQuantity
	, sol.PickingCompletedWhen
	, sol.LastEditedBy
	, sol.LastEditedWhen
FROM Sales.Orders AS so
	INNER JOIN Sales.OrderLines AS sol
		ON sol.OrderID = so.OrderID



--смотрим как конкретно по диапазонам уехали данные
SELECT $PARTITION.fnYearPartition(OrderDate) AS Partition,   
COUNT(*) AS [COUNT], MIN(OrderDate),MAX(OrderDate) 
FROM Sales.OrderLinesYears
GROUP BY $PARTITION.fnYearPartition(OrderDate) 
ORDER BY Partition ; 

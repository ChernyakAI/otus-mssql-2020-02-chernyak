-- =============================================
-- Author:		Chernyak Andrey
-- Create date: 2020-04-11
-- Alter date: 	
-- Description:	XML, JSON и динамический SQL
-- =============================================
USE WideWorldImporters;
GO

--Примечания к заданиям 1, 2:
--* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML.
--* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
--* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы.


--1. Загрузить данные из файла StockItems.xml в таблицу Warehouse.StockItems.
--Существующие записи в таблице обновить, отсутствующие добавить
--сопоставлять записи по полю StockItemName).
--Файл StockItems.xml в личном кабинете.


DECLARE @data AS XML;
DECLARE @handle INT;

SELECT @data = P
FROM OPENROWSET (BULK 'z:\Temp\json_xml_examples_2020_02\StockItems-188-f89807.xml', SINGLE_BLOB) AS TEST(P);

EXEC sp_xml_preparedocument @handle OUTPUT, @data;

WITH XmlData AS
(
	SELECT *
	FROM OPENXML(@handle, '/StockItems/Item', 2)
	WITH (
		StockItemName NVARCHAR(100) '@Name'
		, SupplierID INT 'SupplierID'
		, UnitPackageID INT 'Package/UnitPackageID'
		, OuterPackageID INT 'Package/OuterPackageID'
		, QuantityPerOuter INT 'Package/QuantityPerOuter'
		, TypicalWeightPerUnit DECIMAL(18,3) 'Package/TypicalWeightPerUnit'
		, LeadTimeDays INT 'LeadTimeDays'
		, IsChillerStock BIT 'IsChillerStock'
		, TaxRate DECIMAL(18,3) 'TaxRate'
		, UnitPrice DECIMAL(18, 2) 'UnitPrice'
	)
)

MERGE Warehouse.StockItems AS target  
USING (SELECT * FROM XmlData) AS source (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice)  
ON (target.StockItemName = source.StockItemName)  
WHEN MATCHED THEN
    UPDATE SET
		target.StockItemName = source.StockItemName,
		target.SupplierID = source.SupplierID,
		target.UnitPackageID = source.UnitPackageID,
		target.OuterPackageID = source.OuterPackageID,
		target.QuantityPerOuter = source.QuantityPerOuter,
		target.TypicalWeightPerUnit = source.TypicalWeightPerUnit,
		target.LeadTimeDays = source.LeadTimeDays,
		target.IsChillerStock = source.IsChillerStock,
		target.TaxRate = source.TaxRate,
		target.UnitPrice = source.UnitPrice  
WHEN NOT MATCHED THEN  
    INSERT (StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, LastEditedBy)  
    VALUES (source.StockItemName, source.SupplierID, source.UnitPackageID, source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit, source.LeadTimeDays, source.IsChillerStock, source.TaxRate, source.UnitPrice, 1)  
OUTPUT $action, deleted.*, inserted.*;

EXEC sp_xml_removedocument @handle;

 

-- 2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml

DECLARE @cmd NVARCHAR(4000);
SET @cmd = 'bcp "SELECT ws.StockItemName AS [@Name], ws.SupplierID, ws.UnitPackageID AS [Package/UnitPackageID], ws.OuterPackageID AS [Package/OuterPackageID], ws.QuantityPerOuter AS [Package/QuantityPerOuter], ws.TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit], ws.LeadTimeDays, ws.IsChillerStock, ws.TaxRate, ws.UnitPrice FROM WideWorldImporters.Warehouse.StockItems AS ws FOR XML PATH(''Item''), TYPE, elements xsinil, ROOT(''StockItems'')" queryout "c:\git\otus-mssql-2020-02-chernyak\HW09 - xml_json\StockItems.xml" -c -T -S DESKTOP-UC6FVVF\SQL2017';
exec xp_cmdshell @cmd;



--3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
--Написать SELECT для вывода:
--- StockItemID
--- StockItemName
--- CountryOfManufacture (из CustomFields)
--- FirstTag (из поля CustomFields, первое значение из массива Tags)

SELECT
	wsi.StockItemID
	, wsi.StockItemName
	, JSON_VALUE(wsi.CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture
	, JSON_VALUE(wsi.CustomFields, '$.Tags[0]') AS FirstTag
FROM Warehouse.StockItems AS wsi;



--4. Найти в StockItems строки, где есть тэг "Vintage".
--Вывести:
--- StockItemID
--- StockItemName
--- (опционально) все теги (из CustomFields) через запятую в одном поле

--Тэги искать в поле CustomFields, а не в Tags.
--Запрос написать через функции работы с JSON.
--Для поиска использовать равенство, использовать LIKE запрещено.

--Должно быть в таком виде:
--... where ... = 'Vintage'

--Так принято не будет:
--... where ... Tags like '%Vintage%'
--... where ... CustomFields like '%Vintage%'

WITH ItemsTags AS
(
	SELECT
		wsi.StockItemID
		, REPLACE(
				REPLACE(
					REPLACE(JSON_QUERY(wsi.CustomFields, '$.Tags'), '[', '')
				, ']', '')
			, '"', '') TagsString
	FROM Warehouse.StockItems AS wsi
)
SELECT
	wsi.StockItemID
	, wsi.StockItemName
	, it.TagsString
	, TagsSeparated.Value AS TagValue
FROM Warehouse.StockItems AS wsi
	INNER JOIN ItemsTags AS it
		ON it.StockItemID = wsi.StockItemID
	CROSS APPLY STRING_SPLIT(it.TagsString, ',') AS TagsSeparated 
WHERE TagsSeparated.Value = 'Vintage';



--5. Пишем динамический PIVOT.
--По заданию из занятия “Операторы CROSS APPLY, PIVOT, CUBE”.
--Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
--Название клиента
--МесяцГод Количество покупок

--Нужно написать запрос, который будет генерировать результаты для всех клиентов.
--Имя клиента указывать полностью из CustomerName.
--Дата должна иметь формат dd.mm.yyyy например 25.12.2019

DECLARE @CustomersString NVARCHAR(MAX);
DECLARE @QueryString NVARCHAR(MAX);

WITH DistinctCustomers AS
(
	SELECT DISTINCT	sc.CustomerName
	FROM Sales.Invoices AS si
		INNER JOIN Sales.Customers AS sc
			ON sc.CustomerID = si.CustomerID
)
SELECT @CustomersString = STRING_AGG(CONVERT(nvarchar(max), '[' + dc.CustomerName) + ']',', ')
FROM DistinctCustomers AS dc;

SET @QueryString = '
SELECT
    FORMAT(InvoiceMonth, N''dd.MM.yyyy'') AS InvoiceMonth, ' +
	@CustomersString + '
FROM
(
    SELECT    
		sc.CustomerName AS CustomerName
        , DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate) AS InvoiceMonth
        , si.InvoiceID
    FROM Sales.Invoices AS si
        INNER JOIN Sales.Customers AS sc
            ON sc.CustomerID = si.CustomerID
) AS InvoicesByCustomers
PIVOT
(
    COUNT(InvoiceID)
    FOR CustomerName IN (' + @CustomersString + ')
) AS PVT
ORDER BY PVT.InvoiceMonth
';

exec (@QueryString);
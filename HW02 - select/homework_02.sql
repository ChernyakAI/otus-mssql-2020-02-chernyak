/*
* Домашняя работа к занятию 2
*/

-- 1. Все товары, в которых в название есть пометка urgent или название начинается с Animal
SELECT
	wsi.StockItemName AS StockItemName
FROM
	Warehouse.StockItems AS wsi
WHERE
	wsi.StockItemName LIKE N'%urgent%'
	OR wsi.StockItemName LIKE N'Animal%';

-- 2. Поставщиков, у которых не было сделано ни одного заказа (потом покажем как это делать через подзапрос, сейчас сделайте через JOIN)
SELECT
	ps.SupplierName AS SupplierName
FROM
	Purchasing.Suppliers AS ps
	LEFT JOIN Purchasing.PurchaseOrders AS ppo
		ON ps.SupplierID = ppo.SupplierID
WHERE
	ppo.PurchaseOrderID is null;


-- 3.
-- Продажи с названием месяца, в котором была продажа,
-- номером квартала, к которому относится продажа,
-- включите также к какой трети года относится дата - каждая треть по 4 месяца,
-- дата забора заказа должна быть задана,
-- с ценой товара более 100$ либо количество единиц товара более 20.
-- Добавьте вариант этого запроса с постраничной выборкой пропустив первую 1000 и отобразив следующие 100 записей.
-- Соритровка должна быть по номеру квартала, трети года, дате продажи.
SELECT
	si.InvoiceID								AS InvoiceID,
	si.InvoiceDate								AS InvoiceDate,
	DATENAME(MONTH, si.InvoiceDate)				AS InvoiceMonthOfTheYear,
	DATENAME(QUARTER, si.InvoiceDate)			AS InvoiceQuarterOfTheYear,
	CASE
		WHEN MONTH(si.InvoiceDate) >= 1 AND MONTH(si.InvoiceDate) <= 4 THEN 1
		WHEN MONTH(si.InvoiceDate) >= 5 AND MONTH(si.InvoiceDate) <= 8 THEN 2
		ELSE 3
	END											AS InvoiceThirdOfTheYear,
	CONVERT(DATE, si.ConfirmedDeliveryTime)		AS DeliveryDate,
	sil.UnitPrice								AS Price,
	sil.Quantity								AS Quantity
FROM
	Sales.Invoices AS si
	INNER JOIN Sales.InvoiceLines AS sil
		ON si.InvoiceID = sil.InvoiceID
WHERE
	sil.UnitPrice > 100
	OR sil.Quantity > 20
ORDER BY
	DATENAME(QUARTER, si.InvoiceDate),
	InvoiceThirdOfTheYear,
	si.InvoiceDate;

-- Вариант со смещением
SELECT
	si.InvoiceID								AS InvoiceID,
	si.InvoiceDate								AS InvoiceDate,
	DATENAME(MONTH, si.InvoiceDate)				AS InvoiceMonthOfTheYear,
	DATENAME(QUARTER, si.InvoiceDate)			AS InvoiceQuarterOfTheYear,
	CASE
		WHEN MONTH(si.InvoiceDate) >= 1 AND MONTH(si.InvoiceDate) <= 4 THEN 1
		WHEN MONTH(si.InvoiceDate) >= 5 AND MONTH(si.InvoiceDate) <= 8 THEN 2
		ELSE 3
	END											AS InvoiceThirdOfTheYear,
	CONVERT(DATE, si.ConfirmedDeliveryTime)		AS DeliveryDate,
	sil.UnitPrice								AS Price,
	sil.Quantity								AS Quantity
FROM
	Sales.Invoices AS si
	INNER JOIN Sales.InvoiceLines AS sil
		ON si.InvoiceID = sil.InvoiceID
WHERE
	sil.UnitPrice > 100
	OR sil.Quantity > 20
ORDER BY
	DATENAME(QUARTER, si.InvoiceDate),
	InvoiceThirdOfTheYear,
	si.InvoiceDate
	OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY;


-- 4.
-- Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post,
-- добавьте название поставщика, имя контактного лица принимавшего заказ
SELECT DISTINCT
	ppo.PurchaseOrderID		AS PurchaseOrderID,
	ppo.OrderDate			AS OrderDate,
	ps.SupplierName			AS Supplier,
	ap.FullName				AS ContactPerson,
	adm.DeliveryMethodName	AS DeliveryMethod
FROM
	Purchasing.PurchaseOrders AS ppo
	INNER JOIN Purchasing.PurchaseOrderLines AS ppol
		ON ppo.PurchaseOrderID = ppol.PurchaseOrderID
	INNER JOIN Purchasing.Suppliers AS ps
		ON ppo.SupplierID = ps.SupplierID
	INNER JOIN Application.DeliveryMethods AS adm
		ON ppo.DeliveryMethodID = adm.DeliveryMethodID
	INNER JOIN Application.People AS ap
		ON ppo.ContactPersonID = ap.PersonID
WHERE
	ppol.LastReceiptDate >= '20140101'
	AND ppol.LastReceiptDate < '20150101'
	AND ppol.IsOrderLineFinalized = 1
	AND (adm.DeliveryMethodName = 'Road Freight'
		OR adm.DeliveryMethodName = 'Post');



-- 5. 10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.
SELECT TOP 10
	si.InvoiceID		AS InvoiceID,
	si.InvoiceDate		AS InvoiceDate,
	si.OrderID			AS OrderID,
	sc.CustomerName		AS CustomerName,
	ap.FullName			AS Salesperson
FROM Sales.Invoices AS si
	INNER JOIN Sales.Customers AS sc
		ON si.CustomerID = sc.CustomerID
	INNER JOIN Application.People AS ap
		ON si.SalespersonPersonID = ap.PersonID
ORDER BY
	si.InvoiceDate DESC,
	si.InvoiceID DESC;



-- 6. Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g
SELECT DISTINCT
	sc.CustomerID		AS CustomerID,
	sc.CustomerName		AS CustomerName,
	ap_1.FullName		AS PrimaryContactName,
	ap_1.PhoneNumber	AS PrimaryPhoneNumber,
	ap_2.FullName		AS AlternateContactName,
	ap_2.PhoneNumber	AS AlternatePhoneNumber
FROM
	Sales.InvoiceLines AS sil
	INNER JOIN Warehouse.StockItems AS wis
		ON sil.StockItemID = wis.StockItemID
	INNER JOIN Sales.Invoices AS si
		ON sil.InvoiceID = si.InvoiceID
	INNER JOIN Sales.Customers AS sc
		ON si.CustomerID = sc.CustomerID
		INNER JOIN Application.People AS ap_1
			ON sc.PrimaryContactPersonID = ap_1.PersonID
		LEFT JOIN Application.People AS ap_2
			ON sc.AlternateContactPersonID = ap_2.PersonID
WHERE
	wis.StockItemName = 'Chocolate frogs 250g';
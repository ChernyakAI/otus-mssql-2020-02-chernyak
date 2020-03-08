/*
*	�������� ������ � ������� 2.
*	�������� ������� ��� ����, ����� ��������:
*/

-- 1. ��� ������, � ������� � �������� ���� ������� urgent ��� �������� ���������� � Animal
SELECT
	wsi.StockItemName AS StockItemName
FROM
	Warehouse.StockItems AS wsi
WHERE
	wsi.StockItemName LIKE N'%urgent%'
	OR wsi.StockItemName LIKE N'Animal%';

-- 2. �����������, � ������� �� ���� ������� �� ������ ������ (����� ������� ��� ��� ������ ����� ���������, ������ �������� ����� JOIN)
SELECT
	ps.SupplierName AS SupplierName
FROM
	Purchasing.Suppliers AS ps
	LEFT JOIN Purchasing.PurchaseOrders AS ppo
		ON ps.SupplierID = ppo.SupplierID
WHERE
	ppo.PurchaseOrderID is null;


-- 3.
-- ������� � ��������� ������, � ������� ���� �������,
-- ������� ��������, � �������� ��������� �������,
-- �������� ����� � ����� ����� ���� ��������� ���� - ������ ����� �� 4 ������,
-- ���� ������ ������ ������ ���� ������,
-- � ����� ������ ����� 100$ ���� ���������� ������ ������ ����� 20.
-- �������� ������� ����� ������� � ������������ �������� ��������� ������ 1000 � ��������� ��������� 100 �������.
-- ���������� ������ ���� �� ������ ��������, ����� ����, ���� �������.
SELECT
	si.InvoiceID																	AS InvoiceID,
	si.InvoiceDate																	AS InvoiceDate,
	DATENAME(MONTH, si.InvoiceDate)													AS InvoiceMonthOfTheYear,
	DATENAME(QUARTER, si.InvoiceDate)												AS InvoiceQuarterOfTheYear,
	CASE
		WHEN MONTH(si.InvoiceDate) >= 1 AND MONTH(si.InvoiceDate) <= 4 THEN 1
		WHEN MONTH(si.InvoiceDate) >= 5 AND MONTH(si.InvoiceDate) <= 8 THEN 2
		ELSE 3
	END																				AS InvoiceThirdOfTheYear,
	CONVERT(DATE, si.ConfirmedDeliveryTime)											AS DeliveryDate,
	sil.UnitPrice																	AS Price,
	sil.Quantity																	AS Quantity
FROM
	Sales.Invoices AS si
	INNER JOIN Sales.InvoiceLines AS sil
		ON si.InvoiceID = sil.InvoiceID
WHERE
	sil.UnitPrice > 100
	OR sil.Quantity > 20
ORDER BY
	DATENAME(QUARTER, si.InvoiceDate),
	CASE
		WHEN MONTH(si.InvoiceDate) >= 1 AND MONTH(si.InvoiceDate) <= 4 THEN 1
		WHEN MONTH(si.InvoiceDate) >= 5 AND MONTH(si.InvoiceDate) <= 8 THEN 2
		ELSE 3
	END,
	si.InvoiceDate;

-- ������� �� ���������
SELECT
	si.InvoiceID																	AS InvoiceID,
	si.InvoiceDate																	AS InvoiceDate,
	DATENAME(MONTH, si.InvoiceDate)													AS InvoiceMonthOfTheYear,
	DATENAME(QUARTER, si.InvoiceDate)												AS InvoiceQuarterOfTheYear,
	CASE
		WHEN MONTH(si.InvoiceDate) >= 1 AND MONTH(si.InvoiceDate) <= 4 THEN 1
		WHEN MONTH(si.InvoiceDate) >= 5 AND MONTH(si.InvoiceDate) <= 8 THEN 2
		ELSE 3
	END																				AS InvoiceThirdOfTheYear,
	CONVERT(DATE, si.ConfirmedDeliveryTime)											AS DeliveryDate,
	sil.UnitPrice																	AS Price,
	sil.Quantity																	AS Quantity
FROM
	Sales.Invoices AS si
	INNER JOIN Sales.InvoiceLines AS sil
		ON si.InvoiceID = sil.InvoiceID
WHERE
	sil.UnitPrice > 100
	OR sil.Quantity > 20
ORDER BY
	DATENAME(QUARTER, si.InvoiceDate),
	CASE
		WHEN MONTH(si.InvoiceDate) >= 1 AND MONTH(si.InvoiceDate) <= 4 THEN 1
		WHEN MONTH(si.InvoiceDate) >= 5 AND MONTH(si.InvoiceDate) <= 8 THEN 2
		ELSE 3
	END,
	si.InvoiceDate
	OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY;


-- 4.
-- ������ �����������, ������� ���� ��������� �� 2014� ��� � ��������� Road Freight ��� Post,
-- �������� �������� ����������, ��� ����������� ���� ������������ �����
SELECT DISTINCT
	ppo.PurchaseOrderID			AS PurchaseOrderID,
	ppo.OrderDate				AS OrderDate,
	ps.SupplierName				AS Supplier,
	ap.FullName					AS ContactPerson,
	adm.DeliveryMethodName		AS DeliveryMethod
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



-- 5. 10 ��������� �� ���� ������ � ������ ������� � ������ ����������, ������� ������� �����.
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



-- 6. ��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� Chocolate frogs 250g
SELECT
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

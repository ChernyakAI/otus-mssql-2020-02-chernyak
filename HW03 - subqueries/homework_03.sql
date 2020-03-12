-- Для всех заданий где возможно, сделайте 2 варианта запросов:
-- 1) через вложенный запрос
-- 2) через WITH (для производных таблиц)


-- 1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.

-- вариант с подзапросом
SELECT DISTINCT
	ap.PersonID AS PersonID,
	ap.FullName AS PersonFullName
FROM [Application].People AS ap
	WHERE ap.IsSalesperson = 1
		AND NOT EXISTS (SELECT *
						FROM Sales.Invoices AS si
						WHERE si.SalespersonPersonID = ap.PersonID
					   );

-- вариант с табличным выражением
WITH SalesPersons(PersonID, PersonFullName)
AS
(
	SELECT
		ap.PersonID AS PersonID,
		ap.FullName AS PersonFullName
	FROM [Application].People AS ap
	WHERE ap.IsSalesperson = 1
)
SELECT DISTINCT sp.*
FROM SalesPersons AS sp
	LEFT JOIN Sales.Invoices AS si
		ON si.SalespersonPersonID = sp.PersonID
WHERE si.InvoiceID is null;


-- 2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса. 

SELECT ws.StockItemName, ws.UnitPrice
FROM Warehouse.StockItems AS ws
WHERE ws.UnitPrice = (SELECT MIN(UnitPrice) FROM Warehouse.StockItems);
	
SELECT ws.StockItemName, ws.UnitPrice
FROM Warehouse.StockItems AS ws
WHERE ws.UnitPrice <= ALL (SELECT UnitPrice FROM Warehouse.StockItems);



-- 3. Выберите информацию по клиентам, которые перевели компании 5 максимальных платежей из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)

-- вариант с табличным выражением
WITH BigSales (CustomerID, CustomerName, TransactionAmount)
AS 
(SELECT TOP 5 sc.CustomerID, sc.CustomerName, sct.TransactionAmount
FROM Sales.CustomerTransactions AS sct
	INNER JOIN Sales.Customers AS sc
		ON sc.CustomerID = sct.CustomerID 
ORDER BY sct.TransactionAmount DESC	
)
SELECT CustomerID, CustomerName
FROM BigSales
GROUP BY CustomerID, CustomerName; 

-- вариант с подзапросом
SELECT DISTINCT sc.CustomerID, sc.CustomerName
FROM Sales.CustomerTransactions AS sct
	INNER JOIN Sales.Customers AS sc
		ON sc.CustomerID = sct.CustomerID 
WHERE sct.TransactionAmount >= ANY (SELECT TOP 5 TransactionAmount
									FROM Sales.CustomerTransactions AS sct
									ORDER BY sct.TransactionAmount DESC	
								   );

-- ещё один вариант с подзапросом
SELECT DISTINCT sc.CustomerID, sc.CustomerName
FROM Sales.CustomerTransactions AS sct
	INNER JOIN Sales.Customers AS sc
		ON sc.CustomerID = sct.CustomerID 
WHERE sct.TransactionAmount IN (SELECT TOP 5 TransactionAmount
								FROM Sales.CustomerTransactions AS sct
								ORDER BY sct.TransactionAmount DESC	
							   );



-- 4. Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, а также Имя сотрудника, который осуществлял упаковку заказов

-- вариант с табличным выражением
WITH TheMostExpensiveGoods(StockItemID)
AS (
	SELECT TOP 3 wsi.StockItemID
	FROM Warehouse.StockItems AS wsi
	ORDER BY wsi.UnitPrice DESC
)
SELECT DISTINCT
	ac.CityID AS CityID,
	ac.CityName AS CityName,
	ap.FullName AS Packer
FROM TheMostExpensiveGoods AS meg
	INNER JOIN Sales.InvoiceLines AS sil
		ON sil.StockItemID = meg.StockItemID
	INNER JOIN Sales.Invoices AS si
		ON si.InvoiceID = sil.InvoiceID
	INNER JOIN [Application].People AS ap
		ON ap.PersonID = si.PackedByPersonID
	INNER JOIN Sales.Customers AS sc
		ON sc.CustomerID = si.CustomerID
	INNER JOIN [Application].Cities AS ac
		ON ac.CityID = sc.DeliveryCityID
ORDER BY
	CityID,
	CityName,
	Packer;


-- вариант с подзапросом
SELECT DISTINCT
	ac.CityID AS CityID,
	ac.CityName AS CityName,
	ap.FullName AS Packer
FROM Sales.InvoiceLines AS sil
	INNER JOIN Sales.Invoices AS si
		ON si.InvoiceID = sil.InvoiceID
	INNER JOIN [Application].People AS ap
		ON ap.PersonID = si.PackedByPersonID
	INNER JOIN Sales.Customers AS sc
		ON sc.CustomerID = si.CustomerID
	INNER JOIN [Application].Cities AS ac
		ON ac.CityID = sc.DeliveryCityID
WHERE sil.StockItemID in (SELECT TOP 3 wsi.StockItemID FROM Warehouse.StockItems AS wsi ORDER BY wsi.UnitPrice DESC)
ORDER BY
	CityID,
	CityName,
	Packer;



-- 5. Объясните, что делает и оптимизируйте запрос:

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
									FROM Sales.Orders
									WHERE
										Orders.PickingCompletedWhen IS NOT NULL	
										AND Orders.OrderId = Invoices.OrderId
									)	
	) AS TotalSummForPickedItems
	FROM Sales.Invoices 
		JOIN (
				SELECT InvoiceId, SUM(Quantity * UnitPrice) AS TotalSumm
				FROM Sales.InvoiceLines
				GROUP BY InvoiceId
				HAVING SUM(Quantity * UnitPrice) > 27000
			 ) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC;
/*
Описание:
	Запрос выбирает идентификатор, дату, продавца товара, общую сумму счёта, сумму скомплектованного заказа 
	из всех счетов, которые были выставлены более чем на 27000
*/

-- оптимизированная версия
WITH SalesTotals(InvoiceId, TotalSumm)
AS
(
	SELECT InvoiceId, SUM(Quantity * UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity * UnitPrice) > 27000
)
SELECT 
	si.InvoiceID, 
	si.InvoiceDate,
	ap.FullName AS SalesPersonName,
	st.TotalSumm AS TotalSummByInvoice, 
	(
		SELECT SUM(sol.PickedQuantity * sol.UnitPrice)
		FROM Sales.OrderLines AS sol
			INNER JOIN Sales.Orders AS so
				ON sol.OrderID = so.OrderID
		WHERE so.OrderId = si.OrderId
			AND so.PickingCompletedWhen IS NOT NULL	
	) AS TotalSummForPickedItems
	FROM Sales.Invoices AS si
		INNER JOIN [Application].People AS ap
			ON  ap.PersonID = si.SalespersonPersonID
		INNER JOIN SalesTotals AS st
			ON si.InvoiceID = st.InvoiceID
ORDER BY TotalSummByInvoice DESC;



-- Приложите план запроса и его анализ, а также ход ваших рассуждений по поводу оптимизации. 
-- Можно двигаться как в сторону улучшения читабельности запроса (что уже было в материале лекций), так и в сторону упрощения плана\ускорения.

-- Способы оптимизации:
--		1. Перенёс подзапрос получения имени продавца в секцию соединения таблиц -> запрос немного упрощается, расчётное количество строк в плане запроса уменьшается;
--		2. Вынес получение счетов более 27000 в табличное выражение -> секцию соединения таблиц стало проще читать;
--		3. Подзапрос из подзапроса вычисления суммы скомплектованного заказа можно заменить обычным внутренним соединением

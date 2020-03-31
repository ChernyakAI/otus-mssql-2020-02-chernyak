-- =============================================
-- Author:		Chernyak Andrey
-- Create date: 2020-03-28
-- Alter date: 	
-- Description:	Оконные функции
-- =============================================

/*
1. Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните планы.
В качестве запроса с временной таблицей и табличной переменной можно взять свой запрос или следующий запрос:
Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки)
Выведите id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом
Пример
Дата продажи Нарастающий итог по месяцу
2015-01-29 4801725.31
2015-01-30 4801725.31
2015-01-31 4801725.31
2015-02-01 9626342.98
2015-02-02 9626342.98
2015-02-03 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

-- 1. Вариант с временной таблицей
DROP TABLE IF EXISTS #MonthlySales 
CREATE TABLE #MonthlySales (
    Month Date,
    TotalSum DECIMAL(18, 2)
)
INSERT INTO #MonthlySales
SELECT
    DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate) AS Month,
    SUM(sil.ExtendedPrice) AS TotalSum
FROM Sales.Invoices AS si
    INNER JOIN Sales.InvoiceLines AS sil
        ON sil.InvoiceID = si.InvoiceID
WHERE si.InvoiceDate >= '20150101'
GROUP BY DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate);
--SELECT * FROM #MonthlySales ORDER BY Month

SELECT
    si.InvoiceID,
    sc.CustomerName,
    si.InvoiceDate,
    sil.ExtendedPrice AS TotalAmount,
    (
        SELECT SUM(TotalSum)
        FROM #MonthlySales
        WHERE Month <= DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate)
    ) AS CumulativeAmount
FROM Sales.Invoices AS si
    INNER JOIN Sales.InvoiceLines AS sil
        ON sil.InvoiceID = si.InvoiceID
    INNER JOIN Sales.Customers AS sc
        ON sc.CustomerID = si.CustomerID
WHERE si.InvoiceDate >= '20150101';


-- 2. Вариант с табличной переменной
SET STATISTICS IO ON;
DECLARE @MonthlySales TABLE  (
    Month Date,
    TotalSum DECIMAL(18, 2)
)
INSERT INTO @MonthlySales
SELECT
    DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate) AS Month,
    SUM(sil.ExtendedPrice) AS TotalSum
FROM Sales.Invoices AS si
    INNER JOIN Sales.InvoiceLines AS sil
        ON sil.InvoiceID = si.InvoiceID
WHERE si.InvoiceDate >= '20150101'
GROUP BY DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate);

SELECT
    si.InvoiceID,
    sc.CustomerName,
    si.InvoiceDate,
    sil.ExtendedPrice AS TotalAmount,
    (
        SELECT SUM(TotalSum)
        FROM @MonthlySales
        WHERE Month <= DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate)
    ) AS CumulativeAmount
FROM Sales.Invoices AS si
    INNER JOIN Sales.InvoiceLines AS sil
        ON sil.InvoiceID = si.InvoiceID
    INNER JOIN Sales.Customers AS sc
        ON sc.CustomerID = si.CustomerID
WHERE si.InvoiceDate >= '20150101';

-- Планы практически не отличаются


/*
2. Если вы брали предложенный выше запрос, то сделайте расчет суммы нарастающим итогом с помощью оконной функции.
Сравните 2 варианта запроса - через windows function и без них. Написать какой быстрее выполняется, сравнить по set statistics time on;
*/
SET STATISTICS IO ON;
SELECT DISTINCT
    si.InvoiceID,
    sc.CustomerName,
    si.InvoiceDate,
    SUM(sil.ExtendedPrice) OVER (PARTITION BY si.InvoiceID) AS TotalAmount,
    SUM(sil.ExtendedPrice) OVER (ORDER BY DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate) RANGE UNBOUNDED PRECEDING) AS CumulativeAmount 
FROM Sales.Invoices AS si
    INNER JOIN Sales.InvoiceLines AS sil
        ON sil.InvoiceID = si.InvoiceID
    INNER JOIN Sales.Customers AS sc
        ON sc.CustomerID = si.CustomerID
WHERE si.InvoiceDate >= '20150101'
ORDER BY si.InvoiceID,
    sc.CustomerName,
    si.InvoiceDate;

/*
Без оконной функции:
Table '#B9BFF821'. Scan count 0, logical reads 17, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 1, logical reads 11400, physical reads 3, read-ahead reads 11388, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'InvoiceLines'. Scan count 1, logical reads 5003, physical reads 3, read-ahead reads 4978, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
(17 rows affected)
(101356 rows affected)
Table 'InvoiceLines'. Scan count 1, logical reads 5003, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table '#B9BFF821'. Scan count 31440, logical reads 31440, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 1, logical reads 11400, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Customers'. Scan count 1, logical reads 40, physical reads 1, read-ahead reads 31, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Total execution time: 00:00:09.172
С оконной функцией:
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'InvoiceLines'. Scan count 1, logical reads 5003, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 1, logical reads 11400, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Customers'. Scan count 1, logical reads 40, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Total execution time: 00:00:00.865
*/

/*
2. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)
*/
SET STATISTICS IO ON;
SELECT
    Temp_2.Month
    , Temp_2.StockItemName
FROM
    (
        SELECT
            Temp_1.*
            , ROW_NUMBER() OVER (PARTITION BY Temp_1.Month ORDER BY Temp_1.Quantity DESC) RowNumber
        FROM
            (
                SELECT DISTINCT
                    DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate) AS Month
                    , wsi.StockItemName
                    , SUM(sil.Quantity) OVER (PARTITION BY DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate), wsi.StockItemName) AS Quantity
                FROM Sales.Invoices AS si
                    INNER JOIN Sales.InvoiceLines AS sil
                        ON sil.InvoiceID = si.InvoiceID
                    INNER JOIN Warehouse.StockItems AS wsi
                        ON wsi.StockItemID = sil.StockItemID
                WHERE si.InvoiceDate >= '20160101'
                    AND si.InvoiceDate < '20170101'
            ) AS Temp_1
    ) AS Temp_2
WHERE Temp_2.RowNumber <= 2
ORDER BY Month,
    Quantity;

/*
3. Функции одним запросом
Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
3.1 пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
3.2 посчитайте общее количество товаров и выведете полем в этом же запросе
3.3 посчитайте общее количество товаров в зависимости от первой буквы названия товара
3.4 отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
3.5 предыдущий ид товара с тем же порядком отображения (по имени)
3.6 названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
3.7 сформируйте 30 групп товаров по полю вес товара на 1 шт
Для этой задачи НЕ нужно писать аналог без аналитических функций
*/
SELECT
    wsi.StockItemID
    , wsi.StockItemName
    , wsi.Brand
    , wsi.UnitPrice
    , ROW_NUMBER() OVER (PARTITION BY LEFT(wsi.StockItemName, 1) ORDER BY wsi.StockItemName) AS hw_3_1 -- todo
    , COUNT(*) OVER () AS hw_3_2
    , COUNT(*) OVER (PARTITION BY LEFT(wsi.StockItemName, 1)) AS hw_3_3
    , LEAD(wsi.StockItemID) OVER (ORDER BY wsi.StockItemName) AS hw_3_4
    , LAG(wsi.StockItemID) OVER (ORDER BY wsi.StockItemName) AS hw_3_5
    , LAG(wsi.StockItemName, 2, 'No items') OVER (ORDER BY wsi.StockItemName) AS hw_3_6
    , NTILE(30) OVER (PARTITION BY wsi.TypicalWeightPerUnit ORDER BY wsi.StockItemName) AS hw_3_7
FROM Warehouse.StockItems AS wsi
ORDER BY wsi.StockItemName;

/*
4. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
*/
SET STATISTICS IO ON;
SELECT
    si.SalespersonPersonID
    , ap.FullName AS SalesPersonFullName
    , si.CustomerID
    , sc.CustomerName
    , si.InvoiceDate
    , (SELECT SUM(sil.ExtendedPrice) FROM Sales.InvoiceLines AS sil WHERE sil.InvoiceID = si.InvoiceID) AS TotalSum   
FROM
    (
        SELECT
            si.InvoiceID
            , ROW_NUMBER() OVER (PARTITION BY si.SalespersonPersonID ORDER BY si.InvoiceDate DESC) AS RowNumber
        FROM Sales.Invoices AS si
    ) AS LastSales
    INNER JOIN Sales.Invoices AS si
        ON si.InvoiceID = LastSales.InvoiceID
    INNER JOIN Application.People AS ap
        ON ap.PersonID = si.SalespersonPersonID
    INNER JOIN Sales.Customers AS sc
        ON sc.CustomerID = si.CustomerID
WHERE RowNumber = 1;

/*
5. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/
SET STATISTICS IO ON;
SELECT
    CustomerFinal.CustomerID
    , CustomerFinal.CustomerName
    , CustomerFinal.StockItemName
    , CustomerFinal.UnitPrice
    , si.InvoiceDate
FROM
    (
        SELECT
            CustomersItems.CustomerID
            , CustomersItems.CustomerName
            , CustomersItems.StockItemName
            , CustomersItems.UnitPrice
            , ROW_NUMBER() OVER (PARTITION BY CustomersItems.CustomerID ORDER BY CustomersItems.UnitPrice DESC) RowNumber
        FROM
            (
                SELECT DISTINCT
                    si.CustomerID
                    , sc.CustomerName
                    , ws.StockItemName
                    , ws.UnitPrice
                FROM Sales.Invoices AS si
                    INNER JOIN Sales.InvoiceLines AS sil
                        ON sil.InvoiceID = si.InvoiceID
                    INNER JOIN Sales.Customers AS sc
                        ON sc.CustomerID = si.CustomerID
                    INNER JOIN Warehouse.StockItems AS ws
                        ON ws.StockItemID = sil.StockItemID
            ) AS CustomersItems
    ) AS CustomerFinal
    LEFT JOIN Sales.InvoiceLines AS sil
        ON sil.StockItemID = CustomerFinal.CustomerID
    INNER JOIN Sales.Invoices AS si
        ON si.InvoiceID = sil.InvoiceID
WHERE CustomerFinal.RowNumber <= 2
ORDER BY CustomerFinal.CustomerID;


/*
Опционально можно сделать вариант запросов для заданий 2,4,5 без использования windows function и сравнить скорость как в задании 1.
*/

-- Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)
SET STATISTICS IO ON;
WITH Months AS
(
    SELECT
        DATEADD(DAY, 1 - DAY(si.InvoiceDate), si.InvoiceDate) AS Month
        , sil.StockItemID
        , SUM(sil.Quantity) AS Quantity
    FROM Sales.Invoices AS si
        INNER JOIN Sales.InvoiceLines AS sil
            ON sil.InvoiceID = si.InvoiceID
    WHERE si.InvoiceDate >= '20160101'
        AND si.InvoiceDate < '20170101'
    GROUP BY DATEADD(DAY, 1 - DAY(si.InvoiceDate), si.InvoiceDate),
        sil.StockItemID
)

SELECT DISTINCT
    DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate) AS Month
    , wsi.StockItemName
FROM Sales.Invoices AS si
    INNER JOIN Sales.InvoiceLines AS sil
        ON sil.InvoiceID = si.InvoiceID
    INNER JOIN Warehouse.StockItems AS wsi
        ON wsi.StockItemID = sil.StockItemID
WHERE si.InvoiceDate >= '20160101'
    AND si.InvoiceDate < '20170101'
    AND (sil.StockItemID = (
            SELECT StockItemID
            FROM Months
            WHERE Month = DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate)
            ORDER BY Month, Quantity DESC
                OFFSET 0 ROWS  
                FETCH NEXT 1 ROWS ONLY
        )
    )
UNION ALL
SELECT DISTINCT
    DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate) AS Month
    , wsi.StockItemName
FROM Sales.Invoices AS si
    INNER JOIN Sales.InvoiceLines AS sil
        ON sil.InvoiceID = si.InvoiceID
    INNER JOIN Warehouse.StockItems AS wsi
        ON wsi.StockItemID = sil.StockItemID
WHERE si.InvoiceDate >= '20160101'
    AND si.InvoiceDate < '20170101'
    AND (sil.StockItemID = (
                SELECT StockItemID
                FROM Months
                WHERE Month = DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate)
                ORDER BY Month, Quantity DESC
                    OFFSET 1 ROWS  
                    FETCH NEXT 1 ROWS ONLY)
    )
ORDER BY Month, wsi.StockItemName;

/*
Запрос с оконными функциями:
Table 'StockItems'. Scan count 1, logical reads 6, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'InvoiceLines'. Scan count 4, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 504, lob physical reads 3, lob read-ahead reads 783.
Table 'InvoiceLines'. Segment reads 1, segment skipped 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 3, logical reads 11994, physical reads 0, read-ahead reads 11408, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Total execution time: 00:00:00.502

Запрос без оконных функций:
Table 'InvoiceLines'. Scan count 478348, logical reads 5717860, physical reads 43, read-ahead reads 69, lob logical reads 489, lob physical reads 2, lob read-ahead reads 777.
Table 'InvoiceLines'. Segment reads 2, segment skipped 0.
Table 'Worktable'. Scan count 260, logical reads 292960, physical reads 0, read-ahead reads 6352, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'StockItems'. Scan count 2, logical reads 12, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 4, logical reads 45600, physical reads 3, read-ahead reads 11388, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Total execution time: 00:00:07.309
*/

-- По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
-- В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
SET STATISTICS IO ON;
WITH LastInvoices AS
(
    SELECT
        si.SalespersonPersonID
        , MAX(si.InvoiceID) AS Invoice
        , SUM(sil.ExtendedPrice) AS TotalSum
    FROM Sales.Invoices AS si
        INNER JOIN Sales.InvoiceLines AS sil
            ON sil.InvoiceID = si.InvoiceID
    GROUP BY si.SalespersonPersonID
)
SELECT
    li.SalespersonPersonID
    , ap.FullName
    , sc.CustomerID
    , sc.CustomerName
    , si.InvoiceDate
    , (
        SELECT SUM(inl.ExtendedPrice)
        FROM Sales.InvoiceLines AS inl
        WHERE inl.InvoiceID = li.Invoice
        GROUP BY inl.InvoiceID
    ) AS TotalSum
FROM LastInvoices AS li
    INNER JOIN Application.People AS ap
        ON ap.PersonID = li.SalespersonPersonID
    INNER JOIN Sales.Invoices AS si
        ON si.InvoiceID = li.Invoice
    INNER JOIN Sales.Customers AS sc
        ON sc.CustomerID = si.CustomerID;

/*
Запрос с оконными функциями:
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 2, logical reads 22800, physical reads 0, read-ahead reads 11408, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'People'. Scan count 1, logical reads 11, physical reads 1, read-ahead reads 2, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Customers'. Scan count 1, logical reads 40, physical reads 1, read-ahead reads 31, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'InvoiceLines'. Scan count 1, logical reads 5003, physical reads 3, read-ahead reads 4896, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Total execution time: 00:00:02.972

Запрос без оконных функций:
Table 'InvoiceLines'. Scan count 12, logical reads 125, physical reads 2, read-ahead reads 0, lob logical reads 322, lob physical reads 0, lob read-ahead reads 772.
Table 'InvoiceLines'. Segment reads 1, segment skipped 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Customers'. Scan count 1, logical reads 40, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 1, logical reads 168, physical reads 1, read-ahead reads 136, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'People'. Scan count 0, logical reads 20, physical reads 2, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Total execution time: 00:00:00.554
*/


-- Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
-- В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
SET STATISTICS IO ON;

SELECT DISTINCT
    si.CustomerID
    , sc.CustomerName
    , sil.StockItemID
    , sil.UnitPrice
    , si.InvoiceDate
FROM Sales.Invoices AS si
    INNER JOIN Sales.InvoiceLines as sil
        ON sil.InvoiceID = si.InvoiceID
    INNER JOIN Sales.Customers AS sc
        ON sc.CustomerID = si.CustomerID
WHERE sil.StockItemID = (
        SELECT TOP(1)
            sil_2.StockItemID
        FROM Sales.Invoices AS si_2
            INNER JOIN Sales.InvoiceLines as sil_2
                ON sil_2.InvoiceID = si_2.InvoiceID
        WHERE si_2.CustomerID = si.CustomerID
        ORDER BY sil_2.UnitPrice DESC
    )

UNION ALL

SELECT DISTINCT
    si.CustomerID
    , sc.CustomerName
    , sil.StockItemID
    , sil.UnitPrice
    , si.InvoiceDate
FROM Sales.Invoices AS si
    INNER JOIN Sales.InvoiceLines as sil
        ON sil.InvoiceID = si.InvoiceID
    INNER JOIN Sales.Customers AS sc
        ON sc.CustomerID = si.CustomerID        
WHERE sil.StockItemID = (
        SELECT TOP(1)
            sil_1.StockItemID
        FROM Sales.Invoices AS si_1
            INNER JOIN Sales.InvoiceLines as sil_1
                ON sil_1.InvoiceID = si_1.InvoiceID
        WHERE si_1.CustomerID = si.CustomerID
            AND sil_1.StockItemID <> (
                SELECT TOP(1)
                    sil_2.StockItemID
                FROM Sales.Invoices AS si_2
                    INNER JOIN Sales.InvoiceLines as sil_2
                        ON sil_2.InvoiceID = si_2.InvoiceID
                WHERE si_2.CustomerID = si.CustomerID
                ORDER BY sil_2.UnitPrice DESC
            )
        ORDER BY sil_1.UnitPrice DESC
    )
ORDER BY si.CustomerID, sil.UnitPrice

-- вариант с оконными функциями:
/*
Table 'InvoiceLines'. Scan count 4, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 314, lob physical reads 0, lob read-ahead reads 0.
Table 'InvoiceLines'. Segment reads 2, segment skipped 0.
Table 'Worktable'. Scan count 201, logical reads 418865, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 2, logical reads 11566, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Customers'. Scan count 1, logical reads 40, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'StockItems'. Scan count 1, logical reads 16, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Total execution time: 00:00:07.529
*/

-- вариант без оконных функций:
/*
Table 'InvoiceLines'. Scan count 211534, logical reads 2548317, physical reads 0, read-ahead reads 0, lob logical reads 322, lob physical reads 0, lob read-ahead reads 0.
Table 'InvoiceLines'. Segment reads 2, segment skipped 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 1991, logical reads 27342, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Customers'. Scan count 2, logical reads 80, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Total execution time: 00:00:03.428
*/



/*
Bonus из предыдущей темы
Напишите запрос, который выбирает 10 клиентов, которые сделали больше 30 заказов и последний заказ был не позднее апреля 2016.
*/
SELECT TOP(10)
    *
FROM
(
    SELECT
        so.CustomerID
        , MAX(so.OrderDate) AS LastCustomerOrder -- OVER(PARTITION BY so.CustomerID)
        , COUNT(*) AS OrdersCount -- OVER(PARTITION BY so.CustomerID)
    FROM Sales.Orders AS so
    GROUP BY so.CustomerID
) AS Temp
WHERE Temp.LastCustomerOrder < '20160401'
    AND Temp.OrdersCount > 30
;
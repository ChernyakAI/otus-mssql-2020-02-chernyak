-- =============================================
-- Author:		Chernyak Andrey
-- Create date: 2020-06-21
-- Description:	Решение ДЗ по теме GROUP BY и HAVING
-- =============================================

USE WideWorldImporters;
GO

-- 1. Посчитать среднюю цену товара, общую сумму продажи по месяцам

SELECT 
	FORMAT(si.InvoiceDate, 'yyyyMM')	AS MonthOfSales,
	SUM(sil.ExtendedPrice)				AS TotalSales,
	AVG(ws.UnitPrice)					AS AverageUnitPrice
FROM Sales.Invoices AS si
	INNER JOIN Sales.InvoiceLines AS sil
		ON sil.InvoiceID = si.InvoiceID
	INNER JOIN Warehouse.StockItems AS ws
		ON ws.StockItemID = sil.StockItemID
GROUP BY FORMAT(si.InvoiceDate, 'yyyyMM')
ORDER BY MonthOfSales;


-- 2. Отобразить все месяцы, где общая сумма продаж превысила 10000

SELECT FORMAT(si.InvoiceDate, 'yyyyMM')	AS MonthOfSales
FROM Sales.Invoices AS si
	INNER JOIN Sales.InvoiceLines AS sil
		ON sil.InvoiceID = si.InvoiceID
GROUP BY FORMAT(si.InvoiceDate, 'yyyyMM')
HAVING SUM(sil.ExtendedPrice) > 10000
ORDER BY MonthOfSales;


-- 3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
--    Группировка должна быть по году и месяцу.

SELECT
	YEAR(si.InvoiceDate)	AS Year,
	MONTH(si.InvoiceDate)	AS Month,
	MIN(si.InvoiceDate)		AS FirstSaleDate,
	SUM(sil.ExtendedPrice)	AS MonthlySales
FROM Sales.Invoices AS si
	INNER JOIN Sales.InvoiceLines AS sil
		ON sil.InvoiceID = si.InvoiceID
GROUP BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate)
HAVING SUM(sil.Quantity) < 50
ORDER BY Year, Month;


-- 4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
-- Дано:
/*
CREATE TABLE dbo.MyEmployees
(
	EmployeeID smallint NOT NULL,
	FirstName nvarchar(30) NOT NULL,
	LastName nvarchar(40) NOT NULL,
	Title nvarchar(50) NOT NULL,
	DeptID smallint NOT NULL,
	ManagerID int NULL,
	CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);
INSERT INTO dbo.MyEmployees
VALUES
	(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL),
	(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1),
	(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273),
	(275, N'Michael', N'Blythe', N'Sales Representative',3,274),
	(276, N'Linda', N'Mitchell', N'Sales Representative',3,274),
	(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273),
	(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285),
	(16, N'David',N'Bradley', N'Marketing Manager', 4, 273),
	(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);


Результат вывода рекурсивного CTE:
EmployeeID		Name			Title							EmployeeLevel
1				Ken Sánchez		Chief Executive	Officer			1
273				Brian Welcker	Vice President of Sales			2
16				David Bradley	Marketing Manager				3
23				Mary Gibson		Marketing Specialist			4
274				Stephen Jiang	North American Sales Manager	3
276				Linda Mitchell	Sales Representative			4
275				Michael Blythe	Sales Representative			4
285				Syed Abbas		Pacific Sales Manager			3
286				Lynn Tsoflias	Sales Representative			4
*/


-- а. Временная таблица
DROP TABLE IF EXISTS #T1;
WITH RecursiveCTE AS
(
	SELECT
		EmployeeID						AS EmployeeID,
		FirstName + ' ' + LastName		AS Name,
		Title							AS Title,
		1								AS EmployeeLevel,
		CAST(EmployeeID	AS VARCHAR(255))	AS TreePath	
	FROM dbo.MyEmployees
	WHERE ManagerID IS NULL

	UNION ALL

	SELECT
		t1.EmployeeID,
		t1.FirstName + ' ' + t1.LastName,
		t1.Title,
		t2.EmployeeLevel + 1,
		CAST(t2.TreePath + '_' + CAST(t1.EmployeeID	AS VARCHAR(255)) AS VARCHAR(255))
	FROM dbo.MyEmployees AS t1
		INNER JOIN RecursiveCTE AS t2 ON t2.EmployeeID = t1.ManagerID
)
SELECT *
INTO #T1
FROM RecursiveCTE;

SELECT EmployeeID, Name, Title, EmployeeLevel
FROM #T1
ORDER BY TreePath;

-- б. Табличная переменная
DECLARE @T2 Table
(
	EmployeeID SMALLINT,
	Name NVARCHAR(70),
	Title NVARCHAR(50),
	EmployeeLevel SMALLINT,
	TreePath NVARCHAR(255)
);
WITH RecursiveCTE AS
(
	SELECT
		EmployeeID						AS EmployeeID,
		FirstName + ' ' + LastName		AS Name,
		Title							AS Title,
		1								AS EmployeeLevel,
		CAST(EmployeeID	AS NVARCHAR(255))	AS TreePath	
	FROM dbo.MyEmployees
	WHERE ManagerID IS NULL

	UNION ALL

	SELECT
		t1.EmployeeID,
		t1.FirstName + ' ' + t1.LastName,
		t1.Title,
		t2.EmployeeLevel + 1,
		CAST(t2.TreePath + '_' + CAST(t1.EmployeeID	AS NVARCHAR(255)) AS NVARCHAR(255))
	FROM dbo.MyEmployees AS t1
		INNER JOIN RecursiveCTE AS t2 ON t2.EmployeeID = t1.ManagerID
)
INSERT INTO @T2
SELECT *
FROM RecursiveCTE;

SELECT EmployeeID, Name, Title, EmployeeLevel
FROM @T2
ORDER BY TreePath;



-- Опционально: Написать все эти же запросы, но, если за какой-то месяц не было продаж, то этот месяц тоже должен быть в результате и там должны быть нули.

DECLARE @PeriodBegin DATE, @PeriodEnd DATE;
SET @PeriodBegin = (SELECT MIN(InvoiceDate) FROM Sales.Invoices);
SET @PeriodEnd = (SELECT MAX(InvoiceDate) FROM Sales.Invoices);
--SET @PeriodEnd = '20170101'; -- для проверки корректности, т.к. за все месяцы есть продажи

-- 1.


WITH CTE_Periods
AS
(
	SELECT @PeriodBegin AS Period
	UNION ALL
	SELECT DATEADD(MONTH, 1, cp.Period)
	FROM CTE_Periods AS cp
	WHERE cp.Period < DATEADD(MONTH, -1, @PeriodEnd)
)
SELECT
	UnionTable.MonthOfSales				AS MonthOfSales,
	MAX(UnionTable.TotalSales)			AS TotalSales,
	MAX(UnionTable.AverageUnitPrice)	AS AverageUnitPrice
FROM
(
	SELECT
		cp.Period AS MonthOfSales,
		0 AS TotalSales,
		0 AS AverageUnitPrice
	FROM CTE_Periods AS cp
	UNION
	SELECT
		DATEADD(DAY, 1 - DAY(si.InvoiceDate), si.InvoiceDate)	AS MonthOfSales,
		SUM(sil.ExtendedPrice)									AS TotalSales,
		AVG(ws.UnitPrice)										AS AverageUnitPrice
	FROM Sales.Invoices AS si
		INNER JOIN Sales.InvoiceLines AS sil ON sil.InvoiceID = si.InvoiceID 
		INNER JOIN Warehouse.StockItems AS ws ON ws.StockItemID = sil.StockItemID
	GROUP BY DATEADD(DAY, 1 - DAY(si.InvoiceDate), si.InvoiceDate)
) AS UnionTable 
GROUP BY MonthOfSales
ORDER BY MonthOfSales;


-- 3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
--    Группировка должна быть по году и месяцу.

WITH CTE_Periods
AS
(
	SELECT @PeriodBegin AS Period
	UNION ALL
	SELECT DATEADD(MONTH, 1, cp.Period)
	FROM CTE_Periods AS cp
	WHERE cp.Period < DATEADD(MONTH, -1, @PeriodEnd)
)
SELECT
	UnionTable.Year				AS Year,
	UnionTable.Month				AS Month,
	MAX(UnionTable.FirstSaleDate)	AS FirstSaleDate,
	ISNULL(MAX(UnionTable.MonthlySales), 0)	AS MonthlySales
FROM
(
	SELECT
		YEAR(cp.Period) AS Year,
		MONTH(cp.Period) AS Month,
		NULL AS FirstSaleDate,
		NULL AS MonthlySales
	FROM CTE_Periods AS cp
	UNION

	SELECT
		YEAR(si.InvoiceDate)	AS Year,
		MONTH(si.InvoiceDate)	AS Month,
		MIN(si.InvoiceDate)		AS FirstSaleDate,
		SUM(sil.ExtendedPrice)	AS MonthlySales
	FROM Sales.Invoices AS si
		INNER JOIN Sales.InvoiceLines AS sil
			ON sil.InvoiceID = si.InvoiceID
	GROUP BY YEAR(si.InvoiceDate), MONTH(si.InvoiceDate)
	HAVING SUM(sil.Quantity) < 50

) AS UnionTable 
GROUP BY Year, Month
ORDER BY Year, Month;








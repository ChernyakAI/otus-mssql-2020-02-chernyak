-- =============================================
-- Author:		Chernyak Andrey
-- Create date: 2020-04-22
-- Alter date:  2020-04-25	
-- Description:	stored procedures, functions, isolation levels
-- =============================================
USE WideWorldImporters;
GO



---------- 1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.

DROP FUNCTION IF EXISTS dbo.GetCustomerWithMaxTotalInvoiceSum;
GO
CREATE FUNCTION dbo.GetCustomerWithMaxTotalInvoiceSum()
	RETURNS NVARCHAR(100)
AS
BEGIN
	
	DECLARE @Result NVARCHAR(100);

	WITH MaxInvoiceSum AS
	(
		SELECT TOP(1)
			sil.InvoiceID
			, SUM(sil.Quantity * sil.UnitPrice) AS TotalSum
		FROM Sales.InvoiceLines AS sil
		GROUP BY sil.InvoiceID
		ORDER BY TotalSum DESC
	)
	SELECT @Result = sc.CustomerName
	FROM MaxInvoiceSum AS mis
		INNER JOIN Sales.Invoices AS si
			ON si.InvoiceID = mis.InvoiceID
		INNER JOIN Sales.Customers AS sc
			ON sc.CustomerID = si.CustomerID

	RETURN @Result;

END;
GO

-- вызов
SELECT dbo.GetCustomerWithMaxTotalInvoiceSum();



---------- 2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
---------- Использовать таблицы :
----------     Sales.Customers
----------     Sales.Invoices
----------     Sales.InvoiceLines

DROP PROCEDURE IF EXISTS dbo.GetMaxCustomerInvoiceSum;
GO
CREATE PROCEDURE dbo.GetMaxCustomerInvoiceSum
	@CustomerID INT = NULL
	, @Result DECIMAL(18,2) = 0 OUTPUT
AS
BEGIN

	SET NOCOUNT ON;

	IF @CustomerID IS NULL  
	BEGIN  
	   PRINT 'Внимание: не указан идентификатор покупателя, сумму покупки посчитать невозможно!'  
	   RETURN  
	END

	SET @Result =
	(
		SELECT TOP 1
			SUM(sil.Quantity * sil.UnitPrice) AS TotalSum
		FROM Sales.InvoiceLines AS sil
			INNER JOIN Sales.Invoices AS si
				ON si.InvoiceID = sil.InvoiceID
		WHERE si.CustomerID = 30
		GROUP BY si.InvoiceID
		ORDER BY TotalSum DESC
	)

	RETURN;
END;
GO

-- вызов
DECLARE @CustomerMaxInvoiceSum DECIMAL(18, 2) = 0;
EXEC dbo.GetMaxCustomerInvoiceSum @CustomerID = 30, @Result = @CustomerMaxInvoiceSum OUTPUT;
SELECT @CustomerMaxInvoiceSum;



---------- 3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.

DROP FUNCTION IF EXISTS dbo.TopFiveCustomerTransactions_Function;
GO
CREATE FUNCTION dbo.TopFiveCustomerTransactions_Function(@CustomerID INT) 
RETURNS TABLE  
AS  
RETURN   
(  
    SELECT DISTINCT sct.TransactionDate, sct.TransactionAmount
	FROM Sales.CustomerTransactions AS sct
		INNER JOIN Sales.Customers AS sc
			ON sc.CustomerID = sct.CustomerID 
	WHERE sc.CustomerID = @CustomerID
		AND sct.TransactionAmount >= ANY (SELECT TOP 5 TransactionAmount
										FROM Sales.CustomerTransactions AS sct
										WHERE sct.CustomerID = @CustomerID
										ORDER BY sct.TransactionAmount DESC	
									   )  
);  
GO    

DROP PROCEDURE IF EXISTS dbo.TopFiveCustomerTransactions_Procedure;
GO
CREATE PROCEDURE dbo.TopFiveCustomerTransactions_Procedure
	@CustomerID INT = NULL
AS
BEGIN

	SET NOCOUNT ON;

    SELECT DISTINCT sct.TransactionDate, sct.TransactionAmount
	FROM Sales.CustomerTransactions AS sct
		INNER JOIN Sales.Customers AS sc
			ON sc.CustomerID = sct.CustomerID 
	WHERE sc.CustomerID = @CustomerID
		AND sct.TransactionAmount >= ANY (SELECT TOP 5 TransactionAmount
										FROM Sales.CustomerTransactions AS sct
										WHERE sct.CustomerID = @CustomerID
										ORDER BY sct.TransactionAmount DESC	
									   ) 

END;
GO


SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- вызов функции
SELECT * FROM dbo.TopFiveCustomerTransactions_Function(1);
-- вызов процедуры
EXEC dbo.TopFiveCustomerTransactions_Procedure @CustomerID = 1;

--(5 rows affected)
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'CustomerTransactions'. Scan count 10, logical reads 2252, physical reads 4, read-ahead reads 1125, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'Customers'. Scan count 0, logical reads 2, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

--(1 row affected)
--Table 'Worktable'. Scan count 1, logical reads 46777, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'CustomerTransactions'. Scan count 10, logical reads 2252, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'Customers'. Scan count 0, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0. 

-- по плану в sentry one видно, что стоимость функции ниже, но больше время компиляции:
-- function: 39 ms
-- procedure: 21 ms



---------- 4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.

-- буду использовать табличную функцию из упражнения 3
SELECT
	sc.CustomerID
	, Top5.TransactionDate
	, Top5.TransactionAmount
FROM Sales.Customers AS sc
	CROSS APPLY (SELECT * FROM dbo.TopFiveCustomerTransactions_Function(sc.CustomerID)) AS Top5
ORDER BY sc.CustomerID, Top5.TransactionAmount DESC



---------- Во всех процедурах, в описании укажите для преподавателям
---------- 5) какой уровень изоляции нужен и почему.
-- Минимально достаточным, думаю, будет уровень изоляции по-умолчанию: Read Commited, если мы используем в качестве отчётных данных.
-- Повысить уровень изоляции можно будет, если данные должны будут использоваться в обновлении данных
-- (например, обновление каких-либо данных на основании информации о пяти максимальных сумм в транзакциях покупателя)



---------- Опционально
---------- 6) Переписываем одну и ту же процедуру kitchen sink с множеством входных параметров по поиску в заказах на динамический SQL.
---------- Сравниваем планы запроса.
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

DROP PROCEDURE IF EXISTS dbo.CustomerSearch_KitchenSinkOtus;
GO
CREATE PROCEDURE dbo.CustomerSearch_KitchenSinkOtus
  @CustomerID            int            = NULL,
  @CustomerName          nvarchar(100)  = NULL,
  @BillToCustomerID      int            = NULL,
  @CustomerCategoryID    int            = NULL,
  @BuyingGroupID         int            = NULL,
  @MinAccountOpenedDate  date           = NULL,
  @MaxAccountOpenedDate  date           = NULL,
  @DeliveryCityID        int            = NULL,
  @IsOnCreditHold        bit            = NULL,
  @OrdersCount			 INT			= NULL, 
  @PersonID				 INT			= NULL, 
  @DeliveryStateProvince INT			= NULL,
  @PrimaryContactPersonIDIsEmployee BIT = NULL

AS
BEGIN
  SET NOCOUNT ON;
 
  SELECT CustomerID, CustomerName, IsOnCreditHold
  FROM Sales.Customers AS Client
	JOIN Application.People AS Person ON 
		Person.PersonID = Client.PrimaryContactPersonID
	JOIN Application.Cities AS City ON
		City.CityID = Client.DeliveryCityID
  WHERE (@CustomerID IS NULL 
         OR Client.CustomerID = @CustomerID)
    AND (@CustomerName IS NULL 
         OR Client.CustomerName LIKE @CustomerName)
    AND (@BillToCustomerID IS NULL 
         OR Client.BillToCustomerID = @BillToCustomerID)
    AND (@CustomerCategoryID IS NULL 
         OR Client.CustomerCategoryID = @CustomerCategoryID)
    AND (@BuyingGroupID IS NULL 
         OR Client.BuyingGroupID = @BuyingGroupID)
    AND Client.AccountOpenedDate >= 
        COALESCE(@MinAccountOpenedDate, Client.AccountOpenedDate)
    AND Client.AccountOpenedDate <= 
        COALESCE(@MaxAccountOpenedDate, Client.AccountOpenedDate)
    AND (@DeliveryCityID IS NULL 
         OR Client.DeliveryCityID = @DeliveryCityID)
    AND (@IsOnCreditHold IS NULL 
         OR Client.IsOnCreditHold = @IsOnCreditHold)
	AND ((@OrdersCount IS NULL)
		OR ((SELECT COUNT(*) FROM Sales.Orders
			WHERE Orders.CustomerID = Client.CustomerID)
				>= @OrdersCount
			)
		)
	AND ((@PersonID IS NULL) 
		OR (Client.PrimaryContactPersonID = @PersonID))
	AND ((@DeliveryStateProvince IS NULL)
		OR (City.StateProvinceID = @DeliveryStateProvince))
	AND ((@PrimaryContactPersonIDIsEmployee IS NULL)
		OR (Person.IsEmployee = @PrimaryContactPersonIDIsEmployee)
		);
END
GO

DROP PROCEDURE IF EXISTS dbo.CustomerSearch_KitchenSinkOtus_Dynamic;
GO
CREATE PROCEDURE dbo.CustomerSearch_KitchenSinkOtus_Dynamic
  @CustomerID						INT				= NULL,
  @CustomerName						NVARCHAR(100)	= NULL,
  @BillToCustomerID					INT				= NULL,
  @CustomerCategoryID				INT				= NULL,
  @BuyingGroupID					INT				= NULL,
  @MinAccountOpenedDate				DATE			= NULL,
  @MaxAccountOpenedDate				DATE			= NULL,
  @DeliveryCityID					INT				= NULL,
  @IsOnCreditHold					BIT				= NULL,
  @OrdersCount						INT				= NULL, 
  @PersonID							INT				= NULL, 
  @DeliveryStateProvince			INT				= NULL,
  @PrimaryContactPersonIDIsEmployee BIT				= NULL
AS
BEGIN
 
	SET NOCOUNT ON;
 
	DECLARE @Params NVARCHAR(4000);
	SET @Params = N'
		@CustomerID INT,
		@CustomerName NVARCHAR(100),
		@BillToCustomerID INT,
		@CustomerCategoryID INT,
		@BuyingGroupID INT,
		@MinAccountOpenedDate DATE,
		@MaxAccountOpenedDate DATE,
		@DeliveryCityID INT,
		@IsOnCreditHold BIT,
		@OrdersCount INT, 
		@PersonID INT, 
		@DeliveryStateProvince INT,
		@PrimaryContactPersonIDIsEmployee BIT
	';

	DECLARE @QueryText NVARCHAR(4000);
	SET @QueryText = N'
		SELECT CustomerID, CustomerName, IsOnCreditHold
		FROM Sales.Customers AS Client
			INNER JOIN Application.People AS Person
				ON Person.PersonID = Client.PrimaryContactPersonID
			INNER JOIN Application.Cities AS City
				ON City.CityID = Client.DeliveryCityID
		WHERE 1 = 1';

	IF @CustomerID IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND Client.CustomerID = @CustomerID';
	IF @CustomerName IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND Client.CustomerName LIKE @CustomerName';
	IF @BillToCustomerID IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND Client.BillToCustomerID = @BillToCustomerID';
	IF @CustomerCategoryID IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND Client.CustomerCategoryID = @CustomerCategoryID';
	IF @BuyingGroupID IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND Client.BuyingGroupID = @BuyingGroupID';
	IF @MinAccountOpenedDate IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND Client.AccountOpenedDate >= @MinAccountOpenedDate';
	IF @MaxAccountOpenedDate IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND Client.AccountOpenedDate <= @MaxAccountOpenedDate';
	IF @DeliveryCityID IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND Client.DeliveryCityID = @DeliveryCityID';
	IF @IsOnCreditHold IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND Client.IsOnCreditHold = @IsOnCreditHold';
	IF @PersonID IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND Client.PrimaryContactPersonID = @PersonID';
	IF @DeliveryStateProvince IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND City.StateProvinceID = @DeliveryStateProvince';
	IF @PrimaryContactPersonIDIsEmployee IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND Person.IsEmployee = @PrimaryContactPersonIDIsEmployee';
	IF @OrdersCount IS NOT NULL
		SET @QueryText = @QueryText + N'
			AND ((SELECT COUNT(*) FROM Sales.Orders WHERE Orders.CustomerID = Client.CustomerID) >= @OrdersCount)';

	--SELECT @QueryText, @Params
	EXEC sp_executesql @QueryText, @Params
		, @CustomerID
		, @CustomerName
		, @BillToCustomerID
		, @CustomerCategoryID
		, @BuyingGroupID
		, @MinAccountOpenedDate
		, @MaxAccountOpenedDate
		, @DeliveryCityID
		, @IsOnCreditHold
		, @OrdersCount
		, @PersonID
		, @DeliveryStateProvince
		, @PrimaryContactPersonIDIsEmployee

END
GO

-- testing:
EXEC dbo.CustomerSearch_KitchenSinkOtus @CustomerName = N'%Ale%', @OrdersCount = 130;
EXEC dbo.CustomerSearch_KitchenSinkOtus_Dynamic
	--@CustomerID = 1
	@CustomerName = N'%Ale%'
	--@BillToCustomerID = 401
	--@CustomerCategoryID = 5
	--@BuyingGroupID = 2
	--@MinAccountOpenedDate = '20150901'
	--@MaxAccountOpenedDate = '20150901'
	--@DeliveryCityID = 26010
	--@IsOnCreditHold = 1
	, @OrdersCount = 130 
	--@PersonID = 3088
	--@DeliveryStateProvince = 39
	--@PrimaryContactPersonIDIsEmployee = 0
;

--- 7) Напишите запрос в транзакции где есть выборка, вставка\добавление\удаление данных и параллельно запускаем выборку данных в разных уровнях изоляции, нужно предоставить мини отчет, что на каком уровне было видно со скриншотами и ваши выводы (1-2 предложение)



--- 8) Сделайте параллельно в 2х окнах добавление данных в одну таблицу с разным уровнем изоляции, изменение данных в одной таблице, изменение одной и той же строки. Что в итоге получилось, что нового узнали.


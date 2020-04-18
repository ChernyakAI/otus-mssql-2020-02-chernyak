-- =============================================
-- Author:		Chernyak Andrey
-- Create date: 2020-04-18
-- Alter date: 	
-- Description:	stored procedures, functions, isolation levels
-- =============================================
USE WideWorldImporters;
GO


-- ЧАСТЬ 1:

--1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.


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



--2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
--Использовать таблицы :
--Sales.Customers
--Sales.Invoices
--Sales.InvoiceLines

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
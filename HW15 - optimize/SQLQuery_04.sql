/*
SET STATISTICS IO, TIME OFF;
DBCC FREEPROCCACHE
GO
DBCC DROPCLEANBUFFERS
GO
DBCC FREESYSTEMCACHE('ALL')
GO
DBCC FREESESSIONCACHE
GO

*/

-- UPDATE STATISTICS Sales.Orders;
-- UPDATE STATISTICS Sales.OrderLines; sp_updatestats
-- sp_help N'Sales.OrderLines';
-- ord.orderid, ord.customerid, ord.orderdate, 
-- det.orderid, det.stockitemid, det.unitprice, det.quantity,
SET STATISTICS IO, TIME ON;
WITH Totals AS (
	SELECT 
		ordTotal.CustomerID,
		SUM(Total.UnitPrice*Total.Quantity) Amount
	FROM Sales.OrderLines AS Total
		JOIN Sales.Orders AS ordTotal
			On ordTotal.OrderID = Total.OrderID
	GROUP BY ordTotal.CustomerID
)
SELECT ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
	JOIN Sales.OrderLines AS det
		ON det.OrderID = ord.OrderID
	JOIN Warehouse.StockItems AS It
		ON It.StockItemID = det.StockItemID AND It.SupplierID = 12
	JOIN Warehouse.StockItemTransactions AS ItemTrans
		ON ItemTrans.StockItemID = It.StockItemID
	JOIN Sales.Invoices AS Inv
		ON Inv.OrderID = ord.OrderID AND Inv.InvoiceDate = ord.OrderDate AND Inv.BillToCustomerID != ord.CustomerID
	JOIN Sales.CustomerTransactions AS Trans
		ON Trans.InvoiceID = Inv.InvoiceID
	JOIN Totals AS T
		ON T.CustomerID = ord.CustomerID
WHERE T.Amount > 250000
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID

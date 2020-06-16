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

SET STATISTICS IO, TIME ON;
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)
FROM Sales.Orders AS ord
	JOIN Sales.OrderLines AS det
		ON det.OrderID = ord.OrderID
	JOIN Sales.Invoices AS Inv
		ON Inv.OrderID = ord.OrderID
			AND Inv.InvoiceDate = ord.OrderDate
			AND Inv.BillToCustomerID != ord.CustomerID
	JOIN Sales.CustomerTransactions AS Trans
		ON Trans.InvoiceID = Inv.InvoiceID
	JOIN Warehouse.StockItemTransactions AS ItemTrans
		ON ItemTrans.StockItemID = det.StockItemID
WHERE (	Select SupplierId
			FROM Warehouse.StockItems AS It
			Where It.StockItemID = det.StockItemID
		) = 12
	AND (	SELECT SUM(Total.UnitPrice*Total.Quantity)
			FROM Sales.OrderLines AS Total
				Join Sales.Orders AS ordTotal
					On ordTotal.OrderID = Total.OrderID
			WHERE ordTotal.CustomerID = Inv.CustomerID
		) > 250000
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
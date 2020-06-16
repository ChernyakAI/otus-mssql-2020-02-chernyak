USE [WideWorldImporters]
GO

/****** Object:  Index [FK_Sales_Invoices_OrderID]    Script Date: 14.06.2020 20:44:50 ******/
CREATE NONCLUSTERED INDEX [IX_Sales_Invoices_OrderID_InvoiceDate_BillToCustomerID] ON [Sales].[Invoices]
(
	[OrderID] ASC
)
INCLUDE (InvoiceDate, BillToCustomerID)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [USERDATA]
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Testing' , @level0type=N'SCHEMA',@level0name=N'Sales', @level1type=N'TABLE',@level1name=N'Invoices', @level2type=N'INDEX',@level2name=N'IX_Sales_Invoices_OrderID_InvoiceDate_BillToCustomerID'
GO



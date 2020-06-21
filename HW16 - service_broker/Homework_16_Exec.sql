-- ןאנאלוענû סבמנא מעקועא
DECLARE
	@CustomerID INT = 105,
	@DateBegin DATE = '20140101',
	@DateEnd DATE = '20141231';

EXEC SB.OrderReport_CustomerInvoices
	@CustomerID,
	@DateBegin,
	@DateEnd

EXEC SB.CreateReport_TotalInvoicesByCustomer

EXEC SB.ConfirmReport

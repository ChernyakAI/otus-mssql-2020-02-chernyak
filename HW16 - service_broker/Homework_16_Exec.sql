-- ןאנאלוענû סבמנא מעקועא
DECLARE
	@CustomerID INT = 105,
	@DateBegin DATE = '20140101',
	@DateEnd DATE = '20141231';

EXEC SB.OrderReport_CustomerOrders
	@CustomerID,
	@DateBegin,
	@DateEnd

EXEC SB.CreateReport_TotalOrdersByCustomer

EXEC SB.ConfirmReport

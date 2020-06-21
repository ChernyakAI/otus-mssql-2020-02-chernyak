SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE SB.OrderReport_CustomerInvoices
	@CustomerID INT,
	@DateBegin DATE,
	@DateEnd DATE
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER; --open init dialog
	DECLARE @RequestMessage NVARCHAR(4000); --сообщение, которое будем отправлять
	
	BEGIN TRAN --начинаем транзакцию

	--Prepare the Message  !!!auto generate XML
	SELECT @RequestMessage = (	SELECT
									'OrderReport_InvoicesCountByCustomer' AS ReportType,
									@CustomerID	AS CustomerID,
									@DateBegin AS DateBegin,
									@DateEnd AS DateEnd
								FROM Sales.Customers
								WHERE CustomerID = @CustomerID
								FOR XML AUTO, root('RequestMessage')
	); 
	
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService]
	TO SERVICE
	'//WWI/SB/TargetService'
	ON CONTRACT
	[//WWI/SB/Contract]
	WITH ENCRYPTION=OFF; 

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	--SELECT @RequestMessage AS SentRequestMessage;--we can write data to log
	COMMIT TRAN 
END
GO

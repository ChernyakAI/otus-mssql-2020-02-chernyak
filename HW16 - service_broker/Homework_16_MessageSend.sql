SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE SB.OrderReport_CustomerOrders
	@CustomerID INT,
	@DateBegin DATE,
	@DateEnd DATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(4000);
	
	BEGIN TRAN

	SELECT @RequestMessage = (	SELECT
									@CustomerID	AS CustomerID,
									@DateBegin AS DateBegin,
									@DateEnd AS DateEnd
								FROM Sales.Customers
								WHERE CustomerID = @CustomerID
								FOR XML AUTO, root('RequestMessage')
	); 
	
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

	COMMIT TRAN 
END
GO

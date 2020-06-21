CREATE PROCEDURE SB.CreateReport_TotalInvoicesByCustomer
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER, --идентификатор диалога
			@Message NVARCHAR(4000),--полученное сообщение
			@MessageType Sysname,--тип полученного сообщения
			@ReplyMessage NVARCHAR(4000),--ответное сообщение
			@CustomerID INT,
			@DateBegin DATE,
			@DateEnd DATE,
			@xml XML; 
	
	BEGIN TRAN; 

	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueWWI; 

	SELECT @Message;
	SELECT @MessageType

	SET @xml = CAST(@Message AS XML);

	SELECT 
		@CustomerID = R.Iv.value('@CustomerID','INT'),
		@DateBegin = R.Iv.value('@DateBegin','DATE'),
		@DateEnd = R.Iv.value('@DateEnd','DATE')
	FROM @xml.nodes('/RequestMessage/Sales.Customers') as R(Iv);
	

	IF EXISTS (SELECT * FROM Sales.Invoices WHERE CustomerID = @CustomerID AND InvoiceDate BETWEEN @DateBegin AND @DateEnd)
	BEGIN
		MERGE SB.Report_TotalInvoicesByCustomer AS target  
		USING (
			SELECT COUNT(*) AS InvoicesCount
			FROM Sales.Invoices AS si
			WHERE CustomerID = @CustomerID
				AND InvoiceDate BETWEEN @DateBegin AND @DateEnd
		) AS SOURCE (InvoicesCount)  
		ON (target.CustomerID = @CustomerID AND target.DateBegin = @DateBegin AND target.DateEnd = @DateEnd)  
		WHEN MATCHED THEN
			UPDATE SET target.InvoicesCount = source.InvoicesCount
		WHEN NOT MATCHED THEN  
			INSERT   
			VALUES (@CustomerID, @DateBegin, @DateEnd, source.InvoicesCount);
	END
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;--закроем диалог со стороны таргета
	END 

	COMMIT TRAN;
END
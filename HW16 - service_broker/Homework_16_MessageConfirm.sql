CREATE PROCEDURE SB.ConfirmReport
AS
BEGIN

	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 
		END CONVERSATION @InitiatorReplyDlgHandle;
	COMMIT TRAN; 
END
--переведем БД в однопользовательский режим, отключив остальных
USE master
GO
ALTER DATABASE WideWorldImporters SET SINGLE_USER WITH ROLLBACK IMMEDIATE

USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER; --необходимо включить service broker

ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON; --и разрешить доверенные подключения
--посммотрим свойства БД через студию
select DATABASEPROPERTYEX ('WideWorldImporters','UserAccess');
SELECT is_broker_enabled FROM sys.databases WHERE name = 'WideWorldImporters';

ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];

ALTER DATABASE WideWorldImporters SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO


-- инициализация объектов БД 
USE WideWorldImporters;
GO

CREATE MESSAGE TYPE [//WWI/SB/RequestMessage] VALIDATION=WELL_FORMED_XML;
CREATE MESSAGE TYPE [//WWI/SB/ReplyMessage] VALIDATION=WELL_FORMED_XML; 
GO
CREATE CONTRACT [//WWI/SB/Contract]
    ([//WWI/SB/RequestMessage] SENT BY INITIATOR,
    [//WWI/SB/ReplyMessage] SENT BY TARGET
    );
GO


CREATE QUEUE TargetQueueWWI;
CREATE SERVICE [//WWI/SB/TargetService]
	ON QUEUE TargetQueueWWI
	([//WWI/SB/Contract]);
GO
CREATE QUEUE InitiatorQueueWWI;
CREATE SERVICE [//WWI/SB/InitiatorService]
	ON QUEUE InitiatorQueueWWI
	([//WWI/SB/Contract]);
GO

-- схема для объектов, связанных с сервис-брокером
CREATE SCHEMA SB;
CREATE TABLE SB.Report_TotalOrdersByCustomer(
	CustomerID INT NOT NULL,
	DateBegin DATE NOT NULL,
	DateEnd DATE NOT NULL,
	OrdersCount INT NULL,
	CONSTRAINT PK_Report_TIBC PRIMARY KEY CLUSTERED (CustomerID, DateBegin, DateEnd)
)
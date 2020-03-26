-- =============================================
-- Author:		Chernyak Andrey
-- Create date: 2020-03-26
-- Alter date: 	
-- Description:	SQL и операторы изменения данных
-- =============================================
 
-- 1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers
DELETE FROM Purchasing.Suppliers WHERE WebsiteURL = N'rogaikopita.ru';

INSERT INTO Purchasing.Suppliers (
    SupplierID,
    SupplierName,
    SupplierCategoryID,
    PrimaryContactPersonID,
    AlternateContactPersonID,
    DeliveryCityID,
    PostalCityID,
    PaymentDays,
    PhoneNumber,
    FaxNumber,
    WebsiteURL,
    DeliveryAddressLine1,
    DeliveryPostalCode,
    PostalAddressLine1,
    PostalPostalCode,
    LastEditedBy
)
VALUES 
    (NEXT VALUE FOR Sequences.SupplierID, N'Рога и копыта', 7, 2, 2, 143, 143, 30, N'(415) 555-0100', N'(415) 555-0100', N'rogaikopita.ru', N'Level 1', N'27906', N'PO Box 3390', N'27906', 1),
    (NEXT VALUE FOR Sequences.SupplierID, N'Копыта и рога', 7, 2, 2, 143, 143, 30, N'(415) 555-0100', N'(415) 555-0100', N'rogaikopita.ru', N'Level 2', N'27906', N'PO Box 3390', N'27906', 1),
    (NEXT VALUE FOR Sequences.SupplierID, N'Рога без копыт', 7, 2, 2, 143, 143, 30, N'(415) 555-0100', N'(415) 555-0100', N'rogaikopita.ru', N'Level 3', N'27906', N'PO Box 3390', N'27906', 1),
    (NEXT VALUE FOR Sequences.SupplierID, N'Копыта без рогов', 7, 2, 2, 143, 143, 30, N'(415) 555-0100', N'(415) 555-0100', N'rogaikopita.ru', N'Level 4', N'27906', N'PO Box 3390', N'27906', 1),
    (NEXT VALUE FOR Sequences.SupplierID, N'Без рогов и без копыт', 7, 2, 2, 143, 143, 30, N'(415) 555-0100', N'(415) 555-0100', N'rogaikopita.ru', N'Level 5', N'27906', N'PO Box 3390', N'27906', 1);

-- 2. удалите 1 запись из Customers, которая была вами добавлена
DELETE FROM Purchasing.Suppliers WHERE SupplierName = N'Рога и копыта';

-- 3. изменить одну запись, из добавленных через UPDATE
UPDATE Purchasing.Suppliers
SET SupplierName = N'Рога и копыта'
WHERE SupplierName = N'Без рогов и без копыт';

-- 4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
MERGE Purchasing.Suppliers AS target
USING (
    SELECT 
        N'Рога и копыта',
        2147825698
    ) AS source (
        SupplierName,
        BankAccountNumber
    )
ON (target.SupplierName = source.SupplierName)
WHEN MATCHED THEN
    UPDATE SET BankAccountNumber = source.BankAccountNumber
WHEN NOT MATCHED THEN  
    INSERT (
        SupplierID,
        SupplierName,
        SupplierCategoryID,
        PrimaryContactPersonID,
        AlternateContactPersonID,
        DeliveryCityID,
        PostalCityID,
        BankAccountNumber,
        PaymentDays,
        PhoneNumber,
        FaxNumber,
        WebsiteURL,
        DeliveryAddressLine1,
        DeliveryPostalCode,
        PostalAddressLine1,
        PostalPostalCode,
        LastEditedBy
    )  
    VALUES (
        default,
        source.SupplierName,
        7,
        2,
        2,
        143,
        143,
        source.BankAccountNumber,
        30,
        N'(415) 555-0100',
        N'(415) 555-0100',
        N'rogaikopita.ru',
        N'Level 1',
        N'27906',
        N'PO Box 3390',
        N'27906',
        1
    );

-- 5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
RECONFIGURE;  
GO
SELECT @@SERVERNAME;
exec master..xp_cmdshell 'bcp "WideWorldImporters.Sales.Orders" out "C:\git\otus-mssql-2020-02-chernyak\HW06 - insert_update\Orders.txt" -T -w -t";" -S DESKTOP-UC6FVVF\SQL2017';

SELECT *
INTO Sales.OrdersTest
FROM Sales.Orders;
TRUNCATE TABLE Sales.OrdersTest;

BULK INSERT WideWorldImporters.Sales.OrdersTest
   FROM "C:\git\otus-mssql-2020-02-chernyak\HW06 - insert_update\Orders.txt"
   WITH 
	 (
		BATCHSIZE = 1000, 
		DATAFILETYPE = 'widechar',
		FIELDTERMINATOR = ';',
		ROWTERMINATOR ='\n',
		KEEPNULLS,
		TABLOCK        
	  );
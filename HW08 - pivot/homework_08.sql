-- =============================================
-- Author:		Chernyak Andrey
-- Create date: 2020-04-01
-- Alter date: 	
-- Description:	Pivot и Cross Apply
-- =============================================

/*
1. Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
Название клиента
МесяцГод Количество покупок

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys
имя клиента нужно поменять так чтобы осталось только уточнение
например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY
дата должна иметь формат dd.mm.yyyy например 25.12.2019

Например, как должны выглядеть результаты:
InvoiceMonth Peeples Valley, AZ Medicine Lodge, KS Gasport, NY Sylvanite, MT Jessie, ND
01.01.2013 3 1 4 2 2
01.02.2013 7 3 4 2 1
*/

SELECT
    FORMAT(InvoiceMonth, N'dd.MM.yyyy') AS InvoiceMonth
    , [Peeples Valley, AZ]
    , [Medicine Lodge, KS]
    , [Gasport, NY]
    , [Sylvanite, MT]
    , [Jessie, ND]
FROM
(
    SELECT    
        SUBSTRING(sc.CustomerName, CHARINDEX('(', sc.CustomerName) + 1, CHARINDEX(')', sc.CustomerName) - CHARINDEX('(', sc.CustomerName) - 1) AS CustomerName
        , DATEADD(DAY, 1- DAY(si.InvoiceDate), si.InvoiceDate) AS InvoiceMonth
        , si.InvoiceID
    FROM Sales.Invoices AS si
        INNER JOIN Sales.Customers AS sc
            ON sc.CustomerID = si.CustomerID
    WHERE sc.CustomerID IN (2, 3, 4, 5, 6)
) AS InvoicesByCustomers
PIVOT
(
    COUNT(InvoiceID)
    FOR CustomerName IN ([Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ], [Sylvanite, MT])
) AS PVT
ORDER BY PVT.InvoiceMonth


/*
2. Для всех клиентов с именем, в котором есть Tailspin Toys
вывести все адреса, которые есть в таблице, в одной колонке

Пример результатов
CustomerName AddressLine
Tailspin Toys (Head Office) Shop 38
Tailspin Toys (Head Office) 1877 Mittal Road
Tailspin Toys (Head Office) PO Box 8975
Tailspin Toys (Head Office) Ribeiroville
.....
*/

SELECT sc.CustomerName, ca.Address
FROM Sales.Customers AS sc
    CROSS APPLY (VALUES (DeliveryAddressLine1), (DeliveryAddressLine2), (PostalAddressLine1), (PostalAddressLine2)) ca (Address)
WHERE sc.CustomerName LIKE '%Tailspin Toys%'
ORDER BY sc.CustomerName


/*
3. В таблице стран есть поля с кодом страны цифровым и буквенным
сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
Пример выдачи
CountryId CountryName Code
1 Afghanistan AFG
1 Afghanistan 4
3 Albania ALB
3 Albania 8
*/

SELECT ac.CountryID, ac.CountryName, ca.Code
FROM Application.Countries AS ac
    CROSS APPLY (VALUES (IsoAlpha3Code), (CAST(IsoNumericCode AS nvarchar(3)))) ca (Code)


/*
4. Перепишите ДЗ из оконных функций через CROSS APPLY
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

SELECT
    sc.CustomerID
    , sc.CustomerName
    , Top2Units.StockItemID
    , Top2Units.UnitPrice
    , Top2Units.LastInvoiceDate
FROM Sales.Customers AS sc
    CROSS APPLY (
                    SELECT TOP 2
                        si.CustomerID
                        , MAX(si.InvoiceDate) AS LastInvoiceDate
                        , sil.StockItemID
                        , sil.UnitPrice
                    FROM Sales.Invoices AS si
                        INNER JOIN Sales.InvoiceLines AS sil
                            ON si.InvoiceID = si.InvoiceID
                    WHERE si.CustomerID = sc.CustomerID
                    GROUP BY si.CustomerID, sil.StockItemID, sil.UnitPrice
                    ORDER BY si.CustomerID, sil.UnitPrice DESC
                ) AS Top2Units
ORDER BY sc.CustomerID


/*
5. Code review (опционально). Запрос приложен в материалы Hometask_code_review.sql.
Что делает запрос?
Чем можно заменить CROSS APPLY - можно ли использовать другую стратегию выборки\запроса?
*/
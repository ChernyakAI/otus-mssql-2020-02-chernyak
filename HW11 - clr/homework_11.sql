-- =============================================
-- Author:		Chernyak Andrey
-- Create date: 2020-04-26
-- Alter date:  2020-04-27	
-- Description:	CLR
-- =============================================
USE WideWorldImporters;
GO



-- Включаем CLR
exec sp_configure 'show advanced options', 1;
go
reconfigure;
go

exec sp_configure 'clr enabled', 1;
exec sp_configure 'clr strict security', 0 
go

reconfigure;
go

-- Для EXTERNAL_ACCESS или UNSAFE
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;




----------1) Взять готовую dll, подключить ее и продемонстрировать использование.
----------Например, https://sqlsharp.com

SELECT * FROM sys.assemblies
GO
EXEC SQL#.SQLsharp_SetSecurity 2, N'SQL#.OS';
SELECT SQL#.OS_MachineName()




----------2) Взять готовые исходники из какой-нибудь статьи, скомпилировать, подключить dll, продемонстрировать использование.
----------Например,
----------https://www.sqlservercentral.com/articles/xlsexport-a-clr-procedure-to-export-proc-results-to-excel
----------https://www.mssqltips.com/sqlservertip/1344/clr-string-sort-function-in-sql-server/
----------https://habr.com/ru/post/88396/

-- https://habr.com/ru/post/88396/

CREATE ASSEMBLY CLRFunctions FROM 'c:\git\otus-mssql-2020-02-chernyak\HW11 - clr\SplitString.dll'
go

CREATE FUNCTION [dbo].SplitStringCLR(@text [nvarchar](max), @delimiter [nchar](1))
RETURNS TABLE (
part nvarchar(max),
ID_ODER int
) WITH EXECUTE AS CALLER
AS
EXTERNAL NAME CLRFunctions.UserDefinedFunctions.SplitString

SELECT * FROM dbo.SplitStringCLR(N'Ivanov,Ivan,Ivanovich', N',')


----------3) Написать полностью свое (что-то одно):
----------* Тип: JSON с валидацией, IP / MAC - адреса, ...
----------* Функция: работа с JSON, ...
----------* Агрегат: аналог STRING_AGG, ...
----------* (любой ваш вариант)


DROP FUNCTION IF EXISTS dbo.DeclineFIO
DROP ASSEMBLY IF EXISTS Declination

CREATE ASSEMBLY Declination
FROM 'c:\git\otus-mssql-2020-02-chernyak\HW11 - clr\Declination.dll'
WITH PERMISSION_SET = SAFE;
go

CREATE FUNCTION [dbo].DeclineFIO(@Fio NVARCHAR(250), @Case NCHAR(1))
RETURNS nvarchar(max)
AS
EXTERNAL NAME Declination.[Declination.UserDefinedFunctions].DeclineFIO
GO

SELECT *
FROM sys.assemblies AS a
	INNER JOIN sys.assembly_modules AS am
		ON am.assembly_id = a.assembly_id
WHERE a.name = 'Declination'


-- проверка
DECLARE @Persons TABLE (
    LastName NVARCHAR(50),
	FirstName NVARCHAR(50),
    MiddleName NVARCHAR(50)
);
INSERT INTO @Persons(LastName, FirstName, MiddleName)
VALUES(N'Иванов', N'', N''),
		(N'Иванов1', N'Иван', N'Иванович'),
		(N'Пушкин', N'Александр', N'Сергеевич'),
		(N'Достоевский', N'Фёдор', N'Михайлович'),
		(N'Толстой', N'Лев', N'Николаевич'),
		(N'Пикассо', N'Пабло', N'Диего Хосе Франсиско де Паула'),
		(N'Данелия', N'Георгий', N'Николаевич'),
		(N'Черняк', N'Андрей', N'Игоревич'),
		
		(N'Дмитриева', N'Галина', N'Анатольевна'),
		(N'Шевченко', N'Ирина', N'Петровна'),
		(N'Седых', N'Елена', N'Геннадьевна'),
		(N'Русецкая', N'Вероника', N'Александровна')


SELECT
	p.*
	, dbo.DeclineFIO(p.LastName + ' ' + p.FirstName + ' ' + p.MiddleName, N'р')
FROM @Persons AS p
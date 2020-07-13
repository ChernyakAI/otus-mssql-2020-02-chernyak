USE RKC;
GO


-- ****************************************************************************
-- 1. Ввод лицевого счёта
-- ****************************************************************************
/*
EXEC dbo.CreatePersonalAccount '20200701', 1, 1, 1;
-- проверка
SELECT TOP(1) * FROM Ref.PersonalAccounts
WHERE DateBegin = '20200701';
SELECT TOP(1) * FROM Work.PersonalAccountLiving
WHERE OwnershipDateBegin = '20200701';
*/



-- ****************************************************************************
-- 2. СОЗДАНИЕ УЧЁТНЫХ ПОКАЗАТЕЛЕЙ
-- ****************************************************************************
/*
DECLARE @LastLS INT;
SET @LastLS = (SELECT TOP(1) ID
FROM Ref.PersonalAccounts
ORDER BY Number DESC);
-- электроэнергия
EXEC dbo.CreatePersonalAccountIndicator @LastLS, 1, 1, 1, 3, 3, '20200701';
-- отопление
EXEC dbo.CreatePersonalAccountIndicator @LastLS, 2, 2, 2, 4, 4, '20200701';
-- ХВС
EXEC dbo.CreatePersonalAccountIndicator @LastLS, 2, 3, 1, 5, 5, '20200701';
-- ГВС
EXEC dbo.CreatePersonalAccountIndicator @LastLS, 2, 4, 1, 6, 6, '20200701';
-- водоотведение
EXEC dbo.CreatePersonalAccountIndicator @LastLS, 3, 5, 1, 7, NULL, '20200701';
-- содержание жилья
EXEC dbo.CreatePersonalAccountIndicator @LastLS, 4, 6, 3, 8, NULL, '20200701';
-- домофон
EXEC dbo.CreatePersonalAccountIndicator @LastLS, 5, 7, 5, 9, NULL, '20200701';
-- лифт
EXEC dbo.CreatePersonalAccountIndicator @LastLS, 6, 8, 3, 13, NULL, '20200701';
-- вывоз ТКО
EXEC dbo.CreatePersonalAccountIndicator @LastLS, 7, 9, 2, 10, 7, '20200701';
-- кап. ремонт
EXEC dbo.CreatePersonalAccountIndicator @LastLS, 8, 10, 3, 11, NULL, '20200701';

-- проверка:
SELECT * FROM Work.PersonalAccountIndicators WHERE DateBegin = '20200701';
*/


-- ****************************************************************************
-- 3. УСТАНОВКА ПРИБОРОВ УЧЁТА
-- ****************************************************************************
/*
DECLARE @LastLS INT;
SET @LastLS = (SELECT TOP(1) ID
				FROM Ref.PersonalAccounts
				ORDER BY Number DESC);
DECLARE @IndEE INT, @IndHVS INT, @IndGVS INT;
SELECT @IndEE = ID FROM Work.PersonalAccountIndicators
WHERE PersonalAccountID = @LastLS AND IndicatorTypeID = 1;
SELECT @IndHVS = ID FROM Work.PersonalAccountIndicators
WHERE PersonalAccountID = @LastLS AND IndicatorTypeID = 3;
SELECT @IndGVS = ID FROM Work.PersonalAccountIndicators
WHERE PersonalAccountID = @LastLS AND IndicatorTypeID = 4;
EXEC dbo.InstallMeterDevice 1, @IndEE, '20200701';
EXEC dbo.InstallMeterDevice 2, @IndHVS, '20200701';
EXEC dbo.InstallMeterDevice 3, @IndGVS, '20200701';
-- проверка:
SELECT * FROM Work.MeterDeviceIndicators WHERE InstallationDate = '20200701';
*/


-- ****************************************************************************
-- 4. ВВОД ПОКАЗАНИЙ ПРИБОРОВ УЧЁТА
-- ****************************************************************************
/*
EXEC dbo.InsertMeterDeviceReadings 836, '20200701', 150;
EXEC dbo.InsertMeterDeviceReadings 836, '20200725', 200;
EXEC dbo.InsertMeterDeviceReadings 244, '20200701', 150;
EXEC dbo.InsertMeterDeviceReadings 244, '20200725', 200;
EXEC dbo.InsertMeterDeviceReadings 2114, '20200701', 150;
EXEC dbo.InsertMeterDeviceReadings 2114, '20200725', 200;
--проверка:
SELECT * FROM work.MeterDeviceReadings
WHERE MeterDeviceScaleID IN (836, 244, 2114);
*/



-- ****************************************************************************
-- 5. РАСЧЁТ НАЧИСЛЕНИЙ В СООТВЕТСТВИИ С МЕТОДИКОЙ РАСЧЕТА
-- **************************************************************************** 
/*
-- расчёт определённой услуги по л/счёту
EXEC dbo.MakeCalculations 10001, 1, '20200701'; 
-- расчёт всей базы (альтернативный вариант)
EXEC dbo.MakeCalculations NULL, NULL, '20200701';
-- проверка результата:
SELECT * FROM Calc.Charges WHERE Period = '20200701'
ORDER BY PersonalAccountID, PersonalAccountIndicatorID;
*/


-- ****************************************************************************
-- 6. ВВОД ОПЛАТЫ
-- ****************************************************************************
/*
EXEC dbo.CreatePayment 1, 1927670.59;
-- проверка распределения оплаты
SELECT * FROM Calc.Payments WHERE PersonalAccountID = 1;
*/



-- ****************************************************************************
-- 7. ФИКСАЦИЯ ФИНАНСОВЫХ ПОКАЗАТЕЛЕЙ В РАСЧЁТНОМ ПЕРИОДЕ (ЗАКРЫТИЕ ПЕРИОДА).
-- ****************************************************************************

------ Уже добавлено для демонстрации переходящего остатка:
----INSERT INTO Calc.Balance(SupplierID, PersonalAccountID, 
----	PersonalAccountIndicatorID, Period, Amount)
----VALUES(6, 1, 47900, '20200601', 10);
/*
EXEC dbo.ClosePeriod '20200701';
-- проверка
SElECT TOP(1) Period FROM Calc.ClosedPeriods ORDER BY Period DESC;
SELECT SUM(Amount) FROM Calc.Balance WHERE Period = '20200701';
*/



-- ****************************************************************************
-- 8. ПОДГОТОВКА ДАННЫХ ДЛЯ ПЕЧАТИ ПЛАТЁЖНЫХ ДОКУМЕНТОВ
-- ****************************************************************************
/*
DECLARE @Period DATE = '20200701';
EXEC dbo.GetDataForPrinting_General 1, @Period;			-- основные данные
EXEC dbo.GetDataForPrinting_Indicators 1, @Period;		-- учетные показатели
EXEC dbo.GetDataForPrinting_Finances 1, @Period;		-- финансовые данные
*/
-- альтернативный вариант: массово по всем лицевым счетам
/*
DECLARE @Period DATE = '20200701';
EXEC dbo.GetDataForPrinting_General NULL, @Period;
EXEC dbo.GetDataForPrinting_Indicators NULL, @Period;
EXEC dbo.GetDataForPrinting_Finances NULL, @Period;
*/



-- ****************************************************************************
-- ОТКАТ ВНЕСЁННЫХ В ДЕМО ИЗМЕНЕНИЙ
-- ****************************************************************************

/*
-- 7. Закрытие периода
DELETE FROM Calc.ClosedPeriods WHERE Period = '20200701';
DELETE FROM Calc.Balance WHERE Period = '20200701';
-- 6. Оплаты
DELETE FROM Calc.Payments WHERE PersonalAccountID = 1;
-- 5. Начисления
DELETE FROM Calc.Charges WHERE Period = '20200701';
-- 4. Показания
DELETE FROM work.MeterDeviceReadings
WHERE MeterDeviceScaleID = 836 AND ReadingDate IN ('20200701', '20200725');
DELETE FROM work.MeterDeviceReadings
WHERE MeterDeviceScaleID = 244 AND ReadingDate IN ('20200701', '20200725');
DELETE FROM work.MeterDeviceReadings
WHERE MeterDeviceScaleID = 2114 AND ReadingDate IN ('20200701', '20200725');
-- 3. Приборы учёта
DELETE FROM Work.MeterDeviceIndicators WHERE InstallationDate = '20200701';
-- 2. Учетные показатели
DELETE FROM Work.PersonalAccountIndicators WHERE DateBegin = '20200701';
-- 1. Лицевые счета
DELETE FROM Work.PersonalAccountLiving WHERE OwnershipDateBegin = '20200701';
DELETE FROM Ref.PersonalAccounts WHERE DateBegin = '20200701';
*/
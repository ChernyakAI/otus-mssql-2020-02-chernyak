USE master;
GO

DROP DATABASE IF EXISTS RKC;
GO

CREATE DATABASE RKC;
GO

USE RKC;
GO

-- �������� ����
CREATE SCHEMA CD;
GO
CREATE SCHEMA Ref;
GO
CREATE SCHEMA Work;
GO
CREATE SCHEMA Calc;
GO

CREATE TABLE CD.CalculationMethods
(
	ID			INT IDENTITY(1, 1) PRIMARY KEY,
	Name		NVARCHAR(250) NOT NULL
);
CREATE TABLE CD.Tariffs
(
	ID			INT IDENTITY(1, 1) PRIMARY KEY,
	DateBegin	DATE NOT NULL,
	Name		NVARCHAR(250) NOT NULL,
	Value		DECIMAL(15, 2) NOT NULL
);
CREATE TABLE CD.Normatives
(
	ID			INT IDENTITY(1, 1) PRIMARY KEY,
	DateBegin	DATE NOT NULL,
	Name		NVARCHAR(250) NOT NULL,
	Value		DECIMAL(19, 6) NOT NULL
);
CREATE TABLE CD.Units
(
	ID			TINYINT IDENTITY(1, 1) PRIMARY KEY,
	Name		NVARCHAR(250) NOT NULL
);
CREATE TABLE CD.IndicatorTypes
(
	ID			INT IDENTITY(1, 1) PRIMARY KEY,
	Name		NVARCHAR(250) NOT NULL,
	UnitID		TINYINT NOT NULL
);
CREATE TABLE CD.Scales
(
	ID			TINYINT IDENTITY(1, 1) PRIMARY KEY,
	Name		NVARCHAR(250) NOT NULL
);
CREATE TABLE CD.AddressObjectTypes
(
	ID			SMALLINT IDENTITY(1, 1) PRIMARY KEY,
	Name		NVARCHAR(250) NOT NULL
);

CREATE TABLE Ref.AddressObjects
(
	ID				INT IDENTITY(1, 1) PRIMARY KEY,
	ParentID		INT NULL,
	ObjectTypeID	SMALLINT NOT NULL,
	Name			NVARCHAR(250) NOT NULL
);
CREATE TABLE Ref.Buildings
(
	ID				INT IDENTITY(1, 1) PRIMARY KEY,
	RegionID		INT NOT NULL,
	TownID			INT NULL,
	MunicipalityID	INT NULL,
	StreetID		INT NULL,
	Number			NVARCHAR(20) NULL,
	ZipCode			NVARCHAR(50) NULL,
	FullAddress		NVARCHAR(500) NULL
);
CREATE TABLE Ref.Persons
(
	ID						INT IDENTITY(1, 1) PRIMARY KEY,
	FirstName				NVARCHAR(150) NOT NULL,
	SecondName				NVARCHAR(150) NULL,
	ThirdName				NVARCHAR(100) NULL,
	Gender					BIT NULL,
	BirthDate				DATE NULL,
	Phone					NVARCHAR(50) NULL,
	Email					NVARCHAR(150) NULL,
	DeliveryRegionID		INT NOT NULL,
	DeliveryTownID			INT NULL,
	DeliveryMunicipalityID	INT NULL,
	DeliveryStreetID		INT NULL,
	DeliveryBuildingNumber	NVARCHAR(20) NULL,
	DeliveryPremiseNumber	NVARCHAR(20) NULL,
);
CREATE TABLE Ref.Staff
(
	EmployeeNumber	INT IDENTITY(1, 1) PRIMARY KEY,
	PersonID		INT NOT NULL,
	Position		NVARCHAR(250) NULL
);
CREATE TABLE Ref.PersonalAccounts
(
	ID				INT IDENTITY(1, 1) PRIMARY KEY,
	AccountNumber	NVARCHAR(25) NOT NULL,
	DateBegin		DATE NOT NULL,
	DateEnd			DATE NULL,
	BuildingID		INT NOT NULL,
	PremiseNumber	NVARCHAR(20) NOT NULL,
	StaffID			INT NULL
);
CREATE TABLE Ref.Suppliers
(
	ID				INT IDENTITY(1, 1) PRIMARY KEY,
	Name			NVARCHAR(250) NOT NULL,
	Address			NVARCHAR(500) NULL,
	INN				NVARCHAR(14) NULL,
	KPP				NVARCHAR(9) NULL
);
CREATE TABLE Ref.MeterDevices
(
	ID					INT IDENTITY(1, 1) PRIMARY KEY,
	SerialNumber		NVARCHAR(50) NOT NULL,
	VerificationDate	DATE NULL,
	ReplaceUpToDate		DATE NULL
);

CREATE TABLE Work.PersonalAccountIndicators
(
	ID					INT IDENTITY(1, 1) PRIMARY KEY,
	PersonalAccountID	INT NOT NULL,
	IndicatorTypeID		INT NOT NULL,
	DateBegin			DATE NOT NULL,
	DateEnd				DATE NULL,
	SupplierID			INT NOT NULL,
	CalculationMethodID	INT NOT NULL,
	TariffID			INT NULL,
	NormativeID			INT NULL
);
CREATE TABLE Work.PersonalAccountEvents
(
	ID					INT IDENTITY(1, 1) PRIMARY KEY,
	PersonalAccountID	INT NOT NULL,
	Date				DATE NOT NULL,
	Description			NVARCHAR(MAX) NOT NULL,
	StaffID			INT NULL
);
CREATE TABLE Work.PersonalAccountLiving
(
	ID					INT IDENTITY(1, 1) PRIMARY KEY,
	PersonalAccountID	INT NOT NULL,
	PersonID			INT NOT NULL,
	IsOwner				BIT NULL,
	OwnershipDateBegin	DATE NULL
);
CREATE TABLE Work.MeterDeviceScales
(
	ID				INT IDENTITY(1, 1) PRIMARY KEY,
	MeterDeviceID	INT NOT NULL,
	ScaleID			TINYINT NOT NULL
);
CREATE TABLE Work.MeterDeviceReadings
(
	ID					INT IDENTITY(1, 1) PRIMARY KEY,
	MeterDeviceScaleID	INT NOT NULL,
	ReadingDate			DATE NOT NULL,
	ReadingValue		DECIMAL(19, 6) NOT NULL
);
CREATE TABLE Work.MeterDeviceIndicators
(
	ID							INT IDENTITY(1, 1) PRIMARY KEY,
	MeterDeviceID				INT NOT NULL,
	PersonalAccountIndicatorID	INT NOT NULL,
	InstallationDate			DATE NOT NULL,
	RemovingDate				DATE NULL
);

CREATE TABLE Calc.Charges
(
	ID							INT IDENTITY(1, 1) PRIMARY KEY,
	SupplierID					INT NOT NULL,
	PersonalAccountID			INT NOT NULL,
	PersonalAccountIndicatorID	INT NOT NULL,
	Period						SMALLINT NOT NULL,
	Quantity					DECIMAL(19, 6) NOT NULL,
	Amount						DECIMAL(15, 2) NOT NULL
);
CREATE TABLE Calc.Payments
(
	ID							INT IDENTITY(1, 1) PRIMARY KEY,
	SupplierID					INT NOT NULL,
	PersonalAccountID			INT NOT NULL,
	PersonalAccountIndicatorID	INT NOT NULL,
	Period						SMALLINT NOT NULL,
	Amount						DECIMAL(15, 2) NOT NULL
);
CREATE TABLE Calc.Balance
(
	ID							INT IDENTITY(1, 1) PRIMARY KEY,
	SupplierID					INT NOT NULL,
	PersonalAccountID			INT NOT NULL,
	PersonalAccountIndicatorID	INT NOT NULL,
	Period						SMALLINT NOT NULL,
	Amount						DECIMAL(15, 2) NOT NULL
);

-- �����

ALTER TABLE Work.MeterDeviceScales ADD CONSTRAINT FK_Scales_MeterDeviceScales FOREIGN KEY(ScaleID)
REFERENCES CD.Scales(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Work.MeterDeviceScales ADD CONSTRAINT FK_MeterDevices_MeterDeviceScales FOREIGN KEY(MeterDeviceID)
REFERENCES Ref.MeterDevices(ID)
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE Work.MeterDeviceReadings ADD CONSTRAINT FK_MeterDeviceScales_MeterDeviceReadings FOREIGN KEY(MeterDeviceScaleID)
REFERENCES Work.MeterDeviceScales(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Work.MeterDeviceIndicators ADD CONSTRAINT FK_MeterDevices_MeterDeviceIndicators FOREIGN KEY(MeterDeviceID)
REFERENCES Ref.MeterDevices(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE CD.IndicatorTypes ADD CONSTRAINT FK_Units_IndicatorTypes FOREIGN KEY(UnitID)
REFERENCES CD.Units(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Work.PersonalAccountIndicators ADD CONSTRAINT FK_IndicatorTypes_PersonalAccountIndicators FOREIGN KEY(IndicatorTypeID)
REFERENCES CD.IndicatorTypes(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Work.PersonalAccountIndicators ADD CONSTRAINT FK_CalculationMethods_PersonalAccountIndicators FOREIGN KEY(CalculationMethodID)
REFERENCES CD.CalculationMethods(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Work.PersonalAccountIndicators ADD CONSTRAINT FK_Tariffs_PersonalAccountIndicators FOREIGN KEY(TariffID)
REFERENCES CD.Tariffs(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Work.PersonalAccountIndicators ADD CONSTRAINT FK_Normatives_PersonalAccountIndicators FOREIGN KEY(NormativeID)
REFERENCES CD.Normatives(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Work.PersonalAccountEvents ADD CONSTRAINT FK_PersonalAccounts_PersonalAccountEvents FOREIGN KEY(PersonalAccountID)
REFERENCES Ref.PersonalAccounts(ID)
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE Work.PersonalAccountEvents ADD CONSTRAINT FK_Staff_PersonalAccountEvents FOREIGN KEY(StaffID)
REFERENCES Ref.Staff(EmployeeNumber)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Calc.Charges ADD CONSTRAINT FK_Suppliers_Charges FOREIGN KEY(SupplierID)
REFERENCES Ref.Suppliers(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Calc.Charges ADD CONSTRAINT FK_PersonalAccounts_Charges FOREIGN KEY(PersonalAccountID)
REFERENCES Ref.PersonalAccounts(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Calc.Charges ADD CONSTRAINT FK_PersonalAccountIndicators_Charges FOREIGN KEY(PersonalAccountIndicatorID)
REFERENCES Work.PersonalAccountIndicators(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Calc.Payments ADD CONSTRAINT FK_Suppliers_Payments FOREIGN KEY(SupplierID)
REFERENCES Ref.Suppliers(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Calc.Payments ADD CONSTRAINT FK_PersonalAccounts_Payments FOREIGN KEY(PersonalAccountID)
REFERENCES Ref.PersonalAccounts(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Calc.Payments ADD CONSTRAINT FK_PersonalAccountIndicators_Payments FOREIGN KEY(PersonalAccountIndicatorID)
REFERENCES Work.PersonalAccountIndicators(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;


ALTER TABLE Calc.Balance ADD CONSTRAINT FK_Suppliers_Balance FOREIGN KEY(SupplierID)
REFERENCES Ref.Suppliers(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Calc.Balance ADD CONSTRAINT FK_PersonalAccounts_Balance FOREIGN KEY(PersonalAccountID)
REFERENCES Ref.PersonalAccounts(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;

ALTER TABLE Calc.Balance ADD CONSTRAINT FK_PersonalAccountIndicators_Balance FOREIGN KEY(PersonalAccountIndicatorID)
REFERENCES Work.PersonalAccountIndicators(ID)
ON UPDATE CASCADE
ON DELETE NO ACTION;


ALTER TABLE Work.PersonalAccountIndicators ADD CONSTRAINT FK_Suppliers_PersonalAccountIndicators FOREIGN KEY(SupplierID)
REFERENCES Ref.Suppliers(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE Work.MeterDeviceIndicators ADD CONSTRAINT FK_PersonalAccountIndicators_MeterDeviceIndicators FOREIGN KEY(PersonalAccountIndicatorID)
REFERENCES Work.PersonalAccountIndicators(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE Ref.PersonalAccounts ADD CONSTRAINT FK_Staff_PersonalAccounts FOREIGN KEY(StaffID)
REFERENCES Ref.Staff(EmployeeNumber)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE Work.PersonalAccountLiving ADD CONSTRAINT FK_PersonalAccounts_PersonalAccountLiving FOREIGN KEY(PersonalAccountID)
REFERENCES Ref.PersonalAccounts(ID)
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE Work.PersonalAccountIndicators ADD CONSTRAINT FK_PersonalAccounts_PersonalAccountIndicators FOREIGN KEY(PersonalAccountID)
REFERENCES Ref.PersonalAccounts(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;


ALTER TABLE Ref.PersonalAccounts ADD CONSTRAINT FK_Buildings_PersonalAccounts FOREIGN KEY(BuildingID)
REFERENCES Ref.Buildings(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;


ALTER TABLE Ref.AddressObjects ADD CONSTRAINT FK_AddressObjectTypes_AddressObjects FOREIGN KEY(ObjectTypeID)
REFERENCES CD.AddressObjectTypes(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE Ref.AddressObjects ADD CONSTRAINT FK_AddressObjects_AddressObjects FOREIGN KEY(ParentID)
REFERENCES Ref.AddressObjects(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;


ALTER TABLE Ref.Buildings ADD CONSTRAINT FK_AddressObjects_Buildings_Region FOREIGN KEY(RegionID)
REFERENCES Ref.AddressObjects(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE Ref.Buildings ADD CONSTRAINT FK_AddressObjects_Buildings_Town FOREIGN KEY(TownID)
REFERENCES Ref.AddressObjects(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE Ref.Buildings ADD CONSTRAINT FK_AddressObjects_Buildings_Municipality FOREIGN KEY(MunicipalityID)
REFERENCES Ref.AddressObjects(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE Ref.Buildings ADD CONSTRAINT FK_AddressObjects_Buildings_Street FOREIGN KEY(StreetID)
REFERENCES Ref.AddressObjects(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;


ALTER TABLE Ref.Persons ADD CONSTRAINT FK_AddressObjects_Persons_Region FOREIGN KEY(DeliveryRegionID)
REFERENCES Ref.AddressObjects(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE Ref.Persons ADD CONSTRAINT FK_AddressObjects_Persons_Town FOREIGN KEY(DeliveryTownID)
REFERENCES Ref.AddressObjects(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE Ref.Persons ADD CONSTRAINT FK_AddressObjects_Persons_Municipality FOREIGN KEY(DeliveryMunicipalityID)
REFERENCES Ref.AddressObjects(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE Ref.Persons ADD CONSTRAINT FK_AddressObjects_Persons_Street FOREIGN KEY(DeliveryStreetID)
REFERENCES Ref.AddressObjects(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;


ALTER TABLE Work.PersonalAccountLiving ADD CONSTRAINT FK_Persons_PersonalAccountLiving FOREIGN KEY(PersonID)
REFERENCES Ref.Persons(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

ALTER TABLE Ref.Staff ADD CONSTRAINT FK_Persons_Staff FOREIGN KEY(PersonID)
REFERENCES Ref.Persons(ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION;


-- �������
CREATE NONCLUSTERED INDEX IX_AddressObjects_ParentTD ON Ref.AddressObjects(ParentID);
CREATE NONCLUSTERED INDEX IX_PersonalAccountLiving_PersonalAccountID ON Work.PersonalAccountLiving(PersonalAccountID);
CREATE NONCLUSTERED INDEX IX_PersonalAccountLiving_PersonID ON Work.PersonalAccountLiving(PersonID);
CREATE NONCLUSTERED INDEX IX_PersonalAccountEvents_PersonalAccountID ON Work.PersonalAccountEvents(PersonalAccountID);
CREATE NONCLUSTERED INDEX IX_PersonalAccountEvents_StaffID ON Work.PersonalAccountEvents(StaffID);
CREATE NONCLUSTERED INDEX IX_PersonalAccounts_StaffID ON Ref.PersonalAccounts(StaffID);
CREATE NONCLUSTERED INDEX IX_PersonalAccountIndicators_PersonalAccountID ON Work.PersonalAccountIndicators(PersonalAccountID);
CREATE NONCLUSTERED INDEX IX_MeterDeviceScales_DeviceID_ScaleID ON Work.MeterDeviceScales
(
	MeterDeviceID, 
	ScaleID
);
CREATE NONCLUSTERED INDEX IX_MeterDeviceIndicators_MeterDeviceID ON Work.MeterDeviceIndicators(MeterDeviceID);
CREATE NONCLUSTERED INDEX IX_MeterDeviceIndicators_PersonalAccountIndicatorID ON Work.MeterDeviceIndicators(PersonalAccountIndicatorID);
CREATE NONCLUSTERED INDEX IX_Charges_Period_SupplierID_PersonalAccountIndicatorID ON Calc.Charges
(
	Period,
	SupplierID,
	PersonalAccountIndicatorID
);
CREATE NONCLUSTERED INDEX IX_Charges_Period_PersonalAccountID ON Calc.Charges
(
	Period,
	PersonalAccountID
);
CREATE NONCLUSTERED INDEX IX_Payments_Period_SupplierID_PersonalAccountIndicatorID ON Calc.Payments
(
	Period,
	SupplierID,
	PersonalAccountIndicatorID
);
CREATE NONCLUSTERED INDEX IX_Payments_Period_PersonalAccountID ON Calc.Payments
(
	Period,
	PersonalAccountID
);
CREATE NONCLUSTERED INDEX IX_Balance_Period_SupplierID_PersonalAccountIndicatorID ON Calc.Balance
(
	Period,
	SupplierID,
	PersonalAccountIndicatorID
);
CREATE NONCLUSTERED INDEX IX_Balance_Period_PersonalAccountID ON Calc.Balance
(
	Period,
	PersonalAccountID
);


-- �����������

ALTER TABLE Work.MeterDeviceReadings ADD CONSTRAINT DF_MeterDeviceReadings_ReadingDate CHECK (ReadingDate <= GETDATE());
ALTER TABLE Work.PersonalAccountIndicators ADD CONSTRAINT DF_PersonalAccountIndicators_DateEnd CHECK (DateEnd > DateBegin OR DateEnd IS NULL);
ALTER TABLE Ref.PersonalAccounts ADD CONSTRAINT DF_PersonalAccounts_DateEnd CHECK (DateEnd > DateBegin OR DateEnd IS NULL);
ALTER TABLE Ref.Suppliers ADD CONSTRAINT DF_Suppliers_INN_Unique UNIQUE(INN);
ALTER TABLE Ref.Suppliers ADD CONSTRAINT DF_Suppliers_INN_Len CHECK (LEN(INN)=12);
ALTER TABLE Ref.Persons ADD CONSTRAINT DF_Persons_Email CHECK(Email LIKE '%@%.__%');
GO


-- �������� ������

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� � �������� �������' , @level0type=N'SCHEMA',@level0name=N'Calc', @level1type=N'TABLE',@level1name=N'Balance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����������' , @level0type=N'SCHEMA',@level0name=N'Calc', @level1type=N'TABLE',@level1name=N'Charges'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������' , @level0type=N'SCHEMA',@level0name=N'Calc', @level1type=N'TABLE',@level1name=N'Payments'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� �������� ��������' , @level0type=N'SCHEMA',@level0name=N'CD', @level1type=N'TABLE',@level1name=N'AddressObjectTypes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������ �������' , @level0type=N'SCHEMA',@level0name=N'CD', @level1type=N'TABLE',@level1name=N'CalculationMethods'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� ������� �����������' , @level0type=N'SCHEMA',@level0name=N'CD', @level1type=N'TABLE',@level1name=N'IndicatorTypes'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���������' , @level0type=N'SCHEMA',@level0name=N'CD', @level1type=N'TABLE',@level1name=N'Normatives'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� �����' , @level0type=N'SCHEMA',@level0name=N'CD', @level1type=N'TABLE',@level1name=N'Scales'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������' , @level0type=N'SCHEMA',@level0name=N'CD', @level1type=N'TABLE',@level1name=N'Tariffs'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������� ���������' , @level0type=N'SCHEMA',@level0name=N'CD', @level1type=N'TABLE',@level1name=N'Units'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�������� �������' , @level0type=N'SCHEMA',@level0name=N'Ref', @level1type=N'TABLE',@level1name=N'AddressObjects'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'��������' , @level0type=N'SCHEMA',@level0name=N'Ref', @level1type=N'TABLE',@level1name=N'Buildings'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������� �����' , @level0type=N'SCHEMA',@level0name=N'Ref', @level1type=N'TABLE',@level1name=N'MeterDevices'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������� �����' , @level0type=N'SCHEMA',@level0name=N'Ref', @level1type=N'TABLE',@level1name=N'PersonalAccounts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���������� ����' , @level0type=N'SCHEMA',@level0name=N'Ref', @level1type=N'TABLE',@level1name=N'Persons'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����������' , @level0type=N'SCHEMA',@level0name=N'Ref', @level1type=N'TABLE',@level1name=N'Staff'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����������' , @level0type=N'SCHEMA',@level0name=N'Ref', @level1type=N'TABLE',@level1name=N'Suppliers'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�������� �������� ����� � ������� �����������' , @level0type=N'SCHEMA',@level0name=N'Work', @level1type=N'TABLE',@level1name=N'MeterDeviceIndicators'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'��������� �������� �����' , @level0type=N'SCHEMA',@level0name=N'Work', @level1type=N'TABLE',@level1name=N'MeterDeviceReadings'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ����� �������� �����' , @level0type=N'SCHEMA',@level0name=N'Work', @level1type=N'TABLE',@level1name=N'MeterDeviceScales'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������� ������������� �����' , @level0type=N'SCHEMA',@level0name=N'Work', @level1type=N'TABLE',@level1name=N'PersonalAccountEvents'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�������� ������� ����������� � ������� ������' , @level0type=N'SCHEMA',@level0name=N'Work', @level1type=N'TABLE',@level1name=N'PersonalAccountIndicators'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����������� �� �������� �����' , @level0type=N'SCHEMA',@level0name=N'Work', @level1type=N'TABLE',@level1name=N'PersonalAccountLiving'
GO


-- �������� �����

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Balance', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ����������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Balance', @level2type=N'COLUMN', @level2name=N'SupplierID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� �������� �����', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Balance', @level2type=N'COLUMN', @level2name=N'PersonalAccountID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� �������� ����������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Balance', @level2type=N'COLUMN', @level2name=N'PersonalAccountIndicatorID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Balance', @level2type=N'COLUMN', @level2name=N'Period'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�����', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Balance', @level2type=N'COLUMN', @level2name=N'Amount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Charges', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ����������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Charges', @level2type=N'COLUMN', @level2name=N'SupplierID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� �������� �����', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Charges', @level2type=N'COLUMN', @level2name=N'PersonalAccountID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� �������� ����������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Charges', @level2type=N'COLUMN', @level2name=N'PersonalAccountIndicatorID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Charges', @level2type=N'COLUMN', @level2name=N'Period'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Charges', @level2type=N'COLUMN', @level2name=N'Quantity'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�����', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Charges', @level2type=N'COLUMN', @level2name=N'Amount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Payments', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ����������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Payments', @level2type=N'COLUMN', @level2name=N'SupplierID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� �������� �����', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Payments', @level2type=N'COLUMN', @level2name=N'PersonalAccountID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� �������� ����������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Payments', @level2type=N'COLUMN', @level2name=N'PersonalAccountIndicatorID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Payments', @level2type=N'COLUMN', @level2name=N'Period'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�����', @level0type=N'SCHEMA', @level0name=N'Calc', @level1type=N'TABLE', @level1name=N'Payments', @level2type=N'COLUMN', @level2name=N'Amount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'AddressObjectTypes', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'AddressObjectTypes', @level2type=N'COLUMN', @level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'CalculationMethods', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'CalculationMethods', @level2type=N'COLUMN', @level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'IndicatorTypes', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'IndicatorTypes', @level2type=N'COLUMN', @level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������� ���������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'IndicatorTypes', @level2type=N'COLUMN', @level2name=N'UnitID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Normatives', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� ������ ��������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Normatives', @level2type=N'COLUMN', @level2name=N'DateBegin'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Normatives', @level2type=N'COLUMN', @level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'��������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Normatives', @level2type=N'COLUMN', @level2name=N'Value'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Scales', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Scales', @level2type=N'COLUMN', @level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Tariffs', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� ������ ��������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Tariffs', @level2type=N'COLUMN', @level2name=N'DateBegin'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Tariffs', @level2type=N'COLUMN', @level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'��������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Tariffs', @level2type=N'COLUMN', @level2name=N'Value'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Units', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������', @level0type=N'SCHEMA', @level0name=N'CD', @level1type=N'TABLE', @level1name=N'Units', @level2type=N'COLUMN', @level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'AddressObjects', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������������ ������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'AddressObjects', @level2type=N'COLUMN', @level2name=N'ParentID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ���� ��������� �������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'AddressObjects', @level2type=N'COLUMN', @level2name=N'ObjectTypeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'AddressObjects', @level2type=N'COLUMN', @level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Buildings', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ��������� ������� (������)', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Buildings', @level2type=N'COLUMN', @level2name=N'RegionID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ��������� ������� (�����)', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Buildings', @level2type=N'COLUMN', @level2name=N'TownID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ��������� ������� (�������������)', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Buildings', @level2type=N'COLUMN', @level2name=N'MunicipalityID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ��������� ������� (�����)', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Buildings', @level2type=N'COLUMN', @level2name=N'StreetID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����� ��������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Buildings', @level2type=N'COLUMN', @level2name=N'Number'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�������� ������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Buildings', @level2type=N'COLUMN', @level2name=N'ZipCode'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������ �����', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Buildings', @level2type=N'COLUMN', @level2name=N'FullAddress'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'MeterDevices', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�������� �����', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'MeterDevices', @level2type=N'COLUMN', @level2name=N'SerialNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� �������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'MeterDevices', @level2type=N'COLUMN', @level2name=N'VerificationDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�������� ������ ����� �� ����', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'MeterDevices', @level2type=N'COLUMN', @level2name=N'ReplaceUpToDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'PersonalAccounts', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����� �������� �����', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'PersonalAccounts', @level2type=N'COLUMN', @level2name=N'AccountNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� ��������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'PersonalAccounts', @level2type=N'COLUMN', @level2name=N'DateBegin'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� ��������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'PersonalAccounts', @level2type=N'COLUMN', @level2name=N'DateEnd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ��������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'PersonalAccounts', @level2type=N'COLUMN', @level2name=N'BuildingID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����� ���������/��������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'PersonalAccounts', @level2type=N'COLUMN', @level2name=N'PremiseNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����������� ����������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'PersonalAccounts', @level2type=N'COLUMN', @level2name=N'StaffID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'FirstName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'SecondName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'��������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'ThirdName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'��� (1 - �������, 0 - �������)', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'Gender'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� ��������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'BirthDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'Phone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����� ����������� �����', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ��������� ������� �������� ���������� (������)', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'DeliveryRegionID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ��������� ������� �������� ���������� (�����)', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'DeliveryTownID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ��������� ������� �������� ���������� (�������������)', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'DeliveryMunicipalityID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ��������� ������� �������� ���������� (�����)', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'DeliveryStreetID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����� �������� ��� �������� ����������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'DeliveryBuildingNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����� ���������/�������� ��� �������� ����������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Persons', @level2type=N'COLUMN', @level2name=N'DeliveryPremiseNumber'
GO 

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'��������� ����� ����������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Staff', @level2type=N'COLUMN', @level2name=N'EmployeeNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ����������� ����', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Staff', @level2type=N'COLUMN', @level2name=N'PersonID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Staff', @level2type=N'COLUMN', @level2name=N'Position'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Suppliers', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Suppliers', @level2type=N'COLUMN', @level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�����', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Suppliers', @level2type=N'COLUMN', @level2name=N'Address'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Suppliers', @level2type=N'COLUMN', @level2name=N'INN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���', @level0type=N'SCHEMA', @level0name=N'Ref', @level1type=N'TABLE', @level1name=N'Suppliers', @level2type=N'COLUMN', @level2name=N'KPP'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceIndicators', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������� �����', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceIndicators', @level2type=N'COLUMN', @level2name=N'MeterDeviceID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� �������� ����������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceIndicators', @level2type=N'COLUMN', @level2name=N'PersonalAccountIndicatorID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� ��������� ������� �����', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceIndicators', @level2type=N'COLUMN', @level2name=N'InstallationDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� ������ ������� �����', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceIndicators', @level2type=N'COLUMN', @level2name=N'RemovingDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceReadings', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ����� ������� �����', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceReadings', @level2type=N'COLUMN', @level2name=N'MeterDeviceScaleID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� ���������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceReadings', @level2type=N'COLUMN', @level2name=N'ReadingDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�������� ���������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceReadings', @level2type=N'COLUMN', @level2name=N'ReadingValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceScales', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������� �����', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceScales', @level2type=N'COLUMN', @level2name=N'MeterDeviceID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ����� ������� �����', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'MeterDeviceScales', @level2type=N'COLUMN', @level2name=N'ScaleID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountEvents', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� �������� �����', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountEvents', @level2type=N'COLUMN', @level2name=N'PersonalAccountID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� �������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountEvents', @level2type=N'COLUMN', @level2name=N'Date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'��������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountEvents', @level2type=N'COLUMN', @level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountEvents', @level2type=N'COLUMN', @level2name=N'StaffID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountIndicators', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� �������� �����', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountIndicators', @level2type=N'COLUMN', @level2name=N'PersonalAccountID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ���� �������� ����������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountIndicators', @level2type=N'COLUMN', @level2name=N'IndicatorTypeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� �������� �������� ����������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountIndicators', @level2type=N'COLUMN', @level2name=N'DateBegin'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� �������� �������� ����������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountIndicators', @level2type=N'COLUMN', @level2name=N'DateEnd'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ����������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountIndicators', @level2type=N'COLUMN', @level2name=N'SupplierID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������ �������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountIndicators', @level2type=N'COLUMN', @level2name=N'CalculationMethodID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountIndicators', @level2type=N'COLUMN', @level2name=N'TariffID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ���������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountIndicators', @level2type=N'COLUMN', @level2name=N'NormativeID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountLiving', @level2type=N'COLUMN', @level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� �������� �����', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountLiving', @level2type=N'COLUMN', @level2name=N'PersonalAccountID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'������������� ����������� ����', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountLiving', @level2type=N'COLUMN', @level2name=N'PersonID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'��� �����������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountLiving', @level2type=N'COLUMN', @level2name=N'IsOwner'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'���� ������ �������� ������� ������', @level0type=N'SCHEMA', @level0name=N'Work', @level1type=N'TABLE', @level1name=N'PersonalAccountLiving', @level2type=N'COLUMN', @level2name=N'OwnershipDateBegin'
GO
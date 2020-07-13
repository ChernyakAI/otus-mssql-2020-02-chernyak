USE [master]
GO
/****** Object:  Database [RKCDW]    Script Date: 26.05.2020 21:45:34 ******/
CREATE DATABASE [RKCDW]
WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [RKCDW] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [RKCDW].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [RKCDW] SET ANSI_NULL_DEFAULT ON 
GO
ALTER DATABASE [RKCDW] SET ANSI_NULLS ON 
GO
ALTER DATABASE [RKCDW] SET ANSI_PADDING ON 
GO
ALTER DATABASE [RKCDW] SET ANSI_WARNINGS ON 
GO
ALTER DATABASE [RKCDW] SET ARITHABORT ON 
GO
ALTER DATABASE [RKCDW] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [RKCDW] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [RKCDW] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [RKCDW] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [RKCDW] SET CURSOR_DEFAULT  LOCAL 
GO
ALTER DATABASE [RKCDW] SET CONCAT_NULL_YIELDS_NULL ON 
GO
ALTER DATABASE [RKCDW] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [RKCDW] SET QUOTED_IDENTIFIER ON 
GO
ALTER DATABASE [RKCDW] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [RKCDW] SET  DISABLE_BROKER 
GO
ALTER DATABASE [RKCDW] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [RKCDW] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [RKCDW] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [RKCDW] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [RKCDW] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [RKCDW] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [RKCDW] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [RKCDW] SET RECOVERY FULL 
GO
ALTER DATABASE [RKCDW] SET  MULTI_USER 
GO
ALTER DATABASE [RKCDW] SET PAGE_VERIFY NONE  
GO
ALTER DATABASE [RKCDW] SET DB_CHAINING OFF 
GO
ALTER DATABASE [RKCDW] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [RKCDW] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [RKCDW] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'RKCDW', N'ON'
GO
ALTER DATABASE [RKCDW] SET QUERY_STORE = OFF
GO
USE [RKCDW]
GO
/****** Object:  Table [dbo].[DimAccounts]    Script Date: 26.05.2020 21:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimAccounts](
	[AccountID] [int] NOT NULL,
	[Number] [nvarchar](25) NULL,
	[IndicatorType] [nvarchar](250) NULL,
	[SupplierID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimCalculationFeatures]    Script Date: 26.05.2020 21:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimCalculationFeatures](
	[CalculationFeatureID] [int] NOT NULL,
	[IndicatorType] [nvarchar](250) NULL,
	[CalculationMethod] [nvarchar](250) NULL,
	[Tariff] [nvarchar](250) NULL,
	[Normative] [nvarchar](250) NULL,
PRIMARY KEY CLUSTERED 
(
	[CalculationFeatureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimLocations]    Script Date: 26.05.2020 21:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimLocations](
	[LocationID] [int] NOT NULL,
	[ZipCode] [nvarchar](50) NULL,
	[Region] [nvarchar](250) NULL,
	[Town] [nvarchar](250) NULL,
	[Municipality] [nvarchar](250) NULL,
	[Street] [nvarchar](250) NULL,
	[BuildingNumber] [nvarchar](20) NULL,
	[PremiseNumber] [nvarchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimPersons]    Script Date: 26.05.2020 21:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPersons](
	[PersonID] [int] NOT NULL,
	[IsEmployee] [tinyint] NULL,
	[FIO] [nvarchar](400) NULL,
	[Gender] [tinyint] NULL,
	[BirthDate] [date] NULL,
	[Phone] [nvarchar](50) NULL,
	[Email] [nvarchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimSuppliers]    Script Date: 26.05.2020 21:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimSuppliers](
	[SupplierID] [int] NOT NULL,
	[Name] [nvarchar](250) NULL,
	[Address] [nvarchar](250) NULL,
PRIMARY KEY CLUSTERED 
(
	[SupplierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactBalance]    Script Date: 26.05.2020 21:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactBalance](
	[BalanceID] [bigint] NOT NULL,
	[SupplierID] [int] NULL,
	[AccountID] [int] NULL,
	[AddressID] [int] NULL,
	[Period] [nchar](10) NULL,
	[CalendarYear] [smallint] NULL,
	[CalendarQuarter] [tinyint] NULL,
	[Amount] [decimal](15, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[BalanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactCalculations]    Script Date: 26.05.2020 21:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactCalculations](
	[CalculationID] [bigint] NOT NULL,
	[CalculationFeatureID] [int] NULL,
	[AddressID] [int] NULL,
	[CalendarYear] [smallint] NULL,
	[CalendarQuarter] [tinyint] NULL,
	[CalendarMonth] [tinyint] NULL,
	[AddressesCount] [int] NULL,
	[AccountsCount] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[CalculationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactCharges]    Script Date: 26.05.2020 21:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactCharges](
	[ChargeID] [bigint] NOT NULL,
	[SupplierID] [int] NULL,
	[AccountID] [int] NULL,
	[AddressID] [int] NULL,
	[Period] [nchar](10) NULL,
	[CalendarYear] [smallint] NULL,
	[CalendarQuarter] [tinyint] NULL,
	[Amount] [decimal](15, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[ChargeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactPayments]    Script Date: 26.05.2020 21:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPayments](
	[PaymentID] [bigint] NOT NULL,
	[SupplierID] [int] NULL,
	[AccountID] [int] NULL,
	[AddressID] [int] NULL,
	[Period] [nchar](10) NULL,
	[CalendarYear] [smallint] NULL,
	[CalendarQuarter] [tinyint] NULL,
	[Amount] [decimal](15, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactPersons]    Script Date: 26.05.2020 21:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactPersons](
	[PersonID] [int] NOT NULL,
	[DeliveryAdressIsDifferent] [tinyint] NULL,
	[NumberOfAccounts] [smallint] NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactWorkingByAddress]    Script Date: 26.05.2020 21:45:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactWorkingByAddress](
	[WBAID] [int] NOT NULL,
	[AddressID] [int] NULL,
	[PersonID] [int] NULL,
	[EventDate] [date] NULL,
	[CalendarYear] [smallint] NULL,
	[CalendarQuarter] [tinyint] NULL,
	[CalendarMonth] [tinyint] NULL,
	[Description] [nvarchar](max) NULL,
	[IsMeterReadingsAccept] [tinyint] NULL,
PRIMARY KEY CLUSTERED 
(
	[WBAID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[DimAccounts]  WITH CHECK ADD  CONSTRAINT [FK_DimAccounts_DimSuppliers] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[DimSuppliers] ([SupplierID])
GO
ALTER TABLE [dbo].[DimAccounts] CHECK CONSTRAINT [FK_DimAccounts_DimSuppliers]
GO
ALTER TABLE [dbo].[FactBalance]  WITH CHECK ADD  CONSTRAINT [FK_FactBalance_DimAccounts] FOREIGN KEY([AccountID])
REFERENCES [dbo].[DimAccounts] ([AccountID])
GO
ALTER TABLE [dbo].[FactBalance] CHECK CONSTRAINT [FK_FactBalance_DimAccounts]
GO
ALTER TABLE [dbo].[FactBalance]  WITH CHECK ADD  CONSTRAINT [FK_FactBalance_DimLocations] FOREIGN KEY([AddressID])
REFERENCES [dbo].[DimLocations] ([LocationID])
GO
ALTER TABLE [dbo].[FactBalance] CHECK CONSTRAINT [FK_FactBalance_DimLocations]
GO
ALTER TABLE [dbo].[FactBalance]  WITH CHECK ADD  CONSTRAINT [FK_FactBalance_DimSuppliers] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[DimSuppliers] ([SupplierID])
GO
ALTER TABLE [dbo].[FactBalance] CHECK CONSTRAINT [FK_FactBalance_DimSuppliers]
GO
ALTER TABLE [dbo].[FactCalculations]  WITH CHECK ADD  CONSTRAINT [FK_FactCalculations_DimCalculationFeatures] FOREIGN KEY([CalculationFeatureID])
REFERENCES [dbo].[DimCalculationFeatures] ([CalculationFeatureID])
GO
ALTER TABLE [dbo].[FactCalculations] CHECK CONSTRAINT [FK_FactCalculations_DimCalculationFeatures]
GO
ALTER TABLE [dbo].[FactCalculations]  WITH CHECK ADD  CONSTRAINT [FK_FactCalculations_DimLocations] FOREIGN KEY([AddressID])
REFERENCES [dbo].[DimLocations] ([LocationID])
GO
ALTER TABLE [dbo].[FactCalculations] CHECK CONSTRAINT [FK_FactCalculations_DimLocations]
GO
ALTER TABLE [dbo].[FactCharges]  WITH CHECK ADD  CONSTRAINT [FK_FactCharges_DimAccounts] FOREIGN KEY([AccountID])
REFERENCES [dbo].[DimAccounts] ([AccountID])
GO
ALTER TABLE [dbo].[FactCharges] CHECK CONSTRAINT [FK_FactCharges_DimAccounts]
GO
ALTER TABLE [dbo].[FactCharges]  WITH CHECK ADD  CONSTRAINT [FK_FactCharges_DimLocations] FOREIGN KEY([AddressID])
REFERENCES [dbo].[DimLocations] ([LocationID])
GO
ALTER TABLE [dbo].[FactCharges] CHECK CONSTRAINT [FK_FactCharges_DimLocations]
GO
ALTER TABLE [dbo].[FactCharges]  WITH CHECK ADD  CONSTRAINT [FK_FactCharges_DimSuppliers] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[DimSuppliers] ([SupplierID])
GO
ALTER TABLE [dbo].[FactCharges] CHECK CONSTRAINT [FK_FactCharges_DimSuppliers]
GO
ALTER TABLE [dbo].[FactPayments]  WITH CHECK ADD  CONSTRAINT [FK_FactPayments_DimAccounts] FOREIGN KEY([AccountID])
REFERENCES [dbo].[DimAccounts] ([AccountID])
GO
ALTER TABLE [dbo].[FactPayments] CHECK CONSTRAINT [FK_FactPayments_DimAccounts]
GO
ALTER TABLE [dbo].[FactPayments]  WITH CHECK ADD  CONSTRAINT [FK_FactPayments_DimLocations] FOREIGN KEY([AddressID])
REFERENCES [dbo].[DimLocations] ([LocationID])
GO
ALTER TABLE [dbo].[FactPayments] CHECK CONSTRAINT [FK_FactPayments_DimLocations]
GO
ALTER TABLE [dbo].[FactPayments]  WITH CHECK ADD  CONSTRAINT [FK_FactPayments_DimSuppliers] FOREIGN KEY([SupplierID])
REFERENCES [dbo].[DimSuppliers] ([SupplierID])
GO
ALTER TABLE [dbo].[FactPayments] CHECK CONSTRAINT [FK_FactPayments_DimSuppliers]
GO
ALTER TABLE [dbo].[FactPersons]  WITH CHECK ADD  CONSTRAINT [FK_FactPersons_DimPersons] FOREIGN KEY([PersonID])
REFERENCES [dbo].[DimPersons] ([PersonID])
GO
ALTER TABLE [dbo].[FactPersons] CHECK CONSTRAINT [FK_FactPersons_DimPersons]
GO
ALTER TABLE [dbo].[FactWorkingByAddress]  WITH CHECK ADD  CONSTRAINT [FK_FactWorkingByAddress_DimLocations] FOREIGN KEY([AddressID])
REFERENCES [dbo].[DimLocations] ([LocationID])
GO
ALTER TABLE [dbo].[FactWorkingByAddress] CHECK CONSTRAINT [FK_FactWorkingByAddress_DimLocations]
GO
ALTER TABLE [dbo].[FactWorkingByAddress]  WITH CHECK ADD  CONSTRAINT [FK_FactWorkingByAddress_DimPersons] FOREIGN KEY([PersonID])
REFERENCES [dbo].[DimPersons] ([PersonID])
GO
ALTER TABLE [dbo].[FactWorkingByAddress] CHECK CONSTRAINT [FK_FactWorkingByAddress_DimPersons]
GO
USE [master]
GO
ALTER DATABASE [RKCDW] SET  READ_WRITE 
GO

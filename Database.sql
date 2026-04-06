/*
    TechZone_AllInOne_ResetAndBuild.sql

    Muc tieu:
    - Xoa sach hoan toan database cu TechZoneStoreDb (neu da ton tai)
    - Tao lai toan bo schema
    - Seed/import du lieu tu Excel
    - Seed du lieu kho / nha cung cap / nhap hang / stock transactions
    - Tao report sample
    - Tao admin dashboard views

    CANH BAO:
    - Script nay SE XOA TOAN BO database [TechZoneStoreDb] neu dang ton tai.
    - Hay sao luu truoc khi chay tren moi truong co du lieu quan trong.
*/

USE [master];
GO

IF DB_ID(N'TechZoneStoreDb') IS NOT NULL
BEGIN
    ALTER DATABASE [TechZoneStoreDb] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [TechZoneStoreDb];
END
GO

PRINT N'Da xoa sach database cu (neu co). Bat dau tao lai tu dau...';
GO


/* ============================================================================
   BEGIN FILE: TechZone_FullSchema.sql
   ============================================================================ */


/*
    TechZone_FullSchema.sql
    Muc tieu:
    - Tao bo schema SQL Server day du cho do an website linh kien may tinh
    - Dong bo voi:
      + TechZone.sql hien tai (ASP.NET Core Identity + cac bang ban hang co ban)
      + ERD / bao cao phan tich du lieu da chot
      + Workbook PowerTech_ProductData_Full_With_Laptops_updated_loa_pcbo.xlsx

    Ghi chu:
    - Script nay thiet ke cho SQL Server.
    - Huong den mo hinh EF Core Code First + ASP.NET Core Identity.
    - Day la schema "full" de chay tren database moi / moi truong moi.
    - Mot so bang cu trong TechZone.sql da duoc nang cap:
        * OrderDetails -> OrderItems
        * ProductSpecifications -> mo hinh typed specs (SpecDefinitionId, ValueText, ValueNumber, ValueBoolean)
        * CustomerProfiles / EmployeeProfiles -> gop logic vao AspNetUsers + AspNetUserRoles + UserAddresses
*/

USE [master];
GO

IF DB_ID(N'TechZoneStoreDb') IS NULL
BEGIN
    CREATE DATABASE [TechZoneStoreDb];
END
GO

USE [TechZoneStoreDb];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   1) EF Core migration history
   ========================================================= */
IF OBJECT_ID(N'dbo.__EFMigrationsHistory', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.__EFMigrationsHistory
    (
        MigrationId     NVARCHAR(150) NOT NULL,
        ProductVersion  NVARCHAR(32)  NOT NULL,
        CONSTRAINT PK___EFMigrationsHistory PRIMARY KEY CLUSTERED (MigrationId)
    );
END
GO

/* =========================================================
   2) ASP.NET Core Identity
   ========================================================= */
IF OBJECT_ID(N'dbo.AspNetRoles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AspNetRoles
    (
        Id                NVARCHAR(450) NOT NULL,
        Name              NVARCHAR(256) NULL,
        NormalizedName    NVARCHAR(256) NULL,
        ConcurrencyStamp  NVARCHAR(MAX) NULL,
        Description       NVARCHAR(500) NULL,
        IsActive          BIT NOT NULL CONSTRAINT DF_AspNetRoles_IsActive DEFAULT (1),
        CreatedAt         DATETIME2(7) NOT NULL CONSTRAINT DF_AspNetRoles_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_AspNetRoles PRIMARY KEY CLUSTERED (Id)
    );
END
GO

IF OBJECT_ID(N'dbo.AspNetUsers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AspNetUsers
    (
        Id                   NVARCHAR(450) NOT NULL,
        UserName             NVARCHAR(256) NULL,
        NormalizedUserName   NVARCHAR(256) NULL,
        Email                NVARCHAR(256) NULL,
        NormalizedEmail      NVARCHAR(256) NULL,
        EmailConfirmed       BIT NOT NULL CONSTRAINT DF_AspNetUsers_EmailConfirmed DEFAULT (0),
        PasswordHash         NVARCHAR(MAX) NULL,
        SecurityStamp        NVARCHAR(MAX) NULL,
        ConcurrencyStamp     NVARCHAR(MAX) NULL,
        PhoneNumber          NVARCHAR(20) NULL,
        PhoneNumberConfirmed BIT NOT NULL CONSTRAINT DF_AspNetUsers_PhoneConfirmed DEFAULT (0),
        TwoFactorEnabled     BIT NOT NULL CONSTRAINT DF_AspNetUsers_TwoFactor DEFAULT (0),
        LockoutEnd           DATETIMEOFFSET(7) NULL,
        LockoutEnabled       BIT NOT NULL CONSTRAINT DF_AspNetUsers_LockoutEnabled DEFAULT (1),
        AccessFailedCount    INT NOT NULL CONSTRAINT DF_AspNetUsers_AccessFailedCount DEFAULT (0),

        FullName             NVARCHAR(150) NULL,
        AvatarUrl            NVARCHAR(1000) NULL,
        IsActive             BIT NOT NULL CONSTRAINT DF_AspNetUsers_IsActive DEFAULT (1),
        MustChangePassword   BIT NOT NULL CONSTRAINT DF_AspNetUsers_MustChangePassword DEFAULT (0),
        CreatedByUserId      NVARCHAR(450) NULL,
        CreatedAt            DATETIME2(7) NOT NULL CONSTRAINT DF_AspNetUsers_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt            DATETIME2(7) NULL,

        CONSTRAINT PK_AspNetUsers PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_AspNetUsers_AspNetUsers_CreatedByUserId
            FOREIGN KEY (CreatedByUserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE NO ACTION
    );
END
GO

IF OBJECT_ID(N'dbo.AspNetRoleClaims', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AspNetRoleClaims
    (
        Id          INT IDENTITY(1,1) NOT NULL,
        RoleId      NVARCHAR(450) NOT NULL,
        ClaimType   NVARCHAR(MAX) NULL,
        ClaimValue  NVARCHAR(MAX) NULL,
        CONSTRAINT PK_AspNetRoleClaims PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_AspNetRoleClaims_AspNetRoles_RoleId
            FOREIGN KEY (RoleId) REFERENCES dbo.AspNetRoles(Id)
            ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.AspNetUserClaims', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AspNetUserClaims
    (
        Id          INT IDENTITY(1,1) NOT NULL,
        UserId      NVARCHAR(450) NOT NULL,
        ClaimType   NVARCHAR(MAX) NULL,
        ClaimValue  NVARCHAR(MAX) NULL,
        CONSTRAINT PK_AspNetUserClaims PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_AspNetUserClaims_AspNetUsers_UserId
            FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.AspNetUserLogins', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AspNetUserLogins
    (
        LoginProvider       NVARCHAR(128) NOT NULL,
        ProviderKey         NVARCHAR(128) NOT NULL,
        ProviderDisplayName NVARCHAR(MAX) NULL,
        UserId              NVARCHAR(450) NOT NULL,
        CONSTRAINT PK_AspNetUserLogins PRIMARY KEY CLUSTERED (LoginProvider, ProviderKey),
        CONSTRAINT FK_AspNetUserLogins_AspNetUsers_UserId
            FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.AspNetUserRoles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AspNetUserRoles
    (
        UserId NVARCHAR(450) NOT NULL,
        RoleId NVARCHAR(450) NOT NULL,
        CONSTRAINT PK_AspNetUserRoles PRIMARY KEY CLUSTERED (UserId, RoleId),
        CONSTRAINT FK_AspNetUserRoles_AspNetUsers_UserId
            FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE CASCADE,
        CONSTRAINT FK_AspNetUserRoles_AspNetRoles_RoleId
            FOREIGN KEY (RoleId) REFERENCES dbo.AspNetRoles(Id)
            ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.AspNetUserTokens', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AspNetUserTokens
    (
        UserId        NVARCHAR(450) NOT NULL,
        LoginProvider NVARCHAR(128) NOT NULL,
        [Name]        NVARCHAR(128) NOT NULL,
        [Value]       NVARCHAR(MAX) NULL,
        CONSTRAINT PK_AspNetUserTokens PRIMARY KEY CLUSTERED (UserId, LoginProvider, [Name]),
        CONSTRAINT FK_AspNetUserTokens_AspNetUsers_UserId
            FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE CASCADE
    );
END
GO

/* =========================================================
   3) Danh muc - thuong hieu - san pham
   ========================================================= */
IF OBJECT_ID(N'dbo.Categories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Categories
    (
        Id               INT IDENTITY(1,1) NOT NULL,
        ParentCategoryId INT NULL,
        [Name]           NVARCHAR(150) NOT NULL,
        Slug             NVARCHAR(180) NOT NULL,
        [Description]    NVARCHAR(500) NULL,
        DisplayOrder     INT NOT NULL CONSTRAINT DF_Categories_DisplayOrder DEFAULT (0),
        IsActive         BIT NOT NULL CONSTRAINT DF_Categories_IsActive DEFAULT (1),
        CreatedAt        DATETIME2(7) NOT NULL CONSTRAINT DF_Categories_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt        DATETIME2(7) NULL,
        CONSTRAINT PK_Categories PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_Categories_Categories_ParentCategoryId
            FOREIGN KEY (ParentCategoryId) REFERENCES dbo.Categories(Id)
            ON DELETE NO ACTION
    );
END
GO

IF OBJECT_ID(N'dbo.Brands', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Brands
    (
        Id            INT IDENTITY(1,1) NOT NULL,
        [Name]        NVARCHAR(150) NOT NULL,
        Slug          NVARCHAR(180) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        Country       NVARCHAR(100) NULL,
        LogoUrl       NVARCHAR(1000) NULL,
        IsActive      BIT NOT NULL CONSTRAINT DF_Brands_IsActive DEFAULT (1),
        CreatedAt     DATETIME2(7) NOT NULL CONSTRAINT DF_Brands_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt     DATETIME2(7) NULL,
        CONSTRAINT PK_Brands PRIMARY KEY CLUSTERED (Id)
    );
END
GO

IF OBJECT_ID(N'dbo.SpecificationDefinitions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SpecificationDefinitions
    (
        Id            INT IDENTITY(1,1) NOT NULL,
        CategoryId    INT NOT NULL,
        SpecName      NVARCHAR(150) NOT NULL,
        DisplayName   NVARCHAR(150) NULL,
        DataType      NVARCHAR(20)  NOT NULL,
        Unit          NVARCHAR(50)  NULL,
        GroupName     NVARCHAR(100) NULL,
        SortOrder     INT NOT NULL CONSTRAINT DF_SpecificationDefinitions_SortOrder DEFAULT (0),
        IsFilterable  BIT NOT NULL CONSTRAINT DF_SpecificationDefinitions_IsFilterable DEFAULT (0),
        IsRequired    BIT NOT NULL CONSTRAINT DF_SpecificationDefinitions_IsRequired DEFAULT (0),
        IsActive      BIT NOT NULL CONSTRAINT DF_SpecificationDefinitions_IsActive DEFAULT (1),
        CreatedAt     DATETIME2(7) NOT NULL CONSTRAINT DF_SpecificationDefinitions_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_SpecificationDefinitions PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_SpecificationDefinitions_Categories_CategoryId
            FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(Id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_SpecificationDefinitions_DataType
            CHECK (DataType IN (N'text', N'number', N'boolean'))
    );
END
GO

IF OBJECT_ID(N'dbo.Products', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Products
    (
        Id                INT IDENTITY(1,1) NOT NULL,
        SKU               NVARCHAR(100) NOT NULL,
        [Name]            NVARCHAR(250) NOT NULL,
        Slug              NVARCHAR(250) NOT NULL,
        CategoryId        INT NOT NULL,
        BrandId           INT NOT NULL,
        Price             DECIMAL(18,2) NOT NULL,
        DiscountPrice     DECIMAL(18,2) NULL,
        StockQuantity     INT NOT NULL CONSTRAINT DF_Products_StockQuantity DEFAULT (0),
        SoldQuantity      INT NOT NULL CONSTRAINT DF_Products_SoldQuantity DEFAULT (0),
        ShortDescription  NVARCHAR(500) NULL,
        [Description]     NVARCHAR(MAX) NULL,
        ThumbnailUrl      NVARCHAR(1000) NULL,
        WarrantyMonths    INT NOT NULL CONSTRAINT DF_Products_WarrantyMonths DEFAULT (0),
        IsFeatured        BIT NOT NULL CONSTRAINT DF_Products_IsFeatured DEFAULT (0),
        IsActive          BIT NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT (1),
        CreatedAt         DATETIME2(7) NOT NULL CONSTRAINT DF_Products_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt         DATETIME2(7) NULL,
        CONSTRAINT PK_Products PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_Products_Categories_CategoryId
            FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(Id)
            ON DELETE NO ACTION,
        CONSTRAINT FK_Products_Brands_BrandId
            FOREIGN KEY (BrandId) REFERENCES dbo.Brands(Id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_Products_Price CHECK (Price >= 0),
        CONSTRAINT CK_Products_DiscountPrice CHECK (DiscountPrice IS NULL OR DiscountPrice >= 0),
        CONSTRAINT CK_Products_DiscountLePrice CHECK (DiscountPrice IS NULL OR DiscountPrice <= Price),
        CONSTRAINT CK_Products_StockQuantity CHECK (StockQuantity >= 0),
        CONSTRAINT CK_Products_SoldQuantity CHECK (SoldQuantity >= 0),
        CONSTRAINT CK_Products_WarrantyMonths CHECK (WarrantyMonths >= 0)
    );
END
GO

IF OBJECT_ID(N'dbo.ProductImages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductImages
    (
        Id         INT IDENTITY(1,1) NOT NULL,
        ProductId  INT NOT NULL,
        ImageUrl   NVARCHAR(1000) NOT NULL,
        AltText    NVARCHAR(250) NULL,
        IsPrimary  BIT NOT NULL CONSTRAINT DF_ProductImages_IsPrimary DEFAULT (0),
        SortOrder  INT NOT NULL CONSTRAINT DF_ProductImages_SortOrder DEFAULT (0),
        CreatedAt  DATETIME2(7) NOT NULL CONSTRAINT DF_ProductImages_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_ProductImages PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_ProductImages_Products_ProductId
            FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id)
            ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.ProductSpecifications', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductSpecifications
    (
        Id                INT IDENTITY(1,1) NOT NULL,
        ProductId         INT NOT NULL,
        SpecDefinitionId  INT NOT NULL,
        ValueText         NVARCHAR(500) NULL,
        ValueNumber       DECIMAL(18,4) NULL,
        ValueBoolean      BIT NULL,
        DisplayValue      NVARCHAR(500) NULL,
        CreatedAt         DATETIME2(7) NOT NULL CONSTRAINT DF_ProductSpecifications_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_ProductSpecifications PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_ProductSpecifications_Products_ProductId
            FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id)
            ON DELETE CASCADE,
        CONSTRAINT FK_ProductSpecifications_SpecificationDefinitions_SpecDefinitionId
            FOREIGN KEY (SpecDefinitionId) REFERENCES dbo.SpecificationDefinitions(Id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_ProductSpecifications_AtLeastOneValue
            CHECK (ValueText IS NOT NULL OR ValueNumber IS NOT NULL OR ValueBoolean IS NOT NULL)
    );
END
GO

/* =========================================================
   4) Nguoi dung, dia chi, gio hang
   ========================================================= */
IF OBJECT_ID(N'dbo.UserAddresses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserAddresses
    (
        Id             INT IDENTITY(1,1) NOT NULL,
        UserId         NVARCHAR(450) NOT NULL,
        ReceiverName   NVARCHAR(150) NOT NULL,
        PhoneNumber    NVARCHAR(20) NOT NULL,
        Province       NVARCHAR(100) NULL,
        District       NVARCHAR(100) NULL,
        Ward           NVARCHAR(100) NULL,
        StreetAddress  NVARCHAR(255) NOT NULL,
        IsDefault      BIT NOT NULL CONSTRAINT DF_UserAddresses_IsDefault DEFAULT (0),
        CreatedAt      DATETIME2(7) NOT NULL CONSTRAINT DF_UserAddresses_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt      DATETIME2(7) NULL,
        CONSTRAINT PK_UserAddresses PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_UserAddresses_AspNetUsers_UserId
            FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.Carts', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Carts
    (
        Id         INT IDENTITY(1,1) NOT NULL,
        UserId     NVARCHAR(450) NOT NULL,
        CreatedAt  DATETIME2(7) NOT NULL CONSTRAINT DF_Carts_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt  DATETIME2(7) NULL,
        CONSTRAINT PK_Carts PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_Carts_AspNetUsers_UserId
            FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE CASCADE
    );
END
GO

IF OBJECT_ID(N'dbo.CartItems', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CartItems
    (
        Id         INT IDENTITY(1,1) NOT NULL,
        CartId     INT NOT NULL,
        ProductId  INT NOT NULL,
        Quantity   INT NOT NULL,
        UnitPrice  DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_CartItems PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_CartItems_Carts_CartId
            FOREIGN KEY (CartId) REFERENCES dbo.Carts(Id)
            ON DELETE CASCADE,
        CONSTRAINT FK_CartItems_Products_ProductId
            FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_CartItems_Quantity CHECK (Quantity > 0),
        CONSTRAINT CK_CartItems_UnitPrice CHECK (UnitPrice >= 0)
    );
END
GO

/* =========================================================
   5) Don hang - thanh toan
   ========================================================= */
IF OBJECT_ID(N'dbo.Orders', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders
    (
        Id               INT IDENTITY(1,1) NOT NULL,
        OrderCode        NVARCHAR(50) NOT NULL,
        UserId           NVARCHAR(450) NOT NULL,
        ReceiverName     NVARCHAR(150) NOT NULL,
        PhoneNumber      NVARCHAR(20) NOT NULL,
        ShippingAddress  NVARCHAR(500) NOT NULL,
        OrderStatus      NVARCHAR(30) NOT NULL CONSTRAINT DF_Orders_OrderStatus DEFAULT (N'Pending'),
        PaymentStatus    NVARCHAR(30) NOT NULL CONSTRAINT DF_Orders_PaymentStatus DEFAULT (N'Unpaid'),
        PaymentMethod    NVARCHAR(30) NOT NULL CONSTRAINT DF_Orders_PaymentMethod DEFAULT (N'COD'),
        Subtotal         DECIMAL(18,2) NOT NULL CONSTRAINT DF_Orders_Subtotal DEFAULT (0),
        ShippingFee      DECIMAL(18,2) NOT NULL CONSTRAINT DF_Orders_ShippingFee DEFAULT (0),
        DiscountAmount   DECIMAL(18,2) NOT NULL CONSTRAINT DF_Orders_DiscountAmount DEFAULT (0),
        TotalAmount      DECIMAL(18,2) NOT NULL CONSTRAINT DF_Orders_TotalAmount DEFAULT (0),
        CreatedAt        DATETIME2(7) NOT NULL CONSTRAINT DF_Orders_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt        DATETIME2(7) NULL,
        Note             NVARCHAR(1000) NULL,
        CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_Orders_AspNetUsers_UserId
            FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_Orders_OrderStatus CHECK (OrderStatus IN (N'Pending', N'Confirmed', N'Processing', N'Shipping', N'Completed', N'Cancelled', N'Returned')),
        CONSTRAINT CK_Orders_PaymentStatus CHECK (PaymentStatus IN (N'Unpaid', N'Pending', N'Paid', N'Failed', N'Refunded', N'PartiallyRefunded')),
        CONSTRAINT CK_Orders_PaymentMethod CHECK (PaymentMethod IN (N'COD', N'BankTransfer', N'VNPay', N'MoMo', N'ZaloPay', N'PayPal')),
        CONSTRAINT CK_Orders_Subtotal CHECK (Subtotal >= 0),
        CONSTRAINT CK_Orders_ShippingFee CHECK (ShippingFee >= 0),
        CONSTRAINT CK_Orders_DiscountAmount CHECK (DiscountAmount >= 0),
        CONSTRAINT CK_Orders_TotalAmount CHECK (TotalAmount >= 0),
        CONSTRAINT CK_Orders_TotalFormula CHECK (TotalAmount = (Subtotal + ShippingFee - DiscountAmount))
    );
END
GO

IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderItems
    (
        Id                    INT IDENTITY(1,1) NOT NULL,
        OrderId               INT NOT NULL,
        ProductId             INT NOT NULL,
        ProductNameSnapshot   NVARCHAR(250) NOT NULL,
        UnitPrice             DECIMAL(18,2) NOT NULL,
        Quantity              INT NOT NULL,
        LineTotal             DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_OrderItems PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_OrderItems_Orders_OrderId
            FOREIGN KEY (OrderId) REFERENCES dbo.Orders(Id)
            ON DELETE CASCADE,
        CONSTRAINT FK_OrderItems_Products_ProductId
            FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_OrderItems_UnitPrice CHECK (UnitPrice >= 0),
        CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
        CONSTRAINT CK_OrderItems_LineTotal CHECK (LineTotal >= 0 AND LineTotal = (UnitPrice * Quantity))
    );
END
GO

IF OBJECT_ID(N'dbo.Payments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Payments
    (
        Id               INT IDENTITY(1,1) NOT NULL,
        OrderId          INT NOT NULL,
        PaymentMethod    NVARCHAR(30) NOT NULL,
        PaymentStatus    NVARCHAR(30) NOT NULL,
        Amount           DECIMAL(18,2) NOT NULL,
        TransactionCode  NVARCHAR(100) NULL,
        PaidAt           DATETIME2(7) NULL,
        CreatedAt        DATETIME2(7) NOT NULL CONSTRAINT DF_Payments_CreatedAt DEFAULT (SYSUTCDATETIME()),
        Note             NVARCHAR(500) NULL,
        CONSTRAINT PK_Payments PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_Payments_Orders_OrderId
            FOREIGN KEY (OrderId) REFERENCES dbo.Orders(Id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_Payments_PaymentMethod CHECK (PaymentMethod IN (N'COD', N'BankTransfer', N'VNPay', N'MoMo', N'ZaloPay', N'PayPal')),
        CONSTRAINT CK_Payments_PaymentStatus CHECK (PaymentStatus IN (N'Unpaid', N'Pending', N'Paid', N'Failed', N'Refunded', N'PartiallyRefunded')),
        CONSTRAINT CK_Payments_Amount CHECK (Amount >= 0)
    );
END
GO

/* =========================================================
   6) Review - support
   ========================================================= */
IF OBJECT_ID(N'dbo.Reviews', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Reviews
    (
        Id          INT IDENTITY(1,1) NOT NULL,
        ProductId   INT NOT NULL,
        UserId      NVARCHAR(450) NOT NULL,
        Rating      TINYINT NOT NULL,
        Comment     NVARCHAR(1000) NULL,
        IsApproved  BIT NOT NULL CONSTRAINT DF_Reviews_IsApproved DEFAULT (0),
        CreatedAt   DATETIME2(7) NOT NULL CONSTRAINT DF_Reviews_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt   DATETIME2(7) NULL,
        CONSTRAINT PK_Reviews PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_Reviews_Products_ProductId
            FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id)
            ON DELETE NO ACTION,
        CONSTRAINT FK_Reviews_AspNetUsers_UserId
            FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_Reviews_Rating CHECK (Rating BETWEEN 1 AND 5)
    );
END
GO

IF OBJECT_ID(N'dbo.SupportTickets', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SupportTickets
    (
        Id                INT IDENTITY(1,1) NOT NULL,
        TicketCode        NVARCHAR(50) NOT NULL,
        UserId            NVARCHAR(450) NOT NULL,
        OrderId           INT NULL,
        Title             NVARCHAR(200) NOT NULL,
        Content           NVARCHAR(MAX) NOT NULL,
        Status            NVARCHAR(30) NOT NULL CONSTRAINT DF_SupportTickets_Status DEFAULT (N'Open'),
        Priority          NVARCHAR(20) NOT NULL CONSTRAINT DF_SupportTickets_Priority DEFAULT (N'Medium'),
        AssignedToUserId  NVARCHAR(450) NULL,
        CreatedAt         DATETIME2(7) NOT NULL CONSTRAINT DF_SupportTickets_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt         DATETIME2(7) NULL,
        ClosedAt          DATETIME2(7) NULL,
        CONSTRAINT PK_SupportTickets PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_SupportTickets_AspNetUsers_UserId
            FOREIGN KEY (UserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE NO ACTION,
        CONSTRAINT FK_SupportTickets_AspNetUsers_AssignedToUserId
            FOREIGN KEY (AssignedToUserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE SET NULL,
        CONSTRAINT FK_SupportTickets_Orders_OrderId
            FOREIGN KEY (OrderId) REFERENCES dbo.Orders(Id)
            ON DELETE SET NULL,
        CONSTRAINT CK_SupportTickets_Status CHECK (Status IN (N'Open', N'InProgress', N'Resolved', N'Closed')),
        CONSTRAINT CK_SupportTickets_Priority CHECK (Priority IN (N'Low', N'Medium', N'High', N'Urgent'))
    );
END
GO

/* =========================================================
   7) Kho - nha cung cap - nhap hang
   ========================================================= */
IF OBJECT_ID(N'dbo.Suppliers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Suppliers
    (
        Id            INT IDENTITY(1,1) NOT NULL,
        [Name]        NVARCHAR(150) NOT NULL,
        ContactName   NVARCHAR(150) NULL,
        PhoneNumber   NVARCHAR(20) NULL,
        Email         NVARCHAR(256) NULL,
        [Address]     NVARCHAR(500) NULL,
        TaxCode       NVARCHAR(50) NULL,
        IsActive      BIT NOT NULL CONSTRAINT DF_Suppliers_IsActive DEFAULT (1),
        CreatedAt     DATETIME2(7) NOT NULL CONSTRAINT DF_Suppliers_CreatedAt DEFAULT (SYSUTCDATETIME()),
        UpdatedAt     DATETIME2(7) NULL,
        CONSTRAINT PK_Suppliers PRIMARY KEY CLUSTERED (Id)
    );
END
GO

IF OBJECT_ID(N'dbo.PurchaseReceipts', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PurchaseReceipts
    (
        Id               INT IDENTITY(1,1) NOT NULL,
        ReceiptCode      NVARCHAR(50) NOT NULL,
        SupplierId       INT NOT NULL,
        CreatedByUserId  NVARCHAR(450) NOT NULL,
        ReceiptDate      DATETIME2(7) NOT NULL CONSTRAINT DF_PurchaseReceipts_ReceiptDate DEFAULT (SYSUTCDATETIME()),
        [Status]         NVARCHAR(30) NOT NULL CONSTRAINT DF_PurchaseReceipts_Status DEFAULT (N'Completed'),
        Subtotal         DECIMAL(18,2) NOT NULL CONSTRAINT DF_PurchaseReceipts_Subtotal DEFAULT (0),
        TotalAmount      DECIMAL(18,2) NOT NULL CONSTRAINT DF_PurchaseReceipts_TotalAmount DEFAULT (0),
        Note             NVARCHAR(1000) NULL,
        CONSTRAINT PK_PurchaseReceipts PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_PurchaseReceipts_Suppliers_SupplierId
            FOREIGN KEY (SupplierId) REFERENCES dbo.Suppliers(Id)
            ON DELETE NO ACTION,
        CONSTRAINT FK_PurchaseReceipts_AspNetUsers_CreatedByUserId
            FOREIGN KEY (CreatedByUserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_PurchaseReceipts_Status CHECK ([Status] IN (N'Draft', N'Completed', N'Cancelled')),
        CONSTRAINT CK_PurchaseReceipts_Subtotal CHECK (Subtotal >= 0),
        CONSTRAINT CK_PurchaseReceipts_TotalAmount CHECK (TotalAmount >= 0)
    );
END
GO

IF OBJECT_ID(N'dbo.PurchaseReceiptItems', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PurchaseReceiptItems
    (
        Id                 INT IDENTITY(1,1) NOT NULL,
        PurchaseReceiptId  INT NOT NULL,
        ProductId          INT NOT NULL,
        Quantity           INT NOT NULL,
        ImportPrice        DECIMAL(18,2) NOT NULL,
        LineTotal          DECIMAL(18,2) NOT NULL,
        CONSTRAINT PK_PurchaseReceiptItems PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_PurchaseReceiptItems_PurchaseReceipts_PurchaseReceiptId
            FOREIGN KEY (PurchaseReceiptId) REFERENCES dbo.PurchaseReceipts(Id)
            ON DELETE CASCADE,
        CONSTRAINT FK_PurchaseReceiptItems_Products_ProductId
            FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id)
            ON DELETE NO ACTION,
        CONSTRAINT CK_PurchaseReceiptItems_Quantity CHECK (Quantity > 0),
        CONSTRAINT CK_PurchaseReceiptItems_ImportPrice CHECK (ImportPrice >= 0),
        CONSTRAINT CK_PurchaseReceiptItems_LineTotal CHECK (LineTotal >= 0 AND LineTotal = (ImportPrice * Quantity))
    );
END
GO

IF OBJECT_ID(N'dbo.StockTransactions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.StockTransactions
    (
        Id                 INT IDENTITY(1,1) NOT NULL,
        ProductId          INT NOT NULL,
        PerformedByUserId  NVARCHAR(450) NULL,
        TransactionType    NVARCHAR(20) NOT NULL,
        Quantity           INT NOT NULL,
        ReferenceType      NVARCHAR(50) NULL,
        ReferenceId        INT NULL,
        BeforeQuantity     INT NULL,
        AfterQuantity      INT NULL,
        Note               NVARCHAR(500) NULL,
        CreatedAt          DATETIME2(7) NOT NULL CONSTRAINT DF_StockTransactions_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_StockTransactions PRIMARY KEY CLUSTERED (Id),
        CONSTRAINT FK_StockTransactions_Products_ProductId
            FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id)
            ON DELETE NO ACTION,
        CONSTRAINT FK_StockTransactions_AspNetUsers_PerformedByUserId
            FOREIGN KEY (PerformedByUserId) REFERENCES dbo.AspNetUsers(Id)
            ON DELETE SET NULL,
        CONSTRAINT CK_StockTransactions_TransactionType CHECK (TransactionType IN (N'IMPORT', N'EXPORT', N'ADJUST')),
        CONSTRAINT CK_StockTransactions_Quantity CHECK (Quantity > 0),
        CONSTRAINT CK_StockTransactions_BeforeQuantity CHECK (BeforeQuantity IS NULL OR BeforeQuantity >= 0),
        CONSTRAINT CK_StockTransactions_AfterQuantity CHECK (AfterQuantity IS NULL OR AfterQuantity >= 0)
    );
END
GO

/* =========================================================
   8) Chi muc - unique index
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'RoleNameIndex' AND object_id = OBJECT_ID(N'dbo.AspNetRoles'))
    CREATE UNIQUE NONCLUSTERED INDEX RoleNameIndex
        ON dbo.AspNetRoles(NormalizedName)
        WHERE NormalizedName IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AspNetRoleClaims_RoleId' AND object_id = OBJECT_ID(N'dbo.AspNetRoleClaims'))
    CREATE NONCLUSTERED INDEX IX_AspNetRoleClaims_RoleId ON dbo.AspNetRoleClaims(RoleId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UserNameIndex' AND object_id = OBJECT_ID(N'dbo.AspNetUsers'))
    CREATE UNIQUE NONCLUSTERED INDEX UserNameIndex
        ON dbo.AspNetUsers(NormalizedUserName)
        WHERE NormalizedUserName IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'EmailIndex' AND object_id = OBJECT_ID(N'dbo.AspNetUsers'))
    CREATE UNIQUE NONCLUSTERED INDEX EmailIndex
        ON dbo.AspNetUsers(NormalizedEmail)
        WHERE NormalizedEmail IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AspNetUserClaims_UserId' AND object_id = OBJECT_ID(N'dbo.AspNetUserClaims'))
    CREATE NONCLUSTERED INDEX IX_AspNetUserClaims_UserId ON dbo.AspNetUserClaims(UserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AspNetUserLogins_UserId' AND object_id = OBJECT_ID(N'dbo.AspNetUserLogins'))
    CREATE NONCLUSTERED INDEX IX_AspNetUserLogins_UserId ON dbo.AspNetUserLogins(UserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_AspNetUserRoles_RoleId' AND object_id = OBJECT_ID(N'dbo.AspNetUserRoles'))
    CREATE NONCLUSTERED INDEX IX_AspNetUserRoles_RoleId ON dbo.AspNetUserRoles(RoleId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Categories_Slug' AND object_id = OBJECT_ID(N'dbo.Categories'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_Categories_Slug ON dbo.Categories(Slug);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Categories_ParentCategoryId' AND object_id = OBJECT_ID(N'dbo.Categories'))
    CREATE NONCLUSTERED INDEX IX_Categories_ParentCategoryId ON dbo.Categories(ParentCategoryId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Brands_Slug' AND object_id = OBJECT_ID(N'dbo.Brands'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_Brands_Slug ON dbo.Brands(Slug);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Brands_Name' AND object_id = OBJECT_ID(N'dbo.Brands'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_Brands_Name ON dbo.Brands([Name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SpecificationDefinitions_CategoryId_SpecName' AND object_id = OBJECT_ID(N'dbo.SpecificationDefinitions'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_SpecificationDefinitions_CategoryId_SpecName
        ON dbo.SpecificationDefinitions(CategoryId, SpecName);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SpecificationDefinitions_CategoryId_SortOrder' AND object_id = OBJECT_ID(N'dbo.SpecificationDefinitions'))
    CREATE NONCLUSTERED INDEX IX_SpecificationDefinitions_CategoryId_SortOrder
        ON dbo.SpecificationDefinitions(CategoryId, SortOrder);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Products_SKU' AND object_id = OBJECT_ID(N'dbo.Products'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_Products_SKU ON dbo.Products(SKU);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Products_Slug' AND object_id = OBJECT_ID(N'dbo.Products'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_Products_Slug ON dbo.Products(Slug);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Products_CategoryId' AND object_id = OBJECT_ID(N'dbo.Products'))
    CREATE NONCLUSTERED INDEX IX_Products_CategoryId ON dbo.Products(CategoryId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Products_BrandId' AND object_id = OBJECT_ID(N'dbo.Products'))
    CREATE NONCLUSTERED INDEX IX_Products_BrandId ON dbo.Products(BrandId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Products_IsActive_IsFeatured' AND object_id = OBJECT_ID(N'dbo.Products'))
    CREATE NONCLUSTERED INDEX IX_Products_IsActive_IsFeatured ON dbo.Products(IsActive, IsFeatured);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ProductImages_ProductId' AND object_id = OBJECT_ID(N'dbo.ProductImages'))
    CREATE NONCLUSTERED INDEX IX_ProductImages_ProductId ON dbo.ProductImages(ProductId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_ProductImages_ProductId_ImageUrl' AND object_id = OBJECT_ID(N'dbo.ProductImages'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_ProductImages_ProductId_ImageUrl ON dbo.ProductImages(ProductId, ImageUrl);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_ProductImages_OnePrimaryPerProduct' AND object_id = OBJECT_ID(N'dbo.ProductImages'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_ProductImages_OnePrimaryPerProduct
        ON dbo.ProductImages(ProductId)
        WHERE IsPrimary = 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_ProductSpecifications_ProductId_SpecDefinitionId' AND object_id = OBJECT_ID(N'dbo.ProductSpecifications'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_ProductSpecifications_ProductId_SpecDefinitionId
        ON dbo.ProductSpecifications(ProductId, SpecDefinitionId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ProductSpecifications_SpecDefinitionId' AND object_id = OBJECT_ID(N'dbo.ProductSpecifications'))
    CREATE NONCLUSTERED INDEX IX_ProductSpecifications_SpecDefinitionId
        ON dbo.ProductSpecifications(SpecDefinitionId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UserAddresses_UserId' AND object_id = OBJECT_ID(N'dbo.UserAddresses'))
    CREATE NONCLUSTERED INDEX IX_UserAddresses_UserId ON dbo.UserAddresses(UserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_UserAddresses_OneDefaultPerUser' AND object_id = OBJECT_ID(N'dbo.UserAddresses'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_UserAddresses_OneDefaultPerUser
        ON dbo.UserAddresses(UserId)
        WHERE IsDefault = 1;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Carts_UserId' AND object_id = OBJECT_ID(N'dbo.Carts'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_Carts_UserId ON dbo.Carts(UserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_CartItems_ProductId' AND object_id = OBJECT_ID(N'dbo.CartItems'))
    CREATE NONCLUSTERED INDEX IX_CartItems_ProductId ON dbo.CartItems(ProductId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_CartItems_CartId_ProductId' AND object_id = OBJECT_ID(N'dbo.CartItems'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_CartItems_CartId_ProductId ON dbo.CartItems(CartId, ProductId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Orders_OrderCode' AND object_id = OBJECT_ID(N'dbo.Orders'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_Orders_OrderCode ON dbo.Orders(OrderCode);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Orders_UserId' AND object_id = OBJECT_ID(N'dbo.Orders'))
    CREATE NONCLUSTERED INDEX IX_Orders_UserId ON dbo.Orders(UserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Orders_Status_CreatedAt' AND object_id = OBJECT_ID(N'dbo.Orders'))
    CREATE NONCLUSTERED INDEX IX_Orders_Status_CreatedAt ON dbo.Orders(OrderStatus, CreatedAt);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrderItems_OrderId' AND object_id = OBJECT_ID(N'dbo.OrderItems'))
    CREATE NONCLUSTERED INDEX IX_OrderItems_OrderId ON dbo.OrderItems(OrderId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OrderItems_ProductId' AND object_id = OBJECT_ID(N'dbo.OrderItems'))
    CREATE NONCLUSTERED INDEX IX_OrderItems_ProductId ON dbo.OrderItems(ProductId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Payments_OrderId' AND object_id = OBJECT_ID(N'dbo.Payments'))
    CREATE NONCLUSTERED INDEX IX_Payments_OrderId ON dbo.Payments(OrderId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Reviews_ProductId' AND object_id = OBJECT_ID(N'dbo.Reviews'))
    CREATE NONCLUSTERED INDEX IX_Reviews_ProductId ON dbo.Reviews(ProductId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Reviews_UserId' AND object_id = OBJECT_ID(N'dbo.Reviews'))
    CREATE NONCLUSTERED INDEX IX_Reviews_UserId ON dbo.Reviews(UserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Reviews_ProductId_UserId' AND object_id = OBJECT_ID(N'dbo.Reviews'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_Reviews_ProductId_UserId ON dbo.Reviews(ProductId, UserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Suppliers_Name' AND object_id = OBJECT_ID(N'dbo.Suppliers'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_Suppliers_Name ON dbo.Suppliers([Name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_PurchaseReceipts_ReceiptCode' AND object_id = OBJECT_ID(N'dbo.PurchaseReceipts'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_PurchaseReceipts_ReceiptCode ON dbo.PurchaseReceipts(ReceiptCode);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PurchaseReceipts_SupplierId' AND object_id = OBJECT_ID(N'dbo.PurchaseReceipts'))
    CREATE NONCLUSTERED INDEX IX_PurchaseReceipts_SupplierId ON dbo.PurchaseReceipts(SupplierId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PurchaseReceipts_CreatedByUserId' AND object_id = OBJECT_ID(N'dbo.PurchaseReceipts'))
    CREATE NONCLUSTERED INDEX IX_PurchaseReceipts_CreatedByUserId ON dbo.PurchaseReceipts(CreatedByUserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PurchaseReceiptItems_PurchaseReceiptId' AND object_id = OBJECT_ID(N'dbo.PurchaseReceiptItems'))
    CREATE NONCLUSTERED INDEX IX_PurchaseReceiptItems_PurchaseReceiptId ON dbo.PurchaseReceiptItems(PurchaseReceiptId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PurchaseReceiptItems_ProductId' AND object_id = OBJECT_ID(N'dbo.PurchaseReceiptItems'))
    CREATE NONCLUSTERED INDEX IX_PurchaseReceiptItems_ProductId ON dbo.PurchaseReceiptItems(ProductId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_StockTransactions_ProductId_CreatedAt' AND object_id = OBJECT_ID(N'dbo.StockTransactions'))
    CREATE NONCLUSTERED INDEX IX_StockTransactions_ProductId_CreatedAt ON dbo.StockTransactions(ProductId, CreatedAt DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_StockTransactions_PerformedByUserId' AND object_id = OBJECT_ID(N'dbo.StockTransactions'))
    CREATE NONCLUSTERED INDEX IX_StockTransactions_PerformedByUserId ON dbo.StockTransactions(PerformedByUserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SupportTickets_TicketCode' AND object_id = OBJECT_ID(N'dbo.SupportTickets'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_SupportTickets_TicketCode ON dbo.SupportTickets(TicketCode);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SupportTickets_UserId' AND object_id = OBJECT_ID(N'dbo.SupportTickets'))
    CREATE NONCLUSTERED INDEX IX_SupportTickets_UserId ON dbo.SupportTickets(UserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SupportTickets_AssignedToUserId' AND object_id = OBJECT_ID(N'dbo.SupportTickets'))
    CREATE NONCLUSTERED INDEX IX_SupportTickets_AssignedToUserId ON dbo.SupportTickets(AssignedToUserId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_SupportTickets_OrderId' AND object_id = OBJECT_ID(N'dbo.SupportTickets'))
    CREATE NONCLUSTERED INDEX IX_SupportTickets_OrderId ON dbo.SupportTickets(OrderId);
GO

/* =========================================================
   9) Trigger nghiep vu
   ========================================================= */
IF OBJECT_ID(N'dbo.trg_ProductSpecifications_ValidateDataType', N'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_ProductSpecifications_ValidateDataType;
GO

CREATE TRIGGER dbo.trg_ProductSpecifications_ValidateDataType
ON dbo.ProductSpecifications
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.SpecificationDefinitions sd ON sd.Id = i.SpecDefinitionId
        WHERE
            (
                sd.DataType = N'text'
                AND (i.ValueText IS NULL OR i.ValueNumber IS NOT NULL OR i.ValueBoolean IS NOT NULL)
            )
            OR
            (
                sd.DataType = N'number'
                AND (i.ValueNumber IS NULL OR i.ValueText IS NOT NULL OR i.ValueBoolean IS NOT NULL)
            )
            OR
            (
                sd.DataType = N'boolean'
                AND (i.ValueBoolean IS NULL OR i.ValueText IS NOT NULL OR i.ValueNumber IS NOT NULL)
            )
    )
    BEGIN
        RAISERROR (N'ProductSpecifications khong dung kieu du lieu theo SpecificationDefinitions.DataType.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

IF OBJECT_ID(N'dbo.trg_StockTransactions_PreventNegativeAfterQty', N'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_StockTransactions_PreventNegativeAfterQty;
GO

CREATE TRIGGER dbo.trg_StockTransactions_PreventNegativeAfterQty
ON dbo.StockTransactions
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted
        WHERE AfterQuantity IS NOT NULL AND AfterQuantity < 0
    )
    BEGIN
        RAISERROR (N'AfterQuantity khong duoc am.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

/* =========================================================
   10) Seed role co ban (tuong thich workbook)
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.AspNetRoles WHERE NormalizedName = N'ADMIN')
BEGIN
    INSERT INTO dbo.AspNetRoles (Id, Name, NormalizedName, Description, IsActive)
    VALUES
        (N'11111111-1111-1111-1111-111111111111', N'Admin', N'ADMIN', N'Quan tri he thong', 1),
        (N'22222222-2222-2222-2222-222222222222', N'Customer', N'CUSTOMER', N'Khach hang', 1),
        (N'33333333-3333-3333-3333-333333333333', N'SalesStaff', N'SALESSTAFF', N'Nhan vien ban hang', 1),
        (N'44444444-4444-4444-4444-444444444444', N'WarehouseStaff', N'WAREHOUSESTAFF', N'Nhan vien kho', 1),
        (N'55555555-5555-5555-5555-555555555555', N'SupportStaff', N'SUPPORTSTAFF', N'Nhan vien ho tro', 1);
END
GO

/* =========================================================
   11) Ghi chu import workbook
   =========================================================
   Workbook PowerTech_ProductData_Full_With_Laptops_updated_loa_pcbo.xlsx
   co the import theo thu tu:
   1. AspNetRoles (tu sheet Roles, neu can)
   2. Categories
   3. Brands
   4. SpecificationDefinitions
   5. Products
   6. ProductSpecifications
   7. ProductImages
   8. AspNetUsers
   9. UserAddresses
   10. Orders
   11. OrderItems
   12. Reviews
   13. SupportTickets

   Luu y:
   - Workbook co mot so dong huong dan / vi du trong nhieu sheet -> can bo qua khi import.
   - Orders trong workbook dang luu CustomerEmail, can map sang AspNetUsers.Id.
   - ProductSpecifications trong workbook dang map theo ProductSKU + SpecName,
     can doi sang ProductId + SpecDefinitionId.
*/

PRINT N'TechZone full schema da duoc tao xong.';
GO


/* ============================================================================
   END FILE: TechZone_FullSchema.sql
   ============================================================================ */


/* ============================================================================
   BEGIN FILE: TechZone_SeedImport_FromExcel.sql
   ============================================================================ */

/*
    TechZone_SeedImport_FromExcel.sql

    Muc tieu:
    - Seed / import du lieu tu workbook PowerTech_ProductData_Full_With_Laptops_updated_loa_pcbo.xlsx
    - Chay SAU KHI da chay file schema: TechZone_FullSchema.sql
    - Script duoc viet theo huong idempotent o muc do thuc dung:
      + UPDATE neu ton tai
      + INSERT neu chua co
      + Rebuild lai ProductSpecifications, ProductImages, OrderItems, Payments cho cac ban ghi trong workbook

    Luu y:
    - Script nay tao password hash hop le cho ASP.NET Core Identity truoc khi xuat file SQL.
    - Co 01 SKU du lieu giao dich tham chieu den san pham chua ton tai trong sheet Products.
      Script se tao 1 san pham stub de bao toan khoa ngoai:
        CPU-INTEL-I5-14400F
*/

USE [TechZoneStoreDb];
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN;


IF OBJECT_ID('tempdb..#SeedRoles') IS NOT NULL DROP TABLE #SeedRoles;
CREATE TABLE #SeedRoles (
    RoleName NVARCHAR(256) NULL,
    Description NVARCHAR(500) NULL,
    IsActive BIT NULL
);

IF OBJECT_ID('tempdb..#SeedCategories') IS NOT NULL DROP TABLE #SeedCategories;
CREATE TABLE #SeedCategories (
    CategoryName NVARCHAR(150) NULL,
    Slug NVARCHAR(180) NULL,
    Description NVARCHAR(500) NULL,
    DisplayOrder INT NULL,
    IsActive BIT NULL
);

IF OBJECT_ID('tempdb..#SeedBrands') IS NOT NULL DROP TABLE #SeedBrands;
CREATE TABLE #SeedBrands (
    BrandName NVARCHAR(150) NULL,
    Slug NVARCHAR(180) NULL,
    Description NVARCHAR(500) NULL,
    Country NVARCHAR(100) NULL,
    IsActive BIT NULL
);

IF OBJECT_ID('tempdb..#SeedSpecificationDefinitions') IS NOT NULL DROP TABLE #SeedSpecificationDefinitions;
CREATE TABLE #SeedSpecificationDefinitions (
    CategoryName NVARCHAR(150) NULL,
    SpecName NVARCHAR(150) NULL,
    DisplayName NVARCHAR(150) NULL,
    DataType NVARCHAR(20) NULL,
    Unit NVARCHAR(50) NULL,
    GroupName NVARCHAR(100) NULL,
    SortOrder INT NULL,
    IsFilterable BIT NULL,
    IsRequired BIT NULL
);

IF OBJECT_ID('tempdb..#SeedProducts') IS NOT NULL DROP TABLE #SeedProducts;
CREATE TABLE #SeedProducts (
    SKU NVARCHAR(100) NULL,
    ProductName NVARCHAR(250) NULL,
    Slug NVARCHAR(250) NULL,
    CategoryName NVARCHAR(150) NULL,
    BrandName NVARCHAR(150) NULL,
    Price DECIMAL(18,2) NULL,
    DiscountPrice DECIMAL(18,2) NULL,
    QuantityInStock INT NULL,
    ShortDescription NVARCHAR(500) NULL,
    Description NVARCHAR(MAX) NULL,
    ThumbnailUrl NVARCHAR(1000) NULL,
    WarrantyMonths INT NULL,
    IsStub BIT NULL
);

IF OBJECT_ID('tempdb..#SeedProductSpecifications') IS NOT NULL DROP TABLE #SeedProductSpecifications;
CREATE TABLE #SeedProductSpecifications (
    ProductSKU NVARCHAR(100) NULL,
    CategoryName NVARCHAR(150) NULL,
    SpecName NVARCHAR(150) NULL,
    ValueText NVARCHAR(500) NULL,
    ValueNumber DECIMAL(18,4) NULL,
    ValueBoolean BIT NULL,
    DisplayValue NVARCHAR(500) NULL
);

IF OBJECT_ID('tempdb..#SeedUsers') IS NOT NULL DROP TABLE #SeedUsers;
CREATE TABLE #SeedUsers (
    Email NVARCHAR(256) NULL,
    PasswordHash NVARCHAR(MAX) NULL,
    FullName NVARCHAR(150) NULL,
    PhoneNumber NVARCHAR(20) NULL,
    IsActive BIT NULL,
    MustChangePassword BIT NULL
);

IF OBJECT_ID('tempdb..#SeedUserRoles') IS NOT NULL DROP TABLE #SeedUserRoles;
CREATE TABLE #SeedUserRoles (
    Email NVARCHAR(256) NULL,
    RoleName NVARCHAR(256) NULL
);

IF OBJECT_ID('tempdb..#SeedUserAddresses') IS NOT NULL DROP TABLE #SeedUserAddresses;
CREATE TABLE #SeedUserAddresses (
    UserEmail NVARCHAR(256) NULL,
    ReceiverName NVARCHAR(150) NULL,
    PhoneNumber NVARCHAR(20) NULL,
    Province NVARCHAR(100) NULL,
    District NVARCHAR(100) NULL,
    Ward NVARCHAR(100) NULL,
    StreetAddress NVARCHAR(255) NULL,
    IsDefault BIT NULL
);

IF OBJECT_ID('tempdb..#SeedOrders') IS NOT NULL DROP TABLE #SeedOrders;
CREATE TABLE #SeedOrders (
    OrderCode NVARCHAR(50) NULL,
    CustomerEmail NVARCHAR(256) NULL,
    ReceiverName NVARCHAR(150) NULL,
    PhoneNumber NVARCHAR(20) NULL,
    ShippingAddress NVARCHAR(500) NULL,
    OrderStatus NVARCHAR(30) NULL,
    PaymentStatus NVARCHAR(30) NULL,
    PaymentMethod NVARCHAR(30) NULL,
    Subtotal DECIMAL(18,2) NULL,
    ShippingFee DECIMAL(18,2) NULL,
    TotalAmount DECIMAL(18,2) NULL,
    CreatedAt DATETIME2(7) NULL
);

IF OBJECT_ID('tempdb..#SeedOrderItems') IS NOT NULL DROP TABLE #SeedOrderItems;
CREATE TABLE #SeedOrderItems (
    OrderCode NVARCHAR(50) NULL,
    ProductSKU NVARCHAR(100) NULL,
    ProductNameSnapshot NVARCHAR(250) NULL,
    UnitPrice DECIMAL(18,2) NULL,
    Quantity INT NULL,
    LineTotal DECIMAL(18,2) NULL
);

IF OBJECT_ID('tempdb..#SeedPayments') IS NOT NULL DROP TABLE #SeedPayments;
CREATE TABLE #SeedPayments (
    OrderCode NVARCHAR(50) NULL,
    PaymentMethod NVARCHAR(30) NULL,
    PaymentStatus NVARCHAR(30) NULL,
    Amount DECIMAL(18,2) NULL,
    TransactionCode NVARCHAR(100) NULL,
    PaidAt DATETIME2(7) NULL,
    Note NVARCHAR(500) NULL
);

IF OBJECT_ID('tempdb..#SeedReviews') IS NOT NULL DROP TABLE #SeedReviews;
CREATE TABLE #SeedReviews (
    ProductSKU NVARCHAR(100) NULL,
    UserEmail NVARCHAR(256) NULL,
    Rating TINYINT NULL,
    Comment NVARCHAR(1000) NULL,
    IsApproved BIT NULL,
    CreatedAt DATETIME2(7) NULL
);

IF OBJECT_ID('tempdb..#SeedSupportTickets') IS NOT NULL DROP TABLE #SeedSupportTickets;
CREATE TABLE #SeedSupportTickets (
    TicketCode NVARCHAR(50) NULL,
    UserEmail NVARCHAR(256) NULL,
    Title NVARCHAR(200) NULL,
    Content NVARCHAR(MAX) NULL,
    Status NVARCHAR(30) NULL,
    Priority NVARCHAR(20) NULL,
    AssignedToEmail NVARCHAR(256) NULL,
    CreatedAt DATETIME2(7) NULL
);

IF OBJECT_ID('tempdb..#SeedProductImages') IS NOT NULL DROP TABLE #SeedProductImages;
CREATE TABLE #SeedProductImages (
    ProductSKU NVARCHAR(100) NULL,
    ImageUrl NVARCHAR(1000) NULL,
    AltText NVARCHAR(250) NULL,
    IsPrimary BIT NULL,
    SortOrder INT NULL
);

INSERT INTO #SeedRoles (RoleName, Description, IsActive)
VALUES
(N'Admin', N'Quan tri he thong', 1),
(N'Customer', N'Khach hang', 1),
(N'SalesStaff', N'Nhan vien ban hang', 1),
(N'WarehouseStaff', N'Nhan vien kho', 1),
(N'SupportStaff', N'Nhan vien ho tro', 1);

INSERT INTO #SeedCategories (CategoryName, Slug, Description, DisplayOrder, IsActive)
VALUES
(N'CPU', N'cpu', N'Bo xu ly trung tam', 1, 1),
(N'RAM', N'ram', N'Bo nho tam', 2, 1),
(N'Card đồ họa', N'card-do-hoa', N'Card do hoa roi cho PC gaming va workstation', 3, 1),
(N'Mainboard', N'mainboard', N'Bo mach chu cho he thong may tinh', 4, 1),
(N'Ổ cứng', N'o-cung', N'SSD va HDD luu tru du lieu cho PC va workstation', 5, 1),
(N'Nguồn máy tính', N'nguon-may-tinh', N'Bo nguon PSU cho he thong may tinh', 6, 1),
(N'Case', N'case', N'Vo may tinh cho he thong PC gaming va workstation', 7, 1),
(N'Màn hình', N'man-hinh', N'Man hinh gaming, do hoa va van phong', 8, 1),
(N'Bàn phím', N'ban-phim', N'Ban phim co, gaming, wireless va van phong', 9, 1),
(N'Chuột', N'chuot', N'Chuot gaming, chuot wireless va chuot van phong cho PC va laptop', 10, 1),
(N'Tai nghe', N'tai-nghe', N'Tai nghe gaming, tai nghe khong day va tai nghe da nen tang', 11, 1),
(N'Thiết bị mạng', N'thiet-bi-mang', N'Router, mesh WiFi va thiet bi mang cho gia dinh, van phong va gaming', 12, 1),
(N'Phụ kiện', N'phu-kien', N'Sac, hub, adapter, ban phim cho tablet va cac phu kien ket noi', 13, 1),
(N'Phần mềm', N'phan-mem', N'Ban quyen Windows, Office va cac goi phan mem cho PC va laptop', 14, 1),
(N'Laptop', N'laptop', N'Laptop gaming, van phong, mong nhe va doanh nhan', 15, 1),
(N'Loa', N'loa', N'Loa vi tinh, loa soundbar va he thong am thanh cho gaming, giai tri va lam viec', 16, 1),
(N'PC bộ', N'pc-bo', N'PC lap san, PC gaming va workstation dong bo de su dung ngay', 17, 1);

INSERT INTO #SeedBrands (BrandName, Slug, Description, Country, IsActive)
VALUES
(N'Intel', N'intel', N'Thuong hieu CPU va linh kien PC', N'USA', 1),
(N'AMD', N'amd', N'Thuong hieu CPU/GPU', N'USA', 1),
(N'Corsair', N'corsair', N'Thuong hieu RAM va linh kien PC', N'USA', 1),
(N'Kingston', N'kingston', N'Thuong hieu RAM/SSD', N'USA', 1),
(N'TeamGroup', N'teamgroup', N'Thuong hieu bo nho va luu tru', N'Taiwan', 1),
(N'G.Skill', N'g-skill', N'Thuong hieu RAM hieu nang cao', N'Taiwan', 1),
(N'ASUS', N'asus', N'Thuong hieu linh kien PC', N'Taiwan', 1),
(N'GIGABYTE', N'gigabyte', N'Thuong hieu linh kien PC', N'Taiwan', 1),
(N'Samsung', N'samsung', N'Thuong hieu man hinh va thiet bi luu tru', N'South Korea', 1),
(N'MSI', N'msi', N'Thuong hieu gaming gear va man hinh', N'Taiwan', 1),
(N'HKC', N'hkc', N'Thuong hieu man hinh pho thong', N'China', 1),
(N'Acer', N'acer', N'Thuong hieu may tinh va man hinh', N'Taiwan', 1),
(N'AOC', N'aoc', N'Thuong hieu man hinh', N'Taiwan', 1),
(N'ViewSonic', N'viewsonic', N'Thuong hieu man hinh do hoa va van phong', N'USA', 1),
(N'LG', N'lg', N'Thuong hieu man hinh va thiet bi dien tu', N'South Korea', 1),
(N'Seagate', N'seagate', N'Thuong hieu o cung HDD va luu tru', N'USA', 1),
(N'Western Digital', N'western-digital', N'Thuong hieu HDD va SSD', N'USA', 1),
(N'NZXT', N'nzxt', N'Thuong hieu case va phu kien PC', N'USA', 1),
(N'Cooler Master', N'cooler-master', N'Thuong hieu case va tan nhiet', N'Taiwan', 1),
(N'Jonsbo', N'jonsbo', N'Thuong hieu case may tinh', N'China', 1),
(N'TRYX', N'tryx', N'Thuong hieu case may tinh cao cap', N'China', 1),
(N'Dell', N'dell', N'Thuong hieu may tinh va man hinh', N'USA', 1),
(N'AKKO', N'akko', N'Thuong hieu ban phim co va phu kien keycap', N'China', 1),
(N'AULA', N'aula', N'Thuong hieu ban phim co gaming gia tot', N'China', 1),
(N'DareU', N'dareu', N'Thuong hieu gaming gear va ban phim co', N'China', 1),
(N'Durgod', N'durgod', N'Thuong hieu ban phim co va custom keyboard', N'China', 1),
(N'E-Dra', N'e-dra', N'Thuong hieu gaming gear pho thong', N'Vietnam', 1),
(N'Logitech', N'logitech', N'Thuong hieu gaming gear va thiet bi ngoai vi', N'Switzerland', 1),
(N'Razer', N'razer', N'Thuong hieu gaming gear cao cap', N'Singapore', 1),
(N'Rapoo', N'rapoo', N'Thuong hieu thiet bi ngoai vi va gaming gear', N'China', 1),
(N'ATK', N'atk', N'Thuong hieu gaming gear voi chuot sieu nhe hieu nang cao', N'China', 1),
(N'HyperX', N'hyperx', N'Thuong hieu gaming gear voi tai nghe va chuot gaming', N'USA', 1),
(N'Edifier', N'edifier', N'Thuong hieu am thanh va tai nghe khong day', N'China', 1),
(N'Onikuma', N'onikuma', N'Thuong hieu tai nghe gaming phong cach tre trung', N'China', 1),
(N'Glorious', N'glorious', N'Thuong hieu gaming gear va chuot hieu nang cao', N'USA', 1),
(N'Microsoft', N'microsoft', N'Phan mem he dieu hanh, bo ung dung van phong va dich vu dam may', N'USA', 1),
(N'Apple', N'apple', N'Thiet bi va phu kien thuoc he sinh thai Apple', N'USA', 1),
(N'Ugreen', N'ugreen', N'Phu kien sac, hub va cap ket noi cho dien thoai, tablet va may tinh', N'China', 1),
(N'Mazer', N'mazer', N'Thuong hieu phu kien ket noi va adapter cho laptop, tablet va dien thoai', N'Unknown', 1),
(N'Lenovo', N'lenovo', N'Thuong hieu laptop ThinkPad, Legion va thiet bi van phong/gaming', N'China', 1),
(N'HP', N'hp', N'Thuong hieu laptop va may tinh van phong', N'USA', 1),
(N'Thonet & Vander', N'thonet-vander', N'Thuong hieu loa va thiet bi am thanh huong den giai tri tai gia', N'Germany', 1),
(N'GVN', N'gvn', N'Thuong hieu PC lap san va he thong ban le cong nghe cua GVN', N'Vietnam', 1);

INSERT INTO #SeedSpecificationDefinitions (CategoryName, SpecName, DisplayName, DataType, Unit, GroupName, SortOrder, IsFilterable, IsRequired)
VALUES
(N'CPU', N'Socket', N'Socket', N'text', NULL, N'Thông số', 1, 1, 0),
(N'CPU', N'Số nhân', N'Số nhân', N'number', NULL, N'Thông số', 2, 1, 1),
(N'CPU', N'Số luồng', N'Số luồng', N'number', NULL, N'Thông số', 3, 1, 1),
(N'CPU', N'Bộ nhớ đệm', N'Bộ nhớ đệm', N'number', NULL, N'Thông số', 4, 1, 1),
(N'CPU', N'Xung nhịp tối đa', N'Xung nhịp tối đa', N'number', NULL, N'Thông số', 5, 1, 1),
(N'CPU', N'TDP Max', N'TDP Max', N'number', NULL, N'Thông số', 6, 1, 0),
(N'CPU', N'Số nhân P-core', N'Số nhân P-core', N'number', NULL, N'Thông số', 7, 1, 0),
(N'CPU', N'Số nhân E-core', N'Số nhân E-core', N'number', NULL, N'Thông số', 8, 1, 0),
(N'CPU', N'Tốc độ RAM tối đa', N'Tốc độ RAM tối đa', N'number', NULL, N'Thông số', 9, 1, 0),
(N'CPU', N'Có iGPU', N'Có iGPU', N'boolean', NULL, N'Thông số', 10, 1, 0),
(N'CPU', N'Dòng CPU', N'Dòng CPU', N'text', NULL, N'Thông số', 11, 1, 0),
(N'CPU', N'Thế hệ', N'Thế hệ', N'text', NULL, N'Thông số', 12, 1, 0),
(N'CPU', N'Xung nhịp cơ bản', N'Xung nhịp cơ bản', N'number', NULL, N'Thông số', 13, 1, 0),
(N'CPU', N'Loại đóng gói', N'Loại đóng gói', N'text', NULL, N'Thông số', 14, 1, 0),
(N'RAM', N'Mã sản phẩm', N'Mã sản phẩm', N'text', NULL, N'Thông số', 1, 1, 0),
(N'RAM', N'Chuẩn RAM', N'Chuẩn RAM', N'text', NULL, N'Thông số', 2, 1, 0),
(N'RAM', N'Dung lượng', N'Dung lượng', N'number', NULL, N'Thông số', 3, 1, 0),
(N'RAM', N'Số lượng thanh', N'Số lượng thanh', N'number', NULL, N'Thông số', 4, 1, 0),
(N'RAM', N'Dung lượng mỗi thanh', N'Dung lượng mỗi thanh', N'number', NULL, N'Thông số', 5, 1, 0),
(N'RAM', N'Bus', N'Bus', N'number', NULL, N'Thông số', 6, 1, 0),
(N'RAM', N'Màu sắc', N'Màu sắc', N'text', NULL, N'Thông số', 7, 1, 0),
(N'RAM', N'Độ trễ CL', N'Độ trễ CL', N'number', NULL, N'Thông số', 8, 1, 0),
(N'RAM', N'Intel XMP', N'Intel XMP', N'boolean', NULL, N'Thông số', 9, 1, 0),
(N'RAM', N'AMD EXPO', N'AMD EXPO', N'boolean', NULL, N'Thông số', 10, 1, 0),
(N'RAM', N'RGB/LED', N'RGB/LED', N'boolean', NULL, N'Thông số', 11, 1, 0),
(N'RAM', N'Băng thông', N'Băng thông', N'number', NULL, N'Thông số', 12, 1, 0),
(N'RAM', N'Form Factor', N'Form Factor', N'text', NULL, N'Thông số', 13, 1, 0),
(N'RAM', N'Tản nhiệt', N'Tản nhiệt', N'boolean', NULL, N'Thông số', 14, 1, 0),
(N'Card đồ họa', N'Nhân đồ họa', N'Nhân đồ họa', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Card đồ họa', N'Bus tiêu chuẩn', N'Bus tiêu chuẩn', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Card đồ họa', N'OpenGL', N'OpenGL', N'text', NULL, N'Thông số', 3, 1, 0),
(N'Card đồ họa', N'DirectX', N'DirectX', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Card đồ họa', N'Bộ nhớ Video', N'Bộ nhớ Video', N'text', NULL, N'Thông số', 5, 1, 0),
(N'Card đồ họa', N'Dung lượng VRAM', N'Dung lượng VRAM', N'number', NULL, N'Thông số', 6, 1, 0),
(N'Card đồ họa', N'Chuẩn bộ nhớ', N'Chuẩn bộ nhớ', N'text', NULL, N'Thông số', 7, 1, 0),
(N'Card đồ họa', N'Xung nhịp OC', N'Xung nhịp OC', N'number', NULL, N'Thông số', 8, 1, 0),
(N'Card đồ họa', N'Xung nhịp mặc định', N'Xung nhịp mặc định', N'number', NULL, N'Thông số', 9, 1, 0),
(N'Card đồ họa', N'Nhân CUDA', N'Nhân CUDA', N'number', NULL, N'Thông số', 10, 1, 0),
(N'Card đồ họa', N'Tốc độ bộ nhớ', N'Tốc độ bộ nhớ', N'number', NULL, N'Thông số', 11, 1, 0),
(N'Card đồ họa', N'Giao thức bộ nhớ', N'Giao thức bộ nhớ', N'text', NULL, N'Thông số', 12, 1, 0),
(N'Card đồ họa', N'Độ phân giải tối đa', N'Độ phân giải tối đa', N'text', NULL, N'Thông số', 13, 1, 0),
(N'Card đồ họa', N'HDMI', N'HDMI', N'text', NULL, N'Thông số', 14, 1, 0),
(N'Card đồ họa', N'DisplayPort', N'DisplayPort', N'text', NULL, N'Thông số', 15, 1, 0),
(N'Card đồ họa', N'HDCP', N'HDCP', N'text', NULL, N'Thông số', 16, 1, 0),
(N'Card đồ họa', N'Số lượng màn hình tối đa hỗ trợ', N'Số lượng màn hình tối đa hỗ trợ', N'number', NULL, N'Thông số', 17, 1, 0),
(N'Card đồ họa', N'Hỗ trợ NVLink/Crossfire', N'Hỗ trợ NVLink/Crossfire', N'boolean', NULL, N'Thông số', 18, 1, 0),
(N'Card đồ họa', N'Kích thước card', N'Kích thước card', N'text', NULL, N'Thông số', 19, 1, 0),
(N'Card đồ họa', N'Kích thước radiator', N'Kích thước radiator', N'text', NULL, N'Thông số', 20, 1, 0),
(N'Card đồ họa', N'PSU kiến nghị', N'PSU kiến nghị', N'number', NULL, N'Thông số', 21, 1, 0),
(N'Card đồ họa', N'Kết nối nguồn', N'Kết nối nguồn', N'text', NULL, N'Thông số', 22, 1, 0),
(N'Card đồ họa', N'Khe cắm', N'Khe cắm', N'number', NULL, N'Thông số', 23, 1, 0),
(N'Card đồ họa', N'AURA SYNC', N'AURA SYNC', N'text', NULL, N'Thông số', 24, 1, 0),
(N'Card đồ họa', N'Loại tản nhiệt', N'Loại tản nhiệt', N'text', NULL, N'Thông số', 25, 1, 0),
(N'Card đồ họa', N'Xung nhịp', N'Xung nhịp', N'number', NULL, N'Thông số', 26, 1, 0),
(N'Card đồ họa', N'Xung nhịp reference', N'Xung nhịp reference', N'number', NULL, N'Thông số', 27, 1, 0),
(N'Card đồ họa', N'Kích thước', N'Kích thước', N'text', NULL, N'Thông số', 28, 1, 0),
(N'Mainboard', N'Chipset', N'Chipset', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Mainboard', N'Chuẩn RAM', N'Chuẩn RAM', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Mainboard', N'VRM pha', N'VRM pha', N'text', NULL, N'Thông số', 3, 1, 0),
(N'Mainboard', N'Kết nối mạng LAN', N'Kết nối mạng LAN', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Mainboard', N'Wi-Fi', N'Wi-Fi', N'text', NULL, N'Thông số', 5, 1, 0),
(N'Mainboard', N'Cổng USB', N'Cổng USB', N'number', NULL, N'Thông số', 6, 1, 0),
(N'Mainboard', N'Cổng xuất hình', N'Cổng xuất hình', N'text', NULL, N'Thông số', 7, 1, 0),
(N'Mainboard', N'RGB LED', N'RGB LED', N'boolean', NULL, N'Thông số', 8, 1, 0),
(N'Ổ cứng', N'Loại ổ cứng', N'Loại ổ cứng', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Ổ cứng', N'Chuẩn kết nối', N'Chuẩn kết nối', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Ổ cứng', N'Dung lượng', N'Dung lượng', N'number', N'GB', N'Thông số', 3, 1, 0),
(N'Ổ cứng', N'Form Factor', N'Form Factor', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Ổ cứng', N'Loại chip nhớ', N'Loại chip nhớ', N'text', NULL, N'Thông số', 5, 1, 0),
(N'Ổ cứng', N'Tốc độ đọc', N'Tốc độ đọc', N'number', N'MB/s', N'Thông số', 6, 1, 0),
(N'Ổ cứng', N'Tốc độ ghi', N'Tốc độ ghi', N'number', N'MB/s', N'Thông số', 7, 1, 0),
(N'Ổ cứng', N'TBW', N'TBW', N'number', N'TB', N'Thông số', 8, 1, 0),
(N'Ổ cứng', N'Tốc độ vòng quay', N'Tốc độ vòng quay', N'number', N'RPM', N'Thông số', 9, 1, 0),
(N'Ổ cứng', N'MTBF', N'MTBF', N'number', N'giờ', N'Thông số', 10, 1, 0),
(N'Ổ cứng', N'Nhiệt độ hoạt động', N'Nhiệt độ hoạt động', N'text', NULL, N'Thông số', 11, 1, 0),
(N'Ổ cứng', N'Tốc độ truyền dữ liệu', N'Tốc độ truyền dữ liệu', N'number', N'Gb/s', N'Thông số', 12, 1, 0),
(N'Ổ cứng', N'Trọng lượng', N'Trọng lượng', N'number', N'g', N'Thông số', 13, 1, 0),
(N'Ổ cứng', N'Có tản nhiệt', N'Có tản nhiệt', N'boolean', NULL, N'Thông số', 14, 1, 0),
(N'Ổ cứng', N'Công nghệ quản lý nhiệt', N'Công nghệ quản lý nhiệt', N'text', NULL, N'Thông số', 15, 1, 0),
(N'Nguồn máy tính', N'Chuẩn nguồn', N'Chuẩn nguồn', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Nguồn máy tính', N'Công suất tối đa', N'Công suất tối đa', N'number', N'W', N'Thông số', 2, 1, 0),
(N'Nguồn máy tính', N'Chứng nhận 80 Plus', N'Chứng nhận 80 Plus', N'text', NULL, N'Thông số', 3, 1, 0),
(N'Nguồn máy tính', N'Hiệu suất', N'Hiệu suất', N'number', N'%', N'Thông số', 4, 1, 0),
(N'Nguồn máy tính', N'Full Modular', N'Full Modular', N'boolean', NULL, N'Thông số', 5, 1, 0),
(N'Nguồn máy tính', N'Kích thước quạt', N'Kích thước quạt', N'number', N'mm', N'Thông số', 6, 1, 0),
(N'Nguồn máy tính', N'Kiểu Rail', N'Kiểu Rail', N'text', NULL, N'Thông số', 7, 1, 0),
(N'Nguồn máy tính', N'Tính năng bảo vệ', N'Tính năng bảo vệ', N'text', NULL, N'Thông số', 8, 1, 0),
(N'Nguồn máy tính', N'Chuẩn PCIe', N'Chuẩn PCIe', N'text', NULL, N'Thông số', 9, 1, 0),
(N'Nguồn máy tính', N'Aura Sync / RGB', N'Aura Sync / RGB', N'boolean', NULL, N'Thông số', 10, 1, 0),
(N'Nguồn máy tính', N'Tính năng đặc biệt', N'Tính năng đặc biệt', N'text', NULL, N'Thông số', 11, 1, 0),
(N'Case', N'Chuẩn case', N'Chuẩn case', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Case', N'Hỗ trợ mainboard', N'Hỗ trợ mainboard', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Case', N'Số lượng quạt đi kèm', N'Số lượng quạt đi kèm', N'number', N'cái', N'Thông số', 3, 1, 0),
(N'Case', N'Hỗ trợ radiator tối đa', N'Hỗ trợ radiator tối đa', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Case', N'Cổng USB Type-C', N'Cổng USB Type-C', N'number', N'cổng', N'Thông số', 5, 1, 0),
(N'Case', N'Cổng USB 3.0', N'Cổng USB 3.0', N'number', N'cổng', N'Thông số', 6, 1, 0),
(N'Case', N'Khe cắm mở rộng PCI', N'Khe cắm mở rộng PCI', N'number', N'khe', N'Thông số', 7, 1, 0),
(N'Case', N'LED RGB', N'LED RGB', N'boolean', NULL, N'Thông số', 8, 1, 0),
(N'Case', N'Mặt kính cường lực', N'Mặt kính cường lực', N'boolean', NULL, N'Thông số', 9, 1, 0),
(N'Case', N'Màu sắc', N'Màu sắc', N'text', NULL, N'Thông số', 10, 1, 0),
(N'Case', N'Hỗ trợ GPU tối đa', N'Hỗ trợ GPU tối đa', N'text', NULL, N'Thông số', 11, 1, 0),
(N'Case', N'Hỗ trợ tản nhiệt CPU', N'Hỗ trợ tản nhiệt CPU', N'text', NULL, N'Thông số', 12, 1, 0),
(N'Case', N'Hỗ trợ PSU', N'Hỗ trợ PSU', N'text', NULL, N'Thông số', 13, 1, 0),
(N'Màn hình', N'Model', N'Model', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Màn hình', N'Kiểu màn hình', N'Kiểu màn hình', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Màn hình', N'Kích thước màn hình', N'Kích thước màn hình', N'number', N'inch', N'Thông số', 3, 1, 0),
(N'Màn hình', N'Tỉ lệ màn hình', N'Tỉ lệ màn hình', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Màn hình', N'Tấm nền', N'Tấm nền', N'text', NULL, N'Thông số', 5, 1, 0),
(N'Màn hình', N'Độ phân giải', N'Độ phân giải', N'text', NULL, N'Thông số', 6, 1, 0),
(N'Màn hình', N'Tần số quét', N'Tần số quét', N'number', N'Hz', N'Thông số', 7, 1, 0),
(N'Màn hình', N'Dual mode', N'Dual mode', N'text', NULL, N'Thông số', 8, 1, 0),
(N'Màn hình', N'Thời gian phản hồi', N'Thời gian phản hồi', N'text', NULL, N'Thông số', 9, 1, 0),
(N'Màn hình', N'Độ tương phản', N'Độ tương phản', N'text', NULL, N'Thông số', 10, 1, 0),
(N'Màn hình', N'Không gian màu', N'Không gian màu', N'text', NULL, N'Thông số', 11, 1, 0),
(N'Màn hình', N'Độ sáng', N'Độ sáng', N'text', NULL, N'Thông số', 12, 1, 0),
(N'Màn hình', N'Góc nhìn', N'Góc nhìn', N'text', NULL, N'Thông số', 13, 1, 0),
(N'Màn hình', N'Khử nhấp nháy', N'Khử nhấp nháy', N'boolean', NULL, N'Thông số', 14, 1, 0),
(N'Màn hình', N'Cổng kết nối', N'Cổng kết nối', N'text', NULL, N'Thông số', 15, 1, 0),
(N'Màn hình', N'Tương thích VESA', N'Tương thích VESA', N'text', NULL, N'Thông số', 16, 1, 0),
(N'Màn hình', N'Kích thước tổng thể', N'Kích thước tổng thể', N'text', NULL, N'Thông số', 17, 1, 0),
(N'Màn hình', N'Trọng lượng', N'Trọng lượng', N'text', NULL, N'Thông số', 18, 1, 0),
(N'Màn hình', N'Phụ kiện trong hộp', N'Phụ kiện trong hộp', N'text', NULL, N'Thông số', 19, 1, 0),
(N'Màn hình', N'Nhu cầu sử dụng', N'Nhu cầu sử dụng', N'text', NULL, N'Thông số', 20, 1, 0),
(N'Bàn phím', N'Model', N'Model', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Bàn phím', N'Phương thức kết nối', N'Phương thức kết nối', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Bàn phím', N'Kích thước/Layout', N'Kích thước/Layout', N'text', NULL, N'Thông số', 3, 1, 0),
(N'Bàn phím', N'Switch', N'Switch', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Bàn phím', N'Chất liệu Keycap', N'Chất liệu Keycap', N'text', NULL, N'Thông số', 5, 1, 0),
(N'Bàn phím', N'LED/RGB', N'LED/RGB', N'text', NULL, N'Thông số', 6, 1, 0),
(N'Bàn phím', N'Màu sắc', N'Màu sắc', N'text', NULL, N'Thông số', 7, 1, 0),
(N'Chuột', N'Màu sắc', N'Màu sắc', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Chuột', N'Kiểu dáng (Form)', N'Kiểu dáng (Form)', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Chuột', N'Kết nối', N'Kết nối', N'text', NULL, N'Thông số', 3, 1, 0),
(N'Chuột', N'Cảm biến (Sensor)', N'Cảm biến (Sensor)', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Chuột', N'Độ phân giải (DPI)', N'Độ phân giải (DPI)', N'text', NULL, N'Thông số', 5, 1, 0),
(N'Chuột', N'Gia tốc tối đa (Max Acceleration)', N'Gia tốc tối đa (Max Acceleration)', N'text', NULL, N'Thông số', 6, 1, 0),
(N'Chuột', N'Polling Rate', N'Polling Rate', N'text', NULL, N'Thông số', 7, 1, 0),
(N'Chuột', N'Loại switch', N'Loại switch', N'text', NULL, N'Thông số', 8, 1, 0),
(N'Chuột', N'Độ bền switch', N'Độ bền switch', N'text', NULL, N'Thông số', 9, 1, 0),
(N'Chuột', N'Số nút bấm', N'Số nút bấm', N'number', NULL, N'Thông số', 10, 1, 0),
(N'Chuột', N'Trọng lượng', N'Trọng lượng', N'text', NULL, N'Thông số', 11, 1, 0),
(N'Chuột', N'Kích thước', N'Kích thước', N'text', NULL, N'Thông số', 12, 1, 0),
(N'Chuột', N'Thời lượng pin', N'Thời lượng pin', N'text', NULL, N'Thông số', 13, 1, 0),
(N'Chuột', N'Loại pin', N'Loại pin', N'text', NULL, N'Thông số', 14, 1, 0),
(N'Chuột', N'Cổng sạc', N'Cổng sạc', N'text', NULL, N'Thông số', 15, 1, 0),
(N'Chuột', N'Đèn LED', N'Đèn LED', N'text', NULL, N'Thông số', 16, 1, 0),
(N'Chuột', N'Phần mềm hỗ trợ', N'Phần mềm hỗ trợ', N'text', NULL, N'Thông số', 17, 1, 0),
(N'Chuột', N'Phụ kiện đi kèm', N'Phụ kiện đi kèm', N'text', NULL, N'Thông số', 18, 1, 0),
(N'Tai nghe', N'Màu sắc', N'Màu sắc', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Tai nghe', N'Phương thức kết nối', N'Phương thức kết nối', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Tai nghe', N'Cổng kết nối', N'Cổng kết nối', N'text', NULL, N'Thông số', 3, 1, 0),
(N'Tai nghe', N'Kiểu tai nghe', N'Kiểu tai nghe', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Tai nghe', N'Driver', N'Driver', N'text', NULL, N'Thông số', 5, 1, 0),
(N'Tai nghe', N'Trọng lượng', N'Trọng lượng', N'text', NULL, N'Thông số', 6, 1, 0),
(N'Tai nghe', N'Thời lượng pin', N'Thời lượng pin', N'text', NULL, N'Thông số', 7, 1, 0),
(N'Tai nghe', N'RGB/LED', N'RGB/LED', N'text', NULL, N'Thông số', 8, 1, 0),
(N'Tai nghe', N'Tính năng nổi bật', N'Tính năng nổi bật', N'text', NULL, N'Thông số', 9, 1, 0),
(N'Thiết bị mạng', N'Model', N'Model', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Thiết bị mạng', N'Chuẩn WiFi', N'Chuẩn WiFi', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Thiết bị mạng', N'Tốc độ tối đa', N'Tốc độ tối đa', N'number', N'Mbps', N'Thông số', 3, 1, 0),
(N'Thiết bị mạng', N'Hỗ trợ tối đa', N'Hỗ trợ tối đa', N'number', N'thiết bị', N'Thông số', 4, 1, 0),
(N'Thiết bị mạng', N'Diện tích phủ sóng', N'Diện tích phủ sóng', N'number', N'm2', N'Thông số', 5, 1, 0),
(N'Thiết bị mạng', N'Băng tần', N'Băng tần', N'text', NULL, N'Thông số', 6, 1, 0),
(N'Thiết bị mạng', N'Màu sắc', N'Màu sắc', N'text', NULL, N'Thông số', 7, 1, 0),
(N'Thiết bị mạng', N'Tính năng nổi bật', N'Tính năng nổi bật', N'text', NULL, N'Thông số', 8, 1, 0),
(N'Phụ kiện', N'Loại phụ kiện', N'Loại phụ kiện', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Phụ kiện', N'Model/Mã sản phẩm', N'Model/Mã sản phẩm', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Phụ kiện', N'Kết nối', N'Kết nối', N'text', NULL, N'Thông số', 3, 1, 0),
(N'Phụ kiện', N'Cổng kết nối', N'Cổng kết nối', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Phụ kiện', N'Công suất', N'Công suất', N'text', NULL, N'Thông số', 5, 1, 0),
(N'Phụ kiện', N'Tương thích', N'Tương thích', N'text', NULL, N'Thông số', 6, 1, 0),
(N'Phụ kiện', N'Kích thước/Layout', N'Kích thước/Layout', N'text', NULL, N'Thông số', 7, 1, 0),
(N'Phụ kiện', N'Màu sắc', N'Màu sắc', N'text', NULL, N'Thông số', 8, 1, 0),
(N'Phụ kiện', N'Tính năng nổi bật', N'Tính năng nổi bật', N'text', NULL, N'Thông số', 9, 1, 0),
(N'Phần mềm', N'Mã sản phẩm', N'Mã sản phẩm', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Phần mềm', N'Phiên bản/Gói', N'Phiên bản/Gói', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Phần mềm', N'Loại bản quyền', N'Loại bản quyền', N'text', NULL, N'Thông số', 3, 1, 0),
(N'Phần mềm', N'Kiến trúc hỗ trợ', N'Kiến trúc hỗ trợ', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Phần mềm', N'Ngôn ngữ', N'Ngôn ngữ', N'text', NULL, N'Thông số', 5, 1, 0),
(N'Phần mềm', N'Thời hạn', N'Thời hạn', N'text', NULL, N'Thông số', 6, 1, 0),
(N'Phần mềm', N'Số người dùng', N'Số người dùng', N'number', N'người', N'Thông số', 7, 1, 0),
(N'Phần mềm', N'Số thiết bị', N'Số thiết bị', N'number', N'thiết bị', N'Thông số', 8, 1, 0),
(N'Phần mềm', N'AI/Copilot', N'AI/Copilot', N'text', NULL, N'Thông số', 9, 1, 0),
(N'Phần mềm', N'Ghi chú', N'Ghi chú', N'text', NULL, N'Thông số', 10, 1, 0),
(N'Laptop', N'Loại laptop', N'Loại laptop', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Laptop', N'CPU', N'CPU', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Laptop', N'Card đồ họa', N'Card đồ họa', N'text', NULL, N'Thông số', 3, 1, 0),
(N'Laptop', N'RAM', N'RAM', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Laptop', N'SSD', N'SSD', N'text', NULL, N'Thông số', 5, 1, 0),
(N'Laptop', N'Kích thước màn hình', N'Kích thước màn hình', N'text', NULL, N'Thông số', 6, 1, 0),
(N'Laptop', N'Độ phân giải', N'Độ phân giải', N'text', NULL, N'Thông số', 7, 1, 0),
(N'Laptop', N'Tần số quét', N'Tần số quét', N'text', NULL, N'Thông số', 8, 1, 0),
(N'Laptop', N'Tấm nền', N'Tấm nền', N'text', NULL, N'Thông số', 9, 1, 0),
(N'Laptop', N'Pin', N'Pin', N'text', NULL, N'Thông số', 10, 1, 0),
(N'Laptop', N'Trọng lượng', N'Trọng lượng', N'text', NULL, N'Thông số', 11, 1, 0),
(N'Laptop', N'Hệ điều hành', N'Hệ điều hành', N'text', NULL, N'Thông số', 12, 1, 0),
(N'Laptop', N'Màu sắc', N'Màu sắc', N'text', NULL, N'Thông số', 13, 1, 0),
(N'Laptop', N'Tính năng nổi bật', N'Tính năng nổi bật', N'text', NULL, N'Thông số', 14, 0, 0),
(N'Loa', N'Màu sắc', N'Màu sắc', N'text', NULL, N'Thông số', 1, 1, 0),
(N'Loa', N'Phiên bản Bluetooth', N'Phiên bản Bluetooth', N'text', NULL, N'Thông số', 2, 1, 0),
(N'Loa', N'Công nghệ âm thanh', N'Công nghệ âm thanh', N'text', NULL, N'Thông số', 3, 1, 0),
(N'Loa', N'LED RGB', N'LED RGB', N'text', NULL, N'Thông số', 4, 1, 0),
(N'Loa', N'Điều chỉnh Bass/Treble', N'Điều chỉnh Bass/Treble', N'text', NULL, N'Thông số', 5, 1, 0),
(N'Loa', N'Tỷ lệ SNR', N'Tỷ lệ SNR', N'text', NULL, N'Thông số', 6, 1, 0),
(N'Loa', N'Tình trạng', N'Tình trạng', N'text', NULL, N'Thông số', 7, 1, 0),
(N'PC bộ', N'CPU', N'CPU', N'text', NULL, N'Thông số', 1, 1, 0),
(N'PC bộ', N'Mainboard', N'Mainboard', N'text', NULL, N'Thông số', 2, 1, 0),
(N'PC bộ', N'RAM', N'RAM', N'text', NULL, N'Thông số', 3, 1, 0),
(N'PC bộ', N'SSD', N'SSD', N'text', NULL, N'Thông số', 4, 1, 0),
(N'PC bộ', N'VGA', N'VGA', N'text', NULL, N'Thông số', 5, 1, 0),
(N'PC bộ', N'Tính năng nổi bật', N'Tính năng nổi bật', N'text', NULL, N'Thông số', 6, 0, 0);

INSERT INTO #SeedProducts (SKU, ProductName, Slug, CategoryName, BrandName, Price, DiscountPrice, QuantityInStock, ShortDescription, Description, ThumbnailUrl, WarrantyMonths, IsStub)
VALUES
(N'CPU-INTEL-CU5-245K', N'Bộ vi xử lý Intel Core Ultra 5 245K', N'bo-vi-xu-ly-intel-core-ultra-5-245k', N'CPU', N'Intel', 8990000, 6690000, 18, N'CPU Intel Core Ultra 5 245K, 14 nhân 14 luồng, turbo up to 5.2GHz, socket LGA 1851.', N'Intel Core Ultra 5 245K là bộ vi xử lý thuộc dòng Intel Core Ultra thế hệ mới, hướng đến nhu cầu gaming, làm việc văn phòng nâng cao và sáng tạo nội dung ở mức bán chuyên. Sản phẩm sử dụng socket LGA 1851, có tổng cộng 14 nhân 14 luồng với cấu trúc gồm 6 P-core và 8 E-core, giúp cân bằng hiệu năng đơn nhân và đa nhiệm. CPU hỗ trợ RAM tốc độ cao lên đến 6400MHz, có đồ họa tích hợp, phù hợp cho người dùng muốn xây dựng cấu hình hiện đại, ổn định và có khả năng nâng cấp lâu dài.', N'/uploads/products/cpu/intel-core-ultra-5-245k/thumb.jpg', 36, 0),
(N'CPU-INTEL-CU7-265K', N'Bộ vi xử lý Intel Core Ultra 7 265K', N'bo-vi-xu-ly-intel-core-ultra-7-265k', N'CPU', N'Intel', 11790000, NULL, 12, N'CPU Intel Core Ultra 7 265K, 20 nhân 20 luồng, turbo up to 5.5GHz, socket LGA 1851.', N'Intel Core Ultra 7 265K là lựa chọn mạnh mẽ cho game thủ cao cấp, streamer và người dùng làm việc đa nhiệm nặng. CPU sở hữu 20 nhân 20 luồng, gồm 8 P-core và 12 E-core, cho khả năng xử lý nhanh trong cả tác vụ đơn nhân lẫn đa luồng. Bộ nhớ đệm 30MB, hỗ trợ RAM tối đa 6400MHz và tích hợp đồ họa onboard giúp hệ thống vận hành linh hoạt hơn trong nhiều tình huống sử dụng. Đây là mẫu CPU phù hợp cho các cấu hình hiệu năng cao dùng mainboard nền tảng mới.', N'/uploads/products/cpu/intel-core-ultra-7-265k/thumb.jpg', 36, 0),
(N'CPU-INTEL-CU9-285K', N'Bộ vi xử lý Intel Core Ultra 9 285K', N'bo-vi-xu-ly-intel-core-ultra-9-285k', N'CPU', N'Intel', 17490000, NULL, 8, N'CPU Intel Core Ultra 9 285K, 24 nhân 24 luồng, turbo up to 5.7GHz, socket LGA 1851.', N'Intel Core Ultra 9 285K là bộ xử lý cao cấp dành cho workstation, gaming flagship và các hệ thống yêu cầu hiệu năng cực cao. CPU có 24 nhân 24 luồng, trong đó gồm 8 P-core và 16 E-core, kết hợp bộ nhớ đệm 36MB và xung nhịp tối đa lên đến 5.7GHz. Sản phẩm hỗ trợ RAM tốc độ cao 6400MHz, có đồ họa tích hợp và mang lại hiệu quả mạnh mẽ trong render, xử lý video, lập trình nặng và các tác vụ sáng tạo chuyên sâu.', N'/uploads/products/cpu/intel-core-ultra-9-285k/thumb.jpg', 36, 0),
(N'CPU-INTEL-I3-14100', N'Bộ vi xử lý Intel Core i3 14100', N'bo-vi-xu-ly-intel-core-i3-14100', N'CPU', N'Intel', 4400000, 3890000, 25, N'CPU Intel Core i3 14100, 4 nhân 8 luồng, turbo up to 4.7GHz, socket LGA 1700.', N'Intel Core i3 14100 là lựa chọn phù hợp cho máy tính văn phòng, học tập, giải trí phổ thông và gaming eSports nhẹ. CPU có 4 nhân 8 luồng, xung tối đa 4.7GHz, bộ nhớ đệm 12MB và tích hợp đồ họa onboard giúp tiết kiệm chi phí khi chưa cần card đồ họa rời. Sản phẩm dùng socket LGA 1700, hỗ trợ RAM tối đa 4800MHz và thích hợp cho các cấu hình phổ thông có mức giá dễ tiếp cận.', N'/uploads/products/cpu/intel-core-i3-14100/thumb.jpg', 36, 0),
(N'CPU-AMD-R3-4300G', N'Bộ vi xử lý AMD Ryzen 3 4300G', N'bo-vi-xu-ly-amd-ryzen-3-4300g', N'CPU', N'AMD', 2790000, 2490000, 20, N'CPU AMD Ryzen 3 4300G, 4 nhân 8 luồng, boost up to 4.0GHz, socket AM4.', N'AMD Ryzen 3 4300G là bộ xử lý phổ thông tích hợp đồ họa, rất phù hợp cho nhu cầu học tập, làm việc văn phòng và giải trí cơ bản mà không cần card đồ họa rời. CPU có 4 nhân 8 luồng, xung boost 4.0GHz, bộ nhớ đệm 6MB và hỗ trợ RAM tối đa 3200MHz. Với socket AM4 phổ biến và mức giá dễ tiếp cận, đây là lựa chọn tốt để xây dựng cấu hình tiết kiệm nhưng vẫn đảm bảo hiệu năng ổn định.', N'/uploads/products/cpu/amd-ryzen-3-4300g/thumb.jpg', 36, 0),
(N'CPU-AMD-R5-7600', N'Bộ vi xử lý AMD Ryzen 5 7600', N'bo-vi-xu-ly-amd-ryzen-5-7600', N'CPU', N'AMD', 5990000, 5790000, 22, N'CPU AMD Ryzen 5 7600, 6 nhân 12 luồng, boost up to 5.1GHz, socket AM5.', N'AMD Ryzen 5 7600 là một trong những CPU tầm trung rất đáng chú ý cho gaming và làm việc hằng ngày. Sản phẩm có 6 nhân 12 luồng, xung boost tối đa 5.1GHz, bộ nhớ đệm 38MB và tích hợp đồ họa onboard, phù hợp cho cả người dùng mới build máy lẫn người cần hiệu năng ổn định lâu dài. CPU sử dụng socket AM5 và hỗ trợ RAM DDR5, mang lại khả năng nâng cấp tốt cho các cấu hình thế hệ mới.', N'/uploads/products/cpu/amd-ryzen-5-7600/thumb.jpg', 36, 0),
(N'CPU-AMD-R7-9700X', N'Bộ vi xử lý AMD Ryzen 7 9700X', N'bo-vi-xu-ly-amd-ryzen-7-9700x', N'CPU', N'AMD', 9990000, NULL, 14, N'CPU AMD Ryzen 7 9700X, 8 nhân 16 luồng, boost up to 5.5GHz, socket AM5.', N'AMD Ryzen 7 9700X hướng đến game thủ cao cấp và người dùng sáng tạo nội dung cần hiệu năng mạnh trong phân khúc cận cao cấp. CPU có 8 nhân 16 luồng, xung boost lên đến 5.5GHz, bộ nhớ đệm 40MB và hỗ trợ RAM tốc độ cao 5600MHz. Sản phẩm dùng socket AM5, phù hợp cho các bộ máy gaming mạnh, làm việc đa nhiệm nặng và xử lý tác vụ render ở mức cao.', N'/uploads/products/cpu/amd-ryzen-7-9700x/thumb.jpg', 36, 0),
(N'CPU-AMD-R9-9950X', N'Bộ vi xử lý AMD Ryzen 9 9950X', N'bo-vi-xu-ly-amd-ryzen-9-9950x', N'CPU', N'AMD', 17990000, NULL, 6, N'CPU AMD Ryzen 9 9950X, 16 nhân 32 luồng, boost up to 5.7GHz, socket AM5.', N'AMD Ryzen 9 9950X là bộ vi xử lý cao cấp dành cho workstation, render, dựng phim, lập trình nặng và hệ thống gaming flagship. CPU có 16 nhân 32 luồng, bộ nhớ đệm 80MB, xung boost tối đa 5.7GHz và hỗ trợ RAM tối đa 5200MHz. Đây là lựa chọn phù hợp cho người dùng cần sức mạnh xử lý đa luồng rất cao, hiệu suất ổn định và nền tảng AM5 mới để đầu tư lâu dài.', N'/uploads/products/cpu/amd-ryzen-9-9950x/thumb.jpg', 36, 0),
(N'CPU-AMD-ATHLON-3000G', N'Bộ vi xử lý AMD Athlon 3000G', N'bo-vi-xu-ly-amd-athlon-3000g', N'CPU', N'AMD', 1990000, 1290000, 16, N'CPU AMD Athlon 3000G, 2 nhân 4 luồng, 3.5GHz, socket AM4.', N'AMD Athlon 3000G là CPU giá rẻ dành cho máy tính văn phòng cơ bản, máy học tập hoặc cấu hình tối ưu chi phí. Sản phẩm có 2 nhân 4 luồng, xung nhịp 3.5GHz, bộ nhớ đệm 5MB và tích hợp đồ họa onboard, đủ dùng cho các tác vụ nhẹ như duyệt web, văn bản, học online và quản lý bán hàng. Với socket AM4 thông dụng, đây là lựa chọn hợp lý cho các hệ thống tiết kiệm.', N'/uploads/products/cpu/amd-athlon-3000g/thumb.jpg', 36, 0),
(N'CPU-AMD-R9-9950X-TRAY', N'Bộ vi xử lý AMD Ryzen 9 9950X TRAY', N'bo-vi-xu-ly-amd-ryzen-9-9950x-tray', N'CPU', N'AMD', 17490000, 16990000, 5, N'CPU AMD Ryzen 9 9950X TRAY, 16 nhân 32 luồng, boost up to 5.7GHz, socket AM5.', N'AMD Ryzen 9 9950X TRAY là phiên bản không hộp của dòng Ryzen 9 cao cấp, phù hợp cho người dùng chuyên nghiệp, cửa hàng build PC hoặc hệ thống workstation cần tối ưu chi phí đầu vào. CPU vẫn sở hữu 16 nhân 32 luồng, bộ nhớ đệm 80MB và xung boost tối đa 5.7GHz, đem lại hiệu năng rất mạnh trong các tác vụ nặng như render, biên dịch mã nguồn và xử lý video. Do là phiên bản TRAY, sản phẩm thường phù hợp với người dùng đã có sẵn giải pháp tản nhiệt và cần lưu ý thời hạn bảo hành ngắn hơn bản BOX.', N'/uploads/products/cpu/amd-ryzen-9-9950x-tray/thumb.jpg', 12, 0),
(N'CMK8GX4M1E3200C16', N'RAM Corsair Vengeance LPX 8GB (1x8GB) 3200 DDR4 Black (CMK8GX4M1E3200C16)', N'ram-corsair-vengeance-lpx-8gb-1x8gb-3200-ddr4-black-cmk8gx4m1e3200c16', N'RAM', N'Corsair', 1990000, 1690000, 24, N'RAM Corsair Vengeance LPX 8GB DDR4 bus 3200, thiết kế low-profile, phù hợp PC gaming và văn phòng.', N'Corsair Vengeance LPX 8GB DDR4 3200 là dòng RAM phổ thông chất lượng cao dành cho máy tính để bàn, phù hợp cho cấu hình học tập, văn phòng, gaming eSports và nâng cấp hệ thống giá tốt. Sản phẩm có dung lượng 8GB, bus 3200MHz, hỗ trợ Intel XMP, tản nhiệt nhôm và thiết kế low-profile dễ tương thích với nhiều bộ tản CPU.', N'/uploads/products/ram/corsair-vengeance-lpx-8gb-3200-cmk8gx4m1e3200c16/thumb.jpg', 36, 0),
(N'KF432C16BBA/8', N'RAM Kingston Fury Beast 8GB 3200 DDR4 RGB Black (KF432C16BBA/8)', N'ram-kingston-fury-beast-8gb-3200-ddr4-rgb-black-kf432c16bba-8', N'RAM', N'Kingston', 1290000, 850000, 0, N'RAM Kingston Fury Beast 8GB DDR4 RGB bus 3200, thiết kế gaming, có LED RGB.', N'Kingston Fury Beast 8GB DDR4 RGB 3200 là lựa chọn phù hợp cho người dùng muốn nâng cấp bộ nhớ với chi phí hợp lý nhưng vẫn có ngoại hình đẹp mắt cho hệ thống gaming. RAM sở hữu bus 3200MHz, LED RGB nổi bật, tản nhiệt tốt và tương thích với nhiều bo mạch chủ phổ biến.', N'/uploads/products/ram/kingston-fury-beast-8gb-3200-kf432c16bba-8/thumb.jpg', 36, 0),
(N'CMP32GX5M2B6000C30', N'RAM Corsair Dominator Titanium Black 32GB (2x16GB) RGB 6000 DDR5 (CMP32GX5M2B6000C30)', N'ram-corsair-dominator-titanium-black-32gb-2x16gb-rgb-6000-ddr5-cmp32gx5m2b6000c30', N'RAM', N'Corsair', 11990000, 10990000, 9, N'RAM Corsair Dominator Titanium 32GB DDR5 bus 6000, RGB cao cấp, tối ưu cho PC flagship.', N'Corsair Dominator Titanium Black 32GB DDR5 6000 là dòng RAM cao cấp hướng tới game thủ enthusiast, người làm đồ họa và hệ thống hiệu năng cao. Bộ kit 2x16GB mang lại khả năng đa nhiệm mạnh, hỗ trợ Intel XMP, RGB đẹp mắt, tản nhiệt hiệu quả và kiểu dáng premium cho dàn PC cao cấp.', N'/uploads/products/ram/corsair-dominator-titanium-black-32gb-6000-cmp32gx5m2b6000c30/thumb.jpg', 36, 0),
(N'CMH32GX5M2B5600C40W', N'RAM Corsair Vengeance RGB White 32GB (2x16GB) 5600 DDR5 (CMH32GX5M2B5600C40W)', N'ram-corsair-vengeance-rgb-white-32gb-2x16gb-5600-ddr5-cmh32gx5m2b5600c40w', N'RAM', N'Corsair', 5690000, NULL, 13, N'RAM Corsair Vengeance RGB White 32GB DDR5 bus 5600, màu trắng, phù hợp build PC tone sáng.', N'Corsair Vengeance RGB White 32GB DDR5 5600 là bộ nhớ dành cho các hệ thống desktop hiện đại cần dung lượng lớn, ngoại hình đẹp và hiệu năng ổn định. Sản phẩm gồm 2 thanh 16GB, hỗ trợ LED RGB, bus 5600MHz và tản nhiệt tốt, rất phù hợp với các bộ máy gaming hoặc workstation tone trắng.', N'/uploads/products/ram/corsair-vengeance-rgb-white-32gb-5600-cmh32gx5m2b5600c40w/thumb.jpg', 36, 0),
(N'CMP64GX5M2B6000C30W', N'RAM Corsair Dominator Titanium White 64GB (2x32GB) RGB 6000 DDR5 (CMP64GX5M2B6000C30W)', N'ram-corsair-dominator-titanium-white-64gb-2x32gb-rgb-6000-ddr5-cmp64gx5m2b6000c30w', N'RAM', N'Corsair', 31990000, 21490000, 4, N'RAM Corsair Dominator Titanium White 64GB DDR5 6000, RGB cao cấp, dung lượng lớn cho workstation.', N'Corsair Dominator Titanium White 64GB DDR5 6000 là bộ nhớ cao cấp dành cho hệ thống làm việc chuyên sâu, dựng phim, render, AI workstation và gaming flagship. Bộ kit 2x32GB mang lại dung lượng rất lớn, hỗ trợ Intel XMP, LED RGB đẹp mắt, tản nhiệt tốt và màu trắng cao cấp phù hợp với các bộ máy thẩm mỹ cao.', N'/uploads/products/ram/corsair-dominator-titanium-white-64gb-6000-cmp64gx5m2b6000c30w/thumb.jpg', 36, 0),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM TeamGroup T-Force Delta RGB Black 16GB (1x16GB) 3600 DDR4', N'ram-teamgroup-t-force-delta-rgb-black-16gb-1x16gb-3600-ddr4', N'RAM', N'TeamGroup', 3990000, 3490000, 17, N'RAM TeamGroup T-Force Delta RGB 16GB DDR4 bus 3600, LED RGB, phù hợp gaming.', N'TeamGroup T-Force Delta RGB Black 16GB DDR4 3600 là thanh RAM hiệu năng tốt trong phân khúc gaming tầm trung, thích hợp cho cấu hình chơi game, stream và làm việc đa nhiệm. Sản phẩm có bus 3600MHz, 1 thanh 16GB, hỗ trợ Intel XMP, LED RGB nổi bật và thiết kế tản nhiệt đậm chất gaming.', N'/uploads/products/ram/teamgroup-tforce-delta-black-16gb-3600/thumb.jpg', 60, 0),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM G.Skill Trident Z5 RGB 32GB (2x16GB) 5600 DDR5 Silver CL40 (F5-5600J4040C16GX2-TZ5RS)', N'ram-g-skill-trident-z5-rgb-32gb-2x16gb-5600-ddr5-silver-cl40-f5-5600j4040c16gx2-tz5rs', N'RAM', N'G.Skill', 10990000, 9990000, 10, N'RAM G.Skill Trident Z5 RGB 32GB DDR5 bus 5600, màu silver, thiết kế cao cấp.', N'G.Skill Trident Z5 RGB 32GB DDR5 5600 Silver CL40 là bộ nhớ cao cấp cho desktop hiện đại, phù hợp cho gaming, làm việc sáng tạo nội dung và các cấu hình yêu cầu tính thẩm mỹ cao. Bộ kit 2x16GB hỗ trợ Intel XMP, AMD EXPO, LED RGB và thiết kế tản nhiệt kim loại sang trọng.', N'/uploads/products/ram/gskill-trident-z5-rgb-32gb-5600-f5-5600j4040c16gx2-tz5rs/thumb.jpg', 36, 0),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM G.Skill Trident Z5 RGB 64GB (2x32GB) 6000 DDR5 Silver (F5-6000J3040G32GX2-TZ5RS)', N'ram-g-skill-trident-z5-rgb-64gb-2x32gb-6000-ddr5-silver-f5-6000j3040g32gx2-tz5rs', N'RAM', N'G.Skill', 10990000, 6990000, 0, N'RAM G.Skill Trident Z5 RGB 64GB DDR5 bus 6000, dung lượng lớn, phù hợp workstation.', N'G.Skill Trident Z5 RGB 64GB DDR5 6000 Silver là bộ RAM dung lượng lớn dành cho hệ thống workstation, content creation và PC cao cấp cần khả năng đa nhiệm mạnh. Bộ kit 2x32GB hỗ trợ Intel XMP, LED RGB, thiết kế đẹp mắt và bus 6000MHz giúp tối ưu hiệu năng cho nền tảng desktop mới.', N'/uploads/products/ram/gskill-trident-z5-rgb-64gb-6000-f5-6000j3040g32gx2-tz5rs/thumb.jpg', 36, 0),
(N'CMH96GX5M2B5600C40', N'RAM Corsair Vengeance RGB 96GB (2x48GB) 5600 DDR5 Black (CMH96GX5M2B5600C40)', N'ram-corsair-vengeance-rgb-96gb-2x48gb-5600-ddr5-black-cmh96gx5m2b5600c40', N'RAM', N'Corsair', 36990000, 33990000, 3, N'RAM Corsair Vengeance RGB 96GB DDR5 bus 5600, dung lượng cực lớn cho workstation và AI PC.', N'Corsair Vengeance RGB 96GB DDR5 5600 Black là giải pháp bộ nhớ dung lượng rất lớn dành cho các máy trạm cao cấp, hệ thống dựng phim, lập trình nặng, ảo hóa và AI workstation. Bộ kit 2x48GB cung cấp không gian RAM rộng rãi, LED RGB hiện đại, tản nhiệt tốt và hiệu năng ổn định trên nền tảng DDR5 mới.', N'/uploads/products/ram/corsair-vengeance-rgb-96gb-5600-cmh96gx5m2b5600c40/thumb.jpg', 36, 0),
(N'CMP96GX5M2B6600C32', N'RAM Corsair Dominator Titanium Black 96GB (2x48GB) RGB 6600 DDR5 (CMP96GX5M2B6600C32)', N'ram-corsair-dominator-titanium-black-96gb-2x48gb-rgb-6600-ddr5-cmp96gx5m2b6600c32', N'RAM', N'Corsair', 39990000, 38990000, 2, N'RAM Corsair Dominator Titanium Black 96GB DDR5 bus 6600, RGB cao cấp cho hệ thống flagship.', N'Corsair Dominator Titanium Black 96GB DDR5 6600 là bộ RAM cực cao cấp dành cho những cấu hình flagship cần dung lượng lớn và bus rất cao. Bộ kit 2x48GB thích hợp cho workstation, sáng tạo nội dung chuyên sâu và hệ thống gaming cao cấp, đồng thời mang lại ngoại hình sang trọng, LED RGB đẹp mắt và khả năng tản nhiệt hiệu quả.', N'/uploads/products/ram/corsair-dominator-titanium-black-96gb-6600-cmp96gx5m2b6600c32/thumb.jpg', 36, 0),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'ASUS ROG Matrix GeForce RTX 4090 24GB GDDR6X', N'asus-rog-matrix-geforce-rtx-4090-24gb-gddr6x', N'Card đồ họa', N'ASUS', 82990000, 79990000, 2, N'Card đồ họa cao cấp RTX 4090 24GB GDDR6X, tản nhiệt lai radiator, phù hợp PC flagship và workstation.', N'ASUS ROG Matrix GeForce RTX 4090 24GB GDDR6X là mẫu card đồ họa cực cao cấp dành cho hệ thống gaming flagship, AI PC và workstation hiệu năng lớn. Sản phẩm sử dụng GPU NVIDIA GeForce RTX 4090, 24GB GDDR6X, 16384 nhân CUDA và thiết kế tản nhiệt lai với radiator rời. Đây là lựa chọn dành cho người dùng cần hiệu năng đồ họa tối đa, làm việc dựng hình, render và chơi game 4K/8K ở thiết lập rất cao.', N'/uploads/products/gpu/asus-rog-matrix-rtx4090-24g/thumb.jpg', 36, 0),
(N'GPU-ASUS-RTX4070SUPER-12G', N'ASUS GeForce RTX 4070 SUPER 12GB GDDR6X', N'asus-geforce-rtx-4070-super-12gb-gddr6x', N'Card đồ họa', N'ASUS', 19990000, 18990000, 9, N'Card đồ họa RTX 4070 SUPER 12GB GDDR6X, phù hợp gaming 2K/4K và làm việc sáng tạo nội dung.', N'ASUS GeForce RTX 4070 SUPER 12GB GDDR6X là card đồ họa mạnh trong phân khúc cận cao cấp, phù hợp cho game thủ chơi 2K, 4K và người dùng làm việc với đồ họa, video hay livestream. Sản phẩm có 7168 nhân CUDA, bộ nhớ 12GB GDDR6X, bus 192-bit và hỗ trợ xuất hình đa màn hình với HDMI 2.1 và DisplayPort 1.4a.', N'/uploads/products/gpu/asus-rtx4070-super-12g/thumb.jpg', 36, 0),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'ASUS TUF Gaming GeForce RTX 5070 Ti 16GB GDDR7', N'asus-tuf-gaming-geforce-rtx-5070-ti-16gb-gddr7', N'Card đồ họa', N'ASUS', 33990000, 32990000, 6, N'Card đồ họa RTX 5070 Ti 16GB GDDR7, PCIe 5.0, phù hợp gaming cao cấp và làm việc AI.', N'ASUS TUF Gaming GeForce RTX 5070 Ti 16GB GDDR7 là card đồ họa thế hệ mới hướng đến game thủ cao cấp và người dùng sáng tạo nội dung hiện đại. Card sở hữu 8960 nhân CUDA, bộ nhớ 16GB GDDR7, chuẩn PCI Express 5.0 và hệ thống tản nhiệt TUF bền bỉ. Đây là lựa chọn phù hợp cho cấu hình chơi game AAA, xử lý AI cục bộ và làm việc đồ họa nặng.', N'/uploads/products/gpu/asus-tuf-rtx5070ti-16g/thumb.jpg', 36, 0),
(N'GPU-ASUS-ROG-RTX5080-16G', N'ASUS ROG GeForce RTX 5080 16GB GDDR7', N'asus-rog-geforce-rtx-5080-16gb-gddr7', N'Card đồ họa', N'ASUS', 46990000, 45990000, 4, N'Card đồ họa RTX 5080 16GB GDDR7, hiệu năng cao cho gaming 4K và workstation hiện đại.', N'ASUS ROG GeForce RTX 5080 16GB GDDR7 là card đồ họa cao cấp dành cho hệ thống gaming 4K, sáng tạo nội dung và build PC flagship. Sản phẩm có 10752 nhân CUDA, bộ nhớ 16GB GDDR7, bus 256-bit, hỗ trợ PCI Express 5.0 và hệ sinh thái ROG cao cấp. Card phù hợp cho người dùng muốn hiệu năng mạnh, ngoại hình đẹp và khả năng tản nhiệt tốt.', N'/uploads/products/gpu/asus-rog-rtx5080-16g/thumb.jpg', 36, 0),
(N'GPU-ASUS-TUF-RTX5090-32G', N'ASUS TUF Gaming GeForce RTX 5090 32GB GDDR7', N'asus-tuf-gaming-geforce-rtx-5090-32gb-gddr7', N'Card đồ họa', N'ASUS', 86990000, 84990000, 1, N'Card đồ họa RTX 5090 32GB GDDR7, hiệu năng đầu bảng cho AI, render và gaming flagship.', N'ASUS TUF Gaming GeForce RTX 5090 32GB GDDR7 là card đồ họa đầu bảng dành cho người dùng cần sức mạnh xử lý cực cao. Sản phẩm trang bị 21760 nhân CUDA, bộ nhớ 32GB GDDR7, bus 512-bit, hỗ trợ PCI Express 5.0 và xuất hình đa màn hình với HDMI 2.1b cùng DisplayPort 1.4a. Đây là lựa chọn rất mạnh cho AI workstation, dựng phim, mô phỏng và gaming 4K/8K.', N'/uploads/products/gpu/asus-tuf-rtx5090-32g/thumb.jpg', 36, 0),
(N'MB-ASUS-ROG-Z890-HERO', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 HERO (DDR5)', N'bo-mach-chu-asus-rog-maximus-z890-hero-ddr5', N'Mainboard', N'ASUS', 22890000, 19990000, 5, N'Mainboard cao cấp ASUS ROG MAXIMUS Z890 HERO, DDR5, Wi-Fi 7, LAN kép, phù hợp PC flagship.', N'ASUS ROG MAXIMUS Z890 HERO là bo mạch chủ cao cấp dành cho người dùng enthusiast, game thủ hardcore và hệ thống PC hiệu năng cao. Sản phẩm hỗ trợ nền tảng Z890, RAM DDR5, Wi-Fi 7, LAN tốc độ cao 2.5Gbps và 5Gbps, cùng thiết kế VRM mạnh mẽ 22+1+2+2 pha để phục vụ ép xung và vận hành bền bỉ.', N'/uploads/products/mainboard/asus-rog-maximus-z890-hero/thumb.jpg', 36, 0),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'Bo mạch chủ ASUS ProArt Z890-CREATOR WIFI (DDR5)', N'bo-mach-chu-asus-proart-z890-creator-wifi-ddr5', N'Mainboard', N'ASUS', 16590000, 14990000, 6, N'Mainboard ASUS ProArt Z890-CREATOR WIFI, DDR5, Wi-Fi 7, LAN 10Gbps, tối ưu cho creator workstation.', N'ASUS ProArt Z890-CREATOR WIFI là bo mạch chủ hướng tới người dùng sáng tạo nội dung, thiết kế đồ họa, dựng phim và workstation hiện đại. Bo mạch hỗ trợ RAM DDR5, Wi-Fi 7, LAN kép 10Gbps và 2.5Gbps, VRM 16+1+2+2 pha và hệ thống kết nối xuất hình linh hoạt gồm HDMI, USB-C DP Alt Mode và DisplayPort.', N'/uploads/products/mainboard/asus-proart-z890-creator-wifi/thumb.jpg', 36, 0),
(N'MB-ASUS-ROG-Z890-APEX', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 APEX (DDR5)', N'bo-mach-chu-asus-rog-maximus-z890-apex-ddr5', N'Mainboard', N'ASUS', 22690000, 20290000, 4, N'Mainboard ASUS ROG MAXIMUS Z890 APEX, DDR5, Wi-Fi 7, VRM mạnh, tối ưu ép xung.', N'ASUS ROG MAXIMUS Z890 APEX là bo mạch chủ cao cấp dành cho ép xung và build PC hiệu năng rất cao. Sản phẩm sở hữu VRM 22+1+2+2 pha, Wi-Fi 7, LAN 5Gbps, cổng USB phong phú và hỗ trợ xuất hình qua USB-C DP Alt Mode. Đây là dòng bo mạch phù hợp cho người dùng đam mê hiệu năng và hệ thống gaming cao cấp.', N'/uploads/products/mainboard/asus-rog-maximus-z890-apex/thumb.jpg', 36, 0),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'Bo mạch chủ GIGABYTE Z890 AORUS ELITE WIFI7 (DDR5)', N'bo-mach-chu-gigabyte-z890-aorus-elite-wifi7-ddr5', N'Mainboard', N'GIGABYTE', 9990000, 9590000, 11, N'Mainboard GIGABYTE Z890 AORUS ELITE WIFI7, DDR5, Wi-Fi 7, LAN 2.5Gbps, phù hợp gaming cao cấp.', N'GIGABYTE Z890 AORUS ELITE WIFI7 là bo mạch chủ tầm cao dành cho người dùng gaming và nâng cấp PC thế hệ mới. Bo mạch hỗ trợ RAM DDR5, Wi-Fi 7, LAN 2.5Gbps, VRM 16+1+2 pha và hệ thống cổng kết nối phong phú với DisplayPort và Thunderbolt. Đây là lựa chọn tốt cho cấu hình Intel hiện đại cần độ ổn định và khả năng mở rộng cao.', N'/uploads/products/mainboard/gigabyte-z890-aorus-elite-wifi7/thumb.jpg', 36, 0),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'Bo mạch chủ GIGABYTE Z890 EAGLE WIFI7 (DDR5)', N'bo-mach-chu-gigabyte-z890-eagle-wifi7-ddr5', N'Mainboard', N'GIGABYTE', 7990000, 6990000, 14, N'Mainboard GIGABYTE Z890 EAGLE WIFI7, DDR5, Wi-Fi 7, LAN 2.5Gbps, phù hợp gaming và làm việc.', N'GIGABYTE Z890 EAGLE WIFI7 là bo mạch chủ dành cho người dùng muốn tiếp cận nền tảng Z890 với chi phí hợp lý hơn nhưng vẫn có Wi-Fi 7 và hỗ trợ DDR5. Sản phẩm có VRM 14+1+2 pha, LAN 2.5Gbps, 10 cổng USB và các cổng xuất hình USB-C DP Alt Mode cùng DisplayPort, phù hợp cho cấu hình gaming và làm việc thế hệ mới.', N'/uploads/products/mainboard/gigabyte-z890-eagle-wifi7/thumb.jpg', 36, 0),
(N'MB-ASUS-ROG-Z890-EXTREME', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 EXTREME (DDR5)', N'bo-mach-chu-asus-rog-maximus-z890-extreme-ddr5', N'Mainboard', N'ASUS', 32690000, 28990000, 2, N'Mainboard flagship ASUS ROG MAXIMUS Z890 EXTREME, DDR5, Wi-Fi 7, LAN kép, VRM cực mạnh.', N'ASUS ROG MAXIMUS Z890 EXTREME là bo mạch chủ flagship dành cho người dùng cao cấp nhất, phù hợp cho ép xung nặng, workstation đầu bảng và hệ thống gaming flagship. Bo mạch có VRM 24+1+2+2 pha, LAN 10Gbps và 2.5Gbps, Wi-Fi 7, hỗ trợ xuất hình HDMI và Thunderbolt, cùng hệ thống thiết kế ROG mạnh mẽ cho nhu cầu build PC không giới hạn.', N'/uploads/products/mainboard/asus-rog-maximus-z890-extreme/thumb.jpg', 36, 0),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'Bo mạch chủ GIGABYTE H610M-H V3 (DDR4)', N'bo-mach-chu-gigabyte-h610m-h-v3-ddr4', N'Mainboard', N'GIGABYTE', 1990000, 1890000, 20, N'Mainboard phổ thông GIGABYTE H610M-H V3 DDR4, phù hợp PC văn phòng và học tập.', N'GIGABYTE H610M-H V3 DDR4 là bo mạch chủ phổ thông dành cho cấu hình giá rẻ, máy văn phòng, học tập và sử dụng hằng ngày. Sản phẩm hỗ trợ RAM DDR4, LAN 1Gbps, 6 cổng USB, cổng xuất hình VGA và HDMI, cùng thiết kế nhỏ gọn dễ lắp đặt cho các hệ thống tiết kiệm chi phí.', N'/uploads/products/mainboard/gigabyte-h610m-h-v3-ddr4/thumb.jpg', 36, 0),
(N'SSD-SAMSUNG-9100PRO-1TB', N'Ổ cứng SSD Samsung 9100 PRO NVMe M.2 1TB Gen5', N'o-cung-ssd-samsung-9100-pro-nvme-m-2-1tb-gen5', N'Ổ cứng', N'Samsung', 7490000, 6990000, 7, N'SSD Samsung 9100 PRO 1TB chuẩn NVMe M.2 PCIe Gen5, tốc độ đọc ghi rất cao cho hệ thống cao cấp.', N'Samsung 9100 PRO 1TB Gen5 là mẫu SSD hiệu năng cao dành cho gaming, workstation và các bộ máy cần băng thông lưu trữ cực lớn. Sản phẩm dùng chuẩn M.2 NVMe PCIe Gen5, tốc độ đọc ghi nổi bật, phù hợp cài hệ điều hành, game AAA và các dự án dựng phim nặng.', N'/uploads/products/storage/samsung-9100-pro-1tb/thumb.jpg', 60, 0),
(N'SSD-SAMSUNG-990PRO-2TB', N'Ổ cứng SSD Samsung 990 PRO 2TB M.2 PCIe Gen4 NVMe', N'o-cung-ssd-samsung-990-pro-2tb-m-2-pcie-gen4-nvme', N'Ổ cứng', N'Samsung', 7590000, 6490000, 9, N'SSD Samsung 990 PRO 2TB PCIe Gen4, hiệu năng cao, phù hợp gaming và làm việc chuyên sâu.', N'Samsung 990 PRO 2TB là dòng SSD NVMe Gen4 cao cấp, nổi bật với tốc độ truy xuất nhanh, độ ổn định tốt và độ bền cao. Sản phẩm thích hợp cho máy tính chơi game, máy làm việc đồ họa và các hệ thống cần không gian lưu trữ lớn.', N'/uploads/products/storage/samsung-990-pro-2tb/thumb.jpg', 60, 0),
(N'SSD-KINGSTON-NV3-500GB', N'Ổ cứng SSD Kingston NV3 500GB M.2 PCIe NVMe Gen4', N'o-cung-ssd-kingston-nv3-500gb-m-2-pcie-nvme-gen4', N'Ổ cứng', N'Kingston', 5490000, 3890000, 15, N'SSD Kingston NV3 500GB M.2 PCIe Gen4, lựa chọn lưu trữ phổ thông cho máy tính học tập và văn phòng.', N'Kingston NV3 500GB là giải pháp SSD Gen4 tầm phổ thông với thiết kế M.2 gọn gàng, tốc độ tốt và mức giá dễ tiếp cận. Sản phẩm phù hợp nâng cấp laptop và PC văn phòng, giúp cải thiện tốc độ khởi động máy và mở ứng dụng.', N'/uploads/products/storage/kingston-nv3-500gb/thumb.jpg', 36, 0),
(N'SSD-KINGSTON-NV3-1TB', N'Ổ cứng SSD Kingston NV3 1TB M.2 PCIe NVMe Gen4', N'o-cung-ssd-kingston-nv3-1tb-m-2-pcie-nvme-gen4', N'Ổ cứng', N'Kingston', 5990000, 5790000, 13, N'SSD Kingston NV3 1TB chuẩn M.2 PCIe Gen4, dung lượng tốt cho nhu cầu học tập, làm việc và gaming.', N'Kingston NV3 1TB Gen4 mang lại dung lượng đủ dùng cho hệ điều hành, game, ứng dụng và dữ liệu cá nhân. Đây là lựa chọn hợp lý cho người dùng cần SSD nhanh, ổn định và dễ lắp đặt trong nhiều cấu hình PC/laptop.', N'/uploads/products/storage/kingston-nv3-1tb/thumb.jpg', 36, 0),
(N'SSD-KINGSTON-NV3-2TB', N'Ổ cứng SSD Kingston NV3 2TB M.2 PCIe NVMe Gen4', N'o-cung-ssd-kingston-nv3-2tb-m-2-pcie-nvme-gen4', N'Ổ cứng', N'Kingston', 11490000, 10990000, 8, N'SSD Kingston NV3 2TB Gen4, dung lượng lớn cho lưu trữ game, dữ liệu và công việc chuyên môn.', N'Kingston NV3 2TB là SSD M.2 NVMe Gen4 có dung lượng lớn, đáp ứng tốt nhu cầu lưu trữ dài hạn cho game thủ, người dựng video, lập trình viên hoặc người dùng văn phòng cần nhiều không gian dữ liệu.', N'/uploads/products/storage/kingston-nv3-2tb/thumb.jpg', 36, 0),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng HDD Seagate Barracuda 2TB', N'o-cung-hdd-seagate-barracuda-2tb', N'Ổ cứng', N'Seagate', 3490000, 3290000, 16, N'HDD Seagate Barracuda 2TB 3.5 inch cho lưu trữ dữ liệu, backup và máy tính văn phòng.', N'Seagate Barracuda 2TB là dòng ổ cứng HDD phổ biến cho nhu cầu lưu trữ dữ liệu, phim ảnh, game nhẹ và sao lưu. Sản phẩm phù hợp cho desktop cần mở rộng dung lượng với chi phí hợp lý.', N'/uploads/products/storage/seagate-barracuda-2tb/thumb.jpg', 24, 0),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng HDD WD Blue 6TB 5400RPM', N'o-cung-hdd-wd-blue-6tb-5400rpm', N'Ổ cứng', N'Western Digital', 4890000, 4490000, 10, N'HDD WD Blue 6TB dung lượng lớn, phù hợp lưu trữ dữ liệu, backup và media server cá nhân.', N'WD Blue 6TB 5400RPM là lựa chọn tốt cho người dùng cần dung lượng lưu trữ lớn với độ ổn định cao. Sản phẩm phù hợp cho máy tính cá nhân, NAS cơ bản hoặc hệ thống lưu trữ phim, ảnh và dữ liệu công việc.', N'/uploads/products/storage/wd-blue-6tb-5400rpm/thumb.jpg', 24, 0),
(N'HDD-WD-BLUE-4TB', N'Ổ cứng HDD WD Blue 4TB', N'o-cung-hdd-wd-blue-4tb', N'Ổ cứng', N'Western Digital', 3890000, 3590000, 12, N'HDD WD Blue 4TB cho desktop, lưu trữ dữ liệu lớn với chi phí hợp lý.', N'WD Blue 4TB mang đến dung lượng lớn cho người dùng desktop cần lưu trữ tài liệu, game, hình ảnh hoặc video. Sản phẩm phù hợp cho cả môi trường văn phòng và sử dụng tại nhà.', N'/uploads/products/storage/wd-blue-4tb/thumb.jpg', 24, 0),
(N'HDD-WD-BLUE-2TB-7200', N'Ổ cứng HDD WD Blue 2TB 7200RPM', N'o-cung-hdd-wd-blue-2tb-7200rpm', N'Ổ cứng', N'Western Digital', 3450000, 3290000, 14, N'HDD WD Blue 2TB 7200RPM cho hiệu năng đọc ghi tốt hơn trong phân khúc HDD phổ thông.', N'WD Blue 2TB 7200RPM là ổ cứng HDD phù hợp cho người dùng cần dung lượng vừa phải nhưng vẫn muốn tốc độ truy xuất khá. Sản phẩm thích hợp cho desktop văn phòng, học tập và lưu trữ dữ liệu cá nhân.', N'/uploads/products/storage/wd-blue-2tb-7200rpm/thumb.jpg', 24, 0),
(N'HDD-WD-BLUE-1TB', N'Ổ cứng HDD WD Blue 1TB', N'o-cung-hdd-wd-blue-1tb', N'Ổ cứng', N'Western Digital', 2990000, 2690000, 18, N'HDD WD Blue 1TB là lựa chọn lưu trữ phổ thông cho desktop học tập, văn phòng và gia đình.', N'WD Blue 1TB phù hợp làm ổ lưu trữ bổ sung cho desktop với mức chi phí thấp, độ ổn định tốt và dung lượng đủ dùng cho tài liệu, phần mềm và dữ liệu cá nhân.', N'/uploads/products/storage/wd-blue-1tb/thumb.jpg', 24, 0),
(N'PSU-ASUS-ROG-THOR-850P', N'Nguồn máy tính ASUS ROG Thor 850P 80 Plus Platinum Full Modular 850W', N'nguon-may-tinh-asus-rog-thor-850p-80-plus-platinum-full-modular-850w', N'Nguồn máy tính', N'ASUS', 5990000, NULL, 8, N'PSU ASUS ROG Thor 850P chuẩn 80 Plus Platinum, Full Modular, phù hợp cấu hình gaming cao cấp.', N'ASUS ROG Thor 850P là bộ nguồn cao cấp dành cho các cấu hình gaming và workstation yêu cầu độ ổn định điện năng cao. Sản phẩm có chuẩn Platinum, thiết kế Full Modular, độ hoàn thiện tốt và nhiều tính năng bảo vệ an toàn.', N'/uploads/products/psu/asus-rog-thor-850p/thumb.jpg', 120, 0),
(N'PSU-ASUS-ROG-THOR-1200P2', N'Nguồn máy tính ASUS ROG Thor 1200P2 80 Plus Platinum Full Modular 1200W', N'nguon-may-tinh-asus-rog-thor-1200p2-80-plus-platinum-full-modular-1200w', N'Nguồn máy tính', N'ASUS', 9990000, 9490000, 5, N'PSU ASUS ROG Thor 1200P2 công suất 1200W, 80 Plus Platinum, phù hợp cấu hình cực mạnh.', N'ASUS ROG Thor 1200P2 là bộ nguồn cao cấp cho hệ thống nhiều VGA, workstation và cấu hình đòi hỏi công suất lớn. Sản phẩm hỗ trợ chuẩn ATX 3.0, Full Modular và độ bền cao cho vận hành lâu dài.', N'/uploads/products/psu/asus-rog-thor-1200p2/thumb.jpg', 120, 0),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'Nguồn máy tính ASUS ROG Strix 1000W AURA Edition 80 Plus Gold Full Modular', N'nguon-may-tinh-asus-rog-strix-1000w-aura-edition-80-plus-gold-full-modular', N'Nguồn máy tính', N'ASUS', 6490000, 5990000, 7, N'PSU ASUS ROG Strix 1000W AURA Edition, 80 Plus Gold, Full Modular cho PC gaming mạnh.', N'ASUS ROG Strix 1000W AURA Edition là bộ nguồn phù hợp cho cấu hình gaming cao cấp, hỗ trợ chuẩn ATX 3.0, thiết kế Full Modular, hiệu suất ổn định và đồng bộ Aura Sync đẹp mắt.', N'/uploads/products/psu/asus-rog-strix-1000w-aura/thumb.jpg', 120, 0),
(N'PSU-GIGABYTE-UD850GM-PG5', N'Nguồn máy tính GIGABYTE UD850GM PG5 80 Plus Gold Full Modular 850W', N'nguon-may-tinh-gigabyte-ud850gm-pg5-80-plus-gold-full-modular-850w', N'Nguồn máy tính', N'GIGABYTE', 3490000, 2990000, 11, N'PSU GIGABYTE UD850GM PG5 850W, 80 Plus Gold, Full Modular, tương thích cấu hình hiện đại.', N'GIGABYTE UD850GM PG5 là bộ nguồn 850W hướng đến người dùng cần mức công suất tốt, chuẩn Gold, thiết kế Full Modular và hỗ trợ đầu nguồn mới cho VGA hiện đại. Đây là lựa chọn cân bằng giữa giá thành và hiệu năng.', N'/uploads/products/psu/gigabyte-ud850gm-pg5/thumb.jpg', 36, 0),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính ASUS ROG Thor 1600T3 ATX 3.1 PCIe 5.0 80 Plus Titanium Full Modular 1600W', N'nguon-may-tinh-asus-rog-thor-1600t3-atx-3-1-pcie-5-0-80-plus-titanium-full-modular-1600w', N'Nguồn máy tính', N'ASUS', 24990000, 24490000, 3, N'PSU ASUS ROG Thor 1600T3 chuẩn Titanium cực cao cấp cho cấu hình workstation và enthusiast.', N'ASUS ROG Thor 1600T3 là bộ nguồn đầu bảng cho cấu hình cực mạnh, hỗ trợ ATX 3.1, PCIe 5.0 và chuẩn 80 Plus Titanium. Sản phẩm thích hợp cho hệ thống đa card, AI workstation hoặc PC trình diễn cao cấp.', N'/uploads/products/psu/asus-rog-thor-1600t3/thumb.jpg', 120, 0),
(N'CASE-CORSAIR-6500X-WHITE', N'Vỏ máy tính Corsair 6500X TG Mid-Tower White (CC-9011258-WW)', N'vo-may-tinh-corsair-6500x-tg-mid-tower-white-cc-9011258-ww', N'Case', N'Corsair', 4490000, NULL, 9, N'Case Corsair 6500X màu trắng, thiết kế kính cường lực, phù hợp cho dàn PC trưng bày cao cấp.', N'Corsair 6500X TG Mid-Tower White là mẫu case cao cấp với không gian rộng rãi, thiết kế kính cường lực đẹp mắt và khả năng đi dây tốt. Sản phẩm phù hợp cho cấu hình gaming, streaming hoặc build showcase tone trắng.', N'/uploads/products/case/corsair-6500x-white/thumb.jpg', 24, 0),
(N'CASE-JONSBO-Z20-WHITE', N'Vỏ máy tính Jonsbo Z20 White', N'vo-may-tinh-jonsbo-z20-white', N'Case', N'Jonsbo', 1750000, 1650000, 12, N'Case Jonsbo Z20 White nhỏ gọn, có kính cường lực và hỗ trợ build PC tone trắng đẹp mắt.', N'Jonsbo Z20 White là mẫu case gọn gàng, phù hợp cho các bộ máy mini hoặc micro-ATX hiện đại. Thiết kế màu trắng kết hợp kính cường lực giúp bộ máy nổi bật và thẩm mỹ hơn trên bàn làm việc.', N'/uploads/products/case/jonsbo-z20-white/thumb.jpg', 12, 0),
(N'CASE-JONSBO-Z20-PINK', N'Vỏ máy tính Jonsbo Z20 Pink', N'vo-may-tinh-jonsbo-z20-pink', N'Case', N'Jonsbo', 1990000, 1890000, 10, N'Case Jonsbo Z20 Pink cá tính, phù hợp build PC tone hồng hoặc góc setup nổi bật.', N'Jonsbo Z20 Pink là lựa chọn cho người dùng thích build máy tính có màu sắc riêng. Sản phẩm có thiết kế gọn, kính cường lực và phù hợp với nhiều cấu hình PC giải trí hoặc gaming nhẹ.', N'/uploads/products/case/jonsbo-z20-pink/thumb.jpg', 12, 0),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Vỏ máy tính Cooler Master MASTERBOX TD500 MESH V2 CHUN-LI', N'vo-may-tinh-cooler-master-masterbox-td500-mesh-v2-chun-li', N'Case', N'Cooler Master', 2790000, 2490000, 8, N'Case Cooler Master TD500 Mesh V2 bản CHUN-LI độc đáo, có sẵn quạt ARGB và mặt lưới thoáng.', N'MASTERBOX TD500 MESH V2 CHUN-LI là mẫu case nổi bật dành cho game thủ thích phong cách khác biệt. Sản phẩm có mặt trước thoáng khí, đi kèm quạt ARGB và không gian phù hợp cho cấu hình gaming tầm trung đến cao cấp.', N'/uploads/products/case/cooler-master-td500-v2-chunli/thumb.jpg', 24, 0),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Vỏ máy tính NZXT H9 Elite White', N'vo-may-tinh-nzxt-h9-elite-white', N'Case', N'NZXT', 6990000, 5290000, 6, N'Case NZXT H9 Elite White cao cấp, thiết kế hai mặt kính đẹp mắt và tối ưu cho build trình diễn.', N'NZXT H9 Elite White hướng đến người dùng yêu thích build PC showcase. Sản phẩm có không gian rộng, hỗ trợ nhiều quạt và radiator, phù hợp cho hệ thống gaming hoặc làm việc cao cấp tone trắng.', N'/uploads/products/case/nzxt-h9-elite-white/thumb.jpg', 24, 0),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Vỏ máy tính TRYX Luca L70 Mid Tower Black', N'vo-may-tinh-tryx-luca-l70-mid-tower-black', N'Case', N'TRYX', 5590000, 5490000, 5, N'Case TRYX Luca L70 Mid Tower màu đen, thiết kế hiện đại và hỗ trợ build PC cao cấp.', N'TRYX Luca L70 Mid Tower Black là mẫu case mạnh về thẩm mỹ và không gian lắp ráp. Sản phẩm phù hợp cho cấu hình gaming cao cấp với khả năng hỗ trợ linh kiện dài, nhiều vị trí quạt và kính cường lực sang trọng.', N'/uploads/products/case/tryx-luca-l70-black/thumb.jpg', 24, 0),
(N'CASE-JONSBO-D300-BLACK', N'Vỏ máy tính Jonsbo D300 Black', N'vo-may-tinh-jonsbo-d300-black', N'Case', N'Jonsbo', 1890000, 1790000, 11, N'Case Jonsbo D300 Black thiết kế hiện đại, hỗ trợ kính cường lực và build gọn gàng.', N'Jonsbo D300 Black là lựa chọn phù hợp trong phân khúc dễ tiếp cận cho người dùng thích thiết kế hiện đại, không gian lắp linh hoạt và vẻ ngoài tối giản mạnh mẽ.', N'/uploads/products/case/jonsbo-d300-black/thumb.jpg', 12, 0),
(N'CASE-CORSAIR-6500X-BLACK', N'Vỏ máy tính Corsair 6500X TG Mid-Tower Black (CC-9011257-WW)', N'vo-may-tinh-corsair-6500x-tg-mid-tower-black-cc-9011257-ww', N'Case', N'Corsair', 3990000, NULL, 8, N'Case Corsair 6500X màu đen, kính cường lực, không gian rộng cho build PC cao cấp.', N'Corsair 6500X TG Mid-Tower Black phù hợp với người dùng cần một mẫu case rộng rãi, đi dây đẹp, hỗ trợ tốt cho tản nhiệt nước và dàn linh kiện cao cấp trong tông màu đen sang trọng.', N'/uploads/products/case/corsair-6500x-black/thumb.jpg', 24, 0),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Vỏ máy tính ASUS ROG Hyperion GR701', N'vo-may-tinh-asus-rog-hyperion-gr701', N'Case', N'ASUS', 10990000, NULL, 4, N'Case ASUS ROG Hyperion GR701 cỡ lớn, hỗ trợ build enthusiast và hệ thống tản nhiệt khủng.', N'ASUS ROG Hyperion GR701 là mẫu case full tower cao cấp dành cho các cấu hình flagship. Sản phẩm hỗ trợ mainboard cỡ lớn, nhiều quạt, radiator lớn và có thiết kế ROG đậm chất gaming cao cấp.', N'/uploads/products/case/asus-rog-hyperion-gr701/thumb.jpg', 24, 0),
(N'CASE-JONSBO-TK3-WHITE', N'Vỏ máy tính Jonsbo TK3 White', N'vo-may-tinh-jonsbo-tk3-white', N'Case', N'Jonsbo', 2090000, 1990000, 9, N'Case Jonsbo TK3 White có kính cường lực và LED RGB, phù hợp build PC gaming tone trắng.', N'Jonsbo TK3 White là mẫu case tầm trung có thiết kế hiện đại, hỗ trợ RGB, phù hợp với các cấu hình PC chơi game và làm việc sử dụng mainboard ATX hoặc mATX trong không gian gọn gàng.', N'/uploads/products/case/jonsbo-tk3-white/thumb.jpg', 12, 0),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình Samsung 27Q180 IPS Gaming 27 inch 2K 180Hz', N'man-hinh-samsung-27q180-ips-gaming-27-inch-2k-180hz', N'Màn hình', N'Samsung', 5490000, 4990000, 14, N'Màn hình Samsung 27 inch IPS, 2K, 180Hz, phù hợp chơi game và giải trí.', N'Mẫu màn hình Samsung 27Q180 IPS Gaming phù hợp cho game thủ cần tần số quét cao, độ phân giải 2K sắc nét và màu sắc ổn định. Sản phẩm dùng tấm nền IPS, thời gian phản hồi nhanh và hỗ trợ kết nối cơ bản cho nhu cầu gaming hằng ngày.', N'/uploads/products/monitor/samsung-27q180-ips-gaming/thumb.jpg', 24, 0),
(N'MON-MSI-32U-QDOLED', N'Màn hình MSI 32U QD-OLED Gaming 32 inch 4K', N'man-hinh-msi-32u-qd-oled-gaming-32-inch-4k', N'Màn hình', N'MSI', 24990000, 22990000, 5, N'Màn hình MSI 32 inch QD-OLED 4K cao cấp cho gaming và trải nghiệm hình ảnh đỉnh cao.', N'Mẫu MSI 32U QD-OLED Gaming hướng tới phân khúc cao cấp với tấm nền QD-OLED, độ phân giải 4K và thời gian phản hồi cực thấp. Sản phẩm phù hợp cho game thủ, người làm nội dung và người dùng cần chất lượng hiển thị cao.', N'/uploads/products/monitor/msi-32u-qdoled-gaming/thumb.jpg', 36, 0),
(N'HKC-MB27S9U', N'Màn hình HKC MB27S9U 27 inch 4K IPS', N'man-hinh-hkc-mb27s9u-27-inch-4k-ips', N'Màn hình', N'HKC', 5990000, 4990000, 9, N'Màn hình HKC 27 inch 4K IPS phù hợp làm việc văn phòng, học tập và giải trí đa phương tiện.', N'HKC MB27S9U là màn hình 27 inch độ phân giải 4K sử dụng tấm nền IPS, phù hợp cho người dùng cần không gian hiển thị lớn, hình ảnh sắc nét và mức giá dễ tiếp cận hơn các dòng đồ họa cao cấp.', N'/uploads/products/monitor/hkc-mb27s9u/thumb.jpg', 24, 0),
(N'MON-ACER-27Q-IPS', N'Màn hình Acer 27Q IPS Gaming 27 inch 2K', N'man-hinh-acer-27q-ips-gaming-27-inch-2k', N'Màn hình', N'Acer', 4990000, 4290000, 11, N'Màn hình Acer 27 inch IPS 2K cho gaming phổ thông với phản hồi nhanh và thiết kế gọn gàng.', N'Mẫu Acer 27Q IPS Gaming phù hợp cho người dùng cần màn hình 2K sắc nét, thời gian phản hồi thấp và màu sắc ổn định để chơi game, làm việc và học tập hằng ngày.', N'/uploads/products/monitor/acer-27q-ips-gaming/thumb.jpg', 36, 0),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình AOC 27Q Fast IPS Gaming 27 inch 2K', N'man-hinh-aoc-27q-fast-ips-gaming-27-inch-2k', N'Màn hình', N'AOC', 5490000, 4790000, 10, N'Màn hình AOC 27 inch Fast IPS 2K cho gaming với màu sắc rộng và phản hồi nhanh.', N'AOC 27Q Fast IPS Gaming là mẫu màn hình hướng đến game thủ cần độ phân giải 2K, màu sắc rộng, độ sáng tốt và tốc độ phản hồi nhanh. Sản phẩm phù hợp cho game, xem phim và làm việc sáng tạo cơ bản.', N'/uploads/products/monitor/aoc-27q-fastips-gaming/thumb.jpg', 36, 0),
(N'MON-GIGABYTE-32U-OLED', N'Màn hình Gigabyte 32U OLED Gaming 32 inch 4K', N'man-hinh-gigabyte-32u-oled-gaming-32-inch-4k', N'Màn hình', N'GIGABYTE', 21990000, 19990000, 6, N'Màn hình 32 inch OLED 4K dành cho gaming, màu đen sâu và hiển thị cao cấp.', N'Đây là mẫu màn hình 32 inch OLED 4K được tạm gán theo brand Gigabyte để dùng cho seed data. Sản phẩm hướng tới nhu cầu gaming cao cấp với chất lượng hiển thị nổi bật và thiết kế hiện đại.', N'/uploads/products/monitor/gigabyte-32u-oled-gaming/thumb.jpg', 36, 0),
(N'MON-DELL-43U-IPSBLACK', N'Màn hình Dell 43U IPS Black 43 inch 4K', N'man-hinh-dell-43u-ips-black-43-inch-4k', N'Màn hình', N'Dell', 18990000, 17490000, 4, N'Màn hình 43 inch 4K IPS Black phù hợp đồ họa, văn phòng và làm việc đa cửa sổ.', N'Đây là mẫu màn hình 43 inch 4K IPS Black được tạm gán theo brand Dell để dùng cho seed data. Sản phẩm phù hợp cho nhu cầu đồ họa, văn phòng, quản lý đa cửa sổ và làm việc chuyên nghiệp.', N'/uploads/products/monitor/dell-43u-ips-black-4k/thumb.jpg', 36, 0),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình ViewSonic 27Q Color USB-C 90W 27 inch 2K', N'man-hinh-viewsonic-27q-color-usb-c-90w-27-inch-2k', N'Màn hình', N'ViewSonic', 8990000, 7990000, 7, N'Màn hình ViewSonic 27 inch 2K có USB-C 90W, phù hợp đồ họa và làm việc chuyên nghiệp.', N'Mẫu ViewSonic 27Q Color USB-C 90W là màn hình phù hợp cho người dùng văn phòng cao cấp, thiết kế và sáng tạo nội dung. Sản phẩm có độ sáng tốt, màu rộng và hỗ trợ USB-C cấp nguồn 90W rất tiện cho laptop.', N'/uploads/products/monitor/viewsonic-27q-color-usbc-90w/thumb.jpg', 36, 0),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình ASUS 32U WOLED Dual Mode 32 inch 4K 240Hz', N'man-hinh-asus-32u-woled-dual-mode-32-inch-4k-240hz', N'Màn hình', N'ASUS', 36990000, 34990000, 3, N'Màn hình ASUS 32 inch WOLED 4K cao cấp, hỗ trợ Dual Mode 4K 240Hz / FHD 480Hz.', N'ASUS 32U WOLED Dual Mode là màn hình gaming cực cao cấp dành cho người dùng cần cả độ phân giải 4K sắc nét lẫn tốc độ cực cao ở chế độ FHD 480Hz. Sản phẩm phù hợp cho game thủ esports lẫn AAA cao cấp.', N'/uploads/products/monitor/asus-32u-woled-dual-mode/thumb.jpg', 36, 0),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình LG 27U Nano IPS Dual Mode 27 inch 4K 240Hz', N'man-hinh-lg-27u-nano-ips-dual-mode-27-inch-4k-240hz', N'Màn hình', N'LG', 24990000, 22990000, 4, N'Màn hình LG 27 inch Nano IPS 4K, hỗ trợ Dual Mode cho gaming cao cấp.', N'LG 27U Nano IPS Dual Mode là màn hình gaming cao cấp với khả năng chuyển giữa 4K 240Hz và FHD 480Hz. Sản phẩm phù hợp cho người dùng cần tốc độ cao, màu sắc đẹp và độ chi tiết tốt trong không gian màn hình 27 inch.', N'/uploads/products/monitor/lg-27u-nanoips-dual-mode/thumb.jpg', 24, 0),
(N'KB-AKKO-5075B-PLUS-BWTVN', N'Bàn phím AKKO 5075B Plus Black World Tour VIET NAM', N'ban-phim-akko-5075b-plus-black-world-tour-viet-nam', N'Bàn phím', N'AKKO', 1790000, NULL, 15, N'Bàn phím cơ AKKO layout 75%, hỗ trợ 3 chế độ kết nối và keycap PBT nổi bật theo chủ đề Việt Nam.', N'AKKO 5075B Plus Black World Tour VIET NAM là mẫu bàn phím cơ hướng đến người dùng yêu thích layout gọn gàng nhưng vẫn cần đầy đủ cụm phím chức năng cơ bản. Sản phẩm hỗ trợ kết nối có dây, Bluetooth và Wireless 2.4GHz, phù hợp cho cả desktop lẫn laptop. Bộ keycap PBT bền màu cùng phối màu đen đỏ trắng tạo điểm nhấn nổi bật cho góc máy. Đây là lựa chọn phù hợp cho gaming, làm việc và người dùng thích bàn phím có cá tính riêng.', N'/uploads/products/keyboard/akko-5075b-plus-black-world-tour-viet-nam/thumb.jpg', 24, 0),
(N'KB-AULA-F75-WHITE-RED', N'Bàn phím AULA F75 có dây (Trắng Red switch) F7512', N'ban-phim-aula-f75-co-day-trang-red-switch-f7512', N'Bàn phím', N'AULA', 785000, 650000, 24, N'Bàn phím cơ AULA F75 có dây, layout 75%, switch Red và LED RGB phù hợp tầm giá phổ thông.', N'AULA F75 F7512 là mẫu bàn phím cơ có dây với thiết kế 75% nhỏ gọn, phù hợp cho người dùng muốn tối ưu diện tích bàn làm việc nhưng vẫn có trải nghiệm gõ tốt. Phiên bản màu trắng đi kèm Red switch cho cảm giác nhấn nhẹ, phù hợp gõ văn bản lẫn chơi game. Keycap ABS cùng hệ thống LED RGB giúp sản phẩm nổi bật hơn trong phân khúc ngân sách.', N'/uploads/products/keyboard/aula-f75-co-day-trang-red-switch-f7512/thumb.jpg', 24, 0),
(N'KB-DAREU-EK75-RT-BLACK', N'Bàn phím cơ DareU EK75 Rapid Trigger Black', N'ban-phim-co-dareu-ek75-rapid-trigger-black', N'Bàn phím', N'DareU', 2500000, 1750000, 11, N'Bàn phím gaming DareU EK75 Rapid Trigger layout 75% với kết nối USB-C, tối ưu cho game thủ FPS.', N'DareU EK75 Rapid Trigger Black là mẫu bàn phím gaming tập trung vào hiệu năng, hướng đến người chơi cần tốc độ phản hồi cao và khả năng điều khiển chính xác. Layout 75% giúp tiết kiệm diện tích nhưng vẫn giữ lại các phím điều hướng quan trọng. Kết nối USB-C/USB ổn định, keycap PBT Double-Shot bền bỉ và cảm giác gõ chắc chắn khiến đây là lựa chọn đáng chú ý trong phân khúc bàn phím hiệu năng.', N'/uploads/products/keyboard/dareu-ek75-rapid-trigger-black/thumb.jpg', 24, 0),
(N'KB-DURGOD-CAVALRY-87-BLACK', N'Bàn phím cơ không dây Durgod Cavalry 87 Black Kailh Turbo Silent Red Switch', N'ban-phim-co-khong-day-durgod-cavalry-87-black-kailh-turbo-silent-red-switch', N'Bàn phím', N'Durgod', 1690000, 1190000, 9, N'Bàn phím Durgod Cavalry 87 không dây, layout TKL, switch Kailh Turbo Silent Red và thiết kế gọn cho làm việc.', N'Durgod Cavalry 87 Black là bàn phím cơ không dây theo layout TKL/Tenkeyless, phù hợp cho người dùng muốn tiết kiệm không gian nhưng vẫn giữ trải nghiệm gõ ổn định. Phiên bản sử dụng Kailh Turbo Silent Red switch thiên về sự êm ái, thích hợp cho môi trường làm việc hoặc chơi game đêm khuya. Bàn phím hỗ trợ kết nối wireless và USB-C, kết hợp cùng LED RGB giúp hoàn thiện tốt cả yếu tố thẩm mỹ lẫn công năng.', N'/uploads/products/keyboard/durgod-cavalry-87-black-kailh-turbo-silent-red-switch/thumb.jpg', 24, 0),
(N'KB-CORSAIR-K70-PRO-RED', N'Bàn phím Corsair K70 PRO Red Switch', N'ban-phim-corsair-k70-pro-red-switch', N'Bàn phím', N'Corsair', 3990000, 3590000, 10, N'Bàn phím cơ Corsair K70 PRO full-size, switch Cherry MX Red, keycap PBT Doubleshot và RGB nổi bật.', N'Corsair K70 PRO Red Switch là mẫu bàn phím cơ full-size dành cho game thủ và người dùng cần đủ cụm numpad để làm việc. Sản phẩm dùng switch Cherry MX Red cho hành trình mượt, phù hợp với nhịp gõ nhanh và chơi game liên tục. Keycap PBT Doubleshot bền bỉ, LED RGB đẹp mắt và kết nối có dây ổn định giúp K70 PRO giữ được vị thế trong phân khúc bàn phím gaming cao cấp.', N'/uploads/products/keyboard/corsair-k70-pro-red-switch/thumb.jpg', 24, 0),
(N'KB-E-DRA-EK3104L-BETA-BROWN', N'Bàn phím E-Dra EK3104L Beta Brown Switch', N'ban-phim-e-dra-ek3104l-beta-brown-switch', N'Bàn phím', N'E-Dra', 990000, 559000, 28, N'Bàn phím cơ E-Dra EK3104L Beta full-size giá dễ tiếp cận, Brown switch và LED Rainbow.', N'E-Dra EK3104L Beta Brown Switch là mẫu bàn phím cơ phổ thông dành cho người dùng cần một sản phẩm full-size có mức giá dễ tiếp cận. Brown switch cho cảm giác gõ cân bằng giữa làm việc và giải trí, trong khi LED Rainbow tạo điểm nhấn vừa đủ cho góc máy. Kết nối USB ổn định và layout 100% giúp sản phẩm phù hợp với học tập, văn phòng và gaming cơ bản.', N'/uploads/products/keyboard/e-dra-ek3104l-beta-brown-switch/thumb.jpg', 24, 0),
(N'KB-ASUS-ROG-SCOPE-II-96-WL-SNOW', N'Bàn phím Asus ROG Strix Scope II 96 Wireless ROG NX Snow Switch', N'ban-phim-asus-rog-strix-scope-ii-96-wireless-rog-nx-snow-switch', N'Bàn phím', N'ASUS', 4990000, 3890000, 8, N'Bàn phím ASUS ROG layout 96%, hỗ trợ ba chế độ kết nối, switch NX Snow và keycap PBT cao cấp.', N'ASUS ROG Strix Scope II 96 Wireless là mẫu bàn phím cơ cao cấp hướng đến game thủ cần trải nghiệm gõ tốt nhưng vẫn muốn một layout nhỏ gọn hơn full-size truyền thống. Bàn phím hỗ trợ Wireless 2.4GHz, Bluetooth và USB-C, cho khả năng dùng linh hoạt trên nhiều thiết bị. Switch ROG NX Snow, keycap PBT và LED RGB Aura Sync giúp sản phẩm đáp ứng tốt cả hiệu năng lẫn yếu tố thẩm mỹ trong hệ sinh thái gaming ASUS.', N'/uploads/products/keyboard/asus-rog-strix-scope-ii-96-wireless-rog-nx-snow-switch/thumb.jpg', 24, 0),
(N'KB-LOGITECH-G913-TKL-CLICKY', N'Bàn phím Logitech G913 TKL Lightspeed Wireless Clicky', N'ban-phim-logitech-g913-tkl-lightspeed-wireless-clicky', N'Bàn phím', N'Logitech', 4390000, 3710000, 7, N'Bàn phím Logitech G913 TKL không dây, thiết kế low-profile, kết nối tốc độ cao và switch Clicky cá tính.', N'Logitech G913 TKL Lightspeed Wireless Clicky là mẫu bàn phím cơ low-profile nổi bật với thiết kế mỏng, hiện đại và tối ưu cho góc máy gaming cao cấp. Bàn phím hỗ trợ Wireless 2.4GHz và Bluetooth, phù hợp cho người dùng di chuyển nhiều hoặc thích không gian bàn sạch gọn. Phiên bản Clicky mang lại phản hồi rõ ràng, trong khi hệ thống LED RGB Lightsync tăng thêm trải nghiệm cá nhân hóa.', N'/uploads/products/keyboard/logitech-g913-tkl-lightspeed-wireless-clicky/thumb.jpg', 24, 0),
(N'KB-RAZER-BLACKWIDOW-V4-PRO-GREEN', N'Bàn phím cơ Razer BlackWidow V4 Pro Green Switch', N'ban-phim-co-razer-blackwidow-v4-pro-green-switch', N'Bàn phím', N'Razer', 6190000, 5090000, 6, N'Bàn phím gaming Razer BlackWidow V4 Pro full-size, switch Green, đệm kê tay và RGB Chroma nổi bật.', N'Razer BlackWidow V4 Pro Green Switch là mẫu bàn phím cơ cao cấp dành cho game thủ yêu thích trải nghiệm full-size đầy đủ tính năng. Phiên bản Green switch mang lại cảm giác bấm clicky rõ ràng, phù hợp với người dùng thích phản hồi mạnh tay. Bàn phím dùng kết nối có dây ổn định, keycap Doubleshot ABS bền bỉ, hỗ trợ RGB Chroma và thiết kế nổi bật cho các bộ PC gaming cao cấp.', N'/uploads/products/keyboard/razer-blackwidow-v4-pro-green-switch/thumb.jpg', 24, 0),
(N'KB-RAPOO-V700-A8-DARKGREY-BLUE', N'Bàn phím Rapoo V700-A8 Dark Grey Blue Switch', N'ban-phim-rapoo-v700-a8-dark-grey-blue-switch', N'Bàn phím', N'Rapoo', 1899000, 1090000, 13, N'Bàn phím Rapoo V700-A8 layout 84%, hỗ trợ ba chế độ kết nối và switch Blue phù hợp người thích cảm giác gõ rõ.', N'Rapoo V700-A8 Dark Grey Blue Switch là bàn phím cơ hướng đến người dùng muốn một layout 84% cân bằng giữa gọn gàng và đủ cụm phím cần thiết. Sản phẩm hỗ trợ kết nối có dây, Bluetooth và Wireless 2.4GHz, dễ dàng dùng cho nhiều thiết bị khác nhau. Phiên bản Blue switch cho phản hồi clicky rõ ràng, phù hợp với người dùng thích cảm giác gõ nổi bật và cá tính hơn.', N'/uploads/products/keyboard/rapoo-v700-a8-dark-grey-blue-switch/thumb.jpg', 24, 0),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột Logitech G502 HERO Black', N'chuot-logitech-g502-hero-black', N'Chuột', N'Logitech', 1390000, 1090000, 16, N'Chuột gaming Logitech G502 HERO có dây, cảm biến HERO, 11 nút, RGB và DPI lên đến 25.600.', N'Logitech G502 HERO Black là mẫu chuột gaming có dây nổi tiếng với thiết kế công thái học dành cho tay phải và hệ thống nút bấm phong phú. Cảm biến HERO cho độ chính xác cao, hỗ trợ DPI tối đa 25.600 và phần mềm G HUB giúp tùy biến sâu theo nhu cầu chơi game lẫn làm việc.', N'/uploads/products/mouse/logitech-g502-hero-black/thumb.jpg', 24, 0),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột Logitech G502 X Plus White', N'chuot-logitech-g502-x-plus-white', N'Chuột', N'Logitech', 4290000, 3690000, 10, N'Chuột Logitech G502 X Plus không dây màu trắng, cảm biến HERO 25K, switch Lightforce và pin lâu dài.', N'Logitech G502 X Plus White là mẫu chuột không dây cao cấp với thiết kế công thái học cho tay phải, cảm biến HERO 25K và switch Lightforce hiện đại. Sản phẩm hỗ trợ kết nối 2.4GHz và sạc USB-C, phù hợp cho game thủ cần hiệu năng cao, nhiều nút tùy chỉnh và ngoại hình nổi bật.', N'/uploads/products/mouse/logitech-g502x-plus-white/thumb.jpg', 24, 0),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột ATK PAW3950 Wireless White', N'chuot-atk-paw3950-wireless-white', N'Chuột', N'ATK', 2490000, 2190000, 14, N'Chuột ATK siêu nhẹ đa kết nối, cảm biến Pixart PAW3950, trọng lượng khoảng 49g và pin 75 giờ.', N'ATK PAW3950 Wireless White là mẫu chuột siêu nhẹ hướng đến game thủ FPS cần tốc độ và sự linh hoạt. Cảm biến Pixart PAW3950 hỗ trợ DPI rất cao, form đối xứng dễ làm quen và kết nối đa chế độ giúp sản phẩm phù hợp cả gaming lẫn sử dụng hằng ngày.', N'/uploads/products/mouse/atk-paw3950-wireless-white/thumb.jpg', 12, 0),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột HyperX 26K Wireless White', N'chuot-hyperx-26k-wireless-white', N'Chuột', N'HyperX', 2890000, 2490000, 12, N'Chuột HyperX không dây cảm biến 26K, trọng lượng 59g, RGB và pin đến 100 giờ.', N'HyperX 26K Wireless White là mẫu chuột gaming nhẹ, phù hợp cho người dùng yêu thích form đối xứng và kết nối đa thiết bị. Cảm biến HyperX 26K, switch bền bỉ và thời lượng pin dài giúp sản phẩm đáp ứng tốt cả nhu cầu chơi game nhanh lẫn sử dụng di động.', N'/uploads/products/mouse/hyperx-26k-wireless-white/thumb.jpg', 24, 0),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột Rapoo 26K Wireless White', N'chuot-rapoo-26k-wireless-white', N'Chuột', N'Rapoo', 1990000, 1690000, 13, N'Chuột Rapoo không dây màu trắng, cảm biến PixArt 26K, polling rate 8000Hz và pin rất dài.', N'Rapoo 26K Wireless White là mẫu chuột công thái học hiệu năng cao, nổi bật với polling rate lên tới 8000Hz và cảm biến PixArt 26K. Thiết kế nhẹ, pin bền và kết nối không dây giúp sản phẩm phù hợp cho cả game thủ lẫn người dùng chuyên làm việc cần chuột phản hồi nhanh.', N'/uploads/products/mouse/rapoo-26k-wireless-white/thumb.jpg', 24, 0),
(N'MOU-GLORIOUS-WIRED-BLACK', N'Chuột Glorious Wired Black', N'chuot-glorious-wired-black', N'Chuột', N'Glorious', 1590000, 1390000, 9, N'Chuột Glorious có dây màu đen với form ergonomic, phù hợp gaming và làm việc lâu dài.', N'Glorious Wired Black là mẫu chuột có dây hướng đến trải nghiệm đơn giản, ổn định và dễ làm quen. Form công thái học giúp cầm nắm thoải mái, phù hợp cho người dùng chơi game nhiều giờ hoặc làm việc cần thao tác chính xác liên tục.', N'/uploads/products/mouse/glorious-wired-black/thumb.jpg', 24, 0),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột ASUS ROG AimPoint Pro Wireless Black', N'chuot-asus-rog-aimpoint-pro-wireless-black', N'Chuột', N'ASUS', 3490000, 3090000, 11, N'Chuột ASUS ROG không dây cảm biến AimPoint Pro 42.000 DPI, siêu nhẹ và polling rate tối đa 8000Hz.', N'ASUS ROG AimPoint Pro Wireless Black là mẫu chuột gaming cao cấp với thiết kế công thái học, kết nối linh hoạt và cảm biến quang học độ chính xác cao. Polling rate tối đa 8000Hz cùng switch bền bỉ giúp sản phẩm phù hợp cho game thủ FPS và người dùng cần độ phản hồi nhanh.', N'/uploads/products/mouse/asus-rog-aimpoint-pro-wireless-black/thumb.jpg', 24, 0),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột DareU BRAVO Wireless Black', N'chuot-dareu-bravo-wireless-black', N'Chuột', N'DareU', 690000, 590000, 18, N'Chuột DareU BRAVO đa kết nối, cảm biến BRAVO ATG4090, RGB và kích thước gọn dễ dùng.', N'DareU BRAVO Wireless Black là mẫu chuột giá tốt, thiết kế đối xứng và hỗ trợ đa kết nối linh hoạt. Cảm biến BRAVO (ATG4090), LED RGB cùng phụ kiện đi kèm cơ bản giúp đây là lựa chọn phù hợp cho người dùng phổ thông và gaming nhẹ.', N'/uploads/products/mouse/dareu-bravo-wireless-black/thumb.jpg', 24, 0),
(N'MOU-CORSAIR-WIRELESS-BLACK', N'Chuột Corsair Wireless Black', N'chuot-corsair-wireless-black', N'Chuột', N'Corsair', 2790000, 2390000, 8, N'Chuột Corsair không dây màu đen, form thuận tay phải và dùng pin sạc Li-ion.', N'Corsair Wireless Black là mẫu chuột không dây mang thiết kế công thái học cho tay phải, phù hợp cả chơi game lẫn sử dụng hằng ngày. Dữ liệu gốc cung cấp các thông tin chính về form, kết nối và loại pin, đủ để dùng làm seed data cho danh mục chuột không dây.', N'/uploads/products/mouse/corsair-wireless-black/thumb.jpg', 24, 0),
(N'MOU-RAZER-WIRELESS-BLACK', N'Chuột Razer Wireless Black', N'chuot-razer-wireless-black', N'Chuột', N'Razer', 2990000, 2690000, 9, N'Chuột Razer màu đen thiết kế ergonomic, đa kết nối và sử dụng pin sạc Li-ion.', N'Razer Wireless Black là mẫu chuột được xây dựng cho người dùng ưa thiết kế công thái học và khả năng kết nối linh hoạt. Đây là sản phẩm phù hợp để mở rộng seed data cho danh mục gaming gear, với các thông tin cơ bản về form, màu sắc và nguồn pin sạc.', N'/uploads/products/mouse/razer-wireless-black/thumb.jpg', 24, 0),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'Tai nghe ASUS ROG Pelta WL RGB Black', N'tai-nghe-asus-rog-pelta-wl-rgb-black', N'Tai nghe', N'ASUS', 4570000, 3190000, 12, N'Tai nghe gaming ASUS ROG Pelta không dây, driver titanium 50mm, RGB và pin lên đến 70 giờ.', N'ASUS ROG Pelta WL RGB Black là mẫu tai nghe gaming cao cấp với thiết kế over-ear, kết nối linh hoạt và hệ thống đèn Aura Sync. Driver titanium 50mm, trọng lượng nhẹ khoảng 309g và pin dài đến 70 giờ khiến đây là lựa chọn đáng chú ý cho game thủ chơi trên PC và nhiều nền tảng.', N'/uploads/products/headset/asus-rog-pelta-wl-rgb-black/thumb.jpg', 24, 0),
(N'HS-EDIFIER-W830NB-BLACK', N'Tai nghe Edifier W830NB Black', N'tai-nghe-edifier-w830nb-black', N'Tai nghe', N'Edifier', 1690000, 1490000, 20, N'Tai nghe Edifier W830NB không dây màu đen, kiểu over-ear và sạc Type-C tiện dụng.', N'Edifier W830NB Black là mẫu tai nghe không dây over-ear có thiết kế hiện đại, phù hợp nghe nhạc, làm việc và sử dụng di động. Sản phẩm hỗ trợ Bluetooth, dùng cổng sạc Type-C và phù hợp cho người dùng cần một chiếc tai nghe gọn gàng trong phân khúc dễ tiếp cận.', N'/uploads/products/headset/edifier-w830nb-black/thumb.jpg', 24, 0),
(N'HS-LOGITECH-G435-LIGHTSPEED-WHITE', N'Tai nghe Logitech G435 Lightspeed Wireless White', N'tai-nghe-logitech-g435-lightspeed-wireless-white', N'Tai nghe', N'Logitech', 2000000, 1390000, 18, N'Tai nghe Logitech G435 không dây màu trắng, hỗ trợ Lightspeed/Bluetooth và thiết kế nhẹ đeo thoải mái.', N'Logitech G435 Lightspeed Wireless White là mẫu tai nghe gaming không dây nổi bật với thiết kế trẻ trung, trọng lượng nhẹ và khả năng kết nối linh hoạt. Sản phẩm phù hợp cho người dùng PC, laptop và thiết bị di động cần một chiếc headset chơi game lẫn giải trí hằng ngày.', N'/uploads/products/headset/logitech-g435-lightspeed-wireless-white/thumb.jpg', 24, 0),
(N'HS-RAPOO-VH600', N'Tai nghe Rapoo Gaming VH600', N'tai-nghe-rapoo-gaming-vh600', N'Tai nghe', N'Rapoo', 1390000, 890000, 15, N'Tai nghe Rapoo VH600 có dây qua USB, thiết kế over-ear phù hợp gaming và giải trí cơ bản.', N'Rapoo Gaming VH600 là tai nghe gaming có dây dùng cổng USB, thiết kế over-ear cho cảm giác đeo ổn định và cách âm tốt hơn. Đây là lựa chọn phù hợp cho người dùng cần một chiếc headset dễ dùng, mức giá hợp lý và tương thích tốt với hệ thống PC chơi game.', N'/uploads/products/headset/rapoo-gaming-vh600/thumb.jpg', 24, 0),
(N'HS-ONIKUMA-B5-TRIMODE-WHITE', N'Tai nghe Onikuma Tai Mèo B5 RGB Tri Mode Trắng', N'tai-nghe-onikuma-tai-meo-b5-rgb-tri-mode-trang', N'Tai nghe', N'Onikuma', 1190000, 990000, 17, N'Tai nghe Onikuma B5 phong cách tai mèo, RGB, hỗ trợ kết nối Bluetooth/có dây và thiết kế over-ear.', N'Onikuma Tai Mèo B5 RGB Tri Mode Trắng là mẫu tai nghe nổi bật với ngoại hình dễ thương và đèn RGB bắt mắt. Sản phẩm hỗ trợ nhiều kiểu kết nối và phù hợp cho người dùng thích phong cách setup trẻ trung, giải trí và gaming cơ bản.', N'/uploads/products/headset/onikuma-b5-tri-mode-white/thumb.jpg', 24, 0),
(N'HS-RAZER-BLACKSHARK-V3PRO-CS2', N'Tai nghe Razer Blackshark V3 Pro Counter-Strike 2 Edition', N'tai-nghe-razer-blackshark-v3-pro-counter-strike-2-edition', N'Tai nghe', N'Razer', 8290000, NULL, 8, N'Tai nghe Razer Blackshark V3 Pro bản Counter-Strike 2 Edition, kiểu over-ear và dùng kết nối qua USB-A.', N'Razer Blackshark V3 Pro Counter-Strike 2 Edition là mẫu tai nghe gaming phiên bản đặc biệt, hướng đến game thủ yêu thích thiết kế đậm chất esports. Dữ liệu ảnh cho thấy sản phẩm dùng cổng USB-A và tích hợp công nghệ micro HyperClear Super Wideband, phù hợp để làm seed data cho nhóm headset cao cấp.', N'/uploads/products/headset/razer-blackshark-v3-pro-cs2-edition/thumb.jpg', 24, 0),
(N'HS-CORSAIR-VIRTUOSO-SE-ESPRESSO', N'Tai nghe Corsair Virtuoso RGB Wireless SE Espresso', N'tai-nghe-corsair-virtuoso-rgb-wireless-se-espresso', N'Tai nghe', N'Corsair', 5600000, 5490000, 10, N'Tai nghe Corsair Virtuoso RGB Wireless SE màu Espresso, đa kết nối và thiết kế over-ear cao cấp.', N'Corsair Virtuoso RGB Wireless SE Espresso là tai nghe over-ear cao cấp với thiết kế sang trọng và kết nối rất linh hoạt. Sản phẩm hỗ trợ 2.4GHz, Bluetooth và USB, phù hợp cho người dùng cần một chiếc headset phục vụ đồng thời gaming, giải trí và làm việc.', N'/uploads/products/headset/corsair-virtuoso-rgb-wireless-se-espresso/thumb.jpg', 24, 0),
(N'HS-HYPERX-CLOUD-STINGER-CORE-II', N'Tai nghe HyperX Cloud Stinger Core II', N'tai-nghe-hyperx-cloud-stinger-core-ii', N'Tai nghe', N'HyperX', 990000, 790000, 22, N'Tai nghe HyperX Cloud Stinger Core II có dây, kết nối 3.5mm và thiết kế over-ear dễ dùng.', N'HyperX Cloud Stinger Core II là mẫu tai nghe có dây phù hợp cho nhu cầu gaming phổ thông, học tập và giải trí. Kết nối 3.5mm đơn giản, form over-ear thoải mái và thương hiệu HyperX quen thuộc giúp sản phẩm dễ tiếp cận với nhiều người dùng.', N'/uploads/products/headset/hyperx-cloud-stinger-core-ii/thumb.jpg', 24, 0),
(N'NET-ASUS-RT-AC1500UHP', N'Bộ định tuyến WiFi 5 ASUS RT-AC1500UHP Chuẩn AC1500 (Xuyên tường)', N'bo-dinh-tuyen-wifi-5-asus-rt-ac1500uhp-chuan-ac1500-xuyen-tuong', N'Thiết bị mạng', N'ASUS', 1990000, 1690000, 18, N'Router ASUS RT-AC1500UHP chuẩn WiFi 5 AC1500, 4 anten, tối ưu cho game và phủ sóng ổn định.', N'ASUS RT-AC1500UHP là bộ định tuyến WiFi 5 hướng đến nhu cầu dùng mạng gia đình và văn phòng nhỏ. Sản phẩm hỗ trợ chuẩn 802.11ac tốc độ tối đa 1500Mbps, MU-MIMO và các tính năng tối ưu cho game. Thiết kế nhiều anten giúp tăng khả năng phủ sóng, phù hợp cho người dùng cần một router xuyên tường ổn định trong tầm giá tốt.', N'/uploads/products/network/asus-rt-ac1500uhp/thumb.jpg', 36, 0),
(N'NET-ASUS-XT8-W2PK', N'Thiết bị định tuyến mạng không dây Asus XT8 (W-2-PK)', N'thiet-bi-dinh-tuyen-mang-khong-day-asus-xt8-w-2-pk', N'Thiết bị mạng', N'ASUS', 13990000, 10990000, 7, N'Hệ thống mesh WiFi 6 ASUS XT8 2 pack, tốc độ đến 6000Mbps, phủ sóng rộng và quản lý dễ qua app.', N'ASUS XT8 (W-2-PK) là bộ mesh WiFi cao cấp dành cho nhà nhiều tầng, căn hộ lớn hoặc không gian cần độ phủ sóng mạnh và liền mạch. Sản phẩm hỗ trợ chuẩn WiFi 6 với tốc độ tối đa 6000Mbps, quản lý bằng ứng dụng và hỗ trợ tối đa khoảng 60 thiết bị. Đây là lựa chọn phù hợp cho người dùng cần mạng ổn định cho học tập, làm việc, xem phim 4K và gaming trong toàn bộ ngôi nhà.', N'/uploads/products/network/asus-xt8-w-2-pk/thumb.jpg', 36, 0),
(N'NET-ASUS-RT-AX92U-2PACK', N'Thiết bị mạng AiMesh AX6100 WiFi System (RT-AX92U 2 Pack)', N'thiet-bi-mang-aimesh-ax6100-wifi-system-rt-ax92u-2-pack', N'Thiết bị mạng', N'ASUS', 15990000, 13990000, 6, N'Hệ thống WiFi ASUS AiMesh AX6100 gồm 2 thiết bị, hướng đến gaming và mạng gia đình hiệu năng cao.', N'ASUS RT-AX92U 2 Pack là hệ thống AiMesh WiFi System thuộc phân khúc cao cấp, phù hợp cho người dùng cần vùng phủ lớn và độ ổn định cao. Chuẩn AX6100 giúp hệ thống đáp ứng tốt cho gaming, streaming và dùng nhiều thiết bị cùng lúc. Thiết kế 2 pack hỗ trợ mở rộng vùng phủ sóng linh hoạt trong nhà ở hoặc văn phòng hiện đại.', N'/uploads/products/network/asus-rt-ax92u-2-pack/thumb.jpg', 36, 0),
(N'NET-ASUS-RT-AC1300UHP', N'Thiết bị mạng không dây ASUS RT-AC1300UHP', N'thiet-bi-mang-khong-day-asus-rt-ac1300uhp', N'Thiết bị mạng', N'ASUS', 2190000, 1790000, 16, N'Router ASUS RT-AC1300UHP chuẩn AC1300, MU-MIMO, tối ưu cho game và bảo mật mạng gia đình.', N'ASUS RT-AC1300UHP là router không dây dành cho nhu cầu sử dụng hằng ngày với điểm mạnh ở độ ổn định, phủ sóng tốt và giá hợp lý. Sản phẩm hỗ trợ MU-MIMO, bộ xử lý bốn nhân và các tính năng bảo mật đến từ Trend Micro. Đây là mẫu router phù hợp cho gia đình, phòng trọ cao cấp hoặc văn phòng nhỏ cần mạng 2 băng tần ổn định.', N'/uploads/products/network/asus-rt-ac1300uhp/thumb.jpg', 36, 0),
(N'NET-ASUS-RT-AC59U-AC1500', N'Bộ định tuyến ASUS RT-AC59U Mobile Gaming AC1500 MU-MIMO 2 băng tần', N'bo-dinh-tuyen-asus-rt-ac59u-mobile-gaming-ac1500-mu-mimo-2-bang-tan', N'Thiết bị mạng', N'ASUS', 1950000, 949000, 20, N'Router ASUS RT-AC59U AC1500 2 băng tần, hỗ trợ MU-MIMO và tối ưu cho nhu cầu mobile gaming.', N'ASUS RT-AC59U là mẫu router 2 băng tần hướng đến người dùng cần một thiết bị mạng giá tốt nhưng vẫn đủ ổn định cho học tập, làm việc và chơi game trên di động. Chuẩn AC1500 cùng công nghệ MU-MIMO giúp chia tải tốt hơn khi có nhiều thiết bị truy cập. Sản phẩm phù hợp cho căn hộ nhỏ, phòng riêng hoặc người dùng cần bộ định tuyến dễ thiết lập và sử dụng.', N'/uploads/products/network/asus-rt-ac59u-mobile-gaming-ac1500/thumb.jpg', 36, 0),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'Phần mềm Microsoft Windows 11 Home ESD KW9-00664', N'phan-mem-microsoft-windows-11-home-esd-kw9-00664', N'Phần mềm', N'Microsoft', 3690000, 3190000, 120, N'Bản quyền điện tử Windows 11 Home 32-bit/64-bit, ngôn ngữ đa dạng và kích hoạt linh hoạt.', N'Microsoft Windows 11 Home ESD KW9-00664 là bản quyền điện tử dành cho người dùng cá nhân cần hệ điều hành chính hãng cho PC hoặc laptop. Phiên bản hỗ trợ cả 32-bit và 64-bit, đa ngôn ngữ và có thể kích hoạt lại khi thay đổi phần cứng theo thông tin từ ảnh sản phẩm. Đây là lựa chọn phù hợp cho máy gia đình, học tập và làm việc phổ thông.', N'/uploads/products/software/windows-11-home-esd-kw9-00664/thumb.jpg', 0, 0),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'Phần mềm Microsoft Windows 11 Pro ESD FQC-10572', N'phan-mem-microsoft-windows-11-pro-esd-fqc-10572', N'Phần mềm', N'Microsoft', 5590000, 4850000, 90, N'Bản quyền điện tử Windows 11 Pro dành cho người dùng chuyên nghiệp, hỗ trợ 32-bit/64-bit.', N'Microsoft Windows 11 Pro ESD FQC-10572 là bản quyền điện tử phù hợp cho doanh nghiệp nhỏ, người dùng chuyên nghiệp và máy tính làm việc cần nhiều tính năng quản trị hơn bản Home. Sản phẩm hỗ trợ cả 32-bit và 64-bit, đa ngôn ngữ và có thể kích hoạt lại khi thay đổi phần cứng theo mô tả từ ảnh sản phẩm. Đây là phiên bản phù hợp cho môi trường làm việc cần độ tin cậy và tính chính hãng lâu dài.', N'/uploads/products/software/windows-11-pro-esd-fqc-10572/thumb.jpg', 0, 0),
(N'SW-MICROSOFT-OFFICEHOME2024-EP206796', N'Phần mềm Microsoft Office Home 2024 EP2-06796', N'phan-mem-microsoft-office-home-2024-ep2-06796', N'Phần mềm', N'Microsoft', 3590000, 2990000, 80, N'Bản quyền Office Home 2024 cho nhu cầu học tập và làm việc văn phòng cơ bản.', N'Microsoft Office Home 2024 EP2-06796 là gói phần mềm văn phòng bản quyền phù hợp cho người dùng cá nhân, học sinh sinh viên và hộ gia đình. Sản phẩm là key điện tử, được thiết kế cho các tác vụ văn phòng cơ bản và không thể hoàn lại sau khi mua theo thông tin từ ảnh sản phẩm. Đây là lựa chọn phù hợp để sử dụng Word, Excel và các công cụ Office quen thuộc trong thời gian dài.', N'/uploads/products/software/office-home-2024-ep2-06796/thumb.jpg', 0, 0),
(N'SW-MICROSOFT-365PERSONAL-EP232313', N'Phần mềm Microsoft 365 Personal 1 năm EP2-32313', N'phan-mem-microsoft-365-personal-1-nam-ep2-32313', N'Phần mềm', N'Microsoft', 2090000, 1690000, 140, N'Gói Microsoft 365 Personal 1 năm cho 1 người dùng, tối đa 5 thiết bị và tích hợp AI Copilot.', N'Microsoft 365 Personal EP2-32313 là gói thuê bao bản quyền phù hợp cho người dùng cá nhân cần sử dụng bộ Office luôn cập nhật. Sản phẩm có thời hạn 1 năm, dùng cho 1 tài khoản với tối đa 5 thiết bị và tích hợp AI Copilot theo thông tin hiển thị trên ảnh. Đây là lựa chọn phù hợp cho học tập, làm việc từ xa và sử dụng Office đa nền tảng cùng OneDrive/đám mây của Microsoft.', N'/uploads/products/software/microsoft-365-personal-ep2-32313/thumb.jpg', 0, 0),
(N'SW-MICROSOFT-365FAMILY-EP236890', N'Phần mềm Microsoft 365 Family 1 năm EP2-36890', N'phan-mem-microsoft-365-family-1-nam-ep2-36890', N'Phần mềm', N'Microsoft', 2590000, 1990000, 95, N'Gói Microsoft 365 Family 1 năm cho tối đa 6 người dùng, 30 thiết bị và có AI Copilot.', N'Microsoft 365 Family EP2-36890 là gói bản quyền thuê bao dành cho gia đình hoặc nhóm người dùng cần chia sẻ quyền sử dụng Office. Gói có thời hạn 1 năm, hỗ trợ tối đa 6 người dùng với tổng cộng 30 thiết bị và tích hợp AI Copilot theo ảnh sản phẩm. Đây là lựa chọn phù hợp cho gia đình, nhóm học tập hoặc hộ kinh doanh nhỏ muốn dùng Office bản quyền linh hoạt và tiết kiệm hơn.', N'/uploads/products/software/microsoft-365-family-ep2-36890/thumb.jpg', 0, 0),
(N'ACC-APPLE-SMARTKEYBOARD-IPAD129-4GEN', N'Apple Smart Keyboard Folio for iPad Pro 12.9 inch (4th generation) - US English', N'apple-smart-keyboard-folio-for-ipad-pro-12-9-inch-4th-generation-us-english', N'Phụ kiện', N'Apple', 6000000, 5700000, 9, N'Bàn phím Apple Smart Keyboard Folio cho iPad Pro 12.9 inch 4th gen, kết nối Smart Connector tiện dụng.', N'Apple Smart Keyboard Folio là phụ kiện bàn phím cao cấp dành cho iPad Pro 12.9 inch thế hệ thứ 4. Sản phẩm sử dụng Smart Connector nên không cần sạc hay ghép nối Bluetooth, đồng thời hoạt động như một lớp cover bảo vệ mỏng nhẹ. Đây là lựa chọn phù hợp cho người dùng iPad cần gõ văn bản nhiều và muốn trải nghiệm gần như laptop trong hệ sinh thái Apple.', N'/uploads/products/accessories/apple-smart-keyboard-folio-ipad-pro-129-4th-gen/thumb.jpg', 12, 0),
(N'ACC-UGREEN-NEXODE-200W-CD271', N'Bộ sạc nhanh GaN Nexode 200W Ugreen CD271 40913', N'bo-sac-nhanh-gan-nexode-200w-ugreen-cd271-40913', N'Phụ kiện', N'Ugreen', 2790000, 1750000, 12, N'Bộ sạc Ugreen Nexode GaN 200W hỗ trợ sạc đồng thời nhiều thiết bị, phù hợp laptop và hệ di động.', N'Ugreen Nexode CD271 40913 là bộ sạc nhanh GaN công suất lớn dành cho người dùng có nhiều thiết bị cần sạc cùng lúc. Tổng công suất 200W cho phép sạc laptop, tablet và điện thoại trong một bộ sạc gọn gàng, tiết kiệm không gian ổ cắm. Công nghệ GaN II cùng cơ chế sạc thông minh giúp tăng hiệu suất và nâng cao độ an toàn khi sử dụng lâu dài.', N'/uploads/products/accessories/ugreen-nexode-200w-cd271-40913/thumb.jpg', 18, 0),
(N'ACC-UGREEN-HUB-5IN1-CM136', N'Cổng chuyển đổi USB C Ugreen 5 in 1 CM136 50209', N'cong-chuyen-doi-usb-c-ugreen-5-in-1-cm136-50209', N'Phụ kiện', N'Ugreen', 890000, 690000, 24, N'Hub Ugreen 5 trong 1 qua USB-C, hỗ trợ HDMI 4K, USB 3.0 và sạc PD tiện cho laptop mỏng nhẹ.', N'Ugreen CM136 50209 là hub mở rộng cổng kết nối dành cho laptop, tablet hoặc điện thoại có USB-C. Sản phẩm cung cấp 3 cổng USB 3.0, 1 cổng HDMI và 1 cổng USB-C hỗ trợ PD, rất phù hợp để trình chiếu, dùng chuột/USB và sạc cùng lúc. Thiết kế nhỏ gọn, chất liệu kim loại cùng khả năng xuất hình 4K 30Hz giúp đây là phụ kiện hữu ích cho học tập, làm việc và di chuyển.', N'/uploads/products/accessories/ugreen-usb-c-hub-5-in-1-cm136-50209/thumb.jpg', 18, 0),
(N'ACC-UGREEN-GAN-100W-CD226', N'Củ sạc Ugreen GaN 100W CD226 40747', N'cu-sac-ugreen-gan-100w-cd226-40747', N'Phụ kiện', N'Ugreen', 1260000, 990000, 18, N'Củ sạc Ugreen GaN 100W nhỏ gọn, hỗ trợ nhiều cổng sạc cho laptop, tablet và điện thoại.', N'Ugreen GaN 100W CD226 40747 là củ sạc nhanh công suất cao dành cho người dùng cần một giải pháp sạc gọn gàng khi đi làm hoặc đi công tác. Sản phẩm hỗ trợ nhiều cổng đầu ra, phù hợp cho laptop, tablet và điện thoại hiện đại. Công nghệ GaN giúp giảm kích thước bộ sạc nhưng vẫn duy trì hiệu suất tốt và an toàn khi sử dụng.', N'/uploads/products/accessories/ugreen-gan-100w-cd226-40747/thumb.jpg', 18, 0),
(N'ACC-MAZER-USBC-VGA-MUSBCAL351', N'Bộ chuyển đổi Mazer ALU USB-C to VGA 1080P Adapter M-USBCAL351-GY', N'bo-chuyen-doi-mazer-alu-usb-c-to-vga-1080p-adapter-m-usbcal351-gy', N'Phụ kiện', N'Mazer', 520000, 190000, 30, N'Adapter Mazer chuyển từ USB-C sang VGA, hỗ trợ xuất hình 1080P cho máy chiếu và màn hình cũ.', N'Mazer ALU USB-C to VGA Adapter M-USBCAL351-GY là phụ kiện chuyển đổi nhỏ gọn dành cho laptop hoặc tablet có cổng USB-C. Sản phẩm hỗ trợ xuất tín hiệu VGA độ phân giải 1080P, phù hợp cho phòng họp, lớp học hoặc hệ thống trình chiếu dùng màn hình đời cũ. Thiết kế dạng nhôm và dây ngắn giúp adapter bền bỉ, dễ mang theo và phù hợp dùng hằng ngày.', N'/uploads/products/accessories/mazer-alu-usb-c-to-vga-1080p-adapter-m-usbcal351-gy/thumb.jpg', 24, 0),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop gaming ASUS TUF F16 FX608JMR RV048W', N'laptop-gaming-asus-tuf-f16-fx608jmr-rv048w', N'Laptop', N'ASUS', 40990000, 37990000, 8, N'Laptop gaming ASUS TUF F16, Core i7-14650HX, RTX 5060 8GB, RAM 16GB DDR5, SSD 1TB, màn 16 inch 165Hz.', N'ASUS TUF Gaming F16 FX608JMR RV048W là mẫu laptop gaming hiệu năng cao với Intel Core i7-14650HX, RTX 5060, RAM DDR5 và SSD tốc độ cao, phù hợp game thủ lẫn sáng tạo nội dung.', N'/uploads/products/laptop/asus-tuf-gaming-f16-fx608jmr-rv048w/thumb.jpg', 24, 0),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'Laptop gaming Lenovo Legion Pro 7 16IAX10H 83F500JGVN', N'laptop-gaming-lenovo-legion-pro-7-16iax10h-83f500jgvn', N'Laptop', N'Lenovo', 87990000, 83990000, 4, N'Laptop gaming Lenovo Legion Pro 7, Core Ultra 9-275HX, RTX 5070 Ti 12GB, RAM 32GB, SSD 1TB, màn 16 inch.', N'Lenovo Legion Pro 7 16IAX10H 83F500JGVN là laptop gaming flagship với Intel Core Ultra 9, RTX 5070 Ti, RAM DDR5 dung lượng lớn và khả năng mở rộng SSD linh hoạt cho game thủ chuyên nghiệp.', N'/uploads/products/laptop/lenovo-legion-pro-7-16iax10h-83f500jgvn/thumb.jpg', 24, 0),
(N'LAP-GIGABYTE-A16-CMHI2VN893SH', N'Laptop gaming Gigabyte A16 CMHI2VN893SH', N'laptop-gaming-gigabyte-a16-cmhi2vn893sh', N'Laptop', N'GIGABYTE', 27490000, NULL, 10, N'Laptop Gigabyte A16, Core i7-13620H, RTX 4050 6GB, RAM 16GB DDR5, SSD 512GB, màn 16 inch.', N'Gigabyte A16 CMHI2VN893SH là lựa chọn cân bằng cho game thủ và người dùng đa nhiệm với Intel Core i7-13620H, RTX 4050 6GB, SSD NVMe cùng màn hình lớn 16 inch.', N'/uploads/products/laptop/gigabyte-a16-cmhi2vn893sh/thumb.jpg', 24, 0),
(N'LAP-LG-GRAM-17ZD90Q-GAX52A5', N'Laptop LG Gram 2022 17ZD90Q-G.AX52A5', N'laptop-lg-gram-2022-17zd90q-g-ax52a5', N'Laptop', N'LG', 40990000, 18990000, 5, N'Laptop LG Gram 17, Core i5-1240P, Iris Xe, RAM 16GB, SSD 512GB, màn hình 17 inch.', N'LG Gram 2022 17ZD90Q-G.AX52A5 hướng đến người dùng văn phòng và di động cần màn hình lớn, thiết kế mỏng nhẹ, cấu hình ổn định và thời lượng pin tốt.', N'/uploads/products/laptop/lg-gram-2022-17zd90q-g-ax52a5/thumb.jpg', 12, 0),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'Laptop HP Envy 13 BA1534TU 4U6M3PA', N'laptop-hp-envy-13-ba1534tu-4u6m3pa', N'Laptop', N'HP', 32490000, NULL, 6, N'Laptop HP Envy 13, Core i7-1165G7, Iris Xe, RAM 16GB DDR4, SSD 1TB, màn 13.3 inch FHD.', N'HP Envy 13 BA1534TU 4U6M3PA là mẫu ultrabook cao cấp cho nhu cầu văn phòng, học tập và di chuyển thường xuyên với thiết kế gọn nhẹ và cấu hình ổn định.', N'/uploads/products/laptop/hp-envy-13-ba1534tu-4u6m3pa/thumb.jpg', 12, 0),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'Laptop Dell 15 DC15250 i7U161W11SLU', N'laptop-dell-15-dc15250-i7u161w11slu', N'Laptop', N'Dell', 23490000, 20990000, 11, N'Laptop Dell 15, Core i7-1355U, RAM 16GB DDR4, SSD 1TB, màn 15.6 inch, phù hợp văn phòng và học tập.', N'Dell 15 DC15250 i7U161W11SLU phù hợp cho người dùng cần một mẫu laptop văn phòng cấu hình mạnh với RAM lớn, SSD 1TB, màn hình 15.6 inch và khả năng nâng cấp tốt.', N'/uploads/products/laptop/dell-15-dc15250-i7u161w11slu/thumb.jpg', 12, 0),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'Laptop Lenovo ThinkPad X9-15 Gen 1 21Q60055VN', N'laptop-lenovo-thinkpad-x9-15-gen-1-21q60055vn', N'Laptop', N'Lenovo', 55129000, 49990000, 5, N'Laptop Lenovo ThinkPad X9-15 Gen 1, Core Ultra 7 258V, Intel Arc 140V, RAM 32GB, SSD 1TB, màn 15.6 inch.', N'ThinkPad X9-15 Gen 1 21Q60055VN là mẫu laptop doanh nhân cao cấp với Intel Core Ultra 7, RAM LPDDR5x 32GB, SSD 1TB và thiết kế mỏng nhẹ cho công việc chuyên nghiệp.', N'/uploads/products/laptop/lenovo-thinkpad-x9-15-gen-1-21q60055vn/thumb.jpg', 36, 0),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'Laptop MSI Prestige 16 AI+ Mercedes AMG B2VMG 088VN', N'laptop-msi-prestige-16-ai-mercedes-amg-b2vmg-088vn', N'Laptop', N'MSI', 49990000, 47990000, 4, N'Laptop MSI Prestige 16 AI+, Core Ultra 9 288V, Intel Arc, RAM 32GB, SSD 2TB, màn 16 inch.', N'MSI Prestige 16 AI+ Mercedes AMG B2VMG 088VN là laptop cao cấp thiên về di động và sáng tạo nội dung với Intel Core Ultra 9, RAM lớn, SSD 2TB và thiết kế hợp tác Mercedes-AMG sang trọng.', N'/uploads/products/laptop/msi-prestige-16-ai-mercedes-amg-b2vmg-088vn/thumb.jpg', 24, 0),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'Laptop Acer Swift Go SFG14 74T 55HD', N'laptop-acer-swift-go-sfg14-74t-55hd', N'Laptop', N'Acer', 32490000, 31490000, 9, N'Laptop Acer Swift Go 14, Core Ultra 5 225H, Intel Arc 130T, RAM 16GB, SSD 1TB, màn 14 inch.', N'Acer Swift Go SFG14 74T 55HD là mẫu laptop mỏng nhẹ dành cho học tập và làm việc hiện đại với Intel Core Ultra 5, GPU Intel Arc và SSD 1TB tốc độ cao.', N'/uploads/products/laptop/acer-swift-go-sfg14-74t-55hd/thumb.jpg', 24, 0),
(N'LAP-ASUS-ZENBOOK14-UM3406KA-PP555WS', N'Laptop ASUS Zenbook 14 UM3406KA PP555WS', N'laptop-asus-zenbook-14-um3406ka-pp555ws', N'Laptop', N'ASUS', 31990000, NULL, 7, N'Laptop ASUS Zenbook 14, Ryzen AI 7 350, AMD Radeon, RAM 16GB, SSD 512GB, màn 14 inch.', N'ASUS Zenbook 14 UM3406KA PP555WS là laptop mỏng nhẹ cao cấp hướng đến người dùng văn phòng và sáng tạo với vi xử lý AMD Ryzen AI, thiết kế gọn nhẹ và trải nghiệm di động linh hoạt.', N'/uploads/products/laptop/asus-zenbook-14-um3406ka-pp555ws/thumb.jpg', 24, 0),
(N'SPK-LOGITECH-G560', N'Loa Logitech G560', N'loa-logitech-g560', N'Loa', N'Logitech', 4890000, 4250000, 10, N'Loa vi tính Logitech G560 với Bluetooth 4.1, LED RGB đồng bộ và khả năng chỉnh Bass/Treble tiện cho chơi game, giải trí.', N'Logitech G560 là bộ loa 2.1 dành cho người dùng PC muốn nâng cấp trải nghiệm âm thanh lẫn hiệu ứng ánh sáng trên bàn máy. Sản phẩm hỗ trợ Bluetooth 4.1, LED RGB và cho phép tinh chỉnh âm sắc để phù hợp nhu cầu chơi game, xem phim hoặc nghe nhạc hằng ngày. Đây là lựa chọn hợp lý cho góc máy gaming hoặc desktop giải trí tại nhà.', N'/uploads/products/speaker/logitech-g560/thumb.jpg', 12, 0),
(N'SPK-RAZER-NOMMO-V2', N'Loa Razer Nommo V2', N'loa-razer-nommo-v2', N'Loa', N'Razer', 6990000, 6100000, 8, N'Loa Razer Nommo V2 hỗ trợ Bluetooth 5.3, THX Spatial Audio, LED RGB và độ chi tiết âm thanh tốt cho gaming cao cấp.', N'Razer Nommo V2 là bộ loa gaming hướng đến người dùng cần âm thanh mạnh, rõ và dễ đồng bộ với hệ sinh thái Razer. Bluetooth 5.3 cùng công nghệ THX Spatial Audio giúp tăng cảm giác không gian khi chơi game, xem phim hoặc nghe nhạc. Thiết kế hiện đại, màu đen và hiệu ứng RGB khiến sản phẩm phù hợp cho các bộ bàn máy cao cấp.', N'/uploads/products/speaker/razer-nommo-v2/thumb.jpg', 12, 0),
(N'SPK-THONETVANDER-KUMPEL20-BLACK', N'Loa Thonet & Vander Kumpel 2.0 Black', N'loa-thonet-vander-kumpel-2-0-black', N'Loa', N'Thonet & Vander', 2990000, NULL, 14, N'Loa Thonet & Vander Kumpel 2.0 Black hỗ trợ Bluetooth 5.0, chỉnh Bass/Treble và phù hợp không gian làm việc, giải trí gọn gàng.', N'Thonet & Vander Kumpel 2.0 Black là mẫu loa desktop thiết kế gọn, nhấn mạnh sự cân bằng giữa thẩm mỹ và chất âm sử dụng hằng ngày. Sản phẩm hỗ trợ Bluetooth 5.0, có chỉnh Bass/Treble và giữ phong cách màu Black phù hợp nhiều góc làm việc hoặc giải trí. Đây là lựa chọn đáng cân nhắc cho người dùng thích bộ loa 2.0 đơn giản nhưng vẫn có cá tính riêng.', N'/uploads/products/speaker/thonet-vander-kumpel-2-0-black/thumb.jpg', 12, 0),
(N'SPK-RAZER-LEVIATHAN-V2X', N'Loa Razer Leviathan V2 X', N'loa-razer-leviathan-v2-x', N'Loa', N'Razer', 3990000, 2490000, 12, N'Soundbar Razer Leviathan V2 X nhỏ gọn, THX Spatial Audio, Bluetooth 5.0 và LED RGB, phù hợp cho bàn máy gọn.', N'Razer Leviathan V2 X là mẫu soundbar dành cho game thủ cần thiết kế gọn gàng nhưng vẫn có chất âm mạnh và hiện đại. Bluetooth 5.0, THX Spatial Audio và LED RGB giúp sản phẩm nổi bật trên các góc máy setup tối giản hoặc gaming. Đây là lựa chọn phù hợp cho người dùng ưu tiên tiết kiệm không gian mà vẫn muốn trải nghiệm âm thanh sinh động.', N'/uploads/products/speaker/razer-leviathan-v2-x/thumb.jpg', 12, 0),
(N'SPK-RAZER-LEVIATHAN-V2', N'Loa Razer Leviathan V2', N'loa-razer-leviathan-v2', N'Loa', N'Razer', 6990000, 5790000, 7, N'Loa soundbar Razer Leviathan V2 có Bluetooth 5.2, THX Spatial Audio, LED RGB và tinh chỉnh EQ 10 băng tần qua Synapse.', N'Razer Leviathan V2 là soundbar gaming cao cấp dành cho người dùng cần âm thanh mạnh, hiện đại và dễ tinh chỉnh theo sở thích. Công nghệ THX Spatial Audio, Bluetooth 5.2 và LED RGB giúp sản phẩm phù hợp cả chơi game lẫn giải trí đa phương tiện. Tính năng tùy chỉnh EQ 10 băng tần qua Razer Synapse là điểm cộng lớn cho người dùng thích cá nhân hóa trải nghiệm âm thanh.', N'/uploads/products/speaker/razer-leviathan-v2/thumb.jpg', 12, 0),
(N'PCB-GVN-ROG-MIKU-9800X3D-5080', N'PC GVN X ASUS ROG HATSUNE MIKU EDITION (AMD Ryzen 7 9800X3D/VGA RTX 5080)', N'pc-gvn-x-asus-rog-hatsune-miku-edition-amd-ryzen-7-9800x3d-vga-rtx-5080', N'PC bộ', N'GVN', 139640000, 128990000, 2, N'PC bộ GVN bản collab ASUS ROG Hatsune Miku với Ryzen 7 9800X3D, RAM 64GB, SSD 1TB và RTX 5080 16GB.', N'Đây là cấu hình PC bộ cao cấp dành cho game thủ và người dùng đòi hỏi hiệu năng hàng đầu ở độ phân giải 2K/4K. Bộ máy nổi bật nhờ thiết kế collab ASUS ROG Hatsune Miku cùng Ryzen 7 9800X3D, mainboard X870E, RAM 64GB và card RTX 5080 16GB. Sản phẩm phù hợp cho gaming cao cấp, stream, sáng tạo nội dung và trưng bày setup độc đáo.', N'/uploads/products/pc-build/gvn-rog-hatsune-miku-9800x3d-rtx5080/thumb.jpg', 36, 0),
(N'PCB-GVN-I7-14700F-RTX3050', N'PC GVN Intel i7-14700F/VGA RTX 3050', N'pc-gvn-intel-i7-14700f-vga-rtx-3050', N'PC bộ', N'GVN', 33120000, 31590000, 6, N'PC bộ GVN dùng Intel Core i7-14700F, RTX 3050 6GB, RAM 16GB và SSD 512GB cho gaming phổ thông lẫn làm việc.', N'PC GVN Intel i7-14700F / RTX 3050 là cấu hình cân bằng cho người dùng cần một bộ máy sẵn sàng để học tập, làm việc và chơi game eSports. CPU Intel Core i7-14700F mang lại hiệu năng đa nhiệm tốt, trong khi RTX 3050 6GB đáp ứng ổn các tựa game online và dựng hình cơ bản. Đây là lựa chọn hợp lý cho người dùng muốn đầu tư một cấu hình desktop ổn định, dễ nâng cấp về sau.', N'/uploads/products/pc-build/gvn-i7-14700f-rtx3050/thumb.jpg', 36, 0),
(N'PCB-GVN-I5-14400F-RTX5060TI', N'PC GVN Intel i5-14400F/VGA RTX 5060 Ti', N'pc-gvn-intel-i5-14400f-vga-rtx-5060-ti', N'PC bộ', N'GVN', 28580000, 25990000, 7, N'PC bộ GVN Intel Core i5-14400F, RTX 5060 Ti 8GB, RAM 8GB và SSD 512GB hướng đến gaming 1080p/2K.', N'Cấu hình này phù hợp cho người dùng ưu tiên chơi game hiện đại ở thiết lập tốt với chi phí hợp lý. Intel Core i5-14400F kết hợp RTX 5060 Ti 8GB mang lại hiệu năng tốt cho gaming, sáng tạo nội dung cơ bản và nhu cầu sử dụng dài hạn. Đây là bộ PC sẵn sàng để nâng cấp RAM hoặc dung lượng lưu trữ khi cần.', N'/uploads/products/pc-build/gvn-i5-14400f-rtx5060ti/thumb.jpg', 36, 0),
(N'PCB-GVN-R5-5600X-RX7600', N'PC GVN AMD R5-5600X/VGA RX 7600', N'pc-gvn-amd-r5-5600x-vga-rx-7600', N'PC bộ', N'GVN', 23320000, 21990000, 9, N'PC bộ GVN Ryzen 5 5600X, Radeon RX 7600 8GB, RAM 8GB và SSD 256GB dành cho gaming phổ thông.', N'PC GVN AMD R5-5600X / RX 7600 là lựa chọn tiết kiệm cho game thủ cần bộ máy desktop có thể chơi tốt nhiều tựa game phổ biến ở độ phân giải Full HD. Ryzen 5 5600X vẫn đáp ứng tốt nhu cầu gaming và làm việc hằng ngày, trong khi RX 7600 8GB phù hợp với các tựa game AAA ở mức thiết lập hợp lý. Bộ máy phù hợp để nâng cấp thêm RAM hoặc SSD để mở rộng hiệu năng sử dụng lâu dài.', N'/uploads/products/pc-build/gvn-r5-5600x-rx7600/thumb.jpg', 36, 0),
(N'PCB-GVN-U5-225F-ARCB580', N'PC GVN Intel Ultra 5 225F/VGA ARC B580 (DDR5)', N'pc-gvn-intel-ultra-5-225f-vga-arc-b580-ddr5', N'PC bộ', N'GVN', 30020000, 28490000, 8, N'PC bộ GVN dùng Intel Core Ultra 5 225F, Intel Arc B580 12GB, RAM 16GB DDR5 và SSD 500GB.', N'Bộ PC này hướng đến người dùng muốn trải nghiệm nền tảng Intel Core Ultra mới cùng card đồ họa Intel Arc B580 12GB. Cấu hình phù hợp cho gaming phổ thông, học tập, làm việc đa nhiệm và các nhu cầu sáng tạo nội dung cơ bản. Việc dùng RAM DDR5 và mainboard B860M giúp hệ thống có nền tảng mới, gọn gàng và dễ đồng bộ cho nhu cầu nâng cấp sau này.', N'/uploads/products/pc-build/gvn-ultra5-225f-arc-b580-ddr5/thumb.jpg', 36, 0),
(N'PCB-GVN-U7-265F-RTX5080', N'PC GVN Intel Core Ultra 7 265F/VGA RTX 5080', N'pc-gvn-intel-core-ultra-7-265f-vga-rtx-5080', N'PC bộ', N'GVN', 77820000, 76590000, 3, N'PC bộ GVN Core Ultra 7 265F, RTX 5080 16GB, RAM 16GB và SSD 1TB dành cho gaming cao cấp.', N'PC GVN Intel Core Ultra 7 265F / RTX 5080 là cấu hình mạnh hướng đến game thủ và người dùng cần hiệu năng desktop cao cho nhiều tác vụ nặng. Hệ thống sở hữu card RTX 5080 16GB, SSD 1TB và nền tảng mainboard Z890, đáp ứng tốt nhu cầu chơi game 2K/4K, sáng tạo nội dung và làm việc chuyên sâu. Đây là bộ máy phù hợp cho người dùng muốn lên thẳng phân khúc cao cấp ngay từ đầu.', N'/uploads/products/pc-build/gvn-ultra7-265f-rtx5080/thumb.jpg', 36, 0),
(N'PCB-GVN-U7-265F-RTX5070', N'PC GVN Intel Core Ultra 7 265F/VGA RTX 5070', N'pc-gvn-intel-core-ultra-7-265f-vga-rtx-5070', N'PC bộ', N'GVN', 58120000, 57690000, 4, N'PC bộ GVN Core Ultra 7 265F, RTX 5070, RAM 16GB và SSD 512GB cân bằng giữa hiệu năng cao và chi phí.', N'Cấu hình này hướng tới người dùng cần hiệu năng gaming mạnh nhưng vẫn muốn tối ưu ngân sách hơn so với nhóm RTX 5080. Intel Core Ultra 7 265F kết hợp RTX 5070 đủ sức chơi tốt các tựa game hiện đại và xử lý công việc sáng tạo nội dung ở mức rất tốt. Đây là lựa chọn phù hợp cho game thủ muốn hiệu năng cao, nền tảng mới và khả năng nâng cấp lâu dài.', N'/uploads/products/pc-build/gvn-ultra7-265f-rtx5070/thumb.jpg', 36, 0),
(N'PCB-GVN-R7-9800X3D-RTX5080-MSI', N'PC GVN AMD R7-9800X3D/VGA RTX 5080 (Powered by MSI)', N'pc-gvn-amd-r7-9800x3d-vga-rtx-5080-powered-by-msi', N'PC bộ', N'GVN', 90720000, 88880000, 3, N'PC bộ GVN Powered by MSI với Ryzen 7 9800X3D, RTX 5080, RAM 32GB và SSD 1TB cho gaming flagship.', N'PC GVN AMD R7-9800X3D / RTX 5080 Powered by MSI là bộ máy cao cấp tập trung vào hiệu năng gaming hàng đầu và độ ổn định hệ thống. Ryzen 7 9800X3D kết hợp RTX 5080 mang lại sức mạnh phù hợp cho chơi game 2K/4K, stream và sáng tạo nội dung nặng. Đây là lựa chọn nổi bật cho người dùng thích cấu hình mạnh, hệ linh kiện đồng bộ và trải nghiệm desktop cao cấp.', N'/uploads/products/pc-build/gvn-r7-9800x3d-rtx5080-powered-by-msi/thumb.jpg', 36, 0),
(N'PCB-GVN-I7-14700F-RTX5080', N'PC GVN Intel i7-14700F/VGA RTX 5080', N'pc-gvn-intel-i7-14700f-vga-rtx-5080', N'PC bộ', N'GVN', 79420000, 77490000, 3, N'PC bộ GVN Intel Core i7-14700F, RTX 5080, RAM 32GB và SSD 1TB hướng đến gaming, render và đa nhiệm nặng.', N'PC GVN Intel i7-14700F / RTX 5080 phù hợp cho người dùng cần sức mạnh đồ họa rất cao nhưng vẫn ưu tiên CPU Intel quen thuộc cho làm việc và giải trí. Cấu hình gồm 32GB RAM, SSD 1TB và card RTX 5080 đáp ứng tốt nhu cầu chơi game nặng, dựng video, stream và xử lý đa nhiệm. Đây là bộ máy cao cấp phù hợp cho game thủ hoặc người dùng sáng tạo nội dung bán chuyên đến chuyên nghiệp.', N'/uploads/products/pc-build/gvn-i7-14700f-rtx5080/thumb.jpg', 36, 0),
(N'CPU-INTEL-I5-14400F', N'Intel Core i5-14400F', N'cpu-intel-i5-14400f', N'CPU', N'Intel', 4290000, NULL, 0, N'San pham placeholder tu du lieu giao dich de bao toan khoa ngoai.', N'San pham nay duoc tao tu dong vi xuat hien trong Orders/Reviews nhung chua co dong chi tiet trong sheet Products.', NULL, 0, 1);

INSERT INTO #SeedProductSpecifications (ProductSKU, CategoryName, SpecName, ValueText, ValueNumber, ValueBoolean, DisplayValue)
VALUES
(N'CPU-INTEL-CU5-245K', N'CPU', N'Socket', N'LGA 1851', NULL, NULL, N'LGA 1851'),
(N'CPU-INTEL-CU5-245K', N'CPU', N'Số nhân', NULL, 14, NULL, N'14'),
(N'CPU-INTEL-CU5-245K', N'CPU', N'Số luồng', NULL, 14, NULL, N'14'),
(N'CPU-INTEL-CU5-245K', N'CPU', N'Bộ nhớ đệm', NULL, 24, NULL, N'24'),
(N'CPU-INTEL-CU5-245K', N'CPU', N'Xung nhịp tối đa', NULL, 5.2, NULL, N'5.2'),
(N'CPU-INTEL-CU5-245K', N'CPU', N'TDP Max', NULL, 159, NULL, N'159'),
(N'CPU-INTEL-CU5-245K', N'CPU', N'Số nhân P-core', NULL, 6, NULL, N'6'),
(N'CPU-INTEL-CU5-245K', N'CPU', N'Số nhân E-core', NULL, 8, NULL, N'8'),
(N'CPU-INTEL-CU5-245K', N'CPU', N'Tốc độ RAM tối đa', NULL, 6400, NULL, N'6400'),
(N'CPU-INTEL-CU5-245K', N'CPU', N'Có iGPU', NULL, NULL, 1, N'Có'),
(N'CPU-INTEL-CU5-245K', N'CPU', N'Dòng CPU', N'Intel Core Ultra 5', NULL, NULL, N'Intel Core Ultra 5'),
(N'CPU-INTEL-CU7-265K', N'CPU', N'Socket', N'LGA 1851', NULL, NULL, N'LGA 1851'),
(N'CPU-INTEL-CU7-265K', N'CPU', N'Số nhân', NULL, 20, NULL, N'20'),
(N'CPU-INTEL-CU7-265K', N'CPU', N'Số luồng', NULL, 20, NULL, N'20'),
(N'CPU-INTEL-CU7-265K', N'CPU', N'Bộ nhớ đệm', NULL, 30, NULL, N'30'),
(N'CPU-INTEL-CU7-265K', N'CPU', N'Xung nhịp tối đa', NULL, 5.5, NULL, N'5.5'),
(N'CPU-INTEL-CU7-265K', N'CPU', N'TDP Max', NULL, 250, NULL, N'250'),
(N'CPU-INTEL-CU7-265K', N'CPU', N'Số nhân P-core', NULL, 8, NULL, N'8'),
(N'CPU-INTEL-CU7-265K', N'CPU', N'Số nhân E-core', NULL, 12, NULL, N'12'),
(N'CPU-INTEL-CU7-265K', N'CPU', N'Tốc độ RAM tối đa', NULL, 6400, NULL, N'6400'),
(N'CPU-INTEL-CU7-265K', N'CPU', N'Có iGPU', NULL, NULL, 1, N'Có'),
(N'CPU-INTEL-CU7-265K', N'CPU', N'Dòng CPU', N'Intel Core Ultra 7', NULL, NULL, N'Intel Core Ultra 7'),
(N'CPU-INTEL-CU9-285K', N'CPU', N'Socket', N'LGA 1851', NULL, NULL, N'LGA 1851'),
(N'CPU-INTEL-CU9-285K', N'CPU', N'Số nhân', NULL, 24, NULL, N'24'),
(N'CPU-INTEL-CU9-285K', N'CPU', N'Số luồng', NULL, 24, NULL, N'24'),
(N'CPU-INTEL-CU9-285K', N'CPU', N'Bộ nhớ đệm', NULL, 36, NULL, N'36'),
(N'CPU-INTEL-CU9-285K', N'CPU', N'Xung nhịp tối đa', NULL, 5.7, NULL, N'5.7'),
(N'CPU-INTEL-CU9-285K', N'CPU', N'TDP Max', NULL, 250, NULL, N'250'),
(N'CPU-INTEL-CU9-285K', N'CPU', N'Số nhân P-core', NULL, 8, NULL, N'8'),
(N'CPU-INTEL-CU9-285K', N'CPU', N'Số nhân E-core', NULL, 16, NULL, N'16'),
(N'CPU-INTEL-CU9-285K', N'CPU', N'Tốc độ RAM tối đa', NULL, 6400, NULL, N'6400'),
(N'CPU-INTEL-CU9-285K', N'CPU', N'Có iGPU', NULL, NULL, 1, N'Có'),
(N'CPU-INTEL-CU9-285K', N'CPU', N'Dòng CPU', N'Intel Core Ultra 9', NULL, NULL, N'Intel Core Ultra 9'),
(N'CPU-INTEL-I3-14100', N'CPU', N'Socket', N'LGA 1700', NULL, NULL, N'LGA 1700'),
(N'CPU-INTEL-I3-14100', N'CPU', N'Số nhân', NULL, 4, NULL, N'4'),
(N'CPU-INTEL-I3-14100', N'CPU', N'Số luồng', NULL, 8, NULL, N'8'),
(N'CPU-INTEL-I3-14100', N'CPU', N'Bộ nhớ đệm', NULL, 12, NULL, N'12'),
(N'CPU-INTEL-I3-14100', N'CPU', N'Xung nhịp tối đa', NULL, 4.7, NULL, N'4.7'),
(N'CPU-INTEL-I3-14100', N'CPU', N'TDP Max', NULL, 110, NULL, N'110'),
(N'CPU-INTEL-I3-14100', N'CPU', N'Số nhân P-core', NULL, 4, NULL, N'4'),
(N'CPU-INTEL-I3-14100', N'CPU', N'Số nhân E-core', NULL, 0, NULL, N'0'),
(N'CPU-INTEL-I3-14100', N'CPU', N'Tốc độ RAM tối đa', NULL, 4800, NULL, N'4800'),
(N'CPU-INTEL-I3-14100', N'CPU', N'Có iGPU', NULL, NULL, 1, N'Có'),
(N'CPU-INTEL-I3-14100', N'CPU', N'Dòng CPU', N'Intel Core i3', NULL, NULL, N'Intel Core i3'),
(N'CPU-INTEL-I3-14100', N'CPU', N'Thế hệ', N'Intel Gen 14', NULL, NULL, N'Intel Gen 14'),
(N'CPU-AMD-R3-4300G', N'CPU', N'Socket', N'AM4', NULL, NULL, N'AM4'),
(N'CPU-AMD-R3-4300G', N'CPU', N'Số nhân', NULL, 4, NULL, N'4'),
(N'CPU-AMD-R3-4300G', N'CPU', N'Số luồng', NULL, 8, NULL, N'8'),
(N'CPU-AMD-R3-4300G', N'CPU', N'Bộ nhớ đệm', NULL, 6, NULL, N'6'),
(N'CPU-AMD-R3-4300G', N'CPU', N'Xung nhịp cơ bản', NULL, 3.8, NULL, N'3.8'),
(N'CPU-AMD-R3-4300G', N'CPU', N'Xung nhịp tối đa', NULL, 4, NULL, N'4'),
(N'CPU-AMD-R3-4300G', N'CPU', N'Tốc độ RAM tối đa', NULL, 3200, NULL, N'3200'),
(N'CPU-AMD-R3-4300G', N'CPU', N'Có iGPU', NULL, NULL, 1, N'Có'),
(N'CPU-AMD-R3-4300G', N'CPU', N'Dòng CPU', N'AMD Ryzen 3', NULL, NULL, N'AMD Ryzen 3'),
(N'CPU-AMD-R5-7600', N'CPU', N'Socket', N'AM5', NULL, NULL, N'AM5'),
(N'CPU-AMD-R5-7600', N'CPU', N'Số nhân', NULL, 6, NULL, N'6'),
(N'CPU-AMD-R5-7600', N'CPU', N'Số luồng', NULL, 12, NULL, N'12'),
(N'CPU-AMD-R5-7600', N'CPU', N'Bộ nhớ đệm', NULL, 38, NULL, N'38'),
(N'CPU-AMD-R5-7600', N'CPU', N'Xung nhịp cơ bản', NULL, 3.8, NULL, N'3.8'),
(N'CPU-AMD-R5-7600', N'CPU', N'Xung nhịp tối đa', NULL, 5.1, NULL, N'5.1'),
(N'CPU-AMD-R5-7600', N'CPU', N'Tốc độ RAM tối đa', NULL, 5200, NULL, N'5200'),
(N'CPU-AMD-R5-7600', N'CPU', N'Có iGPU', NULL, NULL, 1, N'Có'),
(N'CPU-AMD-R5-7600', N'CPU', N'Dòng CPU', N'AMD Ryzen 5', NULL, NULL, N'AMD Ryzen 5'),
(N'CPU-AMD-R7-9700X', N'CPU', N'Socket', N'AM5', NULL, NULL, N'AM5'),
(N'CPU-AMD-R7-9700X', N'CPU', N'Số nhân', NULL, 8, NULL, N'8'),
(N'CPU-AMD-R7-9700X', N'CPU', N'Số luồng', NULL, 16, NULL, N'16'),
(N'CPU-AMD-R7-9700X', N'CPU', N'Bộ nhớ đệm', NULL, 40, NULL, N'40'),
(N'CPU-AMD-R7-9700X', N'CPU', N'Xung nhịp cơ bản', NULL, 3.8, NULL, N'3.8'),
(N'CPU-AMD-R7-9700X', N'CPU', N'Xung nhịp tối đa', NULL, 5.5, NULL, N'5.5'),
(N'CPU-AMD-R7-9700X', N'CPU', N'Tốc độ RAM tối đa', NULL, 5600, NULL, N'5600'),
(N'CPU-AMD-R7-9700X', N'CPU', N'Có iGPU', NULL, NULL, 0, N'Không'),
(N'CPU-AMD-R7-9700X', N'CPU', N'Dòng CPU', N'AMD Ryzen 7', NULL, NULL, N'AMD Ryzen 7'),
(N'CPU-AMD-R9-9950X', N'CPU', N'Socket', N'AM5', NULL, NULL, N'AM5'),
(N'CPU-AMD-R9-9950X', N'CPU', N'Số nhân', NULL, 16, NULL, N'16'),
(N'CPU-AMD-R9-9950X', N'CPU', N'Số luồng', NULL, 32, NULL, N'32'),
(N'CPU-AMD-R9-9950X', N'CPU', N'Bộ nhớ đệm', NULL, 80, NULL, N'80'),
(N'CPU-AMD-R9-9950X', N'CPU', N'Xung nhịp cơ bản', NULL, 4.3, NULL, N'4.3'),
(N'CPU-AMD-R9-9950X', N'CPU', N'Xung nhịp tối đa', NULL, 5.7, NULL, N'5.7'),
(N'CPU-AMD-R9-9950X', N'CPU', N'Tốc độ RAM tối đa', NULL, 5200, NULL, N'5200'),
(N'CPU-AMD-R9-9950X', N'CPU', N'Có iGPU', NULL, NULL, 1, N'Có'),
(N'CPU-AMD-R9-9950X', N'CPU', N'Dòng CPU', N'AMD Ryzen 9', NULL, NULL, N'AMD Ryzen 9'),
(N'CPU-AMD-ATHLON-3000G', N'CPU', N'Socket', N'AM4', NULL, NULL, N'AM4'),
(N'CPU-AMD-ATHLON-3000G', N'CPU', N'Số nhân', NULL, 2, NULL, N'2'),
(N'CPU-AMD-ATHLON-3000G', N'CPU', N'Số luồng', NULL, 4, NULL, N'4'),
(N'CPU-AMD-ATHLON-3000G', N'CPU', N'Bộ nhớ đệm', NULL, 5, NULL, N'5'),
(N'CPU-AMD-ATHLON-3000G', N'CPU', N'Xung nhịp cơ bản', NULL, 3.5, NULL, N'3.5'),
(N'CPU-AMD-ATHLON-3000G', N'CPU', N'Tốc độ RAM tối đa', NULL, 2666, NULL, N'2666'),
(N'CPU-AMD-ATHLON-3000G', N'CPU', N'Có iGPU', NULL, NULL, 1, N'Có'),
(N'CPU-AMD-ATHLON-3000G', N'CPU', N'Dòng CPU', N'AMD Athlon', NULL, NULL, N'AMD Athlon'),
(N'CPU-AMD-R9-9950X-TRAY', N'CPU', N'Socket', N'AM5', NULL, NULL, N'AM5'),
(N'CPU-AMD-R9-9950X-TRAY', N'CPU', N'Số nhân', NULL, 16, NULL, N'16'),
(N'CPU-AMD-R9-9950X-TRAY', N'CPU', N'Số luồng', NULL, 32, NULL, N'32'),
(N'CPU-AMD-R9-9950X-TRAY', N'CPU', N'Bộ nhớ đệm', NULL, 80, NULL, N'80'),
(N'CPU-AMD-R9-9950X-TRAY', N'CPU', N'Xung nhịp cơ bản', NULL, 4.3, NULL, N'4.3'),
(N'CPU-AMD-R9-9950X-TRAY', N'CPU', N'Xung nhịp tối đa', NULL, 5.7, NULL, N'5.7'),
(N'CPU-AMD-R9-9950X-TRAY', N'CPU', N'Tốc độ RAM tối đa', NULL, 5600, NULL, N'5600'),
(N'CPU-AMD-R9-9950X-TRAY', N'CPU', N'Có iGPU', NULL, NULL, 1, N'Có'),
(N'CPU-AMD-R9-9950X-TRAY', N'CPU', N'Dòng CPU', N'AMD Ryzen 9', NULL, NULL, N'AMD Ryzen 9'),
(N'CPU-AMD-R9-9950X-TRAY', N'CPU', N'Loại đóng gói', N'TRAY', NULL, NULL, N'TRAY'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Mã sản phẩm', N'CMK8GX4M1E3200C16', NULL, NULL, N'CMK8GX4M1E3200C16'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Chuẩn RAM', N'DDR4', NULL, NULL, N'DDR4'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Dung lượng', NULL, 8, NULL, N'8'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Số lượng thanh', NULL, 1, NULL, N'1'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Dung lượng mỗi thanh', NULL, 8, NULL, N'8'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Bus', NULL, 3200, NULL, N'3200'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Độ trễ CL', NULL, 16, NULL, N'16'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Intel XMP', NULL, NULL, 1, N'Có'),
(N'CMK8GX4M1E3200C16', N'RAM', N'AMD EXPO', NULL, NULL, 0, N'Không'),
(N'CMK8GX4M1E3200C16', N'RAM', N'RGB/LED', NULL, NULL, 0, N'Không'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Băng thông', NULL, 25.6, NULL, N'25.6'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Form Factor', N'DIMM (Desktop)', NULL, NULL, N'DIMM (Desktop)'),
(N'CMK8GX4M1E3200C16', N'RAM', N'Tản nhiệt', NULL, NULL, 1, N'Có'),
(N'KF432C16BBA/8', N'RAM', N'Mã sản phẩm', N'KF432C16BBA/8', NULL, NULL, N'KF432C16BBA/8'),
(N'KF432C16BBA/8', N'RAM', N'Chuẩn RAM', N'DDR4', NULL, NULL, N'DDR4'),
(N'KF432C16BBA/8', N'RAM', N'Dung lượng', NULL, 8, NULL, N'8'),
(N'KF432C16BBA/8', N'RAM', N'Số lượng thanh', NULL, 1, NULL, N'1'),
(N'KF432C16BBA/8', N'RAM', N'Dung lượng mỗi thanh', NULL, 8, NULL, N'8'),
(N'KF432C16BBA/8', N'RAM', N'Bus', NULL, 3200, NULL, N'3200'),
(N'KF432C16BBA/8', N'RAM', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'KF432C16BBA/8', N'RAM', N'Độ trễ CL', NULL, 16, NULL, N'16'),
(N'KF432C16BBA/8', N'RAM', N'Intel XMP', NULL, NULL, 1, N'Có'),
(N'KF432C16BBA/8', N'RAM', N'AMD EXPO', NULL, NULL, 0, N'Không'),
(N'KF432C16BBA/8', N'RAM', N'RGB/LED', NULL, NULL, 1, N'Có'),
(N'KF432C16BBA/8', N'RAM', N'Băng thông', NULL, 25.6, NULL, N'25.6'),
(N'KF432C16BBA/8', N'RAM', N'Form Factor', N'DIMM (Desktop)', NULL, NULL, N'DIMM (Desktop)'),
(N'KF432C16BBA/8', N'RAM', N'Tản nhiệt', NULL, NULL, 1, N'Có'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Mã sản phẩm', N'CMP32GX5M2B6000C30', NULL, NULL, N'CMP32GX5M2B6000C30'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Dung lượng', NULL, 32, NULL, N'32'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Số lượng thanh', NULL, 2, NULL, N'2'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Dung lượng mỗi thanh', NULL, 16, NULL, N'16'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Bus', NULL, 6000, NULL, N'6000'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Độ trễ CL', NULL, 30, NULL, N'30'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Intel XMP', NULL, NULL, 1, N'Có'),
(N'CMP32GX5M2B6000C30', N'RAM', N'AMD EXPO', NULL, NULL, 0, N'Không'),
(N'CMP32GX5M2B6000C30', N'RAM', N'RGB/LED', NULL, NULL, 1, N'Có'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Băng thông', NULL, 60, NULL, N'60'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Form Factor', N'DIMM (Desktop)', NULL, NULL, N'DIMM (Desktop)'),
(N'CMP32GX5M2B6000C30', N'RAM', N'Tản nhiệt', NULL, NULL, 1, N'Có'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Mã sản phẩm', N'CMH32GX5M2B5600C40W', NULL, NULL, N'CMH32GX5M2B5600C40W'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Dung lượng', NULL, 32, NULL, N'32'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Số lượng thanh', NULL, 2, NULL, N'2'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Dung lượng mỗi thanh', NULL, 16, NULL, N'16'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Bus', NULL, 5600, NULL, N'5600'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Màu sắc', N'White', NULL, NULL, N'White'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Độ trễ CL', NULL, 40, NULL, N'40'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Intel XMP', NULL, NULL, 1, N'Có'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'AMD EXPO', NULL, NULL, 0, N'Không'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'RGB/LED', NULL, NULL, 1, N'Có'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Băng thông', NULL, 44.8, NULL, N'44.8'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Form Factor', N'DIMM (Desktop)', NULL, NULL, N'DIMM (Desktop)'),
(N'CMH32GX5M2B5600C40W', N'RAM', N'Tản nhiệt', NULL, NULL, 1, N'Có'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Mã sản phẩm', N'CMP64GX5M2B6000C30W', NULL, NULL, N'CMP64GX5M2B6000C30W'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Dung lượng', NULL, 64, NULL, N'64'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Số lượng thanh', NULL, 2, NULL, N'2'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Dung lượng mỗi thanh', NULL, 32, NULL, N'32'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Bus', NULL, 6000, NULL, N'6000'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Màu sắc', N'White', NULL, NULL, N'White'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Độ trễ CL', NULL, 30, NULL, N'30'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Intel XMP', NULL, NULL, 1, N'Có'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'AMD EXPO', NULL, NULL, 0, N'Không'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'RGB/LED', NULL, NULL, 1, N'Có'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Băng thông', NULL, 48, NULL, N'48'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Form Factor', N'UDIMM', NULL, NULL, N'UDIMM'),
(N'CMP64GX5M2B6000C30W', N'RAM', N'Tản nhiệt', NULL, NULL, 1, N'Có'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'Mã sản phẩm', N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', NULL, NULL, N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'Chuẩn RAM', N'DDR4', NULL, NULL, N'DDR4'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'Dung lượng', NULL, 16, NULL, N'16'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'Số lượng thanh', NULL, 1, NULL, N'1'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'Dung lượng mỗi thanh', NULL, 16, NULL, N'16'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'Bus', NULL, 3600, NULL, N'3600'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'Intel XMP', NULL, NULL, 1, N'Có'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'AMD EXPO', NULL, NULL, 0, N'Không'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'RGB/LED', NULL, NULL, 1, N'Có'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'Băng thông', NULL, 28.8, NULL, N'28.8'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'Form Factor', N'DIMM (Desktop)', NULL, NULL, N'DIMM (Desktop)'),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'RAM', N'Tản nhiệt', NULL, NULL, 1, N'Có'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Mã sản phẩm', N'F5-5600J4040C16GX2-TZ5RS', NULL, NULL, N'F5-5600J4040C16GX2-TZ5RS'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Dung lượng', NULL, 32, NULL, N'32'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Số lượng thanh', NULL, 2, NULL, N'2'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Dung lượng mỗi thanh', NULL, 16, NULL, N'16'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Bus', NULL, 5600, NULL, N'5600'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Màu sắc', N'Silver', NULL, NULL, N'Silver'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Độ trễ CL', NULL, 40, NULL, N'40'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Intel XMP', NULL, NULL, 1, N'Có'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'AMD EXPO', NULL, NULL, 1, N'Có'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'RGB/LED', NULL, NULL, 1, N'Có'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Băng thông', NULL, 44.8, NULL, N'44.8'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Form Factor', N'UDIMM', NULL, NULL, N'UDIMM'),
(N'F5-5600J4040C16GX2-TZ5RS', N'RAM', N'Tản nhiệt', NULL, NULL, 1, N'Có'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Mã sản phẩm', N'F5-6000J3040G32GX2-TZ5RS', NULL, NULL, N'F5-6000J3040G32GX2-TZ5RS'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Dung lượng', NULL, 64, NULL, N'64'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Số lượng thanh', NULL, 2, NULL, N'2'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Dung lượng mỗi thanh', NULL, 32, NULL, N'32'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Bus', NULL, 6000, NULL, N'6000'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Màu sắc', N'Silver', NULL, NULL, N'Silver'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Độ trễ CL', NULL, 30, NULL, N'30'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Intel XMP', NULL, NULL, 1, N'Có'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'AMD EXPO', NULL, NULL, 0, N'Không'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'RGB/LED', NULL, NULL, 1, N'Có'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Băng thông', NULL, 48, NULL, N'48'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Form Factor', N'UDIMM', NULL, NULL, N'UDIMM'),
(N'F5-6000J3040G32GX2-TZ5RS', N'RAM', N'Tản nhiệt', NULL, NULL, 1, N'Có'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Mã sản phẩm', N'CMH96GX5M2B5600C40', NULL, NULL, N'CMH96GX5M2B5600C40'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Dung lượng', NULL, 96, NULL, N'96'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Số lượng thanh', NULL, 2, NULL, N'2'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Dung lượng mỗi thanh', NULL, 48, NULL, N'48'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Bus', NULL, 5600, NULL, N'5600'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Độ trễ CL', NULL, 40, NULL, N'40'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Intel XMP', NULL, NULL, 1, N'Có'),
(N'CMH96GX5M2B5600C40', N'RAM', N'AMD EXPO', NULL, NULL, 0, N'Không'),
(N'CMH96GX5M2B5600C40', N'RAM', N'RGB/LED', NULL, NULL, 1, N'Có'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Băng thông', NULL, 89.6, NULL, N'89.6'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Form Factor', N'UDIMM', NULL, NULL, N'UDIMM'),
(N'CMH96GX5M2B5600C40', N'RAM', N'Tản nhiệt', NULL, NULL, 1, N'Có'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Mã sản phẩm', N'CMP96GX5M2B6600C32', NULL, NULL, N'CMP96GX5M2B6600C32'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Dung lượng', NULL, 96, NULL, N'96'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Số lượng thanh', NULL, 2, NULL, N'2'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Dung lượng mỗi thanh', NULL, 48, NULL, N'48'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Bus', NULL, 6600, NULL, N'6600'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Độ trễ CL', NULL, 32, NULL, N'32'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Intel XMP', NULL, NULL, 1, N'Có'),
(N'CMP96GX5M2B6600C32', N'RAM', N'AMD EXPO', NULL, NULL, 0, N'Không'),
(N'CMP96GX5M2B6600C32', N'RAM', N'RGB/LED', NULL, NULL, 1, N'Có'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Băng thông', NULL, 52.8, NULL, N'52.8'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Form Factor', N'UDIMM', NULL, NULL, N'UDIMM'),
(N'CMP96GX5M2B6600C32', N'RAM', N'Tản nhiệt', NULL, NULL, 1, N'Có'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Nhân đồ họa', N'NVIDIA GeForce RTX 4090', NULL, NULL, N'NVIDIA GeForce RTX 4090'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Bus tiêu chuẩn', N'PCI Express 4.0', NULL, NULL, N'PCI Express 4.0'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'OpenGL', N'OpenGL 4.6', NULL, NULL, N'OpenGL 4.6'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'DirectX', N'DirectX 12 Ultimate', NULL, NULL, N'DirectX 12 Ultimate'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Bộ nhớ Video', N'24 GB GDDR6X', NULL, NULL, N'24 GB GDDR6X'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Dung lượng VRAM', NULL, 24, NULL, N'24'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Chuẩn bộ nhớ', N'GDDR6X', NULL, NULL, N'GDDR6X'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Xung nhịp OC', NULL, 2700, NULL, N'2700'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Xung nhịp mặc định', NULL, 2670, NULL, N'2670'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Nhân CUDA', NULL, 16384, NULL, N'16384'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Tốc độ bộ nhớ', NULL, 21, NULL, N'21'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Giao thức bộ nhớ', N'384-bit', NULL, NULL, N'384-bit'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Độ phân giải tối đa', N'7680 x 4320', NULL, NULL, N'7680 x 4320'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'HDMI', N'2 x Native HDMI 2.1', NULL, NULL, N'2 x Native HDMI 2.1'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'DisplayPort', N'3 x Native DisplayPort 1.4a', NULL, NULL, N'3 x Native DisplayPort 1.4a'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'HDCP', N'Hỗ trợ HDCP 2.3', NULL, NULL, N'Hỗ trợ HDCP 2.3'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Số lượng màn hình tối đa hỗ trợ', NULL, 4, NULL, N'4'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Hỗ trợ NVLink/Crossfire', NULL, NULL, 0, N'Không'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Kích thước card', N'286.5 x 148.3 x 24.5 mm', NULL, NULL, N'286.5 x 148.3 x 24.5 mm'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Kích thước radiator', N'400 x 120 x 65 mm', NULL, NULL, N'400 x 120 x 65 mm'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'PSU kiến nghị', NULL, 1000, NULL, N'1000'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Kết nối nguồn', N'1 x 16 pin', NULL, NULL, N'1 x 16 pin'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Khe cắm', NULL, 2.5, NULL, N'2.5'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'AURA SYNC', N'ARGB', NULL, NULL, N'ARGB'),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'Card đồ họa', N'Loại tản nhiệt', N'Liquid / Radiator Hybrid', NULL, NULL, N'Liquid / Radiator Hybrid'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Nhân đồ họa', N'GeForce RTX 4070 SUPER', NULL, NULL, N'GeForce RTX 4070 SUPER'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Bus tiêu chuẩn', N'PCI-E 4.0', NULL, NULL, N'PCI-E 4.0'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'OpenGL', N'OpenGL 4.6', NULL, NULL, N'OpenGL 4.6'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'DirectX', N'DirectX 12 Ultimate', NULL, NULL, N'DirectX 12 Ultimate'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Bộ nhớ Video', N'12 GB GDDR6X', NULL, NULL, N'12 GB GDDR6X'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Dung lượng VRAM', NULL, 12, NULL, N'12'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Chuẩn bộ nhớ', N'GDDR6X', NULL, NULL, N'GDDR6X'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Xung nhịp', NULL, 2535, NULL, N'2535'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Xung nhịp reference', NULL, 2475, NULL, N'2475'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Nhân CUDA', NULL, 7168, NULL, N'7168'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Tốc độ bộ nhớ', NULL, 21, NULL, N'21'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Giao thức bộ nhớ', N'192-bit', NULL, NULL, N'192-bit'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Độ phân giải tối đa', N'7680 x 4320', NULL, NULL, N'7680 x 4320'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Số lượng màn hình tối đa hỗ trợ', NULL, 4, NULL, N'4'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'HDMI', N'1 x HDMI 2.1', NULL, NULL, N'1 x HDMI 2.1'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'DisplayPort', N'3 x DisplayPort 1.4a', NULL, NULL, N'3 x DisplayPort 1.4a'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Kích thước', N'261 x 126 x 50 mm', NULL, NULL, N'261 x 126 x 50 mm'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'PSU kiến nghị', NULL, 700, NULL, N'700'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Kết nối nguồn', N'1 x 16 pin', NULL, NULL, N'1 x 16 pin'),
(N'GPU-ASUS-RTX4070SUPER-12G', N'Card đồ họa', N'Loại tản nhiệt', N'Air Cooling', NULL, NULL, N'Air Cooling'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Nhân đồ họa', N'NVIDIA GeForce RTX 5070 Ti', NULL, NULL, N'NVIDIA GeForce RTX 5070 Ti'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Bus tiêu chuẩn', N'PCI Express 5.0', NULL, NULL, N'PCI Express 5.0'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'OpenGL', N'OpenGL 4.6', NULL, NULL, N'OpenGL 4.6'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'DirectX', N'DirectX 12 Ultimate', NULL, NULL, N'DirectX 12 Ultimate'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Bộ nhớ Video', N'16 GB GDDR7', NULL, NULL, N'16 GB GDDR7'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Dung lượng VRAM', NULL, 16, NULL, N'16'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Chuẩn bộ nhớ', N'GDDR7', NULL, NULL, N'GDDR7'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Xung nhịp OC', NULL, 2610, NULL, N'2610'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Xung nhịp mặc định', NULL, 2588, NULL, N'2588'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Nhân CUDA', NULL, 8960, NULL, N'8960'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Tốc độ bộ nhớ', NULL, 28, NULL, N'28'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Giao thức bộ nhớ', N'256-bit', NULL, NULL, N'256-bit'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Độ phân giải tối đa', N'7680 x 4320', NULL, NULL, N'7680 x 4320'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'HDMI', N'2 x Native HDMI 2.1b', NULL, NULL, N'2 x Native HDMI 2.1b'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'DisplayPort', N'3 x Native DisplayPort 2.1b', NULL, NULL, N'3 x Native DisplayPort 2.1b'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'HDCP', N'Hỗ trợ HDCP 2.3', NULL, NULL, N'Hỗ trợ HDCP 2.3'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Số lượng màn hình tối đa hỗ trợ', NULL, 4, NULL, N'4'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Hỗ trợ NVLink/Crossfire', NULL, NULL, 0, N'Không'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Kích thước', N'329 x 140 x 62.5 mm', NULL, NULL, N'329 x 140 x 62.5 mm'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'PSU kiến nghị', NULL, 850, NULL, N'850'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Kết nối nguồn', N'1 x 16 pin', NULL, NULL, N'1 x 16 pin'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Khe cắm', NULL, 3.125, NULL, N'3.125'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'AURA SYNC', N'ARGB', NULL, NULL, N'ARGB'),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'Card đồ họa', N'Loại tản nhiệt', N'Air Cooling', NULL, NULL, N'Air Cooling'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Nhân đồ họa', N'NVIDIA GeForce RTX 5080', NULL, NULL, N'NVIDIA GeForce RTX 5080'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Bus tiêu chuẩn', N'PCI Express 5.0', NULL, NULL, N'PCI Express 5.0'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'OpenGL', N'OpenGL 4.6', NULL, NULL, N'OpenGL 4.6'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'DirectX', N'DirectX 12 Ultimate', NULL, NULL, N'DirectX 12 Ultimate'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Bộ nhớ Video', N'16 GB GDDR7', NULL, NULL, N'16 GB GDDR7'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Dung lượng VRAM', NULL, 16, NULL, N'16'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Chuẩn bộ nhớ', N'GDDR7', NULL, NULL, N'GDDR7'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Xung nhịp OC', NULL, 2790, NULL, N'2790'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Xung nhịp mặc định', NULL, 2760, NULL, N'2760'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Nhân CUDA', NULL, 10752, NULL, N'10752'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Tốc độ bộ nhớ', NULL, 30, NULL, N'30'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Giao thức bộ nhớ', N'256-bit', NULL, NULL, N'256-bit'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Độ phân giải tối đa', N'7680 x 4320', NULL, NULL, N'7680 x 4320'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'HDMI', N'2 x Native HDMI 2.1b', NULL, NULL, N'2 x Native HDMI 2.1b'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'DisplayPort', N'3 x Native DisplayPort 1.4a', NULL, NULL, N'3 x Native DisplayPort 1.4a'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'HDCP', N'Hỗ trợ HDCP 2.3', NULL, NULL, N'Hỗ trợ HDCP 2.3'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Số lượng màn hình tối đa hỗ trợ', NULL, 4, NULL, N'4'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Hỗ trợ NVLink/Crossfire', NULL, NULL, 0, N'Không'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Kích thước', N'357.6 x 149.3 x 76 mm', NULL, NULL, N'357.6 x 149.3 x 76 mm'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'PSU kiến nghị', NULL, 850, NULL, N'850'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Kết nối nguồn', N'1 x 16 pin', NULL, NULL, N'1 x 16 pin'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Khe cắm', NULL, 3.8, NULL, N'3.8'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'AURA SYNC', N'ARGB', NULL, NULL, N'ARGB'),
(N'GPU-ASUS-ROG-RTX5080-16G', N'Card đồ họa', N'Loại tản nhiệt', N'Air Cooling', NULL, NULL, N'Air Cooling'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Nhân đồ họa', N'NVIDIA GeForce RTX 5090', NULL, NULL, N'NVIDIA GeForce RTX 5090'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Bus tiêu chuẩn', N'PCI Express 5.0', NULL, NULL, N'PCI Express 5.0'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'OpenGL', N'OpenGL 4.6', NULL, NULL, N'OpenGL 4.6'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'DirectX', N'DirectX 12 Ultimate', NULL, NULL, N'DirectX 12 Ultimate'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Bộ nhớ Video', N'32 GB GDDR7', NULL, NULL, N'32 GB GDDR7'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Dung lượng VRAM', NULL, 32, NULL, N'32'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Chuẩn bộ nhớ', N'GDDR7', NULL, NULL, N'GDDR7'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Xung nhịp OC', NULL, 2437, NULL, N'2437'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Xung nhịp mặc định', NULL, 2407, NULL, N'2407'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Nhân CUDA', NULL, 21760, NULL, N'21760'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Tốc độ bộ nhớ', NULL, 28, NULL, N'28'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Giao thức bộ nhớ', N'512-bit', NULL, NULL, N'512-bit'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Độ phân giải tối đa', N'7680 x 4320', NULL, NULL, N'7680 x 4320'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'HDMI', N'2 x Native HDMI 2.1b', NULL, NULL, N'2 x Native HDMI 2.1b'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'DisplayPort', N'3 x Native DisplayPort 1.4a', NULL, NULL, N'3 x Native DisplayPort 1.4a'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'HDCP', N'Hỗ trợ HDCP 2.3', NULL, NULL, N'Hỗ trợ HDCP 2.3'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Số lượng màn hình tối đa hỗ trợ', NULL, 4, NULL, N'4'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Hỗ trợ NVLink/Crossfire', NULL, NULL, 0, N'Không'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Kích thước', N'348 x 146 x 72 mm', NULL, NULL, N'348 x 146 x 72 mm'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'PSU kiến nghị', NULL, 1000, NULL, N'1000'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Kết nối nguồn', N'1 x 16 pin', NULL, NULL, N'1 x 16 pin'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Khe cắm', NULL, 3.6, NULL, N'3.6'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'AURA SYNC', N'ARGB', NULL, NULL, N'ARGB'),
(N'GPU-ASUS-TUF-RTX5090-32G', N'Card đồ họa', N'Loại tản nhiệt', N'Air Cooling', NULL, NULL, N'Air Cooling'),
(N'MB-ASUS-ROG-Z890-HERO', N'Mainboard', N'Chipset', N'Z890', NULL, NULL, N'Z890'),
(N'MB-ASUS-ROG-Z890-HERO', N'Mainboard', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'MB-ASUS-ROG-Z890-HERO', N'Mainboard', N'VRM pha', N'22+1+2+2 pha', NULL, NULL, N'22+1+2+2 pha'),
(N'MB-ASUS-ROG-Z890-HERO', N'Mainboard', N'Kết nối mạng LAN', N'2.5Gbps, 5Gbps', NULL, NULL, N'2.5Gbps, 5Gbps'),
(N'MB-ASUS-ROG-Z890-HERO', N'Mainboard', N'Wi-Fi', N'Wi-Fi 7', NULL, NULL, N'Wi-Fi 7'),
(N'MB-ASUS-ROG-Z890-HERO', N'Mainboard', N'Cổng USB', NULL, 8, NULL, N'8'),
(N'MB-ASUS-ROG-Z890-HERO', N'Mainboard', N'Cổng xuất hình', N'HDMI', NULL, NULL, N'HDMI'),
(N'MB-ASUS-ROG-Z890-HERO', N'Mainboard', N'Cổng xuất hình', N'USB-C (DP Alt Mode)', NULL, NULL, N'USB-C (DP Alt Mode)'),
(N'MB-ASUS-ROG-Z890-HERO', N'Mainboard', N'RGB LED', NULL, NULL, 1, N'Có'),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'Mainboard', N'Chipset', N'Z890', NULL, NULL, N'Z890'),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'Mainboard', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'Mainboard', N'VRM pha', N'16+1+2+2 pha', NULL, NULL, N'16+1+2+2 pha'),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'Mainboard', N'Kết nối mạng LAN', N'10Gbps, 2.5Gbps', NULL, NULL, N'10Gbps, 2.5Gbps'),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'Mainboard', N'Wi-Fi', N'Wi-Fi 7', NULL, NULL, N'Wi-Fi 7'),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'Mainboard', N'Cổng USB', NULL, 7, NULL, N'7'),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'Mainboard', N'Cổng xuất hình', N'HDMI', NULL, NULL, N'HDMI'),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'Mainboard', N'Cổng xuất hình', N'USB-C (DP Alt Mode)', NULL, NULL, N'USB-C (DP Alt Mode)'),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'Mainboard', N'Cổng xuất hình', N'DisplayPort', NULL, NULL, N'DisplayPort'),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'Mainboard', N'RGB LED', NULL, NULL, 0, N'Không'),
(N'MB-ASUS-ROG-Z890-APEX', N'Mainboard', N'Chipset', N'Z890', NULL, NULL, N'Z890'),
(N'MB-ASUS-ROG-Z890-APEX', N'Mainboard', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'MB-ASUS-ROG-Z890-APEX', N'Mainboard', N'VRM pha', N'22+1+2+2 pha', NULL, NULL, N'22+1+2+2 pha'),
(N'MB-ASUS-ROG-Z890-APEX', N'Mainboard', N'Kết nối mạng LAN', N'5Gbps', NULL, NULL, N'5Gbps'),
(N'MB-ASUS-ROG-Z890-APEX', N'Mainboard', N'Wi-Fi', N'Wi-Fi 7', NULL, NULL, N'Wi-Fi 7'),
(N'MB-ASUS-ROG-Z890-APEX', N'Mainboard', N'Cổng USB', NULL, 8, NULL, N'8'),
(N'MB-ASUS-ROG-Z890-APEX', N'Mainboard', N'Cổng xuất hình', N'USB-C (DP Alt Mode)', NULL, NULL, N'USB-C (DP Alt Mode)'),
(N'MB-ASUS-ROG-Z890-APEX', N'Mainboard', N'RGB LED', NULL, NULL, 1, N'Có'),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'Mainboard', N'Chipset', N'Z890', NULL, NULL, N'Z890'),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'Mainboard', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'Mainboard', N'VRM pha', N'16+1+2 pha', NULL, NULL, N'16+1+2 pha'),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'Mainboard', N'Kết nối mạng LAN', N'2.5Gbps', NULL, NULL, N'2.5Gbps'),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'Mainboard', N'Wi-Fi', N'Wi-Fi 7', NULL, NULL, N'Wi-Fi 7'),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'Mainboard', N'Cổng USB', NULL, 10, NULL, N'10'),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'Mainboard', N'Cổng xuất hình', N'DisplayPort', NULL, NULL, N'DisplayPort'),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'Mainboard', N'Cổng xuất hình', N'Thunderbolt', NULL, NULL, N'Thunderbolt'),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'Mainboard', N'RGB LED', NULL, NULL, 1, N'Có'),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'Mainboard', N'Chipset', N'Z890', NULL, NULL, N'Z890'),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'Mainboard', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'Mainboard', N'VRM pha', N'14+1+2 pha', NULL, NULL, N'14+1+2 pha'),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'Mainboard', N'Kết nối mạng LAN', N'2.5Gbps', NULL, NULL, N'2.5Gbps'),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'Mainboard', N'Wi-Fi', N'Wi-Fi 7', NULL, NULL, N'Wi-Fi 7'),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'Mainboard', N'Cổng USB', NULL, 10, NULL, N'10'),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'Mainboard', N'Cổng xuất hình', N'USB-C (DP Alt Mode)', NULL, NULL, N'USB-C (DP Alt Mode)'),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'Mainboard', N'Cổng xuất hình', N'DisplayPort', NULL, NULL, N'DisplayPort'),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'Mainboard', N'RGB LED', NULL, NULL, 1, N'Có'),
(N'MB-ASUS-ROG-Z890-EXTREME', N'Mainboard', N'Chipset', N'Z890', NULL, NULL, N'Z890'),
(N'MB-ASUS-ROG-Z890-EXTREME', N'Mainboard', N'Chuẩn RAM', N'DDR5', NULL, NULL, N'DDR5'),
(N'MB-ASUS-ROG-Z890-EXTREME', N'Mainboard', N'VRM pha', N'24+1+2+2 pha', NULL, NULL, N'24+1+2+2 pha'),
(N'MB-ASUS-ROG-Z890-EXTREME', N'Mainboard', N'Kết nối mạng LAN', N'10Gbps, 2.5Gbps', NULL, NULL, N'10Gbps, 2.5Gbps'),
(N'MB-ASUS-ROG-Z890-EXTREME', N'Mainboard', N'Wi-Fi', N'Wi-Fi 7', NULL, NULL, N'Wi-Fi 7'),
(N'MB-ASUS-ROG-Z890-EXTREME', N'Mainboard', N'Cổng USB', NULL, 5, NULL, N'5'),
(N'MB-ASUS-ROG-Z890-EXTREME', N'Mainboard', N'Cổng xuất hình', N'HDMI', NULL, NULL, N'HDMI'),
(N'MB-ASUS-ROG-Z890-EXTREME', N'Mainboard', N'Cổng xuất hình', N'Thunderbolt', NULL, NULL, N'Thunderbolt'),
(N'MB-ASUS-ROG-Z890-EXTREME', N'Mainboard', N'RGB LED', NULL, NULL, 1, N'Có'),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'Mainboard', N'Chipset', N'H610', NULL, NULL, N'H610'),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'Mainboard', N'Chuẩn RAM', N'DDR4', NULL, NULL, N'DDR4'),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'Mainboard', N'VRM pha', N'4+1+1 pha', NULL, NULL, N'4+1+1 pha'),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'Mainboard', N'Kết nối mạng LAN', N'1Gbps', NULL, NULL, N'1Gbps'),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'Mainboard', N'Wi-Fi', N'Không', NULL, NULL, N'Không'),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'Mainboard', N'Cổng USB', NULL, 6, NULL, N'6'),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'Mainboard', N'Cổng xuất hình', N'VGA', NULL, NULL, N'VGA'),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'Mainboard', N'Cổng xuất hình', N'HDMI', NULL, NULL, N'HDMI'),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'Mainboard', N'RGB LED', NULL, NULL, 1, N'Có'),
(N'SSD-SAMSUNG-9100PRO-1TB', N'Ổ cứng', N'Loại ổ cứng', N'SSD NVMe', NULL, NULL, N'SSD NVMe'),
(N'SSD-SAMSUNG-9100PRO-1TB', N'Ổ cứng', N'Chuẩn kết nối', N'M.2 PCIe NVMe (Gen 5)', NULL, NULL, N'M.2 PCIe NVMe (Gen 5)'),
(N'SSD-SAMSUNG-9100PRO-1TB', N'Ổ cứng', N'Dung lượng', NULL, 1, NULL, N'1'),
(N'SSD-SAMSUNG-9100PRO-1TB', N'Ổ cứng', N'Form Factor', N'M.2 2280', NULL, NULL, N'M.2 2280'),
(N'SSD-SAMSUNG-9100PRO-1TB', N'Ổ cứng', N'Loại chip nhớ', N'3D V-NAND', NULL, NULL, N'3D V-NAND'),
(N'SSD-SAMSUNG-9100PRO-1TB', N'Ổ cứng', N'Tốc độ đọc', NULL, 14700, NULL, N'14700'),
(N'SSD-SAMSUNG-9100PRO-1TB', N'Ổ cứng', N'Tốc độ ghi', NULL, 13300, NULL, N'13300'),
(N'SSD-SAMSUNG-9100PRO-1TB', N'Ổ cứng', N'Công nghệ quản lý nhiệt', N'Công nghệ quản lý nhiệt', NULL, NULL, N'Công nghệ quản lý nhiệt'),
(N'SSD-SAMSUNG-9100PRO-1TB', N'Ổ cứng', N'TBW', NULL, 600, NULL, N'600'),
(N'SSD-SAMSUNG-990PRO-2TB', N'Ổ cứng', N'Loại ổ cứng', N'SSD NVMe', NULL, NULL, N'SSD NVMe'),
(N'SSD-SAMSUNG-990PRO-2TB', N'Ổ cứng', N'Chuẩn kết nối', N'M.2 PCIe NVMe (Gen 4)', NULL, NULL, N'M.2 PCIe NVMe (Gen 4)'),
(N'SSD-SAMSUNG-990PRO-2TB', N'Ổ cứng', N'Dung lượng', NULL, 2, NULL, N'2'),
(N'SSD-SAMSUNG-990PRO-2TB', N'Ổ cứng', N'Form Factor', N'M.2 2280', NULL, NULL, N'M.2 2280'),
(N'SSD-SAMSUNG-990PRO-2TB', N'Ổ cứng', N'Loại chip nhớ', N'3D TLC NAND', NULL, NULL, N'3D TLC NAND'),
(N'SSD-SAMSUNG-990PRO-2TB', N'Ổ cứng', N'Tốc độ đọc', NULL, 7450, NULL, N'7450'),
(N'SSD-SAMSUNG-990PRO-2TB', N'Ổ cứng', N'Tốc độ ghi', NULL, 6900, NULL, N'6900'),
(N'SSD-SAMSUNG-990PRO-2TB', N'Ổ cứng', N'Có tản nhiệt', NULL, NULL, 0, N'Không'),
(N'SSD-SAMSUNG-990PRO-2TB', N'Ổ cứng', N'TBW', NULL, 1200, NULL, N'1200'),
(N'SSD-KINGSTON-NV3-500GB', N'Ổ cứng', N'Loại ổ cứng', N'SSD NVMe', NULL, NULL, N'SSD NVMe'),
(N'SSD-KINGSTON-NV3-500GB', N'Ổ cứng', N'Chuẩn kết nối', N'M.2 PCIe NVMe (Gen 4)', NULL, NULL, N'M.2 PCIe NVMe (Gen 4)'),
(N'SSD-KINGSTON-NV3-500GB', N'Ổ cứng', N'Dung lượng', NULL, 500, NULL, N'500'),
(N'SSD-KINGSTON-NV3-500GB', N'Ổ cứng', N'Form Factor', N'M.2 2280', NULL, NULL, N'M.2 2280'),
(N'SSD-KINGSTON-NV3-500GB', N'Ổ cứng', N'Loại chip nhớ', N'3D NAND', NULL, NULL, N'3D NAND'),
(N'SSD-KINGSTON-NV3-500GB', N'Ổ cứng', N'Tốc độ đọc', NULL, 6000, NULL, N'6000'),
(N'SSD-KINGSTON-NV3-500GB', N'Ổ cứng', N'Tốc độ ghi', NULL, 4000, NULL, N'4000'),
(N'SSD-KINGSTON-NV3-500GB', N'Ổ cứng', N'Công nghệ quản lý nhiệt', N'Công nghệ quản lý nhiệt', NULL, NULL, N'Công nghệ quản lý nhiệt'),
(N'SSD-KINGSTON-NV3-500GB', N'Ổ cứng', N'TBW', NULL, 320, NULL, N'320'),
(N'SSD-KINGSTON-NV3-1TB', N'Ổ cứng', N'Loại ổ cứng', N'SSD NVMe', NULL, NULL, N'SSD NVMe'),
(N'SSD-KINGSTON-NV3-1TB', N'Ổ cứng', N'Chuẩn kết nối', N'M.2 PCIe NVMe (Gen 4)', NULL, NULL, N'M.2 PCIe NVMe (Gen 4)'),
(N'SSD-KINGSTON-NV3-1TB', N'Ổ cứng', N'Dung lượng', NULL, 1, NULL, N'1'),
(N'SSD-KINGSTON-NV3-1TB', N'Ổ cứng', N'Form Factor', N'M.2 2280', NULL, NULL, N'M.2 2280'),
(N'SSD-KINGSTON-NV3-1TB', N'Ổ cứng', N'Loại chip nhớ', N'3D NAND', NULL, NULL, N'3D NAND'),
(N'SSD-KINGSTON-NV3-1TB', N'Ổ cứng', N'Tốc độ đọc', NULL, 6000, NULL, N'6000'),
(N'SSD-KINGSTON-NV3-1TB', N'Ổ cứng', N'Tốc độ ghi', NULL, 4000, NULL, N'4000'),
(N'SSD-KINGSTON-NV3-1TB', N'Ổ cứng', N'Công nghệ quản lý nhiệt', N'Công nghệ quản lý nhiệt', NULL, NULL, N'Công nghệ quản lý nhiệt'),
(N'SSD-KINGSTON-NV3-1TB', N'Ổ cứng', N'TBW', NULL, 320, NULL, N'320'),
(N'SSD-KINGSTON-NV3-2TB', N'Ổ cứng', N'Loại ổ cứng', N'SSD NVMe', NULL, NULL, N'SSD NVMe'),
(N'SSD-KINGSTON-NV3-2TB', N'Ổ cứng', N'Chuẩn kết nối', N'M.2 PCIe NVMe (Gen 4)', NULL, NULL, N'M.2 PCIe NVMe (Gen 4)'),
(N'SSD-KINGSTON-NV3-2TB', N'Ổ cứng', N'Dung lượng', NULL, 2, NULL, N'2'),
(N'SSD-KINGSTON-NV3-2TB', N'Ổ cứng', N'Form Factor', N'M.2 2280', NULL, NULL, N'M.2 2280'),
(N'SSD-KINGSTON-NV3-2TB', N'Ổ cứng', N'Loại chip nhớ', N'QLC (Quad-Level Cell)', NULL, NULL, N'QLC (Quad-Level Cell)'),
(N'SSD-KINGSTON-NV3-2TB', N'Ổ cứng', N'Tốc độ đọc', NULL, 6000, NULL, N'6000'),
(N'SSD-KINGSTON-NV3-2TB', N'Ổ cứng', N'Tốc độ ghi', NULL, 5000, NULL, N'5000'),
(N'SSD-KINGSTON-NV3-2TB', N'Ổ cứng', N'Có tản nhiệt', NULL, NULL, 0, N'Không'),
(N'SSD-KINGSTON-NV3-2TB', N'Ổ cứng', N'TBW', NULL, 640, NULL, N'640'),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng', N'Loại ổ cứng', N'HDD', NULL, NULL, N'HDD'),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng', N'Chuẩn kết nối', N'SATA III 6Gb/s', NULL, NULL, N'SATA III 6Gb/s'),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng', N'Dung lượng', NULL, 2, NULL, N'2'),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng', N'Form Factor', N'3.5 inch', NULL, NULL, N'3.5 inch'),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng', N'Tốc độ vòng quay', NULL, 7200, NULL, N'7200'),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng', N'MTBF', NULL, 1000000, NULL, N'1000000'),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng', N'Nhiệt độ hoạt động', N'0 - 60 °C', NULL, NULL, N'0 - 60 °C'),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng', N'Tốc độ ghi', NULL, 210, NULL, N'210'),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng', N'Tốc độ đọc', NULL, 210, NULL, N'210'),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng', N'Tốc độ truyền dữ liệu', NULL, 6, NULL, N'6'),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'Ổ cứng', N'Trọng lượng', NULL, 250, NULL, N'250'),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng', N'Loại ổ cứng', N'HDD', NULL, NULL, N'HDD'),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng', N'Chuẩn kết nối', N'SATA III 6Gb/s', NULL, NULL, N'SATA III 6Gb/s'),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng', N'Dung lượng', NULL, 6, NULL, N'6'),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng', N'Form Factor', N'3.5 inch', NULL, NULL, N'3.5 inch'),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng', N'Tốc độ vòng quay', NULL, 5400, NULL, N'5400'),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng', N'MTBF', NULL, 1000000, NULL, N'1000000'),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng', N'Nhiệt độ hoạt động', N'0 - 60 °C', NULL, NULL, N'0 - 60 °C'),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng', N'Tốc độ ghi', NULL, 185, NULL, N'185'),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng', N'Tốc độ đọc', NULL, 140, NULL, N'140'),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng', N'Tốc độ truyền dữ liệu', NULL, 6, NULL, N'6'),
(N'HDD-WD-BLUE-6TB', N'Ổ cứng', N'Trọng lượng', NULL, 600, NULL, N'600'),
(N'HDD-WD-BLUE-4TB', N'Ổ cứng', N'Loại ổ cứng', N'HDD', NULL, NULL, N'HDD'),
(N'HDD-WD-BLUE-4TB', N'Ổ cứng', N'Chuẩn kết nối', N'SATA III 6Gb/s', NULL, NULL, N'SATA III 6Gb/s'),
(N'HDD-WD-BLUE-4TB', N'Ổ cứng', N'Dung lượng', NULL, 4, NULL, N'4'),
(N'HDD-WD-BLUE-4TB', N'Ổ cứng', N'Form Factor', N'3.5 inch', NULL, NULL, N'3.5 inch'),
(N'HDD-WD-BLUE-4TB', N'Ổ cứng', N'Nhiệt độ hoạt động', N'0 - 60 °C', NULL, NULL, N'0 - 60 °C'),
(N'HDD-WD-BLUE-2TB-7200', N'Ổ cứng', N'Loại ổ cứng', N'HDD', NULL, NULL, N'HDD'),
(N'HDD-WD-BLUE-2TB-7200', N'Ổ cứng', N'Chuẩn kết nối', N'SATA III 6Gb/s', NULL, NULL, N'SATA III 6Gb/s'),
(N'HDD-WD-BLUE-2TB-7200', N'Ổ cứng', N'Dung lượng', NULL, 2, NULL, N'2'),
(N'HDD-WD-BLUE-2TB-7200', N'Ổ cứng', N'Form Factor', N'3.5 inch', NULL, NULL, N'3.5 inch'),
(N'HDD-WD-BLUE-2TB-7200', N'Ổ cứng', N'Tốc độ vòng quay', NULL, 7200, NULL, N'7200'),
(N'HDD-WD-BLUE-2TB-7200', N'Ổ cứng', N'Nhiệt độ hoạt động', N'0 - 60 °C', NULL, NULL, N'0 - 60 °C'),
(N'HDD-WD-BLUE-2TB-7200', N'Ổ cứng', N'Tốc độ ghi', NULL, 215, NULL, N'215'),
(N'HDD-WD-BLUE-2TB-7200', N'Ổ cứng', N'Tốc độ đọc', NULL, 215, NULL, N'215'),
(N'HDD-WD-BLUE-2TB-7200', N'Ổ cứng', N'Tốc độ truyền dữ liệu', NULL, 6, NULL, N'6'),
(N'HDD-WD-BLUE-2TB-7200', N'Ổ cứng', N'Trọng lượng', NULL, 450, NULL, N'450'),
(N'HDD-WD-BLUE-1TB', N'Ổ cứng', N'Loại ổ cứng', N'HDD', NULL, NULL, N'HDD'),
(N'HDD-WD-BLUE-1TB', N'Ổ cứng', N'Chuẩn kết nối', N'SATA III 6Gb/s', NULL, NULL, N'SATA III 6Gb/s'),
(N'HDD-WD-BLUE-1TB', N'Ổ cứng', N'Dung lượng', NULL, 1, NULL, N'1'),
(N'HDD-WD-BLUE-1TB', N'Ổ cứng', N'Form Factor', N'3.5 inch', NULL, NULL, N'3.5 inch'),
(N'HDD-WD-BLUE-1TB', N'Ổ cứng', N'Tốc độ ghi', NULL, 150, NULL, N'150'),
(N'HDD-WD-BLUE-1TB', N'Ổ cứng', N'Tốc độ đọc', NULL, 150, NULL, N'150'),
(N'HDD-WD-BLUE-1TB', N'Ổ cứng', N'Tốc độ truyền dữ liệu', NULL, 6, NULL, N'6'),
(N'HDD-WD-BLUE-1TB', N'Ổ cứng', N'Trọng lượng', NULL, 450, NULL, N'450'),
(N'PSU-ASUS-ROG-THOR-850P', N'Nguồn máy tính', N'Công suất tối đa', NULL, 850, NULL, N'850'),
(N'PSU-ASUS-ROG-THOR-850P', N'Nguồn máy tính', N'Hiệu suất', NULL, 90, NULL, N'90'),
(N'PSU-ASUS-ROG-THOR-850P', N'Nguồn máy tính', N'Kích thước quạt', NULL, 135, NULL, N'135'),
(N'PSU-ASUS-ROG-THOR-850P', N'Nguồn máy tính', N'Tính năng bảo vệ', N'OPP; OVP; UVP; SCP; OCP; OTP', NULL, NULL, N'OPP; OVP; UVP; SCP; OCP; OTP'),
(N'PSU-ASUS-ROG-THOR-850P', N'Nguồn máy tính', N'Kiểu Rail', N'Single Rail', NULL, NULL, N'Single Rail'),
(N'PSU-ASUS-ROG-THOR-850P', N'Nguồn máy tính', N'Chứng nhận 80 Plus', N'80 Plus Platinum', NULL, NULL, N'80 Plus Platinum'),
(N'PSU-ASUS-ROG-THOR-850P', N'Nguồn máy tính', N'Full Modular', NULL, NULL, 1, N'Có'),
(N'PSU-ASUS-ROG-THOR-850P', N'Nguồn máy tính', N'Aura Sync / RGB', NULL, NULL, 1, N'Có'),
(N'PSU-ASUS-ROG-THOR-850P', N'Nguồn máy tính', N'Chuẩn nguồn', N'ATX', NULL, NULL, N'ATX'),
(N'PSU-ASUS-ROG-THOR-1200P2', N'Nguồn máy tính', N'Công suất tối đa', NULL, 1200, NULL, N'1200'),
(N'PSU-ASUS-ROG-THOR-1200P2', N'Nguồn máy tính', N'Hiệu suất', NULL, 92, NULL, N'92'),
(N'PSU-ASUS-ROG-THOR-1200P2', N'Nguồn máy tính', N'Kích thước quạt', NULL, 135, NULL, N'135'),
(N'PSU-ASUS-ROG-THOR-1200P2', N'Nguồn máy tính', N'Tính năng bảo vệ', N'OPP; OVP; UVP; SCP; OCP; OTP', NULL, NULL, N'OPP; OVP; UVP; SCP; OCP; OTP'),
(N'PSU-ASUS-ROG-THOR-1200P2', N'Nguồn máy tính', N'Kiểu Rail', N'Single Rail', NULL, NULL, N'Single Rail'),
(N'PSU-ASUS-ROG-THOR-1200P2', N'Nguồn máy tính', N'Chứng nhận 80 Plus', N'80 Plus Platinum', NULL, NULL, N'80 Plus Platinum'),
(N'PSU-ASUS-ROG-THOR-1200P2', N'Nguồn máy tính', N'Full Modular', NULL, NULL, 1, N'Có'),
(N'PSU-ASUS-ROG-THOR-1200P2', N'Nguồn máy tính', N'Chuẩn PCIe', N'PCIe 5.0', NULL, NULL, N'PCIe 5.0'),
(N'PSU-ASUS-ROG-THOR-1200P2', N'Nguồn máy tính', N'Aura Sync / RGB', NULL, NULL, 1, N'Có'),
(N'PSU-ASUS-ROG-THOR-1200P2', N'Nguồn máy tính', N'Chuẩn nguồn', N'ATX 3.0', NULL, NULL, N'ATX 3.0'),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'Nguồn máy tính', N'Công suất tối đa', NULL, 1000, NULL, N'1000'),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'Nguồn máy tính', N'Hiệu suất', NULL, 90, NULL, N'90'),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'Nguồn máy tính', N'Kích thước quạt', NULL, 135, NULL, N'135'),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'Nguồn máy tính', N'Tính năng bảo vệ', N'OPP; OVP; UVP; SCP; OCP; OTP', NULL, NULL, N'OPP; OVP; UVP; SCP; OCP; OTP'),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'Nguồn máy tính', N'Kiểu Rail', N'Single Rail', NULL, NULL, N'Single Rail'),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'Nguồn máy tính', N'Chứng nhận 80 Plus', N'80 Plus Gold', NULL, NULL, N'80 Plus Gold'),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'Nguồn máy tính', N'Full Modular', NULL, NULL, 1, N'Có'),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'Nguồn máy tính', N'Chuẩn PCIe', N'PCIe 5.0', NULL, NULL, N'PCIe 5.0'),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'Nguồn máy tính', N'Aura Sync / RGB', NULL, NULL, 1, N'Có'),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'Nguồn máy tính', N'Chuẩn nguồn', N'ATX 3.0', NULL, NULL, N'ATX 3.0'),
(N'PSU-GIGABYTE-UD850GM-PG5', N'Nguồn máy tính', N'Công suất tối đa', NULL, 850, NULL, N'850'),
(N'PSU-GIGABYTE-UD850GM-PG5', N'Nguồn máy tính', N'Hiệu suất', NULL, 90, NULL, N'90'),
(N'PSU-GIGABYTE-UD850GM-PG5', N'Nguồn máy tính', N'Kích thước quạt', NULL, 120, NULL, N'120'),
(N'PSU-GIGABYTE-UD850GM-PG5', N'Nguồn máy tính', N'Tính năng bảo vệ', N'OCP; OPP; OTP; OV; SCP; UVP', NULL, NULL, N'OCP; OPP; OTP; OV; SCP; UVP'),
(N'PSU-GIGABYTE-UD850GM-PG5', N'Nguồn máy tính', N'Kiểu Rail', N'Single Rail', NULL, NULL, N'Single Rail'),
(N'PSU-GIGABYTE-UD850GM-PG5', N'Nguồn máy tính', N'Chứng nhận 80 Plus', N'80 Plus Gold', NULL, NULL, N'80 Plus Gold'),
(N'PSU-GIGABYTE-UD850GM-PG5', N'Nguồn máy tính', N'Full Modular', NULL, NULL, 1, N'Có'),
(N'PSU-GIGABYTE-UD850GM-PG5', N'Nguồn máy tính', N'Chuẩn PCIe', N'PCIe 5.0', NULL, NULL, N'PCIe 5.0'),
(N'PSU-GIGABYTE-UD850GM-PG5', N'Nguồn máy tính', N'Aura Sync / RGB', NULL, NULL, 0, N'Không'),
(N'PSU-GIGABYTE-UD850GM-PG5', N'Nguồn máy tính', N'Chuẩn nguồn', N'ATX 3.0', NULL, NULL, N'ATX 3.0'),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính', N'Công suất tối đa', NULL, 1600, NULL, N'1600'),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính', N'Hiệu suất', NULL, 94, NULL, N'94'),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính', N'Kích thước quạt', NULL, 140, NULL, N'140'),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính', N'Tính năng bảo vệ', N'OPP; OVP; UVP; SCP; OCP; OTP', NULL, NULL, N'OPP; OVP; UVP; SCP; OCP; OTP'),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính', N'Kiểu Rail', N'Single Rail', NULL, NULL, N'Single Rail'),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính', N'Chứng nhận 80 Plus', N'80 Plus Titanium', NULL, NULL, N'80 Plus Titanium'),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính', N'Full Modular', NULL, NULL, 1, N'Có'),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính', N'Chuẩn PCIe', N'PCIe 5.0', NULL, NULL, N'PCIe 5.0'),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính', N'Aura Sync / RGB', NULL, NULL, 1, N'Có'),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính', N'Chuẩn nguồn', N'ATX 3.1', NULL, NULL, N'ATX 3.1'),
(N'PSU-ASUS-ROG-THOR-1600T3', N'Nguồn máy tính', N'Tính năng đặc biệt', N'Dải OLED Power Display; RGB Aura Sync; tụ điện cao cấp Nhật Bản; thiết kế làm mát tối ưu; silent mode', NULL, NULL, N'Dải OLED Power Display; RGB Aura Sync; tụ điện cao cấp Nhật Bản; thiết kế làm mát tối ưu; silent mode'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Số lượng quạt đi kèm', NULL, 0, NULL, N'0'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Cổng USB Type-C', NULL, 1, NULL, N'1'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Cổng USB 3.0', NULL, 4, NULL, N'4'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Khe cắm mở rộng PCI', NULL, 8, NULL, N'8'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'LED RGB', NULL, NULL, 0, N'Không'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Mặt kính cường lực', NULL, NULL, 1, N'Có'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Màu sắc', N'White', NULL, NULL, N'White'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Chuẩn case', N'Mid Tower', NULL, NULL, N'Mid Tower'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Hỗ trợ mainboard', N'E-ATX / ATX / Micro-ATX / Mini-ITX', NULL, NULL, N'E-ATX / ATX / Micro-ATX / Mini-ITX'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Hỗ trợ radiator tối đa', N'360 mm', NULL, NULL, N'360 mm'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Hỗ trợ GPU tối đa', N'400 mm', NULL, NULL, N'400 mm'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Hỗ trợ tản nhiệt CPU', N'190 mm', NULL, NULL, N'190 mm'),
(N'CASE-CORSAIR-6500X-WHITE', N'Case', N'Hỗ trợ PSU', N'ATX', NULL, NULL, N'ATX'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Số lượng quạt đi kèm', NULL, 0, NULL, N'0'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Cổng USB Type-C', NULL, 1, NULL, N'1'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Cổng USB 3.0', NULL, 1, NULL, N'1'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Khe cắm mở rộng PCI', NULL, 4, NULL, N'4'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'LED RGB', NULL, NULL, 1, N'Có'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Mặt kính cường lực', NULL, NULL, 1, N'Có'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Màu sắc', N'White', NULL, NULL, N'White'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Chuẩn case', N'Mini Tower', NULL, NULL, N'Mini Tower'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Hỗ trợ mainboard', N'Micro-ATX / Mini-ITX', NULL, NULL, N'Micro-ATX / Mini-ITX'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Hỗ trợ radiator tối đa', N'240 mm', NULL, NULL, N'240 mm'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Hỗ trợ GPU tối đa', N'363 mm', NULL, NULL, N'363 mm'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Hỗ trợ tản nhiệt CPU', N'163 mm', NULL, NULL, N'163 mm'),
(N'CASE-JONSBO-Z20-WHITE', N'Case', N'Hỗ trợ PSU', N'ATX / SFX', NULL, NULL, N'ATX / SFX'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Số lượng quạt đi kèm', NULL, 0, NULL, N'0'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Cổng USB Type-C', NULL, 1, NULL, N'1'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Cổng USB 3.0', NULL, 1, NULL, N'1'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Khe cắm mở rộng PCI', NULL, 7, NULL, N'7'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'LED RGB', NULL, NULL, 1, N'Có'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Mặt kính cường lực', NULL, NULL, 1, N'Có'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Màu sắc', N'Pink', NULL, NULL, N'Pink'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Chuẩn case', N'Mini Tower', NULL, NULL, N'Mini Tower'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Hỗ trợ mainboard', N'Micro-ATX / Mini-ITX', NULL, NULL, N'Micro-ATX / Mini-ITX'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Hỗ trợ radiator tối đa', N'240 mm', NULL, NULL, N'240 mm'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Hỗ trợ GPU tối đa', N'363 mm', NULL, NULL, N'363 mm'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Hỗ trợ tản nhiệt CPU', N'163 mm', NULL, NULL, N'163 mm'),
(N'CASE-JONSBO-Z20-PINK', N'Case', N'Hỗ trợ PSU', N'ATX / SFX', NULL, NULL, N'ATX / SFX'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Số lượng quạt đi kèm', NULL, 4, NULL, N'4'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Cổng USB Type-C', NULL, 1, NULL, N'1'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Cổng USB 3.0', NULL, 2, NULL, N'2'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Khe cắm mở rộng PCI', NULL, 7, NULL, N'7'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'LED RGB', NULL, NULL, 1, N'Có'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Mặt kính cường lực', NULL, NULL, 1, N'Có'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Màu sắc', N'White / Blue', NULL, NULL, N'White / Blue'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Chuẩn case', N'Mid Tower', NULL, NULL, N'Mid Tower'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Hỗ trợ mainboard', N'ATX / Micro-ATX / Mini-ITX', NULL, NULL, N'ATX / Micro-ATX / Mini-ITX'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Hỗ trợ radiator tối đa', N'360 mm', NULL, NULL, N'360 mm'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Hỗ trợ GPU tối đa', N'410 mm', NULL, NULL, N'410 mm'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Hỗ trợ tản nhiệt CPU', N'165 mm', NULL, NULL, N'165 mm'),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'Case', N'Hỗ trợ PSU', N'ATX', NULL, NULL, N'ATX'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Số lượng quạt đi kèm', NULL, 4, NULL, N'4'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Cổng USB Type-C', NULL, 1, NULL, N'1'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Cổng USB 3.0', NULL, 2, NULL, N'2'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Khe cắm mở rộng PCI', NULL, 7, NULL, N'7'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'LED RGB', NULL, NULL, 1, N'Có'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Mặt kính cường lực', NULL, NULL, 1, N'Có'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Màu sắc', N'White', NULL, NULL, N'White'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Chuẩn case', N'Mid Tower', NULL, NULL, N'Mid Tower'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Hỗ trợ mainboard', N'ATX / Micro-ATX / Mini-ITX', NULL, NULL, N'ATX / Micro-ATX / Mini-ITX'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Hỗ trợ radiator tối đa', N'360 mm', NULL, NULL, N'360 mm'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Hỗ trợ GPU tối đa', N'435 mm', NULL, NULL, N'435 mm'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Hỗ trợ tản nhiệt CPU', N'165 mm', NULL, NULL, N'165 mm'),
(N'CASE-NZXT-H9-ELITE-WHITE', N'Case', N'Hỗ trợ PSU', N'ATX', NULL, NULL, N'ATX'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Số lượng quạt đi kèm', NULL, 1, NULL, N'1'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Cổng USB Type-C', NULL, 0, NULL, N'0'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Cổng USB 3.0', NULL, 2, NULL, N'2'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Khe cắm mở rộng PCI', NULL, 7, NULL, N'7'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'LED RGB', NULL, NULL, 1, N'Có'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Mặt kính cường lực', NULL, NULL, 1, N'Có'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Chuẩn case', N'Mid Tower', NULL, NULL, N'Mid Tower'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Hỗ trợ mainboard', N'ATX / Micro-ATX / Mini-ITX', NULL, NULL, N'ATX / Micro-ATX / Mini-ITX'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Hỗ trợ radiator tối đa', N'360 mm', NULL, NULL, N'360 mm'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Hỗ trợ GPU tối đa', N'420 mm', NULL, NULL, N'420 mm'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Hỗ trợ tản nhiệt CPU', N'185 mm', NULL, NULL, N'185 mm'),
(N'CASE-TRYX-LUCA-L70-BLACK', N'Case', N'Hỗ trợ PSU', N'ATX', NULL, NULL, N'ATX'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Số lượng quạt đi kèm', NULL, 0, NULL, N'0'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Cổng USB Type-C', NULL, 1, NULL, N'1'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Cổng USB 3.0', NULL, 1, NULL, N'1'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Khe cắm mở rộng PCI', NULL, 7, NULL, N'7'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'LED RGB', NULL, NULL, 0, N'Không'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Mặt kính cường lực', NULL, NULL, 1, N'Có'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Chuẩn case', N'Mid Tower', NULL, NULL, N'Mid Tower'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Hỗ trợ mainboard', N'ATX / Micro-ATX / Mini-ITX', NULL, NULL, N'ATX / Micro-ATX / Mini-ITX'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Hỗ trợ radiator tối đa', N'360 mm', NULL, NULL, N'360 mm'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Hỗ trợ GPU tối đa', N'390 mm', NULL, NULL, N'390 mm'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Hỗ trợ tản nhiệt CPU', N'168 mm', NULL, NULL, N'168 mm'),
(N'CASE-JONSBO-D300-BLACK', N'Case', N'Hỗ trợ PSU', N'ATX', NULL, NULL, N'ATX'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Số lượng quạt đi kèm', NULL, 0, NULL, N'0'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Cổng USB Type-C', NULL, 1, NULL, N'1'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Cổng USB 3.0', NULL, 4, NULL, N'4'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Khe cắm mở rộng PCI', NULL, 8, NULL, N'8'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'LED RGB', NULL, NULL, 0, N'Không'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Mặt kính cường lực', NULL, NULL, 1, N'Có'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Chuẩn case', N'Mid Tower', NULL, NULL, N'Mid Tower'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Hỗ trợ mainboard', N'E-ATX / ATX / Micro-ATX / Mini-ITX', NULL, NULL, N'E-ATX / ATX / Micro-ATX / Mini-ITX'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Hỗ trợ radiator tối đa', N'360 mm', NULL, NULL, N'360 mm'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Hỗ trợ GPU tối đa', N'400 mm', NULL, NULL, N'400 mm'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Hỗ trợ tản nhiệt CPU', N'190 mm', NULL, NULL, N'190 mm'),
(N'CASE-CORSAIR-6500X-BLACK', N'Case', N'Hỗ trợ PSU', N'ATX', NULL, NULL, N'ATX'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Số lượng quạt đi kèm', NULL, 4, NULL, N'4'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Cổng USB Type-C', NULL, 2, NULL, N'2'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Cổng USB 3.0', NULL, 4, NULL, N'4'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Khe cắm mở rộng PCI', NULL, 9, NULL, N'9'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'LED RGB', NULL, NULL, 1, N'Có'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Mặt kính cường lực', NULL, NULL, 1, N'Có'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Chuẩn case', N'Full Tower', NULL, NULL, N'Full Tower'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Hỗ trợ mainboard', N'E-ATX / ATX / Micro-ATX / Mini-ITX', NULL, NULL, N'E-ATX / ATX / Micro-ATX / Mini-ITX'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Hỗ trợ radiator tối đa', N'420 mm', NULL, NULL, N'420 mm'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Hỗ trợ GPU tối đa', N'460 mm', NULL, NULL, N'460 mm'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Hỗ trợ tản nhiệt CPU', N'190 mm', NULL, NULL, N'190 mm'),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'Case', N'Hỗ trợ PSU', N'ATX', NULL, NULL, N'ATX'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Số lượng quạt đi kèm', NULL, 0, NULL, N'0'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Cổng USB Type-C', NULL, 1, NULL, N'1'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Cổng USB 3.0', NULL, 2, NULL, N'2'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Khe cắm mở rộng PCI', NULL, 7, NULL, N'7'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'LED RGB', NULL, NULL, 1, N'Có'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Mặt kính cường lực', NULL, NULL, 1, N'Có'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Màu sắc', N'White', NULL, NULL, N'White'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Chuẩn case', N'Mid Tower', NULL, NULL, N'Mid Tower'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Hỗ trợ mainboard', N'ATX / Micro-ATX / Mini-ITX', NULL, NULL, N'ATX / Micro-ATX / Mini-ITX'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Hỗ trợ radiator tối đa', N'360 mm', NULL, NULL, N'360 mm'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Hỗ trợ GPU tối đa', N'400 mm', NULL, NULL, N'400 mm'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Hỗ trợ tản nhiệt CPU', N'165 mm', NULL, NULL, N'165 mm'),
(N'CASE-JONSBO-TK3-WHITE', N'Case', N'Hỗ trợ PSU', N'ATX', NULL, NULL, N'ATX'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Kiểu màn hình', N'Phẳng', NULL, NULL, N'Phẳng'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Kích thước màn hình', NULL, 27, NULL, N'27'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Tấm nền', N'IPS', NULL, NULL, N'IPS'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Độ phân giải', N'2K/QHD (2560 x 1440)', NULL, NULL, N'2K/QHD (2560 x 1440)'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Tần số quét', NULL, 180, NULL, N'180'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Thời gian phản hồi', N'1 ms', NULL, NULL, N'1 ms'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Không gian màu', N'99% sRGB', NULL, NULL, N'99% sRGB'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Độ sáng', N'300 cd/m²', NULL, NULL, N'300 cd/m²'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Khử nhấp nháy', NULL, NULL, 1, N'Có'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Cổng kết nối', N'DisplayPort 1.2 x1', NULL, NULL, N'DisplayPort 1.2 x1'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Cổng kết nối', N'HDMI 2.0 x1', NULL, NULL, N'HDMI 2.0 x1'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Tương thích VESA', N'100 x 100 mm', NULL, NULL, N'100 x 100 mm'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Phụ kiện trong hộp', N'Dây nguồn', NULL, NULL, N'Dây nguồn'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Phụ kiện trong hộp', N'Dây HDMI (optional)', NULL, NULL, N'Dây HDMI (optional)'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Phụ kiện trong hộp', N'Dây DisplayPort (optional)', NULL, NULL, N'Dây DisplayPort (optional)'),
(N'MON-SAMSUNG-27Q180-IPS', N'Màn hình', N'Nhu cầu sử dụng', N'Màn hình gaming', NULL, NULL, N'Màn hình gaming'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Kích thước màn hình', NULL, 32, NULL, N'32'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Tấm nền', N'QD-OLED', NULL, NULL, N'QD-OLED'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Độ phân giải', N'4K/UHD (3840 x 2160)', NULL, NULL, N'4K/UHD (3840 x 2160)'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Thời gian phản hồi', N'0.03 ms', NULL, NULL, N'0.03 ms'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Không gian màu', N'110% DCI-P3, 138% sRGB', NULL, NULL, N'110% DCI-P3, 138% sRGB'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Độ sáng', N'250 cd/m²', NULL, NULL, N'250 cd/m²'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Khử nhấp nháy', NULL, NULL, 1, N'Có'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Cổng kết nối', N'DisplayPort 2.1 x1', NULL, NULL, N'DisplayPort 2.1 x1'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Cổng kết nối', N'HDMI 2.1 x2', NULL, NULL, N'HDMI 2.1 x2'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Cổng kết nối', N'USB Type-C x1', NULL, NULL, N'USB Type-C x1'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Tương thích VESA', N'100 x 100 mm', NULL, NULL, N'100 x 100 mm'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Phụ kiện trong hộp', N'Dây nguồn', NULL, NULL, N'Dây nguồn'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Phụ kiện trong hộp', N'Dây HDMI (optional)', NULL, NULL, N'Dây HDMI (optional)'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Phụ kiện trong hộp', N'Dây DisplayPort (optional)', NULL, NULL, N'Dây DisplayPort (optional)'),
(N'MON-MSI-32U-QDOLED', N'Màn hình', N'Nhu cầu sử dụng', N'Màn hình gaming', NULL, NULL, N'Màn hình gaming'),
(N'HKC-MB27S9U', N'Màn hình', N'Model', N'MB27S9U', NULL, NULL, N'MB27S9U'),
(N'HKC-MB27S9U', N'Màn hình', N'Kích thước màn hình', NULL, 27, NULL, N'27'),
(N'HKC-MB27S9U', N'Màn hình', N'Tỉ lệ màn hình', N'16:9', NULL, NULL, N'16:9'),
(N'HKC-MB27S9U', N'Màn hình', N'Tấm nền', N'IPS', NULL, NULL, N'IPS'),
(N'HKC-MB27S9U', N'Màn hình', N'Độ phân giải', N'4K/UHD (3840 x 2160)', NULL, NULL, N'4K/UHD (3840 x 2160)'),
(N'HKC-MB27S9U', N'Màn hình', N'Tần số quét', NULL, 60, NULL, N'60'),
(N'HKC-MB27S9U', N'Màn hình', N'Thời gian phản hồi', N'5 ms', NULL, NULL, N'5 ms'),
(N'HKC-MB27S9U', N'Màn hình', N'Độ tương phản', N'1000:1', NULL, NULL, N'1000:1'),
(N'HKC-MB27S9U', N'Màn hình', N'Độ sáng', N'300 nits', NULL, NULL, N'300 nits'),
(N'HKC-MB27S9U', N'Màn hình', N'Góc nhìn', N'178/178', NULL, NULL, N'178/178'),
(N'HKC-MB27S9U', N'Màn hình', N'Không gian màu', N'sRGB 95%', NULL, NULL, N'sRGB 95%'),
(N'HKC-MB27S9U', N'Màn hình', N'Cổng kết nối', N'DVI x1', NULL, NULL, N'DVI x1'),
(N'HKC-MB27S9U', N'Màn hình', N'Cổng kết nối', N'DisplayPort 1.2 x1', NULL, NULL, N'DisplayPort 1.2 x1'),
(N'HKC-MB27S9U', N'Màn hình', N'Cổng kết nối', N'HDMI 2.0 x1', NULL, NULL, N'HDMI 2.0 x1'),
(N'HKC-MB27S9U', N'Màn hình', N'Cổng kết nối', N'HDMI 1.4 x1', NULL, NULL, N'HDMI 1.4 x1'),
(N'HKC-MB27S9U', N'Màn hình', N'Cổng kết nối', N'Audio out x1', NULL, NULL, N'Audio out x1'),
(N'HKC-MB27S9U', N'Màn hình', N'Tương thích VESA', N'75 x 75 mm', NULL, NULL, N'75 x 75 mm'),
(N'HKC-MB27S9U', N'Màn hình', N'Kích thước tổng thể', N'696 x 483 x 245 mm', NULL, NULL, N'696 x 483 x 245 mm'),
(N'HKC-MB27S9U', N'Màn hình', N'Trọng lượng', N'7.6 kg', NULL, NULL, N'7.6 kg'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Kích thước màn hình', NULL, 27, NULL, N'27'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Tấm nền', N'IPS', NULL, NULL, N'IPS'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Độ phân giải', N'2K/QHD (2560 x 1440)', NULL, NULL, N'2K/QHD (2560 x 1440)'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Thời gian phản hồi', N'0.5 ms', NULL, NULL, N'0.5 ms'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Không gian màu', N'99% sRGB', NULL, NULL, N'99% sRGB'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Độ sáng', N'250 cd/m²', NULL, NULL, N'250 cd/m²'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Khử nhấp nháy', NULL, NULL, 1, N'Có'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Cổng kết nối', N'HDMI 2.0 x2', NULL, NULL, N'HDMI 2.0 x2'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Cổng kết nối', N'DisplayPort 1.4 x1', NULL, NULL, N'DisplayPort 1.4 x1'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Tương thích VESA', N'75 x 75 mm', NULL, NULL, N'75 x 75 mm'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Phụ kiện trong hộp', N'Dây nguồn', NULL, NULL, N'Dây nguồn'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Phụ kiện trong hộp', N'Dây HDMI (optional)', NULL, NULL, N'Dây HDMI (optional)'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Phụ kiện trong hộp', N'Dây DisplayPort (optional)', NULL, NULL, N'Dây DisplayPort (optional)'),
(N'MON-ACER-27Q-IPS', N'Màn hình', N'Nhu cầu sử dụng', N'Màn hình gaming', NULL, NULL, N'Màn hình gaming'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Kích thước màn hình', NULL, 27, NULL, N'27'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Tấm nền', N'Fast IPS', NULL, NULL, N'Fast IPS'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Độ phân giải', N'2K/QHD (2560 x 1440)', NULL, NULL, N'2K/QHD (2560 x 1440)'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Thời gian phản hồi', N'1 ms', NULL, NULL, N'1 ms'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Không gian màu', N'107% NTSC, 120% sRGB, 98.5% DCI-P3', NULL, NULL, N'107% NTSC, 120% sRGB, 98.5% DCI-P3'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Độ sáng', N'300 cd/m²', NULL, NULL, N'300 cd/m²'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Khử nhấp nháy', NULL, NULL, 1, N'Có'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Cổng kết nối', N'HDMI 2.0 x2', NULL, NULL, N'HDMI 2.0 x2'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Cổng kết nối', N'DisplayPort 1.4 x1', NULL, NULL, N'DisplayPort 1.4 x1'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Tương thích VESA', N'100 x 100 mm', NULL, NULL, N'100 x 100 mm'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Phụ kiện trong hộp', N'Dây nguồn', NULL, NULL, N'Dây nguồn'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Phụ kiện trong hộp', N'Dây HDMI (optional)', NULL, NULL, N'Dây HDMI (optional)'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Phụ kiện trong hộp', N'Dây DisplayPort (optional)', NULL, NULL, N'Dây DisplayPort (optional)'),
(N'MON-AOC-27Q-FASTIPS', N'Màn hình', N'Nhu cầu sử dụng', N'Màn hình gaming', NULL, NULL, N'Màn hình gaming'),
(N'MON-GIGABYTE-32U-OLED', N'Màn hình', N'Kích thước màn hình', NULL, 32, NULL, N'32'),
(N'MON-GIGABYTE-32U-OLED', N'Màn hình', N'Tấm nền', N'OLED', NULL, NULL, N'OLED'),
(N'MON-GIGABYTE-32U-OLED', N'Màn hình', N'Độ phân giải', N'4K/UHD (3840 x 2160)', NULL, NULL, N'4K/UHD (3840 x 2160)'),
(N'MON-GIGABYTE-32U-OLED', N'Màn hình', N'Tương thích VESA', N'100 x 100 mm', NULL, NULL, N'100 x 100 mm'),
(N'MON-GIGABYTE-32U-OLED', N'Màn hình', N'Phụ kiện trong hộp', N'Cáp nguồn', NULL, NULL, N'Cáp nguồn'),
(N'MON-GIGABYTE-32U-OLED', N'Màn hình', N'Phụ kiện trong hộp', N'Cáp HDMI', NULL, NULL, N'Cáp HDMI'),
(N'MON-GIGABYTE-32U-OLED', N'Màn hình', N'Phụ kiện trong hộp', N'Sách hướng dẫn', NULL, NULL, N'Sách hướng dẫn'),
(N'MON-GIGABYTE-32U-OLED', N'Màn hình', N'Phụ kiện trong hộp', N'Cáp DisplayPort', NULL, NULL, N'Cáp DisplayPort'),
(N'MON-GIGABYTE-32U-OLED', N'Màn hình', N'Nhu cầu sử dụng', N'Gaming', NULL, NULL, N'Gaming'),
(N'MON-DELL-43U-IPSBLACK', N'Màn hình', N'Kích thước màn hình', NULL, 43, NULL, N'43'),
(N'MON-DELL-43U-IPSBLACK', N'Màn hình', N'Tấm nền', N'IPS Black', NULL, NULL, N'IPS Black'),
(N'MON-DELL-43U-IPSBLACK', N'Màn hình', N'Độ phân giải', N'4K/UHD (3840 x 2160)', NULL, NULL, N'4K/UHD (3840 x 2160)'),
(N'MON-DELL-43U-IPSBLACK', N'Màn hình', N'Tương thích VESA', N'100 x 100 mm', NULL, NULL, N'100 x 100 mm'),
(N'MON-DELL-43U-IPSBLACK', N'Màn hình', N'Phụ kiện trong hộp', N'Cáp nguồn', NULL, NULL, N'Cáp nguồn'),
(N'MON-DELL-43U-IPSBLACK', N'Màn hình', N'Phụ kiện trong hộp', N'Cáp HDMI', NULL, NULL, N'Cáp HDMI'),
(N'MON-DELL-43U-IPSBLACK', N'Màn hình', N'Phụ kiện trong hộp', N'Cáp DisplayPort', NULL, NULL, N'Cáp DisplayPort'),
(N'MON-DELL-43U-IPSBLACK', N'Màn hình', N'Phụ kiện trong hộp', N'Cáp USB-C', NULL, NULL, N'Cáp USB-C'),
(N'MON-DELL-43U-IPSBLACK', N'Màn hình', N'Nhu cầu sử dụng', N'Đồ họa', NULL, NULL, N'Đồ họa'),
(N'MON-DELL-43U-IPSBLACK', N'Màn hình', N'Nhu cầu sử dụng', N'Văn phòng', NULL, NULL, N'Văn phòng'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Kích thước màn hình', NULL, 27, NULL, N'27'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Tấm nền', N'IPS', NULL, NULL, N'IPS'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Độ phân giải', N'2K/QHD (2560 x 1440)', NULL, NULL, N'2K/QHD (2560 x 1440)'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Thời gian phản hồi', N'5 ms', NULL, NULL, N'5 ms'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Không gian màu', N'118% sRGB', NULL, NULL, N'118% sRGB'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Độ sáng', N'350 cd/m² (typ)', NULL, NULL, N'350 cd/m² (typ)'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Khử nhấp nháy', NULL, NULL, 1, N'Có'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Cổng kết nối', N'HDMI 2.0 x1', NULL, NULL, N'HDMI 2.0 x1'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Cổng kết nối', N'DisplayPort x1', NULL, NULL, N'DisplayPort x1'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Cổng kết nối', N'USB-A x3', NULL, NULL, N'USB-A x3'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Cổng kết nối', N'USB-C (DP-Alt 90W) x1', NULL, NULL, N'USB-C (DP-Alt 90W) x1'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Cổng kết nối', N'USB-C (15W) x1', NULL, NULL, N'USB-C (15W) x1'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Tương thích VESA', N'100 x 100 mm', NULL, NULL, N'100 x 100 mm'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Phụ kiện trong hộp', N'Dây nguồn', NULL, NULL, N'Dây nguồn'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Phụ kiện trong hộp', N'Dây HDMI (optional)', NULL, NULL, N'Dây HDMI (optional)'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Phụ kiện trong hộp', N'Dây DisplayPort (optional)', NULL, NULL, N'Dây DisplayPort (optional)'),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'Màn hình', N'Nhu cầu sử dụng', N'Màn hình đồ họa', NULL, NULL, N'Màn hình đồ họa'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Kích thước màn hình', NULL, 32, NULL, N'32'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Tấm nền', N'WOLED', NULL, NULL, N'WOLED'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Độ phân giải', N'4K/UHD (3840 x 2160)', NULL, NULL, N'4K/UHD (3840 x 2160)'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Dual mode', N'4K 240Hz - FHD 480Hz', NULL, NULL, N'4K 240Hz - FHD 480Hz'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Thời gian phản hồi', N'0.03 ms', NULL, NULL, N'0.03 ms'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Không gian màu', N'99% DCI-P3', NULL, NULL, N'99% DCI-P3'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Độ sáng', N'1300 cd/m²', NULL, NULL, N'1300 cd/m²'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Khử nhấp nháy', NULL, NULL, 1, N'Có'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Cổng kết nối', N'DisplayPort 1.4 x1', NULL, NULL, N'DisplayPort 1.4 x1'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Cổng kết nối', N'HDMI 2.1 x2', NULL, NULL, N'HDMI 2.1 x2'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Cổng kết nối', N'USB-C (DP Alt Mode, PD 15W) x1', NULL, NULL, N'USB-C (DP Alt Mode, PD 15W) x1'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Tương thích VESA', N'100 x 100 mm', NULL, NULL, N'100 x 100 mm'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Phụ kiện trong hộp', N'Dây nguồn', NULL, NULL, N'Dây nguồn'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Phụ kiện trong hộp', N'Dây HDMI (optional)', NULL, NULL, N'Dây HDMI (optional)'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Phụ kiện trong hộp', N'Dây DisplayPort (optional)', NULL, NULL, N'Dây DisplayPort (optional)'),
(N'MON-ASUS-32U-WOLED-DUAL', N'Màn hình', N'Nhu cầu sử dụng', N'Màn hình gaming', NULL, NULL, N'Màn hình gaming'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Kích thước màn hình', NULL, 27, NULL, N'27'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Tấm nền', N'Nano IPS', NULL, NULL, N'Nano IPS'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Độ phân giải', N'4K/UHD (3840 x 2160)', NULL, NULL, N'4K/UHD (3840 x 2160)'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Dual mode', N'4K 240Hz - FHD 480Hz', NULL, NULL, N'4K 240Hz - FHD 480Hz'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Thời gian phản hồi', N'GTG 1 ms', NULL, NULL, N'GTG 1 ms'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Không gian màu', N'99% DCI-P3', NULL, NULL, N'99% DCI-P3'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Độ sáng', N'750 cd/m²', NULL, NULL, N'750 cd/m²'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Khử nhấp nháy', NULL, NULL, 1, N'Có'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Cổng kết nối', N'HDMI x2', NULL, NULL, N'HDMI x2'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Cổng kết nối', N'DisplayPort x1', NULL, NULL, N'DisplayPort x1'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Tương thích VESA', N'100 x 100 mm', NULL, NULL, N'100 x 100 mm'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Phụ kiện trong hộp', N'Dây nguồn', NULL, NULL, N'Dây nguồn'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Phụ kiện trong hộp', N'Dây HDMI (optional)', NULL, NULL, N'Dây HDMI (optional)'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Phụ kiện trong hộp', N'Dây DisplayPort (optional)', NULL, NULL, N'Dây DisplayPort (optional)'),
(N'MON-LG-27U-NANOIPS-DUAL', N'Màn hình', N'Nhu cầu sử dụng', N'Màn hình gaming', NULL, NULL, N'Màn hình gaming'),
(N'KB-AKKO-5075B-PLUS-BWTVN', N'Bàn phím', N'Model', N'5075B Plus', NULL, NULL, N'5075B Plus'),
(N'KB-AKKO-5075B-PLUS-BWTVN', N'Bàn phím', N'Phương thức kết nối', N'Có dây / Bluetooth / Wireless 2.4GHz', NULL, NULL, N'Có dây / Bluetooth / Wireless 2.4GHz'),
(N'KB-AKKO-5075B-PLUS-BWTVN', N'Bàn phím', N'Kích thước/Layout', N'75%', NULL, NULL, N'75%'),
(N'KB-AKKO-5075B-PLUS-BWTVN', N'Bàn phím', N'Switch', N'Tùy phiên bản / hotswap', NULL, NULL, N'Tùy phiên bản / hotswap'),
(N'KB-AKKO-5075B-PLUS-BWTVN', N'Bàn phím', N'Chất liệu Keycap', N'PBT', NULL, NULL, N'PBT'),
(N'KB-AKKO-5075B-PLUS-BWTVN', N'Bàn phím', N'LED/RGB', N'RGB', NULL, NULL, N'RGB'),
(N'KB-AKKO-5075B-PLUS-BWTVN', N'Bàn phím', N'Màu sắc', N'Black / Red / White', NULL, NULL, N'Black / Red / White'),
(N'KB-AULA-F75-WHITE-RED', N'Bàn phím', N'Model', N'F7512', NULL, NULL, N'F7512'),
(N'KB-AULA-F75-WHITE-RED', N'Bàn phím', N'Phương thức kết nối', N'Có dây', NULL, NULL, N'Có dây'),
(N'KB-AULA-F75-WHITE-RED', N'Bàn phím', N'Kích thước/Layout', N'75%', NULL, NULL, N'75%'),
(N'KB-AULA-F75-WHITE-RED', N'Bàn phím', N'Switch', N'Red switch', NULL, NULL, N'Red switch'),
(N'KB-AULA-F75-WHITE-RED', N'Bàn phím', N'Chất liệu Keycap', N'ABS', NULL, NULL, N'ABS'),
(N'KB-AULA-F75-WHITE-RED', N'Bàn phím', N'LED/RGB', N'RGB', NULL, NULL, N'RGB'),
(N'KB-AULA-F75-WHITE-RED', N'Bàn phím', N'Màu sắc', N'White', NULL, NULL, N'White'),
(N'KB-DAREU-EK75-RT-BLACK', N'Bàn phím', N'Model', N'EK75 Rapid Trigger', NULL, NULL, N'EK75 Rapid Trigger'),
(N'KB-DAREU-EK75-RT-BLACK', N'Bàn phím', N'Phương thức kết nối', N'USB-C / USB', NULL, NULL, N'USB-C / USB'),
(N'KB-DAREU-EK75-RT-BLACK', N'Bàn phím', N'Kích thước/Layout', N'75% (compact)', NULL, NULL, N'75% (compact)'),
(N'KB-DAREU-EK75-RT-BLACK', N'Bàn phím', N'Switch', N'Rapid Trigger magnetic switch', NULL, NULL, N'Rapid Trigger magnetic switch'),
(N'KB-DAREU-EK75-RT-BLACK', N'Bàn phím', N'Chất liệu Keycap', N'PBT Double-Shot', NULL, NULL, N'PBT Double-Shot'),
(N'KB-DAREU-EK75-RT-BLACK', N'Bàn phím', N'LED/RGB', N'RGB', NULL, NULL, N'RGB'),
(N'KB-DAREU-EK75-RT-BLACK', N'Bàn phím', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'KB-DURGOD-CAVALRY-87-BLACK', N'Bàn phím', N'Model', N'Cavalry 87', NULL, NULL, N'Cavalry 87'),
(N'KB-DURGOD-CAVALRY-87-BLACK', N'Bàn phím', N'Phương thức kết nối', N'Wireless / USB-C', NULL, NULL, N'Wireless / USB-C'),
(N'KB-DURGOD-CAVALRY-87-BLACK', N'Bàn phím', N'Kích thước/Layout', N'TKL / Tenkeyless (80%)', NULL, NULL, N'TKL / Tenkeyless (80%)'),
(N'KB-DURGOD-CAVALRY-87-BLACK', N'Bàn phím', N'Switch', N'Kailh Turbo Silent Red', NULL, NULL, N'Kailh Turbo Silent Red'),
(N'KB-DURGOD-CAVALRY-87-BLACK', N'Bàn phím', N'Chất liệu Keycap', N'ABS', NULL, NULL, N'ABS'),
(N'KB-DURGOD-CAVALRY-87-BLACK', N'Bàn phím', N'LED/RGB', N'RGB', NULL, NULL, N'RGB'),
(N'KB-DURGOD-CAVALRY-87-BLACK', N'Bàn phím', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'KB-CORSAIR-K70-PRO-RED', N'Bàn phím', N'Model', N'K70 PRO', NULL, NULL, N'K70 PRO'),
(N'KB-CORSAIR-K70-PRO-RED', N'Bàn phím', N'Phương thức kết nối', N'Có dây', NULL, NULL, N'Có dây'),
(N'KB-CORSAIR-K70-PRO-RED', N'Bàn phím', N'Kích thước/Layout', N'Full-size (100%)', NULL, NULL, N'Full-size (100%)'),
(N'KB-CORSAIR-K70-PRO-RED', N'Bàn phím', N'Switch', N'Cherry MX Red', NULL, NULL, N'Cherry MX Red'),
(N'KB-CORSAIR-K70-PRO-RED', N'Bàn phím', N'Chất liệu Keycap', N'PBT Doubleshot', NULL, NULL, N'PBT Doubleshot'),
(N'KB-CORSAIR-K70-PRO-RED', N'Bàn phím', N'LED/RGB', N'RGB', NULL, NULL, N'RGB'),
(N'KB-CORSAIR-K70-PRO-RED', N'Bàn phím', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'KB-E-DRA-EK3104L-BETA-BROWN', N'Bàn phím', N'Model', N'EK3104L Beta', NULL, NULL, N'EK3104L Beta'),
(N'KB-E-DRA-EK3104L-BETA-BROWN', N'Bàn phím', N'Phương thức kết nối', N'USB', NULL, NULL, N'USB'),
(N'KB-E-DRA-EK3104L-BETA-BROWN', N'Bàn phím', N'Kích thước/Layout', N'Full-size (100%)', NULL, NULL, N'Full-size (100%)'),
(N'KB-E-DRA-EK3104L-BETA-BROWN', N'Bàn phím', N'Switch', N'Brown switch', NULL, NULL, N'Brown switch'),
(N'KB-E-DRA-EK3104L-BETA-BROWN', N'Bàn phím', N'Chất liệu Keycap', N'ABS', NULL, NULL, N'ABS'),
(N'KB-E-DRA-EK3104L-BETA-BROWN', N'Bàn phím', N'LED/RGB', N'Rainbow', NULL, NULL, N'Rainbow'),
(N'KB-E-DRA-EK3104L-BETA-BROWN', N'Bàn phím', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'KB-ASUS-ROG-SCOPE-II-96-WL-SNOW', N'Bàn phím', N'Model', N'ROG Strix Scope II 96 Wireless', NULL, NULL, N'ROG Strix Scope II 96 Wireless'),
(N'KB-ASUS-ROG-SCOPE-II-96-WL-SNOW', N'Bàn phím', N'Phương thức kết nối', N'Wireless 2.4GHz / Bluetooth / USB-C', NULL, NULL, N'Wireless 2.4GHz / Bluetooth / USB-C'),
(N'KB-ASUS-ROG-SCOPE-II-96-WL-SNOW', N'Bàn phím', N'Kích thước/Layout', N'96%', NULL, NULL, N'96%'),
(N'KB-ASUS-ROG-SCOPE-II-96-WL-SNOW', N'Bàn phím', N'Switch', N'ROG NX Snow', NULL, NULL, N'ROG NX Snow'),
(N'KB-ASUS-ROG-SCOPE-II-96-WL-SNOW', N'Bàn phím', N'Chất liệu Keycap', N'PBT', NULL, NULL, N'PBT'),
(N'KB-ASUS-ROG-SCOPE-II-96-WL-SNOW', N'Bàn phím', N'LED/RGB', N'RGB Aura Sync', NULL, NULL, N'RGB Aura Sync'),
(N'KB-ASUS-ROG-SCOPE-II-96-WL-SNOW', N'Bàn phím', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'KB-LOGITECH-G913-TKL-CLICKY', N'Bàn phím', N'Model', N'G913 TKL Lightspeed', NULL, NULL, N'G913 TKL Lightspeed'),
(N'KB-LOGITECH-G913-TKL-CLICKY', N'Bàn phím', N'Phương thức kết nối', N'Wireless 2.4GHz / Bluetooth', NULL, NULL, N'Wireless 2.4GHz / Bluetooth'),
(N'KB-LOGITECH-G913-TKL-CLICKY', N'Bàn phím', N'Kích thước/Layout', N'TKL / Tenkeyless (80%)', NULL, NULL, N'TKL / Tenkeyless (80%)'),
(N'KB-LOGITECH-G913-TKL-CLICKY', N'Bàn phím', N'Switch', N'GL Clicky', NULL, NULL, N'GL Clicky'),
(N'KB-LOGITECH-G913-TKL-CLICKY', N'Bàn phím', N'Chất liệu Keycap', N'PBT', NULL, NULL, N'PBT'),
(N'KB-LOGITECH-G913-TKL-CLICKY', N'Bàn phím', N'LED/RGB', N'RGB Lightsync', NULL, NULL, N'RGB Lightsync'),
(N'KB-LOGITECH-G913-TKL-CLICKY', N'Bàn phím', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'KB-RAZER-BLACKWIDOW-V4-PRO-GREEN', N'Bàn phím', N'Model', N'BlackWidow V4 Pro', NULL, NULL, N'BlackWidow V4 Pro'),
(N'KB-RAZER-BLACKWIDOW-V4-PRO-GREEN', N'Bàn phím', N'Phương thức kết nối', N'Có dây', NULL, NULL, N'Có dây'),
(N'KB-RAZER-BLACKWIDOW-V4-PRO-GREEN', N'Bàn phím', N'Kích thước/Layout', N'Full-size (100%)', NULL, NULL, N'Full-size (100%)'),
(N'KB-RAZER-BLACKWIDOW-V4-PRO-GREEN', N'Bàn phím', N'Switch', N'Razer Mechanical Green', NULL, NULL, N'Razer Mechanical Green'),
(N'KB-RAZER-BLACKWIDOW-V4-PRO-GREEN', N'Bàn phím', N'Chất liệu Keycap', N'Doubleshot ABS keycaps', NULL, NULL, N'Doubleshot ABS keycaps'),
(N'KB-RAZER-BLACKWIDOW-V4-PRO-GREEN', N'Bàn phím', N'LED/RGB', N'RGB Chroma', NULL, NULL, N'RGB Chroma'),
(N'KB-RAZER-BLACKWIDOW-V4-PRO-GREEN', N'Bàn phím', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'KB-RAPOO-V700-A8-DARKGREY-BLUE', N'Bàn phím', N'Model', N'V700-A8', NULL, NULL, N'V700-A8'),
(N'KB-RAPOO-V700-A8-DARKGREY-BLUE', N'Bàn phím', N'Phương thức kết nối', N'Có dây / Bluetooth / Wireless 2.4GHz', NULL, NULL, N'Có dây / Bluetooth / Wireless 2.4GHz'),
(N'KB-RAPOO-V700-A8-DARKGREY-BLUE', N'Bàn phím', N'Kích thước/Layout', N'84%', NULL, NULL, N'84%'),
(N'KB-RAPOO-V700-A8-DARKGREY-BLUE', N'Bàn phím', N'Switch', N'Blue switch', NULL, NULL, N'Blue switch');

INSERT INTO #SeedProductSpecifications (ProductSKU, CategoryName, SpecName, ValueText, ValueNumber, ValueBoolean, DisplayValue)
VALUES
(N'KB-RAPOO-V700-A8-DARKGREY-BLUE', N'Bàn phím', N'Chất liệu Keycap', N'PBT Double-Shot', NULL, NULL, N'PBT Double-Shot'),
(N'KB-RAPOO-V700-A8-DARKGREY-BLUE', N'Bàn phím', N'LED/RGB', N'RGB', NULL, NULL, N'RGB'),
(N'KB-RAPOO-V700-A8-DARKGREY-BLUE', N'Bàn phím', N'Màu sắc', N'Dark Grey', NULL, NULL, N'Dark Grey'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Kiểu dáng (Form)', N'Ergonomic', NULL, NULL, N'Ergonomic'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Kết nối', N'Có dây USB', NULL, NULL, N'Có dây USB'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Cảm biến (Sensor)', N'Quang học HERO', NULL, NULL, N'Quang học HERO'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Độ phân giải (DPI)', N'100 - 25600 DPI', NULL, NULL, N'100 - 25600 DPI'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Gia tốc tối đa (Max Acceleration)', N'40 G', NULL, NULL, N'40 G'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Polling Rate', N'1000 Hz', NULL, NULL, N'1000 Hz'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Số nút bấm', NULL, 11, NULL, N'11'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Trọng lượng', N'121 g', NULL, NULL, N'121 g'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Kích thước', N'131.2 x 75 x 40 mm', NULL, NULL, N'131.2 x 75 x 40 mm'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Đèn LED', N'RGB 16.8 triệu màu', NULL, NULL, N'RGB 16.8 triệu màu'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Phần mềm hỗ trợ', N'G HUB', NULL, NULL, N'G HUB'),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'Chuột', N'Phụ kiện đi kèm', N'Các khối nặng 5 x 3.6 g tùy chọn và tài liệu hướng dẫn sử dụng', NULL, NULL, N'Các khối nặng 5 x 3.6 g tùy chọn và tài liệu hướng dẫn sử dụng'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Màu sắc', N'Trắng', NULL, NULL, N'Trắng'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Kiểu dáng (Form)', N'Ergonomic / Thuận tay phải / Công thái học', NULL, NULL, N'Ergonomic / Thuận tay phải / Công thái học'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Kết nối', N'Không dây 2.4GHz / USB-C to USB-A', NULL, NULL, N'Không dây 2.4GHz / USB-C to USB-A'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Cảm biến (Sensor)', N'HERO 25K', NULL, NULL, N'HERO 25K'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Độ phân giải (DPI)', N'100 - 25000 DPI', NULL, NULL, N'100 - 25000 DPI'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Gia tốc tối đa (Max Acceleration)', N'40 G', NULL, NULL, N'40 G'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Polling Rate', N'1000 Hz', NULL, NULL, N'1000 Hz'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Loại switch', N'Switch Lightforce', NULL, NULL, N'Switch Lightforce'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Độ bền switch', N'60 - 100 triệu lần nhấn', NULL, NULL, N'60 - 100 triệu lần nhấn'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Số nút bấm', NULL, 13, NULL, N'13'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Trọng lượng', N'106 g', NULL, NULL, N'106 g'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Kích thước', N'131.4 x 79.2 x 41.1 mm', NULL, NULL, N'131.4 x 79.2 x 41.1 mm'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Thời lượng pin', N'130 giờ (37 giờ bật RGB)', NULL, NULL, N'130 giờ (37 giờ bật RGB)'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Loại pin', N'Pin sạc', NULL, NULL, N'Pin sạc'),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'Chuột', N'Cổng sạc', N'USB Type-C', NULL, NULL, N'USB Type-C'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Màu sắc', N'Trắng', NULL, NULL, N'Trắng'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Kiểu dáng (Form)', N'Đối xứng', NULL, NULL, N'Đối xứng'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Kết nối', N'Đa kết nối', NULL, NULL, N'Đa kết nối'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Cảm biến (Sensor)', N'Pixart PAW3950', NULL, NULL, N'Pixart PAW3950'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Độ phân giải (DPI)', N'50 - 30000 DPI', NULL, NULL, N'50 - 30000 DPI'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Gia tốc tối đa (Max Acceleration)', N'70 G', NULL, NULL, N'70 G'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Polling Rate', N'1000 Hz', NULL, NULL, N'1000 Hz'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Loại switch', N'Omron Optical Micro Switches', NULL, NULL, N'Omron Optical Micro Switches'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Độ bền switch', N'70 triệu lần nhấn', NULL, NULL, N'70 triệu lần nhấn'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Số nút bấm', NULL, 6, NULL, N'6'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Trọng lượng', N'Khoảng 49±3 g', NULL, NULL, N'Khoảng 49±3 g'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Kích thước', N'127 x 64 x 40 mm', NULL, NULL, N'127 x 64 x 40 mm'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Thời lượng pin', N'75 giờ', NULL, NULL, N'75 giờ'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Loại pin', N'Pin sạc Li-ion', NULL, NULL, N'Pin sạc Li-ion'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Cổng sạc', N'USB Type-C', NULL, NULL, N'USB Type-C'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Đèn LED', N'Không có', NULL, NULL, N'Không có'),
(N'MOU-ATK-PAW3950-WHITE', N'Chuột', N'Phần mềm hỗ trợ', N'Phần mềm riêng', NULL, NULL, N'Phần mềm riêng'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Màu sắc', N'Trắng', NULL, NULL, N'Trắng'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Kiểu dáng (Form)', N'Đối xứng', NULL, NULL, N'Đối xứng'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Kết nối', N'Đa kết nối', NULL, NULL, N'Đa kết nối'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Cảm biến (Sensor)', N'HyperX 26K Sensor', NULL, NULL, N'HyperX 26K Sensor'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Độ phân giải (DPI)', N'20000 - 26000 DPI', NULL, NULL, N'20000 - 26000 DPI'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Gia tốc tối đa (Max Acceleration)', N'50 G', NULL, NULL, N'50 G'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Polling Rate', N'1000 Hz', NULL, NULL, N'1000 Hz'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Loại switch', N'HyperX Switch', NULL, NULL, N'HyperX Switch'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Độ bền switch', N'80 - 100 triệu lần nhấn', NULL, NULL, N'80 - 100 triệu lần nhấn'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Số nút bấm', NULL, 6, NULL, N'6'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Trọng lượng', N'59 g', NULL, NULL, N'59 g'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Kích thước', N'116.6 x 61.9 x 36.5 mm', NULL, NULL, N'116.6 x 61.9 x 36.5 mm'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Thời lượng pin', N'100 giờ', NULL, NULL, N'100 giờ'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Loại pin', N'Pin sạc Li-ion', NULL, NULL, N'Pin sạc Li-ion'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Cổng sạc', N'USB Type-C', NULL, NULL, N'USB Type-C'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Đèn LED', N'RGB 16.8 triệu màu', NULL, NULL, N'RGB 16.8 triệu màu'),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'Chuột', N'Phần mềm hỗ trợ', N'Phần mềm riêng', NULL, NULL, N'Phần mềm riêng'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Màu sắc', N'Trắng', NULL, NULL, N'Trắng'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Kiểu dáng (Form)', N'Ergonomic', NULL, NULL, N'Ergonomic'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Kết nối', N'Wireless', NULL, NULL, N'Wireless'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Cảm biến (Sensor)', N'PixArt 26K Optical Sensor', NULL, NULL, N'PixArt 26K Optical Sensor'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Gia tốc tối đa (Max Acceleration)', N'50 G', NULL, NULL, N'50 G'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Polling Rate', N'8000 Hz', NULL, NULL, N'8000 Hz'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Loại switch', N'Omron mechanical', NULL, NULL, N'Omron mechanical'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Độ bền switch', N'80 - 100 triệu lần nhấn', NULL, NULL, N'80 - 100 triệu lần nhấn'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Số nút bấm', NULL, 10, NULL, N'10'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Trọng lượng', N'49 g', NULL, NULL, N'49 g'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Kích thước', N'121 x 66 x 42 mm', NULL, NULL, N'121 x 66 x 42 mm'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Thời lượng pin', N'Khoảng 500 – 750 giờ ở polling rate 1000 Hz (giảm ở mức polling cao hơn như 4000 Hz/8000 Hz)', NULL, NULL, N'Khoảng 500 – 750 giờ ở polling rate 1000 Hz (giảm ở mức polling cao hơn như 4000 Hz/8000 Hz)'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Loại pin', N'Pin sạc', NULL, NULL, N'Pin sạc'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Cổng sạc', N'USB Type-C', NULL, NULL, N'USB Type-C'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Đèn LED', N'Không có', NULL, NULL, N'Không có'),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'Chuột', N'Phần mềm hỗ trợ', N'Phần mềm riêng', NULL, NULL, N'Phần mềm riêng'),
(N'MOU-GLORIOUS-WIRED-BLACK', N'Chuột', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'MOU-GLORIOUS-WIRED-BLACK', N'Chuột', N'Kiểu dáng (Form)', N'Ergonomic', NULL, NULL, N'Ergonomic'),
(N'MOU-GLORIOUS-WIRED-BLACK', N'Chuột', N'Kết nối', N'Có dây USB', NULL, NULL, N'Có dây USB'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Kiểu dáng (Form)', N'Ergonomic / Công thái học', NULL, NULL, N'Ergonomic / Công thái học'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Kết nối', N'Không dây 2.4GHz / Bluetooth / USB-C to USB-A', NULL, NULL, N'Không dây 2.4GHz / Bluetooth / USB-C to USB-A'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Cảm biến (Sensor)', N'Quang học ROG AimPoint Pro', NULL, NULL, N'Quang học ROG AimPoint Pro'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Độ phân giải (DPI)', N'100 - 42000 DPI', NULL, NULL, N'100 - 42000 DPI'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Polling Rate', N'125 / 250 / 500 / 1000 / 8000 Hz', NULL, NULL, N'125 / 250 / 500 / 1000 / 8000 Hz'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Loại switch', N'ROG Micro Switch II', NULL, NULL, N'ROG Micro Switch II'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Độ bền switch', N'90 - 100 triệu lần nhấn', NULL, NULL, N'90 - 100 triệu lần nhấn'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Số nút bấm', NULL, 5, NULL, N'5'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Trọng lượng', N'65 g', NULL, NULL, N'65 g'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Kích thước', N'121 x 67 x 42 mm', NULL, NULL, N'121 x 67 x 42 mm'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Thời lượng pin', N'Không LED lên đến 192 giờ, có LED lên đến 91 giờ', NULL, NULL, N'Không LED lên đến 192 giờ, có LED lên đến 91 giờ'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Loại pin', N'Pin sạc', NULL, NULL, N'Pin sạc'),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'Chuột', N'Cổng sạc', N'USB Type-C', NULL, NULL, N'USB Type-C'),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột', N'Kiểu dáng (Form)', N'Đối xứng', NULL, NULL, N'Đối xứng'),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột', N'Kết nối', N'Đa kết nối', NULL, NULL, N'Đa kết nối'),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột', N'Cảm biến (Sensor)', N'BRAVO (ATG4090)', NULL, NULL, N'BRAVO (ATG4090)'),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột', N'Polling Rate', N'1000 Hz', NULL, NULL, N'1000 Hz'),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột', N'Độ bền switch', N'10 triệu lần nhấn', NULL, NULL, N'10 triệu lần nhấn'),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột', N'Số nút bấm', NULL, 6, NULL, N'6'),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột', N'Kích thước', N'124.5 x 68.6 x 39.6 mm', NULL, NULL, N'124.5 x 68.6 x 39.6 mm'),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột', N'Đèn LED', N'RGB 16.8 triệu màu', NULL, NULL, N'RGB 16.8 triệu màu'),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột', N'Phần mềm hỗ trợ', N'Phần mềm riêng', NULL, NULL, N'Phần mềm riêng'),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'Chuột', N'Phụ kiện đi kèm', N'Đầu thu USB, cáp sạc', NULL, NULL, N'Đầu thu USB, cáp sạc'),
(N'MOU-CORSAIR-WIRELESS-BLACK', N'Chuột', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'MOU-CORSAIR-WIRELESS-BLACK', N'Chuột', N'Kiểu dáng (Form)', N'Thuận tay phải', NULL, NULL, N'Thuận tay phải'),
(N'MOU-CORSAIR-WIRELESS-BLACK', N'Chuột', N'Kết nối', N'Đa kết nối', NULL, NULL, N'Đa kết nối'),
(N'MOU-CORSAIR-WIRELESS-BLACK', N'Chuột', N'Loại pin', N'Pin sạc Li-ion', NULL, NULL, N'Pin sạc Li-ion'),
(N'MOU-RAZER-WIRELESS-BLACK', N'Chuột', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'MOU-RAZER-WIRELESS-BLACK', N'Chuột', N'Kiểu dáng (Form)', N'Ergonomic', NULL, NULL, N'Ergonomic'),
(N'MOU-RAZER-WIRELESS-BLACK', N'Chuột', N'Kết nối', N'Đa kết nối', NULL, NULL, N'Đa kết nối'),
(N'MOU-RAZER-WIRELESS-BLACK', N'Chuột', N'Loại pin', N'Pin sạc Li-ion', NULL, NULL, N'Pin sạc Li-ion'),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'Tai nghe', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'Tai nghe', N'Phương thức kết nối', N'Không dây 2.4GHz / Bluetooth / USB-C có dây', NULL, NULL, N'Không dây 2.4GHz / Bluetooth / USB-C có dây'),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'Tai nghe', N'Cổng kết nối', N'Type-C', NULL, NULL, N'Type-C'),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'Tai nghe', N'Kiểu tai nghe', N'Over-ear', NULL, NULL, N'Over-ear'),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'Tai nghe', N'Driver', N'Titanium 50 mm', NULL, NULL, N'Titanium 50 mm'),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'Tai nghe', N'Trọng lượng', N'309 g', NULL, NULL, N'309 g'),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'Tai nghe', N'Thời lượng pin', N'Lên đến 70 giờ', NULL, NULL, N'Lên đến 70 giờ'),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'Tai nghe', N'RGB/LED', N'Aura Sync RGB', NULL, NULL, N'Aura Sync RGB'),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'Tai nghe', N'Tính năng nổi bật', N'Hỗ trợ PlayStation 5, ROG SpeedNova, driver titanium 50 mm', NULL, NULL, N'Hỗ trợ PlayStation 5, ROG SpeedNova, driver titanium 50 mm'),
(N'HS-EDIFIER-W830NB-BLACK', N'Tai nghe', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'HS-EDIFIER-W830NB-BLACK', N'Tai nghe', N'Phương thức kết nối', N'Bluetooth', NULL, NULL, N'Bluetooth'),
(N'HS-EDIFIER-W830NB-BLACK', N'Tai nghe', N'Cổng kết nối', N'Type-C', NULL, NULL, N'Type-C'),
(N'HS-EDIFIER-W830NB-BLACK', N'Tai nghe', N'Kiểu tai nghe', N'Over-ear', NULL, NULL, N'Over-ear'),
(N'HS-LOGITECH-G435-LIGHTSPEED-WHITE', N'Tai nghe', N'Màu sắc', N'White', NULL, NULL, N'White'),
(N'HS-LOGITECH-G435-LIGHTSPEED-WHITE', N'Tai nghe', N'Phương thức kết nối', N'Wireless / Bluetooth', NULL, NULL, N'Wireless / Bluetooth'),
(N'HS-LOGITECH-G435-LIGHTSPEED-WHITE', N'Tai nghe', N'Cổng kết nối', N'Type-C', NULL, NULL, N'Type-C'),
(N'HS-LOGITECH-G435-LIGHTSPEED-WHITE', N'Tai nghe', N'Kiểu tai nghe', N'Over-ear', NULL, NULL, N'Over-ear'),
(N'HS-RAPOO-VH600', N'Tai nghe', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'HS-RAPOO-VH600', N'Tai nghe', N'Phương thức kết nối', N'Có dây', NULL, NULL, N'Có dây'),
(N'HS-RAPOO-VH600', N'Tai nghe', N'Cổng kết nối', N'USB', NULL, NULL, N'USB'),
(N'HS-RAPOO-VH600', N'Tai nghe', N'Kiểu tai nghe', N'Over-ear', NULL, NULL, N'Over-ear'),
(N'HS-ONIKUMA-B5-TRIMODE-WHITE', N'Tai nghe', N'Màu sắc', N'Trắng', NULL, NULL, N'Trắng'),
(N'HS-ONIKUMA-B5-TRIMODE-WHITE', N'Tai nghe', N'Phương thức kết nối', N'Bluetooth / Có dây', NULL, NULL, N'Bluetooth / Có dây'),
(N'HS-ONIKUMA-B5-TRIMODE-WHITE', N'Tai nghe', N'Cổng kết nối', N'USB / Bluetooth / 3.5mm', NULL, NULL, N'USB / Bluetooth / 3.5mm'),
(N'HS-ONIKUMA-B5-TRIMODE-WHITE', N'Tai nghe', N'Kiểu tai nghe', N'Over-ear', NULL, NULL, N'Over-ear'),
(N'HS-ONIKUMA-B5-TRIMODE-WHITE', N'Tai nghe', N'RGB/LED', N'RGB', NULL, NULL, N'RGB'),
(N'HS-ONIKUMA-B5-TRIMODE-WHITE', N'Tai nghe', N'Tính năng nổi bật', N'Thiết kế tai mèo, Tri Mode, có biến thể Hồng / Trắng', NULL, NULL, N'Thiết kế tai mèo, Tri Mode, có biến thể Hồng / Trắng'),
(N'HS-RAZER-BLACKSHARK-V3PRO-CS2', N'Tai nghe', N'Màu sắc', N'Counter-Strike 2 Edition', NULL, NULL, N'Counter-Strike 2 Edition'),
(N'HS-RAZER-BLACKSHARK-V3PRO-CS2', N'Tai nghe', N'Phương thức kết nối', N'Wireless / USB receiver', NULL, NULL, N'Wireless / USB receiver'),
(N'HS-RAZER-BLACKSHARK-V3PRO-CS2', N'Tai nghe', N'Cổng kết nối', N'USB-A', NULL, NULL, N'USB-A'),
(N'HS-RAZER-BLACKSHARK-V3PRO-CS2', N'Tai nghe', N'Kiểu tai nghe', N'Over-ear', NULL, NULL, N'Over-ear'),
(N'HS-RAZER-BLACKSHARK-V3PRO-CS2', N'Tai nghe', N'Tính năng nổi bật', N'HyperClear Super Wideband microphone', NULL, NULL, N'HyperClear Super Wideband microphone'),
(N'HS-CORSAIR-VIRTUOSO-SE-ESPRESSO', N'Tai nghe', N'Màu sắc', N'Espresso', NULL, NULL, N'Espresso'),
(N'HS-CORSAIR-VIRTUOSO-SE-ESPRESSO', N'Tai nghe', N'Phương thức kết nối', N'Không dây 2.4GHz / Bluetooth / USB', NULL, NULL, N'Không dây 2.4GHz / Bluetooth / USB'),
(N'HS-CORSAIR-VIRTUOSO-SE-ESPRESSO', N'Tai nghe', N'Cổng kết nối', N'USB', NULL, NULL, N'USB'),
(N'HS-CORSAIR-VIRTUOSO-SE-ESPRESSO', N'Tai nghe', N'Kiểu tai nghe', N'Over-ear', NULL, NULL, N'Over-ear'),
(N'HS-CORSAIR-VIRTUOSO-SE-ESPRESSO', N'Tai nghe', N'RGB/LED', N'RGB', NULL, NULL, N'RGB'),
(N'HS-HYPERX-CLOUD-STINGER-CORE-II', N'Tai nghe', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'HS-HYPERX-CLOUD-STINGER-CORE-II', N'Tai nghe', N'Phương thức kết nối', N'Có dây', NULL, NULL, N'Có dây'),
(N'HS-HYPERX-CLOUD-STINGER-CORE-II', N'Tai nghe', N'Cổng kết nối', N'3.5mm', NULL, NULL, N'3.5mm'),
(N'HS-HYPERX-CLOUD-STINGER-CORE-II', N'Tai nghe', N'Kiểu tai nghe', N'Over-ear', NULL, NULL, N'Over-ear'),
(N'NET-ASUS-RT-AC1500UHP', N'Thiết bị mạng', N'Model', N'RT-AC1500UHP', NULL, NULL, N'RT-AC1500UHP'),
(N'NET-ASUS-RT-AC1500UHP', N'Thiết bị mạng', N'Chuẩn WiFi', N'WiFi 5 (802.11ac)', NULL, NULL, N'WiFi 5 (802.11ac)'),
(N'NET-ASUS-RT-AC1500UHP', N'Thiết bị mạng', N'Tốc độ tối đa', NULL, 1500, NULL, N'1500'),
(N'NET-ASUS-RT-AC1500UHP', N'Thiết bị mạng', N'Hỗ trợ tối đa', NULL, 20, NULL, N'20'),
(N'NET-ASUS-RT-AC1500UHP', N'Thiết bị mạng', N'Băng tần', N'2.4GHz / 5GHz', NULL, NULL, N'2.4GHz / 5GHz'),
(N'NET-ASUS-RT-AC1500UHP', N'Thiết bị mạng', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'NET-ASUS-RT-AC1500UHP', N'Thiết bị mạng', N'Tính năng nổi bật', N'MU-MIMO, tối ưu cho game, bảo mật Trend Micro, khả năng xuyên tường', NULL, NULL, N'MU-MIMO, tối ưu cho game, bảo mật Trend Micro, khả năng xuyên tường'),
(N'NET-ASUS-XT8-W2PK', N'Thiết bị mạng', N'Model', N'XT8 (W-2-PK)', NULL, NULL, N'XT8 (W-2-PK)'),
(N'NET-ASUS-XT8-W2PK', N'Thiết bị mạng', N'Chuẩn WiFi', N'WiFi 6 (802.11ax)', NULL, NULL, N'WiFi 6 (802.11ax)'),
(N'NET-ASUS-XT8-W2PK', N'Thiết bị mạng', N'Tốc độ tối đa', NULL, 6000, NULL, N'6000'),
(N'NET-ASUS-XT8-W2PK', N'Thiết bị mạng', N'Hỗ trợ tối đa', NULL, 60, NULL, N'60'),
(N'NET-ASUS-XT8-W2PK', N'Thiết bị mạng', N'Diện tích phủ sóng', NULL, 500, NULL, N'500'),
(N'NET-ASUS-XT8-W2PK', N'Thiết bị mạng', N'Băng tần', N'2.4GHz / 5GHz', NULL, NULL, N'2.4GHz / 5GHz'),
(N'NET-ASUS-XT8-W2PK', N'Thiết bị mạng', N'Màu sắc', N'Trắng', NULL, NULL, N'Trắng'),
(N'NET-ASUS-XT8-W2PK', N'Thiết bị mạng', N'Tính năng nổi bật', N'AiMesh, quản lý qua app, hệ mesh 2 pack', NULL, NULL, N'AiMesh, quản lý qua app, hệ mesh 2 pack'),
(N'NET-ASUS-RT-AX92U-2PACK', N'Thiết bị mạng', N'Model', N'RT-AX92U 2 Pack', NULL, NULL, N'RT-AX92U 2 Pack'),
(N'NET-ASUS-RT-AX92U-2PACK', N'Thiết bị mạng', N'Chuẩn WiFi', N'WiFi 6 / AX6100', NULL, NULL, N'WiFi 6 / AX6100'),
(N'NET-ASUS-RT-AX92U-2PACK', N'Thiết bị mạng', N'Tốc độ tối đa', NULL, 6100, NULL, N'6100'),
(N'NET-ASUS-RT-AX92U-2PACK', N'Thiết bị mạng', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'NET-ASUS-RT-AX92U-2PACK', N'Thiết bị mạng', N'Tính năng nổi bật', N'AiMesh WiFi System, 2 pack, gaming router, bảo mật mạng', NULL, NULL, N'AiMesh WiFi System, 2 pack, gaming router, bảo mật mạng'),
(N'NET-ASUS-RT-AC1300UHP', N'Thiết bị mạng', N'Model', N'RT-AC1300UHP', NULL, NULL, N'RT-AC1300UHP'),
(N'NET-ASUS-RT-AC1300UHP', N'Thiết bị mạng', N'Chuẩn WiFi', N'WiFi 5 / AC1300', NULL, NULL, N'WiFi 5 / AC1300'),
(N'NET-ASUS-RT-AC1300UHP', N'Thiết bị mạng', N'Tốc độ tối đa', NULL, 1300, NULL, N'1300'),
(N'NET-ASUS-RT-AC1300UHP', N'Thiết bị mạng', N'Băng tần', N'2.4GHz / 5GHz', NULL, NULL, N'2.4GHz / 5GHz'),
(N'NET-ASUS-RT-AC1300UHP', N'Thiết bị mạng', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'NET-ASUS-RT-AC1300UHP', N'Thiết bị mạng', N'Tính năng nổi bật', N'MU-MIMO, bộ xử lý 4 nhân, tối ưu cho game, bảo mật Trend Micro', NULL, NULL, N'MU-MIMO, bộ xử lý 4 nhân, tối ưu cho game, bảo mật Trend Micro'),
(N'NET-ASUS-RT-AC59U-AC1500', N'Thiết bị mạng', N'Model', N'RT-AC59U', NULL, NULL, N'RT-AC59U'),
(N'NET-ASUS-RT-AC59U-AC1500', N'Thiết bị mạng', N'Chuẩn WiFi', N'WiFi 5 / AC1500', NULL, NULL, N'WiFi 5 / AC1500'),
(N'NET-ASUS-RT-AC59U-AC1500', N'Thiết bị mạng', N'Tốc độ tối đa', NULL, 1500, NULL, N'1500'),
(N'NET-ASUS-RT-AC59U-AC1500', N'Thiết bị mạng', N'Băng tần', N'2.4GHz / 5GHz', NULL, NULL, N'2.4GHz / 5GHz'),
(N'NET-ASUS-RT-AC59U-AC1500', N'Thiết bị mạng', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'NET-ASUS-RT-AC59U-AC1500', N'Thiết bị mạng', N'Tính năng nổi bật', N'Mobile Gaming, MU-MIMO, 2 băng tần', NULL, NULL, N'Mobile Gaming, MU-MIMO, 2 băng tần'),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'Phần mềm', N'Mã sản phẩm', N'KW9-00664', NULL, NULL, N'KW9-00664'),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'Phần mềm', N'Phiên bản/Gói', N'Windows 11 Home', NULL, NULL, N'Windows 11 Home'),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'Phần mềm', N'Loại bản quyền', N'FPP(ESD) / Key điện tử', NULL, NULL, N'FPP(ESD) / Key điện tử'),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'Phần mềm', N'Kiến trúc hỗ trợ', N'32-bit / 64-bit', NULL, NULL, N'32-bit / 64-bit'),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'Phần mềm', N'Ngôn ngữ', N'All Language', NULL, NULL, N'All Language'),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'Phần mềm', N'Thời hạn', N'Vĩnh viễn', NULL, NULL, N'Vĩnh viễn'),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'Phần mềm', N'Số người dùng', NULL, 1, NULL, N'1'),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'Phần mềm', N'Số thiết bị', NULL, 1, NULL, N'1'),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'Phần mềm', N'AI/Copilot', N'Không', NULL, NULL, N'Không'),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'Phần mềm', N'Ghi chú', N'Có thể kích hoạt lại khi thay đổi phần cứng; không thể hoàn lại sau khi mua', NULL, NULL, N'Có thể kích hoạt lại khi thay đổi phần cứng; không thể hoàn lại sau khi mua'),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'Phần mềm', N'Mã sản phẩm', N'FQC-10572', NULL, NULL, N'FQC-10572'),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'Phần mềm', N'Phiên bản/Gói', N'Windows 11 Pro', NULL, NULL, N'Windows 11 Pro'),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'Phần mềm', N'Loại bản quyền', N'FPP(ESD) / Key điện tử', NULL, NULL, N'FPP(ESD) / Key điện tử'),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'Phần mềm', N'Kiến trúc hỗ trợ', N'32-bit / 64-bit', NULL, NULL, N'32-bit / 64-bit'),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'Phần mềm', N'Ngôn ngữ', N'All Language', NULL, NULL, N'All Language'),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'Phần mềm', N'Thời hạn', N'Vĩnh viễn', NULL, NULL, N'Vĩnh viễn'),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'Phần mềm', N'Số người dùng', NULL, 1, NULL, N'1'),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'Phần mềm', N'Số thiết bị', NULL, 1, NULL, N'1'),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'Phần mềm', N'AI/Copilot', N'Không', NULL, NULL, N'Không'),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'Phần mềm', N'Ghi chú', N'Có thể kích hoạt lại khi thay đổi phần cứng; không thể hoàn lại sau khi mua', NULL, NULL, N'Có thể kích hoạt lại khi thay đổi phần cứng; không thể hoàn lại sau khi mua'),
(N'SW-MICROSOFT-OFFICEHOME2024-EP206796', N'Phần mềm', N'Mã sản phẩm', N'EP2-06796', NULL, NULL, N'EP2-06796'),
(N'SW-MICROSOFT-OFFICEHOME2024-EP206796', N'Phần mềm', N'Phiên bản/Gói', N'Office Home 2024', NULL, NULL, N'Office Home 2024'),
(N'SW-MICROSOFT-OFFICEHOME2024-EP206796', N'Phần mềm', N'Loại bản quyền', N'Key điện tử', NULL, NULL, N'Key điện tử'),
(N'SW-MICROSOFT-OFFICEHOME2024-EP206796', N'Phần mềm', N'Thời hạn', N'Vĩnh viễn', NULL, NULL, N'Vĩnh viễn'),
(N'SW-MICROSOFT-OFFICEHOME2024-EP206796', N'Phần mềm', N'Số người dùng', NULL, 1, NULL, N'1'),
(N'SW-MICROSOFT-OFFICEHOME2024-EP206796', N'Phần mềm', N'Số thiết bị', NULL, 1, NULL, N'1'),
(N'SW-MICROSOFT-OFFICEHOME2024-EP206796', N'Phần mềm', N'AI/Copilot', N'Không', NULL, NULL, N'Không'),
(N'SW-MICROSOFT-OFFICEHOME2024-EP206796', N'Phần mềm', N'Ghi chú', N'Không thể hoàn lại sau khi mua', NULL, NULL, N'Không thể hoàn lại sau khi mua'),
(N'SW-MICROSOFT-365PERSONAL-EP232313', N'Phần mềm', N'Mã sản phẩm', N'EP2-32313', NULL, NULL, N'EP2-32313'),
(N'SW-MICROSOFT-365PERSONAL-EP232313', N'Phần mềm', N'Phiên bản/Gói', N'Microsoft 365 Personal', NULL, NULL, N'Microsoft 365 Personal'),
(N'SW-MICROSOFT-365PERSONAL-EP232313', N'Phần mềm', N'Loại bản quyền', N'Key điện tử / Thuê bao', NULL, NULL, N'Key điện tử / Thuê bao'),
(N'SW-MICROSOFT-365PERSONAL-EP232313', N'Phần mềm', N'Thời hạn', N'1 năm', NULL, NULL, N'1 năm'),
(N'SW-MICROSOFT-365PERSONAL-EP232313', N'Phần mềm', N'Số người dùng', NULL, 1, NULL, N'1'),
(N'SW-MICROSOFT-365PERSONAL-EP232313', N'Phần mềm', N'Số thiết bị', NULL, 5, NULL, N'5'),
(N'SW-MICROSOFT-365PERSONAL-EP232313', N'Phần mềm', N'AI/Copilot', N'Có', NULL, NULL, N'Có'),
(N'SW-MICROSOFT-365PERSONAL-EP232313', N'Phần mềm', N'Ghi chú', N'Không thể hoàn lại sau khi mua', NULL, NULL, N'Không thể hoàn lại sau khi mua'),
(N'SW-MICROSOFT-365FAMILY-EP236890', N'Phần mềm', N'Mã sản phẩm', N'EP2-36890', NULL, NULL, N'EP2-36890'),
(N'SW-MICROSOFT-365FAMILY-EP236890', N'Phần mềm', N'Phiên bản/Gói', N'Microsoft 365 Family', NULL, NULL, N'Microsoft 365 Family'),
(N'SW-MICROSOFT-365FAMILY-EP236890', N'Phần mềm', N'Loại bản quyền', N'Key điện tử / Thuê bao', NULL, NULL, N'Key điện tử / Thuê bao'),
(N'SW-MICROSOFT-365FAMILY-EP236890', N'Phần mềm', N'Thời hạn', N'1 năm', NULL, NULL, N'1 năm'),
(N'SW-MICROSOFT-365FAMILY-EP236890', N'Phần mềm', N'Số người dùng', NULL, 6, NULL, N'6'),
(N'SW-MICROSOFT-365FAMILY-EP236890', N'Phần mềm', N'Số thiết bị', NULL, 30, NULL, N'30'),
(N'SW-MICROSOFT-365FAMILY-EP236890', N'Phần mềm', N'AI/Copilot', N'Có', NULL, NULL, N'Có'),
(N'SW-MICROSOFT-365FAMILY-EP236890', N'Phần mềm', N'Ghi chú', N'Không thể hoàn lại sau khi mua', NULL, NULL, N'Không thể hoàn lại sau khi mua'),
(N'ACC-APPLE-SMARTKEYBOARD-IPAD129-4GEN', N'Phụ kiện', N'Loại phụ kiện', N'Bàn phím cho tablet/iPad', NULL, NULL, N'Bàn phím cho tablet/iPad'),
(N'ACC-APPLE-SMARTKEYBOARD-IPAD129-4GEN', N'Phụ kiện', N'Model/Mã sản phẩm', N'Smart Keyboard Folio', NULL, NULL, N'Smart Keyboard Folio'),
(N'ACC-APPLE-SMARTKEYBOARD-IPAD129-4GEN', N'Phụ kiện', N'Kết nối', N'Smart Connector', NULL, NULL, N'Smart Connector'),
(N'ACC-APPLE-SMARTKEYBOARD-IPAD129-4GEN', N'Phụ kiện', N'Cổng kết nối', N'Smart Connector', NULL, NULL, N'Smart Connector'),
(N'ACC-APPLE-SMARTKEYBOARD-IPAD129-4GEN', N'Phụ kiện', N'Tương thích', N'iPad Pro 12.9 inch (4th generation)', NULL, NULL, N'iPad Pro 12.9 inch (4th generation)'),
(N'ACC-APPLE-SMARTKEYBOARD-IPAD129-4GEN', N'Phụ kiện', N'Kích thước/Layout', N'Full-size (100%)', NULL, NULL, N'Full-size (100%)'),
(N'ACC-APPLE-SMARTKEYBOARD-IPAD129-4GEN', N'Phụ kiện', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'ACC-APPLE-SMARTKEYBOARD-IPAD129-4GEN', N'Phụ kiện', N'Tính năng nổi bật', N'Không cần sạc, gập bảo vệ màn hình, gõ nhanh tiện dụng', NULL, NULL, N'Không cần sạc, gập bảo vệ màn hình, gõ nhanh tiện dụng'),
(N'ACC-UGREEN-NEXODE-200W-CD271', N'Phụ kiện', N'Loại phụ kiện', N'Bộ sạc GaN', NULL, NULL, N'Bộ sạc GaN'),
(N'ACC-UGREEN-NEXODE-200W-CD271', N'Phụ kiện', N'Model/Mã sản phẩm', N'CD271 / 40913', NULL, NULL, N'CD271 / 40913'),
(N'ACC-UGREEN-NEXODE-200W-CD271', N'Phụ kiện', N'Kết nối', N'Sạc nhiều thiết bị', NULL, NULL, N'Sạc nhiều thiết bị'),
(N'ACC-UGREEN-NEXODE-200W-CD271', N'Phụ kiện', N'Cổng kết nối', N'4 x USB-C, 2 x USB-A', NULL, NULL, N'4 x USB-C, 2 x USB-A'),
(N'ACC-UGREEN-NEXODE-200W-CD271', N'Phụ kiện', N'Công suất', N'200W', NULL, NULL, N'200W'),
(N'ACC-UGREEN-NEXODE-200W-CD271', N'Phụ kiện', N'Tương thích', N'Laptop, tablet, điện thoại', NULL, NULL, N'Laptop, tablet, điện thoại'),
(N'ACC-UGREEN-NEXODE-200W-CD271', N'Phụ kiện', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'ACC-UGREEN-NEXODE-200W-CD271', N'Phụ kiện', N'Tính năng nổi bật', N'Sạc đồng thời 6 thiết bị, GaN II, bảo vệ quá nhiệt/quá tải', NULL, NULL, N'Sạc đồng thời 6 thiết bị, GaN II, bảo vệ quá nhiệt/quá tải'),
(N'ACC-UGREEN-HUB-5IN1-CM136', N'Phụ kiện', N'Loại phụ kiện', N'USB-C Hub / Adapter', NULL, NULL, N'USB-C Hub / Adapter'),
(N'ACC-UGREEN-HUB-5IN1-CM136', N'Phụ kiện', N'Model/Mã sản phẩm', N'CM136 / 50209', NULL, NULL, N'CM136 / 50209'),
(N'ACC-UGREEN-HUB-5IN1-CM136', N'Phụ kiện', N'Kết nối', N'USB-C', NULL, NULL, N'USB-C'),
(N'ACC-UGREEN-HUB-5IN1-CM136', N'Phụ kiện', N'Cổng kết nối', N'3 x USB 3.0, 1 x HDMI, 1 x USB-C PD', NULL, NULL, N'3 x USB 3.0, 1 x HDMI, 1 x USB-C PD'),
(N'ACC-UGREEN-HUB-5IN1-CM136', N'Phụ kiện', N'Công suất', N'PD 60W', NULL, NULL, N'PD 60W'),
(N'ACC-UGREEN-HUB-5IN1-CM136', N'Phụ kiện', N'Tương thích', N'Laptop, máy tính bảng, điện thoại', NULL, NULL, N'Laptop, máy tính bảng, điện thoại'),
(N'ACC-UGREEN-HUB-5IN1-CM136', N'Phụ kiện', N'Màu sắc', N'Xám', NULL, NULL, N'Xám'),
(N'ACC-UGREEN-HUB-5IN1-CM136', N'Phụ kiện', N'Tính năng nổi bật', N'USB 5Gbps, HDMI 4K 30Hz, thiết kế nhỏ gọn', NULL, NULL, N'USB 5Gbps, HDMI 4K 30Hz, thiết kế nhỏ gọn'),
(N'ACC-UGREEN-GAN-100W-CD226', N'Phụ kiện', N'Loại phụ kiện', N'Củ sạc GaN', NULL, NULL, N'Củ sạc GaN'),
(N'ACC-UGREEN-GAN-100W-CD226', N'Phụ kiện', N'Model/Mã sản phẩm', N'CD226 / 40747', NULL, NULL, N'CD226 / 40747'),
(N'ACC-UGREEN-GAN-100W-CD226', N'Phụ kiện', N'Kết nối', N'Sạc nhiều thiết bị', NULL, NULL, N'Sạc nhiều thiết bị'),
(N'ACC-UGREEN-GAN-100W-CD226', N'Phụ kiện', N'Cổng kết nối', N'3 x USB-C, 1 x USB-A', NULL, NULL, N'3 x USB-C, 1 x USB-A'),
(N'ACC-UGREEN-GAN-100W-CD226', N'Phụ kiện', N'Công suất', N'100W', NULL, NULL, N'100W'),
(N'ACC-UGREEN-GAN-100W-CD226', N'Phụ kiện', N'Tương thích', N'Laptop, tablet, điện thoại', NULL, NULL, N'Laptop, tablet, điện thoại'),
(N'ACC-UGREEN-GAN-100W-CD226', N'Phụ kiện', N'Màu sắc', N'Xám', NULL, NULL, N'Xám'),
(N'ACC-UGREEN-GAN-100W-CD226', N'Phụ kiện', N'Tính năng nổi bật', N'GaN nhỏ gọn, sạc nhanh đa cổng', NULL, NULL, N'GaN nhỏ gọn, sạc nhanh đa cổng'),
(N'ACC-MAZER-USBC-VGA-MUSBCAL351', N'Phụ kiện', N'Loại phụ kiện', N'Adapter chuyển đổi', NULL, NULL, N'Adapter chuyển đổi'),
(N'ACC-MAZER-USBC-VGA-MUSBCAL351', N'Phụ kiện', N'Model/Mã sản phẩm', N'M-USBCAL351-GY', NULL, NULL, N'M-USBCAL351-GY'),
(N'ACC-MAZER-USBC-VGA-MUSBCAL351', N'Phụ kiện', N'Kết nối', N'USB-C to VGA', NULL, NULL, N'USB-C to VGA'),
(N'ACC-MAZER-USBC-VGA-MUSBCAL351', N'Phụ kiện', N'Cổng kết nối', N'USB-C male / VGA female', NULL, NULL, N'USB-C male / VGA female'),
(N'ACC-MAZER-USBC-VGA-MUSBCAL351', N'Phụ kiện', N'Tương thích', N'Laptop, tablet hỗ trợ USB-C xuất hình', NULL, NULL, N'Laptop, tablet hỗ trợ USB-C xuất hình'),
(N'ACC-MAZER-USBC-VGA-MUSBCAL351', N'Phụ kiện', N'Màu sắc', N'Xám', NULL, NULL, N'Xám'),
(N'ACC-MAZER-USBC-VGA-MUSBCAL351', N'Phụ kiện', N'Tính năng nổi bật', N'Hỗ trợ 1080P, thiết kế nhôm nhỏ gọn', NULL, NULL, N'Hỗ trợ 1080P, thiết kế nhôm nhỏ gọn'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'Loại laptop', N'Gaming', NULL, NULL, N'Gaming'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'CPU', N'Intel Core i7-14650HX, 16 lõi 24 luồng, up to 5.2GHz', NULL, NULL, N'Intel Core i7-14650HX, 16 lõi 24 luồng, up to 5.2GHz'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'Card đồ họa', N'NVIDIA GeForce RTX 5060 8GB GDDR7 115W', NULL, NULL, N'NVIDIA GeForce RTX 5060 8GB GDDR7 115W'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'RAM', N'16GB (1 x 16GB) DDR5 5600MHz, nâng cấp tối đa 32GB', NULL, NULL, N'16GB (1 x 16GB) DDR5 5600MHz, nâng cấp tối đa 32GB'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'SSD', N'1TB PCIe 4.0 NVMe M.2', NULL, NULL, N'1TB PCIe 4.0 NVMe M.2'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'Kích thước màn hình', N'16 inch', NULL, NULL, N'16 inch'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'Độ phân giải', N'FHD+', NULL, NULL, N'FHD+'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'Tần số quét', N'165Hz', NULL, NULL, N'165Hz'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'Tấm nền', N'IPS', NULL, NULL, N'IPS'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'Hệ điều hành', N'Windows bản quyền tích hợp', NULL, NULL, N'Windows bản quyền tích hợp'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'Laptop', N'Tính năng nổi bật', N'Thiết kế bền bỉ chuẩn TUF, tối ưu cho gaming và học tập sáng tạo', NULL, NULL, N'Thiết kế bền bỉ chuẩn TUF, tối ưu cho gaming và học tập sáng tạo'),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'Laptop', N'Loại laptop', N'Gaming cao cấp', NULL, NULL, N'Gaming cao cấp'),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'Laptop', N'CPU', N'Intel Core Ultra 9-275HX, 24 nhân 24 luồng, turbo up to 5.4GHz', NULL, NULL, N'Intel Core Ultra 9-275HX, 24 nhân 24 luồng, turbo up to 5.4GHz'),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'Laptop', N'Card đồ họa', N'NVIDIA GeForce RTX 5070 Ti 12GB GDDR7, TGP 140W', NULL, NULL, N'NVIDIA GeForce RTX 5070 Ti 12GB GDDR7, TGP 140W'),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'Laptop', N'RAM', N'32GB (2 x 16GB) DDR5 6400MHz', NULL, NULL, N'32GB (2 x 16GB) DDR5 6400MHz'),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'Laptop', N'SSD', N'1TB SSD M.2 2242 PCIe 4.0x4 NVMe, hỗ trợ thêm khe 2280', NULL, NULL, N'1TB SSD M.2 2242 PCIe 4.0x4 NVMe, hỗ trợ thêm khe 2280'),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'Laptop', N'Kích thước màn hình', N'16 inch', NULL, NULL, N'16 inch'),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'Laptop', N'Pin', N'80Wh', NULL, NULL, N'80Wh'),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'Laptop', N'Hệ điều hành', N'Windows bản quyền tích hợp', NULL, NULL, N'Windows bản quyền tích hợp'),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'Laptop', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'Laptop', N'Tính năng nổi bật', N'AI Boost, hiệu năng gaming cao cấp, tản nhiệt mạnh', NULL, NULL, N'AI Boost, hiệu năng gaming cao cấp, tản nhiệt mạnh'),
(N'LAP-GIGABYTE-A16-CMHI2VN893SH', N'Laptop', N'Loại laptop', N'Gaming', NULL, NULL, N'Gaming'),
(N'LAP-GIGABYTE-A16-CMHI2VN893SH', N'Laptop', N'CPU', N'Intel Core i7-13620H, 10 nhân 16 luồng, turbo tối đa 4.9GHz', NULL, NULL, N'Intel Core i7-13620H, 10 nhân 16 luồng, turbo tối đa 4.9GHz'),
(N'LAP-GIGABYTE-A16-CMHI2VN893SH', N'Laptop', N'Card đồ họa', N'NVIDIA GeForce RTX 4050 Laptop GPU 6GB GDDR6', NULL, NULL, N'NVIDIA GeForce RTX 4050 Laptop GPU 6GB GDDR6'),
(N'LAP-GIGABYTE-A16-CMHI2VN893SH', N'Laptop', N'RAM', N'16GB DDR5 5200MHz (1 x 16GB)', NULL, NULL, N'16GB DDR5 5200MHz (1 x 16GB)'),
(N'LAP-GIGABYTE-A16-CMHI2VN893SH', N'Laptop', N'SSD', N'512GB', NULL, NULL, N'512GB'),
(N'LAP-GIGABYTE-A16-CMHI2VN893SH', N'Laptop', N'Kích thước màn hình', N'16 inch', NULL, NULL, N'16 inch'),
(N'LAP-GIGABYTE-A16-CMHI2VN893SH', N'Laptop', N'Hệ điều hành', N'Windows bản quyền tích hợp', NULL, NULL, N'Windows bản quyền tích hợp'),
(N'LAP-GIGABYTE-A16-CMHI2VN893SH', N'Laptop', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'LAP-GIGABYTE-A16-CMHI2VN893SH', N'Laptop', N'Tính năng nổi bật', N'Hiệu năng tốt cho gaming 1080p và đồ họa cơ bản', NULL, NULL, N'Hiệu năng tốt cho gaming 1080p và đồ họa cơ bản'),
(N'LAP-LG-GRAM-17ZD90Q-GAX52A5', N'Laptop', N'Loại laptop', N'Mỏng nhẹ / văn phòng', NULL, NULL, N'Mỏng nhẹ / văn phòng'),
(N'LAP-LG-GRAM-17ZD90Q-GAX52A5', N'Laptop', N'CPU', N'Intel Core i5-1240P', NULL, NULL, N'Intel Core i5-1240P'),
(N'LAP-LG-GRAM-17ZD90Q-GAX52A5', N'Laptop', N'Card đồ họa', N'Intel Iris Xe Graphics', NULL, NULL, N'Intel Iris Xe Graphics'),
(N'LAP-LG-GRAM-17ZD90Q-GAX52A5', N'Laptop', N'RAM', N'16GB', NULL, NULL, N'16GB'),
(N'LAP-LG-GRAM-17ZD90Q-GAX52A5', N'Laptop', N'SSD', N'512GB', NULL, NULL, N'512GB'),
(N'LAP-LG-GRAM-17ZD90Q-GAX52A5', N'Laptop', N'Kích thước màn hình', N'17 inch', NULL, NULL, N'17 inch'),
(N'LAP-LG-GRAM-17ZD90Q-GAX52A5', N'Laptop', N'Hệ điều hành', N'Windows bản quyền tích hợp', NULL, NULL, N'Windows bản quyền tích hợp'),
(N'LAP-LG-GRAM-17ZD90Q-GAX52A5', N'Laptop', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'LAP-LG-GRAM-17ZD90Q-GAX52A5', N'Laptop', N'Tính năng nổi bật', N'Thiết kế Gram siêu nhẹ, màn hình lớn cho làm việc và học tập', NULL, NULL, N'Thiết kế Gram siêu nhẹ, màn hình lớn cho làm việc và học tập'),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'Laptop', N'Loại laptop', N'Văn phòng / mỏng nhẹ', NULL, NULL, N'Văn phòng / mỏng nhẹ'),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'Laptop', N'CPU', N'Intel Core i7-1165G7', NULL, NULL, N'Intel Core i7-1165G7'),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'Laptop', N'Card đồ họa', N'Intel Iris Xe Graphics', NULL, NULL, N'Intel Iris Xe Graphics'),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'Laptop', N'RAM', N'16GB DDR4', NULL, NULL, N'16GB DDR4'),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'Laptop', N'SSD', N'1TB', NULL, NULL, N'1TB'),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'Laptop', N'Kích thước màn hình', N'13.3 inch', NULL, NULL, N'13.3 inch'),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'Laptop', N'Độ phân giải', N'FHD', NULL, NULL, N'FHD'),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'Laptop', N'Hệ điều hành', N'Windows 10 Home', NULL, NULL, N'Windows 10 Home'),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'Laptop', N'Màu sắc', N'Vàng', NULL, NULL, N'Vàng'),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'Laptop', N'Tính năng nổi bật', N'Thiết kế sang trọng, phù hợp làm việc và di chuyển', NULL, NULL, N'Thiết kế sang trọng, phù hợp làm việc và di chuyển'),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'Laptop', N'Loại laptop', N'Văn phòng', NULL, NULL, N'Văn phòng'),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'Laptop', N'CPU', N'Intel Core i7-1355U', NULL, NULL, N'Intel Core i7-1355U'),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'Laptop', N'Card đồ họa', N'Intel Iris Xe Graphics / Intel UHD Graphics', NULL, NULL, N'Intel Iris Xe Graphics / Intel UHD Graphics'),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'Laptop', N'RAM', N'16GB (2 x 8GB) DDR4 2666MHz, nâng cấp tối đa 64GB', NULL, NULL, N'16GB (2 x 8GB) DDR4 2666MHz, nâng cấp tối đa 64GB'),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'Laptop', N'SSD', N'1TB', NULL, NULL, N'1TB'),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'Laptop', N'Kích thước màn hình', N'15.6 inch', NULL, NULL, N'15.6 inch'),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'Laptop', N'Trọng lượng', N'1.9 kg', NULL, NULL, N'1.9 kg'),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'Laptop', N'Hệ điều hành', N'Windows bản quyền tích hợp', NULL, NULL, N'Windows bản quyền tích hợp'),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'Laptop', N'Màu sắc', N'Bạc', NULL, NULL, N'Bạc'),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'Laptop', N'Tính năng nổi bật', N'Cấu hình cân bằng cho văn phòng, học tập và giải trí đa phương tiện', NULL, NULL, N'Cấu hình cân bằng cho văn phòng, học tập và giải trí đa phương tiện'),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'Laptop', N'Loại laptop', N'Doanh nhân cao cấp', NULL, NULL, N'Doanh nhân cao cấp'),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'Laptop', N'CPU', N'Intel Core Ultra 7 258V, 8C (4P + 4LPE), max turbo 4.8GHz', NULL, NULL, N'Intel Core Ultra 7 258V, 8C (4P + 4LPE), max turbo 4.8GHz'),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'Laptop', N'Card đồ họa', N'Integrated Intel Arc Graphics 140V', NULL, NULL, N'Integrated Intel Arc Graphics 140V'),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'Laptop', N'RAM', N'32GB LPDDR5x-8533', NULL, NULL, N'32GB LPDDR5x-8533'),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'Laptop', N'SSD', N'1TB', NULL, NULL, N'1TB'),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'Laptop', N'Kích thước màn hình', N'15.6 inch', NULL, NULL, N'15.6 inch'),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'Laptop', N'Trọng lượng', N'1.5 kg', NULL, NULL, N'1.5 kg'),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'Laptop', N'Hệ điều hành', N'Windows bản quyền tích hợp', NULL, NULL, N'Windows bản quyền tích hợp'),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'Laptop', N'Màu sắc', N'Xám', NULL, NULL, N'Xám'),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'Laptop', N'Tính năng nổi bật', N'Thiết kế ThinkPad cao cấp, bảo hành 36 tháng, phù hợp doanh nhân', NULL, NULL, N'Thiết kế ThinkPad cao cấp, bảo hành 36 tháng, phù hợp doanh nhân'),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'Laptop', N'Loại laptop', N'Cao cấp / sáng tạo nội dung', NULL, NULL, N'Cao cấp / sáng tạo nội dung'),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'Laptop', N'CPU', N'Intel Core Ultra 9 288V', NULL, NULL, N'Intel Core Ultra 9 288V'),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'Laptop', N'Card đồ họa', N'Intel Arc', NULL, NULL, N'Intel Arc'),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'Laptop', N'RAM', N'32GB LPDDR5x-8533 (on-board)', NULL, NULL, N'32GB LPDDR5x-8533 (on-board)'),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'Laptop', N'SSD', N'2TB', NULL, NULL, N'2TB'),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'Laptop', N'Kích thước màn hình', N'16 inch', NULL, NULL, N'16 inch'),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'Laptop', N'Trọng lượng', N'1.5 kg', NULL, NULL, N'1.5 kg'),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'Laptop', N'Hệ điều hành', N'Windows bản quyền tích hợp', NULL, NULL, N'Windows bản quyền tích hợp'),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'Laptop', N'Màu sắc', N'Bạc', NULL, NULL, N'Bạc'),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'Laptop', N'Tính năng nổi bật', N'Phiên bản Mercedes-AMG, hiệu năng AI tốt, thiết kế cao cấp', NULL, NULL, N'Phiên bản Mercedes-AMG, hiệu năng AI tốt, thiết kế cao cấp'),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'Laptop', N'Loại laptop', N'Mỏng nhẹ / văn phòng', NULL, NULL, N'Mỏng nhẹ / văn phòng'),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'Laptop', N'CPU', N'Intel Core Ultra 5 225H, 14 lõi 14 luồng', NULL, NULL, N'Intel Core Ultra 5 225H, 14 lõi 14 luồng'),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'Laptop', N'Card đồ họa', N'Intel Arc 130T Graphics', NULL, NULL, N'Intel Arc 130T Graphics'),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'Laptop', N'RAM', N'16GB LPDDR5X 7500MHz (onboard)', NULL, NULL, N'16GB LPDDR5X 7500MHz (onboard)'),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'Laptop', N'SSD', N'1TB', NULL, NULL, N'1TB'),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'Laptop', N'Kích thước màn hình', N'14 inch', NULL, NULL, N'14 inch'),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'Laptop', N'Trọng lượng', N'1.28 kg', NULL, NULL, N'1.28 kg'),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'Laptop', N'Hệ điều hành', N'Windows bản quyền tích hợp', NULL, NULL, N'Windows bản quyền tích hợp'),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'Laptop', N'Màu sắc', N'Bạc', NULL, NULL, N'Bạc'),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'Laptop', N'Tính năng nổi bật', N'Tích hợp NPU AI, thiết kế mỏng nhẹ, phù hợp công việc di động', NULL, NULL, N'Tích hợp NPU AI, thiết kế mỏng nhẹ, phù hợp công việc di động'),
(N'LAP-ASUS-ZENBOOK14-UM3406KA-PP555WS', N'Laptop', N'Loại laptop', N'Ultrabook', NULL, NULL, N'Ultrabook'),
(N'LAP-ASUS-ZENBOOK14-UM3406KA-PP555WS', N'Laptop', N'CPU', N'AMD Ryzen AI 7 350', NULL, NULL, N'AMD Ryzen AI 7 350'),
(N'LAP-ASUS-ZENBOOK14-UM3406KA-PP555WS', N'Laptop', N'Card đồ họa', N'AMD Radeon', NULL, NULL, N'AMD Radeon'),
(N'LAP-ASUS-ZENBOOK14-UM3406KA-PP555WS', N'Laptop', N'RAM', N'16GB', NULL, NULL, N'16GB'),
(N'LAP-ASUS-ZENBOOK14-UM3406KA-PP555WS', N'Laptop', N'SSD', N'512GB', NULL, NULL, N'512GB'),
(N'LAP-ASUS-ZENBOOK14-UM3406KA-PP555WS', N'Laptop', N'Kích thước màn hình', N'14 inch', NULL, NULL, N'14 inch'),
(N'LAP-ASUS-ZENBOOK14-UM3406KA-PP555WS', N'Laptop', N'Hệ điều hành', N'Windows bản quyền tích hợp', NULL, NULL, N'Windows bản quyền tích hợp'),
(N'LAP-ASUS-ZENBOOK14-UM3406KA-PP555WS', N'Laptop', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'LAP-ASUS-ZENBOOK14-UM3406KA-PP555WS', N'Laptop', N'Tính năng nổi bật', N'Thiết kế Zenbook mỏng nhẹ, tối ưu làm việc di động', NULL, NULL, N'Thiết kế Zenbook mỏng nhẹ, tối ưu làm việc di động'),
(N'SPK-LOGITECH-G560', N'Loa', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'SPK-LOGITECH-G560', N'Loa', N'Phiên bản Bluetooth', N'4.1', NULL, NULL, N'4.1'),
(N'SPK-LOGITECH-G560', N'Loa', N'Công nghệ âm thanh', N'Codec định dạng âm thanh', NULL, NULL, N'Codec định dạng âm thanh'),
(N'SPK-LOGITECH-G560', N'Loa', N'LED RGB', N'Có', NULL, NULL, N'Có'),
(N'SPK-LOGITECH-G560', N'Loa', N'Điều chỉnh Bass/Treble', N'Có', NULL, NULL, N'Có'),
(N'SPK-LOGITECH-G560', N'Loa', N'Tỷ lệ SNR', N'≥80 dB', NULL, NULL, N'≥80 dB'),
(N'SPK-LOGITECH-G560', N'Loa', N'Tình trạng', N'Mới', NULL, NULL, N'Mới'),
(N'SPK-RAZER-NOMMO-V2', N'Loa', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'SPK-RAZER-NOMMO-V2', N'Loa', N'Phiên bản Bluetooth', N'5.3', NULL, NULL, N'5.3'),
(N'SPK-RAZER-NOMMO-V2', N'Loa', N'Công nghệ âm thanh', N'THX Spatial Audio', NULL, NULL, N'THX Spatial Audio'),
(N'SPK-RAZER-NOMMO-V2', N'Loa', N'LED RGB', N'Có', NULL, NULL, N'Có'),
(N'SPK-RAZER-NOMMO-V2', N'Loa', N'Điều chỉnh Bass/Treble', N'Có', NULL, NULL, N'Có'),
(N'SPK-RAZER-NOMMO-V2', N'Loa', N'Tỷ lệ SNR', N'≥90 dB', NULL, NULL, N'≥90 dB'),
(N'SPK-RAZER-NOMMO-V2', N'Loa', N'Tình trạng', N'Mới', NULL, NULL, N'Mới'),
(N'SPK-THONETVANDER-KUMPEL20-BLACK', N'Loa', N'Màu sắc', N'Black', NULL, NULL, N'Black'),
(N'SPK-THONETVANDER-KUMPEL20-BLACK', N'Loa', N'Phiên bản Bluetooth', N'5.0', NULL, NULL, N'5.0'),
(N'SPK-THONETVANDER-KUMPEL20-BLACK', N'Loa', N'Công nghệ âm thanh', N'Cấu trúc loa và phần cứng', NULL, NULL, N'Cấu trúc loa và phần cứng'),
(N'SPK-THONETVANDER-KUMPEL20-BLACK', N'Loa', N'LED RGB', N'Không', NULL, NULL, N'Không'),
(N'SPK-THONETVANDER-KUMPEL20-BLACK', N'Loa', N'Điều chỉnh Bass/Treble', N'Có', NULL, NULL, N'Có'),
(N'SPK-THONETVANDER-KUMPEL20-BLACK', N'Loa', N'Tỷ lệ SNR', N'≥80 dB', NULL, NULL, N'≥80 dB'),
(N'SPK-THONETVANDER-KUMPEL20-BLACK', N'Loa', N'Tình trạng', N'Mới', NULL, NULL, N'Mới'),
(N'SPK-RAZER-LEVIATHAN-V2X', N'Loa', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'SPK-RAZER-LEVIATHAN-V2X', N'Loa', N'Phiên bản Bluetooth', N'5.0', NULL, NULL, N'5.0'),
(N'SPK-RAZER-LEVIATHAN-V2X', N'Loa', N'Công nghệ âm thanh', N'THX Spatial Audio', NULL, NULL, N'THX Spatial Audio'),
(N'SPK-RAZER-LEVIATHAN-V2X', N'Loa', N'LED RGB', N'Có', NULL, NULL, N'Có'),
(N'SPK-RAZER-LEVIATHAN-V2X', N'Loa', N'Điều chỉnh Bass/Treble', N'Có', NULL, NULL, N'Có'),
(N'SPK-RAZER-LEVIATHAN-V2X', N'Loa', N'Tỷ lệ SNR', N'≥90 dB', NULL, NULL, N'≥90 dB'),
(N'SPK-RAZER-LEVIATHAN-V2X', N'Loa', N'Tình trạng', N'Mới', NULL, NULL, N'Mới'),
(N'SPK-RAZER-LEVIATHAN-V2', N'Loa', N'Màu sắc', N'Đen', NULL, NULL, N'Đen'),
(N'SPK-RAZER-LEVIATHAN-V2', N'Loa', N'Phiên bản Bluetooth', N'5.2', NULL, NULL, N'5.2'),
(N'SPK-RAZER-LEVIATHAN-V2', N'Loa', N'Công nghệ âm thanh', N'THX Spatial Audio', NULL, NULL, N'THX Spatial Audio'),
(N'SPK-RAZER-LEVIATHAN-V2', N'Loa', N'LED RGB', N'Có', NULL, NULL, N'Có'),
(N'SPK-RAZER-LEVIATHAN-V2', N'Loa', N'Điều chỉnh Bass/Treble', N'Có', NULL, NULL, N'Có'),
(N'SPK-RAZER-LEVIATHAN-V2', N'Loa', N'Tỷ lệ SNR', N'≥90 dB', NULL, NULL, N'≥90 dB'),
(N'SPK-RAZER-LEVIATHAN-V2', N'Loa', N'Tình trạng', N'Fullbox - NEW 100%', NULL, NULL, N'Fullbox - NEW 100%'),
(N'PCB-GVN-ROG-MIKU-9800X3D-5080', N'PC bộ', N'CPU', N'AMD Ryzen 7 9800X3D', NULL, NULL, N'AMD Ryzen 7 9800X3D'),
(N'PCB-GVN-ROG-MIKU-9800X3D-5080', N'PC bộ', N'Mainboard', N'X870E', NULL, NULL, N'X870E'),
(N'PCB-GVN-ROG-MIKU-9800X3D-5080', N'PC bộ', N'RAM', N'64GB', NULL, NULL, N'64GB'),
(N'PCB-GVN-ROG-MIKU-9800X3D-5080', N'PC bộ', N'SSD', N'1TB', NULL, NULL, N'1TB'),
(N'PCB-GVN-ROG-MIKU-9800X3D-5080', N'PC bộ', N'VGA', N'RTX 5080 16GB', NULL, NULL, N'RTX 5080 16GB'),
(N'PCB-GVN-ROG-MIKU-9800X3D-5080', N'PC bộ', N'Tính năng nổi bật', N'Phiên bản collab ASUS ROG Hatsune Miku, tối ưu cho gaming 4K và build trưng bày cao cấp', NULL, NULL, N'Phiên bản collab ASUS ROG Hatsune Miku, tối ưu cho gaming 4K và build trưng bày cao cấp'),
(N'PCB-GVN-I7-14700F-RTX3050', N'PC bộ', N'CPU', N'Intel Core i7-14700F', NULL, NULL, N'Intel Core i7-14700F'),
(N'PCB-GVN-I7-14700F-RTX3050', N'PC bộ', N'Mainboard', N'B760M', NULL, NULL, N'B760M'),
(N'PCB-GVN-I7-14700F-RTX3050', N'PC bộ', N'RAM', N'16GB', NULL, NULL, N'16GB'),
(N'PCB-GVN-I7-14700F-RTX3050', N'PC bộ', N'SSD', N'512GB', NULL, NULL, N'512GB'),
(N'PCB-GVN-I7-14700F-RTX3050', N'PC bộ', N'VGA', N'RTX 3050 6GB', NULL, NULL, N'RTX 3050 6GB'),
(N'PCB-GVN-I7-14700F-RTX3050', N'PC bộ', N'Tính năng nổi bật', N'Cấu hình cân bằng cho gaming eSports, học tập, làm việc và dựng nội dung cơ bản', NULL, NULL, N'Cấu hình cân bằng cho gaming eSports, học tập, làm việc và dựng nội dung cơ bản'),
(N'PCB-GVN-I5-14400F-RTX5060TI', N'PC bộ', N'CPU', N'Intel Core i5-14400F', NULL, NULL, N'Intel Core i5-14400F'),
(N'PCB-GVN-I5-14400F-RTX5060TI', N'PC bộ', N'Mainboard', N'B760M D4', NULL, NULL, N'B760M D4'),
(N'PCB-GVN-I5-14400F-RTX5060TI', N'PC bộ', N'RAM', N'8GB', NULL, NULL, N'8GB'),
(N'PCB-GVN-I5-14400F-RTX5060TI', N'PC bộ', N'SSD', N'512GB', NULL, NULL, N'512GB'),
(N'PCB-GVN-I5-14400F-RTX5060TI', N'PC bộ', N'VGA', N'RTX 5060 Ti 8GB', NULL, NULL, N'RTX 5060 Ti 8GB'),
(N'PCB-GVN-I5-14400F-RTX5060TI', N'PC bộ', N'Tính năng nổi bật', N'Phù hợp gaming 1080p/2K và dễ nâng cấp RAM để tối ưu hiệu năng dài hạn', NULL, NULL, N'Phù hợp gaming 1080p/2K và dễ nâng cấp RAM để tối ưu hiệu năng dài hạn'),
(N'PCB-GVN-R5-5600X-RX7600', N'PC bộ', N'CPU', N'AMD Ryzen 5 5600X', NULL, NULL, N'AMD Ryzen 5 5600X'),
(N'PCB-GVN-R5-5600X-RX7600', N'PC bộ', N'Mainboard', N'B550M', NULL, NULL, N'B550M'),
(N'PCB-GVN-R5-5600X-RX7600', N'PC bộ', N'RAM', N'8GB', NULL, NULL, N'8GB'),
(N'PCB-GVN-R5-5600X-RX7600', N'PC bộ', N'SSD', N'256GB', NULL, NULL, N'256GB'),
(N'PCB-GVN-R5-5600X-RX7600', N'PC bộ', N'VGA', N'Radeon RX 7600 8GB', NULL, NULL, N'Radeon RX 7600 8GB'),
(N'PCB-GVN-R5-5600X-RX7600', N'PC bộ', N'Tính năng nổi bật', N'Cấu hình AMD giá tốt cho gaming Full HD, làm việc hằng ngày và nâng cấp về sau', NULL, NULL, N'Cấu hình AMD giá tốt cho gaming Full HD, làm việc hằng ngày và nâng cấp về sau'),
(N'PCB-GVN-U5-225F-ARCB580', N'PC bộ', N'CPU', N'Intel Core Ultra 5 225F', NULL, NULL, N'Intel Core Ultra 5 225F'),
(N'PCB-GVN-U5-225F-ARCB580', N'PC bộ', N'Mainboard', N'B860M', NULL, NULL, N'B860M'),
(N'PCB-GVN-U5-225F-ARCB580', N'PC bộ', N'RAM', N'16GB', NULL, NULL, N'16GB'),
(N'PCB-GVN-U5-225F-ARCB580', N'PC bộ', N'SSD', N'500GB', NULL, NULL, N'500GB'),
(N'PCB-GVN-U5-225F-ARCB580', N'PC bộ', N'VGA', N'Intel Arc B580 12GB', NULL, NULL, N'Intel Arc B580 12GB'),
(N'PCB-GVN-U5-225F-ARCB580', N'PC bộ', N'Tính năng nổi bật', N'Nền tảng Intel Core Ultra mới, dùng RAM DDR5 và card Arc cho nhu cầu gaming, học tập, sáng tạo cơ bản', NULL, NULL, N'Nền tảng Intel Core Ultra mới, dùng RAM DDR5 và card Arc cho nhu cầu gaming, học tập, sáng tạo cơ bản'),
(N'PCB-GVN-U7-265F-RTX5080', N'PC bộ', N'CPU', N'Intel Core Ultra 7 265KF', NULL, NULL, N'Intel Core Ultra 7 265KF'),
(N'PCB-GVN-U7-265F-RTX5080', N'PC bộ', N'Mainboard', N'Z890', NULL, NULL, N'Z890'),
(N'PCB-GVN-U7-265F-RTX5080', N'PC bộ', N'RAM', N'16GB', NULL, NULL, N'16GB'),
(N'PCB-GVN-U7-265F-RTX5080', N'PC bộ', N'SSD', N'1TB', NULL, NULL, N'1TB'),
(N'PCB-GVN-U7-265F-RTX5080', N'PC bộ', N'VGA', N'RTX 5080 16GB', NULL, NULL, N'RTX 5080 16GB'),
(N'PCB-GVN-U7-265F-RTX5080', N'PC bộ', N'Tính năng nổi bật', N'Hiệu năng cao cho gaming 2K/4K, stream, render và xử lý đa nhiệm nặng', NULL, NULL, N'Hiệu năng cao cho gaming 2K/4K, stream, render và xử lý đa nhiệm nặng'),
(N'PCB-GVN-U7-265F-RTX5070', N'PC bộ', N'CPU', N'Intel Core Ultra 7 265KF', NULL, NULL, N'Intel Core Ultra 7 265KF'),
(N'PCB-GVN-U7-265F-RTX5070', N'PC bộ', N'Mainboard', N'Z890', NULL, NULL, N'Z890'),
(N'PCB-GVN-U7-265F-RTX5070', N'PC bộ', N'RAM', N'16GB', NULL, NULL, N'16GB'),
(N'PCB-GVN-U7-265F-RTX5070', N'PC bộ', N'SSD', N'512GB', NULL, NULL, N'512GB'),
(N'PCB-GVN-U7-265F-RTX5070', N'PC bộ', N'VGA', N'RTX 5070', NULL, NULL, N'RTX 5070'),
(N'PCB-GVN-U7-265F-RTX5070', N'PC bộ', N'Tính năng nổi bật', N'Cân bằng giữa hiệu năng cao và chi phí, phù hợp gaming nặng và làm việc sáng tạo', NULL, NULL, N'Cân bằng giữa hiệu năng cao và chi phí, phù hợp gaming nặng và làm việc sáng tạo'),
(N'PCB-GVN-R7-9800X3D-RTX5080-MSI', N'PC bộ', N'CPU', N'AMD Ryzen 7 9800X3D', NULL, NULL, N'AMD Ryzen 7 9800X3D'),
(N'PCB-GVN-R7-9800X3D-RTX5080-MSI', N'PC bộ', N'Mainboard', N'X870E', NULL, NULL, N'X870E'),
(N'PCB-GVN-R7-9800X3D-RTX5080-MSI', N'PC bộ', N'RAM', N'32GB', NULL, NULL, N'32GB'),
(N'PCB-GVN-R7-9800X3D-RTX5080-MSI', N'PC bộ', N'SSD', N'1TB', NULL, NULL, N'1TB'),
(N'PCB-GVN-R7-9800X3D-RTX5080-MSI', N'PC bộ', N'VGA', N'RTX 5080', NULL, NULL, N'RTX 5080'),
(N'PCB-GVN-R7-9800X3D-RTX5080-MSI', N'PC bộ', N'Tính năng nổi bật', N'Powered by MSI, tập trung vào hiệu năng gaming flagship và độ ổn định hệ thống', NULL, NULL, N'Powered by MSI, tập trung vào hiệu năng gaming flagship và độ ổn định hệ thống'),
(N'PCB-GVN-I7-14700F-RTX5080', N'PC bộ', N'CPU', N'Intel Core i7-14700F', NULL, NULL, N'Intel Core i7-14700F'),
(N'PCB-GVN-I7-14700F-RTX5080', N'PC bộ', N'Mainboard', N'B760', NULL, NULL, N'B760'),
(N'PCB-GVN-I7-14700F-RTX5080', N'PC bộ', N'RAM', N'32GB', NULL, NULL, N'32GB'),
(N'PCB-GVN-I7-14700F-RTX5080', N'PC bộ', N'SSD', N'1TB', NULL, NULL, N'1TB'),
(N'PCB-GVN-I7-14700F-RTX5080', N'PC bộ', N'VGA', N'RTX 5080', NULL, NULL, N'RTX 5080'),
(N'PCB-GVN-I7-14700F-RTX5080', N'PC bộ', N'Tính năng nổi bật', N'Cấu hình cao cấp cho gaming nặng, dựng video, stream và đa nhiệm cường độ cao', NULL, NULL, N'Cấu hình cao cấp cho gaming nặng, dựng video, stream và đa nhiệm cường độ cao');

INSERT INTO #SeedUsers (Email, PasswordHash, FullName, PhoneNumber, IsActive, MustChangePassword)
VALUES
(N'admin@powertech.vn', N'AQAAAAIAAYagAAAAEEyAxQC/1bajpgWzb3bNVBkWiE2HpYjurOHqhU4UK9lmQUujo9hT/BTRVvjjwjnx6g==', N'PowerTech Admin', N'0900000000', 1, 1),
(N'customer1@powertech.vn', N'AQAAAAIAAYagAAAAEBtJhxqOIxPSrcZ0nzl1qBRBFRBWHFqkOt7Y3cvKhlXix66YqwAxqF2cXTOCKvavxw==', N'Nguyen Van A', N'0901111111', 1, 0),
(N'support1@powertech.vn', N'AQAAAAIAAYagAAAAEKrQmpeDOEVd6lxftfKZrZyRepdv2b2szblzbZcGcDNW/KAfhVb6uYZRj6albGcIKA==', N'Tran Thi Support', N'0902222222', 1, 1);

INSERT INTO #SeedUserRoles (Email, RoleName)
VALUES
(N'admin@powertech.vn', N'Admin'),
(N'customer1@powertech.vn', N'Customer'),
(N'support1@powertech.vn', N'SupportStaff');

INSERT INTO #SeedUserAddresses (UserEmail, ReceiverName, PhoneNumber, Province, District, Ward, StreetAddress, IsDefault)
VALUES
(N'customer1@powertech.vn', N'Nguyen Van A', N'0901111111', N'TP.HCM', N'Go Vap', N'Ward 5', N'123 Nguyen Van Bao', 1);

INSERT INTO #SeedOrders (OrderCode, CustomerEmail, ReceiverName, PhoneNumber, ShippingAddress, OrderStatus, PaymentStatus, PaymentMethod, Subtotal, ShippingFee, TotalAmount, CreatedAt)
VALUES
(N'ORD-0001', N'customer1@powertech.vn', N'Nguyen Van A', N'0901111111', N'123 Nguyen Van Bao, Go Vap, TP.HCM', N'Pending', N'Unpaid', N'COD', 8580000, 30000, 8610000, CAST('2026-04-05 10:30:00' AS DATETIME2(7)));

INSERT INTO #SeedOrderItems (OrderCode, ProductSKU, ProductNameSnapshot, UnitPrice, Quantity, LineTotal)
VALUES
(N'ORD-0001', N'CPU-INTEL-I5-14400F', N'Intel Core i5-14400F', 4290000, 2, 8580000);

INSERT INTO #SeedPayments (OrderCode, PaymentMethod, PaymentStatus, Amount, TransactionCode, PaidAt, Note)
VALUES
(N'ORD-0001', N'COD', N'Unpaid', 8610000, NULL, NULL, N'Seeded from Orders sheet');

INSERT INTO #SeedReviews (ProductSKU, UserEmail, Rating, Comment, IsApproved, CreatedAt)
VALUES
(N'CPU-INTEL-I5-14400F', N'customer1@powertech.vn', 5, N'CPU ngon, chay on dinh', 1, CAST('2026-04-05 11:00:00' AS DATETIME2(7)));

INSERT INTO #SeedSupportTickets (TicketCode, UserEmail, Title, Content, Status, Priority, AssignedToEmail, CreatedAt)
VALUES
(N'TIC-0001', N'customer1@powertech.vn', N'Can ho tro bao hanh', N'San pham bi loi sau 2 ngay', N'Open', N'High', N'support1@powertech.vn', CAST('2026-04-05 12:00:00' AS DATETIME2(7)));

INSERT INTO #SeedProductImages (ProductSKU, ImageUrl, AltText, IsPrimary, SortOrder)
VALUES
(N'CPU-INTEL-CU5-245K', N'/uploads/products/cpu/intel-core-ultra-5-245k/gallery-1.jpg', N'Intel Core Ultra 5 245K gallery 1', 1, 1),
(N'CPU-INTEL-CU5-245K', N'/uploads/products/cpu/intel-core-ultra-5-245k/gallery-2.jpg', N'Intel Core Ultra 5 245K gallery 2', 0, 2),
(N'CPU-INTEL-CU5-245K', N'/uploads/products/cpu/intel-core-ultra-5-245k/gallery-3.jpg', N'Intel Core Ultra 5 245K gallery 3', 0, 3),
(N'CPU-INTEL-CU7-265K', N'/uploads/products/cpu/intel-core-ultra-7-265k/gallery-1.jpg', N'Intel Core Ultra 7 265K gallery 1', 1, 1),
(N'CPU-INTEL-CU7-265K', N'/uploads/products/cpu/intel-core-ultra-7-265k/gallery-2.jpg', N'Intel Core Ultra 7 265K gallery 2', 0, 2),
(N'CPU-INTEL-CU7-265K', N'/uploads/products/cpu/intel-core-ultra-7-265k/gallery-3.jpg', N'Intel Core Ultra 7 265K gallery 3', 0, 3),
(N'CPU-INTEL-CU9-285K', N'/uploads/products/cpu/intel-core-ultra-9-285k/gallery-1.jpg', N'Intel Core Ultra 9 285K gallery 1', 1, 1),
(N'CPU-INTEL-CU9-285K', N'/uploads/products/cpu/intel-core-ultra-9-285k/gallery-2.jpg', N'Intel Core Ultra 9 285K gallery 2', 0, 2),
(N'CPU-INTEL-CU9-285K', N'/uploads/products/cpu/intel-core-ultra-9-285k/gallery-3.jpg', N'Intel Core Ultra 9 285K gallery 3', 0, 3),
(N'CPU-INTEL-I3-14100', N'/uploads/products/cpu/intel-core-i3-14100/gallery-1.jpg', N'Intel Core i3 14100 gallery 1', 1, 1),
(N'CPU-INTEL-I3-14100', N'/uploads/products/cpu/intel-core-i3-14100/gallery-2.jpg', N'Intel Core i3 14100 gallery 2', 0, 2),
(N'CPU-INTEL-I3-14100', N'/uploads/products/cpu/intel-core-i3-14100/gallery-3.jpg', N'Intel Core i3 14100 gallery 3', 0, 3),
(N'CPU-AMD-R3-4300G', N'/uploads/products/cpu/amd-ryzen-3-4300g/gallery-1.jpg', N'AMD Ryzen 3 4300G gallery 1', 1, 1),
(N'CPU-AMD-R3-4300G', N'/uploads/products/cpu/amd-ryzen-3-4300g/gallery-2.jpg', N'AMD Ryzen 3 4300G gallery 2', 0, 2),
(N'CPU-AMD-R3-4300G', N'/uploads/products/cpu/amd-ryzen-3-4300g/gallery-3.jpg', N'AMD Ryzen 3 4300G gallery 3', 0, 3),
(N'CPU-AMD-R5-7600', N'/uploads/products/cpu/amd-ryzen-5-7600/gallery-1.jpg', N'AMD Ryzen 5 7600 gallery 1', 1, 1),
(N'CPU-AMD-R5-7600', N'/uploads/products/cpu/amd-ryzen-5-7600/gallery-2.jpg', N'AMD Ryzen 5 7600 gallery 2', 0, 2),
(N'CPU-AMD-R5-7600', N'/uploads/products/cpu/amd-ryzen-5-7600/gallery-3.jpg', N'AMD Ryzen 5 7600 gallery 3', 0, 3),
(N'CPU-AMD-R7-9700X', N'/uploads/products/cpu/amd-ryzen-7-9700x/gallery-1.jpg', N'AMD Ryzen 7 9700X gallery 1', 1, 1),
(N'CPU-AMD-R7-9700X', N'/uploads/products/cpu/amd-ryzen-7-9700x/gallery-2.jpg', N'AMD Ryzen 7 9700X gallery 2', 0, 2),
(N'CPU-AMD-R7-9700X', N'/uploads/products/cpu/amd-ryzen-7-9700x/gallery-3.jpg', N'AMD Ryzen 7 9700X gallery 3', 0, 3),
(N'CPU-AMD-R9-9950X', N'/uploads/products/cpu/amd-ryzen-9-9950x/gallery-1.jpg', N'AMD Ryzen 9 9950X gallery 1', 1, 1),
(N'CPU-AMD-R9-9950X', N'/uploads/products/cpu/amd-ryzen-9-9950x/gallery-2.jpg', N'AMD Ryzen 9 9950X gallery 2', 0, 2),
(N'CPU-AMD-R9-9950X', N'/uploads/products/cpu/amd-ryzen-9-9950x/gallery-3.jpg', N'AMD Ryzen 9 9950X gallery 3', 0, 3),
(N'CPU-AMD-ATHLON-3000G', N'/uploads/products/cpu/amd-athlon-3000g/gallery-1.jpg', N'AMD Athlon 3000G gallery 1', 1, 1),
(N'CPU-AMD-ATHLON-3000G', N'/uploads/products/cpu/amd-athlon-3000g/gallery-2.jpg', N'AMD Athlon 3000G gallery 2', 0, 2),
(N'CPU-AMD-ATHLON-3000G', N'/uploads/products/cpu/amd-athlon-3000g/gallery-3.jpg', N'AMD Athlon 3000G gallery 3', 0, 3),
(N'CPU-AMD-R9-9950X-TRAY', N'/uploads/products/cpu/amd-ryzen-9-9950x-tray/gallery-1.jpg', N'AMD Ryzen 9 9950X TRAY gallery 1', 1, 1),
(N'CPU-AMD-R9-9950X-TRAY', N'/uploads/products/cpu/amd-ryzen-9-9950x-tray/gallery-2.jpg', N'AMD Ryzen 9 9950X TRAY gallery 2', 0, 2),
(N'CPU-AMD-R9-9950X-TRAY', N'/uploads/products/cpu/amd-ryzen-9-9950x-tray/gallery-3.jpg', N'AMD Ryzen 9 9950X TRAY gallery 3', 0, 3),
(N'CMK8GX4M1E3200C16', N'/uploads/products/ram/corsair-vengeance-lpx-8gb-3200-cmk8gx4m1e3200c16/gallery-1.jpg', N'Corsair Vengeance LPX 8GB (1x8GB) 3200 DDR4 Black (CMK8GX4M1E3200C16) gallery 1', 1, 1),
(N'CMK8GX4M1E3200C16', N'/uploads/products/ram/corsair-vengeance-lpx-8gb-3200-cmk8gx4m1e3200c16/gallery-2.jpg', N'Corsair Vengeance LPX 8GB (1x8GB) 3200 DDR4 Black (CMK8GX4M1E3200C16) gallery 2', 0, 2),
(N'CMK8GX4M1E3200C16', N'/uploads/products/ram/corsair-vengeance-lpx-8gb-3200-cmk8gx4m1e3200c16/gallery-3.jpg', N'Corsair Vengeance LPX 8GB (1x8GB) 3200 DDR4 Black (CMK8GX4M1E3200C16) gallery 3', 0, 3),
(N'KF432C16BBA/8', N'/uploads/products/ram/kingston-fury-beast-8gb-3200-kf432c16bba-8/gallery-1.jpg', N'Kingston Fury Beast 8GB 3200 DDR4 RGB Black (KF432C16BBA/8) gallery 1', 1, 1),
(N'KF432C16BBA/8', N'/uploads/products/ram/kingston-fury-beast-8gb-3200-kf432c16bba-8/gallery-2.jpg', N'Kingston Fury Beast 8GB 3200 DDR4 RGB Black (KF432C16BBA/8) gallery 2', 0, 2),
(N'KF432C16BBA/8', N'/uploads/products/ram/kingston-fury-beast-8gb-3200-kf432c16bba-8/gallery-3.jpg', N'Kingston Fury Beast 8GB 3200 DDR4 RGB Black (KF432C16BBA/8) gallery 3', 0, 3),
(N'CMP32GX5M2B6000C30', N'/uploads/products/ram/corsair-dominator-titanium-black-32gb-6000-cmp32gx5m2b6000c30/gallery-1.jpg', N'Corsair Dominator Titanium Black 32GB (2x16GB) RGB 6000 DDR5 (CMP32GX5M2B6000C30) gallery 1', 1, 1),
(N'CMP32GX5M2B6000C30', N'/uploads/products/ram/corsair-dominator-titanium-black-32gb-6000-cmp32gx5m2b6000c30/gallery-2.jpg', N'Corsair Dominator Titanium Black 32GB (2x16GB) RGB 6000 DDR5 (CMP32GX5M2B6000C30) gallery 2', 0, 2),
(N'CMP32GX5M2B6000C30', N'/uploads/products/ram/corsair-dominator-titanium-black-32gb-6000-cmp32gx5m2b6000c30/gallery-3.jpg', N'Corsair Dominator Titanium Black 32GB (2x16GB) RGB 6000 DDR5 (CMP32GX5M2B6000C30) gallery 3', 0, 3),
(N'CMH32GX5M2B5600C40W', N'/uploads/products/ram/corsair-vengeance-rgb-white-32gb-5600-cmh32gx5m2b5600c40w/gallery-1.jpg', N'Corsair Vengeance RGB White 32GB (2x16GB) 5600 DDR5 (CMH32GX5M2B5600C40W) gallery 1', 1, 1),
(N'CMH32GX5M2B5600C40W', N'/uploads/products/ram/corsair-vengeance-rgb-white-32gb-5600-cmh32gx5m2b5600c40w/gallery-2.jpg', N'Corsair Vengeance RGB White 32GB (2x16GB) 5600 DDR5 (CMH32GX5M2B5600C40W) gallery 2', 0, 2),
(N'CMH32GX5M2B5600C40W', N'/uploads/products/ram/corsair-vengeance-rgb-white-32gb-5600-cmh32gx5m2b5600c40w/gallery-3.jpg', N'Corsair Vengeance RGB White 32GB (2x16GB) 5600 DDR5 (CMH32GX5M2B5600C40W) gallery 3', 0, 3),
(N'CMP64GX5M2B6000C30W', N'/uploads/products/ram/corsair-dominator-titanium-white-64gb-6000-cmp64gx5m2b6000c30w/gallery-1.jpg', N'Corsair Dominator Titanium White 64GB (2x32GB) RGB 6000 DDR5 (CMP64GX5M2B6000C30W) gallery 1', 1, 1),
(N'CMP64GX5M2B6000C30W', N'/uploads/products/ram/corsair-dominator-titanium-white-64gb-6000-cmp64gx5m2b6000c30w/gallery-2.jpg', N'Corsair Dominator Titanium White 64GB (2x32GB) RGB 6000 DDR5 (CMP64GX5M2B6000C30W) gallery 2', 0, 2),
(N'CMP64GX5M2B6000C30W', N'/uploads/products/ram/corsair-dominator-titanium-white-64gb-6000-cmp64gx5m2b6000c30w/gallery-3.jpg', N'Corsair Dominator Titanium White 64GB (2x32GB) RGB 6000 DDR5 (CMP64GX5M2B6000C30W) gallery 3', 0, 3),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'/uploads/products/ram/teamgroup-tforce-delta-black-16gb-3600/gallery-1.jpg', N'TeamGroup T-Force Delta RGB Black 16GB (1x16GB) 3600 DDR4 gallery 1', 1, 1),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'/uploads/products/ram/teamgroup-tforce-delta-black-16gb-3600/gallery-2.jpg', N'TeamGroup T-Force Delta RGB Black 16GB (1x16GB) 3600 DDR4 gallery 2', 0, 2),
(N'RAM-TEAMGROUP-TFORCE-DELTA-16G-3600-BLACK', N'/uploads/products/ram/teamgroup-tforce-delta-black-16gb-3600/gallery-3.jpg', N'TeamGroup T-Force Delta RGB Black 16GB (1x16GB) 3600 DDR4 gallery 3', 0, 3),
(N'F5-5600J4040C16GX2-TZ5RS', N'/uploads/products/ram/gskill-trident-z5-rgb-32gb-5600-f5-5600j4040c16gx2-tz5rs/gallery-1.jpg', N'G.Skill Trident Z5 RGB 32GB (2x16GB) 5600 DDR5 Silver CL40 (F5-5600J4040C16GX2-TZ5RS) gallery 1', 1, 1),
(N'F5-5600J4040C16GX2-TZ5RS', N'/uploads/products/ram/gskill-trident-z5-rgb-32gb-5600-f5-5600j4040c16gx2-tz5rs/gallery-2.jpg', N'G.Skill Trident Z5 RGB 32GB (2x16GB) 5600 DDR5 Silver CL40 (F5-5600J4040C16GX2-TZ5RS) gallery 2', 0, 2),
(N'F5-5600J4040C16GX2-TZ5RS', N'/uploads/products/ram/gskill-trident-z5-rgb-32gb-5600-f5-5600j4040c16gx2-tz5rs/gallery-3.jpg', N'G.Skill Trident Z5 RGB 32GB (2x16GB) 5600 DDR5 Silver CL40 (F5-5600J4040C16GX2-TZ5RS) gallery 3', 0, 3),
(N'F5-6000J3040G32GX2-TZ5RS', N'/uploads/products/ram/gskill-trident-z5-rgb-64gb-6000-f5-6000j3040g32gx2-tz5rs/gallery-1.jpg', N'G.Skill Trident Z5 RGB 64GB (2x32GB) 6000 DDR5 Silver (F5-6000J3040G32GX2-TZ5RS) gallery 1', 1, 1),
(N'F5-6000J3040G32GX2-TZ5RS', N'/uploads/products/ram/gskill-trident-z5-rgb-64gb-6000-f5-6000j3040g32gx2-tz5rs/gallery-2.jpg', N'G.Skill Trident Z5 RGB 64GB (2x32GB) 6000 DDR5 Silver (F5-6000J3040G32GX2-TZ5RS) gallery 2', 0, 2),
(N'F5-6000J3040G32GX2-TZ5RS', N'/uploads/products/ram/gskill-trident-z5-rgb-64gb-6000-f5-6000j3040g32gx2-tz5rs/gallery-3.jpg', N'G.Skill Trident Z5 RGB 64GB (2x32GB) 6000 DDR5 Silver (F5-6000J3040G32GX2-TZ5RS) gallery 3', 0, 3),
(N'CMH96GX5M2B5600C40', N'/uploads/products/ram/corsair-vengeance-rgb-96gb-5600-cmh96gx5m2b5600c40/gallery-1.jpg', N'Corsair Vengeance RGB 96GB (2x48GB) 5600 DDR5 Black (CMH96GX5M2B5600C40) gallery 1', 1, 1),
(N'CMH96GX5M2B5600C40', N'/uploads/products/ram/corsair-vengeance-rgb-96gb-5600-cmh96gx5m2b5600c40/gallery-2.jpg', N'Corsair Vengeance RGB 96GB (2x48GB) 5600 DDR5 Black (CMH96GX5M2B5600C40) gallery 2', 0, 2),
(N'CMH96GX5M2B5600C40', N'/uploads/products/ram/corsair-vengeance-rgb-96gb-5600-cmh96gx5m2b5600c40/gallery-3.jpg', N'Corsair Vengeance RGB 96GB (2x48GB) 5600 DDR5 Black (CMH96GX5M2B5600C40) gallery 3', 0, 3),
(N'CMP96GX5M2B6600C32', N'/uploads/products/ram/corsair-dominator-titanium-black-96gb-6600-cmp96gx5m2b6600c32/gallery-1.jpg', N'Corsair Dominator Titanium Black 96GB (2x48GB) RGB 6600 DDR5 (CMP96GX5M2B6600C32) gallery 1', 1, 1),
(N'CMP96GX5M2B6600C32', N'/uploads/products/ram/corsair-dominator-titanium-black-96gb-6600-cmp96gx5m2b6600c32/gallery-2.jpg', N'Corsair Dominator Titanium Black 96GB (2x48GB) RGB 6600 DDR5 (CMP96GX5M2B6600C32) gallery 2', 0, 2),
(N'CMP96GX5M2B6600C32', N'/uploads/products/ram/corsair-dominator-titanium-black-96gb-6600-cmp96gx5m2b6600c32/gallery-3.jpg', N'Corsair Dominator Titanium Black 96GB (2x48GB) RGB 6600 DDR5 (CMP96GX5M2B6600C32) gallery 3', 0, 3),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'/uploads/products/gpu/asus-rog-matrix-rtx4090-24g/gallery-1.jpg', N'ASUS ROG Matrix GeForce RTX 4090 24GB GDDR6X gallery 1', 1, 1),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'/uploads/products/gpu/asus-rog-matrix-rtx4090-24g/gallery-2.jpg', N'ASUS ROG Matrix GeForce RTX 4090 24GB GDDR6X gallery 2', 0, 2),
(N'GPU-ASUS-ROGMATRIX-RTX4090-24G', N'/uploads/products/gpu/asus-rog-matrix-rtx4090-24g/gallery-3.jpg', N'ASUS ROG Matrix GeForce RTX 4090 24GB GDDR6X gallery 3', 0, 3),
(N'GPU-ASUS-RTX4070SUPER-12G', N'/uploads/products/gpu/asus-rtx4070-super-12g/gallery-1.jpg', N'ASUS GeForce RTX 4070 SUPER 12GB GDDR6X gallery 1', 1, 1),
(N'GPU-ASUS-RTX4070SUPER-12G', N'/uploads/products/gpu/asus-rtx4070-super-12g/gallery-2.jpg', N'ASUS GeForce RTX 4070 SUPER 12GB GDDR6X gallery 2', 0, 2),
(N'GPU-ASUS-RTX4070SUPER-12G', N'/uploads/products/gpu/asus-rtx4070-super-12g/gallery-3.jpg', N'ASUS GeForce RTX 4070 SUPER 12GB GDDR6X gallery 3', 0, 3),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'/uploads/products/gpu/asus-tuf-rtx5070ti-16g/gallery-1.jpg', N'ASUS TUF Gaming GeForce RTX 5070 Ti 16GB GDDR7 gallery 1', 1, 1),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'/uploads/products/gpu/asus-tuf-rtx5070ti-16g/gallery-2.jpg', N'ASUS TUF Gaming GeForce RTX 5070 Ti 16GB GDDR7 gallery 2', 0, 2),
(N'GPU-ASUS-TUF-RTX5070TI-16G', N'/uploads/products/gpu/asus-tuf-rtx5070ti-16g/gallery-3.jpg', N'ASUS TUF Gaming GeForce RTX 5070 Ti 16GB GDDR7 gallery 3', 0, 3),
(N'GPU-ASUS-ROG-RTX5080-16G', N'/uploads/products/gpu/asus-rog-rtx5080-16g/gallery-1.jpg', N'ASUS ROG GeForce RTX 5080 16GB GDDR7 gallery 1', 1, 1),
(N'GPU-ASUS-ROG-RTX5080-16G', N'/uploads/products/gpu/asus-rog-rtx5080-16g/gallery-2.jpg', N'ASUS ROG GeForce RTX 5080 16GB GDDR7 gallery 2', 0, 2),
(N'GPU-ASUS-ROG-RTX5080-16G', N'/uploads/products/gpu/asus-rog-rtx5080-16g/gallery-3.jpg', N'ASUS ROG GeForce RTX 5080 16GB GDDR7 gallery 3', 0, 3),
(N'GPU-ASUS-TUF-RTX5090-32G', N'/uploads/products/gpu/asus-tuf-rtx5090-32g/gallery-1.jpg', N'ASUS TUF Gaming GeForce RTX 5090 32GB GDDR7 gallery 1', 1, 1),
(N'GPU-ASUS-TUF-RTX5090-32G', N'/uploads/products/gpu/asus-tuf-rtx5090-32g/gallery-2.jpg', N'ASUS TUF Gaming GeForce RTX 5090 32GB GDDR7 gallery 2', 0, 2),
(N'GPU-ASUS-TUF-RTX5090-32G', N'/uploads/products/gpu/asus-tuf-rtx5090-32g/gallery-3.jpg', N'ASUS TUF Gaming GeForce RTX 5090 32GB GDDR7 gallery 3', 0, 3),
(N'MB-ASUS-ROG-Z890-HERO', N'/uploads/products/mainboard/asus-rog-maximus-z890-hero/gallery-1.jpg', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 HERO (DDR5) gallery 1', 1, 1),
(N'MB-ASUS-ROG-Z890-HERO', N'/uploads/products/mainboard/asus-rog-maximus-z890-hero/gallery-2.jpg', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 HERO (DDR5) gallery 2', 0, 2),
(N'MB-ASUS-ROG-Z890-HERO', N'/uploads/products/mainboard/asus-rog-maximus-z890-hero/gallery-3.jpg', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 HERO (DDR5) gallery 3', 0, 3),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'/uploads/products/mainboard/asus-proart-z890-creator-wifi/gallery-1.jpg', N'Bo mạch chủ ASUS ProArt Z890-CREATOR WIFI (DDR5) gallery 1', 1, 1),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'/uploads/products/mainboard/asus-proart-z890-creator-wifi/gallery-2.jpg', N'Bo mạch chủ ASUS ProArt Z890-CREATOR WIFI (DDR5) gallery 2', 0, 2),
(N'MB-ASUS-PROART-Z890-CREATOR-WIFI', N'/uploads/products/mainboard/asus-proart-z890-creator-wifi/gallery-3.jpg', N'Bo mạch chủ ASUS ProArt Z890-CREATOR WIFI (DDR5) gallery 3', 0, 3),
(N'MB-ASUS-ROG-Z890-APEX', N'/uploads/products/mainboard/asus-rog-maximus-z890-apex/gallery-1.jpg', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 APEX (DDR5) gallery 1', 1, 1),
(N'MB-ASUS-ROG-Z890-APEX', N'/uploads/products/mainboard/asus-rog-maximus-z890-apex/gallery-2.jpg', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 APEX (DDR5) gallery 2', 0, 2),
(N'MB-ASUS-ROG-Z890-APEX', N'/uploads/products/mainboard/asus-rog-maximus-z890-apex/gallery-3.jpg', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 APEX (DDR5) gallery 3', 0, 3),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'/uploads/products/mainboard/gigabyte-z890-aorus-elite-wifi7/gallery-1.jpg', N'Bo mạch chủ GIGABYTE Z890 AORUS ELITE WIFI7 (DDR5) gallery 1', 1, 1),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'/uploads/products/mainboard/gigabyte-z890-aorus-elite-wifi7/gallery-2.jpg', N'Bo mạch chủ GIGABYTE Z890 AORUS ELITE WIFI7 (DDR5) gallery 2', 0, 2),
(N'MB-GIGABYTE-Z890-AORUS-ELITE-WIFI7', N'/uploads/products/mainboard/gigabyte-z890-aorus-elite-wifi7/gallery-3.jpg', N'Bo mạch chủ GIGABYTE Z890 AORUS ELITE WIFI7 (DDR5) gallery 3', 0, 3),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'/uploads/products/mainboard/gigabyte-z890-eagle-wifi7/gallery-1.jpg', N'Bo mạch chủ GIGABYTE Z890 EAGLE WIFI7 (DDR5) gallery 1', 1, 1),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'/uploads/products/mainboard/gigabyte-z890-eagle-wifi7/gallery-2.jpg', N'Bo mạch chủ GIGABYTE Z890 EAGLE WIFI7 (DDR5) gallery 2', 0, 2),
(N'MB-GIGABYTE-Z890-EAGLE-WIFI7', N'/uploads/products/mainboard/gigabyte-z890-eagle-wifi7/gallery-3.jpg', N'Bo mạch chủ GIGABYTE Z890 EAGLE WIFI7 (DDR5) gallery 3', 0, 3),
(N'MB-ASUS-ROG-Z890-EXTREME', N'/uploads/products/mainboard/asus-rog-maximus-z890-extreme/gallery-1.jpg', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 EXTREME (DDR5) gallery 1', 1, 1),
(N'MB-ASUS-ROG-Z890-EXTREME', N'/uploads/products/mainboard/asus-rog-maximus-z890-extreme/gallery-2.jpg', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 EXTREME (DDR5) gallery 2', 0, 2),
(N'MB-ASUS-ROG-Z890-EXTREME', N'/uploads/products/mainboard/asus-rog-maximus-z890-extreme/gallery-3.jpg', N'Bo mạch chủ ASUS ROG MAXIMUS Z890 EXTREME (DDR5) gallery 3', 0, 3),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'/uploads/products/mainboard/gigabyte-h610m-h-v3-ddr4/gallery-1.jpg', N'Bo mạch chủ GIGABYTE H610M-H V3 (DDR4) gallery 1', 1, 1),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'/uploads/products/mainboard/gigabyte-h610m-h-v3-ddr4/gallery-2.jpg', N'Bo mạch chủ GIGABYTE H610M-H V3 (DDR4) gallery 2', 0, 2),
(N'MB-GIGABYTE-H610M-H-V3-DDR4', N'/uploads/products/mainboard/gigabyte-h610m-h-v3-ddr4/gallery-3.jpg', N'Bo mạch chủ GIGABYTE H610M-H V3 (DDR4) gallery 3', 0, 3),
(N'SSD-SAMSUNG-9100PRO-1TB', N'/uploads/products/storage/samsung-9100-pro-1tb/gallery-1.jpg', N'Samsung 9100 PRO 1TB gallery 1', 1, 1),
(N'SSD-SAMSUNG-9100PRO-1TB', N'/uploads/products/storage/samsung-9100-pro-1tb/gallery-2.jpg', N'Samsung 9100 PRO 1TB gallery 2', 0, 2),
(N'SSD-SAMSUNG-9100PRO-1TB', N'/uploads/products/storage/samsung-9100-pro-1tb/gallery-3.jpg', N'Samsung 9100 PRO 1TB gallery 3', 0, 3),
(N'SSD-SAMSUNG-990PRO-2TB', N'/uploads/products/storage/samsung-990-pro-2tb/gallery-1.jpg', N'Samsung 990 PRO 2TB gallery 1', 1, 1),
(N'SSD-SAMSUNG-990PRO-2TB', N'/uploads/products/storage/samsung-990-pro-2tb/gallery-2.jpg', N'Samsung 990 PRO 2TB gallery 2', 0, 2),
(N'SSD-SAMSUNG-990PRO-2TB', N'/uploads/products/storage/samsung-990-pro-2tb/gallery-3.jpg', N'Samsung 990 PRO 2TB gallery 3', 0, 3),
(N'SSD-KINGSTON-NV3-500GB', N'/uploads/products/storage/kingston-nv3-500gb/gallery-1.jpg', N'Kingston NV3 500GB gallery 1', 1, 1),
(N'SSD-KINGSTON-NV3-500GB', N'/uploads/products/storage/kingston-nv3-500gb/gallery-2.jpg', N'Kingston NV3 500GB gallery 2', 0, 2),
(N'SSD-KINGSTON-NV3-500GB', N'/uploads/products/storage/kingston-nv3-500gb/gallery-3.jpg', N'Kingston NV3 500GB gallery 3', 0, 3),
(N'SSD-KINGSTON-NV3-1TB', N'/uploads/products/storage/kingston-nv3-1tb/gallery-1.jpg', N'Kingston NV3 1TB gallery 1', 1, 1),
(N'SSD-KINGSTON-NV3-1TB', N'/uploads/products/storage/kingston-nv3-1tb/gallery-2.jpg', N'Kingston NV3 1TB gallery 2', 0, 2),
(N'SSD-KINGSTON-NV3-1TB', N'/uploads/products/storage/kingston-nv3-1tb/gallery-3.jpg', N'Kingston NV3 1TB gallery 3', 0, 3),
(N'SSD-KINGSTON-NV3-2TB', N'/uploads/products/storage/kingston-nv3-2tb/gallery-1.jpg', N'Kingston NV3 2TB gallery 1', 1, 1),
(N'SSD-KINGSTON-NV3-2TB', N'/uploads/products/storage/kingston-nv3-2tb/gallery-2.jpg', N'Kingston NV3 2TB gallery 2', 0, 2),
(N'SSD-KINGSTON-NV3-2TB', N'/uploads/products/storage/kingston-nv3-2tb/gallery-3.jpg', N'Kingston NV3 2TB gallery 3', 0, 3),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'/uploads/products/storage/seagate-barracuda-2tb/gallery-1.jpg', N'Seagate Barracuda 2TB gallery 1', 1, 1),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'/uploads/products/storage/seagate-barracuda-2tb/gallery-2.jpg', N'Seagate Barracuda 2TB gallery 2', 0, 2),
(N'HDD-SEAGATE-BARRACUDA-2TB', N'/uploads/products/storage/seagate-barracuda-2tb/gallery-3.jpg', N'Seagate Barracuda 2TB gallery 3', 0, 3),
(N'HDD-WD-BLUE-6TB', N'/uploads/products/storage/wd-blue-6tb-5400rpm/gallery-1.jpg', N'WD Blue 6TB 5400RPM gallery 1', 1, 1),
(N'HDD-WD-BLUE-6TB', N'/uploads/products/storage/wd-blue-6tb-5400rpm/gallery-2.jpg', N'WD Blue 6TB 5400RPM gallery 2', 0, 2),
(N'HDD-WD-BLUE-6TB', N'/uploads/products/storage/wd-blue-6tb-5400rpm/gallery-3.jpg', N'WD Blue 6TB 5400RPM gallery 3', 0, 3),
(N'HDD-WD-BLUE-4TB', N'/uploads/products/storage/wd-blue-4tb/gallery-1.jpg', N'WD Blue 4TB gallery 1', 1, 1),
(N'HDD-WD-BLUE-4TB', N'/uploads/products/storage/wd-blue-4tb/gallery-2.jpg', N'WD Blue 4TB gallery 2', 0, 2),
(N'HDD-WD-BLUE-4TB', N'/uploads/products/storage/wd-blue-4tb/gallery-3.jpg', N'WD Blue 4TB gallery 3', 0, 3),
(N'HDD-WD-BLUE-2TB-7200', N'/uploads/products/storage/wd-blue-2tb-7200rpm/gallery-1.jpg', N'WD Blue 2TB 7200RPM gallery 1', 1, 1),
(N'HDD-WD-BLUE-2TB-7200', N'/uploads/products/storage/wd-blue-2tb-7200rpm/gallery-2.jpg', N'WD Blue 2TB 7200RPM gallery 2', 0, 2),
(N'HDD-WD-BLUE-2TB-7200', N'/uploads/products/storage/wd-blue-2tb-7200rpm/gallery-3.jpg', N'WD Blue 2TB 7200RPM gallery 3', 0, 3),
(N'HDD-WD-BLUE-1TB', N'/uploads/products/storage/wd-blue-1tb/gallery-1.jpg', N'WD Blue 1TB gallery 1', 1, 1),
(N'HDD-WD-BLUE-1TB', N'/uploads/products/storage/wd-blue-1tb/gallery-2.jpg', N'WD Blue 1TB gallery 2', 0, 2),
(N'HDD-WD-BLUE-1TB', N'/uploads/products/storage/wd-blue-1tb/gallery-3.jpg', N'WD Blue 1TB gallery 3', 0, 3),
(N'PSU-ASUS-ROG-THOR-850P', N'/uploads/products/psu/asus-rog-thor-850p/gallery-1.jpg', N'ASUS ROG Thor 850P gallery 1', 1, 1),
(N'PSU-ASUS-ROG-THOR-850P', N'/uploads/products/psu/asus-rog-thor-850p/gallery-2.jpg', N'ASUS ROG Thor 850P gallery 2', 0, 2),
(N'PSU-ASUS-ROG-THOR-850P', N'/uploads/products/psu/asus-rog-thor-850p/gallery-3.jpg', N'ASUS ROG Thor 850P gallery 3', 0, 3),
(N'PSU-ASUS-ROG-THOR-1200P2', N'/uploads/products/psu/asus-rog-thor-1200p2/gallery-1.jpg', N'ASUS ROG Thor 1200P2 gallery 1', 1, 1),
(N'PSU-ASUS-ROG-THOR-1200P2', N'/uploads/products/psu/asus-rog-thor-1200p2/gallery-2.jpg', N'ASUS ROG Thor 1200P2 gallery 2', 0, 2),
(N'PSU-ASUS-ROG-THOR-1200P2', N'/uploads/products/psu/asus-rog-thor-1200p2/gallery-3.jpg', N'ASUS ROG Thor 1200P2 gallery 3', 0, 3),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'/uploads/products/psu/asus-rog-strix-1000w-aura/gallery-1.jpg', N'ASUS ROG Strix 1000W AURA gallery 1', 1, 1),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'/uploads/products/psu/asus-rog-strix-1000w-aura/gallery-2.jpg', N'ASUS ROG Strix 1000W AURA gallery 2', 0, 2),
(N'PSU-ASUS-ROG-STRIX-1000-AURA', N'/uploads/products/psu/asus-rog-strix-1000w-aura/gallery-3.jpg', N'ASUS ROG Strix 1000W AURA gallery 3', 0, 3),
(N'PSU-GIGABYTE-UD850GM-PG5', N'/uploads/products/psu/gigabyte-ud850gm-pg5/gallery-1.jpg', N'GIGABYTE UD850GM PG5 gallery 1', 1, 1),
(N'PSU-GIGABYTE-UD850GM-PG5', N'/uploads/products/psu/gigabyte-ud850gm-pg5/gallery-2.jpg', N'GIGABYTE UD850GM PG5 gallery 2', 0, 2),
(N'PSU-GIGABYTE-UD850GM-PG5', N'/uploads/products/psu/gigabyte-ud850gm-pg5/gallery-3.jpg', N'GIGABYTE UD850GM PG5 gallery 3', 0, 3),
(N'PSU-ASUS-ROG-THOR-1600T3', N'/uploads/products/psu/asus-rog-thor-1600t3/gallery-1.jpg', N'ASUS ROG Thor 1600T3 gallery 1', 1, 1),
(N'PSU-ASUS-ROG-THOR-1600T3', N'/uploads/products/psu/asus-rog-thor-1600t3/gallery-2.jpg', N'ASUS ROG Thor 1600T3 gallery 2', 0, 2),
(N'PSU-ASUS-ROG-THOR-1600T3', N'/uploads/products/psu/asus-rog-thor-1600t3/gallery-3.jpg', N'ASUS ROG Thor 1600T3 gallery 3', 0, 3),
(N'CASE-CORSAIR-6500X-WHITE', N'/uploads/products/case/corsair-6500x-white/gallery-1.jpg', N'Corsair 6500X White gallery 1', 1, 1),
(N'CASE-CORSAIR-6500X-WHITE', N'/uploads/products/case/corsair-6500x-white/gallery-2.jpg', N'Corsair 6500X White gallery 2', 0, 2),
(N'CASE-CORSAIR-6500X-WHITE', N'/uploads/products/case/corsair-6500x-white/gallery-3.jpg', N'Corsair 6500X White gallery 3', 0, 3),
(N'CASE-JONSBO-Z20-WHITE', N'/uploads/products/case/jonsbo-z20-white/gallery-1.jpg', N'Jonsbo Z20 White gallery 1', 1, 1),
(N'CASE-JONSBO-Z20-WHITE', N'/uploads/products/case/jonsbo-z20-white/gallery-2.jpg', N'Jonsbo Z20 White gallery 2', 0, 2),
(N'CASE-JONSBO-Z20-WHITE', N'/uploads/products/case/jonsbo-z20-white/gallery-3.jpg', N'Jonsbo Z20 White gallery 3', 0, 3),
(N'CASE-JONSBO-Z20-PINK', N'/uploads/products/case/jonsbo-z20-pink/gallery-1.jpg', N'Jonsbo Z20 Pink gallery 1', 1, 1),
(N'CASE-JONSBO-Z20-PINK', N'/uploads/products/case/jonsbo-z20-pink/gallery-2.jpg', N'Jonsbo Z20 Pink gallery 2', 0, 2),
(N'CASE-JONSBO-Z20-PINK', N'/uploads/products/case/jonsbo-z20-pink/gallery-3.jpg', N'Jonsbo Z20 Pink gallery 3', 0, 3),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'/uploads/products/case/cooler-master-td500-v2-chunli/gallery-1.jpg', N'Cooler Master TD500 Mesh V2 CHUN-LI gallery 1', 1, 1),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'/uploads/products/case/cooler-master-td500-v2-chunli/gallery-2.jpg', N'Cooler Master TD500 Mesh V2 CHUN-LI gallery 2', 0, 2),
(N'CASE-COOLERMASTER-TD500-V2-CHUNLI', N'/uploads/products/case/cooler-master-td500-v2-chunli/gallery-3.jpg', N'Cooler Master TD500 Mesh V2 CHUN-LI gallery 3', 0, 3),
(N'CASE-NZXT-H9-ELITE-WHITE', N'/uploads/products/case/nzxt-h9-elite-white/gallery-1.jpg', N'NZXT H9 Elite White gallery 1', 1, 1),
(N'CASE-NZXT-H9-ELITE-WHITE', N'/uploads/products/case/nzxt-h9-elite-white/gallery-2.jpg', N'NZXT H9 Elite White gallery 2', 0, 2),
(N'CASE-NZXT-H9-ELITE-WHITE', N'/uploads/products/case/nzxt-h9-elite-white/gallery-3.jpg', N'NZXT H9 Elite White gallery 3', 0, 3),
(N'CASE-TRYX-LUCA-L70-BLACK', N'/uploads/products/case/tryx-luca-l70-black/gallery-1.jpg', N'TRYX Luca L70 Black gallery 1', 1, 1),
(N'CASE-TRYX-LUCA-L70-BLACK', N'/uploads/products/case/tryx-luca-l70-black/gallery-2.jpg', N'TRYX Luca L70 Black gallery 2', 0, 2),
(N'CASE-TRYX-LUCA-L70-BLACK', N'/uploads/products/case/tryx-luca-l70-black/gallery-3.jpg', N'TRYX Luca L70 Black gallery 3', 0, 3),
(N'CASE-JONSBO-D300-BLACK', N'/uploads/products/case/jonsbo-d300-black/gallery-1.jpg', N'Jonsbo D300 Black gallery 1', 1, 1),
(N'CASE-JONSBO-D300-BLACK', N'/uploads/products/case/jonsbo-d300-black/gallery-2.jpg', N'Jonsbo D300 Black gallery 2', 0, 2),
(N'CASE-JONSBO-D300-BLACK', N'/uploads/products/case/jonsbo-d300-black/gallery-3.jpg', N'Jonsbo D300 Black gallery 3', 0, 3),
(N'CASE-CORSAIR-6500X-BLACK', N'/uploads/products/case/corsair-6500x-black/gallery-1.jpg', N'Corsair 6500X Black gallery 1', 1, 1),
(N'CASE-CORSAIR-6500X-BLACK', N'/uploads/products/case/corsair-6500x-black/gallery-2.jpg', N'Corsair 6500X Black gallery 2', 0, 2),
(N'CASE-CORSAIR-6500X-BLACK', N'/uploads/products/case/corsair-6500x-black/gallery-3.jpg', N'Corsair 6500X Black gallery 3', 0, 3),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'/uploads/products/case/asus-rog-hyperion-gr701/gallery-1.jpg', N'ASUS ROG Hyperion GR701 gallery 1', 1, 1),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'/uploads/products/case/asus-rog-hyperion-gr701/gallery-2.jpg', N'ASUS ROG Hyperion GR701 gallery 2', 0, 2),
(N'CASE-ASUS-ROG-HYPERION-GR701', N'/uploads/products/case/asus-rog-hyperion-gr701/gallery-3.jpg', N'ASUS ROG Hyperion GR701 gallery 3', 0, 3),
(N'CASE-JONSBO-TK3-WHITE', N'/uploads/products/case/jonsbo-tk3-white/gallery-1.jpg', N'Jonsbo TK3 White gallery 1', 1, 1),
(N'CASE-JONSBO-TK3-WHITE', N'/uploads/products/case/jonsbo-tk3-white/gallery-2.jpg', N'Jonsbo TK3 White gallery 2', 0, 2),
(N'CASE-JONSBO-TK3-WHITE', N'/uploads/products/case/jonsbo-tk3-white/gallery-3.jpg', N'Jonsbo TK3 White gallery 3', 0, 3),
(N'MON-SAMSUNG-27Q180-IPS', N'/uploads/products/monitor/samsung-27q180-ips-gaming/gallery-1.jpg', N'Samsung 27Q180 IPS Gaming gallery 1', 1, 1),
(N'MON-SAMSUNG-27Q180-IPS', N'/uploads/products/monitor/samsung-27q180-ips-gaming/gallery-2.jpg', N'Samsung 27Q180 IPS Gaming gallery 2', 0, 2),
(N'MON-SAMSUNG-27Q180-IPS', N'/uploads/products/monitor/samsung-27q180-ips-gaming/gallery-3.jpg', N'Samsung 27Q180 IPS Gaming gallery 3', 0, 3),
(N'MON-MSI-32U-QDOLED', N'/uploads/products/monitor/msi-32u-qdoled-gaming/gallery-1.jpg', N'MSI 32U QD-OLED Gaming gallery 1', 1, 1),
(N'MON-MSI-32U-QDOLED', N'/uploads/products/monitor/msi-32u-qdoled-gaming/gallery-2.jpg', N'MSI 32U QD-OLED Gaming gallery 2', 0, 2),
(N'MON-MSI-32U-QDOLED', N'/uploads/products/monitor/msi-32u-qdoled-gaming/gallery-3.jpg', N'MSI 32U QD-OLED Gaming gallery 3', 0, 3),
(N'HKC-MB27S9U', N'/uploads/products/monitor/hkc-mb27s9u/gallery-1.jpg', N'HKC MB27S9U gallery 1', 1, 1),
(N'HKC-MB27S9U', N'/uploads/products/monitor/hkc-mb27s9u/gallery-2.jpg', N'HKC MB27S9U gallery 2', 0, 2),
(N'HKC-MB27S9U', N'/uploads/products/monitor/hkc-mb27s9u/gallery-3.jpg', N'HKC MB27S9U gallery 3', 0, 3),
(N'MON-ACER-27Q-IPS', N'/uploads/products/monitor/acer-27q-ips-gaming/gallery-1.jpg', N'Acer 27Q IPS Gaming gallery 1', 1, 1),
(N'MON-ACER-27Q-IPS', N'/uploads/products/monitor/acer-27q-ips-gaming/gallery-2.jpg', N'Acer 27Q IPS Gaming gallery 2', 0, 2),
(N'MON-ACER-27Q-IPS', N'/uploads/products/monitor/acer-27q-ips-gaming/gallery-3.jpg', N'Acer 27Q IPS Gaming gallery 3', 0, 3),
(N'MON-AOC-27Q-FASTIPS', N'/uploads/products/monitor/aoc-27q-fastips-gaming/gallery-1.jpg', N'AOC 27Q Fast IPS Gaming gallery 1', 1, 1),
(N'MON-AOC-27Q-FASTIPS', N'/uploads/products/monitor/aoc-27q-fastips-gaming/gallery-2.jpg', N'AOC 27Q Fast IPS Gaming gallery 2', 0, 2),
(N'MON-AOC-27Q-FASTIPS', N'/uploads/products/monitor/aoc-27q-fastips-gaming/gallery-3.jpg', N'AOC 27Q Fast IPS Gaming gallery 3', 0, 3),
(N'MON-GIGABYTE-32U-OLED', N'/uploads/products/monitor/gigabyte-32u-oled-gaming/gallery-1.jpg', N'Gigabyte 32U OLED Gaming gallery 1', 1, 1),
(N'MON-GIGABYTE-32U-OLED', N'/uploads/products/monitor/gigabyte-32u-oled-gaming/gallery-2.jpg', N'Gigabyte 32U OLED Gaming gallery 2', 0, 2),
(N'MON-GIGABYTE-32U-OLED', N'/uploads/products/monitor/gigabyte-32u-oled-gaming/gallery-3.jpg', N'Gigabyte 32U OLED Gaming gallery 3', 0, 3),
(N'MON-DELL-43U-IPSBLACK', N'/uploads/products/monitor/dell-43u-ips-black-4k/gallery-1.jpg', N'Dell 43U IPS Black 4K gallery 1', 1, 1),
(N'MON-DELL-43U-IPSBLACK', N'/uploads/products/monitor/dell-43u-ips-black-4k/gallery-2.jpg', N'Dell 43U IPS Black 4K gallery 2', 0, 2),
(N'MON-DELL-43U-IPSBLACK', N'/uploads/products/monitor/dell-43u-ips-black-4k/gallery-3.jpg', N'Dell 43U IPS Black 4K gallery 3', 0, 3),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'/uploads/products/monitor/viewsonic-27q-color-usbc-90w/gallery-1.jpg', N'ViewSonic 27Q Color USB-C 90W gallery 1', 1, 1),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'/uploads/products/monitor/viewsonic-27q-color-usbc-90w/gallery-2.jpg', N'ViewSonic 27Q Color USB-C 90W gallery 2', 0, 2),
(N'MON-VIEWSONIC-27Q-COLOR-90W', N'/uploads/products/monitor/viewsonic-27q-color-usbc-90w/gallery-3.jpg', N'ViewSonic 27Q Color USB-C 90W gallery 3', 0, 3),
(N'MON-ASUS-32U-WOLED-DUAL', N'/uploads/products/monitor/asus-32u-woled-dual-mode/gallery-1.jpg', N'ASUS 32U WOLED Dual Mode gallery 1', 1, 1),
(N'MON-ASUS-32U-WOLED-DUAL', N'/uploads/products/monitor/asus-32u-woled-dual-mode/gallery-2.jpg', N'ASUS 32U WOLED Dual Mode gallery 2', 0, 2),
(N'MON-ASUS-32U-WOLED-DUAL', N'/uploads/products/monitor/asus-32u-woled-dual-mode/gallery-3.jpg', N'ASUS 32U WOLED Dual Mode gallery 3', 0, 3),
(N'MON-LG-27U-NANOIPS-DUAL', N'/uploads/products/monitor/lg-27u-nanoips-dual-mode/gallery-1.jpg', N'LG 27U Nano IPS Dual Mode gallery 1', 1, 1),
(N'MON-LG-27U-NANOIPS-DUAL', N'/uploads/products/monitor/lg-27u-nanoips-dual-mode/gallery-2.jpg', N'LG 27U Nano IPS Dual Mode gallery 2', 0, 2),
(N'MON-LG-27U-NANOIPS-DUAL', N'/uploads/products/monitor/lg-27u-nanoips-dual-mode/gallery-3.jpg', N'LG 27U Nano IPS Dual Mode gallery 3', 0, 3),
(N'KB-AKKO-5075B-PLUS-BWTVN', N'/uploads/products/keyboard/ban-phim-akko-5075b-plus-black-world-tour-viet-nam/gallery-1.jpg', N'Bàn phím AKKO 5075B Plus Black World Tour VIET NAM gallery 1', 1, 1),
(N'KB-AKKO-5075B-PLUS-BWTVN', N'/uploads/products/keyboard/ban-phim-akko-5075b-plus-black-world-tour-viet-nam/gallery-2.jpg', N'Bàn phím AKKO 5075B Plus Black World Tour VIET NAM gallery 2', 0, 2),
(N'KB-AKKO-5075B-PLUS-BWTVN', N'/uploads/products/keyboard/ban-phim-akko-5075b-plus-black-world-tour-viet-nam/gallery-3.jpg', N'Bàn phím AKKO 5075B Plus Black World Tour VIET NAM gallery 3', 0, 3),
(N'KB-AULA-F75-WHITE-RED', N'/uploads/products/keyboard/ban-phim-aula-f75-co-day-trang-red-switch-f7512/gallery-1.jpg', N'Bàn phím AULA F75 có dây (Trắng Red switch) F7512 gallery 1', 1, 1),
(N'KB-AULA-F75-WHITE-RED', N'/uploads/products/keyboard/ban-phim-aula-f75-co-day-trang-red-switch-f7512/gallery-2.jpg', N'Bàn phím AULA F75 có dây (Trắng Red switch) F7512 gallery 2', 0, 2),
(N'KB-AULA-F75-WHITE-RED', N'/uploads/products/keyboard/ban-phim-aula-f75-co-day-trang-red-switch-f7512/gallery-3.jpg', N'Bàn phím AULA F75 có dây (Trắng Red switch) F7512 gallery 3', 0, 3),
(N'KB-DAREU-EK75-RT-BLACK', N'/uploads/products/keyboard/ban-phim-co-dareu-ek75-rapid-trigger-black/gallery-1.jpg', N'Bàn phím cơ DareU EK75 Rapid Trigger Black gallery 1', 1, 1),
(N'KB-DAREU-EK75-RT-BLACK', N'/uploads/products/keyboard/ban-phim-co-dareu-ek75-rapid-trigger-black/gallery-2.jpg', N'Bàn phím cơ DareU EK75 Rapid Trigger Black gallery 2', 0, 2),
(N'KB-DAREU-EK75-RT-BLACK', N'/uploads/products/keyboard/ban-phim-co-dareu-ek75-rapid-trigger-black/gallery-3.jpg', N'Bàn phím cơ DareU EK75 Rapid Trigger Black gallery 3', 0, 3),
(N'KB-DURGOD-CAVALRY-87-BLACK', N'/uploads/products/keyboard/ban-phim-co-khong-day-durgod-cavalry-87-black-kailh-turbo-silent-red-switch/gallery-1.jpg', N'Bàn phím cơ không dây Durgod Cavalry 87 Black Kailh Turbo Silent Red Switch gallery 1', 1, 1),
(N'KB-DURGOD-CAVALRY-87-BLACK', N'/uploads/products/keyboard/ban-phim-co-khong-day-durgod-cavalry-87-black-kailh-turbo-silent-red-switch/gallery-2.jpg', N'Bàn phím cơ không dây Durgod Cavalry 87 Black Kailh Turbo Silent Red Switch gallery 2', 0, 2),
(N'KB-DURGOD-CAVALRY-87-BLACK', N'/uploads/products/keyboard/ban-phim-co-khong-day-durgod-cavalry-87-black-kailh-turbo-silent-red-switch/gallery-3.jpg', N'Bàn phím cơ không dây Durgod Cavalry 87 Black Kailh Turbo Silent Red Switch gallery 3', 0, 3),
(N'KB-CORSAIR-K70-PRO-RED', N'/uploads/products/keyboard/ban-phim-corsair-k70-pro-red-switch/gallery-1.jpg', N'Bàn phím Corsair K70 PRO Red Switch gallery 1', 1, 1),
(N'KB-CORSAIR-K70-PRO-RED', N'/uploads/products/keyboard/ban-phim-corsair-k70-pro-red-switch/gallery-2.jpg', N'Bàn phím Corsair K70 PRO Red Switch gallery 2', 0, 2),
(N'KB-CORSAIR-K70-PRO-RED', N'/uploads/products/keyboard/ban-phim-corsair-k70-pro-red-switch/gallery-3.jpg', N'Bàn phím Corsair K70 PRO Red Switch gallery 3', 0, 3),
(N'KB-E-DRA-EK3104L-BETA-BROWN', N'/uploads/products/keyboard/ban-phim-e-dra-ek3104l-beta-brown-switch/gallery-1.jpg', N'Bàn phím E-Dra EK3104L Beta Brown Switch gallery 1', 1, 1),
(N'KB-E-DRA-EK3104L-BETA-BROWN', N'/uploads/products/keyboard/ban-phim-e-dra-ek3104l-beta-brown-switch/gallery-2.jpg', N'Bàn phím E-Dra EK3104L Beta Brown Switch gallery 2', 0, 2),
(N'KB-E-DRA-EK3104L-BETA-BROWN', N'/uploads/products/keyboard/ban-phim-e-dra-ek3104l-beta-brown-switch/gallery-3.jpg', N'Bàn phím E-Dra EK3104L Beta Brown Switch gallery 3', 0, 3),
(N'KB-ASUS-ROG-SCOPE-II-96-WL-SNOW', N'/uploads/products/keyboard/ban-phim-asus-rog-strix-scope-ii-96-wireless-rog-nx-snow-switch/gallery-1.jpg', N'Bàn phím Asus ROG Strix Scope II 96 Wireless ROG NX Snow Switch gallery 1', 1, 1),
(N'KB-ASUS-ROG-SCOPE-II-96-WL-SNOW', N'/uploads/products/keyboard/ban-phim-asus-rog-strix-scope-ii-96-wireless-rog-nx-snow-switch/gallery-2.jpg', N'Bàn phím Asus ROG Strix Scope II 96 Wireless ROG NX Snow Switch gallery 2', 0, 2),
(N'KB-ASUS-ROG-SCOPE-II-96-WL-SNOW', N'/uploads/products/keyboard/ban-phim-asus-rog-strix-scope-ii-96-wireless-rog-nx-snow-switch/gallery-3.jpg', N'Bàn phím Asus ROG Strix Scope II 96 Wireless ROG NX Snow Switch gallery 3', 0, 3),
(N'KB-LOGITECH-G913-TKL-CLICKY', N'/uploads/products/keyboard/ban-phim-logitech-g913-tkl-lightspeed-wireless-clicky/gallery-1.jpg', N'Bàn phím Logitech G913 TKL Lightspeed Wireless Clicky gallery 1', 1, 1),
(N'KB-LOGITECH-G913-TKL-CLICKY', N'/uploads/products/keyboard/ban-phim-logitech-g913-tkl-lightspeed-wireless-clicky/gallery-2.jpg', N'Bàn phím Logitech G913 TKL Lightspeed Wireless Clicky gallery 2', 0, 2),
(N'KB-LOGITECH-G913-TKL-CLICKY', N'/uploads/products/keyboard/ban-phim-logitech-g913-tkl-lightspeed-wireless-clicky/gallery-3.jpg', N'Bàn phím Logitech G913 TKL Lightspeed Wireless Clicky gallery 3', 0, 3),
(N'KB-RAZER-BLACKWIDOW-V4-PRO-GREEN', N'/uploads/products/keyboard/ban-phim-co-razer-blackwidow-v4-pro-green-switch/gallery-1.jpg', N'Bàn phím cơ Razer BlackWidow V4 Pro Green Switch gallery 1', 1, 1),
(N'KB-RAZER-BLACKWIDOW-V4-PRO-GREEN', N'/uploads/products/keyboard/ban-phim-co-razer-blackwidow-v4-pro-green-switch/gallery-2.jpg', N'Bàn phím cơ Razer BlackWidow V4 Pro Green Switch gallery 2', 0, 2),
(N'KB-RAZER-BLACKWIDOW-V4-PRO-GREEN', N'/uploads/products/keyboard/ban-phim-co-razer-blackwidow-v4-pro-green-switch/gallery-3.jpg', N'Bàn phím cơ Razer BlackWidow V4 Pro Green Switch gallery 3', 0, 3),
(N'KB-RAPOO-V700-A8-DARKGREY-BLUE', N'/uploads/products/keyboard/ban-phim-rapoo-v700-a8-dark-grey-blue-switch/gallery-1.jpg', N'Bàn phím Rapoo V700-A8 Dark Grey Blue Switch gallery 1', 1, 1),
(N'KB-RAPOO-V700-A8-DARKGREY-BLUE', N'/uploads/products/keyboard/ban-phim-rapoo-v700-a8-dark-grey-blue-switch/gallery-2.jpg', N'Bàn phím Rapoo V700-A8 Dark Grey Blue Switch gallery 2', 0, 2),
(N'KB-RAPOO-V700-A8-DARKGREY-BLUE', N'/uploads/products/keyboard/ban-phim-rapoo-v700-a8-dark-grey-blue-switch/gallery-3.jpg', N'Bàn phím Rapoo V700-A8 Dark Grey Blue Switch gallery 3', 0, 3),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'/uploads/products/mouse/chuot-logitech-g502-hero-black/gallery-1.jpg', N'Chuột Logitech G502 HERO Black gallery 1', 1, 1),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'/uploads/products/mouse/chuot-logitech-g502-hero-black/gallery-2.jpg', N'Chuột Logitech G502 HERO Black gallery 2', 0, 2),
(N'MOU-LOGITECH-G502-HERO-BLACK', N'/uploads/products/mouse/chuot-logitech-g502-hero-black/gallery-3.jpg', N'Chuột Logitech G502 HERO Black gallery 3', 0, 3),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'/uploads/products/mouse/chuot-logitech-g502-x-plus-white/gallery-1.jpg', N'Chuột Logitech G502 X Plus White gallery 1', 1, 1),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'/uploads/products/mouse/chuot-logitech-g502-x-plus-white/gallery-2.jpg', N'Chuột Logitech G502 X Plus White gallery 2', 0, 2),
(N'MOU-LOGITECH-G502X-PLUS-WHITE', N'/uploads/products/mouse/chuot-logitech-g502-x-plus-white/gallery-3.jpg', N'Chuột Logitech G502 X Plus White gallery 3', 0, 3),
(N'MOU-ATK-PAW3950-WHITE', N'/uploads/products/mouse/chuot-atk-paw3950-wireless-white/gallery-1.jpg', N'Chuột ATK PAW3950 Wireless White gallery 1', 1, 1),
(N'MOU-ATK-PAW3950-WHITE', N'/uploads/products/mouse/chuot-atk-paw3950-wireless-white/gallery-2.jpg', N'Chuột ATK PAW3950 Wireless White gallery 2', 0, 2),
(N'MOU-ATK-PAW3950-WHITE', N'/uploads/products/mouse/chuot-atk-paw3950-wireless-white/gallery-3.jpg', N'Chuột ATK PAW3950 Wireless White gallery 3', 0, 3),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'/uploads/products/mouse/chuot-hyperx-26k-wireless-white/gallery-1.jpg', N'Chuột HyperX 26K Wireless White gallery 1', 1, 1),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'/uploads/products/mouse/chuot-hyperx-26k-wireless-white/gallery-2.jpg', N'Chuột HyperX 26K Wireless White gallery 2', 0, 2),
(N'MOU-HYPERX-26K-WIRELESS-WHITE', N'/uploads/products/mouse/chuot-hyperx-26k-wireless-white/gallery-3.jpg', N'Chuột HyperX 26K Wireless White gallery 3', 0, 3),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'/uploads/products/mouse/chuot-rapoo-26k-wireless-white/gallery-1.jpg', N'Chuột Rapoo 26K Wireless White gallery 1', 1, 1),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'/uploads/products/mouse/chuot-rapoo-26k-wireless-white/gallery-2.jpg', N'Chuột Rapoo 26K Wireless White gallery 2', 0, 2),
(N'MOU-RAPOO-26K-WIRELESS-WHITE', N'/uploads/products/mouse/chuot-rapoo-26k-wireless-white/gallery-3.jpg', N'Chuột Rapoo 26K Wireless White gallery 3', 0, 3),
(N'MOU-GLORIOUS-WIRED-BLACK', N'/uploads/products/mouse/chuot-glorious-wired-black/gallery-1.jpg', N'Chuột Glorious Wired Black gallery 1', 1, 1),
(N'MOU-GLORIOUS-WIRED-BLACK', N'/uploads/products/mouse/chuot-glorious-wired-black/gallery-2.jpg', N'Chuột Glorious Wired Black gallery 2', 0, 2),
(N'MOU-GLORIOUS-WIRED-BLACK', N'/uploads/products/mouse/chuot-glorious-wired-black/gallery-3.jpg', N'Chuột Glorious Wired Black gallery 3', 0, 3),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'/uploads/products/mouse/chuot-asus-rog-aimpoint-pro-wireless-black/gallery-1.jpg', N'Chuột ASUS ROG AimPoint Pro Wireless Black gallery 1', 1, 1),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'/uploads/products/mouse/chuot-asus-rog-aimpoint-pro-wireless-black/gallery-2.jpg', N'Chuột ASUS ROG AimPoint Pro Wireless Black gallery 2', 0, 2),
(N'MOU-ASUS-ROG-AIMPOINT-PRO-BLACK', N'/uploads/products/mouse/chuot-asus-rog-aimpoint-pro-wireless-black/gallery-3.jpg', N'Chuột ASUS ROG AimPoint Pro Wireless Black gallery 3', 0, 3),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'/uploads/products/mouse/chuot-dareu-bravo-wireless-black/gallery-1.jpg', N'Chuột DareU BRAVO Wireless Black gallery 1', 1, 1),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'/uploads/products/mouse/chuot-dareu-bravo-wireless-black/gallery-2.jpg', N'Chuột DareU BRAVO Wireless Black gallery 2', 0, 2),
(N'MOU-DAREU-BRAVO-WIRELESS-BLACK', N'/uploads/products/mouse/chuot-dareu-bravo-wireless-black/gallery-3.jpg', N'Chuột DareU BRAVO Wireless Black gallery 3', 0, 3),
(N'MOU-CORSAIR-WIRELESS-BLACK', N'/uploads/products/mouse/chuot-corsair-wireless-black/gallery-1.jpg', N'Chuột Corsair Wireless Black gallery 1', 1, 1),
(N'MOU-CORSAIR-WIRELESS-BLACK', N'/uploads/products/mouse/chuot-corsair-wireless-black/gallery-2.jpg', N'Chuột Corsair Wireless Black gallery 2', 0, 2),
(N'MOU-CORSAIR-WIRELESS-BLACK', N'/uploads/products/mouse/chuot-corsair-wireless-black/gallery-3.jpg', N'Chuột Corsair Wireless Black gallery 3', 0, 3),
(N'MOU-RAZER-WIRELESS-BLACK', N'/uploads/products/mouse/chuot-razer-wireless-black/gallery-1.jpg', N'Chuột Razer Wireless Black gallery 1', 1, 1),
(N'MOU-RAZER-WIRELESS-BLACK', N'/uploads/products/mouse/chuot-razer-wireless-black/gallery-2.jpg', N'Chuột Razer Wireless Black gallery 2', 0, 2),
(N'MOU-RAZER-WIRELESS-BLACK', N'/uploads/products/mouse/chuot-razer-wireless-black/gallery-3.jpg', N'Chuột Razer Wireless Black gallery 3', 0, 3),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'/uploads/products/headset/tai-nghe-asus-rog-pelta-wl-rgb-black/gallery-1.jpg', N'Tai nghe ASUS ROG Pelta WL RGB Black gallery 1', 1, 1),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'/uploads/products/headset/tai-nghe-asus-rog-pelta-wl-rgb-black/gallery-2.jpg', N'Tai nghe ASUS ROG Pelta WL RGB Black gallery 2', 0, 2),
(N'HS-ASUS-ROG-PELTA-WL-RGB-BLACK', N'/uploads/products/headset/tai-nghe-asus-rog-pelta-wl-rgb-black/gallery-3.jpg', N'Tai nghe ASUS ROG Pelta WL RGB Black gallery 3', 0, 3),
(N'HS-EDIFIER-W830NB-BLACK', N'/uploads/products/headset/tai-nghe-edifier-w830nb-black/gallery-1.jpg', N'Tai nghe Edifier W830NB Black gallery 1', 1, 1),
(N'HS-EDIFIER-W830NB-BLACK', N'/uploads/products/headset/tai-nghe-edifier-w830nb-black/gallery-2.jpg', N'Tai nghe Edifier W830NB Black gallery 2', 0, 2),
(N'HS-EDIFIER-W830NB-BLACK', N'/uploads/products/headset/tai-nghe-edifier-w830nb-black/gallery-3.jpg', N'Tai nghe Edifier W830NB Black gallery 3', 0, 3),
(N'HS-LOGITECH-G435-LIGHTSPEED-WHITE', N'/uploads/products/headset/tai-nghe-logitech-g435-lightspeed-wireless-white/gallery-1.jpg', N'Tai nghe Logitech G435 Lightspeed Wireless White gallery 1', 1, 1),
(N'HS-LOGITECH-G435-LIGHTSPEED-WHITE', N'/uploads/products/headset/tai-nghe-logitech-g435-lightspeed-wireless-white/gallery-2.jpg', N'Tai nghe Logitech G435 Lightspeed Wireless White gallery 2', 0, 2),
(N'HS-LOGITECH-G435-LIGHTSPEED-WHITE', N'/uploads/products/headset/tai-nghe-logitech-g435-lightspeed-wireless-white/gallery-3.jpg', N'Tai nghe Logitech G435 Lightspeed Wireless White gallery 3', 0, 3),
(N'HS-RAPOO-VH600', N'/uploads/products/headset/tai-nghe-rapoo-gaming-vh600/gallery-1.jpg', N'Tai nghe Rapoo Gaming VH600 gallery 1', 1, 1),
(N'HS-RAPOO-VH600', N'/uploads/products/headset/tai-nghe-rapoo-gaming-vh600/gallery-2.jpg', N'Tai nghe Rapoo Gaming VH600 gallery 2', 0, 2),
(N'HS-RAPOO-VH600', N'/uploads/products/headset/tai-nghe-rapoo-gaming-vh600/gallery-3.jpg', N'Tai nghe Rapoo Gaming VH600 gallery 3', 0, 3),
(N'HS-ONIKUMA-B5-TRIMODE-WHITE', N'/uploads/products/headset/tai-nghe-onikuma-tai-meo-b5-rgb-tri-mode-trang/gallery-1.jpg', N'Tai nghe Onikuma Tai Mèo B5 RGB Tri Mode Trắng gallery 1', 1, 1),
(N'HS-ONIKUMA-B5-TRIMODE-WHITE', N'/uploads/products/headset/tai-nghe-onikuma-tai-meo-b5-rgb-tri-mode-trang/gallery-2.jpg', N'Tai nghe Onikuma Tai Mèo B5 RGB Tri Mode Trắng gallery 2', 0, 2),
(N'HS-ONIKUMA-B5-TRIMODE-WHITE', N'/uploads/products/headset/tai-nghe-onikuma-tai-meo-b5-rgb-tri-mode-trang/gallery-3.jpg', N'Tai nghe Onikuma Tai Mèo B5 RGB Tri Mode Trắng gallery 3', 0, 3),
(N'HS-RAZER-BLACKSHARK-V3PRO-CS2', N'/uploads/products/headset/tai-nghe-razer-blackshark-v3-pro-counter-strike-2-edition/gallery-1.jpg', N'Tai nghe Razer Blackshark V3 Pro Counter-Strike 2 Edition gallery 1', 1, 1),
(N'HS-RAZER-BLACKSHARK-V3PRO-CS2', N'/uploads/products/headset/tai-nghe-razer-blackshark-v3-pro-counter-strike-2-edition/gallery-2.jpg', N'Tai nghe Razer Blackshark V3 Pro Counter-Strike 2 Edition gallery 2', 0, 2),
(N'HS-RAZER-BLACKSHARK-V3PRO-CS2', N'/uploads/products/headset/tai-nghe-razer-blackshark-v3-pro-counter-strike-2-edition/gallery-3.jpg', N'Tai nghe Razer Blackshark V3 Pro Counter-Strike 2 Edition gallery 3', 0, 3),
(N'HS-CORSAIR-VIRTUOSO-SE-ESPRESSO', N'/uploads/products/headset/tai-nghe-corsair-virtuoso-rgb-wireless-se-espresso/gallery-1.jpg', N'Tai nghe Corsair Virtuoso RGB Wireless SE Espresso gallery 1', 1, 1),
(N'HS-CORSAIR-VIRTUOSO-SE-ESPRESSO', N'/uploads/products/headset/tai-nghe-corsair-virtuoso-rgb-wireless-se-espresso/gallery-2.jpg', N'Tai nghe Corsair Virtuoso RGB Wireless SE Espresso gallery 2', 0, 2),
(N'HS-CORSAIR-VIRTUOSO-SE-ESPRESSO', N'/uploads/products/headset/tai-nghe-corsair-virtuoso-rgb-wireless-se-espresso/gallery-3.jpg', N'Tai nghe Corsair Virtuoso RGB Wireless SE Espresso gallery 3', 0, 3),
(N'HS-HYPERX-CLOUD-STINGER-CORE-II', N'/uploads/products/headset/tai-nghe-hyperx-cloud-stinger-core-ii/gallery-1.jpg', N'Tai nghe HyperX Cloud Stinger Core II gallery 1', 1, 1),
(N'HS-HYPERX-CLOUD-STINGER-CORE-II', N'/uploads/products/headset/tai-nghe-hyperx-cloud-stinger-core-ii/gallery-2.jpg', N'Tai nghe HyperX Cloud Stinger Core II gallery 2', 0, 2),
(N'HS-HYPERX-CLOUD-STINGER-CORE-II', N'/uploads/products/headset/tai-nghe-hyperx-cloud-stinger-core-ii/gallery-3.jpg', N'Tai nghe HyperX Cloud Stinger Core II gallery 3', 0, 3),
(N'NET-ASUS-RT-AC1500UHP', N'/uploads/products/network/asus-rt-ac1500uhp/thumb.jpg', N'Bộ định tuyến WiFi 5 ASUS RT-AC1500UHP Chuẩn AC1500 (Xuyên tường) thumbnail', 1, 1),
(N'NET-ASUS-XT8-W2PK', N'/uploads/products/network/asus-xt8-w-2-pk/thumb.jpg', N'Thiết bị định tuyến mạng không dây Asus XT8 (W-2-PK) thumbnail', 1, 1),
(N'NET-ASUS-RT-AX92U-2PACK', N'/uploads/products/network/asus-rt-ax92u-2-pack/thumb.jpg', N'Thiết bị mạng AiMesh AX6100 WiFi System (RT-AX92U 2 Pack) thumbnail', 1, 1),
(N'NET-ASUS-RT-AC1300UHP', N'/uploads/products/network/asus-rt-ac1300uhp/thumb.jpg', N'Thiết bị mạng không dây ASUS RT-AC1300UHP thumbnail', 1, 1),
(N'NET-ASUS-RT-AC59U-AC1500', N'/uploads/products/network/asus-rt-ac59u-mobile-gaming-ac1500/thumb.jpg', N'Bộ định tuyến ASUS RT-AC59U Mobile Gaming AC1500 MU-MIMO 2 băng tần thumbnail', 1, 1),
(N'SW-MICROSOFT-WIN11-HOME-KW900664', N'/uploads/products/software/windows-11-home-esd-kw9-00664/thumb.jpg', N'Phần mềm Microsoft Windows 11 Home ESD KW9-00664 thumbnail', 1, 1),
(N'SW-MICROSOFT-WIN11-PRO-FQC10572', N'/uploads/products/software/windows-11-pro-esd-fqc-10572/thumb.jpg', N'Phần mềm Microsoft Windows 11 Pro ESD FQC-10572 thumbnail', 1, 1),
(N'SW-MICROSOFT-OFFICEHOME2024-EP206796', N'/uploads/products/software/office-home-2024-ep2-06796/thumb.jpg', N'Phần mềm Microsoft Office Home 2024 EP2-06796 thumbnail', 1, 1),
(N'SW-MICROSOFT-365PERSONAL-EP232313', N'/uploads/products/software/microsoft-365-personal-ep2-32313/thumb.jpg', N'Phần mềm Microsoft 365 Personal 1 năm EP2-32313 thumbnail', 1, 1),
(N'SW-MICROSOFT-365FAMILY-EP236890', N'/uploads/products/software/microsoft-365-family-ep2-36890/thumb.jpg', N'Phần mềm Microsoft 365 Family 1 năm EP2-36890 thumbnail', 1, 1),
(N'ACC-APPLE-SMARTKEYBOARD-IPAD129-4GEN', N'/uploads/products/accessories/apple-smart-keyboard-folio-ipad-pro-129-4th-gen/thumb.jpg', N'Apple Smart Keyboard Folio for iPad Pro 12.9 inch (4th generation) - US English thumbnail', 1, 1),
(N'ACC-UGREEN-NEXODE-200W-CD271', N'/uploads/products/accessories/ugreen-nexode-200w-cd271-40913/thumb.jpg', N'Bộ sạc nhanh GaN Nexode 200W Ugreen CD271 40913 thumbnail', 1, 1),
(N'ACC-UGREEN-HUB-5IN1-CM136', N'/uploads/products/accessories/ugreen-usb-c-hub-5-in-1-cm136-50209/thumb.jpg', N'Cổng chuyển đổi USB C Ugreen 5 in 1 CM136 50209 thumbnail', 1, 1),
(N'ACC-UGREEN-GAN-100W-CD226', N'/uploads/products/accessories/ugreen-gan-100w-cd226-40747/thumb.jpg', N'Củ sạc Ugreen GaN 100W CD226 40747 thumbnail', 1, 1),
(N'ACC-MAZER-USBC-VGA-MUSBCAL351', N'/uploads/products/accessories/mazer-alu-usb-c-to-vga-1080p-adapter-m-usbcal351-gy/thumb.jpg', N'Bộ chuyển đổi Mazer ALU USB-C to VGA 1080P Adapter M-USBCAL351-GY thumbnail', 1, 1),
(N'LAP-ASUS-TUF-F16-FX608JMR-RV048W', N'/uploads/products/laptop/asus-tuf-gaming-f16-fx608jmr-rv048w/thumb.jpg', N'Laptop gaming ASUS TUF F16 FX608JMR RV048W thumbnail', 1, 1),
(N'LAP-LENOVO-LEGION-PRO7-16IAX10H-83F500JGVN', N'/uploads/products/laptop/lenovo-legion-pro-7-16iax10h-83f500jgvn/thumb.jpg', N'Laptop gaming Lenovo Legion Pro 7 16IAX10H 83F500JGVN thumbnail', 1, 1),
(N'LAP-GIGABYTE-A16-CMHI2VN893SH', N'/uploads/products/laptop/gigabyte-a16-cmhi2vn893sh/thumb.jpg', N'Laptop gaming Gigabyte A16 CMHI2VN893SH thumbnail', 1, 1),
(N'LAP-LG-GRAM-17ZD90Q-GAX52A5', N'/uploads/products/laptop/lg-gram-2022-17zd90q-g-ax52a5/thumb.jpg', N'Laptop LG Gram 2022 17ZD90Q-G.AX52A5 thumbnail', 1, 1),
(N'LAP-HP-ENVY13-BA1534TU-4U6M3PA', N'/uploads/products/laptop/hp-envy-13-ba1534tu-4u6m3pa/thumb.jpg', N'Laptop HP Envy 13 BA1534TU 4U6M3PA thumbnail', 1, 1),
(N'LAP-DELL-15-DC15250-I7U161W11SLU', N'/uploads/products/laptop/dell-15-dc15250-i7u161w11slu/thumb.jpg', N'Laptop Dell 15 DC15250 i7U161W11SLU thumbnail', 1, 1),
(N'LAP-LENOVO-THINKPAD-X9-15GEN1-21Q60055VN', N'/uploads/products/laptop/lenovo-thinkpad-x9-15-gen-1-21q60055vn/thumb.jpg', N'Laptop Lenovo ThinkPad X9-15 Gen 1 21Q60055VN thumbnail', 1, 1),
(N'LAP-MSI-PRESTIGE16-AI-B2VMG-088VN', N'/uploads/products/laptop/msi-prestige-16-ai-mercedes-amg-b2vmg-088vn/thumb.jpg', N'Laptop MSI Prestige 16 AI+ Mercedes AMG B2VMG 088VN thumbnail', 1, 1),
(N'LAP-ACER-SWIFTGO-SFG14-74T-55HD', N'/uploads/products/laptop/acer-swift-go-sfg14-74t-55hd/thumb.jpg', N'Laptop Acer Swift Go SFG14 74T 55HD thumbnail', 1, 1),
(N'LAP-ASUS-ZENBOOK14-UM3406KA-PP555WS', N'/uploads/products/laptop/asus-zenbook-14-um3406ka-pp555ws/thumb.jpg', N'Laptop ASUS Zenbook 14 UM3406KA PP555WS thumbnail', 1, 1);


/* =========================================================
   1) Roles
   ========================================================= */
UPDATE R
SET
    R.Description = S.Description,
    R.IsActive = ISNULL(S.IsActive, 1)
FROM dbo.AspNetRoles AS R
JOIN #SeedRoles AS S
    ON R.Name = S.RoleName;

INSERT INTO dbo.AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp, Description, IsActive, CreatedAt)
SELECT
    CONVERT(NVARCHAR(450), NEWID()),
    S.RoleName,
    UPPER(S.RoleName),
    CONVERT(NVARCHAR(36), NEWID()),
    S.Description,
    ISNULL(S.IsActive, 1),
    SYSUTCDATETIME()
FROM #SeedRoles AS S
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.AspNetRoles AS R
    WHERE R.Name = S.RoleName
);

/* =========================================================
   2) Categories
   ========================================================= */
UPDATE C
SET
    C.Slug = S.Slug,
    C.[Description] = S.[Description],
    C.DisplayOrder = ISNULL(S.DisplayOrder, 0),
    C.IsActive = ISNULL(S.IsActive, 1),
    C.UpdatedAt = SYSUTCDATETIME()
FROM dbo.Categories AS C
JOIN #SeedCategories AS S
    ON C.[Name] = S.CategoryName;

INSERT INTO dbo.Categories (ParentCategoryId, [Name], Slug, [Description], DisplayOrder, IsActive, CreatedAt)
SELECT
    NULL,
    S.CategoryName,
    S.Slug,
    S.[Description],
    ISNULL(S.DisplayOrder, 0),
    ISNULL(S.IsActive, 1),
    SYSUTCDATETIME()
FROM #SeedCategories AS S
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Categories AS C
    WHERE C.[Name] = S.CategoryName
);

/* =========================================================
   3) Brands
   ========================================================= */
UPDATE B
SET
    B.Slug = S.Slug,
    B.[Description] = S.[Description],
    B.Country = S.Country,
    B.IsActive = ISNULL(S.IsActive, 1),
    B.UpdatedAt = SYSUTCDATETIME()
FROM dbo.Brands AS B
JOIN #SeedBrands AS S
    ON B.[Name] = S.BrandName;

INSERT INTO dbo.Brands ([Name], Slug, [Description], Country, LogoUrl, IsActive, CreatedAt)
SELECT
    S.BrandName,
    S.Slug,
    S.[Description],
    S.Country,
    NULL,
    ISNULL(S.IsActive, 1),
    SYSUTCDATETIME()
FROM #SeedBrands AS S
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Brands AS B
    WHERE B.[Name] = S.BrandName
);

/* =========================================================
   4) SpecificationDefinitions
   ========================================================= */
UPDATE SD
SET
    SD.DisplayName = S.DisplayName,
    SD.DataType = S.DataType,
    SD.Unit = S.Unit,
    SD.GroupName = S.GroupName,
    SD.SortOrder = ISNULL(S.SortOrder, 0),
    SD.IsFilterable = ISNULL(S.IsFilterable, 0),
    SD.IsRequired = ISNULL(S.IsRequired, 0),
    SD.IsActive = 1
FROM dbo.SpecificationDefinitions AS SD
JOIN dbo.Categories AS C
    ON C.Id = SD.CategoryId
JOIN #SeedSpecificationDefinitions AS S
    ON C.[Name] = S.CategoryName
   AND SD.SpecName = S.SpecName;

INSERT INTO dbo.SpecificationDefinitions
(
    CategoryId, SpecName, DisplayName, DataType, Unit, GroupName,
    SortOrder, IsFilterable, IsRequired, IsActive, CreatedAt
)
SELECT
    C.Id,
    S.SpecName,
    S.DisplayName,
    S.DataType,
    S.Unit,
    S.GroupName,
    ISNULL(S.SortOrder, 0),
    ISNULL(S.IsFilterable, 0),
    ISNULL(S.IsRequired, 0),
    1,
    SYSUTCDATETIME()
FROM #SeedSpecificationDefinitions AS S
JOIN dbo.Categories AS C
    ON C.[Name] = S.CategoryName
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.SpecificationDefinitions AS SD
    WHERE SD.CategoryId = C.Id
      AND SD.SpecName = S.SpecName
);

/* =========================================================
   5) Products (including stub products for missing transactional SKU)
   ========================================================= */
UPDATE P
SET
    P.[Name] = S.ProductName,
    P.Slug = S.Slug,
    P.CategoryId = C.Id,
    P.BrandId = B.Id,
    P.Price = ISNULL(S.Price, 0),
    P.DiscountPrice = S.DiscountPrice,
    P.StockQuantity = ISNULL(S.QuantityInStock, 0),
    P.ShortDescription = S.ShortDescription,
    P.[Description] = S.[Description],
    P.ThumbnailUrl = S.ThumbnailUrl,
    P.WarrantyMonths = ISNULL(S.WarrantyMonths, 0),
    P.IsActive = CASE WHEN ISNULL(S.IsStub, 0) = 1 THEN 0 ELSE 1 END,
    P.UpdatedAt = SYSUTCDATETIME()
FROM dbo.Products AS P
JOIN #SeedProducts AS S
    ON P.SKU = S.SKU
JOIN dbo.Categories AS C
    ON C.[Name] = S.CategoryName
JOIN dbo.Brands AS B
    ON B.[Name] = S.BrandName;

INSERT INTO dbo.Products
(
    SKU, [Name], Slug, CategoryId, BrandId, Price, DiscountPrice,
    StockQuantity, SoldQuantity, ShortDescription, [Description],
    ThumbnailUrl, WarrantyMonths, IsFeatured, IsActive, CreatedAt
)
SELECT
    S.SKU,
    S.ProductName,
    S.Slug,
    C.Id,
    B.Id,
    ISNULL(S.Price, 0),
    S.DiscountPrice,
    ISNULL(S.QuantityInStock, 0),
    0,
    S.ShortDescription,
    S.[Description],
    S.ThumbnailUrl,
    ISNULL(S.WarrantyMonths, 0),
    0,
    CASE WHEN ISNULL(S.IsStub, 0) = 1 THEN 0 ELSE 1 END,
    SYSUTCDATETIME()
FROM #SeedProducts AS S
JOIN dbo.Categories AS C
    ON C.[Name] = S.CategoryName
JOIN dbo.Brands AS B
    ON B.[Name] = S.BrandName
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Products AS P
    WHERE P.SKU = S.SKU
);

/* =========================================================
   6) ProductSpecifications (replace for seeded products)
   ========================================================= */
DELETE PS
FROM dbo.ProductSpecifications AS PS
JOIN dbo.Products AS P
    ON P.Id = PS.ProductId
JOIN #SeedProducts AS SP
    ON SP.SKU = P.SKU;

/*
   Workbook co mot so dong co cung ProductSKU + SpecName
   (vi du cac cong ket noi/port duoc tach thanh nhieu dong).
   Bang ProductSpecifications dang rang buoc UNIQUE(ProductId, SpecDefinitionId),
   nen can gom cac dong trung ve 1 dong duy nhat truoc khi insert.
*/
;WITH SpecSource AS
(
    SELECT
        S.ProductSKU,
        S.SpecName,
        NULLIF(LTRIM(RTRIM(S.ValueText)), N'') AS ValueText,
        S.ValueNumber,
        S.ValueBoolean,
        NULLIF(LTRIM(RTRIM(S.DisplayValue)), N'') AS DisplayValue
    FROM #SeedProductSpecifications AS S
    WHERE ISNULL(LTRIM(RTRIM(S.ProductSKU)), N'') <> N''
      AND ISNULL(LTRIM(RTRIM(S.SpecName)), N'') <> N''
      AND ISNULL(LTRIM(RTRIM(S.DisplayValue)), N'') <> N'Gia tri hien thi'
      AND ISNULL(LTRIM(RTRIM(CONVERT(NVARCHAR(50), S.ValueBoolean))), N'') <> N'TRUE/FALSE'
),
SpecDistinct AS
(
    SELECT DISTINCT
        ProductSKU,
        SpecName,
        ValueText,
        ValueNumber,
        ValueBoolean,
        DisplayValue
    FROM SpecSource
),
SpecAgg AS
(
    SELECT
        SS.ProductSKU,
        SS.SpecName,
        CASE
            WHEN COUNT(CASE WHEN SS.ValueText IS NOT NULL THEN 1 END) > 1
                THEN LEFT(STRING_AGG(SS.ValueText, N'; '), 500)
            ELSE MAX(SS.ValueText)
        END AS ValueText,
        CASE
            WHEN COUNT(DISTINCT SS.ValueNumber) = 1 THEN MAX(SS.ValueNumber)
            ELSE NULL
        END AS ValueNumber,
        CASE
            WHEN MAX(CASE WHEN SS.ValueBoolean = 1 THEN 1 ELSE 0 END) = 1 THEN CAST(1 AS BIT)
            WHEN MAX(CASE WHEN SS.ValueBoolean = 0 THEN 1 ELSE 0 END) = 1 THEN CAST(0 AS BIT)
            ELSE NULL
        END AS ValueBoolean,
        CASE
            WHEN COUNT(CASE WHEN COALESCE(SS.DisplayValue, SS.ValueText) IS NOT NULL THEN 1 END) > 1
                THEN LEFT(STRING_AGG(COALESCE(SS.DisplayValue, SS.ValueText), N'; '), 500)
            ELSE COALESCE(
                MAX(SS.DisplayValue),
                MAX(SS.ValueText),
                CASE WHEN COUNT(DISTINCT SS.ValueNumber) = 1 THEN CONVERT(NVARCHAR(100), MAX(SS.ValueNumber)) END,
                CASE
                    WHEN MAX(CASE WHEN SS.ValueBoolean = 1 THEN 1 ELSE 0 END) = 1 THEN N'True'
                    WHEN MAX(CASE WHEN SS.ValueBoolean = 0 THEN 1 ELSE 0 END) = 1 THEN N'False'
                    ELSE NULL
                END
            )
        END AS DisplayValue
    FROM SpecDistinct AS SS
    GROUP BY SS.ProductSKU, SS.SpecName
)
INSERT INTO dbo.ProductSpecifications
(
    ProductId, SpecDefinitionId, ValueText, ValueNumber, ValueBoolean, DisplayValue, CreatedAt
)
SELECT
    P.Id,
    SD.Id,
    A.ValueText,
    A.ValueNumber,
    A.ValueBoolean,
    A.DisplayValue,
    SYSUTCDATETIME()
FROM SpecAgg AS A
JOIN dbo.Products AS P
    ON P.SKU = A.ProductSKU
JOIN dbo.Categories AS C
    ON C.Id = P.CategoryId
JOIN dbo.SpecificationDefinitions AS SD
    ON SD.CategoryId = C.Id
   AND SD.SpecName = A.SpecName
WHERE A.ValueText IS NOT NULL
   OR A.ValueNumber IS NOT NULL
   OR A.ValueBoolean IS NOT NULL;

/* =========================================================
   7) ProductImages (replace for seeded products)
   ========================================================= */
DELETE PI
FROM dbo.ProductImages AS PI
JOIN dbo.Products AS P
    ON P.Id = PI.ProductId
JOIN #SeedProducts AS SP
    ON SP.SKU = P.SKU;

INSERT INTO dbo.ProductImages (ProductId, ImageUrl, AltText, IsPrimary, SortOrder, CreatedAt)
SELECT
    P.Id,
    S.ImageUrl,
    S.AltText,
    ISNULL(S.IsPrimary, 0),
    ISNULL(S.SortOrder, 0),
    SYSUTCDATETIME()
FROM #SeedProductImages AS S
JOIN dbo.Products AS P
    ON P.SKU = S.ProductSKU;

/* =========================================================
   8) Users
   ========================================================= */
UPDATE U
SET
    U.UserName = S.Email,
    U.NormalizedUserName = UPPER(S.Email),
    U.Email = S.Email,
    U.NormalizedEmail = UPPER(S.Email),
    U.EmailConfirmed = 1,
    U.PasswordHash = S.PasswordHash,
    U.PhoneNumber = S.PhoneNumber,
    U.FullName = S.FullName,
    U.IsActive = ISNULL(S.IsActive, 1),
    U.MustChangePassword = ISNULL(S.MustChangePassword, 0),
    U.UpdatedAt = SYSUTCDATETIME()
FROM dbo.AspNetUsers AS U
JOIN #SeedUsers AS S
    ON U.Email = S.Email;

INSERT INTO dbo.AspNetUsers
(
    Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed,
    PasswordHash, SecurityStamp, ConcurrencyStamp,
    PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled,
    LockoutEnd, LockoutEnabled, AccessFailedCount,
    FullName, AvatarUrl, IsActive, MustChangePassword,
    CreatedByUserId, CreatedAt, UpdatedAt
)
SELECT
    CONVERT(NVARCHAR(450), NEWID()),
    S.Email,
    UPPER(S.Email),
    S.Email,
    UPPER(S.Email),
    1,
    S.PasswordHash,
    CONVERT(NVARCHAR(36), NEWID()),
    CONVERT(NVARCHAR(36), NEWID()),
    S.PhoneNumber,
    0,
    0,
    NULL,
    1,
    0,
    S.FullName,
    NULL,
    ISNULL(S.IsActive, 1),
    ISNULL(S.MustChangePassword, 0),
    NULL,
    SYSUTCDATETIME(),
    NULL
FROM #SeedUsers AS S
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.AspNetUsers AS U
    WHERE U.Email = S.Email
);

/* =========================================================
   9) UserRoles (sync for seeded users)
   ========================================================= */
DELETE UR
FROM dbo.AspNetUserRoles AS UR
JOIN dbo.AspNetUsers AS U
    ON U.Id = UR.UserId
JOIN #SeedUsers AS SU
    ON SU.Email = U.Email;

INSERT INTO dbo.AspNetUserRoles (UserId, RoleId)
SELECT
    U.Id,
    R.Id
FROM #SeedUserRoles AS S
JOIN dbo.AspNetUsers AS U
    ON U.Email = S.Email
JOIN dbo.AspNetRoles AS R
    ON R.Name = S.RoleName
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.AspNetUserRoles AS UR
    WHERE UR.UserId = U.Id
      AND UR.RoleId = R.Id
);

/* =========================================================
   10) UserAddresses (replace for seeded users)
   ========================================================= */
DELETE UA
FROM dbo.UserAddresses AS UA
JOIN dbo.AspNetUsers AS U
    ON U.Id = UA.UserId
JOIN #SeedUsers AS SU
    ON SU.Email = U.Email;

INSERT INTO dbo.UserAddresses
(
    UserId, ReceiverName, PhoneNumber, Province, District, Ward, StreetAddress, IsDefault, CreatedAt
)
SELECT
    U.Id,
    S.ReceiverName,
    S.PhoneNumber,
    S.Province,
    S.District,
    S.Ward,
    S.StreetAddress,
    ISNULL(S.IsDefault, 0),
    SYSUTCDATETIME()
FROM #SeedUserAddresses AS S
JOIN dbo.AspNetUsers AS U
    ON U.Email = S.UserEmail;

/* =========================================================
   11) Orders
   ========================================================= */
UPDATE O
SET
    O.UserId = U.Id,
    O.ReceiverName = S.ReceiverName,
    O.PhoneNumber = S.PhoneNumber,
    O.ShippingAddress = S.ShippingAddress,
    O.OrderStatus = S.OrderStatus,
    O.PaymentStatus = S.PaymentStatus,
    O.PaymentMethod = S.PaymentMethod,
    O.Subtotal = ISNULL(S.Subtotal, 0),
    O.ShippingFee = ISNULL(S.ShippingFee, 0),
    O.DiscountAmount = 0,
    O.TotalAmount = ISNULL(S.TotalAmount, 0),
    O.CreatedAt = ISNULL(S.CreatedAt, O.CreatedAt),
    O.UpdatedAt = SYSUTCDATETIME()
FROM dbo.Orders AS O
JOIN #SeedOrders AS S
    ON O.OrderCode = S.OrderCode
JOIN dbo.AspNetUsers AS U
    ON U.Email = S.CustomerEmail;

INSERT INTO dbo.Orders
(
    OrderCode, UserId, ReceiverName, PhoneNumber, ShippingAddress,
    OrderStatus, PaymentStatus, PaymentMethod, Subtotal, ShippingFee,
    DiscountAmount, TotalAmount, CreatedAt, UpdatedAt, Note
)
SELECT
    S.OrderCode,
    U.Id,
    S.ReceiverName,
    S.PhoneNumber,
    S.ShippingAddress,
    S.OrderStatus,
    S.PaymentStatus,
    S.PaymentMethod,
    ISNULL(S.Subtotal, 0),
    ISNULL(S.ShippingFee, 0),
    0,
    ISNULL(S.TotalAmount, 0),
    ISNULL(S.CreatedAt, SYSUTCDATETIME()),
    NULL,
    NULL
FROM #SeedOrders AS S
JOIN dbo.AspNetUsers AS U
    ON U.Email = S.CustomerEmail
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Orders AS O
    WHERE O.OrderCode = S.OrderCode
);

/* =========================================================
   12) OrderItems (replace for seeded orders)
   ========================================================= */
DELETE OI
FROM dbo.OrderItems AS OI
JOIN dbo.Orders AS O
    ON O.Id = OI.OrderId
JOIN #SeedOrders AS SO
    ON SO.OrderCode = O.OrderCode;

INSERT INTO dbo.OrderItems
(
    OrderId, ProductId, ProductNameSnapshot, UnitPrice, Quantity, LineTotal
)
SELECT
    O.Id,
    P.Id,
    S.ProductNameSnapshot,
    ISNULL(S.UnitPrice, 0),
    ISNULL(S.Quantity, 0),
    ISNULL(S.LineTotal, ISNULL(S.UnitPrice, 0) * ISNULL(S.Quantity, 0))
FROM #SeedOrderItems AS S
JOIN dbo.Orders AS O
    ON O.OrderCode = S.OrderCode
JOIN dbo.Products AS P
    ON P.SKU = S.ProductSKU;

/* =========================================================
   13) Payments (1 row / order, derived from Orders sheet)
   ========================================================= */
DELETE PM
FROM dbo.Payments AS PM
JOIN dbo.Orders AS O
    ON O.Id = PM.OrderId
JOIN #SeedOrders AS SO
    ON SO.OrderCode = O.OrderCode;

INSERT INTO dbo.Payments
(
    OrderId, PaymentMethod, PaymentStatus, Amount, TransactionCode, PaidAt, CreatedAt, Note
)
SELECT
    O.Id,
    S.PaymentMethod,
    S.PaymentStatus,
    ISNULL(S.Amount, 0),
    S.TransactionCode,
    S.PaidAt,
    SYSUTCDATETIME(),
    S.Note
FROM #SeedPayments AS S
JOIN dbo.Orders AS O
    ON O.OrderCode = S.OrderCode;

/* =========================================================
   14) Reviews
   ========================================================= */
UPDATE R
SET
    R.Rating = S.Rating,
    R.Comment = S.Comment,
    R.IsApproved = ISNULL(S.IsApproved, 0),
    R.CreatedAt = ISNULL(S.CreatedAt, R.CreatedAt),
    R.UpdatedAt = SYSUTCDATETIME()
FROM dbo.Reviews AS R
JOIN dbo.Products AS P
    ON P.Id = R.ProductId
JOIN dbo.AspNetUsers AS U
    ON U.Id = R.UserId
JOIN #SeedReviews AS S
    ON P.SKU = S.ProductSKU
   AND U.Email = S.UserEmail;

INSERT INTO dbo.Reviews
(
    ProductId, UserId, Rating, Comment, IsApproved, CreatedAt, UpdatedAt
)
SELECT
    P.Id,
    U.Id,
    S.Rating,
    S.Comment,
    ISNULL(S.IsApproved, 0),
    ISNULL(S.CreatedAt, SYSUTCDATETIME()),
    NULL
FROM #SeedReviews AS S
JOIN dbo.Products AS P
    ON P.SKU = S.ProductSKU
JOIN dbo.AspNetUsers AS U
    ON U.Email = S.UserEmail
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Reviews AS R
    WHERE R.ProductId = P.Id
      AND R.UserId = U.Id
);

/* =========================================================
   15) SupportTickets
   ========================================================= */
UPDATE T
SET
    T.UserId = U.Id,
    T.Title = S.Title,
    T.Content = S.Content,
    T.Status = S.Status,
    T.Priority = S.Priority,
    T.AssignedToUserId = AU.Id,
    T.UpdatedAt = SYSUTCDATETIME(),
    T.CreatedAt = ISNULL(S.CreatedAt, T.CreatedAt),
    T.ClosedAt = CASE WHEN S.Status = N'Closed' THEN ISNULL(T.ClosedAt, SYSUTCDATETIME()) ELSE NULL END
FROM dbo.SupportTickets AS T
JOIN #SeedSupportTickets AS S
    ON T.TicketCode = S.TicketCode
JOIN dbo.AspNetUsers AS U
    ON U.Email = S.UserEmail
LEFT JOIN dbo.AspNetUsers AS AU
    ON AU.Email = S.AssignedToEmail;

INSERT INTO dbo.SupportTickets
(
    TicketCode, UserId, OrderId, Title, Content, Status, Priority,
    AssignedToUserId, CreatedAt, UpdatedAt, ClosedAt
)
SELECT
    S.TicketCode,
    U.Id,
    NULL,
    S.Title,
    S.Content,
    S.Status,
    S.Priority,
    AU.Id,
    ISNULL(S.CreatedAt, SYSUTCDATETIME()),
    NULL,
    CASE WHEN S.Status = N'Closed' THEN ISNULL(S.CreatedAt, SYSUTCDATETIME()) ELSE NULL END
FROM #SeedSupportTickets AS S
JOIN dbo.AspNetUsers AS U
    ON U.Email = S.UserEmail
LEFT JOIN dbo.AspNetUsers AS AU
    ON AU.Email = S.AssignedToEmail
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.SupportTickets AS T
    WHERE T.TicketCode = S.TicketCode
);

COMMIT TRAN;
PRINT N'Seed/import du lieu tu workbook da hoan tat thanh cong.';


/* ============================================================================
   END FILE: TechZone_SeedImport_FromExcel.sql
   ============================================================================ */


/* ============================================================================
   BEGIN FILE: TechZone_Seed_Warehouse_Demo.sql
   ============================================================================ */


/*
    TechZone_Seed_Warehouse_Demo.sql

    Muc tieu:
    - Seed du lieu demo cho phan Suppliers / Kho / Nhap hang / StockTransactions
    - Chay SAU KHI da chay:
        1) TechZone_FullSchema.sql
        2) TechZone_SeedImport_FromExcel.sql

    Pham vi:
    - Upsert role noi bo neu bi thieu
    - Tao / cap nhat mot nhom tai khoan nhan vien noi bo de demo
    - Tao / cap nhat Suppliers
    - Tao PurchaseReceipts + PurchaseReceiptItems cho TOAN BO Products hien co
    - Tao StockTransactions IMPORT / EXPORT de mo phong lich su kho
    - Script co tinh idempotent thuc dung:
        + Xoa va tao lai DU LIEU DEMO do script nay tao (ReceiptCode PR-DEMO-%, Note prefix DEMO-WAREHOUSE:)
        + Khong xoa du lieu kinh doanh khac cua ban

    Luu y thiet ke:
    - Script KHONG cap nhat Products.StockQuantity.
      Thay vao do, StockTransactions duoc tao sao cho AfterQuantity ket thuc bang ton hien tai trong Products.
    - Neu san pham hien tai co ton = 0, script van tao 1 IMPORT va 1 EXPORT de lich su kho hop ly.
*/

USE [TechZoneStoreDb];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRAN;

    DECLARE @FallbackPasswordHash NVARCHAR(MAX) = N'AQAAAAIAAYagAAAAEEyAxQC/1bajpgWzb3bNVBkWiE2HpYjurOHqhU4UK9lmQUujo9hT/BTRVvjjwjnx6g==';
    DECLARE @DefaultPasswordHash NVARCHAR(MAX) =
    (
        SELECT TOP (1) PasswordHash
        FROM dbo.AspNetUsers
        WHERE Email IN (N'admin@powertech.vn', N'admin@techzonestore.com')
          AND PasswordHash IS NOT NULL
        ORDER BY CASE WHEN Email = N'admin@powertech.vn' THEN 0 ELSE 1 END
    );

    SET @DefaultPasswordHash = ISNULL(@DefaultPasswordHash, @FallbackPasswordHash);

    DECLARE @SeedCreatedByUserId NVARCHAR(450) =
    (
        SELECT TOP (1) U.Id
        FROM dbo.AspNetUsers U
        LEFT JOIN dbo.AspNetUserRoles UR ON UR.UserId = U.Id
        LEFT JOIN dbo.AspNetRoles R ON R.Id = UR.RoleId
        ORDER BY
            CASE WHEN U.Email = N'admin@powertech.vn' THEN 0 ELSE 1 END,
            CASE WHEN R.Name = N'Admin' THEN 0 ELSE 1 END,
            U.CreatedAt
    );

    IF @SeedCreatedByUserId IS NULL
    BEGIN
        RAISERROR(N'Khong tim thay user nao trong AspNetUsers. Hay chay file import users truoc.', 16, 1);
        RETURN;
    END;

    /* =========================================================
       1) Roles noi bo
       ========================================================= */
    IF OBJECT_ID('tempdb..#SeedRoles') IS NOT NULL DROP TABLE #SeedRoles;
    CREATE TABLE #SeedRoles
    (
        RoleName     NVARCHAR(256) NOT NULL,
        Description  NVARCHAR(500) NULL
    );

    INSERT INTO #SeedRoles (RoleName, Description)
    VALUES
        (N'Admin', N'Quan tri he thong'),
        (N'SalesStaff', N'Nhan vien ban hang'),
        (N'WarehouseStaff', N'Nhan vien kho'),
        (N'SupportStaff', N'Nhan vien ho tro'),
        (N'Customer', N'Khach hang');

    UPDATE R
    SET
        R.NormalizedName = UPPER(S.RoleName),
        R.Description = ISNULL(S.Description, R.Description),
        R.IsActive = 1
    FROM dbo.AspNetRoles R
    JOIN #SeedRoles S
        ON R.Name = S.RoleName;

    INSERT INTO dbo.AspNetRoles (Id, Name, NormalizedName, ConcurrencyStamp, Description, IsActive, CreatedAt)
    SELECT
        CONVERT(NVARCHAR(450), NEWID()),
        S.RoleName,
        UPPER(S.RoleName),
        CONVERT(NVARCHAR(36), NEWID()),
        S.Description,
        1,
        SYSUTCDATETIME()
    FROM #SeedRoles S
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.AspNetRoles R
        WHERE R.Name = S.RoleName
    );

    /* =========================================================
       2) Seed tai khoan noi bo de demo kho / sales
       ========================================================= */
    IF OBJECT_ID('tempdb..#SeedStaffUsers') IS NOT NULL DROP TABLE #SeedStaffUsers;
    CREATE TABLE #SeedStaffUsers
    (
        Email               NVARCHAR(256) NOT NULL,
        FullName            NVARCHAR(150) NOT NULL,
        PhoneNumber         NVARCHAR(20) NULL,
        RoleName            NVARCHAR(256) NOT NULL,
        MustChangePassword  BIT NOT NULL,
        Province            NVARCHAR(100) NULL,
        District            NVARCHAR(100) NULL,
        Ward                NVARCHAR(100) NULL,
        StreetAddress       NVARCHAR(255) NULL
    );

    INSERT INTO #SeedStaffUsers
    (
        Email, FullName, PhoneNumber, RoleName, MustChangePassword,
        Province, District, Ward, StreetAddress
    )
    VALUES
        (N'warehouse1@powertech.vn', N'Le Van Kho', N'0903333331', N'WarehouseStaff', 1, N'TP.HCM', N'Go Vap', N'Ward 5', N'Kho PowerTech - 12 Nguyen Van Bao'),
        (N'warehouse2@powertech.vn', N'Pham Thi Nhan Kho', N'0903333332', N'WarehouseStaff', 1, N'TP.HCM', N'Binh Thanh', N'Ward 25', N'Kho PowerTech - 18 Dien Bien Phu'),
        (N'sales1@powertech.vn', N'Nguyen Thi Sales', N'0904444444', N'SalesStaff', 1, N'TP.HCM', N'Phu Nhuan', N'Ward 9', N'Van phong PowerTech - 25 Hoang Van Thu');

    UPDATE U
    SET
        U.UserName = S.Email,
        U.NormalizedUserName = UPPER(S.Email),
        U.Email = S.Email,
        U.NormalizedEmail = UPPER(S.Email),
        U.EmailConfirmed = 1,
        U.PasswordHash = COALESCE(U.PasswordHash, @DefaultPasswordHash),
        U.PhoneNumber = S.PhoneNumber,
        U.FullName = S.FullName,
        U.IsActive = 1,
        U.MustChangePassword = 1,
        U.CreatedByUserId = COALESCE(U.CreatedByUserId, @SeedCreatedByUserId),
        U.UpdatedAt = SYSUTCDATETIME()
    FROM dbo.AspNetUsers U
    JOIN #SeedStaffUsers S
        ON U.Email = S.Email;

    INSERT INTO dbo.AspNetUsers
    (
        Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed,
        PasswordHash, SecurityStamp, ConcurrencyStamp,
        PhoneNumber, PhoneNumberConfirmed, TwoFactorEnabled,
        LockoutEnd, LockoutEnabled, AccessFailedCount,
        FullName, AvatarUrl, IsActive, MustChangePassword,
        CreatedByUserId, CreatedAt, UpdatedAt
    )
    SELECT
        CONVERT(NVARCHAR(450), NEWID()),
        S.Email,
        UPPER(S.Email),
        S.Email,
        UPPER(S.Email),
        1,
        @DefaultPasswordHash,
        CONVERT(NVARCHAR(36), NEWID()),
        CONVERT(NVARCHAR(36), NEWID()),
        S.PhoneNumber,
        0,
        0,
        NULL,
        1,
        0,
        S.FullName,
        NULL,
        1,
        S.MustChangePassword,
        @SeedCreatedByUserId,
        SYSUTCDATETIME(),
        NULL
    FROM #SeedStaffUsers S
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.AspNetUsers U
        WHERE U.Email = S.Email
    );

    INSERT INTO dbo.AspNetUserRoles (UserId, RoleId)
    SELECT
        U.Id,
        R.Id
    FROM #SeedStaffUsers S
    JOIN dbo.AspNetUsers U
        ON U.Email = S.Email
    JOIN dbo.AspNetRoles R
        ON R.Name = S.RoleName
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.AspNetUserRoles UR
        WHERE UR.UserId = U.Id
          AND UR.RoleId = R.Id
    );

    /* Dat dia chi giao / lien he mac dinh cho user noi bo neu chua co */
    ;WITH PreferredAddress AS
    (
        SELECT
            U.Id AS UserId,
            S.FullName AS ReceiverName,
            S.PhoneNumber,
            S.Province,
            S.District,
            S.Ward,
            S.StreetAddress,
            ROW_NUMBER() OVER (PARTITION BY U.Id ORDER BY UA.Id) AS RN
        FROM #SeedStaffUsers S
        JOIN dbo.AspNetUsers U
            ON U.Email = S.Email
        LEFT JOIN dbo.UserAddresses UA
            ON UA.UserId = U.Id
    )
    INSERT INTO dbo.UserAddresses
    (
        UserId, ReceiverName, PhoneNumber, Province, District, Ward, StreetAddress,
        IsDefault, CreatedAt, UpdatedAt
    )
    SELECT
        P.UserId, P.ReceiverName, P.PhoneNumber, P.Province, P.District, P.Ward, P.StreetAddress,
        1, SYSUTCDATETIME(), NULL
    FROM PreferredAddress P
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.UserAddresses UA
        WHERE UA.UserId = P.UserId
    );

    DECLARE @WarehouseUserId NVARCHAR(450) =
    (
        SELECT TOP (1) U.Id
        FROM dbo.AspNetUsers U
        JOIN dbo.AspNetUserRoles UR ON UR.UserId = U.Id
        JOIN dbo.AspNetRoles R ON R.Id = UR.RoleId
        WHERE R.Name = N'WarehouseStaff'
        ORDER BY CASE WHEN U.Email = N'warehouse1@powertech.vn' THEN 0 ELSE 1 END, U.CreatedAt
    );

    SET @WarehouseUserId = ISNULL(@WarehouseUserId, @SeedCreatedByUserId);

    /* =========================================================
       3) Suppliers
       ========================================================= */
    IF OBJECT_ID('tempdb..#SeedSuppliers') IS NOT NULL DROP TABLE #SeedSuppliers;
    CREATE TABLE #SeedSuppliers
    (
        [Name]        NVARCHAR(150) NOT NULL,
        ContactName   NVARCHAR(150) NULL,
        PhoneNumber   NVARCHAR(20) NULL,
        Email         NVARCHAR(256) NULL,
        [Address]     NVARCHAR(500) NULL,
        TaxCode       NVARCHAR(50) NULL
    );

    INSERT INTO #SeedSuppliers ([Name], ContactName, PhoneNumber, Email, [Address], TaxCode)
    VALUES
        (N'Intel Distribution Vietnam', N'Nguyen Minh Intel', N'02873001111', N'intel.dist@vendor.vn', N'Lot 12, Saigon Hi-Tech Park, Thu Duc, TP.HCM', N'0312345601'),
        (N'AMD Components Vietnam', N'Tran Quoc AMD', N'02873002222', N'amd.dist@vendor.vn', N'No. 8, Street 17, Thu Duc, TP.HCM', N'0312345602'),
        (N'Mainboard VGA Tech Distributor', N'Le Huu Main', N'02873003333', N'mbvga@vendor.vn', N'88 Nguyen Xi, Binh Thanh, TP.HCM', N'0312345603'),
        (N'Memory Storage Parts Hub', N'Pham Storage', N'02873004444', N'storage@vendor.vn', N'45 Quang Trung, Go Vap, TP.HCM', N'0312345604'),
        (N'Gear Peripheral Trading', N'Doan Gear', N'02873005555', N'gear@vendor.vn', N'120 Cong Hoa, Tan Binh, TP.HCM', N'0312345605'),
        (N'Display Network Supply', N'Vo Network', N'02873006666', N'displaynet@vendor.vn', N'32 Dien Bien Phu, Binh Thanh, TP.HCM', N'0312345606'),
        (N'Laptop PC System Distributor', N'Hoang System', N'02873007777', N'laptop-pc@vendor.vn', N'210 Phan Van Tri, Go Vap, TP.HCM', N'0312345607'),
        (N'PowerTech General Supplier', N'Nguyen Tong Hop', N'02873008888', N'general@vendor.vn', N'56 Le Duc Tho, Go Vap, TP.HCM', N'0312345608');

    UPDATE T
    SET
        T.ContactName = S.ContactName,
        T.PhoneNumber = S.PhoneNumber,
        T.Email = S.Email,
        T.[Address] = S.[Address],
        T.TaxCode = S.TaxCode,
        T.IsActive = 1,
        T.UpdatedAt = SYSUTCDATETIME()
    FROM dbo.Suppliers T
    JOIN #SeedSuppliers S
        ON T.[Name] = S.[Name];

    INSERT INTO dbo.Suppliers
    (
        [Name], ContactName, PhoneNumber, Email, [Address], TaxCode, IsActive, CreatedAt, UpdatedAt
    )
    SELECT
        S.[Name], S.ContactName, S.PhoneNumber, S.Email, S.[Address], S.TaxCode, 1, SYSUTCDATETIME(), NULL
    FROM #SeedSuppliers S
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.Suppliers T
        WHERE T.[Name] = S.[Name]
    );

    /* =========================================================
       4) Xoa du lieu demo cu do script nay tao
       ========================================================= */
    DELETE FROM dbo.StockTransactions
    WHERE Note LIKE N'DEMO-WAREHOUSE:%';

    DELETE PRI
    FROM dbo.PurchaseReceiptItems PRI
    JOIN dbo.PurchaseReceipts PR
        ON PR.Id = PRI.PurchaseReceiptId
    WHERE PR.ReceiptCode LIKE N'PR-DEMO-%';

    DELETE FROM dbo.PurchaseReceipts
    WHERE ReceiptCode LIKE N'PR-DEMO-%';

    /* =========================================================
       5) Lap ke hoach nhap kho cho toan bo product hien co
       ========================================================= */
    IF OBJECT_ID('tempdb..#ProductWarehousePlan') IS NOT NULL DROP TABLE #ProductWarehousePlan;
    CREATE TABLE #ProductWarehousePlan
    (
        ProductId      INT NOT NULL,
        SupplierName   NVARCHAR(150) NOT NULL,
        ReceiptCode    NVARCHAR(50) NOT NULL,
        ReceiptDate    DATETIME2(7) NOT NULL,
        ImportQty      INT NOT NULL,
        ImportPrice    DECIMAL(18,2) NOT NULL,
        ExportQty      INT NOT NULL,
        ExportDate     DATETIME2(7) NOT NULL
    );

    ;WITH ProductBase AS
    (
        SELECT
            P.Id AS ProductId,
            P.SKU,
            P.[Name] AS ProductName,
            P.Price,
            P.DiscountPrice,
            P.StockQuantity AS CurrentStock,
            ISNULL(B.[Name], N'') AS BrandName,
            ISNULL(C.[Name], N'') AS CategoryName
        FROM dbo.Products P
        JOIN dbo.Brands B
            ON B.Id = P.BrandId
        JOIN dbo.Categories C
            ON C.Id = P.CategoryId
    ),
    ProductMapped AS
    (
        SELECT
            PB.ProductId,
            PB.SKU,
            PB.ProductName,
            PB.Price,
            PB.DiscountPrice,
            PB.CurrentStock,
            PB.BrandName,
            PB.CategoryName,
            CASE
                WHEN PB.CategoryName IN (N'Laptop', N'PC bộ') THEN N'Laptop PC System Distributor'
                WHEN PB.CategoryName IN (N'Màn hình', N'Thiết bị mạng') THEN N'Display Network Supply'
                WHEN PB.BrandName IN (N'Intel') THEN N'Intel Distribution Vietnam'
                WHEN PB.BrandName IN (N'AMD', N'Sapphire', N'PowerColor', N'XFX') THEN N'AMD Components Vietnam'
                WHEN PB.CategoryName IN (N'Mainboard', N'Card đồ họa')
                     OR PB.BrandName IN (N'ASUS', N'MSI', N'Gigabyte', N'ASRock', N'ZOTAC', N'Colorful', N'Palit', N'Inno3D', N'GALAX', N'Leadtek')
                    THEN N'Mainboard VGA Tech Distributor'
                WHEN PB.CategoryName IN (N'RAM', N'Ổ cứng', N'Nguồn máy tính', N'Case')
                     OR PB.BrandName IN (N'Kingston', N'Corsair', N'TeamGroup', N'Samsung', N'WD', N'Seagate', N'Crucial', N'G.Skill', N'ADATA', N'Apacer', N'Lexar', N'Kioxia', N'Hiksemi', N'Deepcool', N'Cooler Master', N'NZXT', N'Thermaltake', N'Antec')
                    THEN N'Memory Storage Parts Hub'
                WHEN PB.CategoryName IN (N'Bàn phím', N'Chuột', N'Tai nghe', N'Loa', N'Phụ kiện', N'Phần mềm')
                     OR PB.BrandName IN (N'Logitech', N'Razer', N'HyperX', N'Dareu', N'Rapoo', N'SteelSeries', N'Akko', N'Fuhlen')
                    THEN N'Gear Peripheral Trading'
                ELSE N'PowerTech General Supplier'
            END AS SupplierName,
            CAST
            (
                CASE
                    WHEN PB.CategoryName = N'CPU' THEN 0.82
                    WHEN PB.CategoryName = N'Mainboard' THEN 0.78
                    WHEN PB.CategoryName = N'RAM' THEN 0.74
                    WHEN PB.CategoryName = N'Card đồ họa' THEN 0.85
                    WHEN PB.CategoryName = N'Ổ cứng' THEN 0.72
                    WHEN PB.CategoryName = N'Nguồn máy tính' THEN 0.70
                    WHEN PB.CategoryName = N'Case' THEN 0.68
                    WHEN PB.CategoryName = N'Màn hình' THEN 0.76
                    WHEN PB.CategoryName = N'Bàn phím' THEN 0.65
                    WHEN PB.CategoryName = N'Chuột' THEN 0.65
                    WHEN PB.CategoryName = N'Tai nghe' THEN 0.67
                    WHEN PB.CategoryName = N'Loa' THEN 0.66
                    WHEN PB.CategoryName = N'Thiết bị mạng' THEN 0.73
                    WHEN PB.CategoryName = N'Phụ kiện' THEN 0.60
                    WHEN PB.CategoryName = N'Phần mềm' THEN 0.55
                    WHEN PB.CategoryName = N'Laptop' THEN 0.88
                    WHEN PB.CategoryName = N'PC bộ' THEN 0.90
                    ELSE 0.75
                END
            AS DECIMAL(10,4)) AS MarginFactor,
            CASE
                WHEN PB.CurrentStock = 0 THEN 1
                WHEN PB.CurrentStock >= 30 THEN 4
                WHEN PB.CurrentStock >= 20 THEN 3
                WHEN PB.CurrentStock >= 10 THEN 2
                ELSE 1
            END AS ExportQty
        FROM ProductBase PB
    ),
    SupplierOrd AS
    (
        SELECT
            S.[Name] AS SupplierName,
            ROW_NUMBER() OVER (ORDER BY S.[Name]) AS SupplierOrder
        FROM dbo.Suppliers S
        WHERE EXISTS
        (
            SELECT 1
            FROM ProductMapped PM
            WHERE PM.SupplierName = S.[Name]
        )
    )
    INSERT INTO #ProductWarehousePlan
    (
        ProductId, SupplierName, ReceiptCode, ReceiptDate,
        ImportQty, ImportPrice, ExportQty, ExportDate
    )
    SELECT
        PM.ProductId,
        PM.SupplierName,
        CONCAT(N'PR-DEMO-', RIGHT(N'000' + CAST(SO.SupplierOrder AS NVARCHAR(10)), 3)) AS ReceiptCode,
        DATEADD(DAY, SO.SupplierOrder - 1, CAST(N'2026-03-15T09:00:00' AS DATETIME2(7))) AS ReceiptDate,
        PM.CurrentStock + PM.ExportQty AS ImportQty,
        CAST
        (
            CASE
                WHEN ROUND(ISNULL(NULLIF(PM.DiscountPrice, 0), PM.Price) * PM.MarginFactor, -3) < 10000
                    THEN 10000
                ELSE ROUND(ISNULL(NULLIF(PM.DiscountPrice, 0), PM.Price) * PM.MarginFactor, -3)
            END
        AS DECIMAL(18,2)) AS ImportPrice,
        PM.ExportQty,
        DATEADD(DAY, 14 + (PM.ProductId % 5), DATEADD(DAY, SO.SupplierOrder - 1, CAST(N'2026-03-15T09:00:00' AS DATETIME2(7)))) AS ExportDate
    FROM ProductMapped PM
    JOIN SupplierOrd SO
        ON SO.SupplierName = PM.SupplierName;

    /* =========================================================
       6) Tao purchase receipts
       ========================================================= */
    INSERT INTO dbo.PurchaseReceipts
    (
        ReceiptCode, SupplierId, CreatedByUserId, ReceiptDate, [Status], Subtotal, TotalAmount, Note
    )
    SELECT DISTINCT
        P.ReceiptCode,
        S.Id,
        @WarehouseUserId,
        P.ReceiptDate,
        N'Completed',
        0,
        0,
        N'DEMO-WAREHOUSE: Nhap kho demo duoc tao tu catalog san pham hien tai'
    FROM #ProductWarehousePlan P
    JOIN dbo.Suppliers S
        ON S.[Name] = P.SupplierName;

    INSERT INTO dbo.PurchaseReceiptItems
    (
        PurchaseReceiptId, ProductId, Quantity, ImportPrice, LineTotal
    )
    SELECT
        PR.Id,
        P.ProductId,
        P.ImportQty,
        P.ImportPrice,
        CAST(P.ImportQty * P.ImportPrice AS DECIMAL(18,2)) AS LineTotal
    FROM #ProductWarehousePlan P
    JOIN dbo.PurchaseReceipts PR
        ON PR.ReceiptCode = P.ReceiptCode;

    ;WITH ReceiptTotals AS
    (
        SELECT
            PRI.PurchaseReceiptId,
            CAST(SUM(PRI.LineTotal) AS DECIMAL(18,2)) AS Subtotal
        FROM dbo.PurchaseReceiptItems PRI
        GROUP BY PRI.PurchaseReceiptId
    )
    UPDATE PR
    SET
        PR.Subtotal = RT.Subtotal,
        PR.TotalAmount = RT.Subtotal
    FROM dbo.PurchaseReceipts PR
    JOIN ReceiptTotals RT
        ON RT.PurchaseReceiptId = PR.Id
    WHERE PR.ReceiptCode LIKE N'PR-DEMO-%';

    /* =========================================================
       7) StockTransactions IMPORT / EXPORT
       ========================================================= */
    INSERT INTO dbo.StockTransactions
    (
        ProductId, PerformedByUserId, TransactionType, Quantity,
        ReferenceType, ReferenceId, BeforeQuantity, AfterQuantity,
        Note, CreatedAt
    )
    SELECT
        P.ProductId,
        @WarehouseUserId,
        N'IMPORT',
        P.ImportQty,
        N'PurchaseReceipt',
        PR.Id,
        0,
        P.ImportQty,
        CONCAT(N'DEMO-WAREHOUSE: Nhap kho demo theo phieu ', PR.ReceiptCode, N' / ', P.SupplierName),
        DATEADD(MINUTE, P.ProductId % 240, P.ReceiptDate)
    FROM #ProductWarehousePlan P
    JOIN dbo.PurchaseReceipts PR
        ON PR.ReceiptCode = P.ReceiptCode;

    INSERT INTO dbo.StockTransactions
    (
        ProductId, PerformedByUserId, TransactionType, Quantity,
        ReferenceType, ReferenceId, BeforeQuantity, AfterQuantity,
        Note, CreatedAt
    )
    SELECT
        P.ProductId,
        @WarehouseUserId,
        N'EXPORT',
        P.ExportQty,
        N'DemoExport',
        NULL,
        P.ImportQty,
        P.ImportQty - P.ExportQty,
        N'DEMO-WAREHOUSE: Xuat kho demo de can bang ton kho ban dau',
        DATEADD(MINUTE, (P.ProductId * 7) % 180, P.ExportDate)
    FROM #ProductWarehousePlan P
    WHERE P.ExportQty > 0;

    COMMIT TRAN;

    DECLARE @SupplierCount INT = (SELECT COUNT(*) FROM #SeedSuppliers);
    DECLARE @ReceiptCount INT = (SELECT COUNT(DISTINCT ReceiptCode) FROM #ProductWarehousePlan);
    DECLARE @ReceiptItemCount INT = (SELECT COUNT(*) FROM #ProductWarehousePlan);
    DECLARE @TransactionCount INT = (SELECT COUNT(*) FROM #ProductWarehousePlan) + (SELECT COUNT(*) FROM #ProductWarehousePlan WHERE ExportQty > 0);
    DECLARE @StaffCount INT = (SELECT COUNT(*) FROM #SeedStaffUsers);

    PRINT N'=== TECHZONE DEMO WAREHOUSE SEED COMPLETED ===';
    PRINT N'Staff users upserted: ' + CAST(@StaffCount AS NVARCHAR(20));
    PRINT N'Suppliers upserted: ' + CAST(@SupplierCount AS NVARCHAR(20));
    PRINT N'Purchase receipts created: ' + CAST(@ReceiptCount AS NVARCHAR(20));
    PRINT N'Purchase receipt items created: ' + CAST(@ReceiptItemCount AS NVARCHAR(20));
    PRINT N'Stock transactions created: ' + CAST(@TransactionCount AS NVARCHAR(20));
GO


/* ============================================================================
   END FILE: TechZone_Seed_Warehouse_Demo.sql
   ============================================================================ */


/* ============================================================================
   BEGIN FILE: TechZone_Report_Sample.sql
   ============================================================================ */


/*
    TechZone_Report_Sample.sql

    Muc tieu:
    - Tao bo VIEW / STORED PROCEDURE bao cao mau de demo do an:
        1) Doanh thu tong quan
        2) Doanh thu theo ngay / thang
        3) Top san pham ban chay
        4) Ton kho thap
        5) Don hang theo trang thai
        6) Thanh toan theo phuong thuc / trang thai
        7) Hieu qua danh muc / thuong hieu
        8) Hieu qua nha cung cap / nhap hang

    Yeu cau:
    - Chay SAU KHI da chay:
        1) TechZone_FullSchema.sql
        2) TechZone_SeedImport_FromExcel.sql
        3) TechZone_Seed_Warehouse_Demo.sql

    Nen tang:
    - SQL Server
    - Schema: TechZoneStoreDb
*/

USE [TechZoneStoreDb];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   A. VIEW: Tong hop doanh thu theo don hang
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_Report_OrderRevenue
AS
SELECT
    O.Id,
    O.OrderCode,
    O.UserId,
    U.Email AS CustomerEmail,
    U.FullName AS CustomerFullName,
    O.OrderStatus,
    O.PaymentStatus,
    O.PaymentMethod,
    O.Subtotal,
    O.ShippingFee,
    O.DiscountAmount,
    O.TotalAmount,
    O.CreatedAt,
    O.UpdatedAt,
    O.Note,
    CASE
        WHEN O.OrderStatus IN (N'Completed', N'Shipping', N'Processing', N'Confirmed') THEN 1
        ELSE 0
    END AS IsRevenueOrder,
    CASE
        WHEN O.OrderStatus = N'Completed' THEN O.TotalAmount
        ELSE 0
    END AS CompletedRevenue,
    CASE
        WHEN O.PaymentStatus = N'Paid' THEN O.TotalAmount
        ELSE 0
    END AS PaidRevenue
FROM dbo.Orders O
LEFT JOIN dbo.AspNetUsers U
    ON U.Id = O.UserId;
GO

/* =========================================================
   B. VIEW: Chi tiet ban hang theo dong san pham
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_Report_SalesDetail
AS
SELECT
    O.Id AS OrderId,
    O.OrderCode,
    O.CreatedAt AS OrderCreatedAt,
    O.OrderStatus,
    O.PaymentStatus,
    O.PaymentMethod,
    O.UserId,
    U.Email AS CustomerEmail,
    OI.Id AS OrderItemId,
    OI.ProductId,
    P.SKU,
    P.Name AS ProductName,
    P.CategoryId,
    C.Name AS CategoryName,
    P.BrandId,
    B.Name AS BrandName,
    OI.UnitPrice,
    OI.Quantity,
    OI.LineTotal
FROM dbo.OrderItems OI
INNER JOIN dbo.Orders O
    ON O.Id = OI.OrderId
INNER JOIN dbo.Products P
    ON P.Id = OI.ProductId
INNER JOIN dbo.Categories C
    ON C.Id = P.CategoryId
INNER JOIN dbo.Brands B
    ON B.Id = P.BrandId
LEFT JOIN dbo.AspNetUsers U
    ON U.Id = O.UserId;
GO

/* =========================================================
   C. VIEW: Ton kho hien tai + tong nhap/xuat lich su
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_Report_InventorySnapshot
AS
SELECT
    P.Id AS ProductId,
    P.SKU,
    P.Name AS ProductName,
    C.Name AS CategoryName,
    B.Name AS BrandName,
    P.Price,
    P.StockQuantity AS CurrentStock,
    P.SoldQuantity,
    ISNULL(SUM(CASE WHEN ST.TransactionType = N'IMPORT' THEN ST.Quantity ELSE 0 END), 0) AS TotalImportedQty,
    ISNULL(SUM(CASE WHEN ST.TransactionType = N'EXPORT' THEN ST.Quantity ELSE 0 END), 0) AS TotalExportedQty,
    ISNULL(SUM(CASE WHEN ST.TransactionType = N'ADJUST' THEN ST.Quantity ELSE 0 END), 0) AS TotalAdjustedQty,
    MAX(ST.CreatedAt) AS LastStockTransactionAt
FROM dbo.Products P
INNER JOIN dbo.Categories C
    ON C.Id = P.CategoryId
INNER JOIN dbo.Brands B
    ON B.Id = P.BrandId
LEFT JOIN dbo.StockTransactions ST
    ON ST.ProductId = P.Id
GROUP BY
    P.Id, P.SKU, P.Name, C.Name, B.Name, P.Price, P.StockQuantity, P.SoldQuantity;
GO

/* =========================================================
   D. PROCEDURE: Tong quan doanh thu
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_RevenueSummary
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH FilteredOrders AS
    (
        SELECT *
        FROM dbo.Orders O
        WHERE (@DateFrom IS NULL OR O.CreatedAt >= @DateFrom)
          AND (@DateTo   IS NULL OR O.CreatedAt < DATEADD(DAY, 1, @DateTo))
    )
    SELECT
        COUNT(*) AS TotalOrders,
        SUM(CASE WHEN OrderStatus = N'Completed' THEN 1 ELSE 0 END) AS CompletedOrders,
        SUM(CASE WHEN OrderStatus = N'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders,
        SUM(CASE WHEN OrderStatus = N'Returned'  THEN 1 ELSE 0 END) AS ReturnedOrders,

        CAST(ISNULL(SUM(Subtotal), 0) AS DECIMAL(18,2)) AS GrossSubtotal,
        CAST(ISNULL(SUM(ShippingFee), 0) AS DECIMAL(18,2)) AS TotalShippingFee,
        CAST(ISNULL(SUM(DiscountAmount), 0) AS DECIMAL(18,2)) AS TotalDiscountAmount,
        CAST(ISNULL(SUM(TotalAmount), 0) AS DECIMAL(18,2)) AS BookedRevenueAllOrders,

        CAST(ISNULL(SUM(CASE WHEN OrderStatus = N'Completed' THEN TotalAmount ELSE 0 END), 0) AS DECIMAL(18,2)) AS CompletedRevenue,
        CAST(ISNULL(SUM(CASE WHEN PaymentStatus = N'Paid' THEN TotalAmount ELSE 0 END), 0) AS DECIMAL(18,2)) AS PaidRevenue,
        CAST(ISNULL(SUM(CASE WHEN PaymentStatus IN (N'Unpaid', N'Pending') THEN TotalAmount ELSE 0 END), 0) AS DECIMAL(18,2)) AS UnpaidOrPendingRevenue,

        CAST(
            CASE WHEN COUNT(*) = 0 THEN 0
                 ELSE AVG(CAST(TotalAmount AS DECIMAL(18,2)))
            END AS DECIMAL(18,2)
        ) AS AvgOrderValue
    FROM FilteredOrders;
END
GO

/* =========================================================
   E. PROCEDURE: Doanh thu theo ngay
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_RevenueByDay
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CAST(O.CreatedAt AS DATE) AS [OrderDate],
        COUNT(*) AS TotalOrders,
        SUM(CASE WHEN O.OrderStatus = N'Completed' THEN 1 ELSE 0 END) AS CompletedOrders,
        CAST(ISNULL(SUM(O.TotalAmount), 0) AS DECIMAL(18,2)) AS BookedRevenue,
        CAST(ISNULL(SUM(CASE WHEN O.OrderStatus = N'Completed' THEN O.TotalAmount ELSE 0 END), 0) AS DECIMAL(18,2)) AS CompletedRevenue,
        CAST(ISNULL(SUM(CASE WHEN O.PaymentStatus = N'Paid' THEN O.TotalAmount ELSE 0 END), 0) AS DECIMAL(18,2)) AS PaidRevenue
    FROM dbo.Orders O
    WHERE (@DateFrom IS NULL OR O.CreatedAt >= @DateFrom)
      AND (@DateTo   IS NULL OR O.CreatedAt < DATEADD(DAY, 1, @DateTo))
    GROUP BY CAST(O.CreatedAt AS DATE)
    ORDER BY [OrderDate];
END
GO

/* =========================================================
   F. PROCEDURE: Doanh thu theo thang
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_RevenueByMonth
    @Year INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        YEAR(O.CreatedAt) AS [Year],
        MONTH(O.CreatedAt) AS [Month],
        COUNT(*) AS TotalOrders,
        SUM(CASE WHEN O.OrderStatus = N'Completed' THEN 1 ELSE 0 END) AS CompletedOrders,
        CAST(ISNULL(SUM(O.TotalAmount), 0) AS DECIMAL(18,2)) AS BookedRevenue,
        CAST(ISNULL(SUM(CASE WHEN O.OrderStatus = N'Completed' THEN O.TotalAmount ELSE 0 END), 0) AS DECIMAL(18,2)) AS CompletedRevenue,
        CAST(ISNULL(SUM(CASE WHEN O.PaymentStatus = N'Paid' THEN O.TotalAmount ELSE 0 END), 0) AS DECIMAL(18,2)) AS PaidRevenue
    FROM dbo.Orders O
    WHERE (@Year IS NULL OR YEAR(O.CreatedAt) = @Year)
    GROUP BY YEAR(O.CreatedAt), MONTH(O.CreatedAt)
    ORDER BY [Year], [Month];
END
GO

/* =========================================================
   G. PROCEDURE: Top san pham ban chay
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_TopProducts
    @TopN INT = 10,
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL,
    @CompletedOnly BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @TopN IS NULL OR @TopN <= 0
        SET @TopN = 10;

    SELECT TOP (@TopN)
        SD.ProductId,
        SD.SKU,
        SD.ProductName,
        SD.CategoryName,
        SD.BrandName,
        SUM(SD.Quantity) AS TotalSoldQty,
        CAST(SUM(SD.LineTotal) AS DECIMAL(18,2)) AS TotalRevenue,
        COUNT(DISTINCT SD.OrderId) AS TotalOrders,
        CAST(AVG(CAST(SD.UnitPrice AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS AvgUnitPrice
    FROM dbo.vw_Report_SalesDetail SD
    WHERE (@DateFrom IS NULL OR SD.OrderCreatedAt >= @DateFrom)
      AND (@DateTo   IS NULL OR SD.OrderCreatedAt < DATEADD(DAY, 1, @DateTo))
      AND (@CompletedOnly = 0 OR SD.OrderStatus = N'Completed')
    GROUP BY
        SD.ProductId, SD.SKU, SD.ProductName, SD.CategoryName, SD.BrandName
    ORDER BY
        SUM(SD.Quantity) DESC,
        SUM(SD.LineTotal) DESC,
        SD.ProductName;
END
GO

/* =========================================================
   H. PROCEDURE: Top danh muc
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_TopCategories
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL,
    @CompletedOnly BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SD.CategoryName,
        COUNT(DISTINCT SD.ProductId) AS TotalProductsSold,
        SUM(SD.Quantity) AS TotalSoldQty,
        CAST(SUM(SD.LineTotal) AS DECIMAL(18,2)) AS TotalRevenue
    FROM dbo.vw_Report_SalesDetail SD
    WHERE (@DateFrom IS NULL OR SD.OrderCreatedAt >= @DateFrom)
      AND (@DateTo   IS NULL OR SD.OrderCreatedAt < DATEADD(DAY, 1, @DateTo))
      AND (@CompletedOnly = 0 OR SD.OrderStatus = N'Completed')
    GROUP BY SD.CategoryName
    ORDER BY TotalRevenue DESC, TotalSoldQty DESC, SD.CategoryName;
END
GO

/* =========================================================
   I. PROCEDURE: Top thuong hieu
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_TopBrands
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL,
    @CompletedOnly BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SD.BrandName,
        COUNT(DISTINCT SD.ProductId) AS TotalProductsSold,
        SUM(SD.Quantity) AS TotalSoldQty,
        CAST(SUM(SD.LineTotal) AS DECIMAL(18,2)) AS TotalRevenue
    FROM dbo.vw_Report_SalesDetail SD
    WHERE (@DateFrom IS NULL OR SD.OrderCreatedAt >= @DateFrom)
      AND (@DateTo   IS NULL OR SD.OrderCreatedAt < DATEADD(DAY, 1, @DateTo))
      AND (@CompletedOnly = 0 OR SD.OrderStatus = N'Completed')
    GROUP BY SD.BrandName
    ORDER BY TotalRevenue DESC, TotalSoldQty DESC, SD.BrandName;
END
GO

/* =========================================================
   J. PROCEDURE: Ton kho thap
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_LowStock
    @Threshold INT = 10,
    @IncludeInactive BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Threshold IS NULL OR @Threshold < 0
        SET @Threshold = 10;

    SELECT
        P.Id AS ProductId,
        P.SKU,
        P.Name AS ProductName,
        C.Name AS CategoryName,
        B.Name AS BrandName,
        P.Price,
        P.StockQuantity,
        P.SoldQuantity,
        CASE
            WHEN P.StockQuantity = 0 THEN N'OutOfStock'
            WHEN P.StockQuantity <= @Threshold THEN N'LowStock'
            ELSE N'Normal'
        END AS StockLevel
    FROM dbo.Products P
    INNER JOIN dbo.Categories C
        ON C.Id = P.CategoryId
    INNER JOIN dbo.Brands B
        ON B.Id = P.BrandId
    WHERE P.StockQuantity <= @Threshold
      AND (@IncludeInactive = 1 OR P.IsActive = 1)
    ORDER BY
        P.StockQuantity ASC,
        P.SoldQuantity DESC,
        P.Name;
END
GO

/* =========================================================
   K. PROCEDURE: Don hang theo trang thai
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_OrdersByStatus
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        O.OrderStatus,
        COUNT(*) AS TotalOrders,
        CAST(ISNULL(SUM(O.TotalAmount), 0) AS DECIMAL(18,2)) AS TotalAmount,
        CAST(ISNULL(SUM(CASE WHEN O.PaymentStatus = N'Paid' THEN O.TotalAmount ELSE 0 END), 0) AS DECIMAL(18,2)) AS PaidAmount
    FROM dbo.Orders O
    WHERE (@DateFrom IS NULL OR O.CreatedAt >= @DateFrom)
      AND (@DateTo   IS NULL OR O.CreatedAt < DATEADD(DAY, 1, @DateTo))
    GROUP BY O.OrderStatus
    ORDER BY
        CASE O.OrderStatus
            WHEN N'Pending' THEN 1
            WHEN N'Confirmed' THEN 2
            WHEN N'Processing' THEN 3
            WHEN N'Shipping' THEN 4
            WHEN N'Completed' THEN 5
            WHEN N'Cancelled' THEN 6
            WHEN N'Returned' THEN 7
            ELSE 999
        END;
END
GO

/* =========================================================
   L. PROCEDURE: Don hang theo trang thai thanh toan
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_PaymentStatus
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        O.PaymentStatus,
        COUNT(*) AS TotalOrders,
        CAST(ISNULL(SUM(O.TotalAmount), 0) AS DECIMAL(18,2)) AS TotalAmount
    FROM dbo.Orders O
    WHERE (@DateFrom IS NULL OR O.CreatedAt >= @DateFrom)
      AND (@DateTo   IS NULL OR O.CreatedAt < DATEADD(DAY, 1, @DateTo))
    GROUP BY O.PaymentStatus
    ORDER BY
        CASE O.PaymentStatus
            WHEN N'Unpaid' THEN 1
            WHEN N'Pending' THEN 2
            WHEN N'Paid' THEN 3
            WHEN N'Failed' THEN 4
            WHEN N'Refunded' THEN 5
            WHEN N'PartiallyRefunded' THEN 6
            ELSE 999
        END;
END
GO

/* =========================================================
   M. PROCEDURE: Thanh toan theo phuong thuc
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_PaymentMethodSummary
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.PaymentMethod,
        P.PaymentStatus,
        COUNT(*) AS TotalPayments,
        CAST(ISNULL(SUM(P.Amount), 0) AS DECIMAL(18,2)) AS TotalAmount
    FROM dbo.Payments P
    WHERE (@DateFrom IS NULL OR P.CreatedAt >= @DateFrom)
      AND (@DateTo   IS NULL OR P.CreatedAt < DATEADD(DAY, 1, @DateTo))
    GROUP BY P.PaymentMethod, P.PaymentStatus
    ORDER BY P.PaymentMethod, P.PaymentStatus;
END
GO

/* =========================================================
   N. PROCEDURE: Bao cao danh gia san pham
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_ProductRatings
    @TopN INT = 20,
    @ApprovedOnly BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @TopN IS NULL OR @TopN <= 0
        SET @TopN = 20;

    SELECT TOP (@TopN)
        P.Id AS ProductId,
        P.SKU,
        P.Name AS ProductName,
        C.Name AS CategoryName,
        B.Name AS BrandName,
        COUNT(R.Id) AS TotalReviews,
        CAST(AVG(CAST(R.Rating AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AvgRating,
        SUM(CASE WHEN R.Rating = 5 THEN 1 ELSE 0 END) AS FiveStarReviews,
        SUM(CASE WHEN R.Rating <= 2 THEN 1 ELSE 0 END) AS LowRatingReviews
    FROM dbo.Products P
    INNER JOIN dbo.Categories C
        ON C.Id = P.CategoryId
    INNER JOIN dbo.Brands B
        ON B.Id = P.BrandId
    LEFT JOIN dbo.Reviews R
        ON R.ProductId = P.Id
       AND (@ApprovedOnly = 0 OR R.IsApproved = 1)
    GROUP BY P.Id, P.SKU, P.Name, C.Name, B.Name
    HAVING COUNT(R.Id) > 0
    ORDER BY AvgRating DESC, TotalReviews DESC, P.Name;
END
GO

/* =========================================================
   O. PROCEDURE: Bao cao ticket ho tro
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_SupportTicketsSummary
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        T.Status,
        T.Priority,
        COUNT(*) AS TotalTickets,
        SUM(CASE WHEN T.AssignedToUserId IS NOT NULL THEN 1 ELSE 0 END) AS AssignedTickets,
        SUM(CASE WHEN T.ClosedAt IS NOT NULL THEN 1 ELSE 0 END) AS ClosedTickets
    FROM dbo.SupportTickets T
    WHERE (@DateFrom IS NULL OR T.CreatedAt >= @DateFrom)
      AND (@DateTo   IS NULL OR T.CreatedAt < DATEADD(DAY, 1, @DateTo))
    GROUP BY T.Status, T.Priority
    ORDER BY
        CASE T.Status
            WHEN N'Open' THEN 1
            WHEN N'InProgress' THEN 2
            WHEN N'Resolved' THEN 3
            WHEN N'Closed' THEN 4
            ELSE 999
        END,
        CASE T.Priority
            WHEN N'Low' THEN 1
            WHEN N'Medium' THEN 2
            WHEN N'High' THEN 3
            WHEN N'Urgent' THEN 4
            ELSE 999
        END;
END
GO

/* =========================================================
   P. PROCEDURE: Bao cao nha cung cap / nhap hang
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_SupplierImportSummary
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        S.Id AS SupplierId,
        S.Name AS SupplierName,
        COUNT(DISTINCT PR.Id) AS TotalReceipts,
        ISNULL(SUM(PRI.Quantity), 0) AS TotalImportedQty,
        CAST(ISNULL(SUM(PRI.LineTotal), 0) AS DECIMAL(18,2)) AS TotalImportAmount,
        MAX(PR.ReceiptDate) AS LastReceiptDate
    FROM dbo.Suppliers S
    LEFT JOIN dbo.PurchaseReceipts PR
        ON PR.SupplierId = S.Id
       AND (@DateFrom IS NULL OR PR.ReceiptDate >= @DateFrom)
       AND (@DateTo   IS NULL OR PR.ReceiptDate < DATEADD(DAY, 1, @DateTo))
    LEFT JOIN dbo.PurchaseReceiptItems PRI
        ON PRI.PurchaseReceiptId = PR.Id
    GROUP BY S.Id, S.Name
    ORDER BY TotalImportAmount DESC, TotalImportedQty DESC, S.Name;
END
GO

/* =========================================================
   Q. PROCEDURE: Bao cao nhap hang theo san pham
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_ProductImportSummary
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.Id AS ProductId,
        P.SKU,
        P.Name AS ProductName,
        C.Name AS CategoryName,
        B.Name AS BrandName,
        ISNULL(SUM(PRI.Quantity), 0) AS TotalImportedQty,
        CAST(ISNULL(SUM(PRI.LineTotal), 0) AS DECIMAL(18,2)) AS TotalImportAmount,
        CAST(
            CASE WHEN SUM(PRI.Quantity) IS NULL OR SUM(PRI.Quantity) = 0 THEN 0
                 ELSE SUM(PRI.LineTotal) / SUM(PRI.Quantity)
            END AS DECIMAL(18,2)
        ) AS AvgImportPrice
    FROM dbo.Products P
    INNER JOIN dbo.Categories C
        ON C.Id = P.CategoryId
    INNER JOIN dbo.Brands B
        ON B.Id = P.BrandId
    LEFT JOIN dbo.PurchaseReceiptItems PRI
        ON PRI.ProductId = P.Id
    LEFT JOIN dbo.PurchaseReceipts PR
        ON PR.Id = PRI.PurchaseReceiptId
       AND (@DateFrom IS NULL OR PR.ReceiptDate >= @DateFrom)
       AND (@DateTo   IS NULL OR PR.ReceiptDate < DATEADD(DAY, 1, @DateTo))
    WHERE PR.Id IS NOT NULL OR PRI.Id IS NULL
    GROUP BY P.Id, P.SKU, P.Name, C.Name, B.Name
    ORDER BY TotalImportAmount DESC, TotalImportedQty DESC, P.Name;
END
GO

/* =========================================================
   R. PROCEDURE: Dashboard tong hop 1 man hinh
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Report_DashboardSummary
    @DateFrom DATETIME2(7) = NULL,
    @DateTo   DATETIME2(7) = NULL,
    @LowStockThreshold INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    /* 1. KPI tong quan */
    SELECT
        (SELECT COUNT(*) FROM dbo.Products WHERE IsActive = 1) AS ActiveProducts,
        (SELECT COUNT(*) FROM dbo.AspNetUsers WHERE IsActive = 1) AS ActiveUsers,
        (SELECT COUNT(*) FROM dbo.Orders O
          WHERE (@DateFrom IS NULL OR O.CreatedAt >= @DateFrom)
            AND (@DateTo   IS NULL OR O.CreatedAt < DATEADD(DAY, 1, @DateTo))) AS TotalOrders,
        (SELECT COUNT(*) FROM dbo.Orders O
          WHERE O.OrderStatus = N'Completed'
            AND (@DateFrom IS NULL OR O.CreatedAt >= @DateFrom)
            AND (@DateTo   IS NULL OR O.CreatedAt < DATEADD(DAY, 1, @DateTo))) AS CompletedOrders,
        (SELECT CAST(ISNULL(SUM(O.TotalAmount),0) AS DECIMAL(18,2))
         FROM dbo.Orders O
         WHERE O.OrderStatus = N'Completed'
           AND (@DateFrom IS NULL OR O.CreatedAt >= @DateFrom)
           AND (@DateTo   IS NULL OR O.CreatedAt < DATEADD(DAY, 1, @DateTo))) AS CompletedRevenue,
        (SELECT COUNT(*) FROM dbo.Products WHERE StockQuantity <= @LowStockThreshold AND IsActive = 1) AS LowStockProducts,
        (SELECT COUNT(*) FROM dbo.SupportTickets T
          WHERE T.Status IN (N'Open', N'InProgress')
            AND (@DateFrom IS NULL OR T.CreatedAt >= @DateFrom)
            AND (@DateTo   IS NULL OR T.CreatedAt < DATEADD(DAY, 1, @DateTo))) AS OpenSupportTickets;

    /* 2. Don hang theo trang thai */
    SELECT
        O.OrderStatus,
        COUNT(*) AS TotalOrders,
        CAST(ISNULL(SUM(O.TotalAmount),0) AS DECIMAL(18,2)) AS TotalAmount
    FROM dbo.Orders O
    WHERE (@DateFrom IS NULL OR O.CreatedAt >= @DateFrom)
      AND (@DateTo   IS NULL OR O.CreatedAt < DATEADD(DAY, 1, @DateTo))
    GROUP BY O.OrderStatus
    ORDER BY
        CASE O.OrderStatus
            WHEN N'Pending' THEN 1
            WHEN N'Confirmed' THEN 2
            WHEN N'Processing' THEN 3
            WHEN N'Shipping' THEN 4
            WHEN N'Completed' THEN 5
            WHEN N'Cancelled' THEN 6
            WHEN N'Returned' THEN 7
            ELSE 999
        END;

    /* 3. Top 5 san pham */
    SELECT TOP (5)
        SD.ProductId,
        SD.SKU,
        SD.ProductName,
        SUM(SD.Quantity) AS TotalSoldQty,
        CAST(SUM(SD.LineTotal) AS DECIMAL(18,2)) AS TotalRevenue
    FROM dbo.vw_Report_SalesDetail SD
    WHERE (@DateFrom IS NULL OR SD.OrderCreatedAt >= @DateFrom)
      AND (@DateTo   IS NULL OR SD.OrderCreatedAt < DATEADD(DAY, 1, @DateTo))
      AND SD.OrderStatus = N'Completed'
    GROUP BY SD.ProductId, SD.SKU, SD.ProductName
    ORDER BY SUM(SD.Quantity) DESC, SUM(SD.LineTotal) DESC, SD.ProductName;

    /* 4. Top 5 ton kho thap */
    SELECT TOP (5)
        P.Id AS ProductId,
        P.SKU,
        P.Name AS ProductName,
        P.StockQuantity,
        C.Name AS CategoryName,
        B.Name AS BrandName
    FROM dbo.Products P
    INNER JOIN dbo.Categories C ON C.Id = P.CategoryId
    INNER JOIN dbo.Brands B ON B.Id = P.BrandId
    WHERE P.IsActive = 1
      AND P.StockQuantity <= @LowStockThreshold
    ORDER BY P.StockQuantity ASC, P.Name;
END
GO

/* =========================================================
   S. Lenh goi mau de demo nhanh
   ========================================================= */
-- EXEC dbo.sp_Report_RevenueSummary;
-- EXEC dbo.sp_Report_RevenueByDay;
-- EXEC dbo.sp_Report_RevenueByMonth;
-- EXEC dbo.sp_Report_TopProducts @TopN = 10;
-- EXEC dbo.sp_Report_LowStock @Threshold = 10;
-- EXEC dbo.sp_Report_OrdersByStatus;
-- EXEC dbo.sp_Report_PaymentStatus;
-- EXEC dbo.sp_Report_PaymentMethodSummary;
-- EXEC dbo.sp_Report_ProductRatings @TopN = 10;
-- EXEC dbo.sp_Report_SupportTicketsSummary;
-- EXEC dbo.sp_Report_SupplierImportSummary;
-- EXEC dbo.sp_Report_ProductImportSummary;
-- EXEC dbo.sp_Report_DashboardSummary @LowStockThreshold = 10;


/* ============================================================================
   END FILE: TechZone_Report_Sample.sql
   ============================================================================ */


/* ============================================================================
   BEGIN FILE: TechZone_AdminDashboard_Views.sql
   ============================================================================ */


/*
    TechZone_AdminDashboard_Views.sql

    Muc tieu:
    - Tao cac VIEW chuyen dung cho dashboard Admin trong ASP.NET Core MVC
    - De bind truc tiep vao card KPI, chart, bang gan day, top san pham, ton kho thap...

    Thu tu chay khuyen nghi:
        1) TechZone_FullSchema.sql
        2) TechZone_SeedImport_FromExcel.sql
        3) TechZone_Seed_Warehouse_Demo.sql
        4) TechZone_Report_Sample.sql   -- khong bat buoc, file nay KHONG phu thuoc
        5) TechZone_AdminDashboard_Views.sql

    Ghi chu:
    - Tat ca VIEW duoi day doc truc tiep tu bang goc.
    - View khong dung tham so; phia ASP.NET Core MVC co the SELECT/WHERE/TOP de hien thi dashboard.
    - Moi datetime su dung UTC theo schema hien tai.
*/

USE [TechZoneStoreDb];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================
   1) KPI tong quan 1 dong duy nhat
   Dung cho: cards thong ke tren cung dashboard
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_KpiSummary
AS
SELECT
    SYSUTCDATETIME() AS SnapshotUtc,

    /* Users */
    (SELECT COUNT(*) FROM dbo.AspNetUsers) AS TotalUsers,
    (SELECT COUNT(*) FROM dbo.AspNetUsers WHERE IsActive = 1) AS ActiveUsers,
    (SELECT COUNT(DISTINCT U.Id)
     FROM dbo.AspNetUsers U
     INNER JOIN dbo.AspNetUserRoles UR ON UR.UserId = U.Id
     INNER JOIN dbo.AspNetRoles R ON R.Id = UR.RoleId
     WHERE R.Name = N'Customer') AS TotalCustomers,
    (SELECT COUNT(DISTINCT U.Id)
     FROM dbo.AspNetUsers U
     INNER JOIN dbo.AspNetUserRoles UR ON UR.UserId = U.Id
     INNER JOIN dbo.AspNetRoles R ON R.Id = UR.RoleId
     WHERE R.Name IN (N'Admin', N'SalesStaff', N'WarehouseStaff', N'SupportStaff')) AS TotalStaffUsers,

    /* Catalog */
    (SELECT COUNT(*) FROM dbo.Categories) AS TotalCategories,
    (SELECT COUNT(*) FROM dbo.Categories WHERE IsActive = 1) AS ActiveCategories,
    (SELECT COUNT(*) FROM dbo.Brands) AS TotalBrands,
    (SELECT COUNT(*) FROM dbo.Brands WHERE IsActive = 1) AS ActiveBrands,
    (SELECT COUNT(*) FROM dbo.Products) AS TotalProducts,
    (SELECT COUNT(*) FROM dbo.Products WHERE IsActive = 1) AS ActiveProducts,
    (SELECT COUNT(*) FROM dbo.Products WHERE IsFeatured = 1 AND IsActive = 1) AS FeaturedProducts,
    (SELECT COUNT(*) FROM dbo.Products WHERE StockQuantity = 0) AS OutOfStockProducts,
    (SELECT COUNT(*) FROM dbo.Products WHERE StockQuantity > 0 AND StockQuantity <= 5) AS LowStockProducts,

    /* Orders */
    (SELECT COUNT(*) FROM dbo.Orders) AS TotalOrders,
    (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = N'Pending') AS PendingOrders,
    (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = N'Confirmed') AS ConfirmedOrders,
    (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = N'Processing') AS ProcessingOrders,
    (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = N'Shipping') AS ShippingOrders,
    (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = N'Completed') AS CompletedOrders,
    (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = N'Cancelled') AS CancelledOrders,
    (SELECT COUNT(*) FROM dbo.Orders WHERE OrderStatus = N'Returned') AS ReturnedOrders,

    /* Revenue */
    (SELECT ISNULL(SUM(TotalAmount), 0) FROM dbo.Orders) AS GrossOrderValue,
    (SELECT ISNULL(SUM(TotalAmount), 0)
     FROM dbo.Orders
     WHERE OrderStatus IN (N'Confirmed', N'Processing', N'Shipping', N'Completed')) AS RevenuePipelineValue,
    (SELECT ISNULL(SUM(TotalAmount), 0)
     FROM dbo.Orders
     WHERE OrderStatus = N'Completed') AS CompletedRevenue,
    (SELECT ISNULL(SUM(TotalAmount), 0)
     FROM dbo.Orders
     WHERE PaymentStatus = N'Paid') AS PaidRevenue,
    (SELECT CAST(ISNULL(AVG(CAST(TotalAmount AS DECIMAL(18,2))), 0) AS DECIMAL(18,2))
     FROM dbo.Orders) AS AvgOrderValue,
    (SELECT CAST(ISNULL(AVG(CAST(TotalAmount AS DECIMAL(18,2))), 0) AS DECIMAL(18,2))
     FROM dbo.Orders
     WHERE OrderStatus = N'Completed') AS AvgCompletedOrderValue,

    /* Payments */
    (SELECT COUNT(*) FROM dbo.Payments) AS TotalPayments,
    (SELECT COUNT(*) FROM dbo.Payments WHERE PaymentStatus = N'Paid') AS PaidPayments,
    (SELECT COUNT(*) FROM dbo.Payments WHERE PaymentStatus = N'Pending') AS PendingPayments,
    (SELECT COUNT(*) FROM dbo.Payments WHERE PaymentStatus = N'Failed') AS FailedPayments,

    /* Support */
    (SELECT COUNT(*) FROM dbo.SupportTickets) AS TotalSupportTickets,
    (SELECT COUNT(*) FROM dbo.SupportTickets WHERE Status = N'Open') AS OpenTickets,
    (SELECT COUNT(*) FROM dbo.SupportTickets WHERE Status = N'InProgress') AS InProgressTickets,
    (SELECT COUNT(*) FROM dbo.SupportTickets WHERE Status = N'Resolved') AS ResolvedTickets,
    (SELECT COUNT(*) FROM dbo.SupportTickets WHERE Status = N'Closed') AS ClosedTickets,

    /* Warehouse / purchasing */
    (SELECT COUNT(*) FROM dbo.Suppliers) AS TotalSuppliers,
    (SELECT COUNT(*) FROM dbo.Suppliers WHERE IsActive = 1) AS ActiveSuppliers,
    (SELECT COUNT(*) FROM dbo.PurchaseReceipts) AS TotalPurchaseReceipts,
    (SELECT ISNULL(SUM(TotalAmount), 0) FROM dbo.PurchaseReceipts WHERE [Status] = N'Completed') AS TotalImportValue,
    (SELECT COUNT(*) FROM dbo.StockTransactions) AS TotalStockTransactions;
GO

/* =========================================================
   2) So don hang theo trang thai
   Dung cho: pie / donut / horizontal bar
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_OrderStatusSummary
AS
SELECT
    O.OrderStatus,
    CASE O.OrderStatus
        WHEN N'Pending' THEN 1
        WHEN N'Confirmed' THEN 2
        WHEN N'Processing' THEN 3
        WHEN N'Shipping' THEN 4
        WHEN N'Completed' THEN 5
        WHEN N'Cancelled' THEN 6
        WHEN N'Returned' THEN 7
        ELSE 99
    END AS SortOrder,
    COUNT(*) AS OrderCount,
    ISNULL(SUM(O.TotalAmount), 0) AS TotalAmount,
    ISNULL(SUM(CASE WHEN O.PaymentStatus = N'Paid' THEN O.TotalAmount ELSE 0 END), 0) AS PaidAmount,
    ISNULL(SUM(CASE WHEN O.OrderStatus = N'Completed' THEN O.TotalAmount ELSE 0 END), 0) AS CompletedRevenue,
    MIN(O.CreatedAt) AS FirstOrderAt,
    MAX(O.CreatedAt) AS LastOrderAt
FROM dbo.Orders O
GROUP BY O.OrderStatus;
GO

/* =========================================================
   3) Tong hop thanh toan theo trang thai + phuong thuc
   Dung cho: cards / chart payment
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_PaymentSummary
AS
SELECT
    P.PaymentMethod,
    P.PaymentStatus,
    COUNT(*) AS PaymentCount,
    ISNULL(SUM(P.Amount), 0) AS TotalAmount,
    ISNULL(SUM(CASE WHEN P.PaymentStatus = N'Paid' THEN P.Amount ELSE 0 END), 0) AS PaidAmount,
    MIN(COALESCE(P.PaidAt, P.CreatedAt)) AS FirstPaymentAt,
    MAX(COALESCE(P.PaidAt, P.CreatedAt)) AS LastPaymentAt
FROM dbo.Payments P
GROUP BY
    P.PaymentMethod,
    P.PaymentStatus;
GO

/* =========================================================
   4) Doanh thu 30 ngay gan nhat
   Dung cho: line chart
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_RevenueLast30Days
AS
WITH N AS
(
    SELECT TOP (30)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects
),
D AS
(
    SELECT
        CAST(DATEADD(DAY, -(29 - n), CAST(SYSUTCDATETIME() AS DATE)) AS DATE) AS ReportDate
    FROM N
)
SELECT
    D.ReportDate,
    COUNT(O.Id) AS TotalOrders,
    ISNULL(SUM(CASE WHEN O.OrderStatus IN (N'Confirmed', N'Processing', N'Shipping', N'Completed') THEN O.TotalAmount ELSE 0 END), 0) AS RevenuePipelineValue,
    ISNULL(SUM(CASE WHEN O.OrderStatus = N'Completed' THEN O.TotalAmount ELSE 0 END), 0) AS CompletedRevenue,
    ISNULL(SUM(CASE WHEN O.PaymentStatus = N'Paid' THEN O.TotalAmount ELSE 0 END), 0) AS PaidRevenue
FROM D
LEFT JOIN dbo.Orders O
    ON CAST(O.CreatedAt AS DATE) = D.ReportDate
GROUP BY D.ReportDate;
GO

/* =========================================================
   5) Doanh thu 12 thang gan nhat
   Dung cho: column chart theo thang
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_RevenueLast12Months
AS
WITH N AS
(
    SELECT TOP (12)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects
),
M AS
(
    SELECT
        DATEFROMPARTS(YEAR(DATEADD(MONTH, -(11 - n), SYSUTCDATETIME())),
                      MONTH(DATEADD(MONTH, -(11 - n), SYSUTCDATETIME())), 1) AS MonthStart
    FROM N
)
SELECT
    M.MonthStart,
    CONVERT(CHAR(7), M.MonthStart, 120) AS MonthLabel,
    YEAR(M.MonthStart) AS [YearNumber],
    MONTH(M.MonthStart) AS [MonthNumber],
    COUNT(O.Id) AS TotalOrders,
    ISNULL(SUM(CASE WHEN O.OrderStatus IN (N'Confirmed', N'Processing', N'Shipping', N'Completed') THEN O.TotalAmount ELSE 0 END), 0) AS RevenuePipelineValue,
    ISNULL(SUM(CASE WHEN O.OrderStatus = N'Completed' THEN O.TotalAmount ELSE 0 END), 0) AS CompletedRevenue,
    ISNULL(SUM(CASE WHEN O.PaymentStatus = N'Paid' THEN O.TotalAmount ELSE 0 END), 0) AS PaidRevenue
FROM M
LEFT JOIN dbo.Orders O
    ON O.CreatedAt >= M.MonthStart
   AND O.CreatedAt < DATEADD(MONTH, 1, M.MonthStart)
GROUP BY
    M.MonthStart;
GO

/* =========================================================
   6) Top san pham ban chay
   Dung cho: table / leaderboard / chart
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_TopProducts
AS
WITH S AS
(
    SELECT
        P.Id AS ProductId,
        P.SKU,
        P.[Name] AS ProductName,
        C.[Name] AS CategoryName,
        B.[Name] AS BrandName,
        P.StockQuantity AS CurrentStock,
        P.SoldQuantity AS SystemSoldQuantity,
        COUNT(DISTINCT O.Id) AS OrderCount,
        ISNULL(SUM(CASE WHEN O.OrderStatus IN (N'Confirmed', N'Processing', N'Shipping', N'Completed') THEN OI.Quantity ELSE 0 END), 0) AS UnitsSold,
        ISNULL(SUM(CASE WHEN O.OrderStatus IN (N'Confirmed', N'Processing', N'Shipping', N'Completed') THEN OI.LineTotal ELSE 0 END), 0) AS RevenueAmount,
        ISNULL(SUM(CASE WHEN O.OrderStatus = N'Completed' THEN OI.LineTotal ELSE 0 END), 0) AS CompletedRevenue,
        CAST(ISNULL(AVG(CAST(CASE WHEN OI.Quantity > 0 THEN OI.UnitPrice END AS DECIMAL(18,2))), 0) AS DECIMAL(18,2)) AS AvgSellingPrice,
        MAX(O.CreatedAt) AS LastOrderAt
    FROM dbo.Products P
    INNER JOIN dbo.Categories C
        ON C.Id = P.CategoryId
    INNER JOIN dbo.Brands B
        ON B.Id = P.BrandId
    LEFT JOIN dbo.OrderItems OI
        ON OI.ProductId = P.Id
    LEFT JOIN dbo.Orders O
        ON O.Id = OI.OrderId
    GROUP BY
        P.Id, P.SKU, P.[Name], C.[Name], B.[Name], P.StockQuantity, P.SoldQuantity
)
SELECT
    S.*,
    DENSE_RANK() OVER (ORDER BY S.UnitsSold DESC, S.RevenueAmount DESC, S.ProductId ASC) AS SalesRank
FROM S;
GO

/* =========================================================
   7) Hieu qua theo danh muc
   Dung cho: top categories chart
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_TopCategories
AS
WITH X AS
(
    SELECT
        C.Id AS CategoryId,
        C.[Name] AS CategoryName,
        COUNT(DISTINCT P.Id) AS ProductCount,
        COUNT(DISTINCT CASE WHEN P.IsActive = 1 THEN P.Id END) AS ActiveProductCount,
        ISNULL(SUM(P.StockQuantity), 0) AS TotalStock,
        ISNULL(SUM(CASE WHEN O.OrderStatus IN (N'Confirmed', N'Processing', N'Shipping', N'Completed') THEN OI.Quantity ELSE 0 END), 0) AS UnitsSold,
        ISNULL(SUM(CASE WHEN O.OrderStatus IN (N'Confirmed', N'Processing', N'Shipping', N'Completed') THEN OI.LineTotal ELSE 0 END), 0) AS RevenueAmount
    FROM dbo.Categories C
    LEFT JOIN dbo.Products P
        ON P.CategoryId = C.Id
    LEFT JOIN dbo.OrderItems OI
        ON OI.ProductId = P.Id
    LEFT JOIN dbo.Orders O
        ON O.Id = OI.OrderId
    GROUP BY
        C.Id, C.[Name]
)
SELECT
    X.*,
    DENSE_RANK() OVER (ORDER BY X.RevenueAmount DESC, X.UnitsSold DESC, X.CategoryId ASC) AS RevenueRank
FROM X;
GO

/* =========================================================
   8) Hieu qua theo thuong hieu
   Dung cho: top brands chart
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_TopBrands
AS
WITH X AS
(
    SELECT
        B.Id AS BrandId,
        B.[Name] AS BrandName,
        COUNT(DISTINCT P.Id) AS ProductCount,
        COUNT(DISTINCT CASE WHEN P.IsActive = 1 THEN P.Id END) AS ActiveProductCount,
        ISNULL(SUM(P.StockQuantity), 0) AS TotalStock,
        ISNULL(SUM(CASE WHEN O.OrderStatus IN (N'Confirmed', N'Processing', N'Shipping', N'Completed') THEN OI.Quantity ELSE 0 END), 0) AS UnitsSold,
        ISNULL(SUM(CASE WHEN O.OrderStatus IN (N'Confirmed', N'Processing', N'Shipping', N'Completed') THEN OI.LineTotal ELSE 0 END), 0) AS RevenueAmount
    FROM dbo.Brands B
    LEFT JOIN dbo.Products P
        ON P.BrandId = B.Id
    LEFT JOIN dbo.OrderItems OI
        ON OI.ProductId = P.Id
    LEFT JOIN dbo.Orders O
        ON O.Id = OI.OrderId
    GROUP BY
        B.Id, B.[Name]
)
SELECT
    X.*,
    DENSE_RANK() OVER (ORDER BY X.RevenueAmount DESC, X.UnitsSold DESC, X.BrandId ASC) AS RevenueRank
FROM X;
GO

/* =========================================================
   9) Canh bao ton kho thap
   Dung cho: table low stock
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_LowStockProducts
AS
SELECT
    P.Id AS ProductId,
    P.SKU,
    P.[Name] AS ProductName,
    C.[Name] AS CategoryName,
    B.[Name] AS BrandName,
    P.Price,
    P.DiscountPrice,
    P.StockQuantity,
    P.SoldQuantity,
    CASE
        WHEN P.StockQuantity = 0 THEN N'OutOfStock'
        WHEN P.StockQuantity BETWEEN 1 AND 5 THEN N'LowStock'
        WHEN P.StockQuantity BETWEEN 6 AND 10 THEN N'WatchList'
        ELSE N'Normal'
    END AS StockLevel,
    ISNULL(ST.LastTransactionAt, P.UpdatedAt) AS LastActivityAt
FROM dbo.Products P
INNER JOIN dbo.Categories C
    ON C.Id = P.CategoryId
INNER JOIN dbo.Brands B
    ON B.Id = P.BrandId
OUTER APPLY
(
    SELECT MAX(S.CreatedAt) AS LastTransactionAt
    FROM dbo.StockTransactions S
    WHERE S.ProductId = P.Id
) ST
WHERE P.StockQuantity <= 10;
GO

/* =========================================================
   10) Tong hop ton kho theo danh muc
   Dung cho: inventory cards / category stock chart
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_InventoryByCategory
AS
SELECT
    C.Id AS CategoryId,
    C.[Name] AS CategoryName,
    COUNT(P.Id) AS ProductCount,
    ISNULL(SUM(P.StockQuantity), 0) AS TotalUnitsInStock,
    ISNULL(SUM(CAST(P.StockQuantity * ISNULL(P.DiscountPrice, P.Price) AS DECIMAL(18,2))), 0) AS EstimatedStockValue,
    COUNT(CASE WHEN P.StockQuantity = 0 THEN 1 END) AS OutOfStockProducts,
    COUNT(CASE WHEN P.StockQuantity > 0 AND P.StockQuantity <= 5 THEN 1 END) AS LowStockProducts
FROM dbo.Categories C
LEFT JOIN dbo.Products P
    ON P.CategoryId = C.Id
GROUP BY
    C.Id, C.[Name];
GO

/* =========================================================
   11) Don hang gan day
   Dung cho: bang Recent Orders tren dashboard
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_RecentOrders
AS
WITH X AS
(
    SELECT
        O.Id AS OrderId,
        O.OrderCode,
        O.UserId,
        COALESCE(NULLIF(U.FullName, N''), NULLIF(U.UserName, N''), U.Email, N'Unknown') AS CustomerDisplayName,
        U.Email AS CustomerEmail,
        O.ReceiverName,
        O.PhoneNumber,
        O.ShippingAddress,
        O.OrderStatus,
        O.PaymentStatus,
        O.PaymentMethod,
        O.Subtotal,
        O.ShippingFee,
        O.DiscountAmount,
        O.TotalAmount,
        O.CreatedAt,
        O.UpdatedAt,
        COUNT(OI.Id) AS ItemCount,
        SUM(ISNULL(OI.Quantity, 0)) AS TotalQuantity,
        ROW_NUMBER() OVER (ORDER BY O.CreatedAt DESC, O.Id DESC) AS RecencyRank
    FROM dbo.Orders O
    LEFT JOIN dbo.AspNetUsers U
        ON U.Id = O.UserId
    LEFT JOIN dbo.OrderItems OI
        ON OI.OrderId = O.Id
    GROUP BY
        O.Id, O.OrderCode, O.UserId, U.FullName, U.UserName, U.Email,
        O.ReceiverName, O.PhoneNumber, O.ShippingAddress, O.OrderStatus,
        O.PaymentStatus, O.PaymentMethod, O.Subtotal, O.ShippingFee,
        O.DiscountAmount, O.TotalAmount, O.CreatedAt, O.UpdatedAt
)
SELECT * FROM X;
GO

/* =========================================================
   12) Tong hop ticket ho tro
   Dung cho: support KPI / chart
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_SupportTicketSummary
AS
SELECT
    T.Status,
    T.Priority,
    COUNT(*) AS TicketCount,
    MIN(T.CreatedAt) AS FirstCreatedAt,
    MAX(T.CreatedAt) AS LastCreatedAt,
    CAST(
        ISNULL(AVG(
            CASE
                WHEN T.ClosedAt IS NOT NULL
                THEN DATEDIFF(MINUTE, T.CreatedAt, T.ClosedAt) * 1.0
            END
        ), 0) AS DECIMAL(18,2)
    ) AS AvgResolutionMinutes
FROM dbo.SupportTickets T
GROUP BY
    T.Status,
    T.Priority;
GO

/* =========================================================
   13) Ticket gan day
   Dung cho: recent tickets table
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_RecentTickets
AS
WITH X AS
(
    SELECT
        T.Id AS TicketId,
        T.TicketCode,
        T.UserId,
        COALESCE(NULLIF(U.FullName, N''), NULLIF(U.UserName, N''), U.Email, N'Unknown') AS CustomerDisplayName,
        T.OrderId,
        T.Title,
        T.Status,
        T.Priority,
        T.AssignedToUserId,
        COALESCE(NULLIF(AU.FullName, N''), NULLIF(AU.UserName, N''), AU.Email) AS AssignedToDisplayName,
        T.CreatedAt,
        T.UpdatedAt,
        T.ClosedAt,
        ROW_NUMBER() OVER (ORDER BY T.CreatedAt DESC, T.Id DESC) AS RecencyRank
    FROM dbo.SupportTickets T
    LEFT JOIN dbo.AspNetUsers U
        ON U.Id = T.UserId
    LEFT JOIN dbo.AspNetUsers AU
        ON AU.Id = T.AssignedToUserId
)
SELECT * FROM X;
GO

/* =========================================================
   14) Nhap hang theo nha cung cap
   Dung cho: supplier import chart / table
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_SupplierImportSummary
AS
SELECT
    S.Id AS SupplierId,
    S.[Name] AS SupplierName,
    COUNT(DISTINCT PR.Id) AS ReceiptCount,
    ISNULL(SUM(PRI.Quantity), 0) AS TotalImportedUnits,
    ISNULL(SUM(PRI.LineTotal), 0) AS TotalImportValue,
    MIN(PR.ReceiptDate) AS FirstReceiptDate,
    MAX(PR.ReceiptDate) AS LastReceiptDate
FROM dbo.Suppliers S
LEFT JOIN dbo.PurchaseReceipts PR
    ON PR.SupplierId = S.Id
LEFT JOIN dbo.PurchaseReceiptItems PRI
    ON PRI.PurchaseReceiptId = PR.Id
GROUP BY
    S.Id, S.[Name];
GO

/* =========================================================
   15) San pham nhap hang nhieu nhat
   Dung cho: warehouse leaderboard / bar chart
   ========================================================= */
CREATE OR ALTER VIEW dbo.vw_AdminDashboard_TopImportedProducts
AS
WITH X AS
(
    SELECT
        P.Id AS ProductId,
        P.SKU,
        P.[Name] AS ProductName,
        C.[Name] AS CategoryName,
        B.[Name] AS BrandName,
        COUNT(DISTINCT PR.Id) AS ReceiptCount,
        ISNULL(SUM(PRI.Quantity), 0) AS ImportedUnits,
        ISNULL(SUM(PRI.LineTotal), 0) AS ImportValue,
        MAX(PR.ReceiptDate) AS LastReceiptDate
    FROM dbo.Products P
    INNER JOIN dbo.Categories C
        ON C.Id = P.CategoryId
    INNER JOIN dbo.Brands B
        ON B.Id = P.BrandId
    LEFT JOIN dbo.PurchaseReceiptItems PRI
        ON PRI.ProductId = P.Id
    LEFT JOIN dbo.PurchaseReceipts PR
        ON PR.Id = PRI.PurchaseReceiptId
    GROUP BY
        P.Id, P.SKU, P.[Name], C.[Name], B.[Name]
)
SELECT
    X.*,
    DENSE_RANK() OVER (ORDER BY X.ImportedUnits DESC, X.ImportValue DESC, X.ProductId ASC) AS ImportRank
FROM X;
GO

/* =========================================================
   Truy van mau de test nhanh trong SSMS
   =========================================================
SELECT * FROM dbo.vw_AdminDashboard_KpiSummary;
SELECT * FROM dbo.vw_AdminDashboard_OrderStatusSummary ORDER BY SortOrder;
SELECT * FROM dbo.vw_AdminDashboard_PaymentSummary ORDER BY PaymentMethod, PaymentStatus;
SELECT * FROM dbo.vw_AdminDashboard_RevenueLast30Days ORDER BY ReportDate;
SELECT * FROM dbo.vw_AdminDashboard_RevenueLast12Months ORDER BY MonthStart;
SELECT TOP (10) * FROM dbo.vw_AdminDashboard_TopProducts ORDER BY SalesRank, ProductId;
SELECT TOP (10) * FROM dbo.vw_AdminDashboard_TopCategories ORDER BY RevenueRank, CategoryId;
SELECT TOP (10) * FROM dbo.vw_AdminDashboard_TopBrands ORDER BY RevenueRank, BrandId;
SELECT * FROM dbo.vw_AdminDashboard_LowStockProducts ORDER BY StockQuantity ASC, ProductId ASC;
SELECT TOP (10) * FROM dbo.vw_AdminDashboard_RecentOrders ORDER BY RecencyRank;
SELECT * FROM dbo.vw_AdminDashboard_SupportTicketSummary ORDER BY Status, Priority;
SELECT TOP (10) * FROM dbo.vw_AdminDashboard_RecentTickets ORDER BY RecencyRank;
SELECT TOP (10) * FROM dbo.vw_AdminDashboard_SupplierImportSummary ORDER BY TotalImportValue DESC, SupplierId;
SELECT TOP (10) * FROM dbo.vw_AdminDashboard_TopImportedProducts ORDER BY ImportRank, ProductId;
*/


/* ============================================================================
   END FILE: TechZone_AdminDashboard_Views.sql
   ============================================================================ */


USE [master];
GO
PRINT N'TechZone all-in-one da chay xong: schema + seed/import + warehouse demo + reports + admin dashboard views.';
GO

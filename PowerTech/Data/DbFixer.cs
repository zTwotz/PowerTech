using Microsoft.EntityFrameworkCore;
using PowerTech.Data;

namespace PowerTech.Data
{
    public static class DbFixer
    {
        public static async Task FixSchemaAsync(ApplicationDbContext context)
        {
            try
            {
                // Add missing columns to OrderItems if they don't exist
                await context.Database.ExecuteSqlRawAsync(@"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Orders]') AND name = 'InternalNote')
                    BEGIN
                        ALTER TABLE [Orders] ADD [InternalNote] nvarchar(1000) NULL;
                    END
                ");

                await context.Database.ExecuteSqlRawAsync(@"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[OrderItems]') AND name = 'ProductSkuSnapshot')
                    BEGIN
                        ALTER TABLE [OrderItems] ADD [ProductSkuSnapshot] nvarchar(50) NULL;
                    END
                ");
                
                await context.Database.ExecuteSqlRawAsync(@"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[OrderItems]') AND name = 'ProductImageSnapshot')
                    BEGIN
                        ALTER TABLE [OrderItems] ADD [ProductImageSnapshot] nvarchar(500) NULL;
                    END
                ");

                // Add missing columns to Payments
                await context.Database.ExecuteSqlRawAsync(@"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Payments]') AND name = 'GatewayProvider')
                    BEGIN
                        ALTER TABLE [Payments] ADD [GatewayProvider] nvarchar(100) NULL;
                    END
                ");
                
                await context.Database.ExecuteSqlRawAsync(@"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Payments]') AND name = 'RawResponse')
                    BEGIN
                        ALTER TABLE [Payments] ADD [RawResponse] nvarchar(max) NULL;
                    END
                ");

                await context.Database.ExecuteSqlRawAsync(@"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Payments]') AND name = 'UpdatedAt')
                    BEGIN
                        ALTER TABLE [Payments] ADD [UpdatedAt] datetime2 NULL;
                    END
                ");

                // Create missing tables (Reviews, SupportTickets, StockTransactions) 
                // these were likely missed in early empty migrations like SyncWarehouseSupport
                await context.Database.ExecuteSqlRawAsync(@"
                    IF OBJECT_ID(N'[Reviews]') IS NULL
                    BEGIN
                        CREATE TABLE [Reviews] (
                            [Id] int NOT NULL IDENTITY,
                            [ProductId] int NOT NULL,
                            [UserId] nvarchar(450) NOT NULL,
                            [Rating] tinyint NOT NULL,
                            [Comment] nvarchar(1000) NOT NULL,
                            [IsApproved] bit NOT NULL,
                            [CreatedAt] datetime2 NOT NULL,
                            [UpdatedAt] datetime2 NULL,
                            CONSTRAINT [PK_Reviews] PRIMARY KEY ([Id]),
                            CONSTRAINT [FK_Reviews_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE NO ACTION,
                            CONSTRAINT [FK_Reviews_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([Id]) ON DELETE CASCADE
                        );
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Reviews_ProductId' AND object_id = OBJECT_ID('Reviews'))
                            CREATE INDEX [IX_Reviews_ProductId] ON [Reviews] ([ProductId]);
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Reviews_UserId' AND object_id = OBJECT_ID('Reviews'))
                            CREATE INDEX [IX_Reviews_UserId] ON [Reviews] ([UserId]);
                    END
                ");

                await context.Database.ExecuteSqlRawAsync(@"
                    IF OBJECT_ID(N'[SupportTickets]') IS NULL
                    BEGIN
                        CREATE TABLE [SupportTickets] (
                            [Id] int NOT NULL IDENTITY,
                            [TicketCode] nvarchar(50) NOT NULL,
                            [Title] nvarchar(200) NOT NULL,
                            [Content] nvarchar(max) NOT NULL,
                            [Status] nvarchar(50) NOT NULL,
                            [Priority] nvarchar(50) NOT NULL,
                            [UserId] nvarchar(450) NOT NULL,
                            [AssignedToUserId] nvarchar(450) NULL,
                            [OrderId] int NULL,
                            [CreatedAt] datetime2 NOT NULL,
                            [UpdatedAt] datetime2 NULL,
                            [ClosedAt] datetime2 NULL,
                            CONSTRAINT [PK_SupportTickets] PRIMARY KEY ([Id]),
                            CONSTRAINT [FK_SupportTickets_AspNetUsers_AssignedToUserId] FOREIGN KEY ([AssignedToUserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE NO ACTION,
                            CONSTRAINT [FK_SupportTickets_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE NO ACTION,
                            CONSTRAINT [FK_SupportTickets_Orders_OrderId] FOREIGN KEY ([OrderId]) REFERENCES [Orders] ([Id]) ON DELETE SET NULL
                        );
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SupportTickets_AssignedToUserId' AND object_id = OBJECT_ID('SupportTickets'))
                            CREATE INDEX [IX_SupportTickets_AssignedToUserId] ON [SupportTickets] ([AssignedToUserId]);
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SupportTickets_OrderId' AND object_id = OBJECT_ID('SupportTickets'))
                            CREATE INDEX [IX_SupportTickets_OrderId] ON [SupportTickets] ([OrderId]);
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SupportTickets_TicketCode' AND object_id = OBJECT_ID('SupportTickets'))
                            CREATE UNIQUE INDEX [IX_SupportTickets_TicketCode] ON [SupportTickets] ([TicketCode]);
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SupportTickets_UserId' AND object_id = OBJECT_ID('SupportTickets'))
                            CREATE INDEX [IX_SupportTickets_UserId] ON [SupportTickets] ([UserId]);
                    END
                ");

                await context.Database.ExecuteSqlRawAsync(@"
                    IF OBJECT_ID(N'[StockTransactions]') IS NULL
                    BEGIN
                        CREATE TABLE [StockTransactions] (
                            [Id] int NOT NULL IDENTITY,
                            [ProductId] int NOT NULL,
                            [Quantity] int NOT NULL,
                            [BeforeQuantity] int NULL,
                            [AfterQuantity] int NULL,
                            [TransactionType] nvarchar(50) NOT NULL,
                            [ReferenceType] nvarchar(50) NULL,
                            [ReferenceId] int NULL,
                            [Note] nvarchar(500) NULL,
                            [PerformedByUserId] nvarchar(450) NOT NULL,
                            [CreatedAt] datetime2 NOT NULL,
                            CONSTRAINT [PK_StockTransactions] PRIMARY KEY ([Id]),
                            CONSTRAINT [FK_StockTransactions_AspNetUsers_PerformedByUserId] FOREIGN KEY ([PerformedByUserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE NO ACTION,
                            CONSTRAINT [FK_StockTransactions_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([Id]) ON DELETE CASCADE
                        );
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_StockTransactions_PerformedByUserId' AND object_id = OBJECT_ID('StockTransactions'))
                            CREATE INDEX [IX_StockTransactions_PerformedByUserId] ON [StockTransactions] ([PerformedByUserId]);
                        IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_StockTransactions_ProductId' AND object_id = OBJECT_ID('StockTransactions'))
                            CREATE INDEX [IX_StockTransactions_ProductId] ON [StockTransactions] ([ProductId]);
                    END
                ");

                // Mark pending migrations as applied in __EFMigrationsHistory
                var pendingMigrations = new[] 
                {
                    "20260405122421_InitialCreate",
                    "20260405122827_DbInit",
                    "20260406003501_AddCatalogEntities",
                    "20260406004908_AddOrderOrderItemPaymentCore",
                    "20260406013227_AddUserAddressAndCart",
                    "20260406094525_UpdateOrderItemSnapshots", // Added full ID
                    "20260406165852_SyncWarehouseSupport", // The empty one
                    "20260406200745_UpdateCartForAnonymousGuests",
                    "20260407165135_AddUpdatedAtToUsers"
                };

                foreach (var migrationId in pendingMigrations)
                {
                    await context.Database.ExecuteSqlAsync($@"
                        IF NOT EXISTS (SELECT * FROM [__EFMigrationsHistory] WHERE [MigrationId] = {migrationId})
                        BEGIN
                            INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
                            VALUES ({migrationId}, '8.0.0');
                        END
                    ");
                }

                // Create Coupons table
                await context.Database.ExecuteSqlRawAsync(@"
                    IF OBJECT_ID(N'[Coupons]') IS NULL
                    BEGIN
                        CREATE TABLE [Coupons] (
                            [Id] int NOT NULL IDENTITY,
                            [Code] nvarchar(50) NOT NULL,
                            [Type] int NOT NULL,
                            [Value] decimal(18,2) NOT NULL,
                            [MinOrderValue] decimal(18,2) NULL,
                            [MaxDiscountAmount] decimal(18,2) NULL,
                            [StartDate] datetime2 NULL,
                            [EndDate] datetime2 NULL,
                            [UsageLimit] int NULL,
                            [UsedCount] int NOT NULL DEFAULT 0,
                            [IsActive] bit NOT NULL DEFAULT 1,
                            [CreatedAt] datetime2 NOT NULL,
                            [UpdatedAt] datetime2 NULL,
                            CONSTRAINT [PK_Coupons] PRIMARY KEY ([Id])
                        );
                        CREATE UNIQUE INDEX [IX_Coupons_Code] ON [Coupons] ([Code]);
                        
                        -- Seed initial coupons
                        INSERT INTO [Coupons] (Code, Type, Value, MinOrderValue, UsageLimit, UsedCount, IsActive, CreatedAt)
                        VALUES 
                        ('GIAM10', 0, 10, 500000, 100, 0, 1, GETUTCDATE()),
                        ('KM50K', 1, 50000, 1000000, 50, 0, 1, GETUTCDATE());
                    END
                ");

                // Add CouponId to Orders
                await context.Database.ExecuteSqlRawAsync(@"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Orders]') AND name = 'CouponId')
                    BEGIN
                        ALTER TABLE [Orders] ADD [CouponId] int NULL;
                        ALTER TABLE [Orders] ADD CONSTRAINT [FK_Orders_Coupons_CouponId] FOREIGN KEY ([CouponId]) REFERENCES [Coupons] ([Id]);
                    END
                ");

                // Create TicketResponses table
                await context.Database.ExecuteSqlRawAsync(@"
                    IF OBJECT_ID(N'[TicketResponses]') IS NULL
                    BEGIN
                        CREATE TABLE [TicketResponses] (
                            [Id] int NOT NULL IDENTITY,
                            [TicketId] int NOT NULL,
                            [UserId] nvarchar(450) NOT NULL,
                            [Message] nvarchar(max) NOT NULL,
                            [IsInternal] bit NOT NULL DEFAULT 0,
                            [CreatedAt] datetime2 NOT NULL,
                            CONSTRAINT [PK_TicketResponses] PRIMARY KEY ([Id]),
                            CONSTRAINT [FK_TicketResponses_SupportTickets_TicketId] FOREIGN KEY ([TicketId]) REFERENCES [SupportTickets] ([Id]) ON DELETE CASCADE,
                            CONSTRAINT [FK_TicketResponses_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE NO ACTION
                        );
                        CREATE INDEX [IX_TicketResponses_TicketId] ON [TicketResponses] ([TicketId]);
                        CREATE INDEX [IX_TicketResponses_UserId] ON [TicketResponses] ([UserId]);
                    END
                ");

                // Update SupportTickets table
                await context.Database.ExecuteSqlRawAsync(@"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[SupportTickets]') AND name = 'Rating')
                    BEGIN
                        ALTER TABLE [SupportTickets] ADD [Rating] int NULL;
                        ALTER TABLE [SupportTickets] ADD [Feedback] nvarchar(500) NULL;
                        ALTER TABLE [SupportTickets] ADD [AttachmentUrl] nvarchar(max) NULL;
                    END

                    -- Drop old constraints if exists to allow Vietnamese issue types and custom statuses
                    IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_SupportTickets_Priority')
                    BEGIN
                        ALTER TABLE [SupportTickets] DROP CONSTRAINT [CK_SupportTickets_Priority];
                    END
                    IF EXISTS (SELECT * FROM sys.check_constraints WHERE name = 'CK_SupportTickets_Status')
                    BEGIN
                        ALTER TABLE [SupportTickets] DROP CONSTRAINT [CK_SupportTickets_Status];
                    END
                ");

                // Update TicketResponses table
                await context.Database.ExecuteSqlRawAsync(@"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[TicketResponses]') AND name = 'AttachmentUrl')
                    BEGIN
                        ALTER TABLE [TicketResponses] ADD [AttachmentUrl] nvarchar(max) NULL;
                    END
                ");

                // Create CannedResponses table
                await context.Database.ExecuteSqlRawAsync(@"
                    IF OBJECT_ID(N'[CannedResponses]') IS NULL
                    BEGIN
                        CREATE TABLE [CannedResponses] (
                            [Id] int NOT NULL IDENTITY,
                            [Title] nvarchar(100) NOT NULL,
                            [Content] nvarchar(max) NOT NULL,
                            [CreatedAt] datetime2 NOT NULL,
                            CONSTRAINT [PK_CannedResponses] PRIMARY KEY ([Id])
                        );
                        
                        INSERT INTO [CannedResponses] ([Title], [Content], [CreatedAt])
                        VALUES 
                        (N'Mẫu chào hỏi', N'Chào bạn, PowerTech có thể giúp gì cho bạn hôm nay?', GETUTCDATE()),
                        (N'Quy trình bảo hành', N'Để bảo hành, bạn vui lòng mang sản phẩm ra showroom gần nhất. Thời gian xử lý từ 3-5 ngày làm việc.', GETUTCDATE()),
                        (N'Đang xử lý', N'Cảm ơn bạn đã phản hồi. Bộ phận kỹ thuật đang tiến hành kiểm tra và sẽ báo kết quả sớm nhất.', GETUTCDATE());
                    END
                ");

                // Create FAQ tables
                await context.Database.ExecuteSqlRawAsync(@"
                    IF OBJECT_ID(N'[FaqCategories]') IS NULL
                    BEGIN
                        CREATE TABLE [FaqCategories] (
                            [Id] int NOT NULL IDENTITY,
                            [Name] nvarchar(100) NOT NULL,
                            [DisplayOrder] int NOT NULL,
                            CONSTRAINT [PK_FaqCategories] PRIMARY KEY ([Id])
                        );

                        CREATE TABLE [FaqArticles] (
                            [Id] int NOT NULL IDENTITY,
                            [CategoryId] int NOT NULL,
                            [Title] nvarchar(200) NOT NULL,
                            [Content] nvarchar(max) NOT NULL,
                            [ViewCount] int NOT NULL,
                            [CreatedAt] datetime2 NOT NULL,
                            CONSTRAINT [PK_FaqArticles] PRIMARY KEY ([Id]),
                            CONSTRAINT [FK_FaqArticles_FaqCategories_CategoryId] FOREIGN KEY ([CategoryId]) REFERENCES [FaqCategories] ([Id]) ON DELETE CASCADE
                        );
                        CREATE INDEX [IX_FaqArticles_CategoryId] ON [FaqArticles] ([CategoryId]);
                        
                        INSERT INTO [FaqCategories] ([Name], [DisplayOrder]) VALUES (N'Bảo hành & Đổi trả', 1), (N'Thanh toán & Giao hàng', 2), (N'Hỗ trợ Kỹ thuật', 3);
                    END
                ");

                // Create ReviewImages table
                await context.Database.ExecuteSqlRawAsync(@"
                    IF OBJECT_ID(N'[ReviewImages]') IS NULL
                    BEGIN
                        CREATE TABLE [ReviewImages] (
                            [Id] int NOT NULL IDENTITY,
                            [ReviewId] int NOT NULL,
                            [ImageUrl] nvarchar(max) NOT NULL,
                            [CreatedAt] datetime2 NOT NULL,
                            CONSTRAINT [PK_ReviewImages] PRIMARY KEY ([Id]),
                            CONSTRAINT [FK_ReviewImages_Reviews_ReviewId] FOREIGN KEY ([ReviewId]) REFERENCES [Reviews] ([Id]) ON DELETE CASCADE
                        );
                        CREATE INDEX [IX_ReviewImages_ReviewId] ON [ReviewImages] ([ReviewId]);
                    END

                ");

                // 2nd Separate Block: Fix Cart indices (Separate for robustness)
                await context.Database.ExecuteSqlRawAsync(@"
                    -- SQL Server doesn't allow indexing nvarchar(max). Ensure CookieId is indexable size.
                    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[Carts]') AND name = 'CookieId')
                    BEGIN
                        -- Drop if exists wrong unique indices on CookieId first to avoid ALTER TABLE error
                        IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Carts_CookieId' AND object_id = OBJECT_ID('Carts'))
                        BEGIN
                            DROP INDEX [IX_Carts_CookieId] ON [Carts];
                        END
                        
                        -- Now we can safely alter the column
                        ALTER TABLE [Carts] ALTER COLUMN [CookieId] nvarchar(450) NULL;
                    END

                    -- Drop if exists wrong unique indices on UserId
                    IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'UX_Carts_UserId' AND object_id = OBJECT_ID('Carts'))
                    BEGIN
                        DROP INDEX [UX_Carts_UserId] ON [Carts];
                    END
                    
                    IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Carts_UserId' AND object_id = OBJECT_ID('Carts'))
                    BEGIN
                        -- Check if it is already filtered. If not, drop it.
                        IF (SELECT has_filter FROM sys.indexes WHERE name = 'IX_Carts_UserId' AND object_id = OBJECT_ID('Carts')) = 0
                        BEGIN
                            DROP INDEX [IX_Carts_UserId] ON [Carts];
                        END
                    END

                    -- Re-Create filtered index for UserId
                    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Carts_UserId' AND object_id = OBJECT_ID('Carts'))
                    BEGIN
                        CREATE UNIQUE INDEX [IX_Carts_UserId] ON [Carts] ([UserId]) WHERE [UserId] IS NOT NULL;
                    END

                    -- Re-Create filtered index for CookieId
                    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Carts_CookieId' AND object_id = OBJECT_ID('Carts'))
                    BEGIN
                        CREATE UNIQUE INDEX [IX_Carts_CookieId] ON [Carts] ([CookieId]) WHERE [CookieId] IS NOT NULL;
                    END
                ");

                // Create TradeIn tables (Separate for reliability)
                await context.Database.ExecuteSqlRawAsync(@"
                    IF OBJECT_ID(N'[TradeInRequests]') IS NULL
                    BEGIN
                        CREATE TABLE [TradeInRequests] (
                            [Id] int NOT NULL IDENTITY,
                            [UserId] nvarchar(450) NULL,
                            [CategoryId] int NOT NULL,
                            [BrandId] int NULL,
                            [OtherBrandName] nvarchar(100) NULL,
                            [ModelName] nvarchar(255) NOT NULL,
                            [Condition] nvarchar(100) NOT NULL,
                            [Status] nvarchar(50) NOT NULL,
                            [QuotedPrice] decimal(18,2) NULL,
                            [ContactName] nvarchar(100) NOT NULL,
                            [ContactPhone] nvarchar(20) NOT NULL,
                            [ContactEmail] nvarchar(100) NULL,
                            [Note] nvarchar(max) NULL,
                            [CreatedAt] datetime2 NOT NULL,
                            CONSTRAINT [PK_TradeInRequests] PRIMARY KEY ([Id]),
                            CONSTRAINT [FK_TradeInRequests_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE SET NULL,
                            CONSTRAINT [FK_TradeInRequests_Categories_CategoryId] FOREIGN KEY ([CategoryId]) REFERENCES [Categories] ([Id]) ON DELETE NO ACTION,
                            CONSTRAINT [FK_TradeInRequests_Brands_BrandId] FOREIGN KEY ([BrandId]) REFERENCES [Brands] ([Id]) ON DELETE NO ACTION
                        );
                        CREATE INDEX [IX_TradeInRequests_UserId] ON [TradeInRequests] ([UserId]);
                        CREATE INDEX [IX_TradeInRequests_CategoryId] ON [TradeInRequests] ([CategoryId]);
                        CREATE INDEX [IX_TradeInRequests_BrandId] ON [TradeInRequests] ([BrandId]);
                    END

                    IF OBJECT_ID(N'[TradeInRequestImages]') IS NULL
                    BEGIN
                        CREATE TABLE [TradeInRequestImages] (
                            [Id] int NOT NULL IDENTITY,
                            [TradeInRequestId] int NOT NULL,
                            [ImageUrl] nvarchar(max) NOT NULL,
                            CONSTRAINT [PK_TradeInRequestImages] PRIMARY KEY ([Id]),
                            CONSTRAINT [FK_TradeInRequestImages_TradeInRequests_TradeInRequestId] FOREIGN KEY ([TradeInRequestId]) REFERENCES [TradeInRequests] ([Id]) ON DELETE CASCADE
                        );
                        CREATE INDEX [IX_TradeInRequestImages_TradeInRequestId] ON [TradeInRequestImages] ([TradeInRequestId]);
                    END
                ");

            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error during DB Fix: {ex.Message}");
            }
        }
    }
}

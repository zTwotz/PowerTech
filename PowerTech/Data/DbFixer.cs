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
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error during DB Fix: {ex.Message}");
            }
        }
    }
}

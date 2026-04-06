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

                // Mark pending migrations as applied in __EFMigrationsHistory
                var pendingMigrations = new[] 
                {
                    "20260405122421_InitialCreate",
                    "20260405122827_DbInit",
                    "20260406003501_AddCatalogEntities",
                    "20260406004908_AddOrderOrderItemPaymentCore",
                    "20260406013227_AddUserAddressAndCart",
                    "UpdateOrderItemSnapshots"
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

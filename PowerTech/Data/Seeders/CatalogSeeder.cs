using Microsoft.EntityFrameworkCore;
using PowerTech.Models.Entities;

namespace PowerTech.Data.Seeders
{
    public static class CatalogSeeder
    {
        public static async Task SeedCatalogAsync(ApplicationDbContext context)
        {
            // 1. Seed Categories
            var categories = new List<Category>
            {
                new() { Name = "Laptop", Slug = "laptop", Description = "Laptop các loại", DisplayOrder = 1 },
                new() { Name = "CPU", Slug = "cpu", Description = "Bộ vi xử lý", DisplayOrder = 2 },
                new() { Name = "RAM", Slug = "ram", Description = "Bộ nhớ trong", DisplayOrder = 3 },
                new() { Name = "GPU", Slug = "gpu", Description = "Card đồ họa", DisplayOrder = 4 },
                new() { Name = "Monitor", Slug = "monitor", Description = "Màn hình máy tính", DisplayOrder = 5 },
                new() { Name = "Storage", Slug = "storage", Description = "Ổ cứng lưu trữ", DisplayOrder = 6 },
                new() { Name = "Mainboard", Slug = "mainboard", Description = "Bo mạch chủ", DisplayOrder = 7 },
                new() { Name = "Keyboard", Slug = "keyboard", Description = "Bàn phím", DisplayOrder = 8 },
                new() { Name = "Mouse", Slug = "mouse", Description = "Chuột máy tính", DisplayOrder = 9 }
            };

            foreach (var cat in categories)
            {
                if (!await context.Categories.AnyAsync(c => c.Slug == cat.Slug))
                {
                    context.Categories.Add(cat);
                }
            }
            await context.SaveChangesAsync();

            // 2. Seed Brands
            var brands = new List<Brand>
            {
                new() { Name = "ASUS", Slug = "asus", Description = "ASUS Global" },
                new() { Name = "MSI", Slug = "msi", Description = "MSI Gaming" },
                new() { Name = "Gigabyte", Slug = "gigabyte", Description = "Gigabyte Technology" },
                new() { Name = "Logitech", Slug = "logitech", Description = "Logitech Peripherals" },
                new() { Name = "Dell", Slug = "dell", Description = "Dell Inc." },
                new() { Name = "Kingston", Slug = "kingston", Description = "Kingston Technology" },
                new() { Name = "Corsair", Slug = "corsair", Description = "Corsair Gaming" },
                new() { Name = "Samsung", Slug = "samsung", Description = "Samsung Electronics" }
            };

            foreach (var b in brands)
            {
                if (!await context.Brands.AnyAsync(x => x.Slug == b.Slug))
                {
                    context.Brands.Add(b);
                }
            }
            await context.SaveChangesAsync();

            // 3. Seed Products (Demo)
            // Lấy ID sau khi đã seed
            var catLaptop = await context.Categories.FirstAsync(c => c.Slug == "laptop");
            var catCpu = await context.Categories.FirstAsync(c => c.Slug == "cpu");
            var brandAsus = await context.Brands.FirstAsync(b => b.Slug == "asus");
            var brandIntel = await context.Brands.FirstOrDefaultAsync(b => b.Slug == "intel"); // Có thể đã có từ trước
            
            if (brandIntel == null)
            {
                brandIntel = new Brand { Name = "Intel", Slug = "intel", Description = "Intel Corporation" };
                context.Brands.Add(brandIntel);
                await context.SaveChangesAsync();
            }

            var demoProducts = new List<Product>
            {
                new() 
                { 
                    SKU = "LAP-ASUS-ROG-001", Name = "Asus ROG Strix G15", Slug = "asus-rog-strix-g15",
                    CategoryId = catLaptop.Id, BrandId = brandAsus.Id, Price = 25000000, StockQuantity = 10,
                    ShortDescription = "Laptop gaming hiệu năng cao", Description = "Chi tiết về laptop gaming Asus ROG Strix G15...",
                    WarrantyMonths = 24, IsFeatured = true, IsActive = true, CreatedAt = DateTime.UtcNow
                },
                new() 
                { 
                    SKU = "CPU-INTEL-I9-14900K", Name = "Intel Core i9-14900K", Slug = "intel-core-i9-14900k",
                    CategoryId = catCpu.Id, BrandId = brandIntel.Id, Price = 15000000, StockQuantity = 15,
                    ShortDescription = "CPU Intel thế hệ 14 nhất", Description = "Thông số kỹ thuật CPU Intel Core i9-14900K...",
                    WarrantyMonths = 36, IsFeatured = true, IsActive = true, CreatedAt = DateTime.UtcNow
                }
            };

            foreach (var p in demoProducts)
            {
                if (!await context.Products.AnyAsync(x => x.SKU == p.SKU))
                {
                    context.Products.Add(p);
                }
            }
            await context.SaveChangesAsync();
            
            // Seed Specs for one laptop
            var targetProduct = await context.Products.FirstOrDefaultAsync(p => p.SKU == "LAP-ASUS-ROG-001");
            if (targetProduct != null)
            {
                // Check if spec definitions exist for Laptop category
                if (!await context.SpecificationDefinitions.AnyAsync(sd => sd.CategoryId == catLaptop.Id && sd.SpecName == "CPU"))
                {
                    var specDefs = new List<SpecificationDefinition>
                    {
                        new() { CategoryId = catLaptop.Id, SpecName = "CPU", DataType = "text", IsRequired = true, SortOrder = 1 },
                        new() { CategoryId = catLaptop.Id, SpecName = "RAM", DataType = "text", IsRequired = true, SortOrder = 2 },
                        new() { CategoryId = catLaptop.Id, SpecName = "Screen", DataType = "text", IsRequired = true, SortOrder = 3 }
                    };
                    context.SpecificationDefinitions.AddRange(specDefs);
                    await context.SaveChangesAsync();

                    var specDefCpu = specDefs.First(x => x.SpecName == "CPU");
                    var specDefRam = specDefs.First(x => x.SpecName == "RAM");

                    context.ProductSpecifications.AddRange(new List<ProductSpecification>
                    {
                        new() { ProductId = targetProduct.Id, SpecDefinitionId = specDefCpu.Id, ValueText = "AMD Ryzen 7 6800H", DisplayValue = "Ryzen 7 6800H" },
                        new() { ProductId = targetProduct.Id, SpecDefinitionId = specDefRam.Id, ValueText = "16GB DDR5", DisplayValue = "16GB DDR5" }
                    });
                    await context.SaveChangesAsync();
                }
            }
        }
    }
}

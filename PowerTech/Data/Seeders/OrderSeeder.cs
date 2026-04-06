using Microsoft.EntityFrameworkCore;
using PowerTech.Models.Entities;

namespace PowerTech.Data.Seeders
{
    public static class OrderSeeder
    {
        public static async Task SeedAsync(ApplicationDbContext context)
        {
            // 1. Seed a test order for admin if no orders exist yet for that code
            string adminOrderCode = "ORD-ADM-TEST";
            string adminId = "2A983E14-758A-4CB2-8D47-2290B07958CA"; // ID from AspNetUsers record
            
            if (!await context.Orders.AnyAsync(o => o.OrderCode == adminOrderCode))
            {
                var product = await context.Products.FirstOrDefaultAsync(p => p.Id == 1);
                if (product == null) return;

                var order = new Order
                {
                    OrderCode = adminOrderCode,
                    UserId = adminId,
                    ReceiverName = "PowerTech Admin",
                    PhoneNumber = "0900000000",
                    ShippingAddress = "123 Main St, Tech City",
                    OrderStatus = "Completed",
                    PaymentStatus = "Paid",
                    PaymentMethod = "BankTransfer",
                    Subtotal = product.Price,
                    ShippingFee = 0,
                    DiscountAmount = 0,
                    TotalAmount = product.Price,
                    Note = "Initial system test order",
                    CreatedAt = DateTime.UtcNow.AddDays(-1)
                };

                context.Orders.Add(order);
                await context.SaveChangesAsync();

                // 2. Seed Order Item
                var orderItem = new OrderItem
                {
                    OrderId = order.Id,
                    ProductId = product.Id,
                    Quantity = 1,
                    UnitPrice = product.Price,
                    LineTotal = product.Price,
                    ProductNameSnapshot = product.Name,
                    ProductSkuSnapshot = product.SKU,
                    ProductImageSnapshot = product.ThumbnailUrl
                };

                context.OrderItems.Add(orderItem);

                // 3. Seed Payment
                var payment = new Payment
                {
                    OrderId = order.Id,
                    PaymentMethod = "BankTransfer",
                    PaymentStatus = "Paid",
                    Amount = order.TotalAmount,
                    TransactionCode = "TXN-TEST-001",
                    GatewayProvider = "SystemInternal",
                    PaidAt = DateTime.UtcNow.AddHours(-23),
                    CreatedAt = DateTime.UtcNow.AddDays(-1),
                    Note = "Simulated bank payment"
                };

                context.Payments.Add(payment);
                await context.SaveChangesAsync();
            }
        }
    }
}

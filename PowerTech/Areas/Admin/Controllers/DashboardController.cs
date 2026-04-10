using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Constants;
using PowerTech.Data;

namespace PowerTech.Areas.Admin.Controllers
{
    [Area("Admin")]
    [Authorize(Roles = UserRoles.Admin)]
    public class DashboardController : Controller
    {
        private readonly ApplicationDbContext _context;

        public DashboardController(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index(string filter = "today")
        {
            var now = DateTime.Now;
            var today = now.Date;
            var yesterday = today.AddDays(-1);
            
            DateTime startDate, endDate = now;
            string filterDisplay = "Hôm nay";

            switch (filter.ToLower())
            {
                case "yesterday":
                    startDate = yesterday;
                    endDate = today.AddTicks(-1);
                    filterDisplay = "Hôm qua";
                    break;
                case "7days":
                    startDate = today.AddDays(-6);
                    filterDisplay = "7 ngày qua";
                    break;
                case "month":
                    startDate = new DateTime(now.Year, now.Month, 1);
                    filterDisplay = "Tháng này";
                    break;
                default:
                    startDate = today;
                    filterDisplay = "Hôm nay";
                    break;
            }

            ViewBag.CurrentFilter = filter;
            ViewBag.FilterDisplay = filterDisplay;

            // --- Stats based on selected period ---
            var periodOrders = _context.Orders.Where(o => o.CreatedAt >= startDate && o.CreatedAt <= endDate);
            
            ViewBag.PeriodOrdersCount = await periodOrders.CountAsync();
            ViewBag.PeriodRevenue = await _context.Orders
                .Where(o => o.OrderStatus == "Completed" && 
                            ((o.UpdatedAt != null && o.UpdatedAt >= startDate && o.UpdatedAt <= endDate) || 
                             (o.UpdatedAt == null && o.CreatedAt >= startDate && o.CreatedAt <= endDate)))
                .SumAsync(o => (decimal?)o.TotalAmount) ?? 0;

            // --- Global Stats (Still needed for some cards) ---
            ViewBag.TotalOrders = await _context.Orders.CountAsync();
            ViewBag.TotalProducts = await _context.Products.CountAsync();
            ViewBag.TotalRevenue = await _context.Orders
                .Where(o => o.OrderStatus == "Completed")
                .SumAsync(o => o.TotalAmount);
            
            // --- Revenue Comparison (Today vs Yesterday) ---
            var todayRevenue = await _context.Orders
                .Where(o => o.OrderStatus == "Completed" && 
                            ((o.UpdatedAt != null && o.UpdatedAt >= today) || 
                             (o.UpdatedAt == null && o.CreatedAt >= today)))
                .SumAsync(o => (decimal?)o.TotalAmount) ?? 0;
            ViewBag.TodayRevenue = todayRevenue;

            var yesterdayRevenue = await _context.Orders
                .Where(o => o.OrderStatus == "Completed" && 
                            ((o.UpdatedAt != null && o.UpdatedAt >= yesterday && o.UpdatedAt < today) || 
                             (o.UpdatedAt == null && o.CreatedAt >= yesterday && o.CreatedAt < today)))
                .SumAsync(o => (decimal?)o.TotalAmount) ?? 0;
            
            double growthPercent = 0;
            if (yesterdayRevenue > 0)
                growthPercent = (double)((todayRevenue - yesterdayRevenue) / yesterdayRevenue * 100);
            else if (todayRevenue > 0)
                growthPercent = 100;
            ViewBag.RevenueGrowth = growthPercent;

            // --- Detailed Order Stats (Global or Period? Let's show Global for these small badges but filter the main count) ---
            ViewBag.PendingOrders = await _context.Orders.CountAsync(o => o.OrderStatus == "Pending");
            ViewBag.ShippingOrders = await _context.Orders.CountAsync(o => o.OrderStatus == "Shipped" || o.OrderStatus == "Shipping");
            ViewBag.CompletedOrders = await _context.Orders.CountAsync(o => o.OrderStatus == "Completed");

            // --- Inventory Stats ---
            ViewBag.LowStockCount = await _context.Products.CountAsync(p => p.StockQuantity <= 5 && p.IsActive);
            ViewBag.OutOfStockCount = await _context.Products.CountAsync(p => p.StockQuantity <= 0 && p.IsActive);
            ViewBag.TotalCustomers = await _context.Users.CountAsync();
            ViewBag.OpenTickets = await _context.SupportTickets.CountAsync(t => t.Status != "Closed" && t.Status != "Resolved");

            // --- Top Products in Period ---
            var topProducts = await _context.OrderItems
                .Where(oi => oi.Order.CreatedAt >= startDate && oi.Order.CreatedAt <= endDate && oi.Order.OrderStatus != "Cancelled")
                .GroupBy(oi => new { oi.ProductId, oi.Product.Name, oi.Product.ThumbnailUrl, oi.Product.Price })
                .Select(g => new {
                    Name = g.Key.Name,
                    SoldQuantity = g.Sum(oi => oi.Quantity),
                    ThumbnailUrl = g.Key.ThumbnailUrl,
                    Price = g.Key.Price
                })
                .OrderByDescending(x => x.SoldQuantity)
                .Take(5)
                .ToListAsync();
            
            // Fallback if no sales in period
            if (!topProducts.Any())
            {
               var fallbackProducts = await _context.Products
                    .OrderByDescending(p => p.SoldQuantity)
                    .Take(5)
                    .Select(p => new { p.Name, p.SoldQuantity, p.ThumbnailUrl, p.Price })
                    .ToListAsync();
               ViewBag.TopProducts = fallbackProducts;
            }
            else
            {
                ViewBag.TopProducts = topProducts;
            }

            // --- Chart Data: Last 7 Days Revenue ---
            var chartData = new List<object>();
            for (int i = 6; i >= 0; i--)
            {
                var date = today.AddDays(-i);
                var nextDate = date.AddDays(1);
                var dailyRevenue = await _context.Orders
                    .Where(o => o.OrderStatus == "Completed" && 
                                ((o.UpdatedAt != null && o.UpdatedAt >= date && o.UpdatedAt < nextDate) || 
                                 (o.UpdatedAt == null && o.CreatedAt >= date && o.CreatedAt < nextDate)))
                    .SumAsync(o => (decimal?)o.TotalAmount) ?? 0;
                
                chartData.Add(new { 
                    Day = date.ToString("dd/MM"), 
                    Value = dailyRevenue 
                });
            }
            ViewBag.ChartData = chartData;

            var recentOrders = await _context.Orders
                .OrderByDescending(o => o.CreatedAt)
                .Take(5)
                .ToListAsync();

            return View(recentOrders);
        }
    }
}

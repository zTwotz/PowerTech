using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Constants;
using PowerTech.Models.Entities;

namespace PowerTech.Areas.Sales.Controllers
{
    [Area("Sales")]
    [Authorize(Roles = UserRoles.SalesStaff + "," + UserRoles.Admin)]
    public class HomeController : Controller
    {
        private readonly ApplicationDbContext _context;

        public HomeController(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index(string? status = null)
        {
            var today = DateTime.Now.Date;
            var startOfMonth = new DateTime(today.Year, today.Month, 1);

            var ordersQuery = _context.Orders.AsQueryable();
            if (!string.IsNullOrEmpty(status))
            {
                if (status == "Pending") ordersQuery = ordersQuery.Where(o => o.OrderStatus == "Pending");
                else if (status == "Shipping") ordersQuery = ordersQuery.Where(o => o.OrderStatus == "Shipping" || o.OrderStatus == "Shipped");
            }

            var model = new SalesDashboardViewModel
            {
                CurrentFilter = status,
                PendingOrders = await _context.Orders.CountAsync(o => o.OrderStatus == "Pending"),
                ProcessingOrdersCount = await _context.Orders.CountAsync(o => o.OrderStatus == "Processing" || o.OrderStatus == "Confirmed"),
                ShippedOrders = await _context.Orders.CountAsync(o => o.OrderStatus == "Shipping" || o.OrderStatus == "Shipped"),
                CompletedOrdersMonth = await _context.Orders.CountAsync(o => o.CreatedAt >= startOfMonth && o.OrderStatus == "Completed"),
                TodayRevenue = await _context.Orders
                    .Where(o => o.OrderStatus == "Completed" && 
                                ((o.UpdatedAt != null && o.UpdatedAt >= today) || 
                                 (o.UpdatedAt == null && o.CreatedAt >= today)))
                    .SumAsync(o => (decimal?)o.TotalAmount) ?? 0,
                RecentOrders = await ordersQuery
                    .OrderByDescending(o => o.CreatedAt)
                    .Take(8)
                    .Include(o => o.User)
                    .ToListAsync(),
                TopProducts = await _context.OrderItems
                    .GroupBy(oi => new { oi.ProductId, oi.ProductNameSnapshot })
                    .Select(g => new TopProductViewModel {
                        Name = g.Key.ProductNameSnapshot ?? "Sản phẩm không tên",
                        Quantity = g.Sum(x => x.Quantity),
                        Revenue = g.Sum(x => x.LineTotal)
                    })
                    .OrderByDescending(x => x.Quantity)
                    .Take(5)
                    .ToListAsync()
            };

            return View(model);
        }
    }

    public class SalesDashboardViewModel
    {
        public string? CurrentFilter { get; set; }
        public decimal TodayRevenue { get; set; }
        public int PendingOrders { get; set; }
        public int ProcessingOrdersCount { get; set; }
        public int ShippedOrders { get; set; }
        public int CompletedOrdersMonth { get; set; }
        public List<Order> RecentOrders { get; set; } = new List<Order>();
        public List<TopProductViewModel> TopProducts { get; set; } = new List<TopProductViewModel>();
    }

    public class TopProductViewModel
    {
        public string Name { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal Revenue { get; set; }
    }
}

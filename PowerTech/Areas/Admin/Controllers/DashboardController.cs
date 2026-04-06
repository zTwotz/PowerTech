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

        public async Task<IActionResult> Index()
        {
            ViewBag.TotalOrders = await _context.Orders.CountAsync();
            ViewBag.TotalProducts = await _context.Products.CountAsync();
            ViewBag.TotalRevenue = await _context.Orders
                .Where(o => o.OrderStatus != "Cancelled")
                .SumAsync(o => o.TotalAmount);
            ViewBag.PendingOrders = await _context.Orders
                .Where(o => o.OrderStatus == "Pending")
                .CountAsync();

            var recentOrders = await _context.Orders
                .OrderByDescending(o => o.CreatedAt)
                .Take(5)
                .ToListAsync();

            return View(recentOrders);
        }
    }
}

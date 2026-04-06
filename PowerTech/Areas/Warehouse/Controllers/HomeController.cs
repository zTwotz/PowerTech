using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Constants;

namespace PowerTech.Areas.Warehouse.Controllers
{
    [Area("Warehouse")]
    [Authorize(Roles = UserRoles.WarehouseStaff + "," + UserRoles.Admin)]
    public class HomeController : Controller
    {
        private readonly ApplicationDbContext _context;

        public HomeController(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            var lowStockThreshold = 10;
            var stats = new
            {
                TotalProducts = await _context.Products.CountAsync(),
                LowStockProducts = await _context.Products.CountAsync(p => p.StockQuantity < lowStockThreshold),
                OutOfStockProducts = await _context.Products.CountAsync(p => p.StockQuantity == 0),
                TotalStockValue = await _context.Products.SumAsync(p => p.StockQuantity * p.Price),
                RecentProducts = await _context.Products
                    .OrderByDescending(p => p.UpdatedAt ?? p.CreatedAt)
                    .Take(5)
                    .ToListAsync()
            };

            ViewBag.Stats = stats;
            ViewBag.LowStockThreshold = lowStockThreshold;
            return View();
        }
    }
}

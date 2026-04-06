using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Constants;

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

        public async Task<IActionResult> Index()
        {
            var stats = new
            {
                PendingOrders = await _context.Orders.CountAsync(o => o.OrderStatus == "Pending"),
                ProcessingOrders = await _context.Orders.CountAsync(o => o.OrderStatus == "Processing"),
                CancelledOrders = await _context.Orders.CountAsync(o => o.OrderStatus == "Cancelled"),
                RecentOrders = await _context.Orders
                    .OrderByDescending(o => o.CreatedAt)
                    .Take(5)
                    .Include(o => o.User)
                    .ToListAsync()
            };

            ViewBag.Stats = stats;
            return View();
        }
    }
}

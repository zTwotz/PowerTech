using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Constants;

namespace PowerTech.Areas.Support.Controllers
{
    [Area("Support")]
    [Authorize(Roles = UserRoles.SupportStaff + "," + UserRoles.Admin)]
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
                PendingReviews = await _context.Reviews.CountAsync(r => !r.IsApproved),
                OpenTickets = await _context.SupportTickets.CountAsync(t => t.Status == "Open"),
                AssignedTickets = await _context.SupportTickets.CountAsync(t => t.Status != "Closed" && t.AssignedToUserId != null),
                RecentReviews = await _context.Reviews
                    .Include(r => r.Product)
                    .Include(r => r.User)
                    .OrderByDescending(r => r.CreatedAt)
                    .Take(5)
                    .ToListAsync()
            };

            ViewBag.Stats = stats;
            return View();
        }
    }
}

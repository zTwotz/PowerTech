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
            var openTicketsCount = await _context.SupportTickets.CountAsync(t => t.Status == "Open");
            var assignedTicketsCount = await _context.SupportTickets.CountAsync(t => t.Status != "Closed" && t.Status != "Resolved" && t.AssignedToUserId != null);
            
            // SLA: open/in progress tickets untouched for 24h
            var threshold24h = DateTime.UtcNow.AddHours(-24);
            var overdueTicketsCount = await _context.SupportTickets
                .CountAsync(t => t.Status != "Closed" && t.Status != "Resolved" && t.UpdatedAt < threshold24h);

            // CSAT
            var ratedTickets = await _context.SupportTickets.Where(t => t.Rating != null).ToListAsync();
            double avgCsat = ratedTickets.Any() ? ratedTickets.Average(t => t.Rating.GetValueOrDefault()) : 0;

            var stats = new
            {
                TotalCustomers = await _context.Users.CountAsync(), // Simplification, could filter by Role
                PendingReviews = await _context.Reviews.CountAsync(r => !r.IsApproved),
                OpenTickets = openTicketsCount,
                AssignedTickets = assignedTicketsCount,
                OverdueTickets = overdueTicketsCount,
                AverageCsat = avgCsat,
                RecentReviews = await _context.Reviews
                    .Include(r => r.Product)
                    .Include(r => r.User)
                    .OrderByDescending(r => r.CreatedAt)
                    .Take(5)
                    .ToListAsync(),
                RecentTickets = await _context.SupportTickets
                    .Include(t => t.User)
                    .OrderByDescending(t => t.CreatedAt)
                    .Take(10)
                    .ToListAsync(),
                ResolvedToday = await _context.SupportTickets
                    .CountAsync(t => (t.Status == "Resolved" || t.Status == "Closed") && t.UpdatedAt >= DateTime.Today)
            };

            ViewBag.Stats = stats;
            return View();
        }
    }
}

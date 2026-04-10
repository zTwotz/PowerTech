using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Constants;
using PowerTech.Data;
using PowerTech.Models.Entities;

namespace PowerTech.Areas.Support.Controllers
{
    [Area("Support")]
    [Authorize(Roles = UserRoles.SupportStaff + "," + UserRoles.Admin)]
    public class CustomerController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;

        public CustomerController(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        public async Task<IActionResult> Index(string q)
        {
            var userQuery = _userManager.Users.AsQueryable();

            if (!string.IsNullOrEmpty(q))
            {
                userQuery = userQuery.Where(u => (u.Email != null && u.Email.Contains(q)) || (u.FullName != null && u.FullName.Contains(q)) || (u.PhoneNumber != null && u.PhoneNumber.Contains(q)));
                ViewBag.SearchTerm = q;
            }

            var users = await userQuery.OrderBy(u => u.FullName).ToListAsync();
            return View(users);
        }

        public async Task<IActionResult> Detail(string id)
        {
            if (string.IsNullOrEmpty(id)) return NotFound();

            var user = await _userManager.Users
                .FirstOrDefaultAsync(u => u.Id == id);

            if (user == null) return NotFound();

            // Fetch Orders
            var orders = await _context.Orders
                .Where(o => o.UserId == id)
                .OrderByDescending(o => o.CreatedAt)
                .ToListAsync();

            // Fetch Tickets
            var tickets = await _context.SupportTickets
                .Where(t => t.UserId == id)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            // Fetch Addresses
            var addresses = await _context.UserAddresses
                .Where(a => a.UserId == id)
                .ToListAsync();

            ViewBag.Orders = orders;
            ViewBag.Tickets = tickets;
            ViewBag.Addresses = addresses;

            return View(user);
        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ToggleStatus(string id)
        {
            var user = await _userManager.FindByIdAsync(id);
            if (user == null) return Json(new { success = false });

            user.IsActive = !user.IsActive;
            var result = await _userManager.UpdateAsync(user);

            return Json(new { success = result.Succeeded, isActive = user.IsActive });
        }
    }
}

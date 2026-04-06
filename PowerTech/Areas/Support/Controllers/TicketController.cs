using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Constants;
using PowerTech.Models.Entities;
using System.Security.Claims;

namespace PowerTech.Areas.Support.Controllers
{
    [Area("Support")]
    [Authorize(Roles = UserRoles.SupportStaff + "," + UserRoles.Admin)]
    public class TicketController : Controller
    {
        private readonly ApplicationDbContext _context;

        public TicketController(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index(string? status, string? priority)
        {
            var query = _context.SupportTickets
                .Include(t => t.User)
                .Include(t => t.AssignedTo)
                .OrderByDescending(t => t.CreatedAt)
                .AsQueryable();

            if (!string.IsNullOrEmpty(status))
            {
                query = query.Where(t => t.Status == status);
            }

            if (!string.IsNullOrEmpty(priority))
            {
                query = query.Where(t => t.Priority == priority);
            }

            var tickets = await query.ToListAsync();
            ViewBag.CurrentStatus = status;
            ViewBag.CurrentPriority = priority;

            return View(tickets);
        }

        public async Task<IActionResult> Details(int id)
        {
            var ticket = await _context.SupportTickets
                .Include(t => t.User)
                .Include(t => t.Order)
                .Include(t => t.AssignedTo)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (ticket == null) return NotFound();

            return View(ticket);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UpdateStatus(int ticketId, string status)
        {
            var ticket = await _context.SupportTickets.FindAsync(ticketId);
            if (ticket == null) return NotFound();

            ticket.Status = status;
            ticket.UpdatedAt = DateTime.UtcNow;
            
            if (status == "Closed")
            {
                ticket.ClosedAt = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = $"Đơn hỗ trợ {ticket.TicketCode} đã được cập nhật trạng thái {status}!";
            
            return RedirectToAction(nameof(Details), new { id = ticketId });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AssignToMe(int ticketId)
        {
            var ticket = await _context.SupportTickets.FindAsync(ticketId);
            if (ticket == null) return NotFound();

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            ticket.AssignedToUserId = userId;
            ticket.Status = "In Progress";
            ticket.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Bạn đã tự nhận xử lý ticket này thành công!";
            
            return RedirectToAction(nameof(Details), new { id = ticketId });
        }
    }
}

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Constants;
using PowerTech.Models.Entities;
using System.Security.Claims;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.SignalR;

namespace PowerTech.Areas.Support.Controllers
{
    [Area("Support")]
    [Authorize(Roles = UserRoles.SupportStaff + "," + UserRoles.Admin)]
    public class TicketController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IWebHostEnvironment _env;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IHubContext<PowerTech.Hubs.SupportHub> _hubContext;

        public TicketController(ApplicationDbContext context, IWebHostEnvironment env, UserManager<ApplicationUser> userManager, IHubContext<PowerTech.Hubs.SupportHub> hubContext)
        {
            _context = context;
            _env = env;
            _userManager = userManager;
            _hubContext = hubContext;
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
                .Include(t => t.Responses.OrderBy(r => r.CreatedAt))
                    .ThenInclude(r => r.User)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (ticket == null) return NotFound();

            var cannedResponses = await _context.CannedResponses.OrderBy(c => c.Title).ToListAsync();
            ViewBag.CannedResponses = cannedResponses;

            var staffUsers = await _userManager.GetUsersInRoleAsync(UserRoles.SupportStaff);
            var admins = await _userManager.GetUsersInRoleAsync(UserRoles.Admin);
            ViewBag.StaffList = staffUsers.Union(admins).ToList();

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

            var notif = new Notification
            {
                UserId = ticket.UserId,
                Title = "Cập nhật yêu cầu hỗ trợ",
                Message = $"Yêu cầu hỗ trợ {ticket.TicketCode} của bạn đã được cập nhật trạng thái: {status}.",
                Type = "Ticket",
                TargetUrl = $"/Customer/Ticket/Detail/{ticket.Id}"
            };
            _context.Notifications.Add(notif);

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

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AssignTicket(int ticketId, string assignToUserId)
        {
            var ticket = await _context.SupportTickets.FindAsync(ticketId);
            if (ticket == null) return NotFound();

            if (!string.IsNullOrEmpty(assignToUserId))
            {
                ticket.AssignedToUserId = assignToUserId;
                if (ticket.Status == "Open") ticket.Status = "In Progress";
                ticket.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Đã phân công ticket thành công!";
            }

            return RedirectToAction(nameof(Details), new { id = ticketId });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AddResponse(int ticketId, string message, bool isInternal = false, IFormFile? attachment = null)
        {
            var ticket = await _context.SupportTickets.FindAsync(ticketId);
            if (ticket == null) return NotFound();

            if (string.IsNullOrWhiteSpace(message)) return RedirectToAction(nameof(Details), new { id = ticketId });

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var response = new TicketResponse
            {
                TicketId = ticketId,
                UserId = userId ?? string.Empty,
                Message = message,
                IsInternal = isInternal,
                CreatedAt = DateTime.UtcNow
            };

            if (attachment != null && attachment.Length > 0)
            {
                string uploadsFolder = Path.Combine(_env.WebRootPath, "uploads", "support");
                Directory.CreateDirectory(uploadsFolder);
                string uniqueFileName = Guid.NewGuid().ToString() + "_" + attachment.FileName;
                string filePath = Path.Combine(uploadsFolder, uniqueFileName);
                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await attachment.CopyToAsync(fileStream);
                }
                response.AttachmentUrl = "/uploads/support/" + uniqueFileName;
            }

            // Update ticket status if it's the first staff reply
            if (ticket.Status == "Open")
            {
                ticket.Status = "In Progress";
                ticket.AssignedToUserId = userId; // Auto-assign if not assigned
            }
            
            ticket.UpdatedAt = DateTime.UtcNow;

            _context.TicketResponses.Add(response);
            await _context.SaveChangesAsync();

            // Send Real-time notification if not internal
            if (!isInternal)
            {
                var notif = new Notification
                {
                    UserId = ticket.UserId,
                    Title = "Phản hồi mới từ CSKH",
                    Message = $"Nhân viên hỗ trợ vừa trả lời yêu cầu {ticket.TicketCode} của bạn.",
                    Type = "Ticket",
                    TargetUrl = $"/Customer/Ticket/Detail/{ticket.Id}"
                };
                _context.Notifications.Add(notif);
                await _context.SaveChangesAsync();

                if (userId != null)
                {
                    var staffUser = await _userManager.FindByIdAsync(userId);
                    await _hubContext.Clients.Group($"Ticket_{ticketId}").SendAsync("ReceiveTicketUpdate", ticketId, staffUser?.FullName ?? "Nhân viên hỗ trợ", message);
                }
            }
            
            TempData["SuccessMessage"] = "Phản hồi đã được gửi!";
            return RedirectToAction(nameof(Details), new { id = ticketId });
        }
    }
}

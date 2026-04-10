using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Models.Entities;
using Microsoft.AspNetCore.SignalR;
using PowerTech.Hubs;

namespace PowerTech.Areas.Customer.Controllers
{
    [Area("Customer")]
    [Authorize]
    public class SupportController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IWebHostEnvironment _env;
        private readonly IHubContext<SupportHub> _hubContext;

        public SupportController(ApplicationDbContext context, UserManager<ApplicationUser> userManager, IWebHostEnvironment env, IHubContext<SupportHub> hubContext)
        {
            _context = context;
            _userManager = userManager;
            _env = env;
            _hubContext = hubContext;
        }

        public async Task<IActionResult> Index()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            var tickets = await _context.SupportTickets
                .Include(t => t.Order)
                .Where(t => t.UserId == user.Id)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();

            return View(tickets);
        }

        public async Task<IActionResult> Create()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            // Get user's orders to link to ticket if needed
            var orders = await _context.Orders
                .Where(o => o.UserId == user.Id)
                .OrderByDescending(o => o.CreatedAt)
                .Select(o => new { 
                    Id = o.Id, 
                    Text = $"{o.OrderCode} - {o.CreatedAt:dd/MM/yyyy} ({o.TotalAmount:N0}₫)" 
                })
                .ToListAsync();

            ViewBag.Orders = new SelectList(orders, "Id", "Text");
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(SupportTicket ticket, IFormFile? attachment)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            // Set mandatory fields manually
            ticket.UserId = user.Id;
            ticket.TicketCode = "ST-" + DateTime.Now.Ticks.ToString().Substring(10);
            ticket.Status = "Open";
            ticket.CreatedAt = DateTime.UtcNow;

            // Remove these from ModelState validation as they are set server-side
            ModelState.Remove("UserId");
            ModelState.Remove("TicketCode");
            ModelState.Remove("Status");
            ModelState.Remove("User"); // Navigation property

            if (ModelState.IsValid)
            {
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
                    ticket.AttachmentUrl = "/uploads/support/" + uniqueFileName;
                }

                _context.Add(ticket);
                await _context.SaveChangesAsync();

                TempData["Success"] = "Yêu cầu hỗ trợ của bạn đã được gửi thành công!";
                return RedirectToAction(nameof(Index));
            }

            // If error, reload orders
            var orders = await _context.Orders
                .Where(o => o.UserId == user.Id)
                .OrderByDescending(o => o.CreatedAt)
                .Select(o => new { 
                    Id = o.Id, 
                    Text = $"{o.OrderCode} - {o.CreatedAt:dd/MM/yyyy} ({o.TotalAmount:N0}₫)" 
                })
                .ToListAsync();
            ViewBag.Orders = new SelectList(orders, "Id", "Text");
            
            return View(ticket);
        }

        public async Task<IActionResult> Details(int id)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            var ticket = await _context.SupportTickets
                .Include(t => t.Order)
                .Include(t => t.AssignedTo)
                .Include(t => t.Responses.OrderBy(r => r.CreatedAt))
                    .ThenInclude(r => r.User)
                .FirstOrDefaultAsync(t => t.Id == id && t.UserId == user.Id);

            if (ticket == null) return NotFound();

            return View(ticket);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AddResponse(int ticketId, string message, IFormFile? attachment)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            var ticket = await _context.SupportTickets.FirstOrDefaultAsync(t => t.Id == ticketId && t.UserId == user.Id);
            if (ticket == null) return NotFound();

            if (string.IsNullOrWhiteSpace(message)) return RedirectToAction(nameof(Details), new { id = ticketId });

            var response = new TicketResponse
            {
                TicketId = ticketId,
                UserId = user.Id,
                Message = message,
                IsInternal = false,
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

            ticket.UpdatedAt = DateTime.UtcNow;
            
            _context.TicketResponses.Add(response);
            await _context.SaveChangesAsync();

            // Send Real-time notification to staff
            await _hubContext.Clients.Group($"Ticket_{ticketId}").SendAsync("ReceiveTicketUpdate", ticketId, user.FullName ?? "Khách hàng", message);

            TempData["Success"] = "Phản hồi của bạn đã được gửi!";
            return RedirectToAction(nameof(Details), new { id = ticketId });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RateTicket(int ticketId, int rating, string? feedback)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            var ticket = await _context.SupportTickets.FirstOrDefaultAsync(t => t.Id == ticketId && t.UserId == user.Id);
            if (ticket == null || ticket.Status != "Closed" || ticket.Status != "Resolved" && ticket.Status != "Closed") return NotFound();

            if (rating < 1 || rating > 5) return BadRequest();

            ticket.Rating = rating;
            ticket.Feedback = feedback;
            await _context.SaveChangesAsync();

            TempData["Success"] = "Cảm ơn bạn đã gửi đánh giá!";
            return RedirectToAction(nameof(Details), new { id = ticketId });
        }
    }
}

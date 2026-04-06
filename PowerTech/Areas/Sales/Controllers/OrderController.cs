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
    public class OrderController : Controller
    {
        private readonly ApplicationDbContext _context;

        public OrderController(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index(string? status, string? searchTerm)
        {
            var ordersQuery = _context.Orders
                .Include(o => o.User)
                .OrderByDescending(o => o.CreatedAt)
                .AsQueryable();

            if (!string.IsNullOrEmpty(status))
            {
                ordersQuery = ordersQuery.Where(o => o.OrderStatus == status);
            }

            if (!string.IsNullOrEmpty(searchTerm))
            {
                ordersQuery = ordersQuery.Where(o => 
                    o.OrderCode.Contains(searchTerm) || 
                    o.ReceiverName.Contains(searchTerm) || 
                    o.PhoneNumber.Contains(searchTerm));
            }

            var orders = await ordersQuery.ToListAsync();
            ViewBag.CurrentStatus = status;
            ViewBag.SearchTerm = searchTerm;
            return View(orders);
        }

        public async Task<IActionResult> Details(int id)
        {
            var order = await _context.Orders
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .Include(o => o.Payments)
                .FirstOrDefaultAsync(o => o.Id == id);

            if (order == null) return NotFound();

            return View(order);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UpdateStatus(int orderId, string status, string? internalNote)
        {
            var order = await _context.Orders.FindAsync(orderId);
            if (order == null) return NotFound();

            order.OrderStatus = status;
            order.InternalNote = internalNote;
            order.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = $"Cập nhật đơn hàng {order.OrderCode} thành công!";
            
            return RedirectToAction(nameof(Details), new { id = orderId });
        }
    }
}

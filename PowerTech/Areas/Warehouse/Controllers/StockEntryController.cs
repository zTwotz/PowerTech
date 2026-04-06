using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Constants;
using PowerTech.Models.Entities;

namespace PowerTech.Areas.Warehouse.Controllers
{
    [Area("Warehouse")]
    [Authorize(Roles = UserRoles.WarehouseStaff + "," + UserRoles.Admin)]
    public class StockEntryController : Controller
    {
        private readonly ApplicationDbContext _context;

        public StockEntryController(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            // Just listing all products for stock entry reference
            var products = await _context.Products
                .Include(p => p.Category)
                .OrderBy(p => p.Name)
                .ToListAsync();
            return View(products);
        }

        public async Task<IActionResult> Create(int? productId)
        {
            if (productId.HasValue)
            {
                var product = await _context.Products.FindAsync(productId.Value);
                if (product != null)
                {
                    ViewBag.SelectedProduct = product;
                }
            }

            ViewBag.Products = await _context.Products.OrderBy(p => p.Name).ToListAsync();
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(int productId, int quantity, string? note)
        {
            var product = await _context.Products.FindAsync(productId);
            if (product == null) return NotFound();

            if (quantity <= 0)
            {
                ModelState.AddModelError("quantity", "Số lượng nhập phải lớn hơn 0");
                ViewBag.Products = await _context.Products.OrderBy(p => p.Name).ToListAsync();
                ViewBag.SelectedProduct = product;
                return View();
            }

            // Update Stock
            product.StockQuantity += quantity;
            product.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            
            TempData["SuccessMessage"] = $"Đăng ký nhập kho thành công: {product.Name} (+{quantity})";
            return RedirectToAction("Index", "Inventory");
        }
    }
}

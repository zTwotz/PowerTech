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
    public class InventoryController : Controller
    {
        private readonly ApplicationDbContext _context;
        private const int LowStockThreshold = 10;

        public InventoryController(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index(string? searchTerm, int? categoryId, string? status)
        {
            var query = _context.Products
                .Include(p => p.Category)
                .Include(p => p.Brand)
                .AsQueryable();

            // 1. Lọc theo trạng thái tồn kho
            if (status == "low")
            {
                query = query.Where(p => p.StockQuantity > 0 && p.StockQuantity <= LowStockThreshold);
            }
            else if (status == "out")
            {
                query = query.Where(p => p.StockQuantity == 0);
            }

            // 2. Lọc theo danh mục
            if (categoryId.HasValue)
            {
                query = query.Where(p => p.CategoryId == categoryId.Value);
            }

            // 3. Lọc theo từ khóa
            if (!string.IsNullOrEmpty(searchTerm))
            {
                query = query.Where(p => p.Name.Contains(searchTerm) || p.SKU.Contains(searchTerm));
            }

            var products = await query.OrderBy(p => p.StockQuantity).ToListAsync();
            
            ViewBag.Categories = await _context.Categories.ToListAsync();
            ViewBag.SearchTerm = searchTerm;
            ViewBag.CategoryId = categoryId;
            ViewBag.Status = status;
            ViewBag.LowStockThreshold = LowStockThreshold;

            return View(products);
        }

        [HttpGet]
        public async Task<IActionResult> SearchProducts(string searchTerm)
        {
            if (string.IsNullOrEmpty(searchTerm) || searchTerm.Length < 1)
            {
                return Json(new List<object>());
            }

            var products = await _context.Products
                .Include(p => p.Category)
                .Where(p => p.Name.Contains(searchTerm) || 
                            p.SKU.Contains(searchTerm) || 
                            p.Category.Name.Contains(searchTerm))
                .Select(p => new
                {
                    id = p.Id,
                    name = p.Name,
                    sku = p.SKU,
                    thumbnailUrl = p.ThumbnailUrl,
                    stockQuantity = p.StockQuantity,
                    category = p.Category.Name
                })
                .Take(50)
                .ToListAsync();

            return Json(products);
        }

        public async Task<IActionResult> History()
        {
            var transactions = await _context.StockTransactions
                .Include(st => st.Product)
                .Include(st => st.PerformedByUser)
                .OrderByDescending(st => st.CreatedAt)
                .Take(100)
                .ToListAsync();

            return View(transactions);
        }
    }
}

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Constants;
using PowerTech.Models.Entities;
using Microsoft.AspNetCore.Identity;

namespace PowerTech.Areas.Warehouse.Controllers
{
    [Area("Warehouse")]
    [Authorize(Roles = UserRoles.WarehouseStaff + "," + UserRoles.Admin)]
    public class StockEntryController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;

        public StockEntryController(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        public async Task<IActionResult> Index()
        {
            var products = await _context.Products
                .Include(p => p.Category)
                .OrderBy(p => p.Name)
                .Take(20) // Hiển thị 20 sản phẩm mặc định
                .ToListAsync();

            var history = await _context.StockTransactions
                .Include(t => t.Product)
                .Include(t => t.PerformedByUser)
                .OrderByDescending(t => t.CreatedAt)
                .Take(50)
                .ToListAsync();

            ViewBag.History = history;

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
        public async Task<IActionResult> Create(int productId, int quantity, string? note, string referenceType)
        {
            var product = await _context.Products.FindAsync(productId);
            if (product == null) return NotFound();

            if (quantity == 0)
            {
                ModelState.AddModelError("quantity", "Số lượng nhập không thể bằng 0");
                ViewBag.Products = await _context.Products.OrderBy(p => p.Name).ToListAsync();
                ViewBag.SelectedProduct = product;
                return View();
            }

            if (product.StockQuantity + quantity < 0)
            {
                ModelState.AddModelError("quantity", $"Số lượng tồn kho không đủ để xuất. Hiện có: {product.StockQuantity}");
                ViewBag.Products = await _context.Products.OrderBy(p => p.Name).ToListAsync();
                ViewBag.SelectedProduct = product;
                return View();
            }

            using var transactionScope = await _context.Database.BeginTransactionAsync();
            try
            {
                var beforeQty = product.StockQuantity;
                
                // Update Stock
                product.StockQuantity += quantity;
                product.UpdatedAt = DateTime.UtcNow;

                var currentUser = await _userManager.GetUserAsync(User);
                if (currentUser == null)
                {
                    throw new Exception("Phiên đăng nhập không hợp lệ hoặc đã hết hạn.");
                }

                var stockTransaction = new StockTransaction
                {
                    ProductId = product.Id,
                    PerformedByUserId = currentUser.Id,
                    TransactionType = quantity > 0 ? "IMPORT" : "EXPORT",
                    Quantity = quantity,
                    ReferenceType = referenceType ?? "PurchaseReceipt",
                    BeforeQuantity = beforeQty,
                    AfterQuantity = product.StockQuantity,
                    Note = note ?? (quantity > 0 ? "Nhập kho thủ công" : "Xuất/Trừ kho thủ công"),
                    CreatedAt = DateTime.UtcNow
                };

                _context.StockTransactions.Add(stockTransaction);
                await _context.SaveChangesAsync();
                await transactionScope.CommitAsync();
                
                string actionText = quantity > 0 ? "nhập kho" : "xuất kho/trừ kho";
                TempData["SuccessMessage"] = $"Thao tác {actionText} sản phẩm '{product.Name}' thành công ({quantity})";
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                Console.WriteLine("================ ERROR IN STOCK ENTRY ================");
                Console.WriteLine(ex.ToString());
                Console.WriteLine("======================================================");
                await transactionScope.RollbackAsync();
                ModelState.AddModelError("", $"Lỗi hệ thống: {ex.InnerException?.Message ?? ex.Message}");
                ViewBag.Products = await _context.Products.OrderBy(p => p.Name).ToListAsync();
                ViewBag.SelectedProduct = product;
                return View();
            }
        }
    }
}

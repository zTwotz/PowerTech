using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Models.ViewModels.Store;
using PowerTech.Models.Entities;
using Microsoft.AspNetCore.Http;

namespace PowerTech.Areas.Store.Controllers
{
    [Area("Store")]
    [AllowAnonymous]
    [ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
    public class HomeController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IWebHostEnvironment _hostEnvironment;

        public HomeController(ApplicationDbContext context, IWebHostEnvironment hostEnvironment)
        {
            _context = context;
            _hostEnvironment = hostEnvironment;
        }

        public async Task<IActionResult> Index()
        {
            var viewModel = new HomeViewModel
            {
                FeaturedCategories = await _context.Categories
                    .Where(c => c.IsActive && c.ParentCategoryId == null)
                    .OrderBy(c => c.DisplayOrder)
                    .ToListAsync(),

                FeaturedProducts = await _context.Products
                    .Include(p => p.ProductSpecifications)
                    .Where(p => p.IsActive)
                    .OrderBy(p => Guid.NewGuid()) 
                    .Take(15) 
                    .ToListAsync(),

                NewProducts = await _context.Products
                    .Include(p => p.ProductSpecifications)
                    .Where(p => p.IsActive)
                    .OrderByDescending(p => p.CreatedAt)
                    .Take(20)
                    .OrderBy(p => Guid.NewGuid()) 
                    .Take(15)
                    .ToListAsync(),

                DiscountProducts = await _context.Products
                    .Include(p => p.ProductSpecifications)
                    .Where(p => p.IsActive && p.DiscountPrice.HasValue)
                    .OrderByDescending(p => (p.Price - p.DiscountPrice) / p.Price)
                    .Take(20)
                    .OrderBy(p => Guid.NewGuid()) 
                    .Take(15)
                    .ToListAsync(),

                TopBrands = await _context.Brands
                    .OrderBy(b => Guid.NewGuid())
                    .Take(12)
                    .ToListAsync(),

                CategorySections = await _context.Categories
                    .Where(c => c.IsActive && c.ParentCategoryId == null)
                    .OrderBy(c => c.DisplayOrder)
                    .Select(c => new CategorySection
                    {
                        Category = c,
                        Products = _context.Products
                            .Include(p => p.ProductSpecifications)
                            .Where(p => p.IsActive && (p.CategoryId == c.Id || p.Category.ParentCategoryId == c.Id))
                            .OrderBy(p => Guid.NewGuid()) 
                            .Take(10)
                            .ToList()
                    })
                    .Where(cs => cs.Products.Any())
                    .ToListAsync(),

                MenuCategories = await _context.Categories
                    .Where(c => c.IsActive && c.ParentCategoryId == null)
                    .OrderBy(c => c.DisplayOrder)
                    .Select(c => new MenuCategory
                    {
                        Category = c,
                        Children = _context.Categories
                            .Where(child => child.ParentCategoryId == c.Id && child.IsActive)
                            .OrderBy(child => child.DisplayOrder)
                            .ToList(),
                        Brands = _context.Products
                            .Where(p => p.IsActive && (p.CategoryId == c.Id || p.Category.ParentCategoryId == c.Id))
                            .Select(p => p.Brand)
                            .Distinct()
                            .Take(8)
                            .ToList()
                    })
                    .ToListAsync()
            };

            return View(viewModel);
        }

        public IActionResult Showrooms()
        {
            return View();
        }

        public async Task<IActionResult> TradeIn()
        {
            ViewBag.Categories = await _context.Categories
                .Where(c => c.IsActive && c.Name != "Phụ Kiện" && c.Name != "Phần mềm")
                .OrderBy(c => c.DisplayOrder)
                .ToListAsync();
            return View();
        }

        [HttpGet]
        public async Task<IActionResult> GetBrandsByCategory(int categoryId)
        {
            var brands = await _context.Products
                .Where(p => p.CategoryId == categoryId || p.Category.ParentCategoryId == categoryId)
                .Select(p => p.Brand)
                .Distinct()
                .Where(b => b.IsActive)
                .Select(b => new { b.Id, b.Name })
                .ToListAsync();

            return Json(brands);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> TradeIn(TradeInRequest request, List<IFormFile> images)
        {
            try
            {
                // Basic validation
                if (request.CategoryId <= 0) return Json(new { success = false, message = "Vui lòng chọn loại thiết bị." });
                if (string.IsNullOrEmpty(request.ModelName)) return Json(new { success = false, message = "Vui lòng nhập tên model." });
                if (string.IsNullOrEmpty(request.ContactPhone)) return Json(new { success = false, message = "Vui lòng nhập số điện thoại liên hệ." });

                // If BrandId is 0 or less, it's "Other", so set to null
                if (request.BrandId <= 0) request.BrandId = null;

                request.CreatedAt = DateTime.UtcNow;
                request.Status = "Pending";
                request.UserId = User.Identity?.IsAuthenticated == true ? _context.Users.FirstOrDefault(u => u.UserName == User.Identity.Name)?.Id : null;

                _context.TradeInRequests.Add(request);
                await _context.SaveChangesAsync();

                // Save images
                List<string> imageUrls = new List<string>();
                if (images != null && images.Count > 0)
                {
                    foreach (var image in images)
                    {
                        var imageUrl = await SaveImage(image, "trade-in");
                        imageUrls.Add(imageUrl);

                        _context.TradeInRequestImages.Add(new TradeInRequestImage
                        {
                            TradeInRequestId = request.Id,
                            ImageUrl = imageUrl
                        });
                    }
                    await _context.SaveChangesAsync();
                }

                // Create support ticket
                var category = await _context.Categories.FindAsync(request.CategoryId);
                var ticket = new SupportTicket
                {
                    TicketCode = "TI-" + request.Id + "-" + DateTime.Now.ToString("yyMMddHHmm"),
                    UserId = User.Identity?.IsAuthenticated == true ? _context.Users.FirstOrDefault(u => u.UserName == User.Identity.Name)?.Id ?? "System" : "Guest",
                    Title = $"[THU CŨ] {category?.Name}: {request.ModelName}",
                    Content = $"Yêu cầu thu cũ đổi mới mới:\n- Loại: {category?.Name}\n- Model: {request.ModelName}\n- Tình trạng: {request.Condition}\n- Khách hàng: {request.ContactName}\n- SĐT: {request.ContactPhone}\n- Email: {request.ContactEmail}\n- Ghi chú: {request.Note}",
                    Status = "Open",
                    Priority = "High",
                    CreatedAt = DateTime.UtcNow,
                    AttachmentUrl = string.Join(";", imageUrls)
                };
                
                // Ensure the ticket has a valid User ID
                if (string.IsNullOrEmpty(ticket.UserId) || ticket.UserId == "Guest" || ticket.UserId == "System")
                {
                    // If not authenticated or fallback failed, find the first available Admin or any user
                    var firstUser = await _context.Users.FirstOrDefaultAsync();
                    if (firstUser == null)
                    {
                        return Json(new { success = false, message = "Lỗi: Không tìm thấy người dùng nào trong hệ thống để gán ticket." });
                    }
                    ticket.UserId = firstUser.Id;
                }

                _context.SupportTickets.Add(ticket);
                await _context.SaveChangesAsync();

                return Json(new { success = true, message = "Gửi yêu cầu thành công! Đội ngũ Support sẽ liên hệ với bạn sớm nhất." });
            }
            catch (Exception ex)
            {
                var innerMsg = ex.InnerException?.Message ?? "";
                return Json(new { success = false, message = "Đã có lỗi xảy ra: " + ex.Message + " " + innerMsg });
            }
        }

        private async Task<string> SaveImage(IFormFile file, string subFolder)
        {
            string uploadsFolder = Path.Combine(_hostEnvironment.WebRootPath, "uploads", subFolder);
            if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

            string uniqueFileName = Guid.NewGuid().ToString() + "_" + file.FileName;
            string filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(fileStream);
            }

            return $"/uploads/{subFolder}/" + uniqueFileName;
        }

        public IActionResult Warranty()
        {
            return View();
        }

        public IActionResult Error(int? statusCode = null)
        {
            if (statusCode == 404)
            {
                return View("NotFound");
            }
            return View();
        }
    }
}

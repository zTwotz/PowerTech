using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Constants;
using PowerTech.Data;
using PowerTech.Models.Entities;
using PowerTech.Areas.Admin.Models.ViewModels;

namespace PowerTech.Areas.Admin.Controllers
{
    [Area("Admin")]
    [Authorize(Roles = UserRoles.Admin)]
    public class ProductController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IWebHostEnvironment _hostingEnvironment;

        public ProductController(ApplicationDbContext context, IWebHostEnvironment hostingEnvironment)
        {
            _context = context;
            _hostingEnvironment = hostingEnvironment;
        }

        public async Task<IActionResult> Index(string? q, int? categoryId, int page = 1)
        {
            int pageSize = 10;
            var query = _context.Products
                .Include(p => p.Category)
                .Include(p => p.Brand)
                .AsQueryable();

            if (!string.IsNullOrEmpty(q))
            {
                query = query.Where(p => p.Name.Contains(q) || p.SKU.Contains(q));
            }

            if (categoryId.HasValue)
            {
                query = query.Where(p => p.CategoryId == categoryId);
            }

            var totalCount = await query.CountAsync();
            var products = await query
                .OrderByDescending(p => p.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = (int)Math.Ceiling(totalCount / (double)pageSize);
            ViewBag.Query = q;
            ViewBag.CategoryId = categoryId;
            ViewBag.Categories = await _context.Categories.ToListAsync();

            return View(products);
        }

        public async Task<IActionResult> Create()
        {
            await LoadDropdowns();
            return View(new ProductActionViewModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(ProductActionViewModel vm)
        {
            if (ModelState.IsValid)
            {
                var product = new Product
                {
                    SKU = vm.SKU,
                    Name = vm.Name,
                    Slug = vm.Slug,
                    CategoryId = vm.CategoryId,
                    BrandId = vm.BrandId,
                    Price = vm.Price,
                    DiscountPrice = vm.DiscountPrice,
                    StockQuantity = vm.StockQuantity,
                    ShortDescription = vm.ShortDescription,
                    Description = vm.Description,
                    WarrantyMonths = vm.WarrantyMonths,
                    IsFeatured = vm.IsFeatured,
                    IsActive = vm.IsActive,
                    CreatedAt = DateTime.UtcNow
                };

                if (vm.ThumbnailImage != null)
                {
                    product.ThumbnailUrl = await SaveImage(vm.ThumbnailImage);
                }
                else
                {
                    product.ThumbnailUrl = vm.ThumbnailUrl;
                }

                _context.Add(product);
                await _context.SaveChangesAsync();

                if (vm.MoreImages != null && vm.MoreImages.Any())
                {
                    foreach (var file in vm.MoreImages)
                    {
                        var url = await SaveImage(file);
                        _context.ProductImages.Add(new ProductImage
                        {
                            ProductId = product.Id,
                            ImageUrl = url,
                            SortOrder = 0
                        });
                    }
                    await _context.SaveChangesAsync();
                }

                return RedirectToAction(nameof(Index));
            }
            await LoadDropdowns();
            return View(vm);
        }

        public async Task<IActionResult> Edit(int id)
        {
            var p = await _context.Products
                .Include(x => x.ProductImages)
                .FirstOrDefaultAsync(x => x.Id == id);
            
            if (p == null) return NotFound();

            var vm = new ProductActionViewModel
            {
                Id = p.Id,
                SKU = p.SKU,
                Name = p.Name,
                Slug = p.Slug,
                CategoryId = p.CategoryId,
                BrandId = p.BrandId,
                Price = p.Price,
                DiscountPrice = p.DiscountPrice,
                StockQuantity = p.StockQuantity,
                ShortDescription = p.ShortDescription,
                Description = p.Description,
                WarrantyMonths = p.WarrantyMonths,
                IsFeatured = p.IsFeatured,
                IsActive = p.IsActive,
                ThumbnailUrl = p.ThumbnailUrl,
                ExistingImages = p.ProductImages.Select(x => x.ImageUrl).ToList()
            };

            await LoadDropdowns();
            return View(vm);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, ProductActionViewModel vm)
        {
            if (id != vm.Id) return NotFound();

            if (ModelState.IsValid)
            {
                var p = await _context.Products.FindAsync(id);
                if (p == null) return NotFound();

                p.SKU = vm.SKU;
                p.Name = vm.Name;
                p.Slug = vm.Slug;
                p.CategoryId = vm.CategoryId;
                p.BrandId = vm.BrandId;
                p.Price = vm.Price;
                p.DiscountPrice = vm.DiscountPrice;
                p.StockQuantity = vm.StockQuantity;
                p.ShortDescription = vm.ShortDescription;
                p.Description = vm.Description;
                p.WarrantyMonths = vm.WarrantyMonths;
                p.IsFeatured = vm.IsFeatured;
                p.IsActive = vm.IsActive;
                p.UpdatedAt = DateTime.UtcNow;

                if (vm.ThumbnailImage != null)
                {
                    p.ThumbnailUrl = await SaveImage(vm.ThumbnailImage);
                }
                else if (!string.IsNullOrEmpty(vm.ThumbnailUrl))
                {
                    p.ThumbnailUrl = vm.ThumbnailUrl;
                }

                _context.Update(p);
                await _context.SaveChangesAsync();

                if (vm.MoreImages != null && vm.MoreImages.Any())
                {
                    foreach (var file in vm.MoreImages)
                    {
                        var url = await SaveImage(file);
                        _context.ProductImages.Add(new ProductImage { ProductId = p.Id, ImageUrl = url });
                    }
                    await _context.SaveChangesAsync();
                }

                return RedirectToAction(nameof(Index));
            }
            await LoadDropdowns();
            return View(vm);
        }

        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var p = await _context.Products
                    .Include(x => x.ProductImages)
                    .Include(x => x.ProductSpecifications)
                    .FirstOrDefaultAsync(x => x.Id == id);

                if (p == null) 
                    return Json(new { success = false, message = "Không tìm thấy sản phẩm." });

                // Check if product is in any order
                var isInOrder = await _context.OrderItems.AnyAsync(oi => oi.ProductId == id);
                if (isInOrder)
                {
                    return Json(new { 
                        success = false, 
                        message = "Sản phẩm này đã có trong đơn hàng. Bạn nên 'Ẩn' sản phẩm thay vì xóa để giữ lại lịch sử đơn hàng cho khách." 
                    });
                }

                // Check if product is in any cart
                var isInCart = await _context.CartItems.AnyAsync(ci => ci.ProductId == id);
                if (isInCart)
                {
                    // Optionally we can remove it from carts or prevent delete
                    var cartItems = _context.CartItems.Where(ci => ci.ProductId == id);
                    _context.CartItems.RemoveRange(cartItems);
                }

                // Remove images and specs first
                if (p.ProductImages != null) _context.ProductImages.RemoveRange(p.ProductImages);
                if (p.ProductSpecifications != null) _context.ProductSpecifications.RemoveRange(p.ProductSpecifications);

                _context.Products.Remove(p);
                await _context.SaveChangesAsync();
                
                return Json(new { success = true, message = "Xóa sản phẩm thành công!" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "Lỗi hệ thống: " + ex.Message });
            }
        }

        private async Task LoadDropdowns()
        {
            ViewBag.Categories = await _context.Categories.ToListAsync();
            ViewBag.Brands = await _context.Brands.ToListAsync();
        }

        private async Task<string> SaveImage(IFormFile file)
        {
            string uploadsFolder = Path.Combine(_hostingEnvironment.WebRootPath, "uploads", "products");
            if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);
            
            string uniqueFileName = Guid.NewGuid().ToString() + "_" + file.FileName;
            string filePath = Path.Combine(uploadsFolder, uniqueFileName);
            
            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(fileStream);
            }
            
            return "/uploads/products/" + uniqueFileName;
        }
    }
}

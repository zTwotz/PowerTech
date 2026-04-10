using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Constants;
using PowerTech.Data;
using PowerTech.Models.Entities;

namespace PowerTech.Areas.Admin.Controllers
{
    [Area("Admin")]
    [Authorize(Roles = UserRoles.Admin + "," + UserRoles.WarehouseStaff)]
    public class BrandController : Controller
    {
        private readonly ApplicationDbContext _context;

        public BrandController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Admin/Brand
        public async Task<IActionResult> Index()
        {
            var brands = await _context.Brands
                .OrderByDescending(b => b.CreatedAt)
                .ToListAsync();
            return View(brands);
        }

        // GET: Admin/Brand/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Admin/Brand/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Brand brand)
        {
            if (ModelState.IsValid)
            {
                // Simple slug generation
                brand.Slug = brand.Name.ToLower().Replace(" ", "-");
                brand.CreatedAt = DateTime.UtcNow;
                brand.IsActive = true;

                _context.Add(brand);
                await _context.SaveChangesAsync();
                TempData["Success"] = "Thêm thương hiệu mới thành công!";
                return RedirectToAction(nameof(Index));
            }
            return View(brand);
        }

        // GET: Admin/Brand/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null) return NotFound();

            var brand = await _context.Brands.FindAsync(id);
            if (brand == null) return NotFound();

            return View(brand);
        }

        // POST: Admin/Brand/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, Brand brand)
        {
            if (id != brand.Id) return NotFound();

            if (ModelState.IsValid)
            {
                try
                {
                    brand.Slug = brand.Name.ToLower().Replace(" ", "-");
                    brand.UpdatedAt = DateTime.UtcNow;
                    _context.Update(brand);
                    await _context.SaveChangesAsync();
                    TempData["Success"] = "Cập nhật thương hiệu thành công!";
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!BrandExists(brand.Id)) return NotFound();
                    else throw;
                }
                return RedirectToAction(nameof(Index));
            }
            return View(brand);
        }

        // POST: Admin/Brand/Delete/5
        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            var brand = await _context.Brands.FindAsync(id);
            if (brand == null) return Json(new { success = false, message = "Không tìm thấy thương hiệu." });

            // Check if brand has products
            var hasProducts = await _context.Products.AnyAsync(p => p.BrandId == id);
            if (hasProducts)
            {
                return Json(new { success = false, message = "Không thể xóa vì thương hiệu này đang có sản phẩm." });
            }

            _context.Brands.Remove(brand);
            await _context.SaveChangesAsync();
            return Json(new { success = true, message = "Xóa thương hiệu thành công!" });
        }

        private bool BrandExists(int id)
        {
            return _context.Brands.Any(e => e.Id == id);
        }
    }
}

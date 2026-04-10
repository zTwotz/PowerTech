using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Constants;
using PowerTech.Data;
using PowerTech.Models.Entities;

namespace PowerTech.Areas.Sales.Controllers
{
    [Area("Sales")]
    [Authorize(Roles = UserRoles.SalesStaff + "," + UserRoles.Admin)]
    public class CouponsController(ApplicationDbContext context) : Controller
    {
        public async Task<IActionResult> Index()
        {
            var coupons = await context.Coupons
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();
            return View(coupons);
        }

        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Coupon coupon)
        {
            if (ModelState.IsValid)
            {
                // Check if code already exists
                if (await context.Coupons.AnyAsync(c => c.Code == coupon.Code))
                {
                    ModelState.AddModelError("Code", "Mã giảm giá đã tồn tại.");
                    return View(coupon);
                }

                coupon.CreatedAt = DateTime.UtcNow;
                context.Add(coupon);
                await context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            return View(coupon);
        }

        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null) return NotFound();

            var coupon = await context.Coupons.FindAsync(id);
            if (coupon == null) return NotFound();

            return View(coupon);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, Coupon coupon)
        {
            if (id != coupon.Id) return NotFound();

            if (ModelState.IsValid)
            {
                try
                {
                    var existingCoupon = await context.Coupons.FindAsync(id);
                    if (existingCoupon == null) return NotFound();

                    // Update properties
                    existingCoupon.Code = coupon.Code;
                    existingCoupon.Type = coupon.Type;
                    existingCoupon.Value = coupon.Value;
                    existingCoupon.MinOrderValue = coupon.MinOrderValue;
                    existingCoupon.MaxDiscountAmount = coupon.MaxDiscountAmount;
                    existingCoupon.StartDate = coupon.StartDate;
                    existingCoupon.EndDate = coupon.EndDate;
                    existingCoupon.UsageLimit = coupon.UsageLimit;
                    existingCoupon.IsActive = coupon.IsActive;
                    existingCoupon.UpdatedAt = DateTime.UtcNow;

                    context.Update(existingCoupon);
                    await context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!await context.Coupons.AnyAsync(e => e.Id == coupon.Id))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            return View(coupon);
        }

        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null) return NotFound();

            var coupon = await context.Coupons.FindAsync(id);
            if (coupon == null) return NotFound();

            return View(coupon);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var coupon = await context.Coupons.FindAsync(id);
            if (coupon != null)
            {
                // check if coupon is used in any order
                var usedInOrders = await context.Orders.AnyAsync(o => o.CouponId == id);
                if (usedInOrders)
                {
                    TempData["Error"] = "Không thể xóa mã giảm giá đã được sử dụng trong đơn hàng.";
                    return RedirectToAction(nameof(Index));
                }

                context.Coupons.Remove(coupon);
                await context.SaveChangesAsync();
            }
            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        public async Task<IActionResult> ToggleStatus(int id)
        {
            var coupon = await context.Coupons.FindAsync(id);
            if (coupon == null) return NotFound();

            coupon.IsActive = !coupon.IsActive;
            coupon.UpdatedAt = DateTime.UtcNow;
            await context.SaveChangesAsync();

            return Json(new { success = true, isActive = coupon.IsActive });
        }
    }
}

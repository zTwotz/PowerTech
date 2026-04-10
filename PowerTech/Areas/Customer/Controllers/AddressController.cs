using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Models.Entities;

namespace PowerTech.Areas.Customer.Controllers
{
    [Area("Customer")]
    [Authorize]
    public class AddressController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;

        public AddressController(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        public async Task<IActionResult> Index()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            var addresses = await _context.UserAddresses
                .Where(a => a.UserId == user.Id)
                .OrderByDescending(a => a.IsDefault)
                .ThenByDescending(a => a.CreatedAt)
                .ToListAsync();

            return View(addresses);
        }

        [HttpPost]
        public async Task<IActionResult> Create(UserAddress model)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            // If this is the first address, make it default
            var existingCount = await _context.UserAddresses.CountAsync(a => a.UserId == user.Id);
            if (existingCount == 0)
            {
                model.IsDefault = true;
            }
            else if (model.IsDefault)
            {
                // Unset other defaults
                var defaultAddress = await _context.UserAddresses
                    .FirstOrDefaultAsync(a => a.UserId == user.Id && a.IsDefault);
                if (defaultAddress != null)
                {
                    defaultAddress.IsDefault = false;
                }
            }

            model.UserId = user.Id;
            model.CreatedAt = DateTime.UtcNow;

            _context.UserAddresses.Add(model);
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = "Thêm địa chỉ mới thành công!";
            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        public async Task<IActionResult> SetDefault(int id)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            var address = await _context.UserAddresses
                .FirstOrDefaultAsync(a => a.Id == id && a.UserId == user.Id);

            if (address == null) return NotFound();

            // Unset current default
            var currentDefault = await _context.UserAddresses
                .FirstOrDefaultAsync(a => a.UserId == user.Id && a.IsDefault);
            if (currentDefault != null)
            {
                currentDefault.IsDefault = false;
            }

            address.IsDefault = true;
            address.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = "Đã đặt địa chỉ mặc định thành công!";
            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            var address = await _context.UserAddresses
                .FirstOrDefaultAsync(a => a.Id == id && a.UserId == user.Id);

            if (address == null) return NotFound();

            if (address.IsDefault)
            {
                TempData["ErrorMessage"] = "Không thể xóa địa chỉ mặc định!";
                return RedirectToAction(nameof(Index));
            }

            _context.UserAddresses.Remove(address);
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = "Đã xóa địa chỉ thành công!";
            return RedirectToAction(nameof(Index));
        }
    }
}

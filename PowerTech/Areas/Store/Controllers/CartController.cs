using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PowerTech.Models.Entities;
using PowerTech.Services.Interfaces;

namespace PowerTech.Areas.Store.Controllers
{
    [Area("Store")]
    public class CartController : Controller
    {
        private readonly ICartService _cartService;
        private readonly UserManager<ApplicationUser> _userManager;

        public CartController(ICartService cartService, UserManager<ApplicationUser> userManager)
        {
            _cartService = cartService;
            _userManager = userManager;
        }

        public async Task<IActionResult> Index()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return RedirectToPage("/Account/Login", new { area = "Identity", returnUrl = "/Store/Cart" });
            }

            var cart = await _cartService.GetCartAsync(user.Id);
            return View(cart);
        }

        [HttpPost]
        public async Task<IActionResult> Add(int productId, int quantity = 1)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return Json(new { success = false, message = "Vui lòng đăng nhập để thêm vào giỏ hàng." });
            }

            var count = await _cartService.AddToCartAsync(user.Id, productId, quantity);
            return Json(new { success = true, count = count, message = "Đã thêm vào giỏ hàng thành công!" });
        }

        [HttpPost]
        public async Task<IActionResult> UpdateQuantity(int productId, int quantity)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            var success = await _cartService.UpdateQuantityAsync(user.Id, productId, quantity);
            var cart = await _cartService.GetCartAsync(user.Id);
            
            return Json(new { 
                success = success, 
                total = cart.CartItems.Sum(ci => ci.Quantity * ci.UnitPrice).ToString("N0") + "₫",
                itemTotal = cart.CartItems.FirstOrDefault(ci => ci.ProductId == productId)?.Quantity * cart.CartItems.FirstOrDefault(ci => ci.ProductId == productId)?.UnitPrice
            });
        }

        [HttpPost]
        public async Task<IActionResult> Remove(int productId)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            var success = await _cartService.RemoveFromCartAsync(user.Id, productId);
            return Json(new { success = success });
        }

        [HttpGet]
        public async Task<IActionResult> GetCartCount()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Json(0);

            var count = await _cartService.GetCartItemCountAsync(user.Id);
            return Json(count);
        }
    }
}

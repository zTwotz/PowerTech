using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PowerTech.Data;
using PowerTech.Models.Entities;
using PowerTech.Services.Interfaces;

namespace PowerTech.Areas.Store.Controllers
{
    [Area("Store")]
    [Authorize]
    public class CheckoutController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly ICartService _cartService;
        private readonly UserManager<ApplicationUser> _userManager;

        public CheckoutController(ApplicationDbContext context, ICartService cartService, UserManager<ApplicationUser> userManager)
        {
            _context = context;
            _cartService = cartService;
            _userManager = userManager;
        }

        public async Task<IActionResult> Index()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();
            var cart = await _cartService.GetCartAsync(user.Id);

            if (cart.CartItems == null || !cart.CartItems.Any())
            {
                return RedirectToAction("Index", "Cart");
            }

            var addresses = await _context.UserAddresses
                .Where(a => a.UserId == user.Id)
                .ToListAsync();

            ViewBag.Cart = cart;
            return View(addresses);
        }

        [HttpPost]
        public IActionResult UpdateAddress(int addressId)
        {
            // Placeholder: logic to select an address for this checkout session (e.g. TempData or separate Checkout entity)
            TempData["SelectedAddressId"] = addressId;
            return RedirectToAction("Payment");
        }

        public async Task<IActionResult> Payment()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();
            var cart = await _cartService.GetCartAsync(user.Id);
            
            var addressId = TempData.Peek("SelectedAddressId");
            if (addressId == null) return RedirectToAction("Index");
            
            ViewBag.Cart = cart;
            ViewBag.Address = await _context.UserAddresses.FindAsync(addressId);
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> PlaceOrder(string paymentMethod, string note)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();
            var cart = await _cartService.GetCartAsync(user.Id);
            var addressId = (int?)TempData["SelectedAddressId"];

            if (addressId == null || cart.CartItems == null || !cart.CartItems.Any()) 
                return RedirectToAction("Index");

            var address = await _context.UserAddresses.FindAsync(addressId);
            if (address == null) return RedirectToAction("Index");

            var totalAmount = cart.CartItems.Sum(ci => ci.Quantity * ci.UnitPrice);

            // Create Order
            var order = new Order
            {
                OrderCode = $"PT-{DateTime.Now:yyyyMMdd}-{new Random().Next(1000, 9999)}",
                UserId = user.Id,
                ReceiverName = address.ReceiverName,
                PhoneNumber = address.PhoneNumber,
                ShippingAddress = $"{address.StreetAddress}, {address.Ward}, {address.District}, {address.Province}",
                OrderStatus = "Pending",
                PaymentStatus = "Unpaid",
                PaymentMethod = paymentMethod ?? "COD",
                Subtotal = totalAmount,
                ShippingFee = 0, // Placeholder
                DiscountAmount = 0,
                TotalAmount = totalAmount,
                Note = note,
                CreatedAt = DateTime.UtcNow
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            foreach (var item in cart.CartItems)
            {
                var orderItem = new OrderItem
                {
                    OrderId = order.Id,
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    UnitPrice = item.UnitPrice,
                    LineTotal = item.Quantity * item.UnitPrice,
                    ProductNameSnapshot = item.Product.Name,
                    ProductSkuSnapshot = item.Product.SKU,
                    ProductImageSnapshot = item.Product.ThumbnailUrl
                };
                _context.OrderItems.Add(orderItem);
            }

            // Clear Cart
            await _cartService.ClearCartAsync(user.Id);
            await _context.SaveChangesAsync();

            return RedirectToAction("Confirmation", new { orderId = order.Id });
        }

        [HttpGet]
        public IActionResult AddAddress()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> AddAddress(UserAddress address)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            address.UserId = user.Id;
            address.CreatedAt = DateTime.UtcNow;
            
            // If the user has no addresses, make this one the default
            var hasAnyAddress = await _context.UserAddresses.AnyAsync(a => a.UserId == user.Id);
            if (!hasAnyAddress)
            {
                address.IsDefault = true;
            }

            _context.UserAddresses.Add(address);
            await _context.SaveChangesAsync();

            TempData["SelectedAddressId"] = address.Id;
            return RedirectToAction("Payment");
        }

        public async Task<IActionResult> Confirmation(int orderId)
        {
            var order = await _context.Orders
                .Include(o => o.OrderItems)
                    .ThenInclude(oi => oi.Product)
                .FirstOrDefaultAsync(o => o.Id == orderId);
                
            return View(order);
        }
    }
}

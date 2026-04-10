using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PowerTech.Data;
using PowerTech.Models.Entities;
using Microsoft.EntityFrameworkCore;

namespace PowerTech.Areas.Customer.Controllers
{
    [Area("Customer")]
    [Authorize]
    public class ReviewController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IWebHostEnvironment _hostEnvironment;

        public ReviewController(ApplicationDbContext context, UserManager<ApplicationUser> userManager, IWebHostEnvironment hostEnvironment)
        {
            _context = context;
            _userManager = userManager;
            _hostEnvironment = hostEnvironment;
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(int productId, int orderId, byte rating, string comment, List<IFormFile> images)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null) return Unauthorized();

            // 1. Verify user purchased the product and order is completed
            var hasPurchased = await _context.Orders
                .Include(o => o.OrderItems)
                .AnyAsync(o => o.UserId == user.Id && o.OrderStatus == "Completed" && o.OrderItems.Any(oi => oi.ProductId == productId));

            if (!hasPurchased)
            {
                TempData["ErrorMessage"] = "Bạn chỉ có thể đánh giá sản phẩm sau khi đã nhận được hàng!";
                return RedirectToAction("Detail", "Order", new { id = orderId });
            }

            // 2. Verify user hasn't reviewed this product before
            var existingReview = await _context.Reviews
                .AnyAsync(r => r.UserId == user.Id && r.ProductId == productId);

            if (existingReview)
            {
                TempData["ErrorMessage"] = "Bạn đã đánh giá sản phẩm này rồi!";
                return RedirectToAction("Detail", "Order", new { id = orderId });
            }

            // 3. Create Review
            var review = new Review
            {
                ProductId = productId,
                UserId = user.Id,
                Rating = rating,
                Comment = comment,
                IsApproved = false, // Require moderation
                CreatedAt = DateTime.UtcNow
            };

            _context.Reviews.Add(review);
            await _context.SaveChangesAsync();

            // 4. Handle Images
            if (images != null && images.Count > 0)
            {
                string uploadDir = Path.Combine(_hostEnvironment.WebRootPath, "uploads", "reviews");
                if (!Directory.Exists(uploadDir)) Directory.CreateDirectory(uploadDir);

                foreach (var file in images.Take(3)) // Max 3 images
                {
                    string fileName = Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);
                    string filePath = Path.Combine(uploadDir, fileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await file.CopyToAsync(stream);
                    }

                    var reviewImage = new ReviewImage
                    {
                        ReviewId = review.Id,
                        ImageUrl = "/uploads/reviews/" + fileName
                    };
                    _context.ReviewImages.Add(reviewImage);
                }
                await _context.SaveChangesAsync();
            }

            TempData["SuccessMessage"] = "Cảm ơn bạn đã gửi đánh giá! Đánh giá của bạn sẽ được hiển thị sau khi được phê duyệt.";
            return RedirectToAction("Detail", "Order", new { id = orderId });
        }
    }
}

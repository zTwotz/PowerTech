using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using PowerTech.Models.Entities;

namespace PowerTech.Areas.Identity.Pages.Account
{
    public class LogoutModel : PageModel
    {
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly ILogger<LogoutModel> _logger;

        public LogoutModel(SignInManager<ApplicationUser> signInManager, ILogger<LogoutModel> logger)
        {
            _signInManager = signInManager;
            _logger = logger;
        }

        public async Task<IActionResult> OnPost(string? returnUrl = null)
        {
            await _signInManager.SignOutAsync();
            _logger.LogInformation("User logged out.");

            // Clear the cart count cookie on logout
            Response.Cookies.Delete("PT_CartCount");
            // Also delete Guest Cart ID just in case to start fresh or keep it? 
            // Usually, we want a fresh start for a new person, but a guest ID might be needed for a new guest session.
            // But let's at least clear the count so it doesn't show the previous user's items.
            Response.Cookies.Delete("PT_GuestCartId");

            if (returnUrl != null)
            {
                return LocalRedirect(returnUrl);
            }
            else
            {
                // This needs to be a redirect so that the browser performs a new request and the identity cookie is revoked
                return RedirectToPage();
            }
        }
    }
}

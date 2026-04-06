using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PowerTech.Constants;

namespace PowerTech.Areas.Customer.Controllers
{
    [Area("Customer")]
    [Authorize(Roles = UserRoles.Admin + "," + UserRoles.Customer)]
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}

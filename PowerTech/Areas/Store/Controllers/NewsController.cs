using Microsoft.AspNetCore.Mvc;

namespace PowerTech.Areas.Store.Controllers
{
    [Area("Store")]
    public class NewsController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Detail(string slug)
        {
            ViewBag.Slug = slug;
            return View();
        }
    }
}

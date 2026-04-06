using PowerTech.Models.Entities;

namespace PowerTech.Models.ViewModels.Store
{
    public class HomeViewModel
    {
        public List<Category> FeaturedCategories { get; set; } = new List<Category>();
        public List<Product> FeaturedProducts { get; set; } = new List<Product>();
        public List<Product> NewProducts { get; set; } = new List<Product>();
        public List<Product> DiscountProducts { get; set; } = new List<Product>();
    }
}

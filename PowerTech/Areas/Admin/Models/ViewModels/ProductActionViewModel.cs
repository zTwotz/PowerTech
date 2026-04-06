using Microsoft.AspNetCore.Http;
using PowerTech.Models.Entities;
using System.ComponentModel.DataAnnotations;

namespace PowerTech.Areas.Admin.Models.ViewModels
{
    public class ProductActionViewModel
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập SKU")]
        public string SKU { get; set; } = string.Empty;

        [Required(ErrorMessage = "Vui lòng nhập tên sản phẩm")]
        public string Name { get; set; } = string.Empty;

        [Required(ErrorMessage = "Vui lòng nhập Slug")]
        public string Slug { get; set; } = string.Empty;

        [Required(ErrorMessage = "Vui lòng chọn danh mục")]
        public int CategoryId { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn thương hiệu")]
        public int BrandId { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập giá")]
        [Range(0, double.MaxValue, ErrorMessage = "Giá không hợp lệ")]
        public decimal Price { get; set; }

        public decimal? DiscountPrice { get; set; }

        public int StockQuantity { get; set; } = 0;

        public string? ShortDescription { get; set; }

        public string? Description { get; set; }

        public int WarrantyMonths { get; set; } = 12;

        public bool IsFeatured { get; set; } = false;

        public bool IsActive { get; set; } = true;

        public string? ThumbnailUrl { get; set; }
        
        public IFormFile? ThumbnailImage { get; set; }
        
        public List<IFormFile>? MoreImages { get; set; }
        
        public List<string>? ExistingImages { get; set; }
    }
}

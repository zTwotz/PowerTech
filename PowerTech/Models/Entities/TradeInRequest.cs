using System;
using System.Collections.Generic;
using PowerTech.Models.Entities;

namespace PowerTech.Models.Entities
{
    public class TradeInRequest
    {
        public int Id { get; set; }
        public string? UserId { get; set; }
        public ApplicationUser? User { get; set; }
        
        public int CategoryId { get; set; }
        public Category Category { get; set; } = null!;
        
        public int? BrandId { get; set; }
        public Brand? Brand { get; set; }
        
        public string? OtherBrandName { get; set; }
        public string ModelName { get; set; } = string.Empty;
        public string Condition { get; set; } = string.Empty; // Loai 1, 2, 3
        
        public string Status { get; set; } = "Pending";
        public decimal? QuotedPrice { get; set; }
        
        public string ContactName { get; set; } = string.Empty;
        public string ContactPhone { get; set; } = string.Empty;
        public string ContactEmail { get; set; } = string.Empty;
        
        public string? Note { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public ICollection<TradeInRequestImage> Images { get; set; } = new List<TradeInRequestImage>();
    }

    public class TradeInRequestImage
    {
        public int Id { get; set; }
        public int TradeInRequestId { get; set; }
        public TradeInRequest TradeInRequest { get; set; } = null!;
        public string ImageUrl { get; set; } = string.Empty;
    }
}

using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PowerTech.Models.Entities;

public class ProductImage
{
    public int Id { get; set; }

    [Required]
    public int ProductId { get; set; }

    [Required]
    public required string ImageUrl { get; set; }

    public string? AltText { get; set; }

    public bool IsPrimary { get; set; } = false;

    public int SortOrder { get; set; } = 0;

    [Required]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation Properties
    [ForeignKey(nameof(ProductId))]
    public virtual Product Product { get; set; } = null!;
}

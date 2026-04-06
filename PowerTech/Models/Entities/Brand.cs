using System.ComponentModel.DataAnnotations;

namespace PowerTech.Models.Entities;

public class Brand
{
    public int Id { get; set; }

    [Required]
    [StringLength(100)]
    public required string Name { get; set; }

    [Required]
    [StringLength(100)]
    public required string Slug { get; set; }

    public string? Description { get; set; }

    [StringLength(100)]
    public string? Country { get; set; }

    public string? LogoUrl { get; set; }

    public bool IsActive { get; set; } = true;

    [Required]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    // Navigation Properties
    public virtual ICollection<Product> Products { get; set; } = new List<Product>();
}

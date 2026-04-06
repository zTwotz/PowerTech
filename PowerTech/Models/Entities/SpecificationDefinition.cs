using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PowerTech.Models.Entities;

public class SpecificationDefinition
{
    public int Id { get; set; }

    [Required]
    public int CategoryId { get; set; }

    [Required]
    [StringLength(100)]
    public required string SpecName { get; set; }

    [StringLength(100)]
    public string? DisplayName { get; set; }

    /// <summary>
    /// logic values: text, number, boolean
    /// </summary>
    [Required]
    [StringLength(20)]
    public required string DataType { get; set; }

    [StringLength(50)]
    public string? Unit { get; set; }

    [StringLength(100)]
    public string? GroupName { get; set; }

    public int SortOrder { get; set; } = 0;

    public bool IsFilterable { get; set; } = false;

    public bool IsRequired { get; set; } = false;

    public bool IsActive { get; set; } = true;

    [Required]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation Properties
    [ForeignKey(nameof(CategoryId))]
    public virtual Category Category { get; set; } = null!;

    public virtual ICollection<ProductSpecification> ProductSpecifications { get; set; } = new List<ProductSpecification>();
}

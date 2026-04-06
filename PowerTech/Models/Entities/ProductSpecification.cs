using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PowerTech.Models.Entities;

public class ProductSpecification
{
    public int Id { get; set; }

    [Required]
    public int ProductId { get; set; }

    [Required]
    public int SpecDefinitionId { get; set; }

    public string? ValueText { get; set; }

    [Column(TypeName = "decimal(18,4)")]
    public decimal? ValueNumber { get; set; }

    public bool? ValueBoolean { get; set; }

    public string? DisplayValue { get; set; }

    [Required]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation Properties
    [ForeignKey(nameof(ProductId))]
    public virtual Product Product { get; set; } = null!;

    [ForeignKey(nameof(SpecDefinitionId))]
    public virtual SpecificationDefinition SpecificationDefinition { get; set; } = null!;
}

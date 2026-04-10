using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PowerTech.Models.Entities
{
    public class ReviewImage
    {
        [Key]
        public int Id { get; set; }

        public int ReviewId { get; set; }

        [Required]
        public string ImageUrl { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(ReviewId))]
        public virtual Review Review { get; set; } = null!;
    }
}

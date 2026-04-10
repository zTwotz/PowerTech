using System.ComponentModel.DataAnnotations;

namespace PowerTech.Models.Entities
{
    public class FaqCategory
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;

        public int DisplayOrder { get; set; } = 0;

        public virtual ICollection<FaqArticle> Articles { get; set; } = new List<FaqArticle>();
    }
}

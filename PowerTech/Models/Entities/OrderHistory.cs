using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PowerTech.Models.Entities
{
    [Table("OrderHistory")]
    public class OrderHistory
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int OrderId { get; set; }

        [ForeignKey("OrderId")]
        public virtual Order Order { get; set; } = null!;

        [Required]
        [StringLength(50)]
        public string Status { get; set; } = null!;

        [StringLength(1000)]
        public string Note { get; set; } = null!;

        [StringLength(100)]
        public string Action { get; set; } = null!;

        [StringLength(250)]
        public string PerformedBy { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}

using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PowerTech.Models.Entities
{
    public class SupportTicket
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [StringLength(50)]
        public string TicketCode { get; set; } = string.Empty;

        [Required]
        public string UserId { get; set; } = string.Empty;

        public int? OrderId { get; set; }

        [Required]
        [StringLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string Content { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string Status { get; set; } = "Open";

        [Required]
        [StringLength(50)]
        public string Priority { get; set; } = "Medium";

        public string? AssignedToUserId { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        public DateTime? ClosedAt { get; set; }

        public string? AttachmentUrl { get; set; }

        public int? Rating { get; set; }

        [StringLength(500)]
        public string? Feedback { get; set; }

        // Navigation Properties
        [ForeignKey(nameof(UserId))]
        public virtual ApplicationUser User { get; set; } = null!;

        [ForeignKey(nameof(OrderId))]
        public virtual Order? Order { get; set; }

        [ForeignKey(nameof(AssignedToUserId))]
        public virtual ApplicationUser? AssignedTo { get; set; }

        public virtual ICollection<TicketResponse> Responses { get; set; } = new List<TicketResponse>();
    }
}

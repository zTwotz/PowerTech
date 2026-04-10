using PowerTech.Models.Entities;

namespace PowerTech.Models.ViewModels
{
    public class CustomerProfileViewModel
    {
        public ApplicationUser User { get; set; } = null!;
        public string? CurrentPassword { get; set; }
        public string? NewPassword { get; set; }
        public string? ConfirmPassword { get; set; }
        public List<Notification> Notifications { get; set; } = new List<Notification>();
        public string ActiveTab { get; set; } = "profile"; // "profile", "password", "notifications"
    }
}

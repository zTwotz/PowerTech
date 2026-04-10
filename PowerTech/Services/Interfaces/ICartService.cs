using PowerTech.Models.Entities;

namespace PowerTech.Services.Interfaces
{
    public interface ICartService
    {
        Task<Cart> GetCartAsync(string userId);
        Task<int> AddToCartAsync(string userId, int productId, int quantity);
        Task<bool> RemoveFromCartAsync(string userId, int productId);
        Task<bool> UpdateQuantityAsync(string userId, int productId, int quantity);
        Task<bool> ClearCartAsync(string userId);
        Task<int> GetCartItemCountAsync(string userId);
        Task<decimal> GetCartTotalAsync(string userId);
        Task<int> MergeCartAsync(string guestId, string userId);
    }
}

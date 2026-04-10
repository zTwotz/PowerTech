using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace PowerTech.Hubs
{
    public class SupportHub : Hub
    {
        // Join a group specific to the ticket ID to receive messages for that ticket
        public async Task JoinTicketGroup(string ticketId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"Ticket_{ticketId}");
        }

        // Leave the ticket group when closing the page
        public async Task LeaveTicketGroup(string ticketId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"Ticket_{ticketId}");
        }
    }
}

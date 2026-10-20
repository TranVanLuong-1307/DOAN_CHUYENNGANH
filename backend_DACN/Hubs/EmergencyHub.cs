using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;

namespace backend_DACN.Hubs
{
    [Authorize]
    public class EmergencyHub : Hub
    {
        private readonly ILogger<EmergencyHub> _logger;

        public EmergencyHub(ILogger<EmergencyHub> logger)
        {
            _logger = logger;
        }

        public override async Task OnConnectedAsync()
        {
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userId))
            {
                var groupName = $"user_{userId}";
                await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
                _logger.LogInformation("SignalR: Client {ConnectionId} tự động kết nối vào nhóm {GroupName}", Context.ConnectionId, groupName);
            }
            else
            {
                _logger.LogWarning("SignalR: Client {ConnectionId} kết nối nhưng không tìm thấy Claim UserId", Context.ConnectionId);
            }

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userId))
            {
                var groupName = $"user_{userId}";
                await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
                _logger.LogInformation("SignalR: Client {ConnectionId} ngắt kết nối khỏi nhóm {GroupName}", Context.ConnectionId, groupName);
            }

            await base.OnDisconnectedAsync(exception);
        }

        /// <summary>
        /// Cho phép Client Flutter chủ động tham gia nhóm nhận cảnh báo theo UserId
        /// </summary>
        /// <param name="userId">Mã định danh người dùng</param>
        public async Task JoinPersonalGroup(string userId)
        {
            if (string.IsNullOrWhiteSpace(userId))
            {
                throw new HubException("UserId không được để trống khi tham gia nhóm cảnh báo");
            }

            var groupName = $"user_{userId}";
            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
            _logger.LogInformation("SignalR: Connection {ConnectionId} chủ động tham gia nhóm {GroupName}", Context.ConnectionId, groupName);

            await Clients.Caller.SendAsync("JoinedGroupSuccess", new
            {
                Group = groupName,
                Message = $"Đã tham gia kênh cảnh báo khẩn cấp cá nhân thành công: {groupName}",
                JoinedAt = DateTime.UtcNow
            });
        }

        /// <summary>
        /// Cho phép Client Flutter rời khỏi nhóm nhận cảnh báo
        /// </summary>
        /// <param name="userId">Mã định danh người dùng</param>
        public async Task LeavePersonalGroup(string userId)
        {
            if (string.IsNullOrWhiteSpace(userId))
            {
                return;
            }

            var groupName = $"user_{userId}";
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
            _logger.LogInformation("SignalR: Connection {ConnectionId} rời khỏi nhóm {GroupName}", Context.ConnectionId, groupName);
        }
    }
}

using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using backend_DACN.Data;
using backend_DACN.DTOs;

namespace backend_DACN.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class AlertsController : ControllerBase
    {
        private readonly ApplicationDbContext _dbContext;

        public AlertsController(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        /// <summary>
        /// Lấy danh sách cảnh báo khẩn cấp của người dùng với bộ lọc trạng thái và phân trang
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAlerts(
            [FromQuery] bool? isResolved,
            [FromQuery] string? severity,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 20)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize < 1) pageSize = 20;
            if (pageSize > 100) pageSize = 100;

            var userId = GetCurrentUserId();

            var query = _dbContext.EmergencyAlerts
                .AsNoTracking()
                .Where(a => a.UserId == userId);

            if (isResolved.HasValue)
            {
                query = query.Where(a => a.IsResolved == isResolved.Value);
            }

            if (!string.IsNullOrWhiteSpace(severity))
            {
                query = query.Where(a => a.Severity.ToLower() == severity.Trim().ToLower());
            }

            var totalCount = await query.CountAsync();

            var alerts = await query
                .OrderByDescending(a => a.CreatedAt)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .Select(a => new EmergencyAlertDto
                {
                    Id = a.Id,
                    UserId = a.UserId,
                    AlertType = a.AlertType,
                    TriggerValue = a.TriggerValue,
                    ThresholdValue = a.ThresholdValue,
                    Severity = a.Severity,
                    Recommendation = a.Recommendation,
                    IsResolved = a.IsResolved,
                    ResolvedAt = a.ResolvedAt,
                    CreatedAt = a.CreatedAt
                })
                .ToListAsync();

            return Ok(new
            {
                success = true,
                data = new PagedResultDto<EmergencyAlertDto>
                {
                    Items = alerts,
                    TotalCount = totalCount,
                    PageNumber = pageNumber,
                    PageSize = pageSize
                }
            });
        }

        /// <summary>
        /// Lấy chi tiết một cảnh báo theo mã định danh
        /// </summary>
        [HttpGet("{id}")]
        public async Task<IActionResult> GetAlertById(int id)
        {
            var userId = GetCurrentUserId();

            var alert = await _dbContext.EmergencyAlerts
                .AsNoTracking()
                .FirstOrDefaultAsync(a => a.Id == id && a.UserId == userId);

            if (alert == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy cảnh báo này hoặc bạn không có quyền truy cập." });
            }

            return Ok(new
            {
                success = true,
                data = new EmergencyAlertDto
                {
                    Id = alert.Id,
                    UserId = alert.UserId,
                    AlertType = alert.AlertType,
                    TriggerValue = alert.TriggerValue,
                    ThresholdValue = alert.ThresholdValue,
                    Severity = alert.Severity,
                    Recommendation = alert.Recommendation,
                    IsResolved = alert.IsResolved,
                    ResolvedAt = alert.ResolvedAt,
                    CreatedAt = alert.CreatedAt
                }
            });
        }

        /// <summary>
        /// Đánh dấu đã xử lý cảnh báo khẩn cấp (Người dùng đã an toàn hoặc đã được hỗ trợ y tế)
        /// </summary>
        [HttpPut("{id}/resolve")]
        public async Task<IActionResult> ResolveAlert(int id, [FromBody] ResolveAlertDto? dto)
        {
            var userId = GetCurrentUserId();

            var alert = await _dbContext.EmergencyAlerts
                .FirstOrDefaultAsync(a => a.Id == id && a.UserId == userId);

            if (alert == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy cảnh báo này hoặc bạn không có quyền thao tác." });
            }

            if (alert.IsResolved)
            {
                return BadRequest(new { success = false, message = "Cảnh báo này đã được đánh dấu xử lý trước đó." });
            }

            alert.IsResolved = true;
            alert.ResolvedAt = DateTime.UtcNow;

            await _dbContext.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Đã xác nhận xử lý cảnh báo thành công!",
                data = new EmergencyAlertDto
                {
                    Id = alert.Id,
                    UserId = alert.UserId,
                    AlertType = alert.AlertType,
                    TriggerValue = alert.TriggerValue,
                    ThresholdValue = alert.ThresholdValue,
                    Severity = alert.Severity,
                    Recommendation = alert.Recommendation,
                    IsResolved = alert.IsResolved,
                    ResolvedAt = alert.ResolvedAt,
                    CreatedAt = alert.CreatedAt
                }
            });
        }

        /// <summary>
        /// Đếm số lượng cảnh báo khẩn cấp đang chưa được xử lý (Active Alerts)
        /// </summary>
        [HttpGet("active-count")]
        public async Task<IActionResult> GetActiveAlertsCount()
        {
            var userId = GetCurrentUserId();

            var count = await _dbContext.EmergencyAlerts
                .AsNoTracking()
                .CountAsync(a => a.UserId == userId && !a.IsResolved);

            return Ok(new
            {
                success = true,
                activeAlertsCount = count
            });
        }

        private int GetCurrentUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(claim, out var userId))
            {
                return userId;
            }
            throw new UnauthorizedAccessException("Không xác định được danh tính người dùng từ Token.");
        }
    }
}

using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using backend_DACN.DTOs;
using backend_DACN.Services.Interfaces;

namespace backend_DACN.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class BiometricsController : ControllerBase
    {
        private readonly IBiometricService _biometricService;

        public BiometricsController(IBiometricService biometricService)
        {
            _biometricService = biometricService;
        }

        /// <summary>
        /// Gửi gói chỉ số sinh học mới từ Smartwatch/Flutter app lên Server.
        /// Hệ thống sẽ tự động phân tích qua Rule-based Engine và cảnh báo khẩn cấp nếu có bất thường.
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> AddBiometric([FromBody] CreateBiometricRecordDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var userId = GetCurrentUserId();
            var result = await _biometricService.AddBiometricRecordAsync(userId, dto);

            return CreatedAtAction(nameof(GetLatest), new { id = result.Id }, new
            {
                success = true,
                message = "Ghi nhận chỉ số sinh học thành công!",
                data = result
            });
        }

        /// <summary>
        /// Lấy lịch sử chỉ số sinh học có phân trang và lọc theo khoảng thời gian
        /// </summary>
        [HttpGet("history")]
        public async Task<IActionResult> GetHistory(
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 50)
        {
            var userId = GetCurrentUserId();
            var result = await _biometricService.GetHistoryAsync(userId, startDate, endDate, pageNumber, pageSize);

            return Ok(new
            {
                success = true,
                data = result
            });
        }

        /// <summary>
        /// Lấy dữ liệu tổng hợp theo từng khung giờ trong ngày (0h-23h) để ứng dụng Flutter vẽ biểu đồ nhịp tim & SpO2
        /// </summary>
        [HttpGet("chart")]
        public async Task<IActionResult> GetChartSummary([FromQuery] DateTime? date)
        {
            var userId = GetCurrentUserId();
            var targetDate = date ?? DateTime.UtcNow.Date;
            var result = await _biometricService.GetChartSummaryAsync(userId, targetDate);

            return Ok(new
            {
                success = true,
                data = result
            });
        }

        /// <summary>
        /// Lấy bản ghi chỉ số sinh học mới nhất của người dùng
        /// </summary>
        [HttpGet("latest")]
        public async Task<IActionResult> GetLatest()
        {
            var userId = GetCurrentUserId();
            var latest = await _biometricService.GetLatestBiometricAsync(userId);

            if (latest == null)
            {
                return NotFound(new { success = false, message = "Chưa có dữ liệu sinh học nào cho người dùng này." });
            }

            return Ok(new
            {
                success = true,
                data = latest
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

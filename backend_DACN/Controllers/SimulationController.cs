using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using backend_DACN.Data;
using backend_DACN.DTOs;
using backend_DACN.Models;
using backend_DACN.Services.Interfaces;

namespace backend_DACN.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SimulationController : ControllerBase
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly IAlertRuleEngine _alertRuleEngine;

        public SimulationController(ApplicationDbContext dbContext, IAlertRuleEngine alertRuleEngine)
        {
            _dbContext = dbContext;
            _alertRuleEngine = alertRuleEngine;
        }

        /// <summary>
        /// [DEMO BẢO VỆ ĐỒ ÁN] Sinh tự động 5 gói dữ liệu sinh học bình thường (HeartRate 72-78 bpm, SpO2 98-99%, Stress 25) cách nhau 5 phút.
        /// </summary>
        [HttpPost("normal")]
        public async Task<IActionResult> SimulateNormalData([FromBody] SimulationRequestDto dto)
        {
            var userId = await ResolveUserIdAsync(dto.UserId);
            if (userId == null)
            {
                return NotFound(new
                {
                    success = false,
                    message = "Không tìm thấy người dùng mục tiêu để mô phỏng dữ liệu. Hãy đăng ký tài khoản trước hoặc cung cấp userId hợp lệ."
                });
            }

            var now = DateTime.UtcNow;
            var normalRecords = new List<BiometricRecord>
            {
                new BiometricRecord
                {
                    UserId = userId.Value,
                    HeartRate = 72,
                    SpO2 = 98.5,
                    HRV = 62.0,
                    StressLevel = 24,
                    RecordedAt = now.AddMinutes(-20)
                },
                new BiometricRecord
                {
                    UserId = userId.Value,
                    HeartRate = 75,
                    SpO2 = 99.0,
                    HRV = 58.0,
                    StressLevel = 26,
                    RecordedAt = now.AddMinutes(-15)
                },
                new BiometricRecord
                {
                    UserId = userId.Value,
                    HeartRate = 74,
                    SpO2 = 98.0,
                    HRV = 65.0,
                    StressLevel = 23,
                    RecordedAt = now.AddMinutes(-10)
                },
                new BiometricRecord
                {
                    UserId = userId.Value,
                    HeartRate = 78,
                    SpO2 = 98.5,
                    HRV = 59.0,
                    StressLevel = 27,
                    RecordedAt = now.AddMinutes(-5)
                },
                new BiometricRecord
                {
                    UserId = userId.Value,
                    HeartRate = 73,
                    SpO2 = 99.0,
                    HRV = 60.0,
                    StressLevel = 25,
                    RecordedAt = now
                }
            };

            await _dbContext.BiometricRecords.AddRangeAsync(normalRecords);
            await _dbContext.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = $"Đã mô phỏng thành công 5 bản ghi bình thường cho UserId: {userId.Value}",
                userId = userId.Value,
                records = normalRecords
            });
        }

        /// <summary>
        /// [DEMO BẢO VỆ ĐỒ ÁN] Bơm ngay lập tức 1 gói dữ liệu nguy kịch (SpO2: 87%, HeartRate: 148 bpm, Stress: 90, HRV: 15)
        /// Kích hoạt chuỗi Rule-based Engine, ghi nhận DB và phát SignalR hú còi trên App Flutter trong thời gian thực!
        /// </summary>
        [HttpPost("emergency")]
        public async Task<IActionResult> SimulateEmergencyData([FromBody] SimulationRequestDto dto)
        {
            var userId = await ResolveUserIdAsync(dto.UserId);
            if (userId == null)
            {
                return NotFound(new
                {
                    success = false,
                    message = "Không tìm thấy người dùng mục tiêu để mô phỏng dữ liệu khẩn cấp. Hãy đăng ký tài khoản trước hoặc truyền userId hợp lệ."
                });
            }

            var criticalRecord = new BiometricRecord
            {
                UserId = userId.Value,
                HeartRate = 148,     // Tachycardia nguy kịch (> 130 bpm)
                SpO2 = 87.0,         // Suy hô hấp cấp tính (< 90%)
                HRV = 15.0,          // HRV sụt giảm mạnh kết hợp Stress cao
                StressLevel = 90,    // Mức độ căng thẳng tột đỉnh
                RecordedAt = DateTime.UtcNow
            };

            await _dbContext.BiometricRecords.AddAsync(criticalRecord);
            await _dbContext.SaveChangesAsync();

            // Kích hoạt ngay lập tức bộ máy luật y khoa và phát sóng SignalR trực tiếp tới Flutter
            var triggeredAlerts = await _alertRuleEngine.EvaluateBiometricsAsync(userId.Value, criticalRecord);

            return Ok(new
            {
                success = true,
                message = "ĐÃ KÍCH HOẠT TÌNH TRẠNG NGUY KỊCH! Hệ thống đã tự động lưu dữ liệu, phân tích luật y khoa và phát sóng cảnh báo SignalR tới ứng dụng di động Flutter.",
                userId = userId.Value,
                biometricRecord = criticalRecord,
                triggeredAlertsCount = triggeredAlerts.Count,
                alerts = triggeredAlerts
            });
        }

        private async Task<int?> ResolveUserIdAsync(int requestedUserId)
        {
            if (requestedUserId > 0)
            {
                var exists = await _dbContext.Users.AnyAsync(u => u.Id == requestedUserId);
                if (exists) return requestedUserId;
            }

            // Thử lấy từ Token nếu người dùng đang gửi Bearer Token
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(claim, out var authUserId))
            {
                var exists = await _dbContext.Users.AnyAsync(u => u.Id == authUserId);
                if (exists) return authUserId;
            }

            // Nếu không có, tự động lấy user đầu tiên trong cơ sở dữ liệu làm demo
            var firstUser = await _dbContext.Users.AsNoTracking().FirstOrDefaultAsync();
            return firstUser?.Id;
        }
    }
}

using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using backend_DACN.Data;
using backend_DACN.DTOs;
using backend_DACN.Models;

namespace backend_DACN.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ActivityController : ControllerBase
    {
        private readonly ApplicationDbContext _dbContext;

        public ActivityController(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        /// <summary>
        /// Ghi nhận hoặc cập nhật chỉ số vận động trong ngày (bước chân, calo, quãng đường)
        /// </summary>
        [HttpPost("record")]
        public async Task<IActionResult> LogActivity([FromBody] CreateActivityDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var userId = GetCurrentUserId();
            var targetDate = (dto.RecordedDate ?? DateTime.UtcNow).Date;

            var existingRecord = await _dbContext.ActivityRecords
                .FirstOrDefaultAsync(a => a.UserId == userId && a.RecordedDate.Date == targetDate);

            if (existingRecord != null)
            {
                // Cập nhật số liệu tích lũy trong ngày
                existingRecord.Steps = dto.Steps;
                existingRecord.CaloriesBurned = dto.CaloriesBurned;
                existingRecord.DistanceMeter = dto.DistanceMeter;
            }
            else
            {
                existingRecord = new ActivityRecord
                {
                    UserId = userId,
                    Steps = dto.Steps,
                    CaloriesBurned = dto.CaloriesBurned,
                    DistanceMeter = dto.DistanceMeter,
                    RecordedDate = targetDate
                };
                await _dbContext.ActivityRecords.AddAsync(existingRecord);
            }

            await _dbContext.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Ghi nhận chỉ số vận động thành công!",
                data = new ActivityDto
                {
                    Id = existingRecord.Id,
                    UserId = existingRecord.UserId,
                    Steps = existingRecord.Steps,
                    CaloriesBurned = existingRecord.CaloriesBurned,
                    DistanceMeter = existingRecord.DistanceMeter,
                    RecordedDate = existingRecord.RecordedDate
                }
            });
        }

        /// <summary>
        /// Lấy lịch sử hoạt động thể chất của người dùng
        /// </summary>
        [HttpGet("history")]
        public async Task<IActionResult> GetActivityHistory([FromQuery] int days = 7)
        {
            if (days < 1) days = 7;
            if (days > 90) days = 90;

            var userId = GetCurrentUserId();
            var fromDate = DateTime.UtcNow.Date.AddDays(-days);

            var list = await _dbContext.ActivityRecords
                .AsNoTracking()
                .Where(a => a.UserId == userId && a.RecordedDate >= fromDate)
                .OrderByDescending(a => a.RecordedDate)
                .Select(a => new ActivityDto
                {
                    Id = a.Id,
                    UserId = a.UserId,
                    Steps = a.Steps,
                    CaloriesBurned = a.CaloriesBurned,
                    DistanceMeter = a.DistanceMeter,
                    RecordedDate = a.RecordedDate
                })
                .ToListAsync();

            return Ok(new
            {
                success = true,
                data = list
            });
        }

        /// <summary>
        /// Ghi nhận phiên ngủ mới của người dùng
        /// </summary>
        [HttpPost("sleep")]
        public async Task<IActionResult> LogSleep([FromBody] CreateSleepDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            if (dto.EndTime <= dto.StartTime)
            {
                return BadRequest(new { success = false, message = "Thời gian thức dậy phải sau thời gian bắt đầu ngủ." });
            }

            var userId = GetCurrentUserId();

            // Tính toán điểm chất lượng giấc ngủ nếu client không truyền
            var totalDurationMinutes = (dto.EndTime - dto.StartTime).TotalMinutes;
            double qualityScore;

            if (dto.SleepQualityScore.HasValue)
            {
                qualityScore = dto.SleepQualityScore.Value;
            }
            else
            {
                // Điểm dựa trên tổng thời lượng ngủ (7-9 tiếng là chuẩn 100đ) và tỷ lệ ngủ sâu (deep sleep ~ 20-25%)
                var durationHours = totalDurationMinutes / 60.0;
                var baseScore = durationHours switch
                {
                    >= 7.0 and <= 9.0 => 90.0,
                    >= 6.0 and < 7.0 => 75.0,
                    >= 5.0 and < 6.0 => 60.0,
                    > 9.0 => 80.0,
                    _ => 45.0
                };

                var deepSleepRatio = totalDurationMinutes > 0 ? (double)dto.DeepSleepMinutes / totalDurationMinutes : 0;
                var deepBonus = (deepSleepRatio >= 0.18 && deepSleepRatio <= 0.28) ? 10.0 : 5.0;
                qualityScore = Math.Min(100.0, baseScore + deepBonus);
            }

            var sleepRecord = new SleepRecord
            {
                UserId = userId,
                StartTime = dto.StartTime,
                EndTime = dto.EndTime,
                DeepSleepMinutes = dto.DeepSleepMinutes,
                LightSleepMinutes = dto.LightSleepMinutes,
                SleepQualityScore = Math.Round(qualityScore, 1)
            };

            await _dbContext.SleepRecords.AddAsync(sleepRecord);
            await _dbContext.SaveChangesAsync();

            return Ok(new
            {
                success = true,
                message = "Ghi nhận thông tin giấc ngủ thành công!",
                data = new SleepDto
                {
                    Id = sleepRecord.Id,
                    UserId = sleepRecord.UserId,
                    StartTime = sleepRecord.StartTime,
                    EndTime = sleepRecord.EndTime,
                    TotalSleepHours = Math.Round((sleepRecord.EndTime - sleepRecord.StartTime).TotalHours, 1),
                    DeepSleepMinutes = sleepRecord.DeepSleepMinutes,
                    LightSleepMinutes = sleepRecord.LightSleepMinutes,
                    SleepQualityScore = sleepRecord.SleepQualityScore
                }
            });
        }

        /// <summary>
        /// Lấy lịch sử giấc ngủ của người dùng
        /// </summary>
        [HttpGet("sleep/history")]
        public async Task<IActionResult> GetSleepHistory([FromQuery] int days = 7)
        {
            if (days < 1) days = 7;
            if (days > 90) days = 90;

            var userId = GetCurrentUserId();
            var fromDate = DateTime.UtcNow.AddDays(-days);

            var records = await _dbContext.SleepRecords
                .AsNoTracking()
                .Where(s => s.UserId == userId && s.StartTime >= fromDate)
                .OrderByDescending(s => s.StartTime)
                .Select(s => new SleepDto
                {
                    Id = s.Id,
                    UserId = s.UserId,
                    StartTime = s.StartTime,
                    EndTime = s.EndTime,
                    TotalSleepHours = Math.Round((s.EndTime - s.StartTime).TotalHours, 1),
                    DeepSleepMinutes = s.DeepSleepMinutes,
                    LightSleepMinutes = s.LightSleepMinutes,
                    SleepQualityScore = s.SleepQualityScore
                })
                .ToListAsync();

            return Ok(new
            {
                success = true,
                data = records
            });
        }

        /// <summary>
        /// Lấy bảng tổng hợp sức khỏe tổng thể trong ngày cho Màn hình chính (Dashboard) của Mobile Flutter
        /// </summary>
        [HttpGet("summary/today")]
        public async Task<IActionResult> GetTodaySummary()
        {
            var userId = GetCurrentUserId();
            var today = DateTime.UtcNow.Date;
            var tomorrow = today.AddDays(1);

            // Hoạt động thể chất
            var activity = await _dbContext.ActivityRecords
                .AsNoTracking()
                .FirstOrDefaultAsync(a => a.UserId == userId && a.RecordedDate.Date == today);

            // Giấc ngủ gần nhất
            var latestSleep = await _dbContext.SleepRecords
                .AsNoTracking()
                .Where(s => s.UserId == userId && s.EndTime >= today.AddDays(-1))
                .OrderByDescending(s => s.EndTime)
                .FirstOrDefaultAsync();

            // Chỉ số sinh học mới nhất
            var latestBiometric = await _dbContext.BiometricRecords
                .AsNoTracking()
                .Where(b => b.UserId == userId)
                .OrderByDescending(b => b.RecordedAt)
                .FirstOrDefaultAsync();

            // Số cảnh báo đang kích hoạt
            var activeAlertsCount = await _dbContext.EmergencyAlerts
                .AsNoTracking()
                .CountAsync(a => a.UserId == userId && !a.IsResolved);

            var summary = new DailyHealthSummaryDto
            {
                Date = today,
                TotalSteps = activity?.Steps ?? 0,
                TotalCaloriesBurned = activity?.CaloriesBurned ?? 0.0,
                TotalDistanceMeter = activity?.DistanceMeter ?? 0.0,
                TotalSleepHours = latestSleep != null ? Math.Round((latestSleep.EndTime - latestSleep.StartTime).TotalHours, 1) : 0.0,
                SleepQualityScore = latestSleep?.SleepQualityScore ?? 0.0,
                LatestHeartRate = latestBiometric?.HeartRate,
                LatestSpO2 = latestBiometric?.SpO2,
                LatestStressLevel = latestBiometric?.StressLevel,
                ActiveAlertsCount = activeAlertsCount
            };

            return Ok(new
            {
                success = true,
                data = summary
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

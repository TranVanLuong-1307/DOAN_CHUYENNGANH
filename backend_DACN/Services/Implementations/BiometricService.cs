using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using backend_DACN.Data;
using backend_DACN.DTOs;
using backend_DACN.Models;
using backend_DACN.Services.Interfaces;

namespace backend_DACN.Services.Implementations
{
    public class BiometricService : IBiometricService
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly IAlertRuleEngine _alertRuleEngine;

        public BiometricService(ApplicationDbContext dbContext, IAlertRuleEngine alertRuleEngine)
        {
            _dbContext = dbContext;
            _alertRuleEngine = alertRuleEngine;
        }

        public async Task<BiometricRecordDto> AddBiometricRecordAsync(int userId, CreateBiometricRecordDto dto)
        {
            // Kiểm tra xem User có tồn tại không
            var userExists = await _dbContext.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
            {
                throw new KeyNotFoundException($"Không tìm thấy người dùng với Id {userId}");
            }

            var record = new BiometricRecord
            {
                UserId = userId,
                HeartRate = dto.HeartRate,
                SpO2 = dto.SpO2,
                HRV = dto.HRV,
                StressLevel = dto.StressLevel,
                RecordedAt = dto.RecordedAt ?? DateTime.UtcNow
            };

            await _dbContext.BiometricRecords.AddAsync(record);
            await _dbContext.SaveChangesAsync();

            // Kích hoạt bộ máy luật y khoa kiểm tra ngưỡng và cảnh báo theo thời gian thực
            await _alertRuleEngine.EvaluateBiometricsAsync(userId, record);

            return new BiometricRecordDto
            {
                Id = record.Id,
                UserId = record.UserId,
                HeartRate = record.HeartRate,
                SpO2 = record.SpO2,
                HRV = record.HRV,
                StressLevel = record.StressLevel,
                RecordedAt = record.RecordedAt
            };
        }

        public async Task<PagedResultDto<BiometricRecordDto>> GetHistoryAsync(int userId, DateTime? startDate, DateTime? endDate, int pageNumber, int pageSize)
        {
            if (pageNumber < 1) pageNumber = 1;
            if (pageSize < 1) pageSize = 50;
            if (pageSize > 500) pageSize = 500;

            var query = _dbContext.BiometricRecords
                .AsNoTracking()
                .Where(b => b.UserId == userId);

            if (startDate.HasValue)
            {
                query = query.Where(b => b.RecordedAt >= startDate.Value);
            }

            if (endDate.HasValue)
            {
                query = query.Where(b => b.RecordedAt <= endDate.Value);
            }

            var totalCount = await query.CountAsync();

            var items = await query
                .OrderByDescending(b => b.RecordedAt)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .Select(b => new BiometricRecordDto
                {
                    Id = b.Id,
                    UserId = b.UserId,
                    HeartRate = b.HeartRate,
                    SpO2 = b.SpO2,
                    HRV = b.HRV,
                    StressLevel = b.StressLevel,
                    RecordedAt = b.RecordedAt
                })
                .ToListAsync();

            return new PagedResultDto<BiometricRecordDto>
            {
                Items = items,
                TotalCount = totalCount,
                PageNumber = pageNumber,
                PageSize = pageSize
            };
        }

        public async Task<BiometricChartSummaryDto> GetChartSummaryAsync(int userId, DateTime date)
        {
            var startOfDay = date.Date;
            var endOfDay = startOfDay.AddDays(1);

            // Tận dụng Composite Index (UserId, RecordedAt) để tải toàn bộ bản ghi trong ngày
            var dayRecords = await _dbContext.BiometricRecords
                .AsNoTracking()
                .Where(b => b.UserId == userId && b.RecordedAt >= startOfDay && b.RecordedAt < endOfDay)
                .OrderBy(b => b.RecordedAt)
                .ToListAsync();

            var hourlyList = new List<HourlyChartItemDto>();

            // Gom nhóm theo từng khung giờ (0h - 23h) cho Mobile vẽ biểu đồ mượt mà
            for (int hour = 0; hour < 24; hour++)
            {
                var hourRecords = dayRecords.Where(r => r.RecordedAt.Hour == hour).ToList();

                if (hourRecords.Count > 0)
                {
                    hourlyList.Add(new HourlyChartItemDto
                    {
                        Hour = hour,
                        TimeLabel = $"{hour:D2}:00",
                        AvgHeartRate = Math.Round(hourRecords.Average(r => r.HeartRate), 1),
                        MinHeartRate = hourRecords.Min(r => r.HeartRate),
                        MaxHeartRate = hourRecords.Max(r => r.HeartRate),
                        AvgSpO2 = Math.Round(hourRecords.Average(r => r.SpO2), 1),
                        AvgHRV = Math.Round(hourRecords.Average(r => r.HRV), 1),
                        AvgStressLevel = Math.Round(hourRecords.Average(r => r.StressLevel), 1),
                        RecordCount = hourRecords.Count
                    });
                }
                else
                {
                    hourlyList.Add(new HourlyChartItemDto
                    {
                        Hour = hour,
                        TimeLabel = $"{hour:D2}:00",
                        AvgHeartRate = 0,
                        MinHeartRate = 0,
                        MaxHeartRate = 0,
                        AvgSpO2 = 0,
                        AvgHRV = 0,
                        AvgStressLevel = 0,
                        RecordCount = 0
                    });
                }
            }

            var dailyAvgHeartRate = dayRecords.Count > 0 ? Math.Round(dayRecords.Average(r => r.HeartRate), 1) : 0;
            var dailyMinHeartRate = dayRecords.Count > 0 ? dayRecords.Min(r => r.HeartRate) : 0;
            var dailyMaxHeartRate = dayRecords.Count > 0 ? dayRecords.Max(r => r.HeartRate) : 0;
            var dailyAvgSpO2 = dayRecords.Count > 0 ? Math.Round(dayRecords.Average(r => r.SpO2), 1) : 0;

            return new BiometricChartSummaryDto
            {
                Date = startOfDay,
                FormattedDate = startOfDay.ToString("yyyy-MM-dd"),
                HourlyData = hourlyList,
                DailyAvgHeartRate = dailyAvgHeartRate,
                DailyMinHeartRate = dailyMinHeartRate,
                DailyMaxHeartRate = dailyMaxHeartRate,
                DailyAvgSpO2 = dailyAvgSpO2,
                TotalRecords = dayRecords.Count
            };
        }

        public async Task<BiometricRecordDto?> GetLatestBiometricAsync(int userId)
        {
            var latest = await _dbContext.BiometricRecords
                .AsNoTracking()
                .Where(b => b.UserId == userId)
                .OrderByDescending(b => b.RecordedAt)
                .FirstOrDefaultAsync();

            if (latest == null)
            {
                return null;
            }

            return new BiometricRecordDto
            {
                Id = latest.Id,
                UserId = latest.UserId,
                HeartRate = latest.HeartRate,
                SpO2 = latest.SpO2,
                HRV = latest.HRV,
                StressLevel = latest.StressLevel,
                RecordedAt = latest.RecordedAt
            };
        }
    }
}

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using backend_DACN.Data;
using backend_DACN.DTOs;
using backend_DACN.Hubs;
using backend_DACN.Models;
using backend_DACN.Services.Interfaces;

namespace backend_DACN.Services.Implementations
{
    public class AlertRuleEngine : IAlertRuleEngine
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly IHubContext<EmergencyHub> _hubContext;
        private readonly ILogger<AlertRuleEngine> _logger;

        public AlertRuleEngine(
            ApplicationDbContext dbContext,
            IHubContext<EmergencyHub> hubContext,
            ILogger<AlertRuleEngine> logger)
        {
            _dbContext = dbContext;
            _hubContext = hubContext;
            _logger = logger;
        }

        public async Task<List<EmergencyAlert>> EvaluateBiometricsAsync(int userId, BiometricRecord record)
        {
            var triggeredAlerts = new List<EmergencyAlert>();

            // Lấy ngưỡng cá nhân hóa của người dùng (nếu chưa có thì dùng ngưỡng tiêu chuẩn y khoa)
            var threshold = await _dbContext.PersonalThresholds
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.UserId == userId);

            var minRestingHeartRate = threshold?.MinRestingHeartRate ?? 50;
            var maxRestingHeartRate = threshold?.MaxRestingHeartRate ?? 95;
            var minSpO2 = threshold?.MinSpO2 ?? 92.0;
            var maxStressLevel = threshold?.MaxStressLevel ?? 75;

            var evaluationTime = record.RecordedAt != default ? record.RecordedAt : DateTime.UtcNow;

            // ================= QUY TẮC 1: NỒNG ĐỘ OXY TRONG MÁU (SpO2) =================
            if (record.SpO2 < 90.0)
            {
                triggeredAlerts.Add(new EmergencyAlert
                {
                    UserId = userId,
                    AlertType = "SpO2_Drop",
                    TriggerValue = record.SpO2,
                    ThresholdValue = 90.0,
                    Severity = "Critical",
                    Recommendation = "Nồng độ oxy trong máu ở mức nguy hiểm cấp tính. Hãy ngồi thẳng, hít thở sâu và liên hệ cơ sở y tế gần nhất ngay lập tức!",
                    IsResolved = false,
                    CreatedAt = evaluationTime
                });
            }
            else if (record.SpO2 < minSpO2)
            {
                triggeredAlerts.Add(new EmergencyAlert
                {
                    UserId = userId,
                    AlertType = "SpO2_Drop",
                    TriggerValue = record.SpO2,
                    ThresholdValue = minSpO2,
                    Severity = "Medium",
                    Recommendation = $"Nồng độ oxy trong máu ({record.SpO2:F1}%) đang dưới ngưỡng an toàn ({minSpO2:F1}%). Hãy nghỉ ngơi, hít thở chậm và theo dõi sát sao!",
                    IsResolved = false,
                    CreatedAt = evaluationTime
                });
            }

            // ================= QUY TẮC 2: NHỊP TIM LÚC NGHỈ (Heart Rate) =================
            // Nhịp tim nhanh (Tachycardia)
            if (record.HeartRate > maxRestingHeartRate)
            {
                bool isCritical = record.HeartRate > 130;
                triggeredAlerts.Add(new EmergencyAlert
                {
                    UserId = userId,
                    AlertType = "Tachycardia",
                    TriggerValue = record.HeartRate,
                    ThresholdValue = maxRestingHeartRate,
                    Severity = isCritical ? "Critical" : "Medium",
                    Recommendation = isCritical
                        ? "Nhịp tim tăng cao nguy kịch (> 130 bpm)! Hãy dừng ngay mọi hoạt động, ngồi nghỉ và gọi người hỗ trợ nếu thấy khó thở hoặc đau ngực!"
                        : "Nhịp tim tăng cao bất thường khi nghỉ ngơi. Hãy tạm dừng hoạt động và nghỉ ngơi!",
                    IsResolved = false,
                    CreatedAt = evaluationTime
                });
            }
            // Nhịp tim chậm (Bradycardia)
            else if (record.HeartRate < minRestingHeartRate)
            {
                bool isCritical = record.HeartRate < 45;
                triggeredAlerts.Add(new EmergencyAlert
                {
                    UserId = userId,
                    AlertType = "Bradycardia",
                    TriggerValue = record.HeartRate,
                    ThresholdValue = minRestingHeartRate,
                    Severity = isCritical ? "Critical" : "Medium",
                    Recommendation = isCritical
                        ? "Nhịp tim đập quá chậm nguy hiểm!"
                        : $"Nhịp tim đập chậm hơn ngưỡng an toàn cá nhân ({minRestingHeartRate} bpm). Hãy kiểm tra trạng thái sức khỏe và nghỉ ngơi.",
                    IsResolved = false,
                    CreatedAt = evaluationTime
                });
            }

            // ================= QUY TẮC 3: CĂNG THẲNG QUÁ TẢI (High Stress & Low HRV) =================
            if (record.StressLevel > 85 && record.HRV > 0 && record.HRV < 20.0)
            {
                triggeredAlerts.Add(new EmergencyAlert
                {
                    UserId = userId,
                    AlertType = "High_Stress",
                    TriggerValue = record.StressLevel,
                    ThresholdValue = 85.0,
                    Severity = "Medium",
                    Recommendation = "Cơ thể đang rơi vào trạng thái kiệt sức và căng thẳng cao. Hãy thực hiện bài tập thở 4-7-8!",
                    IsResolved = false,
                    CreatedAt = evaluationTime
                });
            }
            else if (record.StressLevel > maxStressLevel)
            {
                triggeredAlerts.Add(new EmergencyAlert
                {
                    UserId = userId,
                    AlertType = "High_Stress",
                    TriggerValue = record.StressLevel,
                    ThresholdValue = maxStressLevel,
                    Severity = "Low",
                    Recommendation = "Mức độ căng thẳng đang tăng cao. Hãy nghỉ ngơi, uống nước và thực hiện các động tác thư giãn nhẹ nhàng.",
                    IsResolved = false,
                    CreatedAt = evaluationTime
                });
            }

            // ================= LƯU VÀ PHÁT TÍN HIỆU SIGNALR CHO MỖI CẢNH BÁO =================
            if (triggeredAlerts.Count > 0)
            {
                await _dbContext.EmergencyAlerts.AddRangeAsync(triggeredAlerts);
                await _dbContext.SaveChangesAsync();

                foreach (var alert in triggeredAlerts)
                {
                    var alertDto = new EmergencyAlertDto
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
                    };

                    var groupName = $"user_{userId}";
                    _logger.LogWarning(
                        "KÍCH HOẠT CẢNH BÁO KHẨN CẤP [UserId: {UserId}, Loại: {AlertType}, Mức độ: {Severity}, Giá trị: {Value}]",
                        userId, alert.AlertType, alert.Severity, alert.TriggerValue);

                    // Bắn tín hiệu SignalR tới Client Flutter đang lắng nghe nhóm hoặc UserId
                    await _hubContext.Clients.Group(groupName).SendAsync("ReceiveEmergencyAlert", alertDto);
                    await _hubContext.Clients.User(userId.ToString()).SendAsync("ReceiveEmergencyAlert", alertDto);
                }
            }

            return triggeredAlerts;
        }
    }
}

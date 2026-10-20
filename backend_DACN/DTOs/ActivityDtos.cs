using System;
using System.ComponentModel.DataAnnotations;

namespace backend_DACN.DTOs
{
    public class CreateActivityDto
    {
        [Range(0, 200000, ErrorMessage = "Số bước chân phải từ 0 đến 200.000")]
        public int Steps { get; set; }

        [Range(0.0, 20000.0, ErrorMessage = "Lượng calo tiêu thụ phải từ 0 đến 20.000 kcal")]
        public double CaloriesBurned { get; set; }

        [Range(0.0, 200000.0, ErrorMessage = "Quãng đường phải từ 0 đến 200.000 mét")]
        public double DistanceMeter { get; set; }

        public DateTime? RecordedDate { get; set; }
    }

    public class ActivityDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int Steps { get; set; }
        public double CaloriesBurned { get; set; }
        public double DistanceMeter { get; set; }
        public DateTime RecordedDate { get; set; }
    }

    public class CreateSleepDto
    {
        [Required(ErrorMessage = "Thời gian bắt đầu ngủ không được để trống")]
        public DateTime StartTime { get; set; }

        [Required(ErrorMessage = "Thời gian thức dậy không được để trống")]
        public DateTime EndTime { get; set; }

        [Range(0, 1440, ErrorMessage = "Thời gian ngủ sâu phải từ 0 đến 1440 phút")]
        public int DeepSleepMinutes { get; set; }

        [Range(0, 1440, ErrorMessage = "Thời gian ngủ nông phải từ 0 đến 1440 phút")]
        public int LightSleepMinutes { get; set; }

        [Range(0.0, 100.0, ErrorMessage = "Điểm chất lượng giấc ngủ từ 0 đến 100")]
        public double? SleepQualityScore { get; set; }
    }

    public class SleepDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public double TotalSleepHours { get; set; }
        public int DeepSleepMinutes { get; set; }
        public int LightSleepMinutes { get; set; }
        public double SleepQualityScore { get; set; }
    }

    public class DailyHealthSummaryDto
    {
        public DateTime Date { get; set; }
        public int TotalSteps { get; set; }
        public double TotalCaloriesBurned { get; set; }
        public double TotalDistanceMeter { get; set; }
        public double TotalSleepHours { get; set; }
        public double SleepQualityScore { get; set; }
        public int? LatestHeartRate { get; set; }
        public double? LatestSpO2 { get; set; }
        public int? LatestStressLevel { get; set; }
        public int ActiveAlertsCount { get; set; }
    }
}

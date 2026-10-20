using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace backend_DACN.DTOs
{
    public class CreateBiometricRecordDto
    {
        [Required(ErrorMessage = "Nhịp tim không được để trống")]
        [Range(20, 300, ErrorMessage = "Nhịp tim phải từ 20 đến 300 bpm")]
        public int HeartRate { get; set; }

        [Required(ErrorMessage = "SpO2 không được để trống")]
        [Range(50.0, 100.0, ErrorMessage = "Nồng độ SpO2 phải từ 50% đến 100%")]
        public double SpO2 { get; set; }

        [Required(ErrorMessage = "HRV không được để trống")]
        [Range(0.0, 300.0, ErrorMessage = "HRV phải từ 0 đến 300 ms")]
        public double HRV { get; set; }

        [Required(ErrorMessage = "Mức độ Stress không được để trống")]
        [Range(0, 100, ErrorMessage = "Mức độ Stress phải từ 0 đến 100")]
        public int StressLevel { get; set; }

        public DateTime? RecordedAt { get; set; }
    }

    public class BiometricRecordDto
    {
        public long Id { get; set; }
        public int UserId { get; set; }
        public int HeartRate { get; set; }
        public double SpO2 { get; set; }
        public double HRV { get; set; }
        public int StressLevel { get; set; }
        public DateTime RecordedAt { get; set; }
    }

    public class HourlyChartItemDto
    {
        public int Hour { get; set; } // 0 - 23
        public string TimeLabel { get; set; } = string.Empty; // "00:00", "01:00", etc.
        public double AvgHeartRate { get; set; }
        public int MinHeartRate { get; set; }
        public int MaxHeartRate { get; set; }
        public double AvgSpO2 { get; set; }
        public double AvgHRV { get; set; }
        public double AvgStressLevel { get; set; }
        public int RecordCount { get; set; }
    }

    public class BiometricChartSummaryDto
    {
        public DateTime Date { get; set; }
        public string FormattedDate { get; set; } = string.Empty;
        public List<HourlyChartItemDto> HourlyData { get; set; } = new List<HourlyChartItemDto>();
        public double DailyAvgHeartRate { get; set; }
        public int DailyMinHeartRate { get; set; }
        public int DailyMaxHeartRate { get; set; }
        public double DailyAvgSpO2 { get; set; }
        public int TotalRecords { get; set; }
    }

    public class PagedResultDto<T>
    {
        public List<T> Items { get; set; } = new List<T>();
        public int TotalCount { get; set; }
        public int PageNumber { get; set; }
        public int PageSize { get; set; }
        public int TotalPages => (int)Math.Ceiling((double)TotalCount / (PageSize > 0 ? PageSize : 1));
        public bool HasPreviousPage => PageNumber > 1;
        public bool HasNextPage => PageNumber < TotalPages;
    }
}

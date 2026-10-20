using System;

namespace backend_DACN.Models
{
    public class BiometricRecord
    {
        public long Id { get; set; }
        public int UserId { get; set; }
        public int HeartRate { get; set; }
        public double SpO2 { get; set; }
        public double HRV { get; set; }
        public int StressLevel { get; set; }
        public DateTime RecordedAt { get; set; } = DateTime.UtcNow;

        // Navigation Property
        public User? User { get; set; }
    }
}

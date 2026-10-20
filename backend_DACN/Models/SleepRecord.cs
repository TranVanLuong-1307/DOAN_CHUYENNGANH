using System;

namespace backend_DACN.Models
{
    public class SleepRecord
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public int DeepSleepMinutes { get; set; }
        public int LightSleepMinutes { get; set; }
        public double SleepQualityScore { get; set; } // Score between 0.0 and 100.0

        // Navigation Property
        public User? User { get; set; }
    }
}

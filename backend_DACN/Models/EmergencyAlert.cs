using System;

namespace backend_DACN.Models
{
    public class EmergencyAlert
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string AlertType { get; set; } = string.Empty; // "SpO2_Drop", "Tachycardia", "Bradycardia", "High_Stress"
        public double TriggerValue { get; set; }
        public double ThresholdValue { get; set; }
        public string Severity { get; set; } = "Medium"; // "Low", "Medium", "Critical"
        public string Recommendation { get; set; } = string.Empty;
        public bool IsResolved { get; set; } = false;
        public DateTime? ResolvedAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation Property
        public User? User { get; set; }
    }
}

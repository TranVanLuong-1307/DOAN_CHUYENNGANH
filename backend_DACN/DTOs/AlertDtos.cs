using System;

namespace backend_DACN.DTOs
{
    public class EmergencyAlertDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string AlertType { get; set; } = string.Empty;
        public double TriggerValue { get; set; }
        public double ThresholdValue { get; set; }
        public string Severity { get; set; } = string.Empty; // "Low", "Medium", "Critical"
        public string Recommendation { get; set; } = string.Empty;
        public bool IsResolved { get; set; }
        public DateTime? ResolvedAt { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class ResolveAlertDto
    {
        public string? Notes { get; set; }
    }

    public class SimulationRequestDto
    {
        public int UserId { get; set; }
    }
}

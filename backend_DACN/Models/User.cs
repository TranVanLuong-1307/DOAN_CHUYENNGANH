using System;
using System.Collections.Generic;

namespace backend_DACN.Models
{
    public class User
    {
        public int Id { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public DateTime DateOfBirth { get; set; }
        public string Gender { get; set; } = "Male"; // "Male" or "Female"
        public double Height { get; set; } // in cm
        public double Weight { get; set; } // in kg
        public string EmergencyContactPhone { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation Properties
        public PersonalThreshold? PersonalThreshold { get; set; }
        public ICollection<BiometricRecord> BiometricRecords { get; set; } = new List<BiometricRecord>();
        public ICollection<EmergencyAlert> EmergencyAlerts { get; set; } = new List<EmergencyAlert>();
        public ICollection<ActivityRecord> ActivityRecords { get; set; } = new List<ActivityRecord>();
        public ICollection<SleepRecord> SleepRecords { get; set; } = new List<SleepRecord>();
    }
}

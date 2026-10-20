using System;

namespace backend_DACN.Models
{
    public class ActivityRecord
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int Steps { get; set; }
        public double CaloriesBurned { get; set; }
        public double DistanceMeter { get; set; }
        public DateTime RecordedDate { get; set; } = DateTime.UtcNow.Date;

        // Navigation Property
        public User? User { get; set; }
    }
}

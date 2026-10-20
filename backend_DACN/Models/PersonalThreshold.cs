namespace backend_DACN.Models
{
    public class PersonalThreshold
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int MinRestingHeartRate { get; set; }
        public int MaxRestingHeartRate { get; set; }
        public double MinSpO2 { get; set; }
        public int MaxStressLevel { get; set; }
        public string? CustomNotes { get; set; }

        // Navigation Property
        public User? User { get; set; }
    }
}

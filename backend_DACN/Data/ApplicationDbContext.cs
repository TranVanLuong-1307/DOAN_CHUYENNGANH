using Microsoft.EntityFrameworkCore;
using backend_DACN.Models;

namespace backend_DACN.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users => Set<User>();
        public DbSet<PersonalThreshold> PersonalThresholds => Set<PersonalThreshold>();
        public DbSet<BiometricRecord> BiometricRecords => Set<BiometricRecord>();
        public DbSet<EmergencyAlert> EmergencyAlerts => Set<EmergencyAlert>();
        public DbSet<ActivityRecord> ActivityRecords => Set<ActivityRecord>();
        public DbSet<SleepRecord> SleepRecords => Set<SleepRecord>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // ================= USER CONFIGURATION =================
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(u => u.Id);
                entity.Property(u => u.FullName).IsRequired().HasMaxLength(150);
                entity.Property(u => u.Email).IsRequired().HasMaxLength(200);
                entity.Property(u => u.PasswordHash).IsRequired();
                entity.Property(u => u.Gender).IsRequired().HasMaxLength(20);
                entity.Property(u => u.EmergencyContactPhone).HasMaxLength(30);

                // Unique Email constraint
                entity.HasIndex(u => u.Email)
                      .IsUnique()
                      .HasDatabaseName("IX_Users_Email");

                // 1-1 with PersonalThreshold
                entity.HasOne(u => u.PersonalThreshold)
                      .WithOne(p => p.User)
                      .HasForeignKey<PersonalThreshold>(p => p.UserId)
                      .OnDelete(DeleteBehavior.Cascade);

                // 1-N Relationships
                entity.HasMany(u => u.BiometricRecords)
                      .WithOne(b => b.User)
                      .HasForeignKey(b => b.UserId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasMany(u => u.EmergencyAlerts)
                      .WithOne(a => a.User)
                      .HasForeignKey(a => a.UserId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasMany(u => u.ActivityRecords)
                      .WithOne(a => a.User)
                      .HasForeignKey(a => a.UserId)
                      .OnDelete(DeleteBehavior.Cascade);

                entity.HasMany(u => u.SleepRecords)
                      .WithOne(s => s.User)
                      .HasForeignKey(s => s.UserId)
                      .OnDelete(DeleteBehavior.Cascade);
            });

            // ================= PERSONAL THRESHOLD CONFIGURATION =================
            modelBuilder.Entity<PersonalThreshold>(entity =>
            {
                entity.HasKey(p => p.Id);
                entity.Property(p => p.CustomNotes).HasMaxLength(500);
            });

            // ================= BIOMETRIC RECORD CONFIGURATION (TIME-SERIES OPTIMIZATION) =================
            modelBuilder.Entity<BiometricRecord>(entity =>
            {
                entity.HasKey(b => b.Id);
                entity.Property(b => b.HeartRate).IsRequired();
                entity.Property(b => b.SpO2).IsRequired();
                entity.Property(b => b.HRV).IsRequired();
                entity.Property(b => b.StressLevel).IsRequired();
                entity.Property(b => b.RecordedAt).IsRequired();

                // Composite Index on (UserId, RecordedAt) for fast time-series queries & chart aggregations
                entity.HasIndex(b => new { b.UserId, b.RecordedAt })
                      .HasDatabaseName("IX_BiometricRecords_UserId_RecordedAt");
            });

            // ================= EMERGENCY ALERT CONFIGURATION =================
            modelBuilder.Entity<EmergencyAlert>(entity =>
            {
                entity.HasKey(a => a.Id);
                entity.Property(a => a.AlertType).IsRequired().HasMaxLength(50);
                entity.Property(a => a.Severity).IsRequired().HasMaxLength(20);
                entity.Property(a => a.Recommendation).IsRequired().HasMaxLength(1000);
                entity.Property(a => a.CreatedAt).IsRequired();

                // Fast lookup index for active alerts and alert history by user
                entity.HasIndex(a => new { a.UserId, a.IsResolved })
                      .HasDatabaseName("IX_EmergencyAlerts_UserId_IsResolved");

                entity.HasIndex(a => new { a.UserId, a.CreatedAt })
                      .HasDatabaseName("IX_EmergencyAlerts_UserId_CreatedAt");
            });

            // ================= ACTIVITY RECORD CONFIGURATION =================
            modelBuilder.Entity<ActivityRecord>(entity =>
            {
                entity.HasKey(a => a.Id);
                entity.Property(a => a.RecordedDate).IsRequired();

                entity.HasIndex(a => new { a.UserId, a.RecordedDate })
                      .HasDatabaseName("IX_ActivityRecords_UserId_RecordedDate");
            });

            // ================= SLEEP RECORD CONFIGURATION =================
            modelBuilder.Entity<SleepRecord>(entity =>
            {
                entity.HasKey(s => s.Id);
                entity.Property(s => s.StartTime).IsRequired();
                entity.Property(s => s.EndTime).IsRequired();

                entity.HasIndex(s => new { s.UserId, s.StartTime })
                      .HasDatabaseName("IX_SleepRecords_UserId_StartTime");
            });
        }
    }
}

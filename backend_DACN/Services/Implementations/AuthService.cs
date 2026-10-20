using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using backend_DACN.Data;
using backend_DACN.DTOs;
using backend_DACN.Models;
using backend_DACN.Services.Interfaces;

namespace backend_DACN.Services.Implementations
{
    public class AuthService : IAuthService
    {
        private readonly ApplicationDbContext _dbContext;
        private readonly IConfiguration _configuration;

        public AuthService(ApplicationDbContext dbContext, IConfiguration configuration)
        {
            _dbContext = dbContext;
            _configuration = configuration;
        }

        public async Task<AuthResponseDto> RegisterAsync(RegisterDto dto)
        {
            var normalizedEmail = dto.Email.Trim().ToLowerInvariant();

            // Kiểm tra xem email đã tồn tại hay chưa
            var existingUser = await _dbContext.Users.AnyAsync(u => u.Email.ToLower() == normalizedEmail);
            if (existingUser)
            {
                throw new InvalidOperationException("Email này đã được đăng ký trong hệ thống.");
            }

            // Mã hóa mật khẩu an toàn với BCrypt
            var passwordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password, workFactor: 12);

            var user = new User
            {
                FullName = dto.FullName.Trim(),
                Email = normalizedEmail,
                PasswordHash = passwordHash,
                DateOfBirth = dto.DateOfBirth,
                Gender = dto.Gender,
                Height = dto.Height,
                Weight = dto.Weight,
                EmergencyContactPhone = dto.EmergencyContactPhone.Trim(),
                CreatedAt = DateTime.UtcNow
            };

            await _dbContext.Users.AddAsync(user);
            await _dbContext.SaveChangesAsync();

            // ================= TỰ ĐỘNG KHỞI TẠO NGƯỠNG CÁ NHÂN HÓA Y KHOA =================
            var today = DateTime.UtcNow.Date;
            var age = today.Year - dto.DateOfBirth.Year;
            if (dto.DateOfBirth.Date > today.AddYears(-age))
            {
                age--;
            }
            if (age < 0) age = 0;

            // Công thức Tanaka: HR_max = 208 - (0.7 * Tuổi)
            var hrMaxTheoretical = 208.0 - (0.7 * age);

            int minRestingHeartRate;
            int maxRestingHeartRate;

            if (string.Equals(dto.Gender, "Female", StringComparison.OrdinalIgnoreCase))
            {
                minRestingHeartRate = 55;
                maxRestingHeartRate = 100;
            }
            else
            {
                minRestingHeartRate = 50;
                maxRestingHeartRate = 95;
            }

            var personalThreshold = new PersonalThreshold
            {
                UserId = user.Id,
                MinRestingHeartRate = minRestingHeartRate,
                MaxRestingHeartRate = maxRestingHeartRate,
                MinSpO2 = 92.0, // Ngưỡng SpO2 an toàn mặc định tối thiểu 92%
                MaxStressLevel = 75,
                CustomNotes = $"Khởi tạo tự động theo công thức Tanaka cho giới tính {dto.Gender}, {age} tuổi. HRmax lý thuyết: {Math.Round(hrMaxTheoretical)} bpm."
            };

            await _dbContext.PersonalThresholds.AddAsync(personalThreshold);
            await _dbContext.SaveChangesAsync();

            // Sinh mã token JWT xác thực
            var (token, expiresAt) = GenerateJwtToken(user);

            return new AuthResponseDto
            {
                Token = token,
                UserId = user.Id,
                FullName = user.FullName,
                Email = user.Email,
                ExpiresAt = expiresAt
            };
        }

        public async Task<AuthResponseDto> LoginAsync(LoginDto dto)
        {
            var normalizedEmail = dto.Email.Trim().ToLowerInvariant();

            var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == normalizedEmail);
            if (user == null)
            {
                throw new UnauthorizedAccessException("Email hoặc mật khẩu không chính xác.");
            }

            // Kiểm tra mật khẩu mã hóa BCrypt
            var isPasswordValid = BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash);
            if (!isPasswordValid)
            {
                throw new UnauthorizedAccessException("Email hoặc mật khẩu không chính xác.");
            }

            var (token, expiresAt) = GenerateJwtToken(user);

            return new AuthResponseDto
            {
                Token = token,
                UserId = user.Id,
                FullName = user.FullName,
                Email = user.Email,
                ExpiresAt = expiresAt
            };
        }

        public async Task<UserProfileDto?> GetProfileAsync(int userId)
        {
            var user = await _dbContext.Users
                .AsNoTracking()
                .Include(u => u.PersonalThreshold)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
            {
                return null;
            }

            return new UserProfileDto
            {
                Id = user.Id,
                FullName = user.FullName,
                Email = user.Email,
                DateOfBirth = user.DateOfBirth,
                Gender = user.Gender,
                Height = user.Height,
                Weight = user.Weight,
                EmergencyContactPhone = user.EmergencyContactPhone,
                CreatedAt = user.CreatedAt,
                PersonalThreshold = user.PersonalThreshold == null ? null : new PersonalThresholdDto
                {
                    Id = user.PersonalThreshold.Id,
                    UserId = user.PersonalThreshold.UserId,
                    MinRestingHeartRate = user.PersonalThreshold.MinRestingHeartRate,
                    MaxRestingHeartRate = user.PersonalThreshold.MaxRestingHeartRate,
                    MinSpO2 = user.PersonalThreshold.MinSpO2,
                    MaxStressLevel = user.PersonalThreshold.MaxStressLevel,
                    CustomNotes = user.PersonalThreshold.CustomNotes
                }
            };
        }

        public async Task<UserProfileDto> UpdateProfileAsync(int userId, UpdateProfileDto dto)
        {
            var user = await _dbContext.Users
                .Include(u => u.PersonalThreshold)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
            {
                throw new KeyNotFoundException("Không tìm thấy thông tin người dùng.");
            }

            if (!string.IsNullOrWhiteSpace(dto.FullName))
            {
                user.FullName = dto.FullName.Trim();
            }

            if (dto.Height.HasValue && dto.Height.Value > 0)
            {
                user.Height = dto.Height.Value;
            }

            if (dto.Weight.HasValue && dto.Weight.Value > 0)
            {
                user.Weight = dto.Weight.Value;
            }

            if (!string.IsNullOrWhiteSpace(dto.EmergencyContactPhone))
            {
                user.EmergencyContactPhone = dto.EmergencyContactPhone.Trim();
            }

            await _dbContext.SaveChangesAsync();

            return (await GetProfileAsync(userId))!;
        }

        public async Task<PersonalThresholdDto?> GetThresholdAsync(int userId)
        {
            var threshold = await _dbContext.PersonalThresholds
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.UserId == userId);

            if (threshold == null)
            {
                return null;
            }

            return new PersonalThresholdDto
            {
                Id = threshold.Id,
                UserId = threshold.UserId,
                MinRestingHeartRate = threshold.MinRestingHeartRate,
                MaxRestingHeartRate = threshold.MaxRestingHeartRate,
                MinSpO2 = threshold.MinSpO2,
                MaxStressLevel = threshold.MaxStressLevel,
                CustomNotes = threshold.CustomNotes
            };
        }

        public async Task<PersonalThresholdDto> UpdateThresholdAsync(int userId, UpdateThresholdDto dto)
        {
            var threshold = await _dbContext.PersonalThresholds
                .FirstOrDefaultAsync(p => p.UserId == userId);

            if (threshold == null)
            {
                threshold = new PersonalThreshold
                {
                    UserId = userId,
                    MinRestingHeartRate = dto.MinRestingHeartRate,
                    MaxRestingHeartRate = dto.MaxRestingHeartRate,
                    MinSpO2 = dto.MinSpO2,
                    MaxStressLevel = dto.MaxStressLevel,
                    CustomNotes = dto.CustomNotes
                };
                await _dbContext.PersonalThresholds.AddAsync(threshold);
            }
            else
            {
                threshold.MinRestingHeartRate = dto.MinRestingHeartRate;
                threshold.MaxRestingHeartRate = dto.MaxRestingHeartRate;
                threshold.MinSpO2 = dto.MinSpO2;
                threshold.MaxStressLevel = dto.MaxStressLevel;
                if (!string.IsNullOrWhiteSpace(dto.CustomNotes))
                {
                    threshold.CustomNotes = dto.CustomNotes;
                }
            }

            await _dbContext.SaveChangesAsync();

            return new PersonalThresholdDto
            {
                Id = threshold.Id,
                UserId = threshold.UserId,
                MinRestingHeartRate = threshold.MinRestingHeartRate,
                MaxRestingHeartRate = threshold.MaxRestingHeartRate,
                MinSpO2 = threshold.MinSpO2,
                MaxStressLevel = threshold.MaxStressLevel,
                CustomNotes = threshold.CustomNotes
            };
        }

        private (string token, DateTime expiresAt) GenerateJwtToken(User user)
        {
            var jwtKey = _configuration["JwtSettings:Key"] ?? "HealthEmergencySuperSecretKeyForJWTAuth2026!";
            var jwtIssuer = _configuration["JwtSettings:Issuer"] ?? "HealthEmergencyBackend";
            var jwtAudience = _configuration["JwtSettings:Audience"] ?? "HealthEmergencyFlutterApp";
            var expiryMinutes = int.TryParse(_configuration["JwtSettings:ExpiryMinutes"], out var minutes) ? minutes : 10080; // 7 days

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email, user.Email),
                new Claim(ClaimTypes.Name, user.FullName),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
            };

            var expiresAt = DateTime.UtcNow.AddMinutes(expiryMinutes);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = expiresAt,
                Issuer = jwtIssuer,
                Audience = jwtAudience,
                SigningCredentials = credentials
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);

            return (tokenHandler.WriteToken(token), expiresAt);
        }
    }
}

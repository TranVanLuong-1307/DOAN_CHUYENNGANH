using System;
using System.ComponentModel.DataAnnotations;

namespace backend_DACN.DTOs
{
    public class RegisterDto
    {
        [Required(ErrorMessage = "Họ và tên không được để trống")]
        [StringLength(150, ErrorMessage = "Họ và tên tối đa 150 ký tự")]
        public string FullName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email không được để trống")]
        [EmailAddress(ErrorMessage = "Email không đúng định dạng")]
        [StringLength(200, ErrorMessage = "Email tối đa 200 ký tự")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mật khẩu không được để trống")]
        [MinLength(6, ErrorMessage = "Mật khẩu phải có ít nhất 6 ký tự")]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "Ngày sinh không được để trống")]
        public DateTime DateOfBirth { get; set; }

        [Required(ErrorMessage = "Giới tính không được để trống")]
        [RegularExpression("^(Male|Female)$", ErrorMessage = "Giới tính phải là 'Male' hoặc 'Female'")]
        public string Gender { get; set; } = "Male";

        [Range(30.0, 250.0, ErrorMessage = "Chiều cao phải từ 30 đến 250 cm")]
        public double Height { get; set; } // in cm

        [Range(10.0, 300.0, ErrorMessage = "Cân nặng phải từ 10 đến 300 kg")]
        public double Weight { get; set; } // in kg

        [Required(ErrorMessage = "Số điện thoại liên hệ khẩn cấp không được để trống")]
        [Phone(ErrorMessage = "Số điện thoại không đúng định dạng")]
        public string EmergencyContactPhone { get; set; } = string.Empty;
    }

    public class LoginDto
    {
        [Required(ErrorMessage = "Email không được để trống")]
        [EmailAddress(ErrorMessage = "Email không đúng định dạng")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Mật khẩu không được để trống")]
        public string Password { get; set; } = string.Empty;
    }

    public class AuthResponseDto
    {
        public string Token { get; set; } = string.Empty;
        public int UserId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
    }

    public class UserProfileDto
    {
        public int Id { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public DateTime DateOfBirth { get; set; }
        public string Gender { get; set; } = "Male";
        public double Height { get; set; }
        public double Weight { get; set; }
        public string EmergencyContactPhone { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public PersonalThresholdDto? PersonalThreshold { get; set; }
    }

    public class UpdateProfileDto
    {
        [StringLength(150, ErrorMessage = "Họ và tên tối đa 150 ký tự")]
        public string? FullName { get; set; }

        [Range(30.0, 250.0, ErrorMessage = "Chiều cao phải từ 30 đến 250 cm")]
        public double? Height { get; set; }

        [Range(10.0, 300.0, ErrorMessage = "Cân nặng phải từ 10 đến 300 kg")]
        public double? Weight { get; set; }

        [Phone(ErrorMessage = "Số điện thoại không đúng định dạng")]
        public string? EmergencyContactPhone { get; set; }
    }

    public class PersonalThresholdDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int MinRestingHeartRate { get; set; }
        public int MaxRestingHeartRate { get; set; }
        public double MinSpO2 { get; set; }
        public int MaxStressLevel { get; set; }
        public string? CustomNotes { get; set; }
    }

    public class UpdateThresholdDto
    {
        [Range(30, 100, ErrorMessage = "Nhịp tim nghỉ tối thiểu từ 30 đến 100 bpm")]
        public int MinRestingHeartRate { get; set; }

        [Range(80, 220, ErrorMessage = "Nhịp tim nghỉ tối đa từ 80 đến 220 bpm")]
        public int MaxRestingHeartRate { get; set; }

        [Range(70.0, 100.0, ErrorMessage = "SpO2 tối thiểu từ 70% đến 100%")]
        public double MinSpO2 { get; set; }

        [Range(1, 100, ErrorMessage = "Mức độ căng thẳng từ 1 đến 100")]
        public int MaxStressLevel { get; set; }

        public string? CustomNotes { get; set; }
    }
}

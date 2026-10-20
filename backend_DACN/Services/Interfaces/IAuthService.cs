using System.Threading.Tasks;
using backend_DACN.DTOs;

namespace backend_DACN.Services.Interfaces
{
    public interface IAuthService
    {
        Task<AuthResponseDto> RegisterAsync(RegisterDto dto);
        Task<AuthResponseDto> LoginAsync(LoginDto dto);
        Task<UserProfileDto?> GetProfileAsync(int userId);
        Task<UserProfileDto> UpdateProfileAsync(int userId, UpdateProfileDto dto);
        Task<PersonalThresholdDto?> GetThresholdAsync(int userId);
        Task<PersonalThresholdDto> UpdateThresholdAsync(int userId, UpdateThresholdDto dto);
    }
}

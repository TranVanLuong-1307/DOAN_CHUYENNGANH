using System;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using backend_DACN.DTOs;
using backend_DACN.Services.Interfaces;

namespace backend_DACN.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService _authService)
        {
            this._authService = _authService;
        }

        /// <summary>
        /// Đăng ký tài khoản người dùng mới và tự động thiết lập ngưỡng y khoa cá nhân hóa
        /// </summary>
        [HttpPost("register")]
        [AllowAnonymous]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _authService.RegisterAsync(dto);
            return Ok(new
            {
                success = true,
                message = "Đăng ký tài khoản thành công!",
                data = result
            });
        }

        /// <summary>
        /// Đăng nhập hệ thống và nhận JWT Token
        /// </summary>
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _authService.LoginAsync(dto);
            return Ok(new
            {
                success = true,
                message = "Đăng nhập thành công!",
                data = result
            });
        }

        /// <summary>
        /// Lấy thông tin hồ sơ cá nhân và ngưỡng cảnh báo của người dùng hiện tại
        /// </summary>
        [HttpGet("profile")]
        [Authorize]
        public async Task<IActionResult> GetProfile()
        {
            var userId = GetCurrentUserId();
            var profile = await _authService.GetProfileAsync(userId);
            if (profile == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy thông tin người dùng." });
            }

            return Ok(new
            {
                success = true,
                data = profile
            });
        }

        /// <summary>
        /// Cập nhật thông tin hồ sơ sức khỏe cá nhân (chiều cao, cân nặng, số điện thoại SOS)
        /// </summary>
        [HttpPut("profile")]
        [Authorize]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var userId = GetCurrentUserId();
            var updated = await _authService.UpdateProfileAsync(userId, dto);
            return Ok(new
            {
                success = true,
                message = "Cập nhật hồ sơ thành công!",
                data = updated
            });
        }

        /// <summary>
        /// Lấy cấu hình ngưỡng cảnh báo y khoa cá nhân
        /// </summary>
        [HttpGet("threshold")]
        [Authorize]
        public async Task<IActionResult> GetThreshold()
        {
            var userId = GetCurrentUserId();
            var threshold = await _authService.GetThresholdAsync(userId);
            if (threshold == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy cấu hình ngưỡng cho người dùng này." });
            }

            return Ok(new
            {
                success = true,
                data = threshold
            });
        }

        /// <summary>
        /// Tùy chỉnh ngưỡng cảnh báo y khoa cá nhân
        /// </summary>
        [HttpPut("threshold")]
        [Authorize]
        public async Task<IActionResult> UpdateThreshold([FromBody] UpdateThresholdDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var userId = GetCurrentUserId();
            var updated = await _authService.UpdateThresholdAsync(userId, dto);
            return Ok(new
            {
                success = true,
                message = "Cập nhật ngưỡng cảnh báo thành công!",
                data = updated
            });
        }

        private int GetCurrentUserId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (int.TryParse(claim, out var userId))
            {
                return userId;
            }
            throw new UnauthorizedAccessException("Không xác định được thông tin người dùng từ mã Token.");
        }
    }
}

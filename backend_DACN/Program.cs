using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using backend_DACN.Data;
using backend_DACN.Hubs;
using backend_DACN.Middlewares;
using backend_DACN.Services.Implementations;
using backend_DACN.Services.Interfaces;

var builder = WebApplication.CreateBuilder(args);

// ================= 1. CẤU HÌNH DATABASE CONTEXT (SQL SERVER) =================
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=.\\SQLEXPRESS;Database=DOANCN;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true";

builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    options.UseSqlServer(connectionString, sqlOptions =>
    {
        sqlOptions.EnableRetryOnFailure(
            maxRetryCount: 5,
            maxRetryDelay: TimeSpan.FromSeconds(10),
            errorNumbersToAdd: null);
    });
});

// ================= 2. CẤU HÌNH DEPENDENCY INJECTION CHO SERVICES =================
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IAlertRuleEngine, AlertRuleEngine>();
builder.Services.AddScoped<IBiometricService, BiometricService>();

// ================= 3. CẤU HÌNH SIGNALR =================
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = true;
    options.KeepAliveInterval = TimeSpan.FromSeconds(15);
    options.ClientTimeoutInterval = TimeSpan.FromSeconds(30);
});

// ================= 4. CẤU HÌNH XÁC THỰC JWT BEARER =================
var jwtKey = builder.Configuration["JwtSettings:Key"] ?? "HealthEmergencySuperSecretKey_ForJWTAuth2026_DotNet8BackendSystem!";
var jwtIssuer = builder.Configuration["JwtSettings:Issuer"] ?? "HealthEmergencyBackend";
var jwtAudience = builder.Configuration["JwtSettings:Audience"] ?? "HealthEmergencyFlutterApp";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidIssuer = jwtIssuer,
        ValidateAudience = true,
        ValidAudience = jwtAudience,
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero,
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
    };

    // Hỗ trợ truyền Bearer Token qua Query String khi Client kết nối SignalR WebSocket
    options.Events = new JwtBearerEvents
    {
        OnMessageReceived = context =>
        {
            var accessToken = context.Request.Query["access_token"];
            var path = context.HttpContext.Request.Path;
            if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/hubs"))
            {
                context.Token = accessToken;
            }
            return Task.CompletedTask;
        }
    };
});

builder.Services.AddAuthorization();

// ================= 5. CẤU HÌNH CORS CHO FLUTTER APP & MÁY ẢO ANDROID =================
builder.Services.AddCors(options =>
{
    options.AddPolicy("CorsPolicy", policy =>
    {
        policy.SetIsOriginAllowed(_ => true) // Chấp nhận mọi nguồn gốc (Emulator 10.0.2.2, localhost, LAN IP)
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials(); // Bắt buộc để truyền tải Token qua SignalR
    });
});

// ================= 6. CẤU HÌNH CONTROLLERS & JSON OPTIONS =================
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
    });

// ================= 7. CẤU HÌNH SWAGGER UI VỚI BEARER TOKEN AUTHORIZATION =================
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Hệ thống Quản lý Sức khỏe & Cảnh báo Khẩn cấp Cá nhân API",
        Version = "v1",
        Description = "ASP.NET Core 8 Web API - Kết nối SQL Server & Ứng dụng Di động Flutter. Hỗ trợ cảnh báo thời gian thực qua SignalR Hub."
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "Nhập mã Bearer Token theo định dạng: Bearer {chuỗi_token_của_bạn}",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

// ================= 8. HTTP REQUEST PIPELINE =================
// Middleware xử lý lỗi tập trung toàn hệ thống
app.UseMiddleware<GlobalExceptionMiddleware>();

if (app.Environment.IsDevelopment() || true) // Luôn bật Swagger cho đồ án dễ kiểm thử và chấm điểm
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Health & Emergency Alert API v1");
        c.RoutePrefix = "swagger"; // Phục vụ tại /swagger để tương thích 100% với cấu hình launchUrl của Visual Studio
    });
}

app.UseCors("CorsPolicy");

app.UseAuthentication();
app.UseAuthorization();

// Đăng ký Controllers
app.MapControllers();

// Đăng ký SignalR Hub cho cảnh báo khẩn cấp cá nhân
app.MapHub<EmergencyHub>("/hubs/emergency");

// Tự động chuyển hướng từ trang chủ "/" sang "/swagger" (ẩn khỏi Swagger UI bằng ExcludeFromDescription)
app.MapGet("/", () => Results.Redirect("/swagger")).ExcludeFromDescription();

// ================= 9. TỰ ĐỘNG CẬP NHẬT DATABASE MIGRATION KHI KHỞI ĐỘNG =================
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<ApplicationDbContext>();
        context.Database.Migrate();
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogWarning(ex, "LƯU Ý: Chưa thể áp dụng Database Migration vào SQL Server lúc khởi động. Vui lòng kiểm tra lại SQL Server.");
    }
}

app.Run();

using System;
using System.Threading.Tasks;
using backend_DACN.DTOs;

namespace backend_DACN.Services.Interfaces
{
    public interface IBiometricService
    {
        Task<BiometricRecordDto> AddBiometricRecordAsync(int userId, CreateBiometricRecordDto dto);
        Task<PagedResultDto<BiometricRecordDto>> GetHistoryAsync(int userId, DateTime? startDate, DateTime? endDate, int pageNumber, int pageSize);
        Task<BiometricChartSummaryDto> GetChartSummaryAsync(int userId, DateTime date);
        Task<BiometricRecordDto?> GetLatestBiometricAsync(int userId);
    }
}

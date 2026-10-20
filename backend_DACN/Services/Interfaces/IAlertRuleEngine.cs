using System.Collections.Generic;
using System.Threading.Tasks;
using backend_DACN.Models;

namespace backend_DACN.Services.Interfaces
{
    public interface IAlertRuleEngine
    {
        /// <summary>
        /// Đánh giá các chỉ số sinh học dựa trên thuật toán Rule-based y khoa cá nhân hóa.
        /// Tự động sinh cảnh báo, ghi cơ sở dữ liệu và phát tín hiệu SignalR nếu có vi phạm.
        /// </summary>
        /// <param name="userId">Mã định danh người dùng</param>
        /// <param name="record">Bản ghi sinh học cần đánh giá</param>
        /// <returns>Danh sách các cảnh báo khẩn cấp được kích hoạt</returns>
        Task<List<EmergencyAlert>> EvaluateBiometricsAsync(int userId, BiometricRecord record);
    }
}

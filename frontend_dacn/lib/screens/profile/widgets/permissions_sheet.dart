import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PermissionsSheet extends StatelessWidget {
  final AppState appState;

  const PermissionsSheet({super.key, required this.appState});

  static void show(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => PermissionsSheet(appState: appState),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final totalGranted = [
          appState.permLocation,
          appState.permSensors,
          appState.permBluetooth,
          appState.permActivity,
          appState.permNotification,
          appState.permStorage,
          appState.permCamera,
        ].where((e) => e).length;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Row with Gear Icon + Title + Close Button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.pillActive,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.settings_suggest_rounded,
                          color: AppColors.primaryMintDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cấp quyền ứng dụng',
                              style: AppTextStyles.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Đã cấp $totalGranted / 7 quyền hệ thống',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryMintDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Đóng',
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Master Grant All Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurfaceAccent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryMint.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.primaryMintDark,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tối ưu hóa tính năng',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Cấp quyền nhanh để app đo nhịp tim & GPS chính xác',
                                style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryMint,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            appState.grantAllPermissions();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã cấp đầy đủ tất cả các quyền cho ứng dụng!'),
                                backgroundColor: AppColors.primaryMintDark,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text(
                            'Cấp tất cả',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Permission Item 1: Vị trí & GPS
                  _buildPermissionTile(
                    icon: Icons.location_on_outlined,
                    iconBg: AppColors.cardSurfaceAccent,
                    iconColor: AppColors.primaryMintDark,
                    title: 'Vị trí & GPS (Chính xác)',
                    subtitle: 'Đo cự ly, vẽ bản đồ lộ trình chạy bộ và quét thiết bị Bluetooth xung quanh',
                    isGranted: appState.permLocation,
                    onChanged: (v) => appState.togglePermission('location', v),
                  ),
                  const Divider(color: AppColors.border, height: 1),

                  // Permission Item 2: Cảm biến cơ thể & Nhịp tim
                  _buildPermissionTile(
                    icon: Icons.favorite_outline_rounded,
                    iconBg: const Color(0xFFFFF0F3),
                    iconColor: AppColors.heartRed,
                    title: 'Cảm biến cơ thể & Nhịp tim',
                    subtitle: 'Theo dõi nhịp tim thời gian thực, nồng độ oxy SpO2 và mức độ căng thẳng',
                    isGranted: appState.permSensors,
                    onChanged: (v) => appState.togglePermission('sensors', v),
                  ),
                  const Divider(color: AppColors.border, height: 1),

                  // Permission Item 3: Bluetooth & Thiết bị lân cận
                  _buildPermissionTile(
                    icon: Icons.bluetooth_rounded,
                    iconBg: AppColors.cardSurfaceBlue,
                    iconColor: AppColors.spo2Blue,
                    title: 'Bluetooth & Thiết bị lân cận',
                    subtitle: 'Kết nối liên tục, đồng bộ mặt đồng hồ và nhận thông báo từ Smart Watch',
                    isGranted: appState.permBluetooth,
                    onChanged: (v) => appState.togglePermission('bluetooth', v),
                  ),
                  const Divider(color: AppColors.border, height: 1),

                  // Permission Item 4: Hoạt động thể chất
                  _buildPermissionTile(
                    icon: Icons.directions_walk_rounded,
                    iconBg: AppColors.cardSurfaceAccent,
                    iconColor: AppColors.primaryMintDark,
                    title: 'Hoạt động thể chất & Đếm bước',
                    subtitle: 'Tự động đếm số bước chân và tính lượng calo tiêu hao hàng ngày',
                    isGranted: appState.permActivity,
                    onChanged: (v) => appState.togglePermission('activity', v),
                  ),
                  const Divider(color: AppColors.border, height: 1),

                  // Permission Item 5: Thông báo & Cảnh báo
                  _buildPermissionTile(
                    icon: Icons.notifications_none_rounded,
                    iconBg: AppColors.cardSurfaceYellow,
                    iconColor: AppColors.stressActive,
                    title: 'Thông báo & Nhắc nhở sức khỏe',
                    subtitle: 'Gửi nhắc nhở uống nước, vận động khi ngồi lâu và cảnh báo nhịp tim',
                    isGranted: appState.permNotification,
                    onChanged: (v) async {
                      appState.togglePermission('notification', v);
                      if (v) {
                        try {
                          await _platform.invokeMethod('requestNotificationPermission');
                        } catch (_) {}
                      }
                    },
                  ),
                  const Divider(color: AppColors.border, height: 1),

                  // Permission Item 6: Bộ nhớ & Tệp
                  _buildPermissionTile(
                    icon: Icons.folder_open_rounded,
                    iconBg: AppColors.avatarBg,
                    iconColor: AppColors.textSecondary,
                    title: 'Bộ nhớ & Xuất dữ liệu',
                    subtitle: 'Lưu trữ hình ảnh lộ trình tập luyện và xuất tệp báo cáo PDF/JSON',
                    isGranted: appState.permStorage,
                    onChanged: (v) => appState.togglePermission('storage', v),
                  ),
                  const Divider(color: AppColors.border, height: 1),

                  // Permission Item 7: Máy ảnh
                  _buildPermissionTile(
                    icon: Icons.camera_alt_outlined,
                    iconBg: AppColors.avatarBg,
                    iconColor: AppColors.textSecondary,
                    title: 'Máy ảnh (Camera)',
                    subtitle: 'Quét mã QR trên màn hình đồng hồ để ghép đôi nhanh chóng',
                    isGranted: appState.permCamera,
                    onChanged: (v) => appState.togglePermission('camera', v),
                  ),
                  const SizedBox(height: 18),

                  // System App Settings Action Button (Redesigned as a Premium Interactive Card)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openSystemAppSettings(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceAccent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryMint.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryMint.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.pillActive,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.settings_applications_rounded,
                                color: AppColors.primaryMintDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mở Cài đặt Ứng dụng trong Hệ thống',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Chuyển đến Cài đặt Android để cấp quyền trực tiếp',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryMint.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.open_in_new_rounded,
                                size: 16,
                                color: AppColors.primaryMintDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static const MethodChannel _platform = MethodChannel('com.example.frontend_dacn/settings');

  Future<void> _openSystemAppSettings(BuildContext context) async {
    try {
      await _platform.invokeMethod('openAppSettings');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng mở Cài đặt thiết bị > Ứng dụng > frontend_dacn để cấp quyền.'),
            backgroundColor: AppColors.primaryMintDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isGranted,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isGranted ? AppColors.pillActive : AppColors.avatarBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isGranted ? 'ĐÃ CẤP' : 'CHƯA CẤP',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isGranted ? AppColors.primaryMintDark : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(fontSize: 11, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: isGranted,
            activeTrackColor: AppColors.primaryMint,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

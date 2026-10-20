import 'package:flutter/material.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  bool _isSyncing = false;
  bool _autoHeart = true;
  bool _autoSpo2 = true;
  bool _autoStress = false;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 24,
          ),
          children: [
            // Top Bar (Overflow-safe with Expanded)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Thiết bị',
                    style: AppTextStyles.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _showAddDeviceSheet(context, appState),
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.primaryMint,
                    size: 26,
                  ),
                ),
              ],
            ),
            // Active Device Card / Empty Skeleton Card
            if (appState.deviceName.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.avatarBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.watch_off_outlined,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chưa kết nối thiết bị nào',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ghép đôi Smart Watch hoặc vòng đeo tay để bắt đầu tự động đo nhịp tim, giấc ngủ và bước chân.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Thêm thiết bị mới'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMint,
                        foregroundColor: AppColors.primaryDarkText,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showAddDeviceSheet(context, appState),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.6),
                  ),
                ),
                child: Column(
                  children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.avatarBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.watch_rounded,
                          color: AppColors.primaryMint,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.deviceName,
                              style: AppTextStyles.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: appState.isDeviceConnected
                                        ? AppColors.primaryMint
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    appState.isDeviceConnected
                                        ? 'Đã kết nối  ·  Pin ${appState.deviceBattery}%'
                                        : 'Đã ngắt kết nối',
                                    style: AppTextStyles.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: appState.isDeviceConnected,
                        activeTrackColor: AppColors.primaryMint,
                        onChanged: (val) {
                          appState.setDeviceConnected(val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDeviceAction(
                        icon: _isSyncing ? Icons.hourglass_top_rounded : Icons.sync_rounded,
                        label: _isSyncing ? 'Đang đồng bộ...' : 'Đồng bộ ngay',
                        onTap: _handleSync,
                      ),
                      _buildDeviceAction(
                        icon: Icons.palette_outlined,
                        label: 'Mặt đồng hồ',
                        onTap: () => _showWatchFacesSheet(context),
                      ),
                      _buildDeviceAction(
                        icon: Icons.notifications_none_rounded,
                        label: 'Thông báo',
                        onTap: () => _showNotificationSettingsSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section: Health Monitoring Settings
            Text(
              'Quản lý theo dõi sức khỏe',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.heartRed,
                    title: 'Đo nhịp tim liên tục (24/7)',
                    subtitle: 'Cảnh báo khi nhịp tim bất thường',
                    value: _autoHeart,
                    onChanged: (v) => setState(() => _autoHeart = v),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildSettingTile(
                    icon: Icons.water_drop_outlined,
                    iconColor: AppColors.spo2Blue,
                    title: 'Theo dõi Oxy trong máu (SpO₂)',
                    subtitle: 'Tự động đo trong lúc ngủ',
                    value: _autoSpo2,
                    onChanged: (v) => setState(() => _autoSpo2 = v),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  _buildSettingTile(
                    icon: Icons.psychology_outlined,
                    iconColor: AppColors.stressActive,
                    title: 'Theo dõi căng thẳng tự động',
                    subtitle: 'Nhắc nhở hít thở thư giãn',
                    value: _autoStress,
                    onChanged: (v) => setState(() => _autoStress = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSync() {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dữ liệu bước chân và nhịp tim đã được đồng bộ thành công!')),
      );
    });
  }

  void _showAddDeviceSheet(BuildContext context, AppState appState) {
    final nearbyDevices = [
      'Smart Watch Active 2',
      'Mi Smart Band 8 Pro',
      'Garmin Forerunner 255',
      'Galaxy Watch 6',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryMint),
                    ),
                    const SizedBox(width: 10),
                    Text('Đang quét thiết bị Bluetooth gần đây...', style: AppTextStyles.titleSmall),
                  ],
                ),
                const SizedBox(height: 14),
                ...nearbyDevices.map((d) => ListTile(
                      leading: const Icon(Icons.bluetooth_searching_rounded, color: AppColors.primaryMint),
                      title: Text(d, style: AppTextStyles.titleSmall),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryMint,
                          foregroundColor: AppColors.primaryDarkText,
                        ),
                        onPressed: () {
                          appState.deviceName = d;
                          appState.deviceBattery = 100;
                          appState.setDeviceConnected(true);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã kết nối thành công với $d!')),
                          );
                        },
                        child: const Text('Ghép đôi'),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWatchFacesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Kho mặt đồng hồ thể thao', style: AppTextStyles.titleMedium),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWatchFaceItem('Neon Sport', AppColors.primaryMint),
                    _buildWatchFaceItem('Minimal Dark', AppColors.border),
                    _buildWatchFaceItem('Cyber Pulse', AppColors.spo2Blue),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWatchFaceItem(String title, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            alignment: Alignment.center,
            child: const Text('10:24', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(title, style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Cài đặt thông báo thiết bị', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Cuộc gọi đến & Rung', style: AppTextStyles.titleSmall),
                  value: true,
                  activeTrackColor: AppColors.primaryMint,
                  onChanged: (v) {},
                ),
                SwitchListTile(
                  title: Text('Tin nhắn & Ứng dụng', style: AppTextStyles.titleSmall),
                  value: true,
                  activeTrackColor: AppColors.primaryMint,
                  onChanged: (v) {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primaryMint, size: 22),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: AppTextStyles.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.primaryMint,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

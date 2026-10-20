import 'package:flutter/material.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/health_step_card.dart';
import 'widgets/health_metric_card.dart';
import 'widgets/sleep_chart_widget.dart';
import 'widgets/hrv_chart_widget.dart';
import 'widgets/stress_level_widget.dart';
import 'widgets/health_detail_sheets.dart';

class HealthScreen extends StatelessWidget {
  final VoidCallback? onAvatarTap;
  final VoidCallback? onCustomizeTap;

  const HealthScreen({
    super.key,
    this.onAvatarTap,
    this.onCustomizeTap,
  });

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
            // Header: Date, Screen Title & Avatar (Fixed overflow with Expanded)
            _buildHeader(context, appState),
            const SizedBox(height: 16),

            // Step Progress Card (Interactive onTap)
            HealthStepCard(
              currentSteps: appState.currentSteps,
              targetSteps: appState.targetSteps,
              distanceKm: appState.distanceKm,
              caloriesKcal: appState.caloriesKcal,
              durationMinutes: appState.durationMinutes,
              onTap: () => HealthDetailSheets.showStepTargetSheet(context, appState),
            ),
            const SizedBox(height: 20),

            // Health Metrics Section Header (Fixed overflow with Expanded)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Chỉ số sức khỏe',
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => HealthDetailSheets.showCustomizeMetricsSheet(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Text(
                      'Tùy chỉnh',
                      style: AppTextStyles.bodyMint,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Metrics Grid Row 1: Cân nặng & Giấc ngủ
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: HealthMetricCard(
                    icon: Icons.monitor_weight_outlined,
                    iconColor: AppColors.textSecondary,
                    title: 'Cân nặng',
                    value: appState.weightKg > 0 ? appState.weightKg.toString().replaceAll('.', ',') : '--',
                    unit: appState.weightKg > 0 ? 'kg' : '',
                    subtitle: appState.weightKg > 0
                        ? '${appState.weightDelta <= 0 ? "↓" : "↑"} ${appState.weightDelta.abs().toString().replaceAll(".", ",")} kg so với tuần trước'
                        : 'Chưa có dữ liệu cân nặng',
                    onTap: () => HealthDetailSheets.showWeightRecordSheet(context, appState),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HealthMetricCard(
                    icon: Icons.bedtime_outlined,
                    iconColor: AppColors.sleepLight,
                    title: 'Giấc ngủ',
                    value: (appState.sleepHours > 0 || appState.sleepMinutes > 0) ? '${appState.sleepHours}' : '--',
                    unit: (appState.sleepHours > 0 || appState.sleepMinutes > 0) ? 'giờ ${appState.sleepMinutes} phút' : '',
                    customWidget: (appState.sleepHours > 0 || appState.sleepMinutes > 0) ? const SleepChartWidget() : null,
                    subtitle: (appState.sleepHours > 0 || appState.sleepMinutes > 0) ? 'Chất lượng tốt · 88 điểm' : 'Chưa có dữ liệu giấc ngủ',
                    onTap: () => HealthDetailSheets.showSleepDetailSheet(context, appState),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Metrics Grid Row 2: Nhịp tim & Oxy trong máu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: HealthMetricCard(
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.heartRed,
                    title: 'Nhịp tim',
                    value: appState.heartRate > 0 ? '${appState.heartRate}' : '--',
                    unit: appState.heartRate > 0 ? 'bpm' : '',
                    subtitle: appState.heartRate > 0 ? 'Lúc nghỉ · Bình thường' : 'Chưa có dữ liệu nhịp tim',
                    onTap: () => HealthDetailSheets.showHeartRateSheet(context, appState),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HealthMetricCard(
                    icon: Icons.water_drop_outlined,
                    iconColor: AppColors.spo2Blue,
                    title: 'Oxy trong máu',
                    value: appState.spo2 > 0 ? '${appState.spo2}' : '--',
                    unit: appState.spo2 > 0 ? '%' : '',
                    subtitle: appState.spo2 > 0 ? 'SpO₂ · Trong ngưỡng tốt' : 'Chưa có dữ liệu SpO₂',
                    onTap: () => HealthDetailSheets.showSpo2Sheet(context, appState),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Metrics Grid Row 3: Biến thiên nhịp tim & Căng thẳng
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: HealthMetricCard(
                    icon: Icons.graphic_eq_rounded,
                    iconColor: AppColors.primaryMint,
                    title: 'Biến thiên nhịp tim',
                    value: appState.hrv > 0 ? '${appState.hrv}' : '--',
                    unit: appState.hrv > 0 ? 'ms' : '',
                    customWidget: appState.hrv > 0 ? const HrvChartWidget() : null,
                    subtitle: appState.hrv > 0 ? 'HRV · Phục hồi tốt' : 'Chưa có dữ liệu HRV',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('HRV: Hệ thần kinh tự chủ đang trong trạng thái cân bằng tốt!')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HealthMetricCard(
                    icon: Icons.psychology_outlined,
                    iconColor: AppColors.stressActive,
                    title: 'Căng thẳng',
                    value: appState.stressLevel > 0 ? '${appState.stressLevel}' : '--',
                    unit: appState.stressLevel > 0 ? '/100' : '',
                    customWidget: appState.stressLevel > 0 ? const StressLevelWidget() : null,
                    subtitle: appState.stressLevel > 0
                        ? (appState.stressLevel > 60 ? 'Khá cao · Chạm để thư giãn' : 'Thư giãn · Bình thường')
                        : 'Chưa có dữ liệu căng thẳng',
                    subtitleColor: appState.stressLevel > 60 ? AppColors.stressActive : AppColors.primaryMint,
                    onTap: () => HealthDetailSheets.showStressBreathingSheet(context, appState),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Footer info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sync_rounded,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Khung giao diện · Chờ kết nối dữ liệu từ Backend',
                    style: AppTextStyles.tinyMuted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getFormattedDate(),
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Sức khỏe',
                style: AppTextStyles.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.avatarBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: (appState.isLoggedIn && appState.userName.isNotEmpty)
                ? Text(
                    _getInitials(appState.userName),
                    style: const TextStyle(
                      color: AppColors.primaryMint,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
          ),
        ),
      ],
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật'
    ];
    final weekdayName = weekdays[now.weekday - 1];
    return '$weekdayName, ${now.day} tháng ${now.month}';
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[parts.length - 1].isNotEmpty) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

import 'package:flutter/material.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/exercise_type_selector.dart';
import 'widgets/exercise_start_button.dart';
import 'widgets/exercise_history_card.dart';
import 'widgets/exercise_plan_banner.dart';
import 'live_workout_screen.dart';

class ExerciseScreen extends StatefulWidget {
  final VoidCallback? onSettingsTap;
  final VoidCallback? onDeviceConnectTap;
  final VoidCallback? onTargetTap;

  const ExerciseScreen({
    super.key,
    this.onSettingsTap,
    this.onDeviceConnectTap,
    this.onTargetTap,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _selectedTypeIndex = 0; // 0: Chạy bộ, 1: Đạp xe, 2: Đi bộ

  final List<String> _targetDistances = ['5,00 km', '20,00 km', '3,00 km'];
  final List<String> _planDescriptions = [
    'Chinh phục 5 km theo nhịp của bạn',
    'Thử thách sức bền 20 km trên đường dài',
    'Hoàn thành 10.000 bước đi bộ mỗi ngày',
  ];

  final List<IconData> _typeIcons = [
    Icons.directions_run_rounded,
    Icons.directions_bike_rounded,
    Icons.directions_walk_rounded,
  ];

  final List<String> _typeNames = ['Chạy bộ', 'Đạp xe', 'Đi bộ'];

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
            // Top Bar: Title & Settings (Overflow-safe with Expanded)
            _buildTopBar(context),
            const SizedBox(height: 14),

            // Exercise Category Selector
            ExerciseTypeSelector(
              selectedIndex: _selectedTypeIndex,
              onSelected: (index) {
                setState(() {
                  _selectedTypeIndex = index;
                });
              },
            ),
            const SizedBox(height: 12),

            // Quick Status & Target Cards (Overflow-safe with minHeight & Expanded)
            _buildQuickActionCards(context, appState),
            const SizedBox(height: 14),

            // Start Exercise Hero Arena (Tap opens Live Active Workout!)
            ExerciseStartHero(
              modeName: 'NGOÀI TRỜI',
              onStart: () {
                _navigateToLiveWorkout();
              },
            ),
            const SizedBox(height: 20),

            // Workout History Header (Overflow-safe with Expanded)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Lịch sử tập luyện',
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAllHistorySheet(context, appState),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Text(
                      'Xem tất cả',
                      style: AppTextStyles.bodyMint,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Workout History List Card (Live from AppState)
            ExerciseHistoryCard(
              items: appState.workoutHistory,
              onItemTap: (workout) {
                _showWorkoutDetailSheet(context, workout);
              },
            ),
            const SizedBox(height: 14),

            // Plan Creation Banner (Interactive)
            ExercisePlanBanner(
              onTap: () => _showPlanEnrollmentSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Bài tập',
            style: AppTextStyles.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        InkWell(
          onTap: () => _showExerciseSettingsSheet(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Cài đặt',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCards(BuildContext context, AppState appState) {
    return Row(
      children: [
        // Device Connection Card
        Expanded(
          child: InkWell(
            onTap: () => _showDeviceConnectSheet(context, appState),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: appState.isDeviceConnected
                      ? AppColors.primaryMint.withValues(alpha: 0.5)
                      : AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.watch_rounded,
                    color: appState.isDeviceConnected
                        ? AppColors.primaryMint
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Thiết bị',
                          style: AppTextStyles.tinyMuted,
                          maxLines: 1,
                        ),
                        Text(
                          appState.isDeviceConnected ? 'Đã kết nối' : 'Chưa kết nối',
                          style: AppTextStyles.metricTitle.copyWith(
                            color: appState.isDeviceConnected
                                ? AppColors.primaryMint
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Target Distance Card
        Expanded(
          child: InkWell(
            onTap: () => _showTargetSelectSheet(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.flag_rounded,
                    color: AppColors.primaryMint,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mục tiêu',
                          style: AppTextStyles.tinyMuted,
                          maxLines: 1,
                        ),
                        Text(
                          _targetDistances[_selectedTypeIndex],
                          style: AppTextStyles.metricTitle.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToLiveWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveWorkoutScreen(
          workoutName: _typeNames[_selectedTypeIndex],
          icon: _typeIcons[_selectedTypeIndex],
        ),
      ),
    );
  }

  void _showDeviceConnectSheet(BuildContext context, AppState appState) {
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
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                Text('Kết nối thiết bị theo dõi', style: AppTextStyles.titleMedium),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: AppColors.avatarBg, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.watch_rounded, color: AppColors.primaryMint),
                  ),
                  title: Text(appState.deviceName, style: AppTextStyles.titleSmall),
                  subtitle: Text(
                    appState.isDeviceConnected ? 'Đang kết nối · Pin ${appState.deviceBattery}%' : 'Đang ở gần · Sẵn sàng kết nối',
                    style: AppTextStyles.caption,
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appState.isDeviceConnected ? AppColors.border : AppColors.primaryMint,
                      foregroundColor: appState.isDeviceConnected ? AppColors.textPrimary : AppColors.primaryDarkText,
                    ),
                    onPressed: () {
                      appState.toggleDeviceConnection();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(appState.isDeviceConnected ? 'Đã ngắt kết nối thiết bị!' : 'Đã kết nối thành công với ${appState.deviceName}!'),
                        ),
                      );
                    },
                    child: Text(appState.isDeviceConnected ? 'Ngắt' : 'Kết nối'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTargetSelectSheet(BuildContext context) {
    final targets = ['3,00 km', '5,00 km', '10,00 km', '21,00 km (Half)', '42,00 km (Full)'];
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
                Text('Chọn mục tiêu cự ly', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                ...targets.map((t) => ListTile(
                      title: Text(t, style: AppTextStyles.titleSmall),
                      trailing: _targetDistances[_selectedTypeIndex] == t
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryMint)
                          : null,
                      onTap: () {
                        setState(() {
                          _targetDistances[_selectedTypeIndex] = t;
                        });
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExerciseSettingsSheet(BuildContext context) {
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
                Text('Cài đặt bài tập', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text('Định vị GPS độ chính xác cao', style: AppTextStyles.titleSmall),
                  subtitle: Text('Ghi lại đường chạy chi tiết', style: AppTextStyles.caption),
                  value: true,
                  activeTrackColor: AppColors.primaryMint,
                  onChanged: (val) {},
                ),
                SwitchListTile(
                  title: Text('Tự động dừng (Auto-pause)', style: AppTextStyles.titleSmall),
                  subtitle: Text('Tạm dừng thời gian khi dừng đèn đỏ', style: AppTextStyles.caption),
                  value: true,
                  activeTrackColor: AppColors.primaryMint,
                  onChanged: (val) {},
                ),
                SwitchListTile(
                  title: Text('Thông báo giọng nói mỗi 1 km', style: AppTextStyles.titleSmall),
                  subtitle: Text('Đọc pace và thời gian qua tai nghe', style: AppTextStyles.caption),
                  value: false,
                  activeTrackColor: AppColors.primaryMint,
                  onChanged: (val) {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWorkoutDetailSheet(BuildContext context, WorkoutRecord workout) {
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
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(workout.icon, color: AppColors.primaryMint),
                    const SizedBox(width: 8),
                    Text(workout.title, style: AppTextStyles.titleMedium),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${workout.distanceKm} km',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildModalMetric('Thời gian', workout.duration),
                    _buildModalMetric('Tốc độ', workout.pace),
                    _buildModalMetric('Calo', '${workout.calories} kcal'),
                    _buildModalMetric('Ngày', workout.date),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildModalMetric(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.tinyMuted),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleSmall),
      ],
    );
  }

  void _showAllHistorySheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Tất cả lịch sử tập luyện', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 16),
                  ExerciseHistoryCard(
                    items: appState.workoutHistory,
                    onItemTap: (w) => _showWorkoutDetailSheet(context, w),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPlanEnrollmentSheet(BuildContext context) {
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
                Text('Kế hoạch: ${_typeNames[_selectedTypeIndex]}', style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                Text(
                  _planDescriptions[_selectedTypeIndex],
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMint,
                    foregroundColor: AppColors.primaryDarkText,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã kích hoạt ${_planDescriptions[_selectedTypeIndex]}! Buổi tập đầu tiên vào ngày mai.')),
                    );
                  },
                  child: const Text('Bắt đầu kế hoạch ngay', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

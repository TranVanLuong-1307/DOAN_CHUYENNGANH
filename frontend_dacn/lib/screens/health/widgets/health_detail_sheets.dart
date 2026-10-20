import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HealthDetailSheets {
  // 1. STEP TARGET SHEET
  static void showStepTargetSheet(BuildContext context, AppState appState) {
    double currentVal = (appState.targetSteps >= 3000 && appState.targetSteps <= 20000)
        ? appState.targetSteps.toDouble()
        : 8000.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Mục tiêu bước chân mỗi ngày', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '${currentVal.toInt()} bước',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMint,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: currentVal.clamp(3000.0, 20000.0),
                      min: 3000,
                      max: 20000,
                      divisions: 34,
                      activeColor: AppColors.primaryMint,
                      inactiveColor: AppColors.pillActive,
                      onChanged: (val) {
                        setState(() {
                          currentVal = (val / 500).round() * 500;
                        });
                      },
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
                        appState.updateTargetSteps(currentVal.toInt());
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã cập nhật mục tiêu: ${currentVal.toInt()} bước!')),
                        );
                      },
                      child: const Text('Lưu mục tiêu', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 2. WEIGHT RECORD SHEET
  static void showWeightRecordSheet(BuildContext context, AppState appState) {
    final controller = TextEditingController(text: appState.weightKg.toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monitor_weight_outlined, color: AppColors.primaryMint),
                  const SizedBox(width: 8),
                  Text('Ghi nhận cân nặng hôm nay', style: AppTextStyles.titleMedium),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  suffixText: 'kg',
                  suffixStyle: AppTextStyles.titleMedium,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
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
                  final parsed = double.tryParse(controller.text.replaceAll(',', '.'));
                  if (parsed != null && parsed > 20 && parsed < 250) {
                    appState.updateWeight(parsed);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã lưu cân nặng mới: $parsed kg')),
                    );
                  }
                },
                child: const Text('Lưu cân nặng', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. SLEEP DETAIL SHEET
  static void showSleepDetailSheet(BuildContext context, AppState appState) {
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
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.bedtime_outlined, color: AppColors.sleepLight),
                    const SizedBox(width: 8),
                    Text('Chi tiết giấc ngủ đêm qua', style: AppTextStyles.titleMedium),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSleepItem('Ngủ sâu', '2h 15m', AppColors.sleepDark),
                      _buildSleepItem('Ngủ nông', '4h 05m', AppColors.sleepLight),
                      _buildSleepItem('REM', '1h 12m', AppColors.primaryMint),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Đi ngủ: 23:15  ·  Thức dậy: 06:47  ·  Điểm giấc ngủ: 88/100 (Tốt)',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildSleepItem(String label, String duration, Color color) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(duration, style: AppTextStyles.titleSmall),
      ],
    );
  }

  // 4. HEART RATE LIVE MEASUREMENT SHEET
  static void showHeartRateSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _LiveHeartRateWidget(appState: appState);
      },
    );
  }

  // 5. SPO2 MEASUREMENT SHEET
  static void showSpo2Sheet(BuildContext context, AppState appState) {
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
                    const Icon(Icons.water_drop_outlined, color: AppColors.spo2Blue),
                    const SizedBox(width: 8),
                    Text('Độ bão hòa Oxy trong máu (SpO₂)', style: AppTextStyles.titleMedium),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${appState.spo2}%',
                  style: GoogleFonts.inter(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: AppColors.spo2Blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tình trạng bình thường: 95% - 100%',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Đo lại SpO₂ ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pillActive,
                    foregroundColor: AppColors.primaryMint,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    appState.recordSpo2(99);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kết quả đo SpO₂ mới: 99% - Tốt')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 6. STRESS & BREATHING GUIDE SHEET
  static void showStressBreathingSheet(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _BreathingGuideWidget(appState: appState);
      },
    );
  }

  // 7. CUSTOMIZE METRICS
  static void showCustomizeMetricsSheet(BuildContext context) {
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
                Text('Tùy chỉnh chỉ số hiển thị', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                _buildCheckbox('Cân nặng & BMI', true),
                _buildCheckbox('Giấc ngủ & Chu kỳ', true),
                _buildCheckbox('Nhịp tim & Cảnh báo', true),
                _buildCheckbox('Oxy trong máu (SpO₂)', true),
                _buildCheckbox('Biến thiên nhịp tim (HRV)', true),
                _buildCheckbox('Mức độ căng thẳng (Stress)', true),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildCheckbox(String title, bool val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
          const Icon(Icons.check_circle_rounded, color: AppColors.primaryMint, size: 20),
        ],
      ),
    );
  }
}

// Stateful Live Heart Rate Measurement with pulsing animation
class _LiveHeartRateWidget extends StatefulWidget {
  final AppState appState;
  const _LiveHeartRateWidget({required this.appState});

  @override
  State<_LiveHeartRateWidget> createState() => _LiveHeartRateWidgetState();
}

class _LiveHeartRateWidgetState extends State<_LiveHeartRateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _isMeasuring = false;
  int _currentBpm = 72;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentBpm = widget.appState.heartRate;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startMeasurement() {
    setState(() {
      _isMeasuring = true;
    });
    _animController.repeat(reverse: true);

    int count = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      count++;
      setState(() {
        _currentBpm = 70 + (count % 8);
      });
      if (count >= 8) {
        t.cancel();
        _animController.stop();
        _animController.reset();
        setState(() {
          _isMeasuring = false;
        });
        widget.appState.recordHeartRate(_currentBpm);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật nhịp tim: $_currentBpm bpm!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Đo nhịp tim thời gian thực', style: AppTextStyles.titleMedium),
            const SizedBox(height: 24),
            ScaleTransition(
              scale: _scaleAnim,
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.heartRed,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$_currentBpm bpm',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _isMeasuring ? 'Đang cảm biến nhịp đập...' : 'Lúc nghỉ · Bình thường',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryMint,
                foregroundColor: AppColors.primaryDarkText,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isMeasuring ? null : _startMeasurement,
              child: Text(
                _isMeasuring ? 'Đang đo...' : 'Đo ngay',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stateful Breathing Guide
class _BreathingGuideWidget extends StatefulWidget {
  final AppState appState;
  const _BreathingGuideWidget({required this.appState});

  @override
  State<_BreathingGuideWidget> createState() => _BreathingGuideWidgetState();
}

class _BreathingGuideWidgetState extends State<_BreathingGuideWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _guideText = 'Hít vào thật sâu (4s)...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _guideText = 'Thở ra từ từ (4s)...');
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() => _guideText = 'Hít vào thật sâu (4s)...');
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text('Bài tập hít thở giảm căng thẳng', style: AppTextStyles.titleMedium),
            const SizedBox(height: 30),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final size = 100.0 + _controller.value * 60.0;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMint.withValues(alpha: 0.2 + _controller.value * 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryMint, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.air_rounded, color: AppColors.primaryMint, size: 36),
                );
              },
            ),
            const SizedBox(height: 30),
            Text(_guideText, style: AppTextStyles.titleSmall),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pillActive,
                foregroundColor: AppColors.primaryMint,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                widget.appState.recordStress(45);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mức căng thẳng đã giảm xuống 45/100 (Thư giãn)!')),
                );
              },
              child: const Text('Hoàn thành bài tập thở'),
            ),
          ],
        ),
      ),
    );
  }
}

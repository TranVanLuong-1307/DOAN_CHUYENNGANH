import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LiveWorkoutScreen extends StatefulWidget {
  final String workoutName;
  final IconData icon;

  const LiveWorkoutScreen({
    super.key,
    required this.workoutName,
    required this.icon,
  });

  @override
  State<LiveWorkoutScreen> createState() => _LiveWorkoutScreenState();
}

class _LiveWorkoutScreenState extends State<LiveWorkoutScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _isPaused = false;
  double _distanceKm = 0.0;
  int _calories = 0;
  int _heartRate = 132;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _seconds++;
          _distanceKm += 0.003; // ~10 km/h simulation
          _calories = (_distanceKm * 65).toInt();
          _heartRate = 128 + (_seconds % 15);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _calculatePace() {
    if (_distanceKm <= 0.01) return '0′00″/km';
    final paceSeconds = (_seconds / _distanceKm).toInt();
    final m = paceSeconds ~/ 60;
    final s = (paceSeconds % 60).toString().padLeft(2, '0');
    return '$m′$s″/km';
  }

  void _finishWorkout() {
    _timer?.cancel();
    final appState = AppStateScope.of(context);
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}';

    final finalDistance = double.parse(_distanceKm.toStringAsFixed(2));
    final record = WorkoutRecord(
      icon: widget.icon,
      title: widget.workoutName,
      distanceKm: finalDistance > 0 ? finalDistance : 0.05,
      duration: _formatDuration(_seconds),
      pace: _calculatePace(),
      date: dateStr,
      calories: _calories > 0 ? _calories : 5,
    );

    appState.addWorkout(record);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.pillActive,
        content: Text(
          'Đã hoàn thành buổi ${widget.workoutName}: ${record.distanceKm} km trong ${record.duration}!',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(widget.icon, color: AppColors.primaryMint, size: 24),
                      const SizedBox(width: 8),
                      Text(widget.workoutName, style: AppTextStyles.titleMedium),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryMint),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryMint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'GPS TỐT',
                          style: TextStyle(
                            color: AppColors.primaryMint,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Distance Live
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _distanceKm.toStringAsFixed(2),
                  style: GoogleFonts.inter(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                'KILOMÉT',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 36),

              // Stats Row (Time, Pace, Kcal, Heart)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Thời gian', _formatDuration(_seconds)),
                    _buildStatItem('Tốc độ', _calculatePace()),
                    _buildStatItem('Calo', '$_calories kcal'),
                    _buildStatItem('Nhịp tim', '$_heartRate bpm'),
                  ],
                ),
              ),
              const Spacer(),

              // Controls: Pause / Resume & Finish
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pause / Resume Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPaused = !_isPaused;
                      });
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryMint, width: 2),
                      ),
                      child: Icon(
                        _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        color: AppColors.primaryMint,
                        size: 36,
                      ),
                    ),
                  ),

                  // Stop / Finish Button
                  GestureDetector(
                    onTap: _finishWorkout,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryMint,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x4478E4CD),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stop_rounded,
                            color: AppColors.primaryDarkText,
                            size: 36,
                          ),
                          Text(
                            'KẾT THÚC',
                            style: TextStyle(
                              color: AppColors.primaryDarkText,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.tinyMuted),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleSmall),
      ],
    );
  }
}

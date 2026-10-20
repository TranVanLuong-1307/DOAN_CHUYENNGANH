import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HealthStepCard extends StatelessWidget {
  final int currentSteps;
  final int targetSteps;
  final double distanceKm;
  final int caloriesKcal;
  final int durationMinutes;
  final VoidCallback? onTap;

  const HealthStepCard({
    super.key,
    required this.currentSteps,
    required this.targetSteps,
    required this.distanceKm,
    required this.caloriesKcal,
    required this.durationMinutes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = targetSteps > 0
        ? (currentSteps / targetSteps).clamp(0.0, 1.0)
        : 0.0;
    final percentInt = (progress * 100).toInt();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primaryMint.withValues(alpha: 0.1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardSurfaceAccent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Progress Indicator
              SizedBox(
                width: 82,
                height: 82,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(82, 82),
                      painter: _StepProgressPainter(
                        progress: progress,
                        trackColor: AppColors.pillActive,
                        progressColor: AppColors.primaryMint,
                        strokeWidth: 7,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_walk_rounded,
                          color: AppColors.primaryMint,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$percentInt%',
                          style: GoogleFonts.inter(
                            color: AppColors.primaryMint,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Stats Column (Expanded to prevent horizontal overflow)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mỗi bước chân đều có giá trị',
                      style: AppTextStyles.bodyMint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: _formatNumber(currentSteps),
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: targetSteps > 0
                                  ? ' / ${_formatNumber(targetSteps)} bước'
                                  : ' / -- bước',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${distanceKm.toString().replaceAll('.', ',')} km  ·  $caloriesKcal kcal  ·  $durationMinutes phút',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryMint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class _StepProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _StepProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw full background circle
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc (-90 degrees is top)
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StepProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ExerciseStartHero extends StatefulWidget {
  final String modeName;
  final VoidCallback onStart;

  const ExerciseStartHero({
    super.key,
    this.modeName = 'NGOÀI TRỜI',
    required this.onStart,
  });

  @override
  State<ExerciseStartHero> createState() => _ExerciseStartHeroState();
}

class _ExerciseStartHeroState extends State<ExerciseStartHero>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 274,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top Left Outdoor Badge
          Positioned(
            left: 14,
            top: 14,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  size: 13,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  widget.modeName,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Outer Concentric Ring with subtle breathing pulse
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 202,
                  height: 202,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.pillActive,
                      width: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),

          // Middle Circle
          Container(
            width: 172,
            height: 172,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardSurfaceAccent,
            ),
          ),

          // Inner Start Button
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: widget.onStart,
              customBorder: const CircleBorder(),
              splashColor: AppColors.pillActive,
              child: Container(
                width: 144,
                height: 144,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryMint,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3378E4CD),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      size: 38,
                      color: AppColors.primaryDarkText,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bắt đầu',
                      style: GoogleFonts.inter(
                        color: AppColors.primaryDarkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom GPS Ready Indicator
          Positioned(
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                  Text(
                    'GPS đã sẵn sàng',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

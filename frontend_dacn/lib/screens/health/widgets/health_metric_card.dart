import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HealthMetricCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final Color? subtitleColor;
  final Widget? customWidget;
  final VoidCallback? onTap;

  const HealthMetricCard({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    this.subtitleColor,
    this.customWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primaryMint.withValues(alpha: 0.1),
        highlightColor: AppColors.cardSurfaceAccent.withValues(alpha: 0.2),
        child: Container(
          constraints: const BoxConstraints(minHeight: 142),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header: Icon + Title
              Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: iconColor ?? AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.metricTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Value & Unit (scaled down smoothly if narrow)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Optional Custom Chart/Widget or Spacer
              if (customWidget != null)
                customWidget!
              else
                const SizedBox(height: 4),

              const SizedBox(height: 4),

              // Subtitle
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: subtitleColor ?? AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

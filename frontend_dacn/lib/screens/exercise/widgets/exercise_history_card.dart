import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ExerciseHistoryCard extends StatelessWidget {
  final List<WorkoutRecord> items;
  final ValueChanged<WorkoutRecord>? onItemTap;

  const ExerciseHistoryCard({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.avatarBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_run_outlined,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Chưa có lịch sử tập luyện',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Các buổi chạy bộ, đạp xe từ ứng dụng hoặc backend sẽ xuất hiện tại đây.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              _buildHistoryRow(item),
              if (!isLast)
                const Divider(
                  color: AppColors.border,
                  height: 1,
                  thickness: 1,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHistoryRow(WorkoutRecord item) {
    return InkWell(
      onTap: () => onItemTap?.call(item),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Icon rounded container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.avatarBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: AppColors.primaryMint,
              ),
            ),
            const SizedBox(width: 12),

            // Distance & Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: item.distanceKm.toString().replaceAll('.', ','),
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' km',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.duration}  ·  ${item.pace}',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Date
            Text(
              item.date,
              style: AppTextStyles.caption,
            ),
            const SizedBox(width: 8),

            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

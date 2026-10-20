import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HrvChartWidget extends StatelessWidget {
  const HrvChartWidget({super.key});

  static const List<double> _hrvHeights = [
    12, 16, 11, 21, 18, 23, 16, 22, 27, 21, 25, 22, 28, 24, 27
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_hrvHeights.length, (index) {
          final isRecent = index >= _hrvHeights.length - 4;
          final opacity = isRecent ? 1.0 : 0.40;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              height: _hrvHeights[index],
              decoration: BoxDecoration(
                color: AppColors.primaryMint.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SleepChartWidget extends StatelessWidget {
  const SleepChartWidget({super.key});

  static const List<double> _barHeights = [
    12, 22, 16, 26, 12, 21, 26, 15, 22, 12, 27, 17, 24, 13, 20, 27, 15
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_barHeights.length, (index) {
          final isDeepSleep = index % 3 == 0;
          final color = isDeepSleep
              ? AppColors.sleepDark
              : AppColors.sleepLight.withValues(alpha: index % 2 == 0 ? 0.9 : 0.55);

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              height: _barHeights[index],
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

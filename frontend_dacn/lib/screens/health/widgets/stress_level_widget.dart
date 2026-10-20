import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StressLevelWidget extends StatelessWidget {
  const StressLevelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(12, (index) {
          final double height = (index == 8) ? 18.0 : 10.0;
          Color color;

          if (index < 5) {
            color = AppColors.stressActive.withValues(alpha: 0.45);
          } else if (index < 8) {
            color = AppColors.stressActive;
          } else {
            color = AppColors.border;
          }

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

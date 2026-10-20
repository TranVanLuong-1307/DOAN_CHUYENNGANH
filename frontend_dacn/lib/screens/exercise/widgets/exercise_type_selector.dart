import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ExerciseTypeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const ExerciseTypeSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const List<String> _types = ['Chạy bộ', 'Đạp xe', 'Đi bộ'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(_types.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryMint : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _types[index],
                  style: GoogleFonts.inter(
                    color: isSelected ? AppColors.primaryDarkText : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

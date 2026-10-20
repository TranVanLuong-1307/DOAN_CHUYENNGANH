import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavBarItemData> _items = [
    _NavBarItemData(
      label: 'Sức khỏe',
      icon: Icons.favorite_rounded,
      unselectedIcon: Icons.favorite_outline_rounded,
    ),
    _NavBarItemData(
      label: 'Bài tập',
      icon: Icons.directions_run_rounded,
      unselectedIcon: Icons.directions_run_outlined,
    ),
    _NavBarItemData(
      label: 'Thiết bị',
      icon: Icons.watch_rounded,
      unselectedIcon: Icons.watch_outlined,
    ),
    _NavBarItemData(
      label: 'Tôi',
      icon: Icons.person_rounded,
      unselectedIcon: Icons.person_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Active indicator pill with icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.pillActive : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          isSelected ? item.icon : item.unselectedIcon,
                          color: isSelected ? AppColors.primaryMint : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Label
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          color: isSelected ? AppColors.primaryMint : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItemData {
  final String label;
  final IconData icon;
  final IconData unselectedIcon;

  const _NavBarItemData({
    required this.label,
    required this.icon,
    required this.unselectedIcon,
  });
}

import 'package:e_services_app/utils/ui_tokens.dart';
import 'package:flutter/material.dart';

class HomeNavItem {
  const HomeNavItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.lockedIndex,
  });

  final List<HomeNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final int? lockedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [BoxShadow(color: AppColors.shadow(context), offset: const Offset(0, -4), blurRadius: 12)],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.navBar,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              final isLockedSlot = lockedIndex != null && index != lockedIndex;
              final flex = isSelected ? 2 : 1;
              return Expanded(
                flex: flex,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isLockedSlot ? null : () => onChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: AppSpacing.navItem,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.brandingPrimaryColor.withValues(alpha: 0.16) : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isLockedSlot && !isSelected ? 0.4 : 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.brandingPrimaryColor
                                : (isLockedSlot ? AppColors.disabled(context) : AppColors.mutedSurface(context)),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Text(
                              item.label,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.brandingPrimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MealFeedbackButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const MealFeedbackButton({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isActive ? color : AppColors.borderMuted(context);
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        selected: isActive,
        child: Material(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    size: 20,
                    color: foreground,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

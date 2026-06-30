import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_colors.dart';

/// Collapsible explanation card describing how savings goals work.
class HowItWorksCard extends StatelessWidget {
  final VoidCallback onClose;
  const HowItWorksCard({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final steps = [
      l10n.savingsGoalHowItWorksStep1,
      l10n.savingsGoalHowItWorksStep2,
      l10n.savingsGoalHowItWorksStep3,
      l10n.savingsGoalHowItWorksStep4,
    ];
    final icons = [
      Icons.flag_outlined,
      Icons.calendar_today,
      Icons.add_circle_outline,
      Icons.trending_up,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CalmCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: AppColors.accent(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.savingsGoalHowItWorksTitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.ink50(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(steps.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.accentSoft(context),
                      child: Icon(
                        icons[i],
                        size: 14,
                        color: AppColors.accent(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.ink70(context),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

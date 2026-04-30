import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/budget_streaks.dart';
import 'calm/calm.dart';
import 'info_icon_button.dart';

/// Dashboard card showing 3-tier budget streak badges.
class BudgetStreakCard extends StatelessWidget {
  final AllStreaks streaks;

  const BudgetStreakCard({
    super.key,
    required this.streaks,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return CalmCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department,
                  size: 18, color: AppColors.warning(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.streakTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              InfoIconButton(title: l10n.streakTitle, body: l10n.infoBudgetStreak),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StreakBadge(
                  icon: '\u{1F949}', // bronze medal
                  count: streaks.bronze.count,
                  label: l10n.streakBronze,
                  sublabel: l10n.streakBronzeDesc,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StreakBadge(
                  icon: '\u{1F948}', // silver medal
                  count: streaks.silver.count,
                  label: l10n.streakSilver,
                  sublabel: l10n.streakSilverDesc,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StreakBadge(
                  icon: '\u{1F947}', // gold medal
                  count: streaks.gold.count,
                  label: l10n.streakGold,
                  sublabel: l10n.streakGoldDesc,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final String icon;
  final int count;
  final String label;
  final String sublabel;

  const _StreakBadge({
    required this.icon,
    required this.count,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = count > 0;

    return Semantics(
      label: '$label: ${count > 0 ? count : 'none'}, $sublabel',
      child: Opacity(
        opacity: isActive ? 1.0 : 0.4,
        child: CalmCard(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                count > 0 ? '$count' : '-',
                style: CalmText.amount(context, size: 18, weight: FontWeight.w800),
              ),
              CalmEyebrow(label),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.ink50(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

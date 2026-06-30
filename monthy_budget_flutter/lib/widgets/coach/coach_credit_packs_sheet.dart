import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/subscription_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Bottom-sheet listing AI credit packs with ROI insight + recommendation.
class CreditPacksSheet extends StatelessWidget {
  final SubscriptionState subscription;
  final ValueChanged<CreditPack> onPurchase;

  const CreditPacksSheet({
    super.key,
    required this.subscription,
    required this.onPurchase,
  });

  String _packSessions(BuildContext context, CreditPack pack) {
    final plus = pack.credits ~/ coachModeCreditCost[CoachMode.plus]!;
    final pro = pack.credits ~/ coachModeCreditCost[CoachMode.pro]!;
    return S.of(context).coachPackSessions(plus, pro);
  }

  int _recommendedPackIndex() {
    if (subscription.totalProSessions > subscription.totalPlusSessions) {
      return 2; // 500 credits for heavy Pro users
    }
    return 1; // 150 credits default
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final recommended = _recommendedPackIndex();
    final insight = subscription.lastSessionInsight;
    final insightValue = subscription.lastSessionInsightValue;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  l10n.coachCreditsTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink(context),
                  ),
                ),
                const Spacer(),
                CalmPill(
                  label: l10n.coachCreditsRemaining(subscription.aiCredits),
                  color: AppColors.accent(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ROI insight card
            if (insight != null) ...[
              CalmCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: 20,
                      color: AppColors.accent(context),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: AppColors.ink70(context),
                          ),
                          children: [
                            TextSpan(text: l10n.coachRoiInsightPrefix),
                            TextSpan(
                              text: insight,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink(context),
                              ),
                            ),
                            if (insightValue != null &&
                                insightValue.isNotEmpty) ...[
                              TextSpan(text: l10n.coachRoiPotential),
                              TextSpan(
                                text: insightValue,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent(context),
                                ),
                              ),
                            ],
                            TextSpan(text: l10n.coachRoiCost),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Cap warning
            if (subscription.isAtCreditCap) ...[
              CalmCard(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      size: 16,
                      color: AppColors.warn(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.coachCapWarningSheet(
                          SubscriptionState.maxCreditCap,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.ink(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Pack cards
            ...List.generate(creditPacks.length, (i) {
              final pack = creditPacks[i];
              final isRecommended = i == recommended;
              final wasted = subscription.creditsWasted(pack.credits);
              final isDimmed = wasted > pack.credits * 0.5;

              return Opacity(
                opacity: isDimmed ? 0.45 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CalmCard(
                    padding: EdgeInsets.zero,
                    onTap: isDimmed ? null : () => onPurchase(pack),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${pack.credits}',
                                style: CalmText.amount(
                                  context,
                                  size: 22,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                l10n.coachCreditsLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink50(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isRecommended)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: CalmPill(
                                      label: l10n.coachBestValue,
                                      color: AppColors.accent(context),
                                    ),
                                  ),
                                Text(
                                  _packSessions(context, pack),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: wasted > 0
                                        ? AppColors.bad(context)
                                        : AppColors.ink70(context),
                                  ),
                                ),
                                if (wasted > 0)
                                  Text(
                                    l10n.coachWastedCredits(wasted),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.bad(context),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed:
                                isDimmed ? null : () => onPurchase(pack),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.line(context)),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              pack.fallbackPrice,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Personalized recommendation
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: AppColors.accent(context),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.coachRecommendedPack(creditPacks[recommended].credits),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.ink70(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

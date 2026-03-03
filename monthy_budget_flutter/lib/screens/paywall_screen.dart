import 'package:flutter/material.dart';
import '../models/subscription_state.dart';
import '../theme/app_colors.dart';

/// Full-screen paywall shown when trial expires or user taps "See Plans".
///
/// Shows the three tiers side-by-side with feature comparison.
class PaywallScreen extends StatefulWidget {
  final SubscriptionState subscription;
  final ValueChanged<SubscriptionTier> onSelectTier;
  final PremiumFeature? blockedFeature;

  const PaywallScreen({
    super.key,
    required this.subscription,
    required this.onSelectTier,
    this.blockedFeature,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _yearlyBilling = true;

  @override
  Widget build(BuildContext context) {
    final trialExpired =
        widget.subscription.trialUsed || !widget.subscription.isTrialActive;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            children: [
              // Header
              Icon(
                Icons.workspace_premium_rounded,
                size: 56,
                color: AppColors.primary(context),
              ),
              const SizedBox(height: 12),
              Text(
                trialExpired
                    ? 'Your trial has ended'
                    : 'Upgrade to Premium',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                trialExpired
                    ? 'Choose a plan to keep all your data and features'
                    : 'Unlock the full power of your budget',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
                textAlign: TextAlign.center,
              ),

              // Blocked feature callout
              if (widget.blockedFeature != null) ...[
                const SizedBox(height: 16),
                _BlockedFeatureCallout(feature: widget.blockedFeature!),
              ],

              const SizedBox(height: 24),

              // Billing toggle
              _BillingToggle(
                yearly: _yearlyBilling,
                onChanged: (v) => setState(() => _yearlyBilling = v),
              ),

              const SizedBox(height: 20),

              // Tier cards
              _TierCard(
                title: 'Free',
                price: '0',
                period: 'forever',
                features: const [
                  'Budget calculator (5 categories)',
                  'Basic expense tracking',
                  '1 savings goal',
                  'Shopping list (local only)',
                  'Banner ads',
                ],
                isCurrentTier:
                    widget.subscription.tier == SubscriptionTier.free &&
                        !widget.subscription.isTrialActive,
                onSelect: () =>
                    widget.onSelectTier(SubscriptionTier.free),
                ctaLabel: 'Continue Free',
                isPrimary: false,
              ),
              const SizedBox(height: 12),
              _TierCard(
                title: 'Premium',
                price: _yearlyBilling ? '2.49' : '3.99',
                period: _yearlyBilling ? '/mo (billed yearly)' : '/month',
                yearlyNote: _yearlyBilling ? '€29.99/year — Save 37%' : null,
                features: const [
                  'Unlimited categories & history',
                  'AI Financial Coach',
                  'Meal Planner + AI recipes',
                  'Real-time shopping list sync',
                  'PDF/CSV export',
                  'Bill reminders',
                  'Expense trends',
                  'Unlimited savings goals',
                  'No ads',
                ],
                isCurrentTier:
                    widget.subscription.tier == SubscriptionTier.premium,
                onSelect: () =>
                    widget.onSelectTier(SubscriptionTier.premium),
                ctaLabel: 'Start Premium',
                isPrimary: true,
                badge: 'Most Popular',
              ),
              const SizedBox(height: 12),
              _TierCard(
                title: 'Family',
                price: _yearlyBilling ? '4.16' : '6.99',
                period: _yearlyBilling ? '/mo (billed yearly)' : '/month',
                yearlyNote: _yearlyBilling ? '€49.99/year — Save 40%' : null,
                features: const [
                  'Everything in Premium',
                  'Household sharing (up to 6)',
                  'Multi-country tax simulator',
                  'Stress index & streaks',
                  'Month-in-review reports',
                  'Dashboard customization',
                  'All color themes',
                ],
                isCurrentTier:
                    widget.subscription.tier == SubscriptionTier.family,
                onSelect: () =>
                    widget.onSelectTier(SubscriptionTier.family),
                ctaLabel: 'Start Family',
                isPrimary: false,
              ),

              const SizedBox(height: 24),

              // Trust signals
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      size: 14, color: AppColors.textMuted(context)),
                  const SizedBox(width: 4),
                  Text(
                    'Cancel anytime • No hidden fees',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // TODO: Link to Terms of Service
                },
                child: Text(
                  'Terms of Service • Privacy Policy',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted(context),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillingToggle extends StatelessWidget {
  final bool yearly;
  final ValueChanged<bool> onChanged;

  const _BillingToggle({required this.yearly, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption(context, 'Monthly', !yearly, () => onChanged(false)),
          _toggleOption(context, 'Yearly (save 37%)', yearly,
              () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _toggleOption(
      BuildContext context, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? yearlyNote;
  final List<String> features;
  final bool isCurrentTier;
  final VoidCallback onSelect;
  final String ctaLabel;
  final bool isPrimary;
  final String? badge;

  const _TierCard({
    required this.title,
    required this.price,
    required this.period,
    this.yearlyNote,
    required this.features,
    required this.isCurrentTier,
    required this.onSelect,
    required this.ctaLabel,
    required this.isPrimary,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary
              ? AppColors.primary(context)
              : AppColors.border(context),
          width: isPrimary ? 2 : 1,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.primary(context).withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '€$price',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: isPrimary
                            ? AppColors.primary(context)
                            : AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
                if (yearlyNote != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    yearlyNote!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success(context),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Features
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 18,
                              color: isPrimary
                                  ? AppColors.primary(context)
                                  : AppColors.success(context)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),

                // CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentTier ? null : onSelect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPrimary
                          ? AppColors.primary(context)
                          : AppColors.surfaceVariant(context),
                      foregroundColor: isPrimary
                          ? Colors.white
                          : AppColors.textPrimary(context),
                      disabledBackgroundColor: AppColors.surfaceVariant(context),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isCurrentTier ? 'Current Plan' : ctaLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shown when a specific feature is blocked.
class _BlockedFeatureCallout extends StatelessWidget {
  final PremiumFeature feature;

  const _BlockedFeatureCallout({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning(context).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline,
              size: 20, color: AppColors.warning(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_featureDisplayName(feature)} requires a paid subscription',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _featureDisplayName(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.aiCoach:
        return 'AI Financial Coach';
      case PremiumFeature.mealPlanner:
        return 'Meal Planner';
      case PremiumFeature.exportData:
        return 'Export Reports';
      case PremiumFeature.unlimitedCategories:
        return 'Unlimited Categories';
      case PremiumFeature.billReminders:
        return 'Bill Reminders';
      case PremiumFeature.shoppingListSync:
        return 'Shopping List Sync';
      case PremiumFeature.noAds:
        return 'Ad-Free Experience';
      case PremiumFeature.householdSharing:
        return 'Household Sharing';
      case PremiumFeature.taxSimulator:
        return 'Tax Simulator';
      case PremiumFeature.stressIndex:
        return 'Stress Index';
      case PremiumFeature.monthReview:
        return 'Month-in-Review';
      case PremiumFeature.dashboardCustomization:
        return 'Dashboard Customization';
      case PremiumFeature.allThemes:
        return 'All Color Themes';
      case PremiumFeature.expenseTrends:
        return 'Expense Trends';
      case PremiumFeature.unlimitedSavingsGoals:
        return 'Unlimited Savings Goals';
    }
  }
}

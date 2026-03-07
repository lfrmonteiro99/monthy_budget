import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/revenuecat_config.dart';
import '../models/subscription_state.dart';
import '../services/revenuecat_service.dart';
import '../theme/app_colors.dart';

/// Full-screen paywall shown when trial expires or user taps "See Plans".
///
/// Shows the three tiers side-by-side with feature comparison.
/// When RevenueCat is configured, fetches real offerings and executes
/// purchases via Google Play Billing.
class PaywallScreen extends StatefulWidget {
  final SubscriptionState subscription;
  final ValueChanged<SubscriptionTier> onSelectTier;
  final ValueChanged<SubscriptionTier>? onPurchaseComplete;
  final ValueChanged<SubscriptionTier>? onRestoreComplete;
  final PremiumFeature? blockedFeature;

  const PaywallScreen({
    super.key,
    required this.subscription,
    required this.onSelectTier,
    this.onPurchaseComplete,
    this.onRestoreComplete,
    this.blockedFeature,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _yearlyBilling = true;
  bool _purchasing = false;
  String? _error;
  Offerings? _offerings;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    final offerings = await RevenueCatService.getOfferings();
    if (mounted) {
      setState(() => _offerings = offerings);
    }
  }

  /// Resolve a package from offerings for the given billing period.
  Package? _findPackage(bool yearly) {
    final offering = _offerings?.current;
    if (offering == null) return null;

    final targetId = yearly
        ? revenueCatProductYearly
        : revenueCatProductMonthly;

    for (final pkg in offering.availablePackages) {
      if (pkg.storeProduct.identifier == targetId) return pkg;
    }
    return null;
  }

  /// Get the store price string, falling back to hardcoded.
  String _priceForTier(bool yearly, String fallback) {
    final pkg = _findPackage(yearly);
    return pkg?.storeProduct.priceString ?? fallback;
  }

  Future<void> _handlePurchase(SubscriptionTier tier) async {
    if (tier == SubscriptionTier.free) {
      widget.onSelectTier(tier);
      return;
    }

    final package = _findPackage(_yearlyBilling);

    // Simulate mode or no package available — fall back to simulated upgrade
    if (revenueCatSimulateMode || package == null) {
      if (widget.onPurchaseComplete != null) {
        widget.onPurchaseComplete!(tier);
      } else {
        widget.onSelectTier(tier);
      }
      return;
    }

    setState(() {
      _purchasing = true;
      _error = null;
    });

    try {
      final resultTier = await RevenueCatService.purchase(package);
      if (mounted) {
        setState(() => _purchasing = false);
        if (widget.onPurchaseComplete != null) {
          widget.onPurchaseComplete!(resultTier);
        } else {
          widget.onSelectTier(resultTier);
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() {
          _purchasing = false;
          // Error code 1 = user cancelled — don't show error
          if (e.code != '1') {
            _error = e.message ?? 'Purchase failed. Please try again.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _purchasing = false;
          _error = 'Purchase failed. Please try again.';
        });
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _purchasing = true;
      _error = null;
    });

    try {
      final tier = await RevenueCatService.restorePurchases();
      if (mounted) {
        setState(() => _purchasing = false);
        widget.onRestoreComplete?.call(tier);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _purchasing = false;
          _error = 'Restore failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trialExpired =
        widget.subscription.trialUsed || !widget.subscription.isTrialActive;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: AppColors.textPrimary(context)),
              onPressed: _purchasing ? null : () => Navigator.of(context).pop(),
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

                  // Pro card — single paid tier (maps to family internally)
                  _TierCard(
                    title: 'Gestão Mensal Pro',
                    price: _yearlyBilling
                        ? _priceForTier(true, '€2.49')
                        : _priceForTier(false, '€3.99'),
                    period: _yearlyBilling ? '/mo (billed yearly)' : '/month',
                    yearlyNote: _yearlyBilling ? _yearlyNote() : null,
                    features: const [
                      'Unlimited categories & history',
                      'AI Financial Coach',
                      'Meal Planner + AI recipes',
                      'Real-time shopping list sync',
                      'PDF/CSV export',
                      'Bill reminders',
                      'Expense trends',
                      'Unlimited savings goals',
                      'Household sharing (up to 6)',
                      'Multi-country tax simulator',
                      'Dashboard customization',
                      'All color themes',
                      'No ads',
                    ],
                    isCurrentTier:
                        widget.subscription.tier != SubscriptionTier.free,
                    // Single entitlement → maps to family (highest tier).
                    onSelect: () => _handlePurchase(SubscriptionTier.family),
                    ctaLabel: 'Start Pro',
                    isPrimary: true,
                    badge: 'Best Value',
                    showPriceAsIs: _offerings != null,
                  ),
                  const SizedBox(height: 12),
                  // Free tier card
                  _TierCard(
                    title: 'Free',
                    price: '0',
                    period: 'forever',
                    features: const [
                      'Budget calculator (8 categories)',
                      'Basic expense tracking',
                      '1 savings goal',
                      'Shopping list (local only)',
                      'Banner ads',
                    ],
                    isCurrentTier:
                        widget.subscription.tier == SubscriptionTier.free &&
                            !widget.subscription.isTrialActive,
                    onSelect: () => _handlePurchase(SubscriptionTier.free),
                    ctaLabel: 'Continue Free',
                    isPrimary: false,
                  ),

                  const SizedBox(height: 24),

                  // Error display
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error(context).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              size: 18, color: AppColors.error(context)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.error(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

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

                  // Restore purchases button
                  if (widget.onRestoreComplete != null) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _purchasing ? null : _handleRestore,
                      child: Text(
                        'Restore Purchases',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary(context),
                        ),
                      ),
                    ),
                  ],

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
        ),

        // Loading overlay during purchase/restore
        if (_purchasing)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  String? _yearlyNote() {
    final pkg = _findPackage(true);
    if (pkg != null) {
      return '${pkg.storeProduct.priceString}/year — Save 37%';
    }
    return '€29.99/year — Save 37%';
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
  final bool showPriceAsIs;

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
    this.showPriceAsIs = false,
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
                      showPriceAsIs ? price : '€$price',
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

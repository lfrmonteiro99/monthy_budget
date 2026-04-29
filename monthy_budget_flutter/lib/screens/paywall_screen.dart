import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/revenuecat_config.dart';
import '../models/subscription_state.dart';
import '../services/revenuecat_service.dart';
import '../constants/app_constants.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

const _termsOfServiceUrl =
    'https://lfrmonteiro99.github.io/monthy_budget/terms-of-service';
const _privacyPolicyUrl =
    'https://lfrmonteiro99.github.io/monthy_budget/privacy-policy';

// 5 features per §22 spec: icon + title + body
const _paywallFeatures = <(IconData, String, String)>[
  (Icons.bar_chart_rounded, 'Orçamento inteligente', // TODO(l10n):
      'Categorias ilimitadas e histórico completo'), // TODO(l10n):
  (Icons.smart_toy_outlined, 'Coach Financeiro IA', // TODO(l10n):
      'Dicas personalizadas em tempo real'), // TODO(l10n):
  (Icons.restaurant_menu_outlined, 'Planeador de Refeições', // TODO(l10n):
      'Receitas IA integradas com a lista de compras'), // TODO(l10n):
  (Icons.sync_rounded, 'Sincronização em tempo real', // TODO(l10n):
      'Lista de compras partilhada com o agregado'), // TODO(l10n):
  (Icons.file_download_outlined, 'Exportação PDF/CSV', // TODO(l10n):
      'Relatórios prontos a enviar'), // TODO(l10n):
];

/// Full-screen paywall — Wave M5 (SCREEN_ROLLOUT §22).
///
/// Restructured on Calm widgets. All RevenueCat purchase flow, plan toggle
/// (anual/mensal), restore purchase and ToS/Privacy wiring are fully preserved.
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
    if (mounted) setState(() => _offerings = offerings);
  }

  Package? _findPackage(bool yearly) {
    final offering = _offerings?.current;
    if (offering == null) return null;
    final targetId = yearly ? revenueCatProductYearly : revenueCatProductMonthly;
    for (final pkg in offering.availablePackages) {
      if (pkg.storeProduct.identifier == targetId) return pkg;
    }
    return null;
  }

  String _priceForTier(bool yearly, String fallback) {
    final pkg = _findPackage(yearly);
    return pkg?.storeProduct.priceString ?? fallback;
  }

  String _yearlyNote() {
    final pkg = _findPackage(true);
    return pkg != null
        ? '${pkg.storeProduct.priceString}/year — Save 37%'
        : '€29.99/year — Save 37%';
  }

  Future<void> _handlePurchase(SubscriptionTier tier) async {
    if (tier == SubscriptionTier.free) {
      widget.onSelectTier(tier);
      return;
    }
    final package = _findPackage(_yearlyBilling);
    if (revenueCatSimulateMode || package == null) {
      if (widget.onPurchaseComplete != null) {
        widget.onPurchaseComplete!(tier);
      } else {
        widget.onSelectTier(tier);
      }
      return;
    }
    setState(() { _purchasing = true; _error = null; });
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
          if (e.code != '1') _error = e.message ?? 'Purchase failed. Please try again.';
        });
      }
    } catch (_) {
      if (mounted) setState(() { _purchasing = false; _error = 'Purchase failed. Please try again.'; });
    }
  }

  Future<void> _handleRestore() async {
    setState(() { _purchasing = true; _error = null; });
    try {
      final tier = await RevenueCatService.restorePurchases();
      if (mounted) {
        setState(() => _purchasing = false);
        widget.onRestoreComplete?.call(tier);
      }
    } catch (_) {
      if (mounted) setState(() { _purchasing = false; _error = 'Restore failed. Please try again.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Stack(
      children: [
        CalmScaffold(
          bodyPadding: const EdgeInsets.symmetric(horizontal: 20),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Close ×
                Align(
                  alignment: Alignment.centerRight,
                  child: Semantics(
                    label: 'Fechar', button: true, // TODO(l10n):
                    child: IconButton(
                      icon: Icon(Icons.close, size: 24, color: AppColors.ink(context)),
                      tooltip: 'Fechar', // TODO(l10n):
                      onPressed: _purchasing ? null : () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Eyebrow
                CalmEyebrow('MONTHLY PLUS', textAlign: TextAlign.center), // TODO(l10n):
                const SizedBox(height: 12),
                // Hero title — one Fraunces per screen (§22)
                Text(
                  'Tudo o que precisas para um ano de paz financeira', // TODO(l10n):
                  style: CalmText.display(context, size: 36),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.blockedFeature != null) ...[
                  const SizedBox(height: 16),
                  _BlockedFeatureCallout(feature: widget.blockedFeature!),
                ],
                const SizedBox(height: 24),
                // Features list wrapped in CalmCard
                CalmCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      for (int i = 0; i < _paywallFeatures.length; i++) ...[
                        if (i > 0) const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(_paywallFeatures[i].$1, size: 22, color: AppColors.ink(context)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_paywallFeatures[i].$2,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                                          color: AppColors.ink(context))),
                                  Text(_paywallFeatures[i].$3,
                                      style: TextStyle(fontSize: 13,
                                          color: AppColors.ink70(context), height: 1.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Segmented toggle
                _BillingToggle(
                  yearly: _yearlyBilling,
                  onChanged: (v) => setState(() => _yearlyBilling = v),
                ),
                const SizedBox(height: 20),
                // Price card
                CalmCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CalmEyebrow(_yearlyBilling ? 'PLANO ANUAL' : 'PLANO MENSAL'), // TODO(l10n):
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _yearlyBilling ? _priceForTier(true, '€2.49') : _priceForTier(false, '€3.99'),
                            style: CalmText.display(context, size: 40),
                          ),
                          const SizedBox(width: 6),
                          Text('/mês', style: TextStyle(fontSize: 14, color: AppColors.ink70(context))), // TODO(l10n):
                        ],
                      ),
                      if (_yearlyBilling) ...[
                        const SizedBox(height: 4),
                        Text(_yearlyNote(), style: TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w600, color: AppColors.ok(context))),
                      ],
                      const SizedBox(height: 8),
                      Text('7 dias grátis · cancela quando quiseres', // TODO(l10n):
                          style: TextStyle(fontSize: 12, color: AppColors.ink50(context), height: 1.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Error
                if (_error != null) ...[
                  Row(children: [
                    Icon(Icons.error_outline, size: 18, color: AppColors.bad(context)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: TextStyle(fontSize: 13, color: AppColors.bad(context)))),
                  ]),
                  const SizedBox(height: 16),
                ],
                // CTA full-width ink
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _purchasing ? null : () => _handlePurchase(SubscriptionTier.family),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink(context),
                      foregroundColor: AppColors.inkInverse(context),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Começar 7 dias grátis', // TODO(l10n):
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 20),
                // Section header for tier comparison
                CalmEyebrow('COMPARAR PLANOS', textAlign: TextAlign.center), // TODO(l10n):
                const SizedBox(height: 12),
                // Pro tier card
                _TierCard(
                  title: '${l10n.appTitle} Pro',
                  price: _yearlyBilling ? _priceForTier(true, '€2.49') : _priceForTier(false, '€3.99'),
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
                  isCurrentTier: widget.subscription.tier != SubscriptionTier.free,
                  onSelect: () => _handlePurchase(SubscriptionTier.family),
                  ctaLabel: l10n.paywallStartPro,
                  isPrimary: true,
                  badge: l10n.paywallBestValue,
                  showPriceAsIs: _offerings != null,
                ),
                const SizedBox(height: 12),
                // Free tier card
                _TierCard(
                  title: l10n.paywallFree,
                  price: '0',
                  period: 'forever',
                  features: const [
                    'Budget calculator (8 categories)',
                    'Basic expense tracking',
                    '1 savings goal',
                    'Shopping list (local only)',
                    'Banner ads',
                  ],
                  isCurrentTier: widget.subscription.tier == SubscriptionTier.free &&
                      !widget.subscription.isTrialActive,
                  onSelect: () => _handlePurchase(SubscriptionTier.free),
                  ctaLabel: l10n.paywallContinueFree,
                  isPrimary: false,
                ),
                const SizedBox(height: 24),
                // Restore purchase
                if (widget.onRestoreComplete != null) ...[
                  Center(
                    child: GestureDetector(
                      onTap: _purchasing ? null : _handleRestore,
                      child: Text('Restaurar compra', // TODO(l10n):
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.accent(context),
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Trust signal
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.ink50(context)),
                  const SizedBox(width: 4),
                  Text('Cancel anytime • No hidden fees',
                      style: TextStyle(fontSize: 12, color: AppColors.ink50(context))),
                ]),
                const SizedBox(height: 12),
                // Footer ToS + Privacy
                _FooterLinks(),
              ],
            ),
          ),
        ),
        if (_purchasing)
          const ColoredBox(
            color: Colors.black26,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

// ── Footer links ──────────────────────────────────────────────────────────────

class _FooterLinks extends StatelessWidget {
  const _FooterLinks();

  @override
  Widget build(BuildContext context) {
    final tosRec = TapGestureRecognizer()
      ..onTap = () => launchUrl(Uri.parse(_termsOfServiceUrl), mode: LaunchMode.externalApplication);
    final privRec = TapGestureRecognizer()
      ..onTap = () => launchUrl(Uri.parse(_privacyPolicyUrl), mode: LaunchMode.externalApplication);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 11, color: AppColors.ink50(context), height: 1.5),
        children: [
          TextSpan(text: 'Terms of Service', // TODO(l10n):
              style: TextStyle(color: AppColors.accent(context)), recognizer: tosRec),
          const TextSpan(text: '  ·  '),
          TextSpan(text: 'Privacy Policy', // TODO(l10n):
              style: TextStyle(color: AppColors.accent(context)), recognizer: privRec),
        ],
      ),
    );
  }
}

// ── Billing toggle ────────────────────────────────────────────────────────────

class _BillingToggle extends StatelessWidget {
  final bool yearly;
  final ValueChanged<bool> onChanged;

  const _BillingToggle({required this.yearly, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CalmCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _option(context, 'Monthly', !yearly, () => onChanged(false))), // TODO(l10n):
          Expanded(child: _option(context, 'Yearly (save 37%)', yearly, () => onChanged(true), // TODO(l10n):
              pill: CalmPill(label: '−20%', color: AppColors.ok(context)))),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, String label, bool selected, VoidCallback onTap, {Widget? pill}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: selected ? AppColors.inkInverse(context) : AppColors.ink70(context))),
            if (pill != null) ...[const SizedBox(width: 6), pill],
          ],
        ),
      ),
    );
  }
}

// ── Tier card ─────────────────────────────────────────────────────────────────

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
    return Stack(
      children: [
        CalmCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.ink(context))),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(showPriceAsIs ? price : '€$price',
                      style: CalmText.amount(context, size: 32, weight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  Text(period, style: TextStyle(fontSize: 13, color: AppColors.ink70(context))),
                ],
              ),
              if (yearlyNote != null) ...[
                const SizedBox(height: 4),
                Text(yearlyNote!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.ok(context))),
              ],
              const SizedBox(height: 16),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Icon(Icons.check_circle, size: 18,
                      color: isPrimary ? AppColors.ink(context) : AppColors.ok(context)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(f, style: TextStyle(fontSize: 13, color: AppColors.ink(context)))),
                ]),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isCurrentTier ? null : onSelect,
                  style: FilledButton.styleFrom(
                    backgroundColor: isPrimary ? AppColors.ink(context) : AppColors.bgSunk(context),
                    foregroundColor: isPrimary ? AppColors.inkInverse(context) : AppColors.ink(context),
                    disabledBackgroundColor: AppColors.bgSunk(context),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(isCurrentTier ? 'Current Plan' : ctaLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
        if (badge != null)
          Positioned(
            top: 12, right: 12,
            child: CalmPill(label: badge!, color: AppColors.accent(context)),
          ),
      ],
    );
  }
}

// ── Blocked feature callout ───────────────────────────────────────────────────

class _BlockedFeatureCallout extends StatelessWidget {
  final PremiumFeature feature;

  const _BlockedFeatureCallout({required this.feature});

  @override
  Widget build(BuildContext context) {
    return CalmCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Icon(Icons.lock_outline, size: 20, color: AppColors.warn(context)),
        const SizedBox(width: 10),
        Expanded(
          child: Text('${_featureDisplayName(feature)} requires a paid subscription',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.ink(context))),
        ),
      ]),
    );
  }

  String _featureDisplayName(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.aiCoach:            return 'AI Financial Coach';
      case PremiumFeature.mealPlanner:        return 'Meal Planner';
      case PremiumFeature.exportData:         return 'Export Reports';
      case PremiumFeature.unlimitedCategories: return 'Unlimited Categories';
      case PremiumFeature.billReminders:      return 'Bill Reminders';
      case PremiumFeature.shoppingListSync:   return 'Shopping List Sync';
      case PremiumFeature.noAds:              return 'Ad-Free Experience';
      case PremiumFeature.householdSharing:   return 'Household Sharing';
      case PremiumFeature.taxSimulator:       return 'Tax Simulator';
      case PremiumFeature.stressIndex:        return 'Stress Index';
      case PremiumFeature.monthReview:        return 'Month-in-Review';
      case PremiumFeature.dashboardCustomization: return 'Dashboard Customization';
      case PremiumFeature.allThemes:          return 'All Color Themes';
      case PremiumFeature.expenseTrends:      return 'Expense Trends';
      case PremiumFeature.unlimitedSavingsGoals: return 'Unlimited Savings Goals';
    }
  }
}

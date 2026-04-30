import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/subscription_state.dart';
import '../theme/app_colors.dart';

/// One observation rendered in the "OBSERVAÇÕES" section.
class MoreObservation {
  const MoreObservation({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
  });

  final String id;
  final CalmObservationKind kind;
  final String title;
  final String body;
}

/// Implements the "Insights & mais" hub (rollout entry #5).
///
/// Three sections, top → bottom:
///   1. `CalmPageHeader` — eyebrow `ENTENDIMENTO` + Fraunces title.
///   2. `CalmCoachHeroCard` — dark hero with quote + CTA.
///   3. `OBSERVAÇÕES` — up to 3 [CalmObservationCard]s (section skipped
///      when [observations] is empty — never an empty state here).
///   4. `FERRAMENTAS` — single grouped card listing 13 tools (items
///      marked premium are still visible; flagged-off items collapse).
///
/// Pure presentation: every navigation target is supplied as a callback
/// from [AppHomeState] — no provider lookups inside the screen.
class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.coachQuote,
    required this.observations,
    required this.onOpenCoach,
    required this.onOpenInsight,
    required this.onOpenPlanShop,
    required this.onOpenShoppingList,
    required this.onOpenMealPlanner,
    required this.onOpenPantry,
    required this.onOpenIncome,
    required this.onOpenRecurring,
    required this.onOpenHousehold,
    required this.onOpenYearlySummary,
    required this.onOpenTaxSimulator,
    required this.onOpenScanReceipt,
    required this.onOpenDataHealth,
    required this.onOpenNotifications,
    required this.onOpenSettings,
    required this.onOpenPaywall,
    this.subscription,
    this.householdMemberCount = 0,
    this.dataHealthAlertCount = 0,
    this.currentYear,
    this.taxSimulatorEnabled = true,
    this.receiptOcrEnabled = true,
  });

  /// Coach headline. Caller passes a static fallback if the live
  /// endpoint is offline.
  final String coachQuote;

  /// Up to 3 observations. Empty list = section skipped.
  final List<MoreObservation> observations;

  // ── Hero ─────────────────────────────────────────────────────
  final VoidCallback onOpenCoach;
  final ValueChanged<MoreObservation> onOpenInsight;

  // ── Tools (13) ───────────────────────────────────────────────
  final VoidCallback onOpenPlanShop;
  final VoidCallback onOpenShoppingList;
  final VoidCallback onOpenMealPlanner;
  final VoidCallback onOpenPantry;
  final VoidCallback onOpenIncome;
  final VoidCallback onOpenRecurring;
  final VoidCallback onOpenHousehold;
  final VoidCallback onOpenYearlySummary;
  final VoidCallback onOpenTaxSimulator;
  final VoidCallback onOpenScanReceipt;
  final VoidCallback onOpenDataHealth;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  /// Used when free tier taps the coach hero.
  final VoidCallback onOpenPaywall;

  final SubscriptionState? subscription;
  final int householdMemberCount;
  final int dataHealthAlertCount;
  final int? currentYear;
  final bool taxSimulatorEnabled;
  final bool receiptOcrEnabled;

  bool get _isFreeTier =>
      subscription != null && !subscription!.hasPremiumAccess;

  String _kindLabel(CalmObservationKind kind, S l10n) {
    switch (kind) {
      case CalmObservationKind.warning:
        return l10n.moreObsKindWarning;
      case CalmObservationKind.info:
        return l10n.moreObsKindInfo;
      case CalmObservationKind.success:
        return l10n.moreObsKindSuccess;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final year = currentYear ?? DateTime.now().year;

    final tools = <_MoreTool>[
      _MoreTool(
        icon: Icons.restaurant_outlined,
        title: l10n.moreToolPlanShop,
        sub: l10n.moreToolPlanShopSub,
        onTap: onOpenPlanShop,
      ),
      _MoreTool(
        icon: Icons.shopping_cart_outlined,
        title: l10n.moreToolShoppingList,
        sub: l10n.moreToolShoppingListSub,
        onTap: onOpenShoppingList,
      ),
      _MoreTool(
        icon: Icons.calendar_today_outlined,
        title: l10n.moreToolMealsWeek,
        sub: l10n.moreToolMealsWeekSub,
        onTap: onOpenMealPlanner,
      ),
      _MoreTool(
        icon: Icons.kitchen_outlined,
        title: l10n.moreToolPantry,
        sub: l10n.moreToolPantrySub,
        onTap: onOpenPantry,
      ),
      _MoreTool(
        icon: Icons.trending_up_outlined,
        title: l10n.moreToolIncome,
        sub: l10n.moreToolIncomeSub,
        onTap: onOpenIncome,
      ),
      _MoreTool(
        icon: Icons.event_repeat_outlined,
        title: l10n.moreToolRecurring,
        sub: l10n.moreToolRecurringSub,
        onTap: onOpenRecurring,
      ),
      _MoreTool(
        icon: Icons.group_outlined,
        title: l10n.moreToolHousehold,
        sub: householdMemberCount > 0
            ? l10n.moreToolHouseholdSubFmt(householdMemberCount)
            : l10n.moreToolHouseholdSubConfigure,
        subAccent: householdMemberCount == 0,
        onTap: onOpenHousehold,
      ),
      _MoreTool(
        icon: Icons.bar_chart_outlined,
        title: l10n.moreToolYearly,
        sub: l10n.moreToolYearlySubFmt(year),
        onTap: onOpenYearlySummary,
      ),
      if (taxSimulatorEnabled)
        _MoreTool(
          icon: Icons.receipt_long_outlined,
          title: l10n.moreToolTaxSimulator,
          sub: l10n.moreToolTaxSimulatorSub,
          onTap: onOpenTaxSimulator,
        ),
      if (receiptOcrEnabled)
        _MoreTool(
          icon: Icons.document_scanner_outlined,
          title: l10n.moreToolReceiptScan,
          sub: l10n.moreToolReceiptScanSub,
          onTap: onOpenScanReceipt,
        ),
      _MoreTool(
        icon: Icons.health_and_safety_outlined,
        title: l10n.moreToolDataHealth,
        sub: l10n.moreToolDataHealthSub,
        trailingBadge: dataHealthAlertCount > 0
            ? dataHealthAlertCount.toString()
            : null,
        onTap: onOpenDataHealth,
      ),
      _MoreTool(
        icon: Icons.notifications_outlined,
        title: l10n.moreToolNotifications,
        sub: l10n.moreToolNotificationsSub,
        onTap: onOpenNotifications,
      ),
      _MoreTool(
        icon: Icons.settings_outlined,
        title: l10n.moreToolSettings,
        sub: l10n.moreToolSettingsSub,
        onTap: onOpenSettings,
      ),
    ];

    return CalmScaffold(
      bodyPadding: EdgeInsets.zero,
      body: ListView(
        padding: EdgeInsets.only(
          top: 6,
          bottom: 24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          // 1 · Page header (ENTENDIMENTO + Fraunces title 36)
          CalmPageHeader(
            eyebrow: l10n.moreScreenEyebrow.toUpperCase(),
            title: l10n.moreScreenTitle,
            showBack: false,
            titleSize: 36,
          ),

          // 2 · Coach hero card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: CalmCoachHeroCard(
              eyebrow: l10n.moreCoachEyebrow,
              quote: coachQuote,
              ctaLabel: _isFreeTier
                  ? l10n.moreCoachUnlockCta
                  : l10n.moreCoachCta,
              onTap: _isFreeTier ? onOpenPaywall : onOpenCoach,
              semanticsLabel: l10n.moreCoachEyebrow,
              trailingPill: _isFreeTier ? const _ProPill() : null,
            ),
          ),

          // 3 + 4 · Observações section (skipped when empty)
          if (observations.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: CalmEyebrow(l10n.moreObservationsEyebrow.toUpperCase()),
            ),
            for (var i = 0; i < observations.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CalmObservationCard(
                  kind: observations[i].kind,
                  kindLabel: _kindLabel(observations[i].kind, l10n),
                  title: observations[i].title,
                  body: observations[i].body,
                  onTap: () => onOpenInsight(observations[i]),
                ),
              ),
            ],
          ],

          // 5 · Ferramentas eyebrow
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: CalmEyebrow(l10n.moreToolsEyebrow.toUpperCase()),
          ),

          // 6 · Tools grouped card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: _ToolsGroup(tools: tools),
          ),
        ],
      ),
    );
  }
}

class _MoreTool {
  const _MoreTool({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
    this.subAccent = false,
    this.trailingBadge,
  });

  final IconData icon;
  final String title;
  final String sub;
  final bool subAccent;
  final String? trailingBadge;
  final VoidCallback onTap;
}

class _ToolsGroup extends StatelessWidget {
  const _ToolsGroup({required this.tools});

  final List<_MoreTool> tools;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < tools.length; i++) ...[
            _ToolRow(tool: tools[i]),
            if (i < tools.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.line(context),
              ),
          ],
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({required this.tool});

  final _MoreTool tool;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tool.title,
      hint: tool.sub,
      child: InkWell(
        onTap: tool.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.bgSunk(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    tool.icon,
                    size: 16,
                    color: AppColors.ink70(context),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tool.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.ink(context),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        tool.sub,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: tool.subAccent
                              ? AppColors.accent(context)
                              : AppColors.ink50(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (tool.trailingBadge != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    tool.trailingBadge!,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.ink50(context),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                ExcludeSemantics(
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.ink50(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProPill extends StatelessWidget {
  const _ProPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accentSoft(context),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.accent(context),
        ),
      ),
    );
  }
}

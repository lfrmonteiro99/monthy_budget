import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/data_health_status.dart';
import '../theme/app_colors.dart';
import '../utils/data_alert_builder.dart';

class ConfidenceCenterScreen extends StatelessWidget {
  final Map<SyncDomain, SyncDomainStatus> statuses;
  final List<DataAlert> alerts;

  const ConfidenceCenterScreen({
    super.key,
    required this.statuses,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return CalmScaffold(
      title: l10n.confidenceCenterTitle,
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          // Sync health section
          CalmEyebrow(l10n.confidenceSyncHealth),
          const SizedBox(height: 8),
          _SyncHealthCard(statuses: statuses),
          const SizedBox(height: 24),

          // Data alerts section
          CalmEyebrow(l10n.confidenceDataAlerts),
          const SizedBox(height: 8),
          if (alerts.isEmpty)
            CalmEmptyState(
              icon: Icons.check_circle_outline,
              title: l10n.confidenceNoAlerts,
              body: '',
            )
          else
            ...alerts.map((alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AlertCard(alert: alert),
                )),
          const SizedBox(height: 24),

          // Recommended actions section
          CalmEyebrow(l10n.confidenceRecommendedActions),
          const SizedBox(height: 8),
          ..._recommendedActions(alerts, l10n, context),
        ],
      ),
    );
  }

  List<Widget> _recommendedActions(
    List<DataAlert> alerts,
    S l10n,
    BuildContext context,
  ) {
    final actions = alerts
        .where((a) => a.recommendedAction != null)
        .map((a) => a.recommendedAction!)
        .toSet()
        .toList();

    if (actions.isEmpty) {
      return [
        CalmEmptyState(
          icon: Icons.check_circle_outline,
          title: l10n.confidenceAllHealthy,
          body: '',
        ),
      ];
    }

    // All actions in one card to keep the section compact.
    return [
      CalmCard(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: actions
              .map((action) => CalmListTile(
                    leadingIcon: Icons.arrow_forward,
                    leadingColor: AppColors.accent(context),
                    title: action,
                  ))
              .toList(),
        ),
      ),
    ];
  }
}

/// Sync domain status chips wrapped in a CalmCard.
class _SyncHealthCard extends StatelessWidget {
  final Map<SyncDomain, SyncDomainStatus> statuses;
  const _SyncHealthCard({required this.statuses});

  @override
  Widget build(BuildContext context) {
    return CalmCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: SyncDomain.values.map((domain) {
          final status = statuses[domain] ?? SyncDomainStatus(domain: domain);
          final color = status.hasRecentError
              ? AppColors.bad(context)
              : status.isStale
                  ? AppColors.warn(context)
                  : AppColors.ok(context);
          return CalmPill(
            label: domainLabel(domain),
            color: color,
          );
        }).toList(),
      ),
    );
  }
}

/// Alert card: one CalmCard per DataAlert with a CalmListTile inside.
class _AlertCard extends StatelessWidget {
  final DataAlert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final (Color leadColor, String severityLabel) = switch (alert.severity) {
      AlertSeverity.critical => (AppColors.bad(context), 'crítico'), // TODO(l10n):
      AlertSeverity.warning => (AppColors.warn(context), 'aviso'), // TODO(l10n):
      AlertSeverity.info => (AppColors.accent(context), 'info'), // TODO(l10n):
    };

    final icon = switch (alert.severity) {
      AlertSeverity.critical => Icons.error_outline,
      AlertSeverity.warning => Icons.warning_amber_outlined,
      AlertSeverity.info => Icons.info_outline,
    };

    return CalmCard(
      padding: EdgeInsets.zero,
      child: CalmListTile(
        leadingIcon: icon,
        leadingColor: leadColor,
        title: alert.title,
        subtitle: alert.body,
        trailing: severityLabel,
      ),
    );
  }
}

/// Banner widget to embed on the dashboard when critical alerts exist.
class CriticalAlertBanner extends StatelessWidget {
  final int criticalCount;
  final VoidCallback onTap;

  const CriticalAlertBanner({
    super.key,
    required this.criticalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (criticalCount <= 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppColors.bad(context),
        child: Row(
          children: [
            const Icon(Icons.warning, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$criticalCount critical alert${criticalCount == 1 ? '' : 's'} — tap to view', // TODO(l10n):
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        surfaceTintColor: AppColors.surface(context),
        title: Text(
          l10n.confidenceCenterTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _SectionHeader(title: l10n.confidenceSyncHealth),
          const SizedBox(height: 8),
          _SyncHealthGrid(statuses: statuses),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.confidenceDataAlerts),
          const SizedBox(height: 8),
          if (alerts.isEmpty)
            _EmptyAlerts()
          else
            ...alerts.map((alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AlertCard(alert: alert),
                )),
          const SizedBox(height: 24),
          _SectionHeader(title: l10n.confidenceRecommendedActions),
          const SizedBox(height: 8),
          ..._recommendedActions(alerts),
        ],
      ),
    );
  }

  List<Widget> _recommendedActions(List<DataAlert> alerts) {
    final actions = alerts
        .where((a) => a.recommendedAction != null)
        .map((a) => a.recommendedAction!)
        .toSet()
        .toList();
    if (actions.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'All systems healthy. No actions needed.',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ];
    }
    return actions
        .map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2, right: 8),
                    child: Icon(Icons.arrow_forward, size: 16),
                  ),
                  Expanded(
                    child: Text(action, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ))
        .toList();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(context),
      ),
    );
  }
}

class _SyncHealthGrid extends StatelessWidget {
  final Map<SyncDomain, SyncDomainStatus> statuses;
  const _SyncHealthGrid({required this.statuses});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SyncDomain.values.map((domain) {
        final status = statuses[domain] ?? SyncDomainStatus(domain: domain);
        return _SyncChip(domain: domain, status: status);
      }).toList(),
    );
  }
}

class _SyncChip extends StatelessWidget {
  final SyncDomain domain;
  final SyncDomainStatus status;
  const _SyncChip({required this.domain, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.hasRecentError
        ? AppColors.error(context)
        : status.isStale
            ? Colors.orange
            : Colors.green;

    final icon = status.hasRecentError
        ? Icons.error_outline
        : status.isStale
            ? Icons.warning_amber_outlined
            : Icons.check_circle_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            domainLabel(domain),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final DataAlert alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border, IconData icon) = switch (alert.severity) {
      AlertSeverity.critical => (
          AppColors.errorBackground(context),
          AppColors.errorBorder(context),
          Icons.error,
        ),
      AlertSeverity.warning => (
          AppColors.warningBackground(context),
          AppColors.warningBorder(context),
          Icons.warning_amber,
        ),
      AlertSeverity.info => (
          AppColors.infoBackground(context),
          AppColors.infoBorder(context),
          Icons.info_outline,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: border),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.body,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            'No alerts. Everything looks good.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
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
        color: AppColors.error(context),
        child: Row(
          children: [
            const Icon(Icons.warning, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$criticalCount critical alert${criticalCount == 1 ? '' : 's'} — tap to view',
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

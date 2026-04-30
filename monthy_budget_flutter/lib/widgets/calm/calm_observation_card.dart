import 'package:flutter/material.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// Kind of an observation (insight) tag — drives the dot/label colour.
///
/// Mapping mirrors `data.jsx::insights[].kind` from the Calm prototype:
/// - [warning] → `warn` token, label "Atenção"
/// - [info]    → `accent` token, label "Informação"
/// - [success] → `ok` token, label "Ótimo"
enum CalmObservationKind { warning, info, success }

/// Insight/observation card used on the More tab (#5 · Insights & mais)
/// and reused on the Insights screen (#17).
///
/// Renders a small coloured dot + uppercase kind label, then a 14px ink
/// title and a 12.5px ink70 body. Tapping anywhere on the card runs
/// [onTap] (typically pushing the insights screen filtered on this obs).
class CalmObservationCard extends StatelessWidget {
  const CalmObservationCard({
    super.key,
    required this.kind,
    required this.kindLabel,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final CalmObservationKind kind;
  final String kindLabel;
  final String title;
  final String body;
  final VoidCallback onTap;

  Color _kindColor(BuildContext context) {
    switch (kind) {
      case CalmObservationKind.warning:
        return AppColors.warn(context);
      case CalmObservationKind.info:
        return AppColors.accent(context);
      case CalmObservationKind.success:
        return AppColors.ok(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _kindColor(context);

    return Material(
      color: AppColors.card(context),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line(context)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    kindLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  color: AppColors.ink(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: AppColors.ink70(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

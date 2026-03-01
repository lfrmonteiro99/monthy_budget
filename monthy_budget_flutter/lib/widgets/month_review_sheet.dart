import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../utils/month_review.dart';
import '../utils/formatters.dart';

void showMonthReviewSheet({
  required BuildContext context,
  required MonthReviewResult review,
  VoidCallback? onAskAI,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => _MonthReviewContent(
        scrollController: scrollController,
        review: review,
        onAskAI: onAskAI,
      ),
    ),
  );
}

class _MonthReviewContent extends StatelessWidget {
  final ScrollController scrollController;
  final MonthReviewResult review;
  final VoidCallback? onAskAI;

  const _MonthReviewContent({
    required this.scrollController,
    required this.review,
    this.onAskAI,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = review.totalDifference > 0;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text(
          S.of(context).monthReviewTitle(review.monthLabel),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),

        // Totals
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _stat(S.of(context).monthReviewPlanned, formatCurrency(review.totalPlanned), const Color(0xFF64748B))),
                  Expanded(child: _stat(S.of(context).monthReviewActual, formatCurrency(review.totalActual), const Color(0xFF1E293B))),
                  Expanded(
                    child: _stat(
                      S.of(context).monthReviewDifference,
                      '${isOver ? '+' : ''}${formatCurrency(review.totalDifference)}',
                      isOver ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              if (review.foodBudget > 0) ...[
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.of(context).monthReviewFood, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    Text(
                      S.of(context).monthReviewFoodValue(formatCurrency(review.foodActual), formatCurrency(review.foodBudget)),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: review.foodActual > review.foodBudget
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Top deviations
        if (review.deviations.isNotEmpty) ...[
          Text(
            S.of(context).monthReviewTopDeviations,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          ...review.deviations.take(3).map((d) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text(
                            '${formatCurrency(d.planned)} → ${formatCurrency(d.actual)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${d.difference > 0 ? '+' : ''}${formatCurrency(d.difference)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: d.difference > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          ),
                        ),
                        Text(
                          '${d.difference > 0 ? '+' : ''}${(d.percentChange * 100).toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
        ],

        // Suggestions
        Text(
          S.of(context).monthReviewSuggestions,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        ...review.suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  Expanded(
                    child: Text(s, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ),
                ],
              ),
            )),

        // AI button
        if (onAskAI != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAskAI,
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: Text(S.of(context).monthReviewAiAnalysis),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

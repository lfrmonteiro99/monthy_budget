import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import 'calm/calm.dart';

enum ExportFormat { pdf, csv, monthlySummary }

Future<ExportFormat?> showExportSheet(BuildContext context) {
  final l10n = S.of(context);
  return CalmBottomSheet.show<ExportFormat>(
    context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.exportTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(ctx),
              ),
            ),
          ),
          CalmListTile(
            leadingIcon: Icons.picture_as_pdf,
            leadingColor: AppColors.error(ctx),
            title: l10n.exportPdf,
            subtitle: l10n.exportPdfDesc,
            onTap: () => Navigator.pop(ctx, ExportFormat.pdf),
          ),
          CalmListTile(
            leadingIcon: Icons.table_chart,
            leadingColor: AppColors.success(ctx),
            title: l10n.exportCsv,
            subtitle: l10n.exportCsvDesc,
            onTap: () => Navigator.pop(ctx, ExportFormat.csv),
          ),
          CalmListTile(
            leadingIcon: Icons.summarize,
            leadingColor: AppColors.primary(ctx),
            title: l10n.exportMonthlySummary,
            subtitle: l10n.exportMonthlySummaryDesc,
            onTap: () => Navigator.pop(ctx, ExportFormat.monthlySummary),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

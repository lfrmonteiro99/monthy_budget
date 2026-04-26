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
          ListTile(
            leading: Icon(Icons.picture_as_pdf, color: AppColors.error(ctx)),
            title: Text(l10n.exportPdf),
            subtitle: Text(
              l10n.exportPdfDesc,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(ctx),
              ),
            ),
            onTap: () => Navigator.pop(ctx, ExportFormat.pdf),
          ),
          ListTile(
            leading: Icon(Icons.table_chart, color: AppColors.success(ctx)),
            title: Text(l10n.exportCsv),
            subtitle: Text(
              l10n.exportCsvDesc,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(ctx),
              ),
            ),
            onTap: () => Navigator.pop(ctx, ExportFormat.csv),
          ),
          ListTile(
            leading: Icon(Icons.summarize, color: AppColors.primary(ctx)),
            title: Text(l10n.exportMonthlySummary),
            subtitle: Text(
              l10n.exportMonthlySummaryDesc,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(ctx),
              ),
            ),
            onTap: () => Navigator.pop(ctx, ExportFormat.monthlySummary),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

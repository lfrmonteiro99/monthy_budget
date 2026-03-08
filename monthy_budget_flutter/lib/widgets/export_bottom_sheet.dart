import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

enum ExportFormat { pdf, csv }

Future<ExportFormat?> showExportSheet(BuildContext context) {
  final l10n = S.of(context);
  return showModalBottomSheet<ExportFormat>(
    showDragHandle: true,
    context: context,
    backgroundColor: AppColors.surface(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
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
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

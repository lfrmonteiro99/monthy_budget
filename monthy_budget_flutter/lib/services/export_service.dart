import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/actual_expense.dart';
import '../models/budget_summary.dart';

class ExportService {
  Future<Uint8List> generatePdf({
    required String monthLabel,
    required List<CategoryBudgetSummary> summaries,
    required List<ActualExpense> expenses,
    required String Function(String) categoryLabelMap,
    required List<String> headerLabels,
    required String Function(double) formatCurrency,
    required String reportTitle,
    required String budgetVsActualTitle,
    required String expenseDetailTitle,
  }) async {
    final pdf = pw.Document();

    final totalBudgeted = summaries.fold(0.0, (s, e) => s + e.budgeted);
    final totalActual = summaries.fold(0.0, (s, e) => s + e.actual);
    final totalRemaining = totalBudgeted - totalActual;

    final sortedExpenses = List<ActualExpense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              reportTitle,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              monthLabel,
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
            pw.Divider(),
          ],
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ),
        build: (context) => [
          // Budget vs Actual table
          pw.Text(
            budgetVsActualTitle,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.grey200),
            headers: headerLabels.take(4).toList(),
            data: [
              ...summaries.map((s) => [
                    categoryLabelMap(s.category),
                    formatCurrency(s.budgeted),
                    formatCurrency(s.actual),
                    formatCurrency(s.remaining),
                  ]),
              [
                'Total',
                formatCurrency(totalBudgeted),
                formatCurrency(totalActual),
                formatCurrency(totalRemaining),
              ],
            ],
          ),
          pw.SizedBox(height: 24),

          // Expense detail table
          pw.Text(
            expenseDetailTitle,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          if (sortedExpenses.isEmpty)
            pw.Text('—', style: const pw.TextStyle(fontSize: 10))
          else
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey200),
              headers: headerLabels.skip(4).toList(),
              data: sortedExpenses.map((e) {
                final dateStr =
                    '${e.date.day.toString().padLeft(2, '0')}/${e.date.month.toString().padLeft(2, '0')}/${e.date.year}';
                return [
                  dateStr,
                  categoryLabelMap(e.category),
                  e.description ?? '',
                  formatCurrency(e.amount),
                ];
              }).toList(),
            ),
        ],
      ),
    );

    return pdf.save();
  }

  String generateCsv({
    required List<ActualExpense> expenses,
    required String Function(String) categoryLabelMap,
    required List<String> headerRow,
  }) {
    final sortedExpenses = List<ActualExpense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final rows = <List<String>>[
      headerRow,
      ...sortedExpenses.map((e) {
        final dateStr =
            '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
        return [
          dateStr,
          categoryLabelMap(e.category),
          e.description ?? '',
          e.amount.toStringAsFixed(2),
        ];
      }),
    ];

    return const ListToCsvConverter().convert(rows);
  }

  /// Generates a multi-section CSV with income, budget vs actual,
  /// expense detail, and a monthly summary including savings rate.
  String generateMonthlySummaryCsv({
    required String monthLabel,
    required BudgetSummary budgetSummary,
    required List<CategoryBudgetSummary> categorySummaries,
    required List<ActualExpense> expenses,
    required String Function(String) categoryLabelMap,
    required String Function(double) formatCurrency,
    required String sectionIncome,
    required String sectionBudgetVsActual,
    required String sectionExpenses,
    required String sectionSummary,
    required String headerCategory,
    required String headerBudgeted,
    required String headerActual,
    required String headerRemaining,
    required String headerDate,
    required String headerDescription,
    required String headerAmount,
    required String labelTotalIncome,
    required String labelGrossIncome,
    required String labelDeductions,
    required String labelTotalExpenses,
    required String labelNetLiquidity,
    required String labelSavingsRate,
    required String labelTotal,
  }) {
    const converter = ListToCsvConverter();
    final rows = <List<String>>[];

    // Title row
    rows.add([monthLabel]);
    rows.add([]);

    // --- Income section ---
    rows.add([sectionIncome]);
    rows.add([labelGrossIncome, formatCurrency(budgetSummary.totalGross)]);
    rows.add([labelDeductions, formatCurrency(budgetSummary.totalDeductions)]);
    rows.add([
      labelTotalIncome,
      formatCurrency(budgetSummary.totalNetWithMeal),
    ]);
    rows.add([]);

    // --- Budget vs Actual section ---
    rows.add([sectionBudgetVsActual]);
    rows.add([headerCategory, headerBudgeted, headerActual, headerRemaining]);

    final totalBudgeted =
        categorySummaries.fold(0.0, (s, e) => s + e.budgeted);
    final totalActual = categorySummaries.fold(0.0, (s, e) => s + e.actual);
    final totalRemaining = totalBudgeted - totalActual;

    for (final s in categorySummaries) {
      rows.add([
        categoryLabelMap(s.category),
        formatCurrency(s.budgeted),
        formatCurrency(s.actual),
        formatCurrency(s.remaining),
      ]);
    }
    rows.add([
      labelTotal,
      formatCurrency(totalBudgeted),
      formatCurrency(totalActual),
      formatCurrency(totalRemaining),
    ]);
    rows.add([]);

    // --- Expense Detail section ---
    rows.add([sectionExpenses]);
    rows.add([headerDate, headerCategory, headerDescription, headerAmount]);

    final sortedExpenses = List<ActualExpense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    for (final e in sortedExpenses) {
      final dateStr =
          '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}';
      rows.add([
        dateStr,
        categoryLabelMap(e.category),
        e.description ?? '',
        formatCurrency(e.amount),
      ]);
    }
    rows.add([]);

    // --- Monthly Summary section ---
    rows.add([sectionSummary]);
    rows.add([
      labelTotalIncome,
      formatCurrency(budgetSummary.totalNetWithMeal),
    ]);
    rows.add([
      labelTotalExpenses,
      formatCurrency(totalActual),
    ]);
    rows.add([
      labelNetLiquidity,
      formatCurrency(budgetSummary.netLiquidity),
    ]);
    rows.add([
      labelSavingsRate,
      '${(budgetSummary.savingsRate * 100).toStringAsFixed(2)}%',
    ]);

    return converter.convert(rows);
  }

  Future<File> writeTempFile(String filename, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    return file.writeAsBytes(bytes);
  }
}

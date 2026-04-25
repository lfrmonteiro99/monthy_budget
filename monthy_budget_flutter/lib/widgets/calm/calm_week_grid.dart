import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// One row in a [CalmWeekGrid]. Carries a left-axis label and 7 cell
/// strings (one per weekday). Use empty string for empty cells; the cell
/// renders a thin dash placeholder.
class CalmWeekGridRow {
  const CalmWeekGridRow({
    required this.label,
    required this.cells,
  });

  /// Row label rendered in the left gutter (e.g. `'Almoço'`).
  final String label;

  /// 7 cell labels, Mon → Sun.
  final List<String> cells;
}

/// 7-day × N-meal compact grid used on the Ementa screen (mockup #3).
///
/// **Geometry:**
/// - Header row (day names) — 28 high.
/// - Each meal row — min height 48.
/// - Left gutter (row label column) — 56 wide.
/// - Day cells — equal-width, separated by 4px horizontal gap (achieved via
///   `Padding`).
/// - Selected cell — 1.5px ink border, radius 8, ink text.
/// - Unselected cell — no border, ink70 text.
///
/// **Selection state:** caller supplies a `Set<(int row, int day)>` of
/// selected coordinates. The grid does NOT manage internal selection state —
/// the meal-planner data layer is the source of truth.
class CalmWeekGrid extends StatelessWidget {
  const CalmWeekGrid({
    super.key,
    required this.days,
    required this.rows,
    this.selected = const {},
    this.onCellTap,
  });

  /// Day labels for the header row (length must be 7). E.g.
  /// `['Seg','Ter','Qua','Qui','Sex','Sáb','Dom']`.
  final List<String> days;

  /// One [CalmWeekGridRow] per meal slot.
  final List<CalmWeekGridRow> rows;

  /// Set of `(row, day)` index pairs that should render as selected.
  /// Use a `Set<(int row, int day)>` (Dart records).
  final Set<(int, int)> selected;

  /// Tap handler invoked with `(row, day)` indices.
  final void Function(int row, int day)? onCellTap;

  @override
  Widget build(BuildContext context) {
    assert(days.length == 7, 'CalmWeekGrid requires exactly 7 day labels.');
    assert(rows.every((r) => r.cells.length == 7),
        'Each CalmWeekGridRow must have 7 cells.');

    final dayHeader = Row(
      children: [
        const SizedBox(width: 56),
        for (final d in days)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                d,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink50(context),
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
      ],
    );

    Widget mealRow(int rowIdx, CalmWeekGridRow row) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  row.label,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink70(context),
                  ),
                ),
              ),
            ),
            for (var d = 0; d < 7; d++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _Cell(
                    text: row.cells[d],
                    isSelected: selected.contains((rowIdx, d)),
                    onTap: onCellTap == null ? null : () => onCellTap!(rowIdx, d),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        dayHeader,
        const SizedBox(height: 8),
        for (var i = 0; i < rows.length; i++) mealRow(i, rows[i]),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      constraints: const BoxConstraints(minHeight: 44),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: AppColors.ink(context), width: 1.5)
            : null,
      ),
      child: Text(
        text.isEmpty ? '—' : text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: text.isEmpty
              ? AppColors.ink50(context)
              : (isSelected
                  ? AppColors.ink(context)
                  : AppColors.ink70(context)),
          height: 1.2,
        ),
      ),
    );
    if (onTap == null) return inner;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: inner,
    );
  }
}

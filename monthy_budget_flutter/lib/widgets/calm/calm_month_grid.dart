import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/models/meal_settings.dart';
import 'package:monthly_management/theme/app_colors.dart';

/// Month grid for the meal planner. Pure presentation, modeled on
/// [CalmWeekGrid] geometry: equal-width columns, 4px gaps, rounded cells,
/// Inter 11. Each day cell shows its number plus one dot per [MealType]
/// present that day (missing types render muted).
class CalmMonthGrid extends StatelessWidget {
  const CalmMonthGrid({
    super.key,
    required this.year,
    required this.month,
    required this.mealsByDay,
    required this.weekdayLabels,
    required this.onDayTap,
    this.today,
    this.selectedDay,
  });

  final int year;
  final int month;
  final Map<int, Set<MealType>> mealsByDay;
  final List<String> weekdayLabels;
  final void Function(int day) onDayTap;
  final DateTime? today;
  final int? selectedDay;

  static const _order = [
    MealType.breakfast,
    MealType.lunch,
    MealType.snack,
    MealType.dinner,
  ];

  @override
  Widget build(BuildContext context) {
    assert(weekdayLabels.length == 7, 'weekdayLabels must have length 7');
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Monday-first offset: DateTime.weekday is Mon=1..Sun=7.
    final leading = DateTime(year, month, 1).weekday - 1;
    final totalCells = leading + daysInMonth;
    final rows = (totalCells / 7).ceil();

    Widget header() => Row(
          children: [
            for (final d in weekdayLabels)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
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

    Widget cell(int cellIndex) {
      final dayNum = cellIndex - leading + 1;
      if (dayNum < 1 || dayNum > daysInMonth) {
        return const Expanded(child: SizedBox.shrink());
      }
      final present = mealsByDay[dayNum] ?? const <MealType>{};
      final isToday = today != null &&
          today!.year == year &&
          today!.month == month &&
          today!.day == dayNum;
      final isSelected = selectedDay == dayNum;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: InkWell(
            onTap: () => onDayTap(dayNum),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: (isSelected || isToday)
                    ? Border.all(color: AppColors.ink(context), width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$dayNum',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.ink(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final t in _order)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: present.contains(t)
                                  ? AppColors.primary(context)
                                  : AppColors.ink50(context)
                                      .withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header(),
        const SizedBox(height: 4),
        for (var r = 0; r < rows; r++)
          Row(children: [for (var c = 0; c < 7; c++) cell(r * 7 + c)]),
      ],
    );
  }
}
